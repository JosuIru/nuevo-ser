/// Leer contornos de fincas y parcelas de ficheros: GeoJSON, KML y KMZ
/// (Google Earth), GPX (el recorrido de un GPS alrededor de la parcela) y
/// Shapefile en zip (QGIS, descargas de SIGPAC o del catastro), con su
/// reproyección a grados (WGS84) si vienen en UTM.
///
/// Solo se toma el anillo exterior de cada polígono (los huecos no caben en
/// una zona de la app). Puro: recibe bytes y devuelve polígonos.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:latlong2/latlong.dart';
import 'package:proj4dart/proj4dart.dart';
import 'package:xml/xml.dart';

/// Un polígono leído de un fichero, listo para crear una zona.
class PoligonoImportado {
  const PoligonoImportado({required this.nombre, required this.vertices});

  /// El nombre que trae (Placemark, propiedad «name»/«nombre», campo de la
  /// tabla del Shapefile) o '' si no trae.
  final String nombre;

  /// Anillo exterior, sin repetir el primer vértice al final.
  final List<LatLng> vertices;
}

/// Resultado de leer un fichero: los polígonos y, si hubo que suponer algo
/// (sistema de coordenadas sin .prj), un aviso para enseñar.
class ContornosLeidos {
  const ContornosLeidos(this.poligonos, {this.supuestoUtm30 = false});

  final List<PoligonoImportado> poligonos;

  /// El Shapefile no traía .prj y las coordenadas no eran grados: se han
  /// tomado como UTM 30N (ETRS89), lo habitual en Navarra.
  final bool supuestoUtm30;
}

class FormatoNoSoportado implements Exception {
  const FormatoNoSoportado(this.nombreFichero);
  final String nombreFichero;
  @override
  String toString() => 'Formato no soportado: $nombreFichero';
}

/// Lee un fichero según su extensión.
ContornosLeidos leerContornos(String nombreFichero, Uint8List bytes) {
  final nombre = nombreFichero.toLowerCase();
  if (nombre.endsWith('.geojson') || nombre.endsWith('.json')) {
    return ContornosLeidos(
        leerGeoJson(utf8.decode(bytes, allowMalformed: true)));
  }
  if (nombre.endsWith('.kml')) {
    return ContornosLeidos(leerKml(utf8.decode(bytes, allowMalformed: true)));
  }
  if (nombre.endsWith('.kmz')) return ContornosLeidos(leerKmz(bytes));
  if (nombre.endsWith('.gpx')) {
    return ContornosLeidos(leerGpx(utf8.decode(bytes, allowMalformed: true)));
  }
  if (nombre.endsWith('.zip')) return leerShapefileZip(bytes);
  throw FormatoNoSoportado(nombreFichero);
}

// ─── Utilidades ───

/// Quita el último vértice si repite el primero y descarta anillos de menos
/// de 3 vértices (devuelve null).
List<LatLng>? _anilloLimpio(List<LatLng> puntos) {
  final lista = [...puntos];
  if (lista.length > 1 &&
      lista.first.latitude == lista.last.latitude &&
      lista.first.longitude == lista.last.longitude) {
    lista.removeLast();
  }
  return lista.length < 3 ? null : lista;
}

/// Nombre de un polígono de varios: «Monte (2)».
String _conNumero(String nombre, int indice, int total) =>
    total <= 1 ? nombre : '${nombre.isEmpty ? '' : '$nombre '}(${indice + 1})';

// ─── GeoJSON ───

List<PoligonoImportado> leerGeoJson(String texto) {
  final raiz = jsonDecode(texto);
  final salida = <PoligonoImportado>[];

  String nombreDe(Object? propiedades) {
    if (propiedades is! Map) return '';
    for (final clave in [
      'nombre',
      'name',
      'Name',
      'NAME',
      'NOMBRE',
      'PARAJE'
    ]) {
      final valor = propiedades[clave];
      if (valor is String && valor.trim().isNotEmpty) return valor.trim();
    }
    return '';
  }

  List<LatLng> anillo(Object? coordenadas) => [
        for (final punto in (coordenadas as List? ?? const []))
          if (punto is List && punto.length >= 2)
            LatLng((punto[1] as num).toDouble(), (punto[0] as num).toDouble()),
      ];

  void geometria(Object? forma, String nombre) {
    if (forma is! Map) return;
    final tipo = forma['type'];
    final coordenadas = forma['coordinates'];
    final anillos = <List<LatLng>>[];
    if (tipo == 'Polygon' && coordenadas is List && coordenadas.isNotEmpty) {
      final limpio = _anilloLimpio(anillo(coordenadas.first));
      if (limpio != null) anillos.add(limpio);
    } else if (tipo == 'MultiPolygon' && coordenadas is List) {
      for (final poligono in coordenadas) {
        if (poligono is List && poligono.isNotEmpty) {
          final limpio = _anilloLimpio(anillo(poligono.first));
          if (limpio != null) anillos.add(limpio);
        }
      }
    } else if (tipo == 'GeometryCollection') {
      for (final parte in (forma['geometries'] as List? ?? const [])) {
        geometria(parte, nombre);
      }
    }
    for (var i = 0; i < anillos.length; i++) {
      salida.add(PoligonoImportado(
          nombre: _conNumero(nombre, i, anillos.length), vertices: anillos[i]));
    }
  }

  if (raiz is Map && raiz['type'] == 'FeatureCollection') {
    for (final rasgo in (raiz['features'] as List? ?? const [])) {
      if (rasgo is Map) {
        geometria(rasgo['geometry'], nombreDe(rasgo['properties']));
      }
    }
  } else if (raiz is Map && raiz['type'] == 'Feature') {
    geometria(raiz['geometry'], nombreDe(raiz['properties']));
  } else {
    geometria(raiz, '');
  }
  return salida;
}

// ─── KML / KMZ ───

List<LatLng> _coordenadasKml(String texto) => [
      for (final tupla in texto.trim().split(RegExp(r'\s+')))
        if (tupla.split(',').length >= 2)
          LatLng(double.parse(tupla.split(',')[1]),
              double.parse(tupla.split(',')[0])),
    ];

List<PoligonoImportado> leerKml(String texto) {
  final documento = XmlDocument.parse(texto);
  final salida = <PoligonoImportado>[];
  for (final marca in documento.findAllElements('Placemark')) {
    final nombre = marca.getElement('name')?.innerText.trim() ?? '';
    final anillos = <List<LatLng>>[];
    for (final poligono in marca.findAllElements('Polygon')) {
      final exterior = poligono
          .findAllElements('outerBoundaryIs')
          .expand((e) => e.findAllElements('coordinates'))
          .firstOrNull;
      if (exterior == null) continue;
      final limpio = _anilloLimpio(_coordenadasKml(exterior.innerText));
      if (limpio != null) anillos.add(limpio);
    }
    // Una línea cerrada dibujada en Google Earth también vale.
    if (anillos.isEmpty) {
      for (final linea in marca.findAllElements('LineString')) {
        final coordenadas = linea.getElement('coordinates');
        if (coordenadas == null) continue;
        final puntos = _coordenadasKml(coordenadas.innerText);
        if (puntos.length >= 4 && Distance()(puntos.first, puntos.last) < 30) {
          final limpio = _anilloLimpio(puntos);
          if (limpio != null) anillos.add(limpio);
        }
      }
    }
    for (var i = 0; i < anillos.length; i++) {
      salida.add(PoligonoImportado(
          nombre: _conNumero(nombre, i, anillos.length), vertices: anillos[i]));
    }
  }
  return salida;
}

List<PoligonoImportado> leerKmz(Uint8List bytes) {
  final zip = ZipDecoder().decodeBytes(bytes);
  final kml = zip.files
          .where((f) => f.isFile && f.name.toLowerCase() == 'doc.kml')
          .firstOrNull ??
      zip.files
          .where((f) => f.isFile && f.name.toLowerCase().endsWith('.kml'))
          .firstOrNull;
  if (kml == null) return const [];
  return leerKml(utf8.decode(kml.content as List<int>, allowMalformed: true));
}

// ─── GPX ───

/// Cada track (o ruta) que vuelve cerca de donde empezó es el contorno de
/// algo recorrido a pie: se cierra como polígono.
List<PoligonoImportado> leerGpx(String texto) {
  final documento = XmlDocument.parse(texto);
  final salida = <PoligonoImportado>[];
  LatLng? punto(XmlElement e) {
    final lat = double.tryParse(e.getAttribute('lat') ?? '');
    final lon = double.tryParse(e.getAttribute('lon') ?? '');
    return lat == null || lon == null ? null : LatLng(lat, lon);
  }

  void anadir(String nombre, Iterable<XmlElement> puntos) {
    final lista = puntos.map(punto).whereType<LatLng>().toList();
    final limpio = _anilloLimpio(lista);
    if (limpio != null) {
      salida.add(PoligonoImportado(nombre: nombre, vertices: limpio));
    }
  }

  for (final track in documento.findAllElements('trk')) {
    final nombre = track.getElement('name')?.innerText.trim() ?? '';
    final segmentos = track.findElements('trkseg').toList();
    for (var i = 0; i < segmentos.length; i++) {
      anadir(_conNumero(nombre, i, segmentos.length),
          segmentos[i].findElements('trkpt'));
    }
  }
  for (final ruta in documento.findAllElements('rte')) {
    anadir(ruta.getElement('name')?.innerText.trim() ?? '',
        ruta.findElements('rtept'));
  }
  return salida;
}

// ─── Shapefile (zip con .shp, .dbf y .prj) ───

/// Proyecciones que se reconocen en el .prj (WKT). Las de España: ETRS89 y
/// ED50 en UTM 29, 30 y 31, y grados.
const Map<String, String> _proyeccionesUtm = {
  'ETRS89_UTM29':
      '+proj=utm +zone=29 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs',
  'ETRS89_UTM30':
      '+proj=utm +zone=30 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs',
  'ETRS89_UTM31':
      '+proj=utm +zone=31 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs',
  'ED50_UTM29':
      '+proj=utm +zone=29 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs',
  'ED50_UTM30':
      '+proj=utm +zone=30 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs',
  'ED50_UTM31':
      '+proj=utm +zone=31 +ellps=intl +towgs84=-87,-98,-121,0,0,0,0 +units=m +no_defs',
};

/// La proyección de un .prj, o null si son grados. Sin reconocer, UTM 30N
/// ETRS89 (la de Navarra).
String? proyeccionDesdePrj(String wkt) {
  final texto = wkt.toUpperCase();
  if (!texto.startsWith('PROJCS')) return null; // GEOGCS: grados.
  final huso = RegExp(r'(?:UTM[ _]ZONE[ _]|UTM_ZONE_|/ UTM ZONE )(\d{2})')
          .firstMatch(texto)
          ?.group(1) ??
      RegExp(r'ZONE_(\d{2})N').firstMatch(texto)?.group(1) ??
      '30';
  final datum = texto.contains('ED50') || texto.contains('EUROPEAN_1950')
      ? 'ED50'
      : 'ETRS89';
  return _proyeccionesUtm['${datum}_UTM$huso'] ??
      _proyeccionesUtm['ETRS89_UTM30'];
}

LatLng Function(double x, double y) _conversorDesde(String? proyeccion) {
  if (proyeccion == null) return (x, y) => LatLng(y, x);
  final origen = Projection.parse(proyeccion);
  final destino = Projection.get('EPSG:4326')!;
  return (x, y) {
    final punto = origen.transform(destino, Point(x: x, y: y));
    return LatLng(punto.y, punto.x);
  };
}

ContornosLeidos leerShapefileZip(Uint8List bytes) {
  final zip = ZipDecoder().decodeBytes(bytes);
  ArchiveFile? buscar(String extension) => zip.files
      .where((f) => f.isFile && f.name.toLowerCase().endsWith(extension))
      .firstOrNull;
  final shp = buscar('.shp');
  if (shp == null) return const ContornosLeidos([]);
  final prj = buscar('.prj');
  final dbf = buscar('.dbf');
  return leerShapefile(
    Uint8List.fromList(shp.content as List<int>),
    prj: prj == null
        ? null
        : latin1.decode(prj.content as List<int>, allowInvalid: true),
    dbf: dbf == null ? null : Uint8List.fromList(dbf.content as List<int>),
  );
}

/// Lee los polígonos de un .shp (tipos 5, 15 y 25), con nombres del .dbf
/// si lo hay.
ContornosLeidos leerShapefile(Uint8List shp, {String? prj, Uint8List? dbf}) {
  final datos = ByteData.sublistView(shp);
  final nombres = dbf == null ? const <String>[] : _nombresDbf(dbf);
  final rings = <List<(double, double)>>[];
  final nombrePorRing = <String>[];

  var posicion = 100;
  var registro = 0;
  while (posicion + 8 <= datos.lengthInBytes) {
    final longitudPalabras = datos.getInt32(posicion + 4, Endian.big);
    final inicio = posicion + 8;
    final fin = inicio + longitudPalabras * 2;
    if (fin > datos.lengthInBytes) break;
    final tipo = datos.getInt32(inicio, Endian.little);
    if (tipo == 5 || tipo == 15 || tipo == 25) {
      final partes = datos.getInt32(inicio + 36, Endian.little);
      final puntos = datos.getInt32(inicio + 40, Endian.little);
      final indices = [
        for (var i = 0; i < partes; i++)
          datos.getInt32(inicio + 44 + i * 4, Endian.little)
      ];
      final base = inicio + 44 + partes * 4;
      final nombre = registro < nombres.length ? nombres[registro] : '';
      for (var p = 0; p < partes; p++) {
        final desde = indices[p];
        final hasta = p + 1 < partes ? indices[p + 1] : puntos;
        final anillo = [
          for (var i = desde; i < hasta; i++)
            (
              datos.getFloat64(base + i * 16, Endian.little),
              datos.getFloat64(base + i * 16 + 8, Endian.little)
            )
        ];
        // En Shapefile los anillos exteriores van en sentido horario; los
        // huecos, al revés: solo se toman los exteriores.
        if (_areaConSigno(anillo) <= 0) {
          rings.add(anillo);
          nombrePorRing.add(nombre);
        }
      }
    }
    registro++;
    posicion = fin;
  }

  final enGrados = rings.every((anillo) =>
      anillo.every((punto) => punto.$1.abs() <= 180 && punto.$2.abs() <= 90));
  final supuesto = prj == null && !enGrados;
  final proyeccion = prj != null
      ? proyeccionDesdePrj(prj)
      : (enGrados ? null : _proyeccionesUtm['ETRS89_UTM30']);
  final convertir = _conversorDesde(proyeccion);

  final poligonos = <PoligonoImportado>[];
  final cuentaPorNombre = <String, int>{};
  for (final nombre in nombrePorRing) {
    cuentaPorNombre[nombre] = (cuentaPorNombre[nombre] ?? 0) + 1;
  }
  final vistoPorNombre = <String, int>{};
  for (var i = 0; i < rings.length; i++) {
    final limpio =
        _anilloLimpio([for (final (x, y) in rings[i]) convertir(x, y)]);
    if (limpio == null) continue;
    final nombre = nombrePorRing[i];
    final indice = vistoPorNombre[nombre] = (vistoPorNombre[nombre] ?? -1) + 1;
    poligonos.add(PoligonoImportado(
        nombre: _conNumero(nombre, indice, cuentaPorNombre[nombre]!),
        vertices: limpio));
  }
  return ContornosLeidos(poligonos, supuestoUtm30: supuesto);
}

/// Área con signo (fórmula del lazo): negativa en sentido horario.
double _areaConSigno(List<(double, double)> anillo) {
  var suma = 0.0;
  for (var i = 0; i < anillo.length; i++) {
    final (x1, y1) = anillo[i];
    final (x2, y2) = anillo[(i + 1) % anillo.length];
    suma += x1 * y2 - x2 * y1;
  }
  return suma / 2;
}

/// El primer campo de texto de cada registro del .dbf que parezca un
/// nombre (NOMBRE, NAME, PARAJE…), o el primer campo de texto.
List<String> _nombresDbf(Uint8List dbf) {
  final datos = ByteData.sublistView(dbf);
  if (dbf.length < 32) return const [];
  final registros = datos.getUint32(4, Endian.little);
  final cabecera = datos.getUint16(8, Endian.little);
  final longitudRegistro = datos.getUint16(10, Endian.little);
  final campos = <(String, String, int, int)>[]; // nombre, tipo, desde, largo
  var desplazamiento = 1;
  for (var p = 32; p + 32 <= cabecera && dbf[p] != 0x0D; p += 32) {
    final nombre = latin1
        .decode(dbf.sublist(p, p + 11))
        .replaceAll('\u0000', '')
        .trim()
        .toUpperCase();
    final tipo = String.fromCharCode(dbf[p + 11]);
    final largo = dbf[p + 16];
    campos.add((nombre, tipo, desplazamiento, largo));
    desplazamiento += largo;
  }
  final texto = campos.where((c) => c.$2 == 'C').toList();
  if (texto.isEmpty) return const [];
  final preferido = texto.firstWhere(
      (c) => ['NOMBRE', 'NAME', 'PARAJE', 'NOM', 'DENOMINACI']
          .any(c.$1.startsWith),
      orElse: () => texto.first);
  return [
    for (var r = 0; r < registros; r++)
      () {
        final inicio = cabecera + r * longitudRegistro + preferido.$3;
        if (inicio + preferido.$4 > dbf.length) return '';
        final bruto = dbf.sublist(inicio, inicio + preferido.$4);
        try {
          return utf8.decode(bruto).trim();
        } catch (_) {
          return latin1.decode(bruto).trim();
        }
      }(),
  ];
}
