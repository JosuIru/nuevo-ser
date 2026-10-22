import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/control_temperatura.dart';
import '../modelos/evento_curacion.dart';
import '../modelos/pieza.dart';

class PantallaCava extends StatefulWidget {
  const PantallaCava({super.key});
  @override
  State<PantallaCava> createState() => _PantallaCavaState();
}

class _PantallaCavaState extends State<PantallaCava> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _formatter = DateFormat('d MMM yyyy', 'es_ES');
  List<Pieza> _piezasAfinando = [], _piezasListas = [];
  Map<String, String> _tempsCava = {};
  final _tempC = TextEditingController(), _hrC = TextEditingController(), _cavaC = TextEditingController(text: 'Cava principal');

  @override
  void initState() { super.initState(); _recargar(); }

  Future<void> _recargar() async {
    final af = await _bd.listarPiezas(estado: 'afinando');
    final li = await _bd.listarPiezas(estado: 'lista');
    final tc = await _bd.ultimaTemperaturaPorCava();
    if (mounted) setState(() { _piezasAfinando = af; _piezasListas = li;
      _tempsCava = tc.map((k, v) => MapEntry(k, '${v.temperatura.toStringAsFixed(1)}°C / ${v.humedadRelativa.toStringAsFixed(0)}% HR')); });
  }

  Future<void> _regTemp() async {
    final t = leerNumero(_tempC.text); final h = leerNumero(_hrC.text);
    if (t == null || h == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce temperatura y humedad (p. ej. 12,5)'))); return; }
    await _bd.guardarControlTemperatura(ControlTemperatura(fechaMs: DateTime.now().millisecondsSinceEpoch, cavaId: _cavaC.text, temperatura: t, humedadRelativa: h));
    _tempC.clear(); _hrC.clear(); await _recargar();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.t('temperatura_registrada'))));
  }

  Future<void> _volteo(Pieza p) async {
    await _bd.guardarEventoCuracion(EventoCuracion(piezaId: p.id!, fechaMs: DateTime.now().millisecondsSinceEpoch, tipo: 'volteo', fechaCreacionMs: DateTime.now().millisecondsSinceEpoch));
    await _recargar();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Volteo registrado — ${p.numeroPieza}')));
  }

  Future<void> _marcarLista(Pieza p) async { await _bd.actualizarPieza(p.id!, {'estado': 'lista'}); await _recargar(); }

  @override
  void dispose() { _tempC.dispose(); _hrC.dispose(); _cavaC.dispose(); super.dispose(); }

  String _edad(int d) => d < 30 ? '$d días' : '${(d/30).floor()} meses${d%30 > 0 ? ' ${d%30} días' : ''}';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = _piezasAfinando.length + _piezasListas.length;
    return Scaffold(
      appBar: AppBar(title: Text('Cava ($total piezas)')),
      body: RefreshIndicator(onRefresh: _recargar, child: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Registro de temperatura', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(controller: _cavaC, decoration: const InputDecoration(labelText: 'Cava / cámara', border: OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextFormField(controller: _tempC, decoration: const InputDecoration(labelText: 'Temperatura (°C)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: TextFormField(controller: _hrC, decoration: const InputDecoration(labelText: 'Humedad (%)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number))]),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _regTemp, icon: const Icon(Icons.thermostat), label: const Text('Registrar')),
          if (_tempsCava.isNotEmpty) ..._tempsCava.entries.map((e) => Text('${e.key}: ${e.value}', style: t.textTheme.bodySmall)),
        ]))),
        const SizedBox(height: 16),
        Text('Afinando (${_piezasAfinando.length})', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_piezasAfinando.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(24), child: Text('No hay piezas en afinado', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))))
        else ..._piezasAfinando.map((p) => Card(child: ListTile(dense: true, title: Text(p.numeroPieza), subtitle: Text('${p.pesoActual?.toStringAsFixed(2) ?? p.pesoInicial.toStringAsFixed(2)} kg · ${_edad(p.edadDias)} · ${p.ubicacionActual}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.flip, size: 20), tooltip: 'Registrar volteo', onPressed: () => _volteo(p)), IconButton(icon: const Icon(Icons.check, size: 20, color: Colors.green), tooltip: 'Marcar como lista', onPressed: () => _marcarLista(p))])))),
        const SizedBox(height: 16),
        Text('Listas para vender (${_piezasListas.length})', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_piezasListas.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(24), child: Text('No hay piezas listas', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))))
        else ..._piezasListas.map((p) => Card(child: ListTile(dense: true, title: Text(p.numeroPieza), subtitle: Text('${p.pesoActual?.toStringAsFixed(2) ?? p.pesoInicial.toStringAsFixed(2)} kg · ${_edad(p.edadDias)}'), trailing: const Icon(Icons.check_circle, color: Colors.green)))),
      ])),
    );
  }
}
