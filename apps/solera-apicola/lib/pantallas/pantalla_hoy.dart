import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_calendario_apicola.dart';
import 'pantalla_chat.dart';
import 'pantalla_guia.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

/// Pantalla "Hoy": muestra las próximas tareas del calendario apícola
/// para la zona seleccionada. Sirve como agenda rápida del apicultor —
/// "qué toca esta semana / este mes" sin abrir cada apiario.
///
/// Selección de zona en chips arriba; persistencia futura por apiario
/// activo (cuando exista mapa zona-apiario).
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  ZonaClimaticaApicola _zona = ZonaClimaticaApicola.centro;

  String _etiquetaZona(ZonaClimaticaApicola z) {
    switch (z) {
      case ZonaClimaticaApicola.norte:
        return SoleraL10n.t('api.zona_norte');
      case ZonaClimaticaApicola.centro:
        return SoleraL10n.t('api.zona_centro');
      case ZonaClimaticaApicola.sur:
        return SoleraL10n.t('api.zona_sur');
    }
  }

  /// Claves escritas una a una (no «'api.de_mes_$mes'») para que el test
  /// de traducciones del core las encuentre.
  static const _clavesDeMes = [
    'api.de_mes_1',
    'api.de_mes_2',
    'api.de_mes_3',
    'api.de_mes_4',
    'api.de_mes_5',
    'api.de_mes_6',
    'api.de_mes_7',
    'api.de_mes_8',
    'api.de_mes_9',
    'api.de_mes_10',
    'api.de_mes_11',
    'api.de_mes_12',
  ];
  static const _clavesDiaSemana = [
    'api.dia_semana_1',
    'api.dia_semana_2',
    'api.dia_semana_3',
    'api.dia_semana_4',
    'api.dia_semana_5',
    'api.dia_semana_6',
    'api.dia_semana_7',
  ];

  String _formatoFecha(int mes, int decada) {
    return SoleraL10n.tf('api.decada_de_mes', {
      'n': decada,
      'de_mes': SoleraL10n.t(_clavesDeMes[mes - 1]),
    });
  }

  String _fechaHoy(DateTime hoy) {
    return SoleraL10n.tf('api.fecha_hoy', {
      'dia_semana': SoleraL10n.t(_clavesDiaSemana[hoy.weekday - 1]),
      'dia': hoy.day,
      'de_mes': SoleraL10n.t(_clavesDeMes[hoy.month - 1]),
    });
  }

  /// Tareas del calendario de la zona para el mes de [hoy] y, si se da
  /// [decada], solo para esa década.
  int _contarTareas(DateTime hoy, {int? decada}) => tareasDeZona(_zona)
      .where((tarea) =>
          tarea.mes == hoy.month && (decada == null || tarea.decada == decada))
      .length;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = context.coloresSolera;
    final hoy = DateTime.now();
    final fechaHoy = _fechaHoy(hoy);
    final decadaActual = ((hoy.day - 1) ~/ 10 + 1).clamp(1, 3);
    final proximas = tareasProximas(zona: _zona, fecha: hoy, limite: 6);
    return Scaffold(
      body: ListView(
        padding:
            rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
        children: [
          CabeceraHoySolera(
            titulo: SoleraL10n.t('api.hoy'),
            fecha: fechaHoy[0].toUpperCase() + fechaHoy.substring(1),
            acciones: [
              IconButton(
                icon: const Icon(Icons.menu_book_outlined),
                tooltip: SoleraL10n.t('api.guia_tooltip'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PantallaGuia()),
                ),
              ),
            ],
            cifras: [
              CifraCabecera(
                valor: '${_contarTareas(hoy, decada: decadaActual)}',
                etiqueta: SoleraL10n.t('api.tareas_esta_decada'),
                detalle: _formatoFecha(hoy.month, decadaActual),
              ),
              CifraCabecera(
                valor: '${_contarTareas(hoy)}',
                etiqueta: SoleraL10n.t('api.tareas_este_mes'),
                detalle: _etiquetaZona(_zona),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Aviso de versión nueva (no ocupa sitio si no hay).
                AvisoActualizaciones(
                  config: configActualizacionesMonorepo('solera-apicola'),
                  nombreApp: 'Larrea Apícola',
                  margen: const EdgeInsets.only(bottom: 12),
                ),
                const TarjetaResumenMeteo(),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(SoleraL10n.t('api.asistente_chat')),
                    subtitle: Text(SoleraL10n.t('api.asistente_chat_ayuda')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PantallaChat()),
                    ),
                  ),
                ),
                TituloBloqueSolera(SoleraL10n.t('api.proximas_tareas')),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final zona in ZonaClimaticaApicola.values)
                      ChoiceChip(
                        label: Text(_etiquetaZona(zona)),
                        selected: _zona == zona,
                        onSelected: (seleccionada) {
                          if (seleccionada) setState(() => _zona = zona);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (proximas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(children: [
                      Icon(Icons.task_alt, size: 40, color: colores.hecho),
                      const SizedBox(height: 8),
                      Text(SoleraL10n.t('api.sin_tareas_zona'),
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodyLarge?.copyWith(
                              color: tema.colorScheme.onSurfaceVariant)),
                    ]),
                  )
                else
                  Card(
                    child: Column(children: [
                      for (final tarea in proximas)
                        ListTile(
                          leading: Icon(
                            Icons.event,
                            // Las de esta década, en el color de «pendiente».
                            color: tarea.mes == hoy.month &&
                                    tarea.decada == decadaActual
                                ? colores.pendiente
                                : tema.colorScheme.onSurfaceVariant,
                          ),
                          title: Text(tarea.nombreVisible),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatoFecha(tarea.mes, tarea.decada)),
                              if (tarea.notas.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    tarea.notas,
                                    style: tema.textTheme.bodySmall
                                        ?.copyWith(fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ]),
                  ),
                const SizedBox(height: 16),
                Text(
                  SoleraL10n.t('api.aviso_decadas_orientativas'),
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
