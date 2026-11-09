// Campos de formulario para las fichas de las apps: el punto y el área de
// una parcela, zona, colmenar… Cada app guarda lo que devuelven en sus
// columnas (latitud/longitud y el contorno con `codificarContorno`).

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../geometria/geodesia.dart';
import '../gps/ubicacion.dart';
import 'formato.dart';
import 'pantalla_editor_area.dart';
import 'pantalla_marcar_punto.dart';

/// Ubicación de algo (un punto): con el GPS, en el sitio, o marcándola en
/// el mapa desde cualquier parte.
class CampoPunto extends StatefulWidget {
  const CampoPunto({
    super.key,
    required this.latitud,
    required this.longitud,
    required this.alCambiar,
    this.titulo,
    this.centro,
    this.areasDeFondo = const [],
    this.paqueteApp = 'com.coleccionnuevoser.larrea',
    this.leerGps = leerPosicionActual,
  });

  final double? latitud;
  final double? longitud;

  /// (null, null) = se quitó la ubicación.
  final void Function(double? latitud, double? longitud) alCambiar;
  final String? titulo;
  final LatLng? centro;
  final List<AreaDeFondo> areasDeFondo;
  final String paqueteApp;
  final Future<LecturaGps?> Function() leerGps;

  @override
  State<CampoPunto> createState() => _CampoPuntoState();
}

class _CampoPuntoState extends State<CampoPunto> {
  bool _leyendoGps = false;

  LatLng? get _actual => widget.latitud == null || widget.longitud == null
      ? null
      : LatLng(widget.latitud!, widget.longitud!);

  Future<void> _usarGps() async {
    setState(() => _leyendoGps = true);
    final lectura = await widget.leerGps();
    if (!mounted) return;
    setState(() => _leyendoGps = false);
    if (lectura == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(SoleraL10n.t('mapa.sin_gps'))));
      return;
    }
    widget.alCambiar(lectura.posicion.latitude, lectura.posicion.longitude);
  }

  Future<void> _marcarEnMapa() async {
    final marcado = await marcarPunto(context,
        inicial: _actual,
        centro: widget.centro,
        areasDeFondo: widget.areasDeFondo,
        paqueteApp: widget.paqueteApp);
    if (marcado == null) return;
    widget.alCambiar(marcado.punto?.latitude, marcado.punto?.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final actual = _actual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(widget.titulo ?? SoleraL10n.t('mapa.punto_titulo')),
          subtitle: Text(actual == null
              ? '—'
              : '${actual.latitude.toStringAsFixed(5)}, '
                  '${actual.longitude.toStringAsFixed(5)}'),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _leyendoGps ? null : _usarGps,
              icon: _leyendoGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: Text(SoleraL10n.t('mapa.area_mi_posicion')),
            ),
            OutlinedButton.icon(
              onPressed: _marcarEnMapa,
              icon: const Icon(Icons.map_outlined),
              label: Text(SoleraL10n.t('mapa.marcar_punto')),
            ),
          ],
        ),
      ],
    );
  }
}

/// El área (contorno) de algo, con su superficie calculada. Si la app pasa
/// [alUsarSuperficie], ofrece copiar la superficie calculada a su campo
/// (la oficial manda: no se copia sola): en hectáreas o, con
/// [enMetrosCuadrados], en m².
class CampoArea extends StatelessWidget {
  const CampoArea({
    super.key,
    required this.vertices,
    required this.alCambiar,
    this.alUsarSuperficie,
    this.enMetrosCuadrados = false,
    this.titulo,
    this.centro,
    this.areasDeFondo = const [],
    this.paqueteApp = 'com.coleccionnuevoser.larrea',
  });

  final List<LatLng> vertices;
  final ValueChanged<List<LatLng>> alCambiar;
  final ValueChanged<double>? alUsarSuperficie;
  final bool enMetrosCuadrados;
  final String? titulo;

  /// Dónde abrir el mapa si aún no hay área (p. ej. el punto de la
  /// parcela).
  final LatLng? centro;
  final List<AreaDeFondo> areasDeFondo;
  final String paqueteApp;

  Future<void> _editar(BuildContext context) async {
    final nuevas = await editarArea(context,
        inicial: vertices,
        centro: centro,
        titulo: titulo,
        areasDeFondo: areasDeFondo,
        paqueteApp: paqueteApp);
    if (nuevas != null) alCambiar(nuevas);
  }

  @override
  Widget build(BuildContext context) {
    final hayArea = vertices.length >= 3;
    final hectareas = superficieHectareas(vertices);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.pentagon_outlined),
          title: Text(titulo ?? SoleraL10n.t('mapa.area_titulo')),
          subtitle: Text(hayArea
              ? '${SoleraL10n.tf('mapa.area_marcada', {
                      'hectareas': formatearHectareas(hectareas)
                    })} · ${SoleraL10n.tf('mapa.area_esquinas', {
                      'n': '${vertices.length}'
                    })}'
              : SoleraL10n.t('mapa.sin_area')),
        ),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => _editar(context),
              icon: const Icon(Icons.edit_location_alt_outlined),
              label: Text(hayArea
                  ? SoleraL10n.t('mapa.editar_area')
                  : SoleraL10n.t('mapa.marcar_area')),
            ),
            if (hayArea && alUsarSuperficie != null)
              TextButton(
                onPressed: () => alUsarSuperficie!(
                    enMetrosCuadrados ? hectareas * 10000 : hectareas),
                child: Text(enMetrosCuadrados
                    ? SoleraL10n.tf('mapa.usar_superficie_m2',
                        {'metros': formatearMetros(hectareas * 10000)})
                    : SoleraL10n.tf('mapa.usar_superficie',
                        {'hectareas': formatearHectareas(hectareas)})),
              ),
          ],
        ),
      ],
    );
  }
}
