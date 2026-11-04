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
    'api.de_mes_1', 'api.de_mes_2', 'api.de_mes_3', 'api.de_mes_4',
    'api.de_mes_5', 'api.de_mes_6', 'api.de_mes_7', 'api.de_mes_8',
    'api.de_mes_9', 'api.de_mes_10', 'api.de_mes_11', 'api.de_mes_12',
  ];
  static const _clavesDiaSemana = [
    'api.dia_semana_1', 'api.dia_semana_2', 'api.dia_semana_3',
    'api.dia_semana_4', 'api.dia_semana_5', 'api.dia_semana_6',
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

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final fechaHoy = _fechaHoy(hoy);
    final proximas = tareasProximas(zona: _zona, fecha: hoy, limite: 6);
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('api.hoy')),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: SoleraL10n.t('api.guia_tooltip'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaGuia()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 12),
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
                    SoleraL10n.tf('api.proximas_tareas_zona', {'zona': _etiquetaZona(_zona)}),
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
                for (final z in ZonaClimaticaApicola.values)
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
              child: Text(SoleraL10n.t('api.sin_tareas_zona')),
            )
          else
            for (final t in proximas)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event, color: Color(0xFFB8860B)),
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
            SoleraL10n.t('api.aviso_decadas_orientativas'),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
