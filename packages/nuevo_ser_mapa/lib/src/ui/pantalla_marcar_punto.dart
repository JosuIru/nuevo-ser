// Marcar un punto en el mapa: una cruz fija en el centro; se mueve el mapa
// (o se toca el sitio) y «Usar este punto». Con el GPS se va a la posición
// actual. Devuelve el punto o null si se cancela.
//
// Sustituye a los «Usar mi ubicación» de cada app, que solo admitían el
// GPS: así se puede marcar un sitio sin estar en él.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, buscarLugarEnMapa;

import '../gps/ubicacion.dart';
import 'capas.dart';
import 'pantalla_editor_area.dart' show centroPeninsula, AreaDeFondo;

/// Resultado de marcar: el punto, o la orden de quitarlo.
typedef PuntoMarcado = ({LatLng? punto});

Future<PuntoMarcado?> marcarPunto(
  BuildContext context, {
  LatLng? inicial,
  LatLng? centro,
  String? titulo,
  List<AreaDeFondo> areasDeFondo = const [],
  String paqueteApp = 'com.coleccionnuevoser.larrea',
}) =>
    Navigator.of(context).push<PuntoMarcado>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PantallaMarcarPunto(
        inicial: inicial,
        centro: centro,
        titulo: titulo,
        areasDeFondo: areasDeFondo,
        paqueteApp: paqueteApp,
      ),
    ));

class PantallaMarcarPunto extends StatefulWidget {
  const PantallaMarcarPunto({
    super.key,
    this.inicial,
    this.centro,
    this.titulo,
    this.areasDeFondo = const [],
    this.paqueteApp = 'com.coleccionnuevoser.larrea',
    this.conTeselas = true,
    this.leerGps = leerPosicionActual,
  });

  final LatLng? inicial;
  final LatLng? centro;
  final String? titulo;
  final List<AreaDeFondo> areasDeFondo;
  final String paqueteApp;
  final bool conTeselas;
  final Future<LecturaGps?> Function() leerGps;

  @override
  State<PantallaMarcarPunto> createState() => _PantallaMarcarPuntoState();
}

class _PantallaMarcarPuntoState extends State<PantallaMarcarPunto> {
  final MapController _controladorMapa = MapController();
  late LatLng _centro = widget.inicial ?? widget.centro ?? centroPeninsula;
  CapaBase _capa = CapaBase.callejero;
  bool _leyendoGps = false;
  double? _precisionMetros;

  @override
  void initState() {
    super.initState();
    // Sin sitio de partida, se intenta empezar donde está la persona.
    if (widget.inicial == null && widget.centro == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _irAMiUbicacion());
    }
  }

  Future<void> _irAMiUbicacion() async {
    setState(() => _leyendoGps = true);
    final lectura = await widget.leerGps();
    if (!mounted) return;
    setState(() => _leyendoGps = false);
    if (lectura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('mapa.sin_gps'))));
      return;
    }
    _controladorMapa.move(lectura.posicion, 18);
    setState(() {
      _centro = lectura.posicion;
      _precisionMetros = lectura.precisionMetros;
    });
  }

  Future<void> _buscar() async {
    final lugar = await buscarLugarEnMapa(context);
    if (lugar == null || !mounted) return;
    _controladorMapa.move(lugar, 16);
  }

  void _moverA(LatLng punto) {
    _controladorMapa.move(punto, _controladorMapa.camera.zoom);
    setState(() {
      _centro = punto;
      _precisionMetros = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo ?? SoleraL10n.t('mapa.punto_titulo')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('mapa.buscar'),
            icon: const Icon(Icons.search),
            onPressed: _buscar,
          ),
          if (widget.inicial != null)
            IconButton(
              tooltip: SoleraL10n.t('mapa.punto_quitar'),
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  Navigator.pop(context, (punto: null) as PuntoMarcado),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controladorMapa,
            options: MapOptions(
              initialCenter: _centro,
              initialZoom:
                  widget.inicial != null || widget.centro != null ? 17 : 6,
              maxZoom: 22,
              onTap: (_, punto) => _moverA(punto),
              onPositionChanged: (camara, _) => setState(() {
                _centro = camara.center;
              }),
            ),
            children: [
              if (widget.conTeselas)
                capaDeTeselas(_capa, paqueteApp: widget.paqueteApp),
              PolygonLayer(polygons: [
                for (final fondo in widget.areasDeFondo)
                  if (fondo.vertices.length >= 3)
                    Polygon(
                      points: fondo.vertices,
                      color: colores.primary.withValues(alpha: 0.12),
                      borderColor: colores.primary,
                      borderStrokeWidth: 1.5,
                      label: fondo.nombre,
                    ),
              ]),
              AtribucionCapa(_capa),
            ],
          ),
          // La cruz marca el centro del mapa: ese es el punto.
          IgnorePointer(
            child: Center(
              child: Icon(Icons.add, size: 44, color: colores.error),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'mapa.capa',
                  tooltip: SoleraL10n.t('mapa.cambiar_capa'),
                  onPressed: () => setState(() => _capa = _capa.otra),
                  child: Icon(_capa == CapaBase.ortofoto
                      ? Icons.map_outlined
                      : Icons.satellite_alt_outlined),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'mapa.ubicacion',
                  tooltip: SoleraL10n.t('mapa.mi_ubicacion'),
                  onPressed: _leyendoGps ? null : _irAMiUbicacion,
                  child: _leyendoGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            right: 64,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(SoleraL10n.t('mapa.punto_ayuda')),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${_centro.latitude.toStringAsFixed(6)}, '
                '${_centro.longitude.toStringAsFixed(6)}'
                '${_precisionMetros == null ? '' : '  (±${_precisionMetros!.round()} m)'}',
                key: const ValueKey('mapa.coordenadas'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.pop(context, (punto: _centro) as PuntoMarcado),
                icon: const Icon(Icons.check),
                label: Text(SoleraL10n.t('mapa.punto_usar')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
