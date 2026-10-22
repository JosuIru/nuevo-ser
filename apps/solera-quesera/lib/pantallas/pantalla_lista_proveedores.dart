import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/proveedor_leche.dart';

class PantallaListaProveedores extends StatefulWidget {
  PantallaListaProveedores({super.key});
  @override
  State<PantallaListaProveedores> createState() => _PantallaListaProveedoresState();
}

class _PantallaListaProveedoresState extends State<PantallaListaProveedores> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  List<ProveedorLeche> _proveedores = [];
  final _buscador = TextEditingController();

  @override
  void initState() { super.initState(); _recargar(); }
  @override
  void dispose() { _buscador.dispose(); super.dispose(); }

  Future<void> _recargar() async {
    final p = await _bd.listarProveedores();
    if (mounted) setState(() => _proveedores = p);
  }

  List<ProveedorLeche> get _filtrados {
    final q = _buscador.text.toLowerCase().trim();
    if (q.isEmpty) return _proveedores;
    return _proveedores.where((p) => p.nombre.toLowerCase().contains(q) || p.nif.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final f = _filtrados;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('proveedores_de_leche')), actions: [if (_proveedores.isNotEmpty) Text('${_proveedores.length}', style: t.textTheme.bodyMedium)]),
      body: Column(children: [
        if (_proveedores.isNotEmpty) BarraBusqueda(controlador: _buscador, onChanged: (_) => setState(() {}), sugerencia: 'Buscar proveedor…'),
        Expanded(child: _proveedores.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.person_outline, size: 64, color: t.colorScheme.outline), SizedBox(height: 16), Text(SoleraL10n.t('sin_proveedores'), style: t.textTheme.titleMedium), SizedBox(height: 8), FilledButton.icon(onPressed: () => _editar(null), icon: Icon(Icons.add), label: Text(SoleraL10n.t('anadir_proveedor')))]))
          : RefreshIndicator(onRefresh: _recargar, child: ListView.builder(padding: const EdgeInsets.all(8), itemCount: f.length, itemBuilder: (_, i) {
              final p = f[i];
              return Card(child: ListTile(
                leading: CircleAvatar(backgroundColor: p.esPropio ? Colors.blue.withAlpha(30) : Colors.amber.withAlpha(30), child: Icon(p.esPropio ? Icons.home : Icons.person, color: p.esPropio ? Colors.blue : Colors.amber)),
                title: Text(p.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${p.tipoLeche} · ${p.explotacionGanadera}', style: TextStyle(fontSize: 12)),
                trailing: PopupMenuButton<String>(onSelected: (a) { if (a == 'editar') _editar(p); else if (a == 'borrar') _borrar(p); },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit), title: Text(SoleraL10n.t('editar')))),
                    PopupMenuItem(value: 'borrar', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text(SoleraL10n.t('borrar'), style: TextStyle(color: Colors.red)))),
                  ]),
                onTap: () => _editar(p),
              ));
            })),
        ),
      ]),
      floatingActionButton: FloatingActionButton(heroTag: 'fab_prov', onPressed: () => _editar(null), child: Icon(Icons.add)),
    );
  }

  void _editar(ProveedorLeche? e) => Navigator.push(context, MaterialPageRoute(builder: (_) => _EditarProveedor(p: e, onOk: _recargar)));
  Future<void> _borrar(ProveedorLeche p) async {
    final ok = await DialogoConfirmacion.mostrar(context, titulo: SoleraL10n.t('borrar_proveedor'), mensaje: '¿Borrar ${p.nombre}?', textoConfirmar: SoleraL10n.t('borrar'), esPeligroso: true);
    if (ok && p.id != null) { await _bd.borrarProveedor(p.id!); await _recargar(); }
  }
}

class _EditarProveedor extends StatefulWidget {
  final ProveedorLeche? p; final VoidCallback onOk;
  _EditarProveedor({this.p, required this.onOk});
  @override
  State<_EditarProveedor> createState() => _EditarProveedorState();
}

class _EditarProveedorState extends State<_EditarProveedor> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fk = GlobalKey<FormState>();
  late final _nomC, _nifC, _dirC, _expC;
  String _tipoLeche = 'oveja', _razaId = '';
  int? _numAnimales;
  bool _esPropio = false, _guardando = false;

  @override
  void initState() {
    super.initState();
    final r = widget.p;
    _nomC = TextEditingController(text: r?.nombre ?? '');
    _nifC = TextEditingController(text: r?.nif ?? '');
    _dirC = TextEditingController(text: r?.direccion ?? '');
    _expC = TextEditingController(text: r?.explotacionGanadera ?? '');
    _tipoLeche = r?.tipoLeche ?? 'oveja'; _razaId = r?.razaId ?? ''; _numAnimales = r?.numAnimales; _esPropio = r?.esPropio ?? false;
  }

  @override
  void dispose() { _nomC.dispose(); _nifC.dispose(); _dirC.dispose(); _expC.dispose(); super.dispose(); }

  Future<void> _guardar() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _guardando = true);
    await _bd.guardarProveedor(ProveedorLeche(nombre: _nomC.text, nif: _nifC.text, direccion: _dirC.text, explotacionGanadera: _expC.text, tipoLeche: _tipoLeche, razaId: _razaId, numAnimales: _numAnimales, esPropio: _esPropio, fechaCreacionMs: widget.p?.fechaCreacionMs ?? DateTime.now().millisecondsSinceEpoch));
    widget.onOk();
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.p == null ? "Creado" : "Actualizado"}: ${_nomC.text}'))); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.p != null ? 'Editar proveedor' : 'Nuevo proveedor')),
    body: Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
      SwitchListTile(title: Text(SoleraL10n.t('rebano_propio')), subtitle: Text('Activado si es tu propia explotación'), value: _esPropio, onChanged: (v) => setState(() => _esPropio = v)),
      TextFormField(controller: _nomC, decoration: InputDecoration(labelText: 'Nombre / razón social', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null),
      SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _nifC, decoration: InputDecoration(labelText: 'NIF', border: OutlineInputBorder(), isDense: true))), SizedBox(width: 8), Expanded(child: TextFormField(controller: _expC, decoration: InputDecoration(labelText: 'Explotación ganadera', border: OutlineInputBorder(), isDense: true)))]),
      SizedBox(height: 12),
      DropdownButtonFormField<String>(decoration: InputDecoration(labelText: 'Tipo de leche', border: OutlineInputBorder()), initialValue: _tipoLeche, items: const [DropdownMenuItem(value: 'oveja', child: Text('Leche de oveja')), DropdownMenuItem(value: 'cabra', child: Text('Leche de cabra')), DropdownMenuItem(value: 'vaca', child: Text('Leche de vaca')), DropdownMenuItem(value: 'mixto', child: Text('Mezcla'))], onChanged: (v) => setState(() => _tipoLeche = v ?? 'oveja')),
      SizedBox(height: 12),
      TextFormField(decoration: InputDecoration(labelText: 'Raza (ID del catálogo)', border: OutlineInputBorder(), helperText: 'latxa, carranzana, manchega…'), initialValue: _razaId, onChanged: (v) => _razaId = v),
      SizedBox(height: 12),
      TextFormField(decoration: InputDecoration(labelText: 'Número de animales', border: OutlineInputBorder()), initialValue: _numAnimales?.toString() ?? '', keyboardType: TextInputType.number, validator: validarEnteroOpcional, onChanged: (v) => _numAnimales = leerEntero(v)),
      SizedBox(height: 24),
      FilledButton(onPressed: _guardando ? null : _guardar, child: _guardando ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.p != null ? 'Guardar cambios' : 'Crear proveedor')),
    ])),
  );
}
