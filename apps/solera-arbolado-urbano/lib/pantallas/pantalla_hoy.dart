import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_calendario_arbolado.dart';
import '../utiles/etiquetas_l10n.dart';
import 'pantalla_guia.dart';

/// Pantalla "Hoy": muestra las próximas tareas del calendario de
/// arbolado urbano para la zona seleccionada. Sirve como agenda rápida
/// del operario municipal — "qué toca esta semana / este mes" sin
/// abrir la lista de árboles ni el mapa.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  ZonaClimaticaArbolado _zona = ZonaClimaticaArbolado.centro;

  String _etiquetaZona(ZonaClimaticaArbolado z) {
    switch (z) {
      case ZonaClimaticaArbolado.norte:
        return SoleraL10n.t('arb.zona_norte_atlantica');
      case ZonaClimaticaArbolado.centro:
        return SoleraL10n.t('arb.zona_centro_meseta');
      case ZonaClimaticaArbolado.sur:
        return SoleraL10n.t('arb.zona_sur_mediterranea');
    }
  }

  String _formatoFecha(int mes, int decada) {
    return SoleraL10n.tf('arb.decada_de_mes', {
      'n': decada.clamp(1, 3),
      'de_mes': deMesTraducido(mes),
    });
  }

  /// «Jueves, 5 de noviembre» en el idioma de la app, con mayúscula inicial.
  String _fechaDeHoy(DateTime hoy) {
    final texto = DateFormat.MMMMEEEEd(SoleraL10n.idioma).format(hoy);
    return texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
  }

  void _abrirGuia() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => PantallaGuia()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = context.coloresSolera;
    final hoy = DateTime.now();
    final proximas = tareasProximas(zona: _zona, fecha: hoy, limite: 6);
    // Cifras de la cabecera: del mismo calendario de la zona que alimenta
    // la lista (catálogo en memoria, sin consultas nuevas).
    final tareasDeLaZona = tareasDeZona(_zona);
    final decadaActual = ((hoy.day - 1) ~/ 10 + 1).clamp(1, 3);
    final tareasDeEsteMes =
        tareasDeLaZona.where((tarea) => tarea.mes == hoy.month).toList();
    final tareasDeEstaDecada = tareasDeEsteMes
        .where((tarea) => tarea.decada == decadaActual)
        .length;
    return Scaffold(
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
        children: [
          CabeceraHoySolera(
            titulo: SoleraL10n.t('arb.hoy'),
            fecha: _fechaDeHoy(hoy),
            acciones: [
              IconButton(
                icon: const Icon(Icons.menu_book),
                tooltip: SoleraL10n.t('arb.guia_de_plagas'),
                onPressed: _abrirGuia,
              ),
            ],
            cifras: [
              CifraCabecera(
                valor: '$tareasDeEstaDecada',
                etiqueta: SoleraL10n.t('arb.tareas_esta_decada'),
                detalle: _formatoFecha(hoy.month, decadaActual),
              ),
              CifraCabecera(
                valor: '${tareasDeEsteMes.length}',
                etiqueta: SoleraL10n.t('arb.tareas_este_mes'),
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
                  config: configActualizacionesMonorepo('solera-arbolado-urbano'),
                  nombreApp: 'Larrea Arbolado Urbano',
                  margen: const EdgeInsets.only(bottom: 4),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final zona in ZonaClimaticaArbolado.values)
                      ChoiceChip(
                        label: Text(_etiquetaZona(zona)),
                        selected: _zona == zona,
                        onSelected: (seleccionada) {
                          if (seleccionada) setState(() => _zona = zona);
                        },
                      ),
                  ],
                ),
                TituloBloqueSolera(SoleraL10n.tf(
                    'arb.proximas_actuaciones_en_zona',
                    {'zona': _etiquetaZona(_zona)})),
                if (proximas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(children: [
                      Icon(Icons.task_alt, size: 40, color: colores.hecho),
                      const SizedBox(height: 8),
                      Text(SoleraL10n.t('arb.sin_tareas_calendario_zona'),
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
                          leading: Icon(Icons.event, color: colores.pendiente),
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
                  SoleraL10n.t('arb.aviso_decadas_orientativas'),
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
