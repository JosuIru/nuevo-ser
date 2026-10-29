import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../datos/base_datos.dart';
import '../estado/zona_activa.dart';
import '../modelos/arbol.dart';
import '../modelos/zona.dart';
import '../utiles/permisos_gps.dart';
import 'pantalla_escaner_qr.dart';
import 'pantalla_ficha_arbol.dart';
import 'pantalla_nuevo_arbol.dart';

/// Capa de fondo del mapa: callejero (OSM) o foto aérea (Esri).
enum _CapaMapa { callejero, satelite }

const _urlCapaCallejero = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _urlCapaSatelite =
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

/// Pantalla principal de Larrea Arbolado Urbano — el operario abre la
/// app y ve los árboles del municipio sobre el mapa filtrados por zona.
/// Tap en un árbol → ficha. FAB principal "Nuevo árbol" con captura
/// GPS. Botón cámara abre escáner QR para localizar un árbol existente
/// por su chapa. Es la pestaña con la que arranca la app.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key, this.avisoRecarga});

  /// Si se da, el mapa relee zonas y árboles cada vez que avisa (al
  /// volver a la pestaña desde la lista, por ejemplo).
  final Listenable? avisoRecarga;

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final _controlador = MapController();
  final _persistenciaZona = ZonaActivaPersistida();
  List<Zona> _zonas = [];
  List<Arbol> _arboles = [];
  int? _zonaActivaId;
  LatLng _centroActual = LatLng(40.4, -3.7);
  double _zoomActual = 6;
  bool _centroResuelto = false;
  _CapaMapa _capaMapa = _CapaMapa.callejero;

  @override
  void initState() {
    super.initState();
    widget.avisoRecarga?.addListener(_cargarTodo);
    _cargarTodo();
    _resolverCentroInicial();
  }

  @override
  void dispose() {
    widget.avisoRecarga?.removeListener(_cargarTodo);
    super.dispose();
  }

  Future<void> _resolverCentroInicial() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && !_centroResuelto && mounted) {
        _aplicarCentro(LatLng(last.latitude, last.longitude), 16);
      }
    } catch (_) {}
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido || !mounted) return;
    try {
      final pos =
          await Geolocator.getCurrentPosition().timeout(Duration(seconds: 8));
      if (mounted) _aplicarCentro(LatLng(pos.latitude, pos.longitude), 16);
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

  void _alternarCapaMapa() {
    setState(() {
      _capaMapa = _capaMapa == _CapaMapa.callejero
          ? _CapaMapa.satelite
          : _CapaMapa.callejero;
    });
  }

  /// Busca una calle, plaza o dirección y lleva el mapa allí (zoom de
  /// ciudad: se ven los árboles uno a uno).
  Future<void> _alBuscarLugar() async {
    final lugar = await buscarLugarEnMapa(
      context,
      identificacion: 'Larrea Arbolado Urbano',
    );
    if (lugar == null || !mounted) return;
    // Movemos siempre: el GPS inicial ya no debe pisar lo buscado.
    _centroResuelto = true;
    _centroActual = lugar;
    _zoomActual = 17;
    _controlador.move(lugar, 17);
  }

  Future<void> _cargarTodo() async {
    final zonas = await BaseDatosSoleraArbolado.instancia.listarZonas();
    final zonaActivaId = await _persistenciaZona.cargar();
    final arboles =
        await BaseDatosSoleraArbolado.instancia.listarArboles(zonaId: zonaActivaId);
    if (!mounted) return;
    setState(() {
      _zonas = zonas;
      _arboles = arboles;
      _zonaActivaId = zonaActivaId;
    });
  }

  Future<void> _cambiarZonaActiva(int? nuevaId) async {
    await _persistenciaZona.guardar(nuevaId);
    final arboles =
        await BaseDatosSoleraArbolado.instancia.listarArboles(zonaId: nuevaId);
    if (!mounted) return;
    setState(() {
      _zonaActivaId = nuevaId;
      _arboles = arboles;
    });
  }

  Future<void> _abrirNuevoArbol({double? latitud, double? longitud, String? qrPayload}) async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoArbol(
          zonaIdInicial: _zonaActivaId,
          latitudInicial: latitud,
          longitudInicial: longitud,
          qrPayloadInicial: qrPayload,
        ),
      ),
    );
    if (creado == true) _cargarTodo();
  }

  Future<void> _alAnadirAqui() async {
    // Intentamos GPS, pero abrimos el formulario PASE LO QUE PASE.
    // Sin permiso o sin señal, el formulario permite capturar la
    // ubicación más tarde con el botón "Recapturar".
    double? latitud;
    double? longitud;
    try {
      final permitido = await asegurarPermisoUbicacion();
      if (permitido) {
        final pos = await Geolocator.getCurrentPosition()
            .timeout(Duration(seconds: 6));
        latitud = pos.latitude;
        longitud = pos.longitude;
      }
    } catch (_) {
      // Cualquier fallo (permiso roto, plugin sin manifest, GPS lento)
      // se traga aquí — abrimos el formulario igualmente.
    }
    if (!mounted) return;
    if (latitud == null || longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'GPS no disponible — captura la ubicación desde el formulario.',
        )),
      );
    }
    await _abrirNuevoArbol(latitud: latitud, longitud: longitud);
  }

  Future<void> _alEscanearQr() async {
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => PantallaEscanerQr()),
    );
    if (payload == null || payload.isEmpty || !mounted) return;
    final arbol =
        await BaseDatosSoleraArbolado.instancia.obtenerArbolPorQrPayload(payload);
    if (!mounted) return;
    if (arbol != null) {
      final cambio = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PantallaFichaArbol(arbolId: arbol.id!)),
      );
      if (cambio == true) _cargarTodo();
    } else {
      // No hay árbol con ese QR — ofrecer dar de alta uno nuevo prerelleno.
      final crear = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('QR no reconocido'),
          content: Text(
            'No hay ningún árbol con el QR "$payload" en el inventario.\n\n'
            '¿Quieres dar de alta uno nuevo con este QR?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
            FilledButton(
                onPressed: () => Navigator.pop(context, true), child: Text('Dar de alta')),
          ],
        ),
      );
      if (crear == true && mounted) {
        await _abrirNuevoArbol(qrPayload: payload);
      }
    }
  }

  Future<void> _abrirSelectorZona() async {
    final activo = _zonaActivaId;
    final elegido = await showModalBottomSheet<int?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.public),
              title: Text('Todo el municipio'),
              trailing: activo == null ? Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, null),
            ),
            Divider(height: 1),
            for (final z in _zonas)
              ListTile(
                leading: Icon(Icons.location_on, color: Color(z.colorEntero)),
                title: Text(z.nombre),
                subtitle: z.codigoMunicipal.isEmpty ? null : Text(z.codigoMunicipal),
                trailing: activo == z.id ? Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, z.id),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (elegido != activo) await _cambiarZonaActiva(elegido);
  }

  Color _colorEstadoArbol(EstadoArbol e, ColorScheme paleta) {
    switch (e) {
      case EstadoArbol.sano:
        return paleta.primary;
      case EstadoArbol.observacion:
        return Colors.amber.shade700;
      case EstadoArbol.riesgo:
        return Colors.red;
      case EstadoArbol.caido:
        return Colors.grey.shade700;
      case EstadoArbol.sustituido:
        return Colors.blueGrey;
    }
  }

  List<Marker> _marcadores() {
    final paleta = Theme.of(context).colorScheme;
    return [
      for (final a in _arboles)
        if (a.latitud != null && a.longitud != null)
          Marker(
            point: LatLng(a.latitud!, a.longitud!),
            width: 36,
            height: 36,
            child: GestureDetector(
              onTap: () async {
                final cambio = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => PantallaFichaArbol(arbolId: a.id!)),
                );
                if (cambio == true) _cargarTodo();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _colorEstadoArbol(a.estado, paleta),
                  border: Border.all(color: Colors.white, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.park, color: Colors.white, size: 14),
              ),
            ),
          ),
    ];
  }

  String _tituloFiltro() {
    if (_zonaActivaId == null) return 'Todo el municipio';
    final z = _zonas.where((z) => z.id == _zonaActivaId).firstOrNull;
    return z?.nombre ?? 'Zona';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Larrea Arbolado Urbano'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Buscar un lugar',
            onPressed: _alBuscarLugar,
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            tooltip: 'Buscar por QR',
            onPressed: _alEscanearQr,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _controlador,
                  options: MapOptions(
                    initialCenter: _centroActual,
                    initialZoom: _zoomActual,
                    minZoom: 3,
                    maxZoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _capaMapa == _CapaMapa.callejero
                          ? _urlCapaCallejero
                          : _urlCapaSatelite,
                      userAgentPackageName: 'com.coleccionnuevoser.solera_arbolado_urbano',
                      maxNativeZoom: 19,
                    ),
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 60,
                        size: Size(40, 40),
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
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                      onTap: _abrirSelectorZona,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list, size: 16),
                            SizedBox(width: 6),
                            Text(_tituloFiltro()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Selector de capa: callejero ↔ satélite, como en Larrea.
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      onTap: _alternarCapaMapa,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _capaMapa == _CapaMapa.callejero
                                  ? Icons.satellite_alt
                                  : Icons.map_outlined,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(_capaMapa == _CapaMapa.callejero
                                ? 'Satélite'
                                : 'Callejero'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_capaMapa == _CapaMapa.satelite)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text(
                          'Esri satélite',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _alAnadirAqui,
        icon: Icon(Icons.add_location),
        label: Text('Nuevo árbol'),
      ),
    );
  }
}
