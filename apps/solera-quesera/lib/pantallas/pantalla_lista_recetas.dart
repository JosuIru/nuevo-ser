import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/base_datos.dart';
import '../modelos/receta.dart';
import '../utiles/validar_numero.dart';

class PantallaListaRecetas extends StatefulWidget {
  const PantallaListaRecetas({super.key});
  @override
  State<PantallaListaRecetas> createState() => _PantallaListaRecetasState();
}

class _PantallaListaRecetasState extends State<PantallaListaRecetas> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  List<Receta> _recetas = [];
  @override
  void initState() { super.initState(); _recargar(); }
  Future<void> _recargar() async { final r = await _bd.listarRecetas(); if (mounted) setState(() => _recetas = r); }

  Future<void> _borrar(Receta r) async {
    if (r.id == null) return;
    final lotes = await _bd.listarLotesPorReceta(r.id!);
    final ok = await DialogoConfirmacion.mostrar(context, titulo: SoleraL10n.t('borrar_receta'),
      mensaje: lotes.isNotEmpty ? '${r.nombre} tiene ${lotes.length} lote(s) asociado(s).' : '¿Borrar "${r.nombre}"?',
      textoConfirmar: SoleraL10n.t('borrar'), esPeligroso: true);
    if (ok) { await _bd.borrarReceta(r.id!); await _recargar(); }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('recetas')), actions: [if (_recetas.isNotEmpty) Text('${_recetas.length}', style: t.textTheme.bodyMedium)]),
      body: _recetas.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.restaurant_menu_outlined, size: 64, color: t.colorScheme.outline), const SizedBox(height: 16), Text(SoleraL10n.t('no_hay_recetas'), style: t.textTheme.titleMedium), const SizedBox(height: 8), FilledButton.icon(onPressed: () => _editar(null), icon: const Icon(Icons.add), label: Text(SoleraL10n.t('crear_primera_receta')))]))
        : RefreshIndicator(onRefresh: _recargar, child: ListView.builder(padding: const EdgeInsets.all(8), itemCount: _recetas.length, itemBuilder: (_, i) { final r = _recetas[i];
            return Card(child: ListTile(
              leading: CircleAvatar(backgroundColor: r.doId != null ? Colors.green.withAlpha(30) : t.colorScheme.primary.withAlpha(30), child: Icon(Icons.restaurant_menu, color: r.doId != null ? Colors.green : t.colorScheme.primary)),
              title: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${r.tipoLeche} · Cuajo ${r.tipoCuajo} · Rend. ${r.rendimientoEsperado} L/kg · Curación ${r.curacionMinimaDias}d${r.doId != null ? " · DO: ${r.doId}" : ""}', style: const TextStyle(fontSize: 12)),
              trailing: PopupMenuButton<String>(onSelected: (a) { if (a == 'editar') _editar(r); else if (a == 'borrar') _borrar(r); },
                itemBuilder: (_) => [const PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))), const PopupMenuItem(value: 'borrar', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Borrar', style: TextStyle(color: Colors.red))))]),
              onTap: () => _editar(r),
            ));
          })),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_rec', onPressed: () => _editar(null), child: const Icon(Icons.add)),
    );
  }

  void _editar(Receta? e) => Navigator.push(context, MaterialPageRoute(builder: (_) => _EditarReceta(r: e, onOk: _recargar)));
}

class _EditarReceta extends StatefulWidget {
  final Receta? r; final VoidCallback onOk;
  const _EditarReceta({this.r, required this.onOk});
  @override
  State<_EditarReceta> createState() => _EditarRecetaState();
}

class _EditarRecetaState extends State<_EditarReceta> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fk = GlobalKey<FormState>();
  late final _nomC, _fermC;
  String _tipoLeche = 'oveja', _tipoCuajo = 'animal', _tamCuajada = 'medio', _tipoQuesoId = '', _doId = '';
  double _tempCoag = 30, _rend = 8, _tempCoc = 0;
  int _tiempoCoag = 30, _curacionDias = 60;
  double? _phSalado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState(); final r = widget.r;
    _nomC = TextEditingController(text: r?.nombre ?? ''); _fermC = TextEditingController(text: r?.fermento ?? '');
    _tipoLeche = r?.tipoLeche ?? 'oveja'; _tipoCuajo = r?.tipoCuajo ?? 'animal'; _tamCuajada = r?.tamCuajada ?? 'medio';
    _tempCoag = r?.tempCoagulacion ?? 30; _tiempoCoag = r?.tiempoCoagMinutos ?? 30; _rend = r?.rendimientoEsperado ?? 8;
    _curacionDias = r?.curacionMinimaDias ?? 60; _tipoQuesoId = r?.tipoQuesoId ?? ''; _doId = r?.doId ?? '';
    _tempCoc = r?.tempCocion ?? 0; _phSalado = r?.phSalado;
  }
  @override
  void dispose() { _nomC.dispose(); _fermC.dispose(); super.dispose(); }

  Future<void> _guardar() async {
    if (!_fk.currentState!.validate()) return; setState(() => _guardando = true);
    final rec = Receta(nombre: _nomC.text, tipoQuesoId: _tipoQuesoId, doId: _doId.isEmpty ? null : _doId, tipoLeche: _tipoLeche, fermento: _fermC.text, tipoCuajo: _tipoCuajo, tempCoagulacion: _tempCoag, tiempoCoagMinutos: _tiempoCoag, tamCuajada: _tamCuajada, tempCocion: _tempCoc > 0 ? _tempCoc : null, phSalado: _phSalado, rendimientoEsperado: _rend, curacionMinimaDias: _curacionDias);
    if (widget.r?.id != null) await _bd.actualizarReceta(widget.r!.id!, rec.toMap()); else await _bd.guardarReceta(rec);
    widget.onOk(); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.r == null ? "Creada" : "Actualizada"}: ${_nomC.text}'))); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.r != null ? 'Editar receta' : 'Nueva receta')),
    body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
      TextFormField(controller: _nomC, decoration: const InputDecoration(labelText: 'Nombre de la receta', border: OutlineInputBorder(), hintText: 'Ej: Idiazabal semicurado'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'ID tipo de queso', border: OutlineInputBorder(), helperText: 'idiazabal_semicurado…'), initialValue: _tipoQuesoId, onChanged: (v) => _tipoQuesoId = v)), const SizedBox(width: 8), Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'DO (opcional)', border: OutlineInputBorder(), helperText: 'idiazabal…'), initialValue: _doId, onChanged: (v) => _doId = v))]),
      const SizedBox(height: 16),
      Text('Tipo de leche', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      SegmentedButton<String>(segments: const [ButtonSegment(value: 'oveja', label: Text('Oveja')), ButtonSegment(value: 'cabra', label: Text('Cabra')), ButtonSegment(value: 'vaca', label: Text('Vaca')), ButtonSegment(value: 'mezcla', label: Text('Mezcla'))], selected: {_tipoLeche}, onSelectionChanged: (v) => setState(() => _tipoLeche = v.first)),
      const SizedBox(height: 16),
      Text('Ingredientes', style: DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(controller: _fermC, decoration: const InputDecoration(labelText: 'Fermento', border: OutlineInputBorder())),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Tipo de cuajo', border: OutlineInputBorder()), initialValue: _tipoCuajo, items: const [DropdownMenuItem(value: 'animal', child: Text('Animal (cordero)')), DropdownMenuItem(value: 'vegetal', child: Text('Vegetal (cardo)')), DropdownMenuItem(value: 'microbiano', child: Text('Microbiano'))], onChanged: (v) => setState(() => _tipoCuajo = v ?? 'animal')),
      const SizedBox(height: 16),
      Text('Parámetros de proceso', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Temp. coag. (°C)', border: OutlineInputBorder(), isDense: true), initialValue: _tempCoag.toString(), keyboardType: TextInputType.number, validator: avisoNumeroNoValido, onChanged: (v) => _tempCoag = leerNumero(v) ?? 30)), const SizedBox(width: 12), Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Tiempo coag. (min)', border: OutlineInputBorder(), isDense: true), initialValue: _tiempoCoag.toString(), keyboardType: TextInputType.number, onChanged: (v) => _tiempoCoag = int.tryParse(v) ?? 30))]),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: 'Tamaño de cuajada', border: OutlineInputBorder()), initialValue: _tamCuajada, items: const [DropdownMenuItem(value: 'grueso', child: Text('Grano grueso')), DropdownMenuItem(value: 'medio', child: Text('Grano medio')), DropdownMenuItem(value: 'fino', child: Text('Grano fino'))], onChanged: (v) => setState(() => _tamCuajada = v ?? 'medio')),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Temp. cocción (°C)', border: OutlineInputBorder(), isDense: true), initialValue: _tempCoc > 0 ? _tempCoc.toString() : '', keyboardType: TextInputType.number, validator: avisoNumeroNoValido, onChanged: (v) => _tempCoc = leerNumero(v) ?? 0)), const SizedBox(width: 12), Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'pH salado', border: OutlineInputBorder(), isDense: true), initialValue: _phSalado?.toString() ?? '', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: avisoNumeroNoValido, onChanged: (v) => _phSalado = leerNumero(v)))]),
      const SizedBox(height: 16),
      Text('Rendimiento y curación', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Rendimiento (L/kg)', border: OutlineInputBorder(), isDense: true), initialValue: _rend.toString(), keyboardType: TextInputType.number, validator: avisoNumeroNoValido, onChanged: (v) => _rend = leerNumero(v) ?? 8)), const SizedBox(width: 12), Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Curación mínima (días)', border: OutlineInputBorder(), isDense: true), initialValue: _curacionDias.toString(), keyboardType: TextInputType.number, onChanged: (v) => _curacionDias = int.tryParse(v) ?? 60))]),
      const SizedBox(height: 24),
      FilledButton(onPressed: _guardando ? null : _guardar, child: _guardando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.r != null ? 'Guardar cambios' : 'Crear receta')),
    ])),
  );
}
