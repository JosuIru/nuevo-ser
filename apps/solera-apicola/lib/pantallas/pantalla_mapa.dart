import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../datos/base_datos.dart';
import '../estado/apiario_activo.dart';
import '../modelos/apiario.dart';
import '../modelos/colmena.dart';
import '../utiles/permisos_gps.dart';
import 'pantalla_ficha_colmena.dart';
import 'pantalla_gestion_apiarios.dart';
import 'pantalla_libro_rega.dart';
import 'pantalla_nueva_colmena.dart';

enum _AccionMenu { apiarios, libroRega }

enum _EstiloMapa { calle, satelite }

enum _OrigenAltaMapa { gps, centroMapa }

/// Pantalla principal de Larrea Apícola — el apicultor abre la app y
/// ve sus apiarios y colmenas sobre el mapa. Tap en una colmena →
/// ficha. FAB → nueva colmena con captura GPS.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final _controlador = MapController();
  final _persistenciaApiario = ApiarioActivoPersistido();
  List<Apiario> _apiarios = [];
  List<Colmena> _colmenas = [];
  int? _apiarioActivoId;
  _EstiloMapa _estiloMapa = _EstiloMapa.calle;
  double? _altitudGps;
  LatLng? _posicionGps;
  LatLng _centroActual = const LatLng(40.4, -3.7);
  double _zoomActual = 6;
  bool _centroResuelto = false;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
    _resolverCentroInicial();
  }

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

  /// Abre el buscador de lugares del core y lleva el mapa al resultado.
  Future<void> _buscarLugar() async {
    final lugarEncontrado =
        await buscarLugarEnMapa(context, identificacion: 'Larrea Apicola');
    if (lugarEncontrado == null || !mounted) return;
    _aplicarCentro(lugarEncontrado, 15);
  }

  Future<void> _cargarTodo() async {
    final apiarios = await BaseDatosSoleraApicola.instancia.listarApiarios();
    final apiarioActivoId = await _persistenciaApiario.cargar();
    final colmenas = await BaseDatosSoleraApicola.instancia
        .listarColmenas(apiarioId: apiarioActivoId);
    if (!mounted) return;
    setState(() {
      _apiarios = apiarios;
      _colmenas = colmenas;
      _apiarioActivoId = apiarioActivoId;
    });
  }

  Future<void> _cambiarApiarioActivo(int? nuevaId) async {
    await _persistenciaApiario.guardar(nuevaId);
    final colmenas = await BaseDatosSoleraApicola.instancia
        .listarColmenas(apiarioId: nuevaId);
    if (!mounted) return;
    setState(() {
      _apiarioActivoId = nuevaId;
      _colmenas = colmenas;
    });
  }

  Future<void> _abrirNuevaColmena({double? latitud, double? longitud}) async {
    final creada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevaColmena(
          apiarioIdInicial: _apiarioActivoId,
          latitudInicial: latitud,
          longitudInicial: longitud,
        ),
      ),
    );
    if (creada == true) _cargarTodo();
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
              title: Text('Nueva colmena'),
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
      await _abrirNuevaColmena(
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
        } else {
          _altitudGps = pos.altitude;
          _posicionGps = LatLng(pos.latitude, pos.longitude);
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
        )),
      );
    }
    await _abrirNuevaColmena(latitud: latitud, longitud: longitud);
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

  Future<void> _abrirSelectorApiario() async {
    final activo = _apiarioActivoId;
    final elegido = await showModalBottomSheet<int?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Todas las colmenas'),
              trailing: activo == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, null),
            ),
            const Divider(height: 1),
            for (final a in _apiarios)
              ListTile(
                leading: Icon(Icons.location_on, color: Color(a.colorEntero)),
                title: Text(a.nombre),
                subtitle: a.codigoSitran.isEmpty
                    ? null
                    : Text('SITRAN ${a.codigoSitran}'),
                trailing: activo == a.id ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, a.id),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (elegido != activo) await _cambiarApiarioActivo(elegido);
  }

  List<Marker> _marcadores() {
    final paleta = Theme.of(context).colorScheme;
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
      for (final c in _colmenas)
        if (c.ultimaLatitud != null && c.ultimaLongitud != null)
          Marker(
            point: LatLng(c.ultimaLatitud!, c.ultimaLongitud!),
            width: 36,
            height: 36,
            child: GestureDetector(
              onTap: () async {
                final cambio = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => PantallaFichaColmena(colmenaId: c.id!)),
                );
                if (cambio == true) _cargarTodo();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: c.estado == EstadoColmena.viva
                      ? paleta.primary
                      : Colors.grey.shade400,
                  border: Border.all(color: Colors.white, width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hexagon, color: Colors.white, size: 12),
              ),
            ),
          ),
    ];
  }

  String _tituloFiltro() {
    if (_apiarioActivoId == null) return 'Todas las colmenas';
    final a = _apiarios.where((a) => a.id == _apiarioActivoId).firstOrNull;
    return a?.nombre ?? 'Apiario';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Larrea Apícola'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar un lugar',
            onPressed: _buscarLugar,
          ),
          PopupMenuButton<_AccionMenu>(
            tooltip: 'Más',
            onSelected: (a) async {
              switch (a) {
                case _AccionMenu.apiarios:
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => const PantallaGestionApiarios(),
                    ),
                  );
                  break;
                case _AccionMenu.libroRega:
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                        builder: (_) => const PantallaLibroRega()),
                  );
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _AccionMenu.apiarios,
                child: ListTile(
                  leading: Icon(Icons.hub),
                  title: Text('Apiarios'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _AccionMenu.libroRega,
                child: ListTile(
                  leading: Icon(Icons.description),
                  title: Text('Libro REGA'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
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
                userAgentPackageName: 'com.coleccionnuevoser.solera_apicola',
                maxZoom: 22,
                maxNativeZoom: 19,
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 42,
                  disableClusteringAtZoom: 21,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  markers: _marcadores(),
                  builder: (context, markers) {
                    final paleta = Theme.of(context).colorScheme;
                    return Container(
                      decoration: BoxDecoration(
                        color: paleta.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                onTap: _abrirSelectorApiario,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, size: 16),
                      const SizedBox(width: 6),
                      Text(_tituloFiltro()),
                    ],
                  ),
                ),
              ),
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
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        _altitudGps == null
                            ? 'Alt. GPS --'
                            : 'Alt. GPS ${_altitudGps!.toStringAsFixed(0)} m',
                      ),
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
        label: const Text('Nueva colmena'),
      ),
    );
  }
}
