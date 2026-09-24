import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_calendario_apicola.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

const _diasSemana = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _mesesEs = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

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
        return 'Norte (atlántica)';
      case ZonaClimaticaApicola.centro:
        return 'Centro (meseta)';
      case ZonaClimaticaApicola.sur:
        return 'Sur (mediterránea)';
    }
  }

  String _formatoFecha(int mes, int decada) {
    final etiquetaDec = decada == 1
        ? '1ª'
        : decada == 2
            ? '2ª'
            : '3ª';
    return '$etiquetaDec década de ${_mesesEs[mes - 1]}';
  }

  String _fechaHoyEs(DateTime hoy) {
    return '${_diasSemana[hoy.weekday - 1]} ${hoy.day} de ${_mesesEs[hoy.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final fechaHoy = _fechaHoyEs(hoy);
    final proximas = tareasProximas(zona: _zona, fecha: hoy, limite: 6);
    return Scaffold(
      appBar: AppBar(title: const Text('Hoy')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Aviso de versión nueva (no ocupa sitio si no hay).
          AvisoActualizaciones(
            config: configActualizacionesMonorepo('solera-apicola'),
            nombreApp: 'Solera Apícola',
            margen: const EdgeInsets.only(bottom: 12),
          ),
          const TarjetaResumenMeteo(),
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
                    'Próximas tareas en zona ${_etiquetaZona(_zona)}.',
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin tareas en el calendario para esta zona.'),
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
            'Las décadas son orientativas (±2 semanas según año, microclima y altitud). '
            'Verifica con tu boletín apícola local antes de planificar tratamientos.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
