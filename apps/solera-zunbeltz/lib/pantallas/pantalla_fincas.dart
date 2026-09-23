import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/zona_finca.dart';
import '../utiles/estilos_tarea.dart';
import '../utiles/geodesia.dart';
import '../utiles/permisos_gps.dart';
import 'ficha_punto.dart';
import 'ficha_zona.dart';
import 'nueva_zona.dart';
import 'nuevo_punto.dart';
import 'pantalla_meteo.dart';
import 'tablero_tareas.dart';

enum _EstiloMapa { calle, satelite }

enum _OrigenAlta { gps, centroMapa }

/// Pestaña "Fincas": mapa de Zunbeltz y La Planilla con sus puntos de
/// infraestructura y sus zonas dibujadas. Tap en un punto → ficha con sus
/// tareas; tap dentro de una zona → ficha de la zona. FAB → nuevo punto
/// (GPS o centro del mapa) o dibujar zona. Acción → tablero de tareas.
///
/// El mapa tiene tres modos, y el toque significa una cosa distinta en
/// cada uno: en normal añade un punto (o abre la zona tocada), en
/// recolocar fija la nueva posición de un punto, y en dibujo cada toque
/// marca una esquina de la zona en curso.
class PantallaFincas extends StatefulWidget {
  const PantallaFincas({super.key});

  @override
  State<PantallaFincas> createState() => _PantallaFincasState();
}

class _PantallaFincasState extends State<PantallaFincas> {
  final _controlador = MapController();
  final _bd = BaseDatosSoleraZunbeltz();
  List<Finca> _fincas = const [];
  List<PuntoInfraestructura> _conCoords = const [];
  List<ZonaFinca> _zonas = const [];
  bool _cargando = true;
  _EstiloMapa _estiloMapa = _EstiloMapa.calle;
  LatLng? _posicionGps;
  // Id del punto que se está recolocando (el siguiente toque fija su nueva
  // posición); null = modo normal (el toque añade un punto nuevo).
  int? _recolocandoId;
  // Esquinas de la zona que se está dibujando; vacío = no hay dibujo en
  // curso. Mientras haya dibujo, el toque del mapa marca esquinas y no
  // añade puntos.
  List<LatLng> _trazado = const [];
  bool _dibujando = false;
  // Zona cuyo trazado se está rehaciendo (null = zona nueva).
  int? _redibujandoZonaId;
  // Centro aproximado de la zona de Andía / Tierra Estella (Navarra).
  LatLng _centroActual = const LatLng(42.793, -1.958);
  double _zoomActual = 12;
  bool _centroResuelto = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    _resolverCentroInicial();
    notificadorDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => _cargar();

  Future<void> _cargar() async {
    var fincas = <Finca>[];
    var puntos = <PuntoInfraestructura>[];
    var zonas = <ZonaFinca>[];
    try {
      await _bd.sembrarEspacioRealSiVacia();
      fincas = await _bd.listarFincas();
      puntos = await _bd.listarPuntos();
      zonas = await _bd.listarZonas();
    } catch (_) {
      // Sin BD disponible (p. ej. en tests sin plugins) mostramos el mapa
      // vacío en lugar de romper la pestaña.
    }
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _conCoords = puntos
          .where((p) => p.latitud != null && p.longitud != null)
          .toList(growable: false);
      _zonas = zonas.where((z) => z.esPoligonoValido).toList(growable: false);
      _cargando = false;
    });
    if (!_centroResuelto) {
      final referencia = <LatLng>[];
      if (_conCoords.isNotEmpty) {
        for (final p in _conCoords) {
          referencia.add(LatLng(p.latitud!, p.longitud!));
        }
      } else {
        for (final f in fincas) {
          if (f.latitud != null && f.longitud != null) {
            referencia.add(LatLng(f.latitud!, f.longitud!));
          }
        }
      }
      if (referencia.isNotEmpty) {
        final lat = referencia.map((p) => p.latitude).reduce((a, b) => a + b) /
            referencia.length;
        final lon = referencia.map((p) => p.longitude).reduce((a, b) => a + b) /
            referencia.length;
        _aplicarCentro(LatLng(lat, lon), 13);
      }
    }
  }

  Future<void> _resolverCentroInicial() async {
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && !_centroResuelto && mounted) {
        _posicionGps = LatLng(last.latitude, last.longitude);
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

  Future<void> _centrarEnGps() async {
    final textos = AppLocalizations.of(context);
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(textos.mapaGpsNoDisponible)));
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 8));
      if (!mounted) return;
      setState(() => _posicionGps = LatLng(pos.latitude, pos.longitude));
      _aplicarCentro(LatLng(pos.latitude, pos.longitude), 16);
    } catch (_) {}
  }

  Future<int?> _elegirFinca() async {
    if (_fincas.length == 1) return _fincas.first.id;
    final textos = AppLocalizations.of(context);
    return showModalBottomSheet<int>(
      useSafeArea: true,
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(textos.mapaElegirFinca)),
            const Divider(height: 1),
            for (final f in _fincas)
              ListTile(
                leading: const Icon(Icons.landscape_outlined),
                title: Text(f.nombre),
                onTap: () => Navigator.pop(context, f.id),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _alAnadirPunto() async {
    final textos = AppLocalizations.of(context);
    final fincaId = await _elegirFinca();
    if (fincaId == null || !mounted) return;

    final origen = await showModalBottomSheet<_OrigenAlta>(
      useSafeArea: true,
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.gps_fixed),
              title: Text(textos.mapaUsarGps),
              onTap: () => Navigator.pop(context, _OrigenAlta.gps),
            ),
            ListTile(
              leading: const Icon(Icons.center_focus_strong),
              title: Text(textos.mapaUsarCentro),
              subtitle: Text(
                  '${_centroActual.latitude.toStringAsFixed(5)}, ${_centroActual.longitude.toStringAsFixed(5)}'),
              onTap: () => Navigator.pop(context, _OrigenAlta.centroMapa),
            ),
          ],
        ),
      ),
    );
    if (origen == null || !mounted) return;

    double? latitud;
    double? longitud;
    if (origen == _OrigenAlta.centroMapa) {
      latitud = _centroActual.latitude;
      longitud = _centroActual.longitude;
    } else {
      try {
        final permitido = await asegurarPermisoUbicacion();
        if (permitido) {
          final pos = await Geolocator.getCurrentPosition()
              .timeout(const Duration(seconds: 8));
          latitud = pos.latitude;
          longitud = pos.longitude;
          if (mounted) {
            setState(() => _posicionGps = LatLng(pos.latitude, pos.longitude));
          }
        }
      } catch (_) {}
      if (latitud == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(textos.mapaGpsNoDisponible)));
      }
    }

    if (!mounted) return;
    final creado = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NuevoPunto(
        fincas: _fincas,
        fincaIdInicial: fincaId,
        latitudInicial: latitud,
        longitudInicial: longitud,
      ),
    ));
    if (creado == true) await _cargar();
  }

  /// Alta de un punto en las coordenadas tocadas en el mapa, con la finca
  /// más cercana ya preseleccionada (editable en el formulario).
  Future<void> _anadirEnPunto(LatLng punto) async {
    if (_fincas.isEmpty) return;
    final fincaId = _fincaMasCercana(punto) ?? _fincas.first.id;
    final creado = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NuevoPunto(
        fincas: _fincas,
        fincaIdInicial: fincaId,
        latitudInicial: punto.latitude,
        longitudInicial: punto.longitude,
      ),
    ));
    if (creado == true && mounted) await _cargar();
  }

  /// Fija la nueva posición de un punto existente (modo recolocar).
  Future<void> _moverPunto(int puntoId, LatLng punto) async {
    await _bd.actualizarPuntoCoords(puntoId, punto.latitude, punto.longitude);
    if (!mounted) return;
    setState(() => _recolocandoId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).puntoRecolocado)),
    );
    await _cargar();
  }

  // ─── Dibujo de zonas ──────────────────────────────────

  /// Entra en modo dibujo. [zonaId] no nulo = se rehace el trazado de una
  /// zona que ya existe en lugar de crear una nueva.
  void _empezarDibujo({int? zonaId}) {
    setState(() {
      _dibujando = true;
      _redibujandoZonaId = zonaId;
      _trazado = const [];
      _recolocandoId = null;
    });
  }

  void _cancelarDibujo() {
    setState(() {
      _dibujando = false;
      _redibujandoZonaId = null;
      _trazado = const [];
    });
  }

  void _marcarEsquina(LatLng esquina) {
    setState(() => _trazado = [..._trazado, esquina]);
  }

  void _deshacerEsquina() {
    if (_trazado.isEmpty) return;
    setState(() => _trazado = _trazado.sublist(0, _trazado.length - 1));
  }

  /// Cierra el trazado: guarda el nuevo recorrido de la zona que se estaba
  /// rehaciendo, o abre el formulario de alta para una zona nueva.
  Future<void> _cerrarTrazado() async {
    final textos = AppLocalizations.of(context);
    if (_trazado.length < 3) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.zonaTrazadoCorto)));
      return;
    }
    final trazado = _trazado;
    final zonaId = _redibujandoZonaId;
    _cancelarDibujo();

    if (zonaId != null) {
      await _bd.actualizarTrazadoZona(zonaId, trazado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.zonaTrazadoActualizado)));
      await _cargar();
      return;
    }

    if (_fincas.isEmpty) return;
    final centro = centroide(trazado);
    final fincaId = (centro == null ? null : _fincaMasCercana(centro)) ??
        _fincas.first.id;
    final creada = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NuevaZona(
        fincas: _fincas,
        vertices: trazado,
        fincaIdInicial: fincaId,
      ),
    ));
    if (creada == true && mounted) await _cargar();
  }

  /// Zona que contiene el punto tocado, si hay alguna. Con zonas solapadas
  /// gana la más pequeña: es la que el dedo quería señalar (una parcela
  /// dentro de un cercado grande, por ejemplo).
  ZonaFinca? _zonaEn(LatLng punto) {
    ZonaFinca? encontrada;
    for (final zona in _zonas) {
      if (!zona.contiene(punto)) continue;
      if (encontrada == null ||
          zona.superficieHaCalculada < encontrada.superficieHaCalculada) {
        encontrada = zona;
      }
    }
    return encontrada;
  }

  Future<void> _abrirZona(ZonaFinca zona) async {
    final res = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(builder: (_) => FichaZona(zona: zona)),
    );
    if (!mounted) return;
    if (res == 'redibujar') {
      _empezarDibujo(zonaId: zona.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).dibujoTocaVertices),
      ));
    } else if (res == true) {
      await _cargar();
    }
  }

  /// Qué hace un toque en el mapa, según el modo activo.
  void _alTocarMapa(LatLng punto) {
    if (_dibujando) {
      _marcarEsquina(punto);
      return;
    }
    if (_recolocandoId != null) {
      _moverPunto(_recolocandoId!, punto);
      return;
    }
    final zona = _zonaEn(punto);
    if (zona != null) {
      _abrirZona(zona);
      return;
    }
    _anadirEnPunto(punto);
  }

  /// Polígonos de las zonas guardadas más el trazado en curso.
  List<Polygon> _poligonos() => [
        for (final zona in _zonas)
          Polygon(
            points: zona.vertices,
            color: colorEstadoZona(zona.estado).withValues(alpha: 0.18),
            borderColor: colorEstadoZona(zona.estado),
            borderStrokeWidth: 2,
          ),
        if (_trazado.length >= 2)
          Polygon(
            points: _trazado,
            color: colorSenalZunbeltz.withValues(alpha: 0.12),
            borderColor: colorSenalZunbeltz,
            borderStrokeWidth: 2,
          ),
      ];

  /// Etiquetas de las zonas (nombre y superficie) y puntitos de las
  /// esquinas del trazado en curso. Van fuera del clustering: agrupar una
  /// etiqueta de parcela con un abrevadero no tendría sentido.
  List<Marker> _marcadoresDeZonas(String idioma) {
    final marcadores = <Marker>[];
    for (final zona in _zonas) {
      final centro = zona.centro;
      if (centro == null) continue;
      final nombre = zona.nombre.isEmpty
          ? (buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo)
          : zona.nombre;
      marcadores.add(Marker(
        point: centro,
        width: 130,
        height: 34,
        child: IgnorePointer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nombre,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorMonteZunbeltz,
                ),
              ),
              Text(
                '${zona.superficieHa.toStringAsFixed(2)} ha',
                style: const TextStyle(fontSize: 10, color: colorMonteZunbeltz),
              ),
            ],
          ),
        ),
      ));
    }
    for (final esquina in _trazado) {
      marcadores.add(Marker(
        point: esquina,
        width: 14,
        height: 14,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: colorSenalZunbeltz,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ));
    }
    return marcadores;
  }

  /// Id de la finca cuyo centroide está más cerca del punto tocado.
  int? _fincaMasCercana(LatLng p) {
    const distancia = Distance();
    int? mejor;
    var mejorMetros = double.infinity;
    for (final f in _fincas) {
      if (f.latitud == null || f.longitud == null) continue;
      final d =
          distancia.as(LengthUnit.Meter, p, LatLng(f.latitud!, f.longitud!));
      if (d < mejorMetros) {
        mejorMetros = d;
        mejor = f.id;
      }
    }
    return mejor;
  }

  List<Marker> _marcadores() {
    return [
      if (_posicionGps != null)
        Marker(
          point: _posicionGps!,
          width: 28,
          height: 28,
          child: Container(
            decoration: BoxDecoration(
              color: colorEstadoEnCurso.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.circle, size: 10, color: colorEstadoEnCurso),
            ),
          ),
        ),
      for (final punto in _conCoords)
        Marker(
          point: LatLng(punto.latitud!, punto.longitud!),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () async {
              final res = await Navigator.of(context).push<Object?>(
                MaterialPageRoute(builder: (_) => FichaPunto(punto: punto)),
              );
              if (!mounted) return;
              if (res == 'recolocar') {
                setState(() => _recolocandoId = punto.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context).mapaTocaNuevaUbicacion),
                ));
              } else if (res == true) {
                await _cargar();
              }
            },
            child: Icon(Icons.location_on,
                size: 38, color: colorEstadoPunto(punto.estado)),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(title: Text(textos.navFincas)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.navFincas),
        actions: [
          IconButton(
            tooltip: textos.meteoTitulo,
            icon: const Icon(Icons.cloud_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PantallaMeteo()),
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TableroTareas()),
            ),
            icon: const Icon(Icons.checklist),
            label: Text(textos.mapaTablero),
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
              onTap: (_, punto) => _alTocarMapa(punto),
            ),
            children: [
              TileLayer(
                urlTemplate: _estiloMapa == _EstiloMapa.calle
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.coleccionnuevoser.solera_zunbeltz',
                maxZoom: 22,
                maxNativeZoom: 19,
              ),
              PolygonLayer(polygons: _poligonos()),
              MarkerLayer(markers: _marcadoresDeZonas(idioma)),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 42,
                  disableClusteringAtZoom: 20,
                  size: const Size(40, 40),
                  markers: _marcadores(),
                  builder: (context, markers) => Container(
                    decoration: const BoxDecoration(
                      color: colorMonteZunbeltz,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${markers.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_dibujando)
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: Material(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(radioZunbeltz)),
                  side: BorderSide(color: colorSenalZunbeltz),
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textos.dibujoTocaVertices,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(
                        textos.dibujoEnCurso(
                          textos.dibujoEsquinas(_trazado.length),
                          superficieHectareas(_trazado).toStringAsFixed(2),
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: colorSenalZunbeltz),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_conCoords.isEmpty)
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: Material(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(radioZunbeltz)),
                  side: BorderSide(color: colorLineaZunbeltz),
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(textos.mapaSinPuntos,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ),
          if (!_dibujando && (_conCoords.isNotEmpty || _recolocandoId != null))
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(radioZunbeltz)),
                    side: BorderSide(color: colorLineaZunbeltz),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            _recolocandoId != null
                                ? Icons.edit_location_alt_outlined
                                : Icons.touch_app_outlined,
                            size: 16),
                        const SizedBox(width: 6),
                        Text(
                            _recolocandoId != null
                                ? textos.mapaTocaNuevaUbicacion
                                : textos.mapaTocaParaAnadir,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: _dibujando
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelarDibujo,
                        icon: const Icon(Icons.close),
                        label: Text(textos.dibujoCancelar),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _trazado.isEmpty ? null : _deshacerEsquina,
                        icon: const Icon(Icons.undo),
                        label: Text(textos.dibujoDeshacer),
                      ),
                    ),
                  ],
                )
              : Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _estiloMapa = _estiloMapa == _EstiloMapa.calle
                        ? _EstiloMapa.satelite
                        : _EstiloMapa.calle;
                  }),
                  icon: Icon(_estiloMapa == _EstiloMapa.calle
                      ? Icons.layers_outlined
                      : Icons.map_outlined),
                  label: Text(_estiloMapa == _EstiloMapa.calle
                      ? textos.mapaCapas
                      : textos.mapaMapa),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _centrarEnGps,
                  icon: const Icon(Icons.my_location),
                  label: Text(textos.mapaGps),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _dibujando
          ? FloatingActionButton.extended(
              onPressed: _trazado.length < 3 ? null : _cerrarTrazado,
              backgroundColor: _trazado.length < 3
                  ? Theme.of(context).disabledColor
                  : null,
              icon: const Icon(Icons.check),
              label: Text(textos.dibujoCerrar),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fabZona',
                  onPressed: _fincas.isEmpty ? null : () => _empezarDibujo(),
                  icon: const Icon(Icons.draw_outlined),
                  label: Text(textos.zonaDibujar),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'fabPunto',
                  onPressed: _alAnadirPunto,
                  icon: const Icon(Icons.add_location_alt),
                  label: Text(textos.mapaNuevoPunto),
                ),
              ],
            ),
    );
  }
}
