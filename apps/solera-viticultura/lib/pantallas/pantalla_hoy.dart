import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_bbch.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

const _diasSemana = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _mesesEs = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// Pantalla "Hoy": muestra el estado fenológico esperado de una
/// variedad+zona y los próximos hitos del calendario BBCH. Sirve como
/// "qué toca esta semana" para el viticultor sin abrir cada cepa.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  // Variedades cubiertas hoy por el calendario BBCH (CSV provisional).
  // Cuando entren más, este listado las recoge automáticamente.
  late final List<String> _variedadesConCalendario =
      calendarioFenologicoBbch.map((e) => e.variedadId).toSet().toList()..sort();

  String _variedadId = 'tempranillo';
  ZonaClimaticaVid _zona = ZonaClimaticaVid.sur;

  String _etiquetaVariedad(String id) {
    final v = variedadPorId(id);
    return v?.nombreCanonico ?? id;
  }

  String _etiquetaZona(ZonaClimaticaVid z) {
    switch (z) {
      case ZonaClimaticaVid.norte:
        return 'Norte (atlántica)';
      case ZonaClimaticaVid.sur:
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

  /// Próximos N estados ordenados por mes/década, con wrap-around al
  /// año siguiente si quedan menos del límite hasta diciembre.
  List<EstadoFenologicoBbch> _proximosEstados({
    required String variedadId,
    required ZonaClimaticaVid zona,
    required DateTime fecha,
    int limite = 5,
  }) {
    final lista = calendarioDe(variedadId, zona);
    if (lista.isEmpty) return const [];
    final decadaActual = (fecha.day - 1) ~/ 10 + 1;
    final claveActual = fecha.month * 10 + decadaActual.clamp(1, 3);
    final futuros = lista
        .where((e) => e.mes * 10 + e.decada >= claveActual)
        .toList();
    if (futuros.length >= limite) return futuros.take(limite).toList();
    final restantes = limite - futuros.length;
    return [...futuros, ...lista.take(restantes)];
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final fechaHoy = _fechaHoyEs(hoy);
    final estadoActual =
        estadoEsperadoEn(variedadId: _variedadId, zona: _zona, fecha: hoy);
    final proximos = _proximosEstados(
      variedadId: _variedadId,
      zona: _zona,
      fecha: hoy,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Hoy')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Aviso de versión nueva (no ocupa sitio si no hay).
          AvisoActualizaciones(
            config: configActualizacionesMonorepo('solera-viticultura'),
            nombreApp: 'Solera Viticultura',
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
                  if (estadoActual != null) ...[
                    Text(
                      'Estado fenológico esperado: ${estadoActual.nombreEstado} '
                      '(BBCH ${estadoActual.estadoBbch})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_etiquetaVariedad(_variedadId)} en zona ${_etiquetaZona(_zona)}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ] else
                    const Text('Sin datos para esta combinación.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Variedad',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final id in _variedadesConCalendario)
                  ChoiceChip(
                    label: Text(_etiquetaVariedad(id)),
                    selected: _variedadId == id,
                    onSelected: (s) {
                      if (s) setState(() => _variedadId = id);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Zona',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              spacing: 8,
              children: [
                for (final z in ZonaClimaticaVid.values)
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
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Próximos hitos fenológicos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          if (proximos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin datos en el calendario para esta combinación.'),
            )
          else
            for (final e in proximos)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event, color: Color(0xFF7A1F2D)),
                  title: Text('${e.nombreEstado} · BBCH ${e.estadoBbch}'),
                  subtitle: Text(_formatoFecha(e.mes, e.decada)),
                ),
              ),
          const SizedBox(height: 16),
          Text(
            'Las décadas son orientativas (±2 décadas según año, microclima y altitud). '
            'Verifica con tu boletín de avisos fitosanitarios local antes de planificar tratamientos.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
