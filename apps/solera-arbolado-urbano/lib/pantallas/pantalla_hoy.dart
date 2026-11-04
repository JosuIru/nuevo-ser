import 'package:flutter/material.dart';
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

  /// «martes 4 de noviembre» en el idioma de la app.
  String _fechaHoyTraducida(DateTime hoy) {
    return SoleraL10n.tf('arb.fecha_hoy', {
      'dia_semana': diaSemanaTraducido(hoy.weekday),
      'dia': hoy.day,
      'de_mes': deMesTraducido(hoy.month),
    });
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final fechaHoy = _fechaHoyTraducida(hoy);
    final proximas = tareasProximas(zona: _zona, fecha: hoy, limite: 6);
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('arb.hoy')),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: SoleraL10n.t('arb.guia_de_plagas'),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(builder: (_) => PantallaGuia()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Aviso de versión nueva (no ocupa sitio si no hay).
          AvisoActualizaciones(
            config: configActualizacionesMonorepo('solera-arbolado-urbano'),
            nombreApp: 'Larrea Arbolado Urbano',
            margen: const EdgeInsets.only(bottom: 8),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fechaHoy[0].toUpperCase() + fechaHoy.substring(1),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    SoleraL10n.tf('arb.proximas_actuaciones_en_zona', {'zona': _etiquetaZona(_zona)}),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              spacing: 8,
              children: [
                for (final z in ZonaClimaticaArbolado.values)
                  ChoiceChip(
                    label: Text(_etiquetaZona(z)),
                    selected: _zona == z,
                    onSelected: (s) {
                      if (s) setState(() => _zona = z);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (proximas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(SoleraL10n.t('arb.sin_tareas_calendario_zona')),
            )
          else
            for (final t in proximas)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event, color: Color(0xFF2E7D32)),
                  title: Text(t.nombreVisible),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatoFecha(t.mes, t.decada)),
                      if (t.notas.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            t.notas,
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 16),
          Text(
            SoleraL10n.t('arb.aviso_decadas_orientativas'),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
