import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/ver_en_mapa.dart';
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
import 'widgets/hoja_pieza.dart';
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

enum _OrigenAlta { gps, centroMapa }

/// Por debajo de este zoom no se ponen los nombres de las piezas.
const double _zoomMinimoEtiquetas = 14.5;

/// La finca con la que se abre el mapa: la que tiene más piezas y puntos
/// (Zunbeltz frente a La Planilla).
Finca? _fincaPrincipal(List<Finca> fincas, List<ZonaFinca> zonas,
    List<PuntoInfraestructura> puntos) {
  Finca? mejor;
  var mejorCuenta = -1;
  for (final finca in fincas) {
    final cuenta = zonas.where((zona) => zona.fincaId == finca.id).length +
        puntos.where((punto) => punto.fincaId == finca.id).length;
    if (cuenta > mejorCuenta) {
      mejor = finca;
      mejorCuenta = cuenta;
    }
  }
  return mejor;
}

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

  /// Pieza tocada en el mapa: su hoja sustituye a la de la finca.
  ZonaFinca? _zonaElegida;

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

  /// Finca de la hoja de abajo (la elegida en el chip; al principio, la
  /// primera).
  int? _fincaVistaId;

  /// Filtros del mapa: piezas, puntos y solo los puntos por revisar.
  bool _verPiezas = true;
  bool _verPuntos = true;
  bool _soloPorRevisar = false;

  /// Tareas sin hacer, para el contador del botón de tareas.
  int _tareasAbiertas = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
    _resolverCentroInicial();
    notificadorDatos.addListener(_recargar);
    peticionVerEnMapa.addListener(_atenderVerEnMapa);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_recargar);
    peticionVerEnMapa.removeListener(_atenderVerEnMapa);
    super.dispose();
  }

  void _recargar() => _cargar();

  /// Llega del botón «Mapa» del tablero: elige la pieza o se centra en el
  /// punto. Si aún está cargando, se atiende al terminar la carga.
  void _atenderVerEnMapa() {
    final destino = peticionVerEnMapa.value;
    if (destino == null || _cargando || !mounted) return;
    peticionVerEnMapa.value = null;
    if (_dibujando || _ajustando) return;
    final zona = _zonas.where((z) => z.id == destino.zonaId).firstOrNull;
    if (zona != null) {
      setState(() => _verPiezas = true);
      _elegirZona(zona);
      return;
    }
    final punto = _conCoords.where((p) => p.id == destino.puntoId).firstOrNull;
    if (punto != null) {
      setState(() {
        _zonaElegida = null;
        _verPuntos = true;
        _soloPorRevisar = false;
      });
      try {
        _controlador.move(LatLng(punto.latitud!, punto.longitud!), 18);
      } catch (_) {
        // Sin mapa montado todavía.
      }
    }
  }

  Future<void> _cargar() async {
    var fincas = <Finca>[];
    var puntos = <PuntoInfraestructura>[];
    var zonas = <ZonaFinca>[];
    var cabezasPorZona = <int, int>{};
    var tareasAbiertas = 0;
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
      tareasAbiertas = (await _bd.listarTareas())
          .where((tarea) => tarea.estado != 'hecha')
          .length;
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
      final elegidaId = _zonaElegida?.id;
      _zonaElegida = elegidaId == null
          ? null
          : _zonas.where((zona) => zona.id == elegidaId).firstOrNull;
      _tareasAbiertas = tareasAbiertas;
      if (!fincas.any((finca) => finca.id == _fincaVistaId)) {
        _fincaVistaId = _fincaPrincipal(fincas, _zonas, _conCoords)?.id;
      }
      _cargando = false;
    });
    if (!_centroResuelto) {
      // Se abre sobre la finca principal; sin piezas ni puntos, en el
      // centro de todas las fincas.
      final referencia = <LatLng>[
        for (final zona in _zonas)
          if (zona.fincaId == _fincaVistaId && zona.centro != null)
            zona.centro!,
        for (final punto in _conCoords)
          if (punto.fincaId == _fincaVistaId)
            LatLng(punto.latitud!, punto.longitud!),
      ];
      if (referencia.isEmpty) {
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
        _aplicarCentro(LatLng(lat, lon), 15);
      }
    }
    // Una petición del tablero que llegó mientras cargaba: con el mapa ya
    // montado.
    if (peticionVerEnMapa.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _atenderVerEnMapa());
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
              child: Icon(Icons.add, size: 14, color: colorSenalZunbeltz),
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
    // Con las piezas ocultas, el toque no abre ninguna.
    if (!_verPiezas) return null;
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

  /// Elige una pieza: su hoja sale abajo y el mapa la encuadra por encima
  /// de la hoja.
  void _elegirZona(ZonaFinca zona) {
    setState(() => _zonaElegida = zona);
    if (zona.vertices.length < 2) return;
    try {
      _controlador.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(zona.vertices),
        padding: EdgeInsets.fromLTRB(
            56, MediaQuery.paddingOf(context).top + 80, 56, 470),
        maxZoom: 18,
      ));
    } catch (_) {
      // Sin mapa montado todavía: se queda donde está.
    }
  }

  void _soltarZona() => setState(() => _zonaElegida = null);

  /// La ficha completa de la pieza (fotos, notas, todas sus tareas).
  Future<void> _abrirZona(ZonaFinca zona) async {
    final res = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(builder: (_) => FichaZona(zona: zona)),
    );
    if (!mounted) return;
    if (res is String) {
      await _accionZona(zona, res);
    } else {
      await _cargar();
    }
  }

  /// Editar datos, ajustar el contorno o volver a dibujarlo: desde el lápiz
  /// de la hoja o desde la ficha completa.
  Future<void> _accionZona(ZonaFinca zona, String accion) async {
    if (accion == 'editar_datos') {
      final editada = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              NuevaZona(fincas: _fincas, vertices: zona.vertices, zona: zona),
        ),
      );
      if (editada == true && mounted) await _cargar();
    } else if (accion == 'ajustar') {
      _soltarZona();
      _encuadrar(zona.vertices);
      _empezarAjuste(zona);
    } else if (accion == 'redibujar') {
      _soltarZona();
      _encuadrar(zona.vertices);
      _empezarDibujo(zonaId: zona.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).dibujoTocaVertices),
      ));
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
      _elegirZona(zona);
      return;
    }
    // Con una pieza elegida, tocar fuera solo la suelta.
    if (_zonaElegida != null) {
      _soltarZona();
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
        for (final zona
            in (_verPiezas || _editandoContorno) ? _zonas : const <ZonaFinca>[])
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
          else if (zona.id != null && zona.id == _zonaElegida?.id) ...[
            // La pieza elegida: halo blanco y borde pino grueso.
            Polygon(
              points: zona.vertices,
              borderColor: Colors.white.withValues(alpha: 0.9),
              borderStrokeWidth: 10,
            ),
            Polygon(
              points: zona.vertices,
              color: colorDeZona(zona).withValues(alpha: 0.35),
              borderColor: colorMonteZunbeltz,
              borderStrokeWidth: 5,
            ),
          ] else ...[
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
    for (final zona
        in (_editandoContorno || !_verPiezas) ? const <ZonaFinca>[] : _zonas) {
      final centro = zona.centro;
      if (centro == null) continue;
      final nombre = zona.nombre.isEmpty
          ? (buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo)
          : zona.nombre;
      final cabezas = _cabezasPorZona[zona.id] ?? 0;
      final elegida = zona.id != null && zona.id == _zonaElegida?.id;
      marcadores.add(Marker(
        point: centro,
        width: 170,
        height: cabezas > 0 ? 48 : 32,
        child: IgnorePointer(
          // Con poco zoom los nombres se amontonan: solo de cerca.
          child: Builder(
            builder: (contextoMapa) => !elegida &&
                    MapCamera.of(contextoMapa).zoom < _zoomMinimoEtiquetas
                ? const SizedBox.shrink()
                : Center(
                    child: _EtiquetaPieza(
                      elegida: elegida,
                      nombre: nombre,
                      detalle: cabezas > 0
                          ? AppLocalizations.of(context).ganCabezas(cabezas)
                          : null,
                    ),
                  ),
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
            child: Center(
              child: Icon(Icons.circle, size: 10, color: colorEstadoEnCurso),
            ),
          ),
        ),
      for (final punto in _puntosVisibles)
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
            child: _MarcadorPunto(punto: punto),
          ),
        ),
    ];
  }

  bool _porRevisar(PuntoInfraestructura punto) =>
      punto.estado == 'revisar' || punto.estado == 'averiado';

  /// Los puntos que se ven con los filtros de arriba.
  List<PuntoInfraestructura> get _puntosVisibles {
    if (!_verPuntos) return const [];
    if (!_soloPorRevisar) return _conCoords;
    return _conCoords.where(_porRevisar).toList(growable: false);
  }

  Finca? get _fincaVista {
    for (final finca in _fincas) {
      if (finca.id == _fincaVistaId) return finca;
    }
    return _fincas.isEmpty ? null : _fincas.first;
  }

  Future<void> _elegirFincaVista() async {
    final textos = AppLocalizations.of(context);
    final elegida = await showModalBottomSheet<Finca>(
      useSafeArea: true,
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(textos.mapaElegirFincaVista)),
            for (final finca in _fincas)
              ListTile(
                leading: const Icon(Icons.home_work_outlined),
                title: Text(finca.nombre),
                selected: finca.id == _fincaVistaId,
                onTap: () => Navigator.pop(contexto, finca),
              ),
          ],
        ),
      ),
    );
    if (elegida != null && mounted) _verFinca(elegida);
  }

  /// Elige la finca de la hoja de abajo y lleva el mapa a ella.
  void _verFinca(Finca finca) {
    setState(() => _fincaVistaId = finca.id);
    final vertices = [
      for (final zona in _zonas)
        if (zona.fincaId == finca.id) ...zona.vertices,
      for (final punto in _conCoords)
        if (punto.fincaId == finca.id) LatLng(punto.latitud!, punto.longitud!),
    ];
    if (vertices.length >= 2) {
      _encuadrar(vertices);
    } else if (finca.latitud != null && finca.longitud != null) {
      _aplicarCentro(LatLng(finca.latitud!, finca.longitud!), 15);
    }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final editando = _dibujando || _ajustando;
    final arriba = MediaQuery.paddingOf(context).top;
    final politica = politicaEspacioActual;
    final porRevisar = _conCoords.where(_porRevisar).length;
    final finca = _fincaVista;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // El mapa es claro: iconos de la barra de estado en oscuro.
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: _zonaElegida == null,
        onPopInvokedWithResult: (hecho, _) {
          if (!hecho && _zonaElegida != null) _soltarZona();
        },
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
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
                      fallbackUrl: _estiloMapa == _EstiloMapa.calle
                          ? null
                          : urlOrtofotoEsri,
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
                          decoration: BoxDecoration(
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
              ),
              if (!editando && _zonaElegida != null)
                Positioned(
                  top: arriba + 8,
                  left: 16,
                  child: _BotonMapa(
                    icono: Icons.arrow_back,
                    tooltip: textos.piezaVolverAlMapa,
                    alPulsar: _soltarZona,
                    redondo: true,
                  ),
                ),
              if (!editando && _zonaElegida == null)
                Positioned(
                  top: arriba + 8,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _BarraBusquedaMapa(
                          tareasAbiertas: _tareasAbiertas,
                          alBuscar: _buscarLugar,
                          alVerTareas: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TableroTareas()),
                          ),
                          opciones: [
                            (
                              Icons.cloud_outlined,
                              textos.meteoTitulo,
                              () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const PantallaMeteo())),
                            ),
                            if (politica.puedeEditarEspacio) ...[
                              (
                                Icons.add_home_work_outlined,
                                textos.fincaNueva,
                                _nuevaFinca,
                              ),
                              if (_fincas.isNotEmpty) ...[
                                (
                                  Icons.layers_outlined,
                                  textos.zonaDesdeCatastroCentro,
                                  () => _crearZonasDesde(() =>
                                      parcelaCatastralEn(
                                          context, _centroActual)),
                                ),
                                (
                                  Icons.pin_outlined,
                                  textos.zonaDesdeCatastroRef,
                                  () => _crearZonasDesde(() =>
                                      parcelaCatastralPorReferencia(context)),
                                ),
                                (
                                  Icons.upload_file_outlined,
                                  textos.zonaDesdeFichero,
                                  () => _crearZonasDesde(
                                      () => contornosDeFichero(context)),
                                ),
                              ],
                            ],
                            // Mapa sin cobertura (no en web: allí manda la
                            // caché del navegador).
                            if (MapaSinCobertura.instancia != null) ...[
                              (
                                Icons.cloud_download_outlined,
                                textos.mapaDescargarFincas,
                                () => descargarMapaFincas(context),
                              ),
                              (
                                Icons.offline_pin_outlined,
                                textos.mapaSinCobertura,
                                () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PantallaMapaSinCobertura())),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (finca != null && _fincas.length > 1) ...[
                              ActionChip(
                                elevation: 1,
                                avatar: const Icon(Icons.home_work_outlined),
                                label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(finca.nombre),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 20),
                                    ]),
                                onPressed: _elegirFincaVista,
                              ),
                              const SizedBox(width: 8),
                            ],
                            FilterChip(
                              elevation: 1,
                              label: Text(textos.mapaFiltroPiezas),
                              selected: _verPiezas,
                              onSelected: (valor) =>
                                  setState(() => _verPiezas = valor),
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              elevation: 1,
                              label: Text(textos.mapaFiltroPuntos),
                              selected: _verPuntos,
                              onSelected: (valor) => setState(() {
                                _verPuntos = valor;
                                if (!valor) _soloPorRevisar = false;
                              }),
                            ),
                            if (porRevisar > 0) ...[
                              const SizedBox(width: 8),
                              FilterChip(
                                elevation: 1,
                                avatar: _soloPorRevisar
                                    ? null
                                    : Icon(Icons.error_outline,
                                        color:
                                            context.coloresZunbeltz.pendiente),
                                label:
                                    Text(textos.mapaFiltroRevisar(porRevisar)),
                                selected: _soloPorRevisar,
                                onSelected: (valor) => setState(() {
                                  _soloPorRevisar = valor;
                                  if (valor) _verPuntos = true;
                                }),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_recolocandoId != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: _AvisoSobreMapa(
                            icono: Icons.edit_location_alt_outlined,
                            texto: textos.mapaTocaNuevaUbicacion,
                            // Si no, el siguiente toque en el mapa, aunque sea
                            // horas después, movería el punto.
                            accion: TextButton(
                              onPressed: () =>
                                  setState(() => _recolocandoId = null),
                              child: Text(textos.comunCancelar),
                            ),
                          ),
                        )
                      else if (_conCoords.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: _AvisoSobreMapa(
                            icono: Icons.touch_app_outlined,
                            texto: textos.mapaSinPuntos,
                          ),
                        ),
                      // Progreso de «Descargar el mapa de las fincas».
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: FranjaDescargaMapa(),
                      ),
                    ],
                  ),
                ),
              if (_dibujando || _ajustando)
                Positioned(
                  right: 16,
                  top: arriba + 96,
                  child: FloatingActionButton.small(
                    heroTag: 'capaEdicion',
                    tooltip: _estiloMapa == _EstiloMapa.calle
                        ? textos.mapaCapas
                        : textos.mapaMapa,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: context.esquemaZunbeltz.primary,
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
                  top: arriba + 12,
                  child: Material(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(radioZunbeltz)),
                      side:
                          BorderSide(color: context.coloresZunbeltz.bloqueada),
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
                                ?.copyWith(
                                    color: context.coloresZunbeltz.bloqueada),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (editando)
                Positioned(
                  left: 16,
                  right: 16,
                  top: arriba + 144,
                  child: const FranjaDescargaMapa(),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 16, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _AtribucionMapa(
                              calle: _estiloMapa == _EstiloMapa.calle),
                          const Spacer(),
                          if (!editando) ...[
                            _BotonMapa(
                              icono: _estiloMapa == _EstiloMapa.calle
                                  ? Icons.layers_outlined
                                  : Icons.map_outlined,
                              tooltip: _estiloMapa == _EstiloMapa.calle
                                  ? textos.mapaCapas
                                  : textos.mapaMapa,
                              alPulsar: _cambiarEstiloMapa,
                            ),
                            const SizedBox(width: 12),
                            _BotonMapa(
                              icono: Icons.my_location,
                              tooltip: textos.mapaGps,
                              alPulsar: _centrarEnGps,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!editando && _zonaElegida != null)
                      HojaPieza(
                        key: ValueKey(_zonaElegida!.id),
                        zona: _zonaElegida!,
                        alCerrar: _soltarZona,
                        alVerFicha: () => _abrirZona(_zonaElegida!),
                        alAccion: (accion) =>
                            _accionZona(_zonaElegida!, accion),
                        alCambiarDatos: _cargar,
                      )
                    else if (!editando && finca != null)
                      _HojaFinca(
                        finca: finca,
                        piezas:
                            _zonas.where((z) => z.fincaId == finca.id).length,
                        puntos: _conCoords
                            .where((p) => p.fincaId == finca.id)
                            .length,
                        porRevisar: _conCoords
                            .where(
                                (p) => p.fincaId == finca.id && _porRevisar(p))
                            .length,
                        alNuevoPunto:
                            politica.puedeAnadirPuntos ? _alAnadirPunto : null,
                        alDibujarZona: politica.puedeEditarEspacio
                            ? () => _empezarDibujo()
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: !editando
              ? null
              : SafeArea(
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
                                    onPressed: _historialAjuste.isEmpty
                                        ? null
                                        : _deshacerAjuste,
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
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    label: Text(textos.ajusteQuitarEsquina),
                                  ),
                                ),
                              ],
                            )
                          : Row(
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
                                    onPressed: _trazado.isEmpty
                                        ? null
                                        : _deshacerEsquina,
                                    icon: const Icon(Icons.undo),
                                    label: Text(textos.dibujoDeshacer),
                                  ),
                                ),
                              ],
                            )),
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
                  : null,
        ),
      ),
    );
  }
}

/// Buscador flotante del mapa: logotipo, «Buscar en el mapa», tareas (con
/// cuántas hay abiertas) y el menú con el resto de opciones.
class _BarraBusquedaMapa extends StatelessWidget {
  const _BarraBusquedaMapa({
    required this.tareasAbiertas,
    required this.alBuscar,
    required this.alVerTareas,
    required this.opciones,
  });

  final int tareasAbiertas;
  final VoidCallback alBuscar;
  final VoidCallback alVerTareas;
  final List<(IconData, String, VoidCallback)> opciones;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final esquema = context.esquemaZunbeltz;
    return Material(
      color: esquema.surfaceContainerHigh,
      elevation: 3,
      shadowColor: Colors.black38,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: Row(children: [
        Expanded(
          child: InkWell(
            onTap: alBuscar,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(rutaLogoZunbeltz,
                      width: 34, height: 34, excludeFromSemantics: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(textos.mapaBuscarEnMapa,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: esquema.onSurfaceVariant)),
                ),
              ]),
            ),
          ),
        ),
        IconButton(
          tooltip: textos.mapaTablero,
          onPressed: alVerTareas,
          icon: Badge(
            isLabelVisible: tareasAbiertas > 0,
            backgroundColor: context.coloresZunbeltz.bloqueada,
            label: Text('$tareasAbiertas'),
            child: const Icon(Icons.checklist),
          ),
        ),
        PopupMenuButton<VoidCallback>(
          tooltip: textos.mapaMasOpciones,
          icon: const Icon(Icons.more_vert),
          onSelected: (accion) => accion(),
          itemBuilder: (_) => [
            for (final (icono, texto, accion) in opciones)
              PopupMenuItem(
                value: accion,
                child: Row(children: [
                  Icon(icono, size: 20, color: esquema.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Flexible(child: Text(texto)),
                ]),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ]),
    );
  }
}

/// Aviso corto sobre el mapa (debajo de los filtros).
class _AvisoSobreMapa extends StatelessWidget {
  const _AvisoSobreMapa(
      {required this.icono, required this.texto, this.accion});

  final IconData icono;
  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.esquemaZunbeltz.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 10, accion == null ? 14 : 4, 10),
        child: Row(children: [
          Icon(icono, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
          if (accion != null) accion!,
        ]),
      ),
    );
  }
}

/// Botón cuadrado sobre el mapa (capas, GPS).
class _BotonMapa extends StatelessWidget {
  const _BotonMapa(
      {required this.icono,
      required this.tooltip,
      required this.alPulsar,
      this.redondo = false});

  final IconData icono;
  final String tooltip;
  final VoidCallback alPulsar;
  final bool redondo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.esquemaZunbeltz.surfaceContainerHigh,
      elevation: 3,
      shadowColor: Colors.black38,
      shape: redondo
          ? const CircleBorder()
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radioTarjetaZunbeltz)),
      child: IconButton(
        tooltip: tooltip,
        onPressed: alPulsar,
        iconSize: 24,
        padding: const EdgeInsets.all(14),
        color: context.esquemaZunbeltz.onSurface,
        icon: Icon(icono),
      ),
    );
  }
}

/// Atribución de las teselas, abajo a la izquierda.
class _AtribucionMapa extends StatelessWidget {
  const _AtribucionMapa({required this.calle});
  final bool calle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(radioZunbeltz),
        ),
        child: Text(
          calle ? '© OpenStreetMap' : 'PNOA © IGN · Esri',
          style: const TextStyle(fontSize: 11, color: colorTintaZunbeltz),
        ),
      ),
    );
  }
}

/// Nombre de una pieza sobre el mapa, en una píldora clara (el mapa es
/// siempre claro: colores fijos).
class _EtiquetaPieza extends StatelessWidget {
  const _EtiquetaPieza(
      {required this.nombre, this.detalle, this.elegida = false});

  final String nombre;
  final String? detalle;

  /// La pieza elegida va en pino con letra blanca, como en la propuesta.
  final bool elegida;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            elegida ? colorMonteZunbeltz : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(radioZunbeltz),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: elegida ? Colors.white : colorTintaZunbeltz)),
        if (detalle != null)
          Text(detalle!,
              style: TextStyle(
                  fontSize: 11,
                  color: elegida
                      ? colorMusgoZunbeltz
                      : colorTintaApagadaZunbeltz)),
      ]),
    );
  }
}

/// Un punto de infraestructura en el mapa: círculo con el icono de su tipo,
/// en verde pino si está operativo, en marrón si hay que revisarlo y en
/// rojo si está averiado.
class _MarcadorPunto extends StatelessWidget {
  const _MarcadorPunto({required this.punto});
  final PuntoInfraestructura punto;

  @override
  Widget build(BuildContext context) {
    final color = switch (punto.estado) {
      'revisar' => colorEstadoPendiente,
      'averiado' => colorEstadoBloqueada,
      _ => colorMonteZunbeltz,
    };
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Icon(iconoTipoPunto(punto.tipo), size: 19, color: Colors.white),
      ),
    );
  }
}

/// Hoja de abajo del mapa: la finca que se ve, su superficie, cuántas
/// piezas y puntos tiene, y los botones de añadir.
class _HojaFinca extends StatelessWidget {
  const _HojaFinca({
    required this.finca,
    required this.piezas,
    required this.puntos,
    required this.porRevisar,
    required this.alNuevoPunto,
    required this.alDibujarZona,
  });

  final Finca finca;
  final int piezas;
  final int puntos;
  final int porRevisar;
  final VoidCallback? alNuevoPunto;
  final VoidCallback? alDibujarZona;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 12),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: esquema.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(finca.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: estilos.headlineSmall),
                ),
                if (finca.superficieHa > 0)
                  Text(
                      '${NumberFormat('#,##0.00', idioma).format(finca.superficieHa)} ha',
                      style: estilos.titleMedium),
              ]),
          const SizedBox(height: 2),
          Text(textos.fincaResumen(piezas, puntos, porRevisar),
              style: estilos.bodyMedium
                  ?.copyWith(color: esquema.onSurfaceVariant)),
          if (alNuevoPunto != null || alDibujarZona != null) ...[
            const SizedBox(height: 16),
            Row(children: [
              if (alNuevoPunto != null)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: alNuevoPunto,
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: Text(textos.mapaNuevoPunto),
                  ),
                ),
              if (alNuevoPunto != null && alDibujarZona != null)
                const SizedBox(width: 12),
              if (alDibujarZona != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: alDibujarZona,
                    icon: const Icon(Icons.draw_outlined),
                    label: Text(textos.zonaDibujar),
                  ),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}
