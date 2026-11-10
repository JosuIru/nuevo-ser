import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/base_datos.dart';
import '../modelos/lote_produccion.dart';
import '../utiles/textos_quesera.dart';

class PantallaNuevoLote extends StatefulWidget {
  const PantallaNuevoLote({super.key});
  @override
  State<PantallaNuevoLote> createState() => _PantallaNuevoLoteState();
}

class _PantallaNuevoLoteState extends State<PantallaNuevoLote> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fk = GlobalKey<FormState>();
  DateFormat get _ff => DateFormat('d MMM yyyy', localeFechasQuesera());
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
    final vol = leerNumero(_volC.text, nullSiAmbiguo: true) ?? 0; final peso = leerNumero(_pesoC.text, nullSiAmbiguo: true) ?? 0; final np = leerEntero(_numPieC.text) ?? 0;
    try {
      final nl = await _bd.siguienteNumeroLote(_fecha);
      final lid = await _bd.guardarLote(LoteProduccion(numeroLote: nl, fechaMs: _fecha.millisecondsSinceEpoch, recetaId: _recetaId ?? 0, tipoQuesoId: _tipoQueso, doId: _doId.isEmpty ? null : _doId, partidasLecheUsadasJson: _partidasIds.toString(), volumenLecheTotal: vol, pesoTotalObtenido: peso, rendimientoReal: peso > 0 ? vol / peso : 0, numPiezasProducidas: np, pesoMedioPieza: np > 0 ? peso / np : 0, fermentoNombre: _fermC.text, fermentoLoteComercial: _fermLotC.text, cuajoTipo: _cuajoC.text, cuajoLoteComercial: _cuajoLotC.text, salLote: _salC.text, tempCoagulacion: leerNumero(_tempCoagC.text) ?? 30, tiempoCoagMinutos: leerEntero(_tiempoCoagC.text) ?? 30, phCuajada: leerNumero(_phC.text), estado: 'fresca', notas: _notasC.text, fechaCreacionMs: DateTime.now().millisecondsSinceEpoch));
      if (lid > 0 && np > 0) await _bd.generarPiezasParaLote(lid, nl, np, np > 0 ? peso / np : 0);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.tf('ques.lote_creado', {'lote': nl, 'n': np})))); Navigator.pop(context); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${SoleraL10n.t('error')}: $e'))); }
    finally { if (mounted) setState(() => _guardando = false); }
  }

  @override
  void dispose() { _volC.dispose(); _pesoC.dispose(); _numPieC.dispose(); _fermC.dispose(); _fermLotC.dispose(); _cuajoC.dispose(); _cuajoLotC.dispose(); _salC.dispose(); _tempCoagC.dispose(); _tiempoCoagC.dispose(); _phC.dispose(); _notasC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(SoleraL10n.t('ques.nuevo_lote'))),
    body: _cargando ? const Center(child: CircularProgressIndicator()) : Form(key: _fk, child: ListView(padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)), children: [
      ListTile(leading: const Icon(Icons.calendar_today), title: Text(_ff.format(_fecha)), trailing: const Icon(Icons.edit), onTap: () async { final p = await showDatePicker(context: context, initialDate: _fecha, firstDate: DateTime(2020), lastDate: DateTime.now()); if (p != null) setState(() => _fecha = p); }),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(decoration: InputDecoration(labelText: SoleraL10n.t('ques.receta'), border: const OutlineInputBorder()), items: _recetas.map((r) => DropdownMenuItem<int>(value: r.id as int, child: Text(r.nombre as String))).toList(), onChanged: (id) { setState(() { _recetaId = id; final r = _recetas.firstWhere((r) => r.id == id, orElse: () => null); if (r != null) { _tipoQueso = r.tipoQuesoId ?? ''; _doId = r.doId ?? ''; _rendEsp = r.rendimientoEsperado ?? 8; _tempCoagC.text = (r.tempCoagulacion ?? 30).toString(); _tiempoCoagC.text = (r.tiempoCoagMinutos ?? 30).toString(); _cuajoC.text = r.tipoCuajo ?? 'animal'; } }); }),
      const SizedBox(height: 16),
      Text(SoleraL10n.t('ques.partidas_de_leche_usadas'), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ..._partidas.cast<Map<String, Object?>>().map((p) { final id = p['id'] as int; return CheckboxListTile(dense: true, title: Text(SoleraL10n.tf('ques.partida_n_litros', {'id': id, 'litros': (p['volumen_litros'] as num?)?.toDouble() ?? 0})), value: _partidasIds.contains(id), onChanged: (s) { setState(() { if (s == true) _partidasIds.add(id); else _partidasIds.remove(id); }); }); }),
      const SizedBox(height: 16),
      TextFormField(controller: _volC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.volumen_total_leche_l'), border: const OutlineInputBorder(), suffixText: 'L'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? SoleraL10n.t('ques.requerido') : validarNumeroOpcional(v, nullSiAmbiguo: true)),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: TextFormField(controller: _pesoC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.peso_total_obtenido_kg'), border: const OutlineInputBorder(), suffixText: 'kg'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? SoleraL10n.t('ques.requerido') : validarNumeroOpcional(v, nullSiAmbiguo: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _numPieC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.numero_de_piezas'), border: const OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? SoleraL10n.t('ques.requerido') : validarEnteroOpcional(v)))]),
      if (_rendEsp > 0) Text(SoleraL10n.tf('ques.rendimiento_esperado', {'n': _rendEsp}), style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 16),
      Text(SoleraL10n.t('ques.ingredientes'), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _fermC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.fermento'), border: const OutlineInputBorder(), isDense: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _fermLotC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.lote_del_fermento'), border: const OutlineInputBorder(), isDense: true)))]),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _cuajoC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.tipo_de_cuajo'), border: const OutlineInputBorder(), isDense: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _cuajoLotC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.lote_del_cuajo'), border: const OutlineInputBorder(), isDense: true)))]),
      const SizedBox(height: 8),
      TextFormField(controller: _salC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.sal_lote'), border: const OutlineInputBorder())),
      const SizedBox(height: 16),
      Text(SoleraL10n.t('ques.parametros_de_proceso'), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [Expanded(child: TextFormField(controller: _tempCoagC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.temp_coagulacion_c'), border: const OutlineInputBorder(), suffixText: '°C'), keyboardType: TextInputType.number, validator: (v) => validarNumeroOpcional(v, permitirNegativos: true))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: _tiempoCoagC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.tiempo_coag_min'), border: const OutlineInputBorder(), suffixText: 'min'), keyboardType: TextInputType.number, validator: validarEnteroOpcional))]),
      const SizedBox(height: 8),
      TextFormField(controller: _phC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.ph_cuajada_opcional'), border: const OutlineInputBorder()), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: validarNumeroOpcional),
      const SizedBox(height: 12),
      TextFormField(controller: _notasC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.notas'), border: const OutlineInputBorder()), maxLines: 3),
      const SizedBox(height: 24),
      FilledButton(onPressed: _guardando ? null : _guardar, child: _guardando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(SoleraL10n.t('ques.guardar_lote'))),
    ])),
  );
}
