import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../datos/base_datos.dart';
import '../datos/sembrador_datos.dart';
import '../modelos/lote_produccion.dart';
import '../modelos/simulacion_trazabilidad.dart';
import '../servicios/generador_informe_simulacion.dart';

class PantallaSimulacionTrazabilidad extends StatefulWidget {
  const PantallaSimulacionTrazabilidad({super.key});
  @override
  State<PantallaSimulacionTrazabilidad> createState() => _PantallaSimulacionTrazabilidadState();
}

class _PantallaSimulacionTrazabilidadState extends State<PantallaSimulacionTrazabilidad> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fd = DateFormat('d MMM yyyy HH:mm', 'es_ES');
  int _paso = 0;
  List<LoteProduccion> _lotes = [];
  LoteProduccion? _loteSel;
  bool _aleat = false;
  Map<String, Object?>? _result;
  bool _trazando = false;
  int _tIni = 0, _tFin = 0;
  List<SimulacionTrazabilidad> _sims = [];
  final _inspC = TextEditingController(), _realC = TextEditingController(), _notasC = TextEditingController();
  bool _sembrando = false;

  @override
  void initState() { super.initState(); _cargar(); _cargarSims(); }
  Future<void> _cargar() async { _lotes = await _bd.listarLotes(); if (mounted) setState(() {}); }
  Future<void> _cargarSims() async { _sims = await _bd.listarSimulaciones(); if (mounted) setState(() {}); }

  Future<void> _sembrar() async { setState(() => _sembrando = true); await SembradorDatos.instancia.sembrar(); await _cargar(); if (mounted) setState(() => _sembrando = false); }

  Future<void> _selAleat() async {
    final l = await _bd.loteAleatorio();
    if (l == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay lotes registrados'))); return; }
    setState(() { _loteSel = l; _aleat = true; });
  }

  Future<void> _ejecutar() async {
    if (_loteSel?.id == null) return;
    setState(() { _trazando = true; _tIni = DateTime.now().millisecondsSinceEpoch; });
    _result = await _bd.trazarCompleta(_loteSel!.id!);
    setState(() { _tFin = DateTime.now().millisecondsSinceEpoch; _trazando = false; _paso = 2; });
  }

  int get _tSeg => (_tFin - _tIni) ~/ 1000;
  bool get _completa => _result != null && ((_result!['partidas_leche'] as List?)?.isNotEmpty ?? false) && ((_result!['piezas'] as List?)?.isNotEmpty ?? false);

  List<String> get _verifs {
    final r = _result; if (r == null) return [];
    final pts = <String>[];
    void add(bool ok, String s, String e) => pts.add('${ok ? "✅" : "❌"} $s${ok ? "" : " — $e"}');
    add((r['partidas_leche'] as List?)?.isNotEmpty ?? false, 'Trazabilidad hacia atrás', 'No hay partidas');
    add((r['piezas'] as List?)?.isNotEmpty ?? false, 'Piezas registradas', 'Faltan piezas');
    add(((r['fermento'] as String?)?.isNotEmpty ?? false), 'Fermento registrado', 'Falta fermento');
    add(((r['cuajo'] as String?)?.isNotEmpty ?? false), 'Cuajo registrado', 'Falta cuajo');
    add((r['eventos_curacion'] as List?)?.isNotEmpty ?? false, 'Eventos de curación', 'Sin eventos');
    add((r['analiticas'] as List?)?.isNotEmpty ?? false, 'Analíticas realizadas', 'Sin analíticas');
    add((r['ventas'] as List?)?.isNotEmpty ?? false, 'Ventas registradas', 'Sin ventas');
    return pts;
  }

  Future<void> _guardarSim() async {
    if (_loteSel == null || _result == null) return;
    await _bd.guardarSimulacion(SimulacionTrazabilidad(fechaMs: DateTime.now().millisecondsSinceEpoch, tipo: 'completa', elementoSimulado: '${_aleat ? "Aleatorio: " : ""}Lote ${_loteSel!.numeroLote}', aleatorio: _aleat, completa: _completa, resumen: _verifs.join('; '), resultadoJson: jsonEncode(_result), tiempoSegundos: _tSeg, realizadaPor: _realC.text.isNotEmpty ? _realC.text : 'Quesero/a', firmaInspector: _inspC.text, notas: _notasC.text, fechaCreacionMs: DateTime.now().millisecondsSinceEpoch));
    await _cargarSims();
    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulación archivada'))); }
  }

  Future<void> _genPdf() async {
    if (_result == null || _loteSel == null) return;
    final doc = await GeneradorInformeSimulacion().generar(resultado: _result!, loteSeleccionado: _loteSel!, aleatorio: _aleat, tiempoSegundos: _tSeg, verificaciones: _verifs, cadenaCompleta: _completa, inspector: _inspC.text, realizador: _realC.text, notas: _notasC.text);
    await Printing.sharePdf(bytes: await doc.save(), filename: 'simulacion_${_loteSel!.numeroLote}.pdf');
  }

  @override
  void dispose() { _inspC.dispose(); _realC.dispose(); _notasC.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Simulación de inspección'),
        actions: [TextButton(onPressed: _lotes.isEmpty ? _sembrar : null, child: _sembrando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cargar demo'))],
      ),
      body: _lotes.isEmpty
        ? _empty(t)
        : ListView(padding: const EdgeInsets.all(16), children: [
            _pasoInd(t), const SizedBox(height: 16),
            if (_paso == 0) _paso1(t),
            if (_paso >= 2 && _result != null) ...[_resultados(t), _verificacion(t), _archivo(t)],
            if (_sims.isNotEmpty) _historial(t),
          ]),
    );
  }

  Widget _empty(ThemeData t) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.analytics_outlined, size: 64, color: t.colorScheme.outline),
    const SizedBox(height: 16),
    const Text('Simulación de trazabilidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 12),
    const Text('Reproduce una inspección real según CE 178/2002.', textAlign: TextAlign.center),
    const SizedBox(height: 24),
    FilledButton.icon(onPressed: _sembrar, icon: const Icon(Icons.download), label: const Text('Cargar datos demo')),
  ])));

  Widget _pasoInd(ThemeData t) => Row(children: ['Seleccionar', 'Trazar', 'Verificar', 'Informe'].asMap().entries.map((e) => Expanded(child: Column(children: [
    CircleAvatar(radius: 14, backgroundColor: e.key <= _paso ? t.colorScheme.primary : t.colorScheme.outline.withAlpha(80), child: Icon(e.key < _paso ? Icons.check : Icons.circle_outlined, size: 16, color: e.key <= _paso ? Colors.white : Colors.grey)),
    Text(e.value, style: TextStyle(fontSize: 10, fontWeight: e.key <= _paso ? FontWeight.bold : FontWeight.normal, color: e.key <= _paso ? t.colorScheme.primary : Colors.grey)),
  ]))).toList());

  Widget _paso1(ThemeData t) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(Icons.touch_app, color: t.colorScheme.primary), const SizedBox(width: 8), Text('1. Seleccionar elemento', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
    DropdownButtonFormField<int>(decoration: const InputDecoration(labelText: 'Seleccionar lote', border: OutlineInputBorder(), isDense: true), items: _lotes.map((l) => DropdownMenuItem<int>(value: l.id!, child: Text('${l.numeroLote} — ${l.tipoQuesoId}'))).toList(), onChanged: (id) => setState(() { _loteSel = _lotes.firstWhere((l) => l.id == id); _aleat = false; }), value: _loteSel?.id),
    const SizedBox(height: 12),
    OutlinedButton.icon(onPressed: _selAleat, icon: const Icon(Icons.shuffle), label: const Text('Seleccionar lote al azar')),
    if (_loteSel != null) ...[const Divider(), Chip(avatar: Icon(_aleat ? Icons.shuffle : Icons.check, size: 16, color: _aleat ? Colors.orange : Colors.green), label: Text('${_aleat ? "Aleatorio: " : ""}${_loteSel!.numeroLote}')), const SizedBox(height: 16),
      FilledButton.icon(onPressed: _trazando ? null : _ejecutar, icon: _trazando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search), label: Text(_trazando ? 'Trazando…' : 'Ejecutar trazabilidad')),
    ],
  ])));

  Widget _resultados(ThemeData t) {
    final r = _result!;
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(Icons.account_tree, color: t.colorScheme.primary), const SizedBox(width: 8), Text('Resultado', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
      Text('${_loteSel!.numeroLote} · ${_tSeg}s', style: t.textTheme.bodySmall),
      _secRes('Hacia atrás', (r['partidas_leche'] as List?) ?? [], (x) => Text('#${x['partida_id']} · ${x['proveedor']} · ${x['volumen']}L', style: const TextStyle(fontSize: 12))),
      _secRes('Piezas', (r['piezas'] as List?) ?? [], (x) => Text('${x['numero']} · ${x['estado']}', style: const TextStyle(fontSize: 12))),
      _secRes('Eventos curación', (r['eventos_curacion'] as List?) ?? [], (x) => Text('${x['tipo']} · ${x['pieza']}', style: const TextStyle(fontSize: 12))),
      _secRes('Analíticas', (r['analiticas'] as List?) ?? [], (x) => Text('${x['tipo']}: ${x['conforme'] == true ? "✅" : "❌"}', style: const TextStyle(fontSize: 12))),
      _secRes('Ventas', (r['ventas'] as List?) ?? [], (x) => Text('${x['cliente']} · ${x['total']}€', style: const TextStyle(fontSize: 12))),
    ])));
  }

  Widget _secRes(String tit, List items, Widget Function(dynamic) item) {
    if (items.isEmpty) return Padding(padding: const EdgeInsets.only(top: 4), child: Text('$tit: —', style: const TextStyle(color: Colors.grey, fontSize: 12)));
    return Padding(padding: const EdgeInsets.only(top: 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$tit (${items.length})', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
      ...items.take(3).map((x) => Padding(padding: const EdgeInsets.only(left: 8), child: item(x))),
      if (items.length > 3) Text('… y ${items.length - 3} más', style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ]));
  }

  Widget _verificacion(ThemeData t) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(Icons.verified, color: _completa ? Colors.green : Colors.orange), const SizedBox(width: 8), Text('Verificación', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
    ..._verifs.map((v) => Text(v, style: TextStyle(fontSize: 12, color: v.startsWith('✅') ? Colors.green.shade700 : Colors.red.shade700))),
    Row(children: [Icon(_completa ? Icons.check_circle : Icons.info_outline, color: _completa ? Colors.green : Colors.orange), const SizedBox(width: 8), Text(_completa ? 'Cadena completa' : 'Se detectaron roturas', style: TextStyle(fontWeight: FontWeight.bold, color: _completa ? Colors.green : Colors.orange))]),
  ])));

  Widget _archivo(ThemeData t) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(Icons.description_outlined, color: t.colorScheme.primary), const SizedBox(width: 8), Text('Archivar', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
    TextFormField(controller: _realC, decoration: const InputDecoration(labelText: 'Realizado por', border: OutlineInputBorder(), isDense: true, hintText: 'Tu nombre')),
    const SizedBox(height: 8), TextFormField(controller: _inspC, decoration: const InputDecoration(labelText: 'Inspector', border: OutlineInputBorder(), isDense: true, hintText: 'Nombre opcional')),
    const SizedBox(height: 8), TextFormField(controller: _notasC, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder(), isDense: true), maxLines: 2),
    const SizedBox(height: 16),
    FilledButton.icon(onPressed: _guardarSim, icon: Icon(Icons.save), label: Text("Guardar")),
    SizedBox(height: 8),
    OutlinedButton.icon(onPressed: _genPdf, icon: Icon(Icons.picture_as_pdf), label: Text("PDF")),
  ])));

  Widget _historial(ThemeData t) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(Icons.history, color: t.colorScheme.primary), const SizedBox(width: 8), Text('Historial', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Spacer(), Text('${_sims.length} ejercicios', style: t.textTheme.bodySmall)]),
    ..._sims.take(10).map((s) => ListTile(dense: true, leading: Icon(s.completa ? Icons.check_circle : Icons.warning_amber, color: s.completa ? Colors.green : Colors.orange), title: Text(s.elementoSimulado, style: const TextStyle(fontSize: 13)), subtitle: Text('${_fd.format(DateTime.fromMillisecondsSinceEpoch(s.fechaMs))} · ${s.tiempoSegundos}s', style: const TextStyle(fontSize: 11)))),
  ])));
}
