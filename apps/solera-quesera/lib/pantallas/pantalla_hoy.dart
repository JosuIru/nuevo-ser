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
  int _partidasHoy = 0;
  double _litrosHoy = 0;
  Map<String, int> _piezasPorEstado = {};
  Map<String, ControlTemperatura> _tempCavas = {};
  List<EventoCuracion> _pendientes = [];

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recargar();
  }

  Future<void> _recargar() async {
    final inicio = DateTime.now().subtract(Duration(hours: 12));
    final fin = DateTime.now().add(Duration(hours: 12));
    final p = await _bd.listarPartidasLeche(
        desdeMs: inicio.millisecondsSinceEpoch,
        hastaMs: fin.millisecondsSinceEpoch);
    final l = await _bd.totalLitrosEnPeriodo(
        inicio.millisecondsSinceEpoch, fin.millisecondsSinceEpoch);
    final pe = await _bd.contarPiezasPorEstado();
    final tc = await _bd.ultimaTemperaturaPorCava();
    final ev = await _bd.eventosPendientesHoy();
    if (!mounted) return;
    setState(() {
      _partidasHoy = p.length;
      _litrosHoy = l;
      _piezasPorEstado = pe;
      _tempCavas = tc;
      _pendientes = ev;
    });
  }

  String get _fechaDeHoy {
    final texto =
        DateFormat.MMMMEEEEd(localeFechasQuesera()).format(DateTime.now());
    return texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
  }

  void _registrarPartida() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => PantallaNuevaPartida()));
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colores = context.coloresSolera;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _registrarPartida,
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t('registrar_partida_de_leche')),
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        edgeOffset: MediaQuery.paddingOf(context).top,
        child: ListView(
          padding:
              rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 96)),
          children: [
            CabeceraHoySolera(
              titulo: SoleraL10n.t('ques.hoy'),
              fecha: _fechaDeHoy,
              cifras: [
                CifraCabecera(
                  valor: '$_partidasHoy',
                  etiqueta: SoleraL10n.t('ques.partidas_de_leche_hoy'),
                  detalle: SoleraL10n.tf('ques.litros_n',
                      {'n': formatearNumero(_litrosHoy, decimales: 1)}),
                ),
                CifraCabecera(
                  valor: '${_piezasPorEstado['afinando'] ?? 0}',
                  etiqueta: SoleraL10n.t('ques.estado_afinando'),
                ),
                CifraCabecera(
                  valor: '${_piezasPorEstado['lista'] ?? 0}',
                  etiqueta: SoleraL10n.t('ques.listas_para_vender'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Aviso de versión nueva: si no la hay, no ocupa sitio.
                  AvisoActualizaciones(
                    config: configActualizacionesMonorepo('solera-quesera'),
                    nombreApp: 'Larrea Quesera',
                    margen: const EdgeInsets.only(bottom: 4),
                  ),
                  if (_pendientes.isNotEmpty) ...[
                    TituloBloqueSolera(SoleraL10n.t('pendientes_hoy')),
                    Card(
                      child: Column(children: [
                        for (final pendiente in _pendientes)
                          ListTile(
                            leading: Icon(Icons.notifications_active_outlined,
                                color: colores.pendiente),
                            title: Text(SoleraL10n.tf('ques.evento_de_pieza', {
                              'evento': textoTipoEventoCuracion(pendiente.tipo),
                              'pieza': pendiente.piezaId,
                            })),
                            trailing: Text(
                                DateFormat('HH:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        pendiente.fechaMs)),
                                style: theme.textTheme.bodySmall),
                          ),
                      ]),
                    ),
                  ],
                  if (_pendientes.isEmpty && _tempCavas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(children: [
                        Icon(Icons.task_alt, size: 40, color: colores.hecho),
                        const SizedBox(height: 8),
                        Text(SoleraL10n.t('ques.hoy_nada_pendiente'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ]),
                    ),
                  if (_tempCavas.isNotEmpty) ...[
                    TituloBloqueSolera(SoleraL10n.t('estado_de_cavas')),
                    Card(
                      child: Column(children: [
                        for (final cava in _tempCavas.entries)
                          ListTile(
                            leading: const Icon(Icons.thermostat),
                            title: Text(cava.key),
                            trailing: Text(
                                textoTemperaturaHumedad(cava.value.temperatura,
                                    cava.value.humedadRelativa),
                                style: theme.textTheme.titleSmall),
                          ),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
