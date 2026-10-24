import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/zona_finca.dart';
import '../utiles/estilos_tarea.dart';
import '../utiles/edicion_contorno.dart';
import '../utiles/geodesia.dart';
import '../utiles/permisos_gps.dart';
import '../servicios/mapa_sin_cobertura.dart';
import '../servicios/proveedor_teselas_cacheadas.dart';
import 'crear_zonas_importadas.dart';
import 'pantalla_mapa_sin_cobertura.dart';
import 'ficha_punto.dart';
import 'ficha_zona.dart';
import 'nueva_zona.dart';
import 'nuevo_punto.dart';
import 'pantalla_meteo.dart';
import 'tablero_tareas.dart';
import '../utiles/numeros.dart';
import 'widgets/liberar_al_cerrar.dart';

enum _EstiloMapa { calle, satelite }

/// Teselas guardadas en disco (ver `servicios/cache_teselas.dart`): sin
/// cobertura se ve lo ya visto y lo descargado. En web, null: el
/// `NetworkTileProvider` de siempre, con la caché del navegador.
final TileProvider? _proveedorOrtofoto = MapaSinCobertura.instancia == null
    ? null
    : ProveedorTeselasCacheadas(
        obtenedor: MapaSinCobertura.instancia!.obtenedor,
        capa: capaPnoa,
        capaRespaldo: capaEsri);
final TileProvider? _proveedorCallejero = MapaSinCobertura.instancia == null
    ? null
    : ProveedorTeselasCacheadas(
        obtenedor: MapaSinCobertura.instancia!.obtenedor, capa: capaOsm);

/// Halo blanco de los nombres de zona: se leen sobre cualquier fondo.
const List<Shadow> _haloEtiqueta = [
  Shadow(color: Colors.white, blurRadius: 3),
  Shadow(color: Colors.white, blurRadius: 6),
];

enum _OrigenAlta { gps, centroMapa }

/// Pestaña "Fincas": mapa de Zunbeltz y La Planilla con sus puntos de
/// infraestructura y sus zonas dibujadas. Tap en un punto → ficha con sus
/// tareas; tap dentro de una zona → ficha de la zona. FAB → nuevo punto
/// (GPS o centro del mapa) o dibujar zona. Acción → tablero de tareas.
///
/// El mapa tiene cuatro modos, y el toque significa una cosa distinta en
/// cada uno: en normal añade un punto (o abre la zona tocada), en
/// recolocar fija la nueva posición de un punto, en dibujo cada toque
/// marca una esquina de la zona en curso, y en ajuste lleva la esquina
/// elegida al sitio tocado.
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

  /// Cabezas de ganado que hay ahora en cada zona (por id).
  Map<int, int> _cabezasPorZona = const {};
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

  /// Contornos del catastro o de un fichero, a la espera de elegir cuál se
  /// crea (borde a trazos en el mapa).
  List<ContornoPropuesto> _propuestos = const [];
  bool _dibujando = false;
  // Zona cuyo trazado se está rehaciendo (null = zona nueva).
  int? _redibujandoZonaId;
  // Zona cuyo contorno se está ajustando esquina a esquina (en `_trazado`),
  // la esquina elegida para moverla y los contornos anteriores para
  // deshacer.
  int? _ajustandoZonaId;
  int? _esquinaElegida;
  List<List<LatLng>> _historialAjuste = const [];
  bool get _ajustando => _ajustandoZonaId != null;
  // Centro aproximado de la zona de Andía / Tierra Estella (Navarra).
  LatLng _centroActual = const LatLng(42.8226, -2.0315);
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
    var cabezasPorZona = <int, int>{};
    try {
      await _bd.sembrarEspacioRealSiVacia();
      fincas = await _bd.listarFincas();
      puntos = await _bd.listarPuntos();
      zonas = await _bd.listarZonas();
      cabezasPorZona = {
        for (final MapEntry(key: zonaId, value: lotes)
            in (await _bd.lotesPorZona()).entries)
          zonaId: lotes.fold(0, (suma, resumen) => suma + resumen.cabezas),
      };
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
      _cabezasPorZona = cabezasPorZona;
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(textos.mapaGpsNoDisponible)));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(textos.mapaGpsNoDisponible)));
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
      _estiloMapa = _EstiloMapa.satelite;
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

  void _cambiarEstiloMapa() => setState(() {
        _estiloMapa = _estiloMapa == _EstiloMapa.calle
            ? _EstiloMapa.satelite
            : _EstiloMapa.calle;
      });

  // ─── Ajuste del contorno de una zona ──────────────────

  void _empezarAjuste(ZonaFinca zona) {
    setState(() {
      _ajustandoZonaId = zona.id;
      // Los bordes se siguen sobre la foto aérea.
      _estiloMapa = _EstiloMapa.satelite;
      _trazado = zona.vertices;
      _esquinaElegida = null;
      _historialAjuste = const [];
      _recolocandoId = null;
    });
    _encuadrar(zona.vertices);
  }

  /// Centra y acerca el mapa a una zona, con margen para las asas.
  void _encuadrar(List<LatLng> vertices) {
    if (vertices.length < 2) return;
    try {
      _controlador.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(vertices),
        padding: const EdgeInsets.fromLTRB(48, 110, 48, 48),
        maxZoom: 19,
      ));
    } catch (_) {
      // Sin mapa montado todavía: se queda donde está.
    }
  }

  void _cancelarAjuste() {
    setState(() {
      _ajustandoZonaId = null;
      _trazado = const [];
      _esquinaElegida = null;
      _historialAjuste = const [];
    });
  }

  void _cambiarContorno(List<LatLng> nuevo) {
    if (identical(nuevo, _trazado)) return;
    setState(() {
      _historialAjuste = [..._historialAjuste, _trazado];
      _trazado = nuevo;
    });
  }

  void _deshacerAjuste() {
    if (_historialAjuste.isEmpty) return;
    setState(() {
      _trazado = _historialAjuste.last;
      _historialAjuste =
          _historialAjuste.sublist(0, _historialAjuste.length - 1);
      _esquinaElegida = null;
    });
  }

  void _quitarEsquinaElegida() {
    final elegida = _esquinaElegida;
    if (elegida == null) return;
    _cambiarContorno(quitarEsquina(_trazado, elegida));
    setState(() => _esquinaElegida = null);
  }

  void _anadirEsquinaEnLado(int lado) {
    _cambiarContorno(insertarEsquinaEnLado(_trazado, lado));
    setState(() =>
        _esquinaElegida = posicionEsquinaInsertada(_trazado.length, lado));
  }

  Future<void> _guardarAjuste() async {
    final zonaId = _ajustandoZonaId;
    if (zonaId == null || _trazado.length < esquinasMinimas) return;
    final contorno = _trazado;
    _cancelarAjuste();
    await _bd.actualizarTrazadoZona(zonaId, contorno);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).zonaTrazadoActualizado)));
    await _cargar();
  }

  /// Asas del ajuste: un círculo por esquina (tocar = elegirla) y un «+»
  /// en mitad de cada lado (tocar = añadir ahí una esquina).
  List<Marker> _asasDeAjuste() {
    final medios = puntosMedios(_trazado);
    return [
      for (var lado = 0; lado < medios.length; lado++)
        Marker(
          point: medios[lado],
          width: 22,
          height: 22,
          child: GestureDetector(
            onTap: () => _anadirEsquinaEnLado(lado),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(color: colorSenalZunbeltz),
              ),
              child: const Icon(Icons.add, size: 14, color: colorSenalZunbeltz),
            ),
          ),
        ),
      for (var indice = 0; indice < _trazado.length; indice++)
        Marker(
          point: _trazado[indice],
          width: 28,
          height: 28,
          child: GestureDetector(
            onTap: () => setState(() =>
                _esquinaElegida = _esquinaElegida == indice ? null : indice),
            child: Center(
              child: Container(
                width: _esquinaElegida == indice ? 24 : 14,
                height: _esquinaElegida == indice ? 24 : 14,
                decoration: BoxDecoration(
                  color: _esquinaElegida == indice
                      ? colorSenalZunbeltz
                      : colorMonteZunbeltz,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ),
    ];
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.zonaTrazadoActualizado)));
      await _cargar();
      return;
    }

    if (_fincas.isEmpty) return;
    final centro = centroide(trazado);
    final fincaId =
        (centro == null ? null : _fincaMasCercana(centro)) ?? _fincas.first.id;
    final creada = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NuevaZona(
        fincas: _fincas,
        vertices: trazado,
        fincaIdInicial: fincaId,
      ),
    ));
    if (creada == true && mounted) await _cargar();
  }

  /// Lleva el mapa a un lugar buscado por nombre.
  Future<void> _buscarLugar() async {
    final posicion = await buscarLugarEnMapa(context);
    if (posicion == null || !mounted) return;
    try {
      _controlador.move(posicion, 16);
    } catch (_) {}
  }

  /// Crea zonas a partir de contornos propuestos: se pintan a trazos y se
  /// elige uno tras otro hasta cerrar la hoja.
  Future<void> _crearZonasDesde(
      Future<List<ContornoPropuesto>> Function() obtener) async {
    if (_fincas.isEmpty) return;
    final contornos = await obtener();
    if (!mounted || contornos.isEmpty) return;
    setState(() => _propuestos = contornos);
    _encuadrar([for (final c in contornos) ...c.vertices]);
    try {
      while (_propuestos.isNotEmpty) {
        if (!mounted) break;
        final elegido = _propuestos.length == 1
            ? _propuestos.single
            : await elegirContorno(context, _propuestos);
        if (elegido == null || !mounted) break;
        final centro = centroide(elegido.vertices);
        final creada = await Navigator.of(context).push<bool>(MaterialPageRoute(
          builder: (_) => NuevaZona(
            fincas: _fincas,
            vertices: elegido.vertices,
            fincaIdInicial:
                (centro == null ? null : _fincaMasCercana(centro)) ??
                    _fincas.first.id,
            nombreInicial: elegido.nombre,
            notasIniciales: elegido.notas,
          ),
        ));
        if (!mounted) return;
        if (creada != true) {
          if (_propuestos.length == 1) break;
          continue;
        }
        setState(() => _propuestos =
            _propuestos.where((c) => !identical(c, elegido)).toList());
        await _cargar();
      }
    } finally {
      if (mounted) setState(() => _propuestos = const []);
    }
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
      _encuadrar(zona.vertices);
    }
    if (res == 'editar_datos') {
      final editada = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              NuevaZona(fincas: _fincas, vertices: zona.vertices, zona: zona),
        ),
      );
      if (editada == true && mounted) await _cargar();
    } else if (res == 'ajustar') {
      _empezarAjuste(zona);
    } else if (res == 'redibujar') {
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
    if (_ajustando) {
      final elegida = _esquinaElegida;
      if (elegida != null) {
        _cambiarContorno(moverEsquina(_trazado, elegida, punto));
        setState(() => _esquinaElegida = null);
      }
      return;
    }
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
    // Igual que el botón de añadir: solo si el rol lo permite.
    if (politicaEspacioActual.puedeAnadirPuntos) _anadirEnPunto(punto);
  }

  /// Polígonos de las zonas guardadas más el trazado en curso.
  /// Mientras se ajusta o se dibuja una zona, el resto se apaga y la que
  /// se edita destaca (halo blanco y borde de señal), para no perderla.
  bool get _editandoContorno => _ajustando || _dibujando;

  List<Polygon> _poligonos() => [
        for (final zona in _zonas)
          if (zona.id == _ajustandoZonaId)
            ...const <Polygon>[]
          else if (zona.id == _redibujandoZonaId && _dibujando)
            // El contorno que se está rehaciendo, de referencia.
            Polygon(
              points: zona.vertices,
              borderColor: Colors.white,
              borderStrokeWidth: 2.5,
              pattern: StrokePattern.dashed(segments: const [10, 8]),
            )
          else if (_editandoContorno)
            Polygon(
              points: zona.vertices,
              color: colorDeZona(zona).withValues(alpha: 0.06),
              borderColor: colorDeZona(zona).withValues(alpha: 0.45),
              borderStrokeWidth: 1.5,
            )
          else ...[
            // Cada zona va dos veces: un filo oscuro ancho debajo y su color
            // encima, para que el borde se lea sobre el verde y sobre la foto.
            Polygon(
              points: zona.vertices,
              borderColor: Colors.black.withValues(alpha: 0.55),
              borderStrokeWidth: 6,
              pattern: patronEstadoZona(zona.estado),
            ),
            Polygon(
              points: zona.vertices,
              // El blanco relleno tapa la foto: casi transparente.
              color: colorDeZona(zona).withValues(
                  alpha:
                      colorDeZona(zona) == paletaZonas['blanco'] ? 0.05 : 0.22),
              borderColor: colorDeZona(zona),
              borderStrokeWidth: 3.5,
              pattern: patronEstadoZona(zona.estado),
            ),
          ],
        for (final contorno in _propuestos)
          Polygon(
            points: contorno.vertices,
            color: colorSenalZunbeltz.withValues(alpha: 0.12),
            borderColor: colorSenalZunbeltz,
            borderStrokeWidth: 3,
            pattern: StrokePattern.dashed(segments: const [12, 8]),
          ),
        if (_trazado.length >= 2) ...[
          Polygon(
            points: _trazado,
            borderColor: Colors.white.withValues(alpha: 0.9),
            borderStrokeWidth: 9,
          ),
          Polygon(
            points: _trazado,
            color: colorSenalZunbeltz.withValues(alpha: 0.28),
            borderColor: colorSenalZunbeltz,
            borderStrokeWidth: 4,
          ),
        ],
      ];

  /// Etiquetas de las zonas (nombre y superficie) y puntitos de las
  /// esquinas del trazado en curso. Van fuera del clustering: agrupar una
  /// etiqueta de parcela con un abrevadero no tendría sentido.
  List<Marker> _marcadoresDeZonas(String idioma) {
    final marcadores = <Marker>[];
    for (final zona in _editandoContorno ? const <ZonaFinca>[] : _zonas) {
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
                  shadows: _haloEtiqueta,
                ),
              ),
              Text(
                [
                  '${zona.superficieHa.toStringAsFixed(2)} ha',
                  if ((_cabezasPorZona[zona.id] ?? 0) > 0)
                    AppLocalizations.of(context)
                        .ganCabezas(_cabezasPorZona[zona.id]!),
                ].join(' · '),
                style: const TextStyle(
                    fontSize: 10,
                    color: colorMonteZunbeltz,
                    shadows: _haloEtiqueta),
              ),
            ],
          ),
        ),
      ));
    }
    for (final esquina in _ajustando ? const <LatLng>[] : _trazado) {
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
          // La punta de la chincheta, no su centro, es la que marca el sitio.
          alignment: Alignment.topCenter,
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
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Icon(Icons.location_on,
                  size: 38, color: colorEstadoPunto(punto.estado)),
            ),
          ),
        ),
    ];
  }

  /// Alta de una finca en el centro del mapa (p. ej. la de Zufía). Solo
  /// coordinación; los recintos y puntos se añaden después sobre el mapa.
  Future<void> _nuevaFinca() async {
    final textos = AppLocalizations.of(context);
    final controladorNombre = TextEditingController();
    final controladorSuperficie = TextEditingController();
    final confirmada = await showDialog<bool>(
      context: context,
      builder: (contexto) => LiberarAlCerrar(
        controladores: [controladorNombre, controladorSuperficie],
        child: AlertDialog(
          title: Text(textos.fincaNueva),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controladorNombre,
                autofocus: true,
                decoration: InputDecoration(labelText: textos.fincaNuevaNombre),
              ),
              TextField(
                controller: controladorSuperficie,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    InputDecoration(labelText: textos.fincaNuevaSuperficie),
              ),
              const SizedBox(height: 12),
              Text(textos.fincaNuevaCentro,
                  style: Theme.of(contexto).textTheme.bodySmall),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto, false),
                child: Text(textos.comunCancelar)),
            FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: Text(textos.comunGuardar)),
          ],
        ),
      ),
    );
    final nombre = controladorNombre.text.trim();
    if (confirmada != true || nombre.isEmpty) return;
    await _bd.guardarFinca(Finca(
      nombre: nombre,
      latitud: _centroActual.latitude,
      longitud: _centroActual.longitude,
      superficieHa: leerNumero(controladorSuperficie.text) ?? 0,
    ));
    avisarCambioDatos();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.fincaNuevaCreada(nombre))));
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
            tooltip: textos.mapaBuscar,
            icon: const Icon(Icons.search),
            onPressed: _buscarLugar,
          ),
          if (politicaEspacioActual.puedeEditarEspacio && _fincas.isNotEmpty)
            PopupMenuButton<int>(
              tooltip: textos.zonasDesde,
              icon: const Icon(Icons.layers_outlined),
              onSelected: (opcion) => switch (opcion) {
                0 => _crearZonasDesde(
                    () => parcelaCatastralEn(context, _centroActual)),
                1 => _crearZonasDesde(
                    () => parcelaCatastralPorReferencia(context)),
                _ => _crearZonasDesde(() => contornosDeFichero(context)),
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 0, child: Text(textos.zonaDesdeCatastroCentro)),
                PopupMenuItem(
                    value: 1, child: Text(textos.zonaDesdeCatastroRef)),
                PopupMenuItem(value: 2, child: Text(textos.zonaDesdeFichero)),
              ],
            ),
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
          if (politicaEspacioActual.puedeEditarEspacio)
            IconButton(
              tooltip: textos.fincaNueva,
              icon: const Icon(Icons.add_home_work_outlined),
              onPressed: _nuevaFinca,
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
              // Foto aérea: la ortofoto oficial del PNOA (IGN), la misma
              // sobre la que se encajaron los mapas de la finca; fuera de
              // España, o si el IGN no responde, la de Esri.
              TileLayer(
                urlTemplate: _estiloMapa == _EstiloMapa.calle
                    ? urlCallejeroOsm
                    : urlOrtofotoPnoa,
                fallbackUrl:
                    _estiloMapa == _EstiloMapa.calle ? null : urlOrtofotoEsri,
                tileProvider: _estiloMapa == _EstiloMapa.calle
                    ? _proveedorCallejero
                    : _proveedorOrtofoto,
                // Una tesela que no llegó (sin red y sin guardar) se vuelve
                // a pedir cuando sale de la vista, no se queda en blanco.
                evictErrorTileStrategy:
                    EvictErrorTileStrategy.notVisibleRespectMargin,
                userAgentPackageName: paqueteAgenteUsuario,
                maxZoom: 22,
                maxNativeZoom: 19,
              ),
              PolygonLayer(polygons: _poligonos()),
              MarkerLayer(markers: _marcadoresDeZonas(idioma)),
              if (_ajustando) MarkerLayer(markers: _asasDeAjuste()),
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
              Align(
                alignment: Alignment.bottomLeft,
                child: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    color: Colors.white.withValues(alpha: 0.7),
                    child: Text(
                      _estiloMapa == _EstiloMapa.calle
                          ? '© OpenStreetMap'
                          : 'PNOA © IGN · Esri',
                      style: const TextStyle(
                          fontSize: 10, color: colorMonteZunbeltz),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_dibujando || _ajustando)
            Positioned(
              right: 16,
              top: 96,
              child: FloatingActionButton.small(
                heroTag: 'capaEdicion',
                tooltip: _estiloMapa == _EstiloMapa.calle
                    ? textos.mapaCapas
                    : textos.mapaMapa,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: colorMonteZunbeltz,
                onPressed: _cambiarEstiloMapa,
                child: Icon(_estiloMapa == _EstiloMapa.calle
                    ? Icons.satellite_alt_outlined
                    : Icons.map_outlined),
              ),
            ),
          if (_dibujando || _ajustando)
            Positioned(
              left: 16,
              right: 16,
              top: 12,
              child: Material(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(radioZunbeltz)),
                  side: BorderSide(color: colorSenalZunbeltz),
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          !_ajustando
                              ? textos.dibujoTocaVertices
                              : _esquinaElegida == null
                                  ? textos.ajusteInstrucciones
                                  : textos.ajusteEsquinaElegida,
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
                  borderRadius:
                      BorderRadius.all(Radius.circular(radioZunbeltz)),
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
          if (!_dibujando &&
              !_ajustando &&
              (_conCoords.isNotEmpty || _recolocandoId != null))
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
                        Flexible(
                          child: Text(
                              _recolocandoId != null
                                  ? textos.mapaTocaNuevaUbicacion
                                  : textos.mapaTocaParaAnadir,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                        // Si no, el siguiente toque en el mapa, aunque sea
                        // horas después, movería el punto.
                        if (_recolocandoId != null)
                          TextButton(
                            onPressed: () =>
                                setState(() => _recolocandoId = null),
                            child: Text(textos.comunCancelar),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Progreso de «Descargar el mapa de las fincas», debajo de los
          // avisos de arriba (y de la capa de edición, si se edita).
          Positioned(
            left: 16,
            right: 16,
            top: (_dibujando || _ajustando) ? 144 : 52,
            child: const FranjaDescargaMapa(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: _ajustando
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelarAjuste,
                        icon: const Icon(Icons.close),
                        label: Text(textos.dibujoCancelar),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _historialAjuste.isEmpty ? null : _deshacerAjuste,
                        icon: const Icon(Icons.undo),
                        label: Text(textos.dibujoDeshacer),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _esquinaElegida != null &&
                                sePuedeQuitarEsquina(_trazado)
                            ? _quitarEsquinaElegida
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        label: Text(textos.ajusteQuitarEsquina),
                      ),
                    ),
                  ],
                )
              : _dibujando
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
                            onPressed:
                                _trazado.isEmpty ? null : _deshacerEsquina,
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
                            onPressed: _cambiarEstiloMapa,
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
                        // Mapa sin cobertura (no en web: allí manda la
                        // caché del navegador).
                        if (MapaSinCobertura.instancia != null) ...[
                          const SizedBox(width: 8),
                          PopupMenuButton<int>(
                            tooltip: textos.mapaSinCobertura,
                            icon: const Icon(Icons.cloud_download_outlined),
                            onSelected: (opcion) => opcion == 0
                                ? descargarMapaFincas(context)
                                : Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        const PantallaMapaSinCobertura())),
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                  value: 0,
                                  child: Text(textos.mapaDescargarFincas)),
                              PopupMenuItem(
                                  value: 1,
                                  child: Text(textos.mapaSinCobertura)),
                            ],
                          ),
                        ],
                      ],
                    ),
        ),
      ),
      floatingActionButton: _ajustando
          ? FloatingActionButton.extended(
              onPressed: _guardarAjuste,
              icon: const Icon(Icons.check),
              label: Text(textos.ajusteGuardar),
            )
          : _dibujando
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
                    if (politicaEspacioActual.puedeEditarEspacio) ...[
                      FloatingActionButton.extended(
                        heroTag: 'fabZona',
                        onPressed:
                            _fincas.isEmpty ? null : () => _empezarDibujo(),
                        icon: const Icon(Icons.draw_outlined),
                        label: Text(textos.zonaDibujar),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (politicaEspacioActual.puedeAnadirPuntos)
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
