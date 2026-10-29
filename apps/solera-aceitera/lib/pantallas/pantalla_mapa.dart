import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show buscarLugarEnMapa;

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import '../utiles/permisos_gps.dart';
import 'pantalla_ficha_parcela.dart';
import 'pantalla_nueva_parcela.dart';

enum _EstiloMapa { calle, satelite }

enum _OrigenAltaMapa { gps, centroMapa }

/// Pantalla principal del mapa del olivar — el agricultor abre la app
/// y ve sus parcelas. Tap en una parcela → ficha. FAB → nueva parcela
/// con GPS o centro de mapa.
///
/// Paridad con el patrón de viticultura/apícola/arbolado: capa base
/// toggle (calle/satélite), centro inicial inteligente (lastKnown →
/// GPS preciso → fallback Jaén), marker GPS, cluster, bottom bar con
/// capas/GPS/altitud y buscador de lugares en la barra. La meteo está
/// en Hoy.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final _controlador = MapController();
  final _bd = BaseDatosSoleraAceitera();
  List<Parcela> _conCoords = const [];
  List<Parcela> _sinCoords = const [];
  bool _cargando = true;
  _EstiloMapa _estiloMapa = _EstiloMapa.calle;
  double? _altitudGps;
  LatLng? _posicionGps;
  // Centro aproximado del olivar peninsular (Jaén — capital olivarera).
  LatLng _centroActual = const LatLng(37.78, -3.78);
  double _zoomActual = 7;
  bool _centroResuelto = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    _resolverCentroInicial();
  }

  Future<void> _cargar() async {
    final todas = await _bd.listarParcelas();
    if (!mounted) return;
    setState(() {
      _conCoords = todas
          .where((p) => p.latitud != null && p.longitud != null)
          .toList(growable: false);
      _sinCoords = todas
          .where((p) => p.latitud == null || p.longitud == null)
          .toList(growable: false);
      _cargando = false;
    });
    // Si hay parcelas con coords y aún no hemos centrado por GPS,
    // centramos en el centroide. Si después llega un fix GPS gana el GPS.
    if (_conCoords.isNotEmpty && !_centroResuelto) {
      final lat = _conCoords.map((p) => p.latitud!).reduce((a, b) => a + b) /
          _conCoords.length;
      final lon = _conCoords.map((p) => p.longitud!).reduce((a, b) => a + b) /
          _conCoords.length;
      _aplicarCentro(LatLng(lat, lon), 14);
    }
  }

  /// Centro inicial del mapa, en cascada: lastKnownPosition (cache
  /// del sistema, instantáneo) → getCurrentPosition (1-3 s, fix
  /// preciso) → centroide de parcelas → Jaén como fallback. Una vez
  /// resuelto, ya no se reasigna automáticamente.
  Future<void> _resolverCentroInicial() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && !_centroResuelto && mounted) {
        _altitudGps = last.altitude;
        _posicionGps = LatLng(last.latitude, last.longitude);
        _aplicarCentro(LatLng(last.latitude, last.longitude), 16);
      }
    } catch (_) {}
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido || !mounted) return;
    try {
      final pos = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 8));
      if (mounted) {
        _altitudGps = pos.altitude;
        _posicionGps = LatLng(pos.latitude, pos.longitude);
        _aplicarCentro(LatLng(pos.latitude, pos.longitude), 16);
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _buscarLugar() async {
    final lugar =
        await buscarLugarEnMapa(context, identificacion: 'Larrea Aceitera');
    if (lugar == null || !mounted) return;
    _aplicarCentro(lugar, 15);
  }

  void _aplicarCentro(LatLng centro, double zoom) {
    _centroActual = centro;
    _zoomActual = zoom;
    if (!_centroResuelto) {
      setState(() => _centroResuelto = true);
    } else {
      try {
        _controlador.move(centro, zoom);
      } catch (_) {}
    }
  }

  Future<void> _abrirNuevaParcela({double? latitud, double? longitud}) async {
    final olivar = await _bd.obtenerOlivar();
    if (!mounted) return;
    if (olivar?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta crear el olivar primero.')),
      );
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PantallaNuevaParcela(
        olivarId: olivar!.id!,
        latitudInicial: latitud,
        longitudInicial: longitud,
      ),
    ));
    if (mounted) await _cargar();
  }

  Future<void> _alAnadirAqui() async {
    final origen = await showModalBottomSheet<_OrigenAltaMapa>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.add_location),
              title: Text('Nueva parcela'),
              subtitle: Text('Elige cómo fijar el punto inicial.'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: const Text('Usar GPS actual'),
              subtitle: Text(
                _posicionGps == null
                    ? 'Captura una posición nueva del dispositivo.'
                    : 'Último GPS: ${_posicionGps!.latitude.toStringAsFixed(6)}, ${_posicionGps!.longitude.toStringAsFixed(6)}',
              ),
              onTap: () => Navigator.pop(context, _OrigenAltaMapa.gps),
            ),
            ListTile(
              leading: const Icon(Icons.center_focus_strong),
              title: const Text('Usar centro del mapa'),
              subtitle: Text(
                '${_centroActual.latitude.toStringAsFixed(6)}, ${_centroActual.longitude.toStringAsFixed(6)}',
              ),
              onTap: () => Navigator.pop(context, _OrigenAltaMapa.centroMapa),
            ),
          ],
        ),
      ),
    );
    if (origen == null) return;
    if (origen == _OrigenAltaMapa.centroMapa) {
      await _abrirNuevaParcela(
        latitud: _centroActual.latitude,
        longitud: _centroActual.longitude,
      );
      return;
    }

    double? latitud;
    double? longitud;
    try {
      final permitido = await asegurarPermisoUbicacion();
      if (permitido) {
        final pos = await Geolocator.getCurrentPosition()
            .timeout(const Duration(seconds: 6));
        latitud = pos.latitude;
        longitud = pos.longitude;
        if (mounted) {
          setState(() {
            _altitudGps = pos.altitude;
            _posicionGps = LatLng(pos.latitude, pos.longitude);
          });
        }
      }
    } catch (_) {
      // Cualquier fallo (permiso roto, plugin sin manifest, GPS lento)
      // se traga aquí — abrimos el formulario igualmente.
    }
    if (!mounted) return;
    if (latitud == null || longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'GPS no disponible — captura la ubicación desde el formulario.',
          ),
        ),
      );
    }
    await _abrirNuevaParcela(latitud: latitud, longitud: longitud);
  }

  void _alternarEstiloMapa() {
    setState(() {
      _estiloMapa = _estiloMapa == _EstiloMapa.calle
          ? _EstiloMapa.satelite
          : _EstiloMapa.calle;
    });
  }

  Future<void> _centrarEnGps() async {
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falta permiso de ubicación.')),
        );
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 8),
      );
      if (!mounted) return;
      setState(() {
        _altitudGps = pos.altitude;
        _posicionGps = LatLng(pos.latitude, pos.longitude);
      });
      _aplicarCentro(LatLng(pos.latitude, pos.longitude), 16);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener el GPS actual.')),
        );
      }
    }
  }

  List<Marker> _marcadores() {
    return [
      if (_posicionGps != null)
        Marker(
          point: _posicionGps!,
          width: 34,
          height: 34,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      for (final parcela in _conCoords)
        Marker(
          point: LatLng(parcela.latitud!, parcela.longitud!),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaFichaParcela(parcela: parcela),
                ),
              );
              if (mounted) await _cargar();
            },
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF5C6B3A),
              size: 36,
            ),
          ),
        ),
    ];
  }

  Future<void> _asignarGpsActual(Parcela p) async {
    Navigator.of(context).pop();
    final mensajero = ScaffoldMessenger.of(context);
    mensajero.showSnackBar(
      const SnackBar(content: Text('Capturando GPS…')),
    );
    try {
      final permiso = await asegurarPermisoUbicacion();
      if (!mounted) return;
      if (!permiso) {
        mensajero
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'GPS no disponible. Revisa que la ubicación esté '
                'encendida y los permisos concedidos.',
              ),
            ),
          );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      if (!mounted) return;
      await _bd.actualizarParcelaCoords(
        id: p.id!,
        latitud: pos.latitude,
        longitud: pos.longitude,
      );
      if (!mounted) return;
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'GPS asignado a ${p.nombre}: '
              '${pos.latitude.toStringAsFixed(5)}, '
              '${pos.longitude.toStringAsFixed(5)}',
            ),
          ),
        );
      await _cargar();
    } catch (e) {
      if (!mounted) return;
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Error capturando GPS: $e')),
        );
    }
  }

  void _mostrarSinCoords() {
    if (_sinCoords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las parcelas tienen coordenadas.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Parcelas sin coordenadas (${_sinCoords.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ..._sinCoords.map((p) => ListTile(
                  leading: const Icon(Icons.location_off),
                  title: Text(p.nombre),
                  subtitle: p.codigoSigpac.isNotEmpty
                      ? Text(p.codigoSigpac)
                      : null,
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('Asignar GPS'),
                    onPressed: () => _asignarGpsActual(p),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PantallaFichaParcela(parcela: p),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mapa')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar un lugar',
            onPressed: _buscarLugar,
          ),
          IconButton(
            tooltip: 'Parcelas sin coordenadas',
            onPressed: _mostrarSinCoords,
            icon: _sinCoords.isEmpty
                ? const Icon(Icons.location_off_outlined)
                : Badge(
                    label: Text('${_sinCoords.length}'),
                    child: const Icon(Icons.location_off),
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            child: FlutterMap(
              mapController: _controlador,
              options: MapOptions(
                initialCenter: _centroActual,
                initialZoom: _zoomActual,
                minZoom: 3,
                maxZoom: 22,
                onPositionChanged: (cam, _) {
                  _centroActual = cam.center;
                  _zoomActual = cam.zoom;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _estiloMapa == _EstiloMapa.calle
                      ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                      : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName:
                      'com.coleccionnuevoser.solera_aceitera',
                  maxZoom: 22,
                  maxNativeZoom: 19,
                  keepBuffer: 4,
                  panBuffer: 1,
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 42,
                    disableClusteringAtZoom: 21,
                    size: const Size(40, 40),
                    alignment: Alignment.center,
                    markers: _marcadores(),
                    builder: (context, markers) => Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF5C6B3A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_estiloMapa == _EstiloMapa.satelite)
            Positioned(
              left: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'Esri satélite',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ),
          Center(
            child: IgnorePointer(
              child: Icon(
                Icons.add_location_alt_outlined,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
                shadows: const [
                  Shadow(color: Colors.white, blurRadius: 4),
                  Shadow(color: Colors.white, blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _alternarEstiloMapa,
                      icon: Icon(
                        _estiloMapa == _EstiloMapa.calle
                            ? Icons.layers_outlined
                            : Icons.map_outlined,
                      ),
                      label: Text(
                        _estiloMapa == _EstiloMapa.calle ? 'Capas' : 'Mapa',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _centrarEnGps,
                      icon: const Icon(Icons.my_location),
                      label: const Text('GPS'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Text(_altitudGps == null
                          ? 'Alt. GPS --'
                          : 'Alt. GPS ${_altitudGps!.toStringAsFixed(0)} m'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _alAnadirAqui,
        icon: const Icon(Icons.add_location),
        label: const Text('Nueva parcela'),
      ),
    );
  }
}
