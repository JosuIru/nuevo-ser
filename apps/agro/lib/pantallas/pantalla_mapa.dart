import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../estado/finca_activa.dart';
import '../estado/ultimo_centro_mapa.dart';
import '../modelos/finca.dart';
import '../modelos/planta.dart';
import '../servicios/grabador_track.dart';
import '../utiles/permisos_gps.dart';
import 'pantalla_ficha_planta.dart';
import 'pantalla_nueva_planta.dart';
import 'pantalla_nuevo_evento.dart';
import 'pantalla_tracks.dart';

enum _AccionMarcador { cosecha, observacion, incidencia, abrirFicha }

enum _EstiloMapa { calle, satelite }

enum _OrigenAltaMapa { gps, centroMapa }

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final _controlador = MapController();
  final _persistenciaFinca = FincaActivaPersistida();
  final _persistenciaUltimoCentro = UltimoCentroMapa();
  List<Finca> _fincas = [];
  List<Planta> _plantas = [];
  int? _fincaActivaId;
  bool _modoCenso = false;
  _EstiloMapa _estiloMapa = _EstiloMapa.calle;
  double? _altitudGps;
  LatLng? _posicionGps;
  final Set<String> _cultivosOcultos = {};
  LatLng _centroActual = LatLng(40.4, -3.7);
  double _zoomActual = 6;
  bool _centroResuelto = false;
  StreamSubscription<void>? _suscripcionGrabador;
  // Tick del track: cada GPS-fix del grabador antes disparaba setState
  // que reconstruía TODO el FlutterMap, lo que en algunos dispositivos
  // dejaba la PolylineLayer parpadeando o sin pintarse hasta que el
  // usuario tocaba el mapa (bug reportado en testeo 2026-05-15:
  // "mientras graba, la app NO dibuja el recorrido"). Ahora un
  // ValueNotifier que sólo agita la PolylineLayer dentro de un
  // ValueListenableBuilder.
  final ValueNotifier<int> _tickTrack = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _cargarTodo();
    _resolverCentroInicial();
    _suscripcionGrabador = GrabadorTrack.instancia.cambios.listen((_) {
      // Tick específico para la polyline. Usamos también setState
      // ligero para refrescar el icono del AppBar (rojo/parar) — pero
      // sin tocar la polyline directamente.
      _tickTrack.value++;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _suscripcionGrabador?.cancel();
    _tickTrack.dispose();
    super.dispose();
  }

  /// Centro inicial del mapa con cascada de prioridades:
  /// 1) Primera planta del filtro actual (cargada en _cargarTodo).
  /// 2) Centroide de la finca activa.
  /// 3) Último centro guardado en prefs (sesión anterior).
  /// 4) lastKnownPosition del sistema (instantáneo si lo hay).
  /// 5) getCurrentPosition (1-3 s, refina cuando llega).
  /// 6) Centro de Iberia como último fallback.
  ///
  /// Cada paso que devuelve algo útil llama a `_aplicarCentro` que
  /// mueve el mapa con el `MapController` ya construido. Esto evita
  /// reconstruir el FlutterMap (que perdería estado de panning si el
  /// usuario empezó a moverse por su cuenta).
  Future<void> _resolverCentroInicial() async {
    // Paso 3: último centro persistido — instantáneo desde prefs.
    final ultimo = await _persistenciaUltimoCentro.cargar();
    if (ultimo != null && !_centroResuelto && mounted) {
      _aplicarCentro(LatLng(ultimo.latitud, ultimo.longitud), ultimo.zoom);
    }
    // Paso 4: lastKnownPosition — instantáneo (cache del sistema).
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && !_centroResuelto && mounted) {
        _altitudGps = last.altitude;
        _posicionGps = LatLng(last.latitude, last.longitude);
        _aplicarCentro(LatLng(last.latitude, last.longitude), 16);
      }
    } catch (_) {}
    // Paso 5: getCurrentPosition — fix preciso (1-3s).
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido || !mounted) return;
    try {
      final pos = await Geolocator.getCurrentPosition().timeout(
        Duration(seconds: 8),
      );
      if (mounted) {
        _altitudGps = pos.altitude;
        _posicionGps = LatLng(pos.latitude, pos.longitude);
        _aplicarCentro(LatLng(pos.latitude, pos.longitude), 16);
        setState(() {});
      }
    } catch (_) {}
  }

  /// Aplica el centro y el zoom al mapa. La primera vez actualiza el
  /// estado para que `_centroInicial` y `_zoomInicial` respondan
  /// correctamente al primer build; las siguientes mueven el mapa
  /// directamente con `_controlador.move`.
  void _aplicarCentro(LatLng centro, double zoom) {
    _centroActual = centro;
    _zoomActual = zoom;
    if (!_centroResuelto) {
      // Aún no se ha construido el FlutterMap o estamos en la primera
      // resolución — un setState basta porque el initialCenter en
      // MapOptions toma este valor.
      setState(() => _centroResuelto = true);
    } else {
      // FlutterMap ya inicializado: mover sin reconstruir.
      try {
        _controlador.move(centro, zoom);
      } catch (_) {}
    }
    _persistenciaUltimoCentro.guardar(
      latitud: centro.latitude,
      longitud: centro.longitude,
      zoom: zoom,
    );
  }

  Future<void> _cargarTodo() async {
    final fincas = await BaseDatosAgro.instancia.listarFincas();
    final fincaActivaId = await _persistenciaFinca.cargar();
    final plantas = await BaseDatosAgro.instancia.listarPlantas(
      fincaId: fincaActivaId,
    );
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _plantas = plantas;
      _fincaActivaId = fincaActivaId;
    });
  }

  Future<void> _cambiarFincaActiva(int? nuevaId) async {
    await _persistenciaFinca.guardar(nuevaId);
    final plantas = await BaseDatosAgro.instancia.listarPlantas(
      fincaId: nuevaId,
    );
    if (!mounted) return;
    setState(() {
      _fincaActivaId = nuevaId;
      _plantas = plantas;
    });
  }

  Future<void> _alAbrirNuevaPlanta({double? latitud, double? longitud}) async {
    final creada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevaPlanta(
          fincaIdInicial: _fincaActivaId,
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
            ListTile(
              leading: Icon(Icons.add_location),
              title: Text('Añadir planta'),
              subtitle: Text('Elige cómo fijar el punto inicial.'),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.gps_fixed),
              title: Text('Usar GPS actual'),
              subtitle: Text(
                _posicionGps == null
                    ? 'Captura una posición nueva del dispositivo.'
                    : 'Último GPS: ${_posicionGps!.latitude.toStringAsFixed(6)}, ${_posicionGps!.longitude.toStringAsFixed(6)}',
              ),
              onTap: () => Navigator.pop(context, _OrigenAltaMapa.gps),
            ),
            ListTile(
              leading: Icon(Icons.center_focus_strong),
              title: Text('Usar centro del mapa'),
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
      await _alAbrirNuevaPlanta(
        latitud: _centroActual.latitude,
        longitud: _centroActual.longitude,
      );
      return;
    }

    final permitido = await asegurarPermisoUbicacion();
    if (!permitido) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falta permiso de ubicación o GPS desactivado.'),
        ),
      );
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _altitudGps = pos.altitude;
        _posicionGps = LatLng(pos.latitude, pos.longitude);
      });
    } else {
      _altitudGps = pos.altitude;
      _posicionGps = LatLng(pos.latitude, pos.longitude);
    }
    await _alAbrirNuevaPlanta(latitud: pos.latitude, longitud: pos.longitude);
  }

  /// Modo censo: cada vez que el usuario toca el mapa, crea una planta
  /// directamente en el punto pulsado (con coords del mapa, no del GPS).
  /// Útil cuando se camina la finca desde un sitio fijo y se van
  /// marcando árboles sin moverse físicamente. El alta es rápido —
  /// abre el formulario con cultivo prefijado al último usado.
  Future<void> _alPulsarMapa(LatLng punto) async {
    if (!_modoCenso) return;
    await _alAbrirNuevaPlanta(
      latitud: punto.latitude,
      longitud: punto.longitude,
    );
  }

  void _alternarVisibilidadCultivo(String cultivoId) {
    setState(() {
      if (_cultivosOcultos.contains(cultivoId)) {
        _cultivosOcultos.remove(cultivoId);
      } else {
        _cultivosOcultos.add(cultivoId);
      }
    });
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
          SnackBar(content: Text('Falta permiso de ubicación.')),
        );
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition().timeout(
        Duration(seconds: 8),
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
          SnackBar(content: Text('No se pudo obtener el GPS actual.')),
        );
      }
    }
  }

  List<Marker> _marcadoresVisibles() {
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
      for (final p in _plantas)
        if (!_cultivosOcultos.contains(p.cultivoId))
          Marker(
            point: LatLng(p.latitud, p.longitud),
            width: 36,
            height: 36,
            child: GestureDetector(
              onTap: () async {
                final cambio = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => PantallaFichaPlanta(plantaId: p.id!),
                  ),
                );
                if (cambio == true) _cargarTodo();
              },
              onLongPress: () => _mostrarMenuRapido(p),
              child: Container(
                decoration: BoxDecoration(
                  color: cultivoPorId(p.cultivoId).color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  cultivoPorId(p.cultivoId).icono,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
    ];
  }

  /// Menú rápido al mantener pulsado un marcador. Permite registrar
  /// un evento en pocos toques sin abrir la ficha completa, lo cual
  /// es importante en campo cuando se está caminando rápido entre
  /// plantas y se quiere apuntar algo concreto sin perder el ritmo.
  Future<void> _mostrarMenuRapido(Planta planta) async {
    final cultivo = cultivoPorId(planta.cultivoId);
    final accion = await showModalBottomSheet<_AccionMarcador>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: cultivo.color,
                child: Icon(cultivo.icono, color: Colors.white, size: 20),
              ),
              title: Text(
                planta.etiqueta.isNotEmpty
                    ? planta.etiqueta
                    : cultivo.nombreVisible,
              ),
              subtitle: Text(
                [
                  cultivo.nombreVisible,
                  if (planta.variedad.isNotEmpty) planta.variedad,
                ].join(' · '),
              ),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.shopping_basket,
                color: Color(0xFF689F38),
              ),
              title: Text('Cosecha rápida'),
              onTap: () => Navigator.pop(context, _AccionMarcador.cosecha),
            ),
            ListTile(
              leading: Icon(Icons.visibility, color: Color(0xFF1976D2)),
              title: Text('Observación rápida'),
              onTap: () => Navigator.pop(context, _AccionMarcador.observacion),
            ),
            ListTile(
              leading: Icon(
                Icons.warning_amber,
                color: Color(0xFFE65100),
              ),
              title: Text('Incidencia rápida'),
              onTap: () => Navigator.pop(context, _AccionMarcador.incidencia),
            ),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text('Abrir ficha completa'),
              onTap: () => Navigator.pop(context, _AccionMarcador.abrirFicha),
            ),
          ],
        ),
      ),
    );
    if (accion == null || !mounted) return;
    switch (accion) {
      case _AccionMarcador.cosecha:
        await _abrirEventoRapido(planta.id!, TipoEventoNuevo.cosecha);
        break;
      case _AccionMarcador.observacion:
        await _abrirEventoRapido(planta.id!, TipoEventoNuevo.observacion);
        break;
      case _AccionMarcador.incidencia:
        await _abrirEventoRapido(planta.id!, TipoEventoNuevo.incidencia);
        break;
      case _AccionMarcador.abrirFicha:
        if (!mounted) return;
        final cambio = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaFichaPlanta(plantaId: planta.id!),
          ),
        );
        if (cambio == true) _cargarTodo();
        break;
    }
  }

  Future<void> _abrirEventoRapido(int plantaId, TipoEventoNuevo tipo) async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoEvento(plantaId: plantaId, tipo: tipo),
      ),
    );
    if (creado == true && mounted) _cargarTodo();
  }

  Future<void> _alternarGrabacionTrack() async {
    final grabador = GrabadorTrack.instancia;
    if (grabador.grabando) {
      final controlador = TextEditingController();
      final guardar = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Detener recorrido'),
          content: TextField(
            controller: controlador,
            decoration: InputDecoration(labelText: 'Nombre (opcional)'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Descartar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(SoleraL10n.t('guardar')),
            ),
          ],
        ),
      );
      if (guardar == true) {
        final inicioMs = grabador.inicioMs;
        final r = grabador.detener(nombre: controlador.text.trim());
        if (r != null) {
          await BaseDatosAgro.instancia.guardarTrack(r.track, r.puntos);
          if (inicioMs != null) {
            await grabador.descartarBufferDeSesion(inicioMs);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Recorrido guardado (${r.puntos.length} puntos).',
                ),
              ),
            );
          }
        }
      } else {
        grabador.cancelar();
      }
    } else {
      final permitido = await asegurarPermisoUbicacion();
      if (!permitido) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falta permiso de ubicación.')),
          );
        }
        return;
      }
      await asegurarPermisoNotificaciones();
      grabador.iniciar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔴 Grabando recorrido. Puedes bloquear la pantalla, sigue activo.',
            ),
          ),
        );
      }
    }
  }

  /// Busca un paraje, pueblo o dirección y lleva el mapa allí. El nuevo
  /// centro se guarda solo, por `onPositionChanged`.
  Future<void> _buscarLugar() async {
    final lugarEncontrado = await buscarLugarEnMapa(
      context,
      identificacion: 'Larrea (agro)',
    );
    if (lugarEncontrado == null || !mounted) return;
    _controlador.move(lugarEncontrado, 15);
  }

  LatLng _centroInicial() {
    if (_plantas.isNotEmpty) {
      return LatLng(_plantas.first.latitud, _plantas.first.longitud);
    }
    final fincaActiva = _fincas
        .where((f) => f.id == _fincaActivaId)
        .firstOrNull;
    if (fincaActiva?.latitudCentroide != null &&
        fincaActiva?.longitudCentroide != null) {
      return LatLng(
        fincaActiva!.latitudCentroide!,
        fincaActiva.longitudCentroide!,
      );
    }
    // GPS resuelto / último centro / Iberia (cascada en _resolverCentroInicial).
    return _centroActual;
  }

  double _zoomInicial() {
    if (_plantas.isNotEmpty) return 17;
    return _zoomActual;
  }

  @override
  Widget build(BuildContext context) {
    final cultivosPresentes = <String>{for (final p in _plantas) p.cultivoId};
    return Scaffold(
      appBar: AppBar(
        title: _SelectorFincaActiva(
          fincas: _fincas,
          fincaActivaId: _fincaActivaId,
          alCambiar: _cambiarFincaActiva,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar un lugar',
            onPressed: _buscarLugar,
          ),
          IconButton(
            icon: Icon(
              GrabadorTrack.instancia.grabando
                  ? Icons.stop_circle
                  : Icons.fiber_manual_record,
            ),
            color: GrabadorTrack.instancia.grabando ? Colors.red : null,
            tooltip: GrabadorTrack.instancia.grabando
                ? 'Detener recorrido'
                : 'Grabar recorrido GPS',
            onPressed: _alternarGrabacionTrack,
          ),
          IconButton(
            icon: const Icon(Icons.route),
            tooltip: 'Recorridos guardados',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTracks()),
            ),
          ),
          IconButton(
            icon: Icon(
              _modoCenso
                  ? Icons.add_location_alt
                  : Icons.add_location_alt_outlined,
            ),
            color: _modoCenso ? Colors.amber : null,
            tooltip: _modoCenso
                ? 'Modo censo activo (toca el mapa para añadir)'
                : 'Activar modo censo',
            onPressed: () => setState(() => _modoCenso = !_modoCenso),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controlador,
            options: MapOptions(
              initialCenter: _centroInicial(),
              initialZoom: _zoomInicial(),
              maxZoom: 22,
              minZoom: 4,
              onTap: (_, punto) => _alPulsarMapa(punto),
              // Long press en cualquier sitio del mapa: alta rápida de
              // planta con coords del punto pulsado, sin necesidad de
              // estar en modo censo (bug reportado en testeo
              // 2026-05-15: "Toque largo en mapa NO abre Nueva planta
              // con coordenadas predefinidas").
              onLongPress: (_, punto) => _alAbrirNuevaPlanta(
                latitud: punto.latitude,
                longitud: punto.longitude,
              ),
              onPositionChanged: (cam, _) {
                _centroActual = cam.center;
                _zoomActual = cam.zoom;
                // Persistimos el último centro/zoom para que la próxima
                // apertura arranque ahí. Throttle implícito porque
                // SharedPreferences agrupa escrituras.
                _persistenciaUltimoCentro.guardar(
                  latitud: cam.center.latitude,
                  longitud: cam.center.longitude,
                  zoom: cam.zoom,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _estiloMapa == _EstiloMapa.calle
                    ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                    : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.josu.agro',
                maxZoom: 22,
                maxNativeZoom: 19,
              ),
              ValueListenableBuilder<int>(
                valueListenable: _tickTrack,
                builder: (context, _, __) {
                  if (!GrabadorTrack.instancia.grabando ||
                      GrabadorTrack.instancia.puntos.length < 2) {
                    return const SizedBox.shrink();
                  }
                  return PolylineLayer(
                    polylines: [
                      Polyline(
                        points: GrabadorTrack.instancia.puntos
                            .map((p) => LatLng(p.latitud, p.longitud))
                            .toList(),
                        color: Colors.red,
                        strokeWidth: 4,
                      ),
                    ],
                  );
                },
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 42,
                  disableClusteringAtZoom: 21,
                  size: Size(40, 40),
                  markers: _marcadoresVisibles(),
                  builder: (context, marcadores) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${marcadores.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (cultivosPresentes.isNotEmpty)
            Positioned(
              left: 8,
              top: 8,
              child: _LeyendaCultivos(
                cultivosPresentes: cultivosPresentes,
                ocultos: _cultivosOcultos,
                alAlternar: _alternarVisibilidadCultivo,
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
                child: Padding(
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
          if (_modoCenso)
            Positioned(
              left: 8,
              right: 8,
              bottom: 80,
              child: Card(
                color: Colors.amber,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Modo censo: toca el mapa para añadir una planta en ese punto.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _centrarEnGps,
                      icon: Icon(Icons.my_location),
                      label: Text('GPS'),
                    ),
                  ),
                  SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
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
        icon: Icon(Icons.add_location),
        label: Text('Añadir aquí'),
      ),
    );
  }
}

class _SelectorFincaActiva extends StatelessWidget {
  final List<Finca> fincas;
  final int? fincaActivaId;
  final ValueChanged<int?> alCambiar;

  _SelectorFincaActiva({
    required this.fincas,
    required this.fincaActivaId,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<int?>(
        value: fincaActivaId,
        hint: Text('Todas las fincas'),
        isDense: true,
        onChanged: alCambiar,
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Todas las fincas'),
          ),
          for (final finca in fincas)
            DropdownMenuItem<int?>(value: finca.id, child: Text(finca.nombre)),
        ],
      ),
    );
  }
}

class _LeyendaCultivos extends StatelessWidget {
  final Set<String> cultivosPresentes;
  final Set<String> ocultos;
  final ValueChanged<String> alAlternar;

  _LeyendaCultivos({
    required this.cultivosPresentes,
    required this.ocultos,
    required this.alAlternar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final id in cultivosPresentes)
              InkWell(
                onTap: () => alAlternar(id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: ocultos.contains(id)
                              ? Colors.grey.shade300
                              : cultivoPorId(id).color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        cultivoPorId(id).nombreVisible,
                        style: TextStyle(
                          fontSize: 12,
                          decoration: ocultos.contains(id)
                              ? TextDecoration.lineThrough
                              : null,
                          color: ocultos.contains(id) ? Colors.grey : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
