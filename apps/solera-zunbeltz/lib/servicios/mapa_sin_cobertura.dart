import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

import '../modelos/finca.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/zona_finca.dart';
import '../utiles/cola_descarga_teselas.dart';
import '../utiles/fotos_sincronizadas.dart' show redPermiteTransferirFotos;
import '../utiles/teselas_mapa.dart';
import 'cache_teselas.dart';

/// Capas del mapa de Fincas: de dónde salen y cómo se llama su carpeta en
/// la caché.
const String urlOrtofotoPnoa = 'https://www.ign.es/wmts/pnoa-ma?'
    'request=GetTile&service=WMTS&VERSION=1.0.0&Layer=OI.OrthoimageCoverage'
    '&Style=default&Format=image/jpeg&TileMatrixSet=GoogleMapsCompatible'
    '&TileMatrix={z}&TileRow={y}&TileCol={x}';
const String urlOrtofotoEsri = 'https://server.arcgisonline.com/ArcGIS/rest/'
    'services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
const String urlCallejeroOsm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

const String capaPnoa = 'pnoa';
const String capaEsri = 'esri';
const String capaOsm = 'osm';

const String paqueteAgenteUsuario = 'com.coleccionnuevoser.solera_zunbeltz';

/// La URL de una tesela a partir de una plantilla `{z}/{x}/{y}`.
String urlDeTesela(String plantilla, TeselaXYZ tesela) => plantilla
    .replaceAll('{z}', '${tesela.z}')
    .replaceAll('{x}', '${tesela.x}')
    .replaceAll('{y}', '${tesela.y}');

/// Lo dibujado en cada finca (esquinas de zonas, puntos), agrupado para
/// [rectangulosDeFincas].
List<FincaParaDescarga> fincasParaDescarga(List<Finca> fincas,
    List<ZonaFinca> zonas, List<PuntoInfraestructura> puntos) {
  return [
    for (final finca in fincas)
      FincaParaDescarga(
        nombre: finca.nombre,
        centro: finca.latitud == null || finca.longitud == null
            ? null
            : LatLng(finca.latitud!, finca.longitud!),
        superficieHa: finca.superficieHa,
        puntosDibujados: [
          for (final zona in zonas)
            if (zona.fincaId == finca.id) ...zona.vertices,
          for (final punto in puntos)
            if (punto.fincaId == finca.id &&
                punto.latitud != null &&
                punto.longitud != null)
              LatLng(punto.latitud!, punto.longitud!),
        ],
      ),
  ];
}

/// Qué se va a bajar: teselas pendientes (las que no están ya descargadas
/// y vigentes) y cuánto ocuparán.
class PlanDescargaMapa {
  const PlanDescargaMapa({
    required this.nombresFincas,
    required this.totalTeselas,
    required this.pendientes,
  });

  final List<String> nombresFincas;
  final int totalTeselas;
  final List<TeselaXYZ> pendientes;

  int get yaDescargadas => totalTeselas - pendientes.length;
  int get bytesEstimados => estimarBytesTeselas(pendientes.length);
  bool get nadaQueBajar => pendientes.isEmpty;
}

/// Lleva la descarga de la ortofoto de las fincas. Vive mientras viva la
/// app (no la pantalla del mapa): se puede salir del mapa y sigue. Si la app
/// se cierra, al volver a pedirla se salta lo que ya está bajado.
class GestorDescargaMapa extends ChangeNotifier {
  GestorDescargaMapa({
    required this.almacen,
    required this.obtenedor,
    required this.hayWifi,
    this.concurrencia = 4,
    this.cabeceras = const {},
    Future<void> Function(Duration espera)? dormir,
  }) : dormir = dormir ?? ((espera) => Future<void>.delayed(espera));

  final AlmacenTeselas almacen;
  final ObtenedorTeselas obtenedor;
  final Future<bool> Function() hayWifi;
  final int concurrencia;
  final Map<String, String> cabeceras;
  final Future<void> Function(Duration espera) dormir;

  ColaDescargaTeselas? _cola;
  ProgresoDescargaTeselas? _progreso;
  FinDescargaTeselas? _ultimoFin;

  bool get descargando => _cola != null;
  ProgresoDescargaTeselas? get progreso => _progreso;

  /// Cómo acabó la última descarga (null mientras no ha habido o tras
  /// [olvidarResultado]).
  FinDescargaTeselas? get ultimoFin => _ultimoFin;

  Future<PlanDescargaMapa> planificar(List<FincaParaDescarga> fincas) async {
    final rectangulos = rectangulosDeFincas(fincas);
    final teselas = teselasDeRectangulos(rectangulos);
    final pendientes = <TeselaXYZ>[];
    for (final tesela in teselas) {
      if (!await almacen.tieneDescargadaVigente(capaPnoa, tesela)) {
        pendientes.add(tesela);
      }
    }
    return PlanDescargaMapa(
      nombresFincas: [
        for (final finca in fincas)
          if (finca.centro != null || finca.puntosDibujados.isNotEmpty)
            finca.nombre,
      ],
      totalTeselas: teselas.length,
      pendientes: pendientes,
    );
  }

  /// Empieza a bajar [plan]. Devuelve cómo acabó (también queda en
  /// [ultimoFin]). Si ya hay una en marcha, devuelve null y no hace nada.
  Future<FinDescargaTeselas?> iniciar(PlanDescargaMapa plan) async {
    if (_cola != null) return null;
    final cola = ColaDescargaTeselas(
      teselas: plan.pendientes,
      concurrencia: concurrencia,
      dormir: dormir,
      puedeSeguir: hayWifi,
      descargar: (tesela) => obtenedor.bajarYGuardar(
          capaPnoa, tesela, urlDeTesela(urlOrtofotoPnoa, tesela),
          cabeceras: cabeceras),
      alProgresar: (progreso) {
        _progreso = progreso;
        notifyListeners();
      },
    );
    _cola = cola;
    _progreso = cola.progreso;
    _ultimoFin = null;
    notifyListeners();
    FinDescargaTeselas fin;
    try {
      fin = await cola.ejecutar();
    } catch (_) {
      fin = FinDescargaTeselas.demasiadosFallos;
    }
    _cola = null;
    _ultimoFin = fin;
    notifyListeners();
    return fin;
  }

  void cancelar() => _cola?.cancelar();

  void olvidarResultado() {
    if (_ultimoFin == null) return;
    _ultimoFin = null;
    _progreso = null;
    notifyListeners();
  }
}

/// Todo lo del mapa sin cobertura, uno para toda la app. En web no hay
/// (null): el mapa usa la caché del navegador y no se ofrece la descarga.
class MapaSinCobertura {
  MapaSinCobertura._() {
    final cliente = IOClient(HttpClient()
      ..connectionTimeout = const Duration(seconds: 6)
      ..maxConnectionsPerHost = 6);
    almacen = AlmacenTeselas(() async => Directory(path_lib.join(
        (await getApplicationSupportDirectory()).path, 'teselas_mapa')));
    obtenedor = ObtenedorTeselas(
      almacen: almacen,
      cliente: cliente,
      hayConexion: () async => (await _conexiones())
          .any((conexion) => conexion != ConnectivityResult.none),
    );
    descarga = GestorDescargaMapa(
      almacen: almacen,
      obtenedor: obtenedor,
      hayWifi: () async => redPermiteTransferirFotos(await _conexiones()),
      cabeceras: const {
        'User-Agent': 'flutter_map ($paqueteAgenteUsuario)',
      },
    );
    _suscripcion = Connectivity().onConnectivityChanged.listen((conexiones) {
      _conexiones.olvidar();
      if (conexiones.any((c) => c != ConnectivityResult.none)) {
        obtenedor.olvidarCortes();
      }
    }, onError: (_) {});
  }

  static MapaSinCobertura? _instancia;

  /// null en web.
  static MapaSinCobertura? get instancia =>
      kIsWeb ? null : (_instancia ??= MapaSinCobertura._());

  late final AlmacenTeselas almacen;
  late final ObtenedorTeselas obtenedor;
  late final GestorDescargaMapa descarga;
  // ignore: unused_field
  StreamSubscription<List<ConnectivityResult>>? _suscripcion;

  final RespuestaConVigencia<List<ConnectivityResult>> _conexiones =
      RespuestaConVigencia(() => Connectivity().checkConnectivity());

  /// ¿Hay wifi o cable ahora mismo? (para no empezar la descarga con datos
  /// móviles).
  Future<bool> hayWifi() async =>
      redPermiteTransferirFotos(await Connectivity().checkConnectivity());
}
