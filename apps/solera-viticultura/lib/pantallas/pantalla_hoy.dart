import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_bbch.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import 'pantalla_chat.dart';
import 'pantalla_guia.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

/// Nombre del día de la semana (1 = lunes) en el idioma actual.
String _nombreDiaSemana(int diaSemana) => [
      SoleraL10n.t('viti.dia_lunes'),
      SoleraL10n.t('viti.dia_martes'),
      SoleraL10n.t('viti.dia_miercoles'),
      SoleraL10n.t('viti.dia_jueves'),
      SoleraL10n.t('viti.dia_viernes'),
      SoleraL10n.t('viti.dia_sabado'),
      SoleraL10n.t('viti.dia_domingo')
    ][diaSemana - 1];

/// «de enero», «urtarrilaren», «d'abril»… en el idioma actual.
String _mesConPreposicion(int mes) => [
      SoleraL10n.t('viti.de_enero'),
      SoleraL10n.t('viti.de_febrero'),
      SoleraL10n.t('viti.de_marzo'),
      SoleraL10n.t('viti.de_abril'),
      SoleraL10n.t('viti.de_mayo'),
      SoleraL10n.t('viti.de_junio'),
      SoleraL10n.t('viti.de_julio'),
      SoleraL10n.t('viti.de_agosto'),
      SoleraL10n.t('viti.de_septiembre'),
      SoleraL10n.t('viti.de_octubre'),
      SoleraL10n.t('viti.de_noviembre'),
      SoleraL10n.t('viti.de_diciembre')
    ][mes - 1];

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
        return SoleraL10n.t('viti.zona_norte_atlantica');
      case ZonaClimaticaVid.sur:
        return SoleraL10n.t('viti.zona_sur_mediterranea');
    }
  }

  String _formatoFecha(int mes, int decada) {
    return SoleraL10n.tf('viti.decada_de_mes', {
      'n': decada.clamp(1, 3),
      'mes_de': _mesConPreposicion(mes),
    });
  }

  String _fechaHoyEs(DateTime hoy) {
    return SoleraL10n.tf('viti.fecha_hoy', {
      'dia_semana': _nombreDiaSemana(hoy.weekday),
      'dia': hoy.day,
      'mes_de': _mesConPreposicion(hoy.month),
    });
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
      appBar: AppBar(
        title: Text(SoleraL10n.t('viti.pestana_hoy')),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: SoleraL10n.t('viti.guia_de_viticultura'),
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
            config: configActualizacionesMonorepo('solera-viticultura'),
            nombreApp: 'Larrea Viticultura',
            margen: const EdgeInsets.only(bottom: 12),
          ),
          const TarjetaResumenMeteo(),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text(SoleraL10n.t('viti.asistente_chat')),
              subtitle: Text(SoleraL10n.t('viti.asistente_chat_ayuda')),
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
                  if (estadoActual != null) ...[
                    Text(
                      SoleraL10n.tf('viti.estado_fenologico_esperado', {
                        'estado': estadoActual.nombreEstado,
                        'bbch': estadoActual.estadoBbch,
                      }),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SoleraL10n.tf('viti.variedad_en_zona', {
                        'variedad': _etiquetaVariedad(_variedadId),
                        'zona': _etiquetaZona(_zona),
                      }),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ] else
                    Text(SoleraL10n.t('viti.sin_datos_combinacion')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              SoleraL10n.t('viti.variedad'),
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              SoleraL10n.t('viti.zona'),
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              SoleraL10n.t('viti.proximos_hitos_fenologicos'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          if (proximos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(SoleraL10n.t('viti.sin_datos_calendario_combinacion')),
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
            SoleraL10n.t('viti.aviso_decadas_orientativas'),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
