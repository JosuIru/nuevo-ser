import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/catalogos_generados/catalogo_bbch.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import 'pantalla_chat.dart';
import 'pantalla_guia.dart';
import '../utiles/idioma_fechas.dart';
import 'widgets/tarjeta_resumen_meteo.dart';

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

  /// «Jueves, 5 de noviembre» en el idioma de la app, con mayúscula inicial.
  String _fechaDeHoy(DateTime hoy) {
    final textoFecha = DateFormat.MMMMEEEEd(localeFechasSolera).format(hoy);
    return textoFecha.isEmpty
        ? textoFecha
        : textoFecha[0].toUpperCase() + textoFecha.substring(1);
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
    final tema = Theme.of(context);
    final hoy = DateTime.now();
    final estadoActual =
        estadoEsperadoEn(variedadId: _variedadId, zona: _zona, fecha: hoy);
    final proximos = _proximosEstados(
      variedadId: _variedadId,
      zona: _zona,
      fecha: hoy,
    );
    // El primer hito que no es el estado en que ya está la viña.
    final proximoHito = proximos
        .where((estado) => estado.estadoBbch != estadoActual?.estadoBbch)
        .firstOrNull;

    return Scaffold(
      body: ListView(
        padding:
            rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
        children: [
          CabeceraHoySolera(
            titulo: SoleraL10n.t('viti.pestana_hoy'),
            fecha: _fechaDeHoy(hoy),
            acciones: [
              IconButton(
                icon: const Icon(Icons.menu_book_outlined),
                tooltip: SoleraL10n.t('viti.guia_de_viticultura'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PantallaGuia()),
                ),
              ),
            ],
            cifras: [
              CifraCabecera(
                valor: estadoActual == null
                    ? '—'
                    : 'BBCH ${estadoActual.estadoBbch}',
                etiqueta: SoleraL10n.t('viti.cifra_estado_esperado'),
                detalle: estadoActual?.nombreEstado,
              ),
              CifraCabecera(
                valor: proximoHito == null
                    ? '—'
                    : 'BBCH ${proximoHito.estadoBbch}',
                etiqueta: SoleraL10n.t('viti.cifra_proximo_hito'),
                detalle: proximoHito == null
                    ? null
                    : _formatoFecha(proximoHito.mes, proximoHito.decada),
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
                if (estadoActual == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
                    child: Text(SoleraL10n.t('viti.sin_datos_combinacion'),
                        style: tema.textTheme.bodyMedium?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant)),
                  ),
                TituloBloqueSolera(SoleraL10n.t('viti.variedad')),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final id in _variedadesConCalendario)
                      ChoiceChip(
                        label: Text(_etiquetaVariedad(id)),
                        selected: _variedadId == id,
                        onSelected: (seleccionado) {
                          if (seleccionado) setState(() => _variedadId = id);
                        },
                      ),
                  ],
                ),
                TituloBloqueSolera(SoleraL10n.t('viti.zona')),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final zona in ZonaClimaticaVid.values)
                      ChoiceChip(
                        label: Text(_etiquetaZona(zona)),
                        selected: _zona == zona,
                        onSelected: (seleccionado) {
                          if (seleccionado) setState(() => _zona = zona);
                        },
                      ),
                  ],
                ),
                TituloBloqueSolera(
                    SoleraL10n.t('viti.proximos_hitos_fenologicos')),
                if (proximos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                        SoleraL10n.t('viti.sin_datos_calendario_combinacion')),
                  )
                else
                  Card(
                    child: Column(children: [
                      for (final estado in proximos)
                        ListTile(
                          leading: Icon(Icons.event,
                              color: tema.colorScheme.primary),
                          title: Text(
                              '${estado.nombreEstado} · BBCH ${estado.estadoBbch}'),
                          subtitle:
                              Text(_formatoFecha(estado.mes, estado.decada)),
                        ),
                    ]),
                  ),
                const SizedBox(height: 16),
                Text(
                  SoleraL10n.t('viti.aviso_decadas_orientativas'),
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
