import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../datos/base_datos.dart';
import '../modelos/control_temperatura.dart';

class PantallaRegistroAppcc extends StatefulWidget {
  const PantallaRegistroAppcc({super.key});
  @override
  State<PantallaRegistroAppcc> createState() => _PantallaRegistroAppccState();
}

class _PantallaRegistroAppccState extends State<PantallaRegistroAppcc> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  final _fd = DateFormat('d MMM yyyy HH:mm', 'es_ES');
  List<ControlTemperatura> _temps = [];
  int _sec = 0;

  @override
  void initState() { super.initState(); _recargar(); }
  Future<void> _recargar() async { _temps = await _bd.listarTemperaturasRecientes(limite: 5); if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('registros_appcc'))),
      body: Column(children: [
        SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
          ChoiceChip(selected: _sec == 0, avatar: const Icon(Icons.thermostat, size: 18), label: const Text('Temperatura'), onSelected: (_) => setState(() => _sec = 0)),
          const SizedBox(width: 8),
          ChoiceChip(selected: _sec == 1, avatar: const Icon(Icons.cleaning_services, size: 18), label: const Text('Limpieza'), onSelected: (_) => setState(() => _sec = 1)),
          const SizedBox(width: 8),
          ChoiceChip(selected: _sec == 2, avatar: const Icon(Icons.bug_report, size: 18), label: const Text('Plagas'), onSelected: (_) => setState(() => _sec = 2)),
          const SizedBox(width: 8),
          ChoiceChip(selected: _sec == 3, avatar: const Icon(Icons.science, size: 18), label: const Text('Analíticas'), onSelected: (_) => setState(() => _sec = 3)),
          const SizedBox(width: 8),
          ChoiceChip(selected: _sec == 4, avatar: const Icon(Icons.school, size: 18), label: const Text('Formación'), onSelected: (_) => setState(() => _sec = 4)),
        ])),
        Expanded(child: _sec == 0 ? _secTemp(t) : Center(child: Text('Sección ${_sec + 1} — próximamente', style: TextStyle(color: Colors.grey)))),
      ]),
    );
  }

  final _tCavaC = TextEditingController(text: 'Cava principal'), _tValC = TextEditingController(), _tHrC = TextEditingController();

  Widget _secTemp(ThemeData t) => ListView(padding: const EdgeInsets.all(16), children: [
    Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Nuevo registro', style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      TextFormField(controller: _tCavaC, decoration: const InputDecoration(labelText: 'Cava / cámara', border: OutlineInputBorder(), isDense: true)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: TextFormField(controller: _tValC, decoration: const InputDecoration(labelText: 'Temperatura (°C)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
        const SizedBox(width: 8),
        Expanded(child: TextFormField(controller: _tHrC, decoration: const InputDecoration(labelText: 'Humedad (%)', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
      ]),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: _guardarTemp, icon: const Icon(Icons.save), label: const Text('Registrar')),
    ]))),
    Text('Últimos registros', style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    ..._temps.map((x) => Card(
      child: ListTile(dense: true,
        leading: CircleAvatar(backgroundColor: x.temperatura > 16 ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30), child: Icon(Icons.thermostat, color: x.temperatura > 16 ? Colors.red : Colors.green, size: 18)),
        title: Text('${x.cavaId}: ${x.temperatura.toStringAsFixed(1)}°C / ${x.humedadRelativa.toStringAsFixed(0)}% HR'),
        subtitle: Text(_fd.format(DateTime.fromMillisecondsSinceEpoch(x.fechaMs))),
      ),
    )),
  ]);

  Future<void> _guardarTemp() async {
    final t = leerNumero(_tValC.text); final h = leerNumero(_tHrC.text);
    if (t == null || h == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introduce temperatura y humedad (p. ej. 12,5)'))); return; }
    await _bd.guardarControlTemperatura(ControlTemperatura(fechaMs: DateTime.now().millisecondsSinceEpoch, cavaId: _tCavaC.text, temperatura: t, humedadRelativa: h));
    _tValC.clear(); _tHrC.clear(); await _recargar(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.t('temperatura_registrada'))));
  }

  @override
  void dispose() { _tCavaC.dispose(); _tValC.dispose(); _tHrC.dispose(); super.dispose(); }
}
