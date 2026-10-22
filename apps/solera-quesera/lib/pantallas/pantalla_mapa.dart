import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/proveedor_leche.dart';
import '../utiles/permisos_gps.dart';
import 'pantalla_lista_proveedores.dart';

enum _AccionMenu { proveedores }

enum _EstiloMapa { calle, satelite }

/// Mapa de proveedores de leche de la quesería — ganaderos externos y
/// rebaño propio. Tap en un marker → sheet con info y atajo a la lista
/// de proveedores. FAB → gestión de proveedores (crear / editar).
///
/// Paridad con el patrón de viticultura/apícola/arbolado/aceitera:
/// capa base toggle (calle / satélite), centro inicial inteligente
/// (lastKnown → GPS preciso → centroide proveedores → fallback Iberia),
/// marker GPS "yo aquí", cluster, bottom bar Capas/GPS/Altitud.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final _controlador = MapController();
  final _bd = BaseDatosSoleraQuesera.instancia;
  List<ProveedorLeche> _proveedores = const [];
  bool _cargando = true;
  _EstiloMapa _estiloMapa = _EstiloMapa.calle;
  double? _altitudGps;
  LatLng? _posicionGps;
  // Centro de Iberia como fallback amplio.
  LatLng _centroActual = const LatLng(40.4, -3.7);
  double _zoomActual = 6;
  bool _centroResuelto = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    _resolverCentroInicial();
  }

  Future<void> _cargar() async {
    final lista = await _bd.listarProveedores();
    if (!mounted) return;
    setState(() {
      _proveedores = lista;
      _cargando = false;
    });
    final conCoords = lista
        .where((p) => p.latitud != null && p.longitud != null)
        .toList(growable: false);
    if (conCoords.isNotEmpty && !_centroResuelto) {
      final lat =
          conCoords.map((p) => p.latitud!).reduce((a, b) => a + b) /
              conCoords.length;
      final lon =
          conCoords.map((p) => p.longitud!).reduce((a, b) => a + b) /
              conCoords.length;
      _aplicarCentro(LatLng(lat, lon), 11);
    }
  }

  Future<void> _resolverCentroInicial() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && !_centroResuelto && mounted) {
        _altitudGps = last.altitude;
        _posicionGps = LatLng(last.latitude, last.longitude);
        _aplicarCentro(LatLng(last.latitude, last.longitude), 14);
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
        _aplicarCentro(LatLng(pos.latitude, pos.longitude), 14);
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

  Future<void> _buscarLugar() async {
    final lugar =
        await buscarLugarEnMapa(context, identificacion: 'Solera Quesera');
    if (lugar == null || !mounted) return;
    _aplicarCentro(lugar, 15);
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
      _aplicarCentro(LatLng(pos.latitude, pos.longitude), 14);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener el GPS actual.')),
        );
      }
    }
  }

  Future<void> _abrirGestionProveedores() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PantallaListaProveedores()),
    );
    if (mounted) await _cargar();
  }

  void _mostrarFichaProveedor(ProveedorLeche p) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFC8923B).withValues(alpha: 0.18),
                    child: Icon(
                      p.esPropio ? Icons.home : Icons.pets,
                      color: const Color(0xFFC8923B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nombre,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '${p.esPropio ? 'Rebaño propio' : 'Ganadero externo'} · '
                          '${p.tipoLeche}'
                          '${p.numAnimales != null ? ' · ${p.numAnimales} cabezas' : ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (p.explotacionGanadera.isNotEmpty)
                _Fila(clave: 'REGA', valor: p.explotacionGanadera),
              if (p.nif.isNotEmpty) _Fila(clave: 'NIF', valor: p.nif),
              if (p.direccion.isNotEmpty)
                _Fila(clave: 'Dirección', valor: p.direccion),
              if (p.notas.isNotEmpty) _Fila(clave: 'Notas', valor: p.notas),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _abrirGestionProveedores();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      for (final p in _proveedores)
        if (p.latitud != null && p.longitud != null)
          Marker(
            point: LatLng(p.latitud!, p.longitud!),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _mostrarFichaProveedor(p),
              child: Icon(
                p.esPropio ? Icons.home : Icons.pets,
                color: const Color(0xFFC8923B),
                size: 32,
              ),
            ),
          ),
    ];
  }

  int get _sinCoordsCount =>
      _proveedores.where((p) => p.latitud == null || p.longitud == null).length;

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: Text(SoleraL10n.t('mapa'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('mapa')),
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
                case _AccionMenu.proveedores:
                  await _abrirGestionProveedores();
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _AccionMenu.proveedores,
                child: ListTile(
                  leading: _sinCoordsCount > 0
                      ? Badge(
                          label: Text('$_sinCoordsCount'),
                          child: const Icon(Icons.pets),
                        )
                      : const Icon(Icons.pets),
                  title: const Text('Gestión de proveedores'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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
                  userAgentPackageName: 'com.josu.solera_quesera',
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
                        color: Color(0xFFC8923B),
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
          if (_proveedores.isEmpty)
            Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pets, size: 48, color: Color(0xFFC8923B)),
                      const SizedBox(height: 12),
                      const Text(
                        'Aún no hay proveedores de leche.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Da de alta los ganaderos externos y/o tu rebaño propio '
                        'para que aparezcan en el mapa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _abrirGestionProveedores,
                        icon: const Icon(Icons.add),
                        label: const Text('Gestión de proveedores'),
                      ),
                    ],
                  ),
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
        heroTag: 'fab_proveedores_mapa',
        onPressed: _abrirGestionProveedores,
        icon: const Icon(Icons.pets),
        label: const Text('Proveedores'),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String clave;
  final String valor;
  const _Fila({required this.clave, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(clave,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Expanded(child: Text(valor, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
