import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/control_temperatura.dart';
import '../modelos/evento_curacion.dart';
import '../modelos/pieza.dart';
import '../utiles/textos_quesera.dart';
import 'pantalla_ia_queso.dart';

class PantallaCava extends StatefulWidget {
  const PantallaCava({super.key, this.barraPestanas});

  /// Pestañas Lotes/Cava bajo la barra superior cuando la pantalla va
  /// dentro de la pestaña Lotes (ver `PantallaLotesYCava`).
  final PreferredSizeWidget? barraPestanas;
  @override
  State<PantallaCava> createState() => _PantallaCavaState();
}

class _PantallaCavaState extends State<PantallaCava> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  List<Pieza> _piezasAfinando = [], _piezasListas = [];
  Map<String, ControlTemperatura> _tempsCava = {};
  final _tempC = TextEditingController(), _hrC = TextEditingController(), _cavaC = TextEditingController(text: 'Cava principal');

  @override
  void initState() { super.initState(); _recargar(); }

  Future<void> _recargar() async {
    final af = await _bd.listarPiezas(estado: 'afinando');
    final li = await _bd.listarPiezas(estado: 'lista');
    final tc = await _bd.ultimaTemperaturaPorCava();
    if (mounted) setState(() { _piezasAfinando = af; _piezasListas = li;
      _tempsCava = tc; });
  }

  Future<void> _regTemp() async {
    final t = leerNumero(_tempC.text); final h = leerNumero(_hrC.text);
    if (t == null || h == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.t('ques.introduce_temperatura_y_humedad')))); return; }
    await _bd.guardarControlTemperatura(ControlTemperatura(fechaMs: DateTime.now().millisecondsSinceEpoch, cavaId: _cavaC.text, temperatura: t, humedadRelativa: h));
    _tempC.clear(); _hrC.clear(); await _recargar();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.t('temperatura_registrada'))));
  }

  Future<void> _volteo(Pieza p) async {
    await _bd.guardarEventoCuracion(EventoCuracion(piezaId: p.id!, fechaMs: DateTime.now().millisecondsSinceEpoch, tipo: 'volteo', fechaCreacionMs: DateTime.now().millisecondsSinceEpoch));
    await _recargar();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(SoleraL10n.tf('ques.volteo_registrado', {'pieza': p.numeroPieza}))));
  }

  Future<void> _marcarLista(Pieza p) async { await _bd.actualizarPieza(p.id!, {'estado': 'lista'}); await _recargar(); }

  @override
  void dispose() { _tempC.dispose(); _hrC.dispose(); _cavaC.dispose(); super.dispose(); }

  String _edad(int d) => textoEdadPieza(d);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final total = _piezasAfinando.length + _piezasListas.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.tf('ques.cava_piezas_n', {'n': total})),
        bottom: widget.barraPestanas,
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            tooltip: SoleraL10n.t('ques.defectos_en_queso_con_ia'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaIaQueso())),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _recargar, child: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(SoleraL10n.t('ques.registro_de_temperatura'), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(controller: _cavaC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.cava_camara'), border: const OutlineInputBorder(), isDense: true)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextFormField(controller: _tempC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.temperatura_c'), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: TextFormField(controller: _hrC, decoration: InputDecoration(labelText: SoleraL10n.t('ques.humedad_pct'), border: const OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number))]),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _regTemp, icon: const Icon(Icons.thermostat), label: Text(SoleraL10n.t('ques.registrar'))),
          if (_tempsCava.isNotEmpty) ..._tempsCava.entries.map((e) => Text('${e.key}: ${textoTemperaturaHumedad(e.value.temperatura, e.value.humedadRelativa)}', style: t.textTheme.bodySmall)),
        ]))),
        const SizedBox(height: 16),
        Text(SoleraL10n.tf('ques.afinando_n', {'n': _piezasAfinando.length}), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_piezasAfinando.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(SoleraL10n.t('ques.no_hay_piezas_en_afinado'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))))
        else ..._piezasAfinando.map((p) => Card(child: ListTile(dense: true, title: Text(p.numeroPieza), subtitle: Text('${formatearNumero(p.pesoActual ?? p.pesoInicial, decimales: 2)} kg · ${_edad(p.edadDias)} · ${p.ubicacionActual}'),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.flip, size: 20), tooltip: SoleraL10n.t('ques.registrar_volteo'), onPressed: () => _volteo(p)), IconButton(icon: const Icon(Icons.check, size: 20, color: Colors.green), tooltip: SoleraL10n.t('ques.marcar_como_lista'), onPressed: () => _marcarLista(p))])))),
        const SizedBox(height: 16),
        Text(SoleraL10n.tf('ques.listas_para_vender_n', {'n': _piezasListas.length}), style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (_piezasListas.isEmpty) Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(SoleraL10n.t('ques.no_hay_piezas_listas'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))))
        else ..._piezasListas.map((p) => Card(child: ListTile(dense: true, title: Text(p.numeroPieza), subtitle: Text('${formatearNumero(p.pesoActual ?? p.pesoInicial, decimales: 2)} kg · ${_edad(p.edadDias)}'), trailing: const Icon(Icons.check_circle, color: Colors.green)))),
      ])),
    );
  }
}
