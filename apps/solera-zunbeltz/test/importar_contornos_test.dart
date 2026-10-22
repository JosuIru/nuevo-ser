import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:solera_zunbeltz/utiles/geodesia.dart';
import 'package:solera_zunbeltz/utiles/importar_contornos.dart';

Uint8List _fichero(String nombre) =>
    File('test/fixtures/contornos/$nombre').readAsBytesSync();

void main() {
  // Parcela 24-2 de Yerri según IDENA: 229,36 ha y este vértice.
  const verticeCatastro = LatLng(42.80698135, -2.04095564);

  test('GeoJSON del catastro: la parcela y sus subparcelas, con su superficie', () {
    final leidos = leerContornos(
        'catastro-yerri-24-2.geojson', _fichero('catastro-yerri-24-2.geojson'));
    // La parcela entera y sus 26 subparcelas.
    expect(leidos.poligonos, hasLength(27));
    final poligono = leidos.poligonos.first;
    expect(poligono.vertices.first, verticeCatastro);
    expect(superficieHectareas(poligono.vertices), closeTo(229.36, 0.5));
    expect(leidos.supuestoUtm30, isFalse);
  });

  test('KML: polígonos y líneas cerradas; fuera huecos, caminos y puntos', () {
    final poligonos =
        leerContornos('piezas.kml', _fichero('piezas.kml')).poligonos;
    expect(
        poligonos.map((p) => p.nombre), ['Parque de cerdos', 'Cierre a mano']);
    expect(poligonos.first.vertices, hasLength(4),
        reason: 'sin repetir el primero y sin el hueco');
    expect(poligonos.first.vertices.first, const LatLng(42.82, -2.03));
  });

  test('KMZ: el KML de dentro del zip', () {
    final kml = _fichero('piezas.kml');
    final kmz = leerKmz(Uint8List.fromList(_zip('doc.kml', kml)));
    expect(kmz, hasLength(2));
  });

  test('GPX: el recorrido de un track se cierra como polígono', () {
    final poligono =
        leerContornos('vuelta.gpx', _fichero('vuelta.gpx')).poligonos.single;
    expect(poligono.nombre, 'Vuelta a la Planilla');
    expect(poligono.vertices, hasLength(4));
  });

  test('Shapefile en UTM 30N con .prj: se pasa a grados', () {
    final leidos =
        leerContornos('parcela-utm30.zip', _fichero('parcela-utm30.zip'));
    final poligono = leidos.poligonos.single;
    expect(poligono.nombre, 'Pieza grande');
    expect(leidos.supuestoUtm30, isFalse);
    final distancia = const Distance();
    final masCercano = poligono.vertices
        .map((v) => distancia(v, verticeCatastro))
        .reduce((a, b) => a < b ? a : b);
    expect(masCercano, lessThan(1.0), reason: 'menos de un metro');
    expect(superficieHectareas(poligono.vertices), closeTo(229.36, 0.5));
  });

  test('Shapefile sin .prj y en metros: se supone UTM 30N y se avisa', () {
    final leidos = leerContornos(
        'parcela-utm30-sin-prj.zip', _fichero('parcela-utm30-sin-prj.zip'));
    expect(leidos.supuestoUtm30, isTrue);
    expect(superficieHectareas(leidos.poligonos.single.vertices),
        closeTo(229.36, 0.5));
  });

  test('el .prj decide la proyección', () {
    expect(proyeccionDesdePrj('GEOGCS["WGS 84"]'), isNull);
    expect(proyeccionDesdePrj('PROJCS["ETRS89 / UTM zone 31N"]'),
        contains('+zone=31'));
    expect(
        proyeccionDesdePrj(
            'PROJCS["ED50_UTM_zone_30N",GEOGCS["European_1950"]]'),
        contains('+ellps=intl'));
  });

  test('un formato desconocido avisa', () {
    expect(() => leerContornos('mapa.dxf', Uint8List(0)),
        throwsA(isA<FormatoNoSoportado>()));
  });
}

List<int> _zip(String nombre, List<int> contenido) {
  // Zip mínimo con un fichero sin comprimir (método 0).
  final datos = contenido;
  final nombreBytes = nombre.codeUnits;
  final crc = _crc32(datos);
  final local = BytesBuilder()
    ..add(_u32(0x04034b50))
    ..add(_u16(20))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u32(crc))
    ..add(_u32(datos.length))
    ..add(_u32(datos.length))
    ..add(_u16(nombreBytes.length))
    ..add(_u16(0))
    ..add(nombreBytes)
    ..add(datos);
  final central = BytesBuilder()
    ..add(_u32(0x02014b50))
    ..add(_u16(20))
    ..add(_u16(20))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u32(crc))
    ..add(_u32(datos.length))
    ..add(_u32(datos.length))
    ..add(_u16(nombreBytes.length))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u32(0))
    ..add(_u32(0))
    ..add(nombreBytes);
  final fin = BytesBuilder()
    ..add(_u32(0x06054b50))
    ..add(_u16(0))
    ..add(_u16(0))
    ..add(_u16(1))
    ..add(_u16(1))
    ..add(_u32(central.length))
    ..add(_u32(local.length))
    ..add(_u16(0));
  return [...local.toBytes(), ...central.toBytes(), ...fin.toBytes()];
}

List<int> _u16(int v) => [v & 0xff, (v >> 8) & 0xff];
List<int> _u32(int v) =>
    [v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff];

int _crc32(List<int> datos) {
  var crc = 0xffffffff;
  for (final byte in datos) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return crc ^ 0xffffffff;
}
