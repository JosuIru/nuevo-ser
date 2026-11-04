import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/control_temperatura.dart';
import '../modelos/evento_curacion.dart';
import '../utiles/textos_quesera.dart';
import 'pantalla_nueva_partida.dart';

class PantallaHoy extends StatefulWidget {
  PantallaHoy({super.key});
  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  final _bd = BaseDatosSoleraQuesera.instancia;
  DateFormat get _formatter => DateFormat('EEEE d/M/yyyy', localeFechasQuesera());
  int _partidasHoy = 0;
  double _litrosHoy = 0;
  Map<String, int> _piezasPorEstado = {};
  Map<String, ControlTemperatura> _tempCavas = {};
  List<EventoCuracion> _pendientes = [];

  @override
  void initState() { super.initState(); _recargar(); }

  @override
  void didChangeDependencies() { super.didChangeDependencies(); _recargar(); }

  Future<void> _recargar() async {
    final inicio = DateTime.now().subtract(Duration(hours: 12));
    final fin = DateTime.now().add(Duration(hours: 12));
    final p = await _bd.listarPartidasLeche(desdeMs: inicio.millisecondsSinceEpoch, hastaMs: fin.millisecondsSinceEpoch);
    final l = await _bd.totalLitrosEnPeriodo(inicio.millisecondsSinceEpoch, fin.millisecondsSinceEpoch);
    final pe = await _bd.contarPiezasPorEstado();
    final tc = await _bd.ultimaTemperaturaPorCava();
    final ev = await _bd.eventosPendientesHoy();
    if (!mounted) return;
    setState(() {
      _partidasHoy = p.length; _litrosHoy = l; _piezasPorEstado = pe;
      _tempCavas = tc;
      _pendientes = ev;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.tf('ques.hoy_fecha', {'fecha': _formatter.format(DateTime.now())})), backgroundColor: theme.colorScheme.surface),
      body: RefreshIndicator(onRefresh: _recargar, child: ListView(padding: const EdgeInsets.all(16), children: [
        // Aviso de versión nueva: si no la hay, no ocupa sitio.
        AvisoActualizaciones(
          config: configActualizacionesMonorepo('solera-quesera'),
          nombreApp: 'Larrea Quesera',
          margen: const EdgeInsets.only(bottom: 12),
        ),
        TarjetaResumen(titulo: SoleraL10n.t('ques.partidas_de_leche_hoy'), valor: '$_partidasHoy', subtitulo: SoleraL10n.tf('ques.litros_n', {'n': formatearNumero(_litrosHoy, decimales: 1)}), icono: Icons.water_drop, color: theme.colorScheme.primary),
        SizedBox(height: 12),
        if (_tempCavas.isNotEmpty) ...[
          Text(SoleraL10n.t('estado_de_cavas'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ..._tempCavas.entries.map((e) => Card(child: ListTile(leading: Icon(Icons.thermostat), title: Text(e.key), trailing: Text(textoTemperaturaHumedad(e.value.temperatura, e.value.humedadRelativa), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))))),
          SizedBox(height: 16),
        ],
        Text(SoleraL10n.t('inventario_de_cava'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TarjetaResumen(titulo: SoleraL10n.t('ques.estado_afinando'), valor: '${_piezasPorEstado['afinando'] ?? 0}', icono: Icons.schedule, color: Colors.orange),
        SizedBox(height: 8),
        TarjetaResumen(titulo: SoleraL10n.t('ques.listas_para_vender'), valor: '${_piezasPorEstado['lista'] ?? 0}', icono: Icons.check_circle, color: Colors.green),
        SizedBox(height: 16),
        if (_pendientes.isNotEmpty) ...[
          Text(SoleraL10n.t('pendientes_hoy'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ..._pendientes.map((p) => Card(child: ListTile(leading: Icon(Icons.notifications_active, color: Colors.orange), title: Text(SoleraL10n.tf('ques.evento_de_pieza', {'evento': textoTipoEventoCuracion(p.tipo), 'pieza': p.piezaId})), trailing: Text(DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(p.fechaMs)), style: theme.textTheme.bodySmall)))),
          SizedBox(height: 16),
        ],
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaNuevaPartida())), icon: Icon(Icons.add), label: Text(SoleraL10n.t('registrar_partida_de_leche')))),
      ])),
    );
  }
}

