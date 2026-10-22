import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/base_datos.dart';
import '../modelos/lote_produccion.dart';
import '../utiles/validar_numero.dart';

class PantallaNuevoLote extends StatefulWidget {
  const PantallaNuevoLote({super.key});
  @override
  State<PantallaNuevoLote> createState() => _PantallaNuevoLoteState();
}

class _PantallaNuevoLoteState extends State<PantallaNuevoLote> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fk = GlobalKey<FormState>();
  final _ff = DateFormat('d MMM yyyy', 'es_ES');
  DateTime _fecha = DateTime.now();
  int? _recetaId;
  String _tipoQueso = '', _doId = '';
  final _partidasIds = <int>[];
  final _volC = TextEditingController(), _pesoC = TextEditingController(), _numPieC = TextEditingController();
  final _fermC = TextEditingController(), _fermLotC = TextEditingController(), _cuajoC = TextEditingController(text: 'animal');
  final _cuajoLotC = TextEditingController(), _salC = TextEditingController(), _tempCoagC = TextEditingController(text: '30');
  final _tiempoCoagC = TextEditingController(text: '30'), _phC = TextEditingController(), _notasC = TextEditingController();
  List _recetas = [], _partidas = [];
  double _rendEsp = 8; bool _guardando = false, _cargando = true;

  @override
  void initState() { super.initState(); _cargar(); }

  Future<void> _cargar() async {
    final rs = await _bd.listarRecetas(); final ps = await _bd.listarPartidasLeche();
    if (mounted) setState(() { _recetas = rs; _partidas = ps; _cargando = false; });
  }

  Future<void> _guardar() async {
    if (!_fk.currentState!.validate()) return; setState(() => _guardando = true);
    final vol = leerNumero(_volC.text, nullSiAmbiguo: true) ?? 0; final peso = leerNumero(_pesoC.text, nullSiAmbiguo: true) ?? 0; final np = int.tryParse(_numPieC.text) ?? 0;
    try {
      final nl = await _bd.siguienteNumeroLote(_fecha);
      final lid = await _bd.guardarLote(LoteProduccion(numeroLote: nl, fechaMs: _fecha.millisecondsSinceEpoch, recetaId: _recetaId ?? 0, tipoQuesoId: _tipoQueso, doId: _doId.isEmpty ? null : _doId, partidasLecheUsadasJson: _partidasIds.toString(), volumenLecheTotal: vol, pesoTotalObtenido: peso, rendimientoReal: peso > 0 ? vol / peso : 0, numPiezasProducidas: np, pesoMedioPieza: np > 0 ? peso / np : 0, fermentoNombre: _fermC.text, fermentoLoteComercial: _fermLotC.text, cuajoTipo: _cuajoC.text, cuajoLoteComercial: _cuajoLotC.text, salLote: _salC.text, tempCoagulacion: leerNumero(_tempCoagC.text) ?? 30, tiempoCoagMinutos: int.tryParse(_tiempoCoagC.text) ?? 30, phCuajada: leerNumero(_phC.text), estado: 'fresca', notas: _notasC.text, fechaCreacionMs: DateTime.now().millisecondsSinceEpoch));
      if (lid > 0 && np > 0) await _bd.generarPiezasParaLote(lid, nl, np, np > 0 ? peso / np : 0);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lote $nl creado ($np piezas)'))); Navigator.pop(context); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    finally { if (mounted) setState(() => _guardando = false); }
  }

  @override
  void dispose() { _volC.dispose(); _pesoC.dispose(); _numPieC.dispose(); _fermC.dispose(); _fermLotC.dispose(); _cuajoC.dispose(); _cuajoLotC.dispose(); _salC.dispose(); _tempCoagC.dispose(); _tiempoCoagC.dispose(); _phC.dispose(); _notasC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nuevo lote')),
    body: _cargando ? const Center(child: CircularProgressIndicator()) : Form(key: _fk, child: ListView(padding: const EdgeInsets.all(16), children: [
      ListTile(leading: const Icon(Icons.calendar_today), title: Text(_ff.format(_fecha)), trailing: const Icon(Icons.edit), onTap: () async { final p = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setState(() => _fecha = p); }),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(decoration: const InputDecoration(labelText: 'Receta', border: OutlineInputBorder()), items: _recetas.map((r) => DropdownMenuItem<int>(value: r.id as int, child: Text(r.nombre as String))).toList(), onChanged: (id) { setState(() { _recetaId = id; final r = _recetas.firstWhere((r) => r.id == id, orElse: () => null); if (r != null) { _tipoQueso = r.tipoQuesoId ?? ''; _doId = r.doId ?? ''; _rendEsp = r.rendimientoEsperado ?? 8; _tempCoagC.text = (r.tempCoagulacion ?? 30).toString(); _tiempoCoagC.text = (r.tiempoCoagMinutos ?? 30).toString(); _cuajoC.text = r.tipoCuajo ?? 'animal'; } }); }),
      const SizedBox(height: 16),
      Text('Partidas de leche usadas', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ..._partidas.cast<Map<String, Object?>>().map((p) { final id = p['id'] as int; return CheckboxListTile(dense: true, title: Text('Partida #$id — ${(p['volumen_litros'] as num?)?.toDouble() ?? 0}L'), value: _partidasIds.contains(id), onChanged: (s) { setState(() { if (s == true) _partidasIds.add(id); else _partidasIds.remove(id); }); }); }),
      const SizedBox(height: 16),
      TextFormField(controller: _volC, decoration: const InputDecoration(labelText: 'Volumen total de leche (L)', border: OutlineInputBorder(), suffixText: 'L'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : avisoNumeroNoValido(v, nullSiAmbiguo: true)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _pesoC, decoration: const InputDecoration(labelText: 'Peso total obtenido (kg)', border: OutlineInputBorder(), suffixText: 'kg'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : avisoNumeroNoValido(v, nullSiAmbiguo: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _numPieC, decoration: const InputDecoration(labelText: 'Nº piezas', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null))]),
      if (_rendEsp > 0) Text('Rendimiento esperado: $_rendEsp L/kg', style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 16),
      Text('Ingredientes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _fermC, decoration: const InputDecoration(labelText: 'Fermento', border: OutlineInputBorder(), isDense: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _fermLotC, decoration: const InputDecoration(labelText: 'Lote fermento', border: OutlineInputBorder(), isDense: true)))]),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _cuajoC, decoration: const InputDecoration(labelText: 'Tipo cuajo', border: OutlineInputBorder(), isDense: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _cuajoLotC, decoration: const InputDecoration(labelText: 'Lote cuajo', border: OutlineInputBorder(), isDense: true)))]),
      const SizedBox(height: 8),
      TextFormField(controller: _salC, decoration: const InputDecoration(labelText: 'Sal / lote', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      Text('Parámetros de proceso', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _tempCoagC, decoration: const InputDecoration(labelText: 'Temp. coagulación (°C)', border: OutlineInputBorder(), suffixText: '°C'), keyboardType: TextInputType.number, validator: avisoNumeroNoValido)), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _tiempoCoagC, decoration: const InputDecoration(labelText: 'Tiempo coag. (min)', border: OutlineInputBorder(), suffixText: 'min'), keyboardType: TextInputType.number))]),
      const SizedBox(height: 8),
      TextFormField(controller: _phC, decoration: const InputDecoration(labelText: 'pH de la cuajada (opcional)', border: OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: avisoNumeroNoValido),
      const SizedBox(height: 12),
      TextFormField(controller: _notasC, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder()), maxLines: 3),
      const SizedBox(height: 24),
      FilledButton(onPressed: _guardando ? null : _guardar, child: _guardando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Guardar lote')),
    ])),
  );
}
