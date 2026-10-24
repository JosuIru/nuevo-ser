/// Cuentas de teselas del mapa (esquema XYZ de Google/OSM, el
/// «GoogleMapsCompatible» del WMTS del IGN): qué teselas cubren un
/// rectángulo, cuánto pesan y qué rectángulo cubre cada finca. Dart puro,
/// para poder probarlo sin Flutter.
library;

import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'geodesia.dart';

/// Zooms que se bajan con «Descargar el mapa de las fincas»: del 12 (se ve
/// el valle entero en una tesela) al 19 (el máximo nativo del PNOA, al que
/// el mapa amplía sin pedir más).
const int zoomMinimoDescarga = 12;
const int zoomMaximoDescarga = 19;

/// Margen alrededor de lo dibujado en cada finca, para poder moverse un
/// poco fuera del cierre sin caer en gris.
const double margenDescargaMetros = 400;

/// Peso medio de una tesela JPEG del PNOA en esta zona: medido el
/// 2026-10-24 sobre Zunbeltz con teselas de los zooms 12 a 19 (entre 9 y
/// 18 KB, media ~16 KB). Se redondea hacia arriba: mejor avisar de algo más
/// de lo que acaba ocupando.
const int bytesMedioTeselaPnoa = 17 * 1024;

/// Una tesela: zoom, columna (x) y fila (y, contando desde el norte).
class TeselaXYZ {
  const TeselaXYZ(this.z, this.x, this.y);

  final int z;
  final int x;
  final int y;

  @override
  bool operator ==(Object other) =>
      other is TeselaXYZ && other.z == z && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(z, x, y);

  @override
  String toString() => '$z/$x/$y';
}

/// Columna de la tesela que contiene la longitud [longitud] en el zoom [z].
int columnaTesela(double longitud, int z) {
  final n = 1 << z;
  final columna = ((longitud + 180.0) / 360.0 * n).floor();
  return columna.clamp(0, n - 1);
}

/// Fila de la tesela que contiene la latitud [latitud] en el zoom [z]
/// (proyección de Mercator; la fila 0 es la del norte).
int filaTesela(double latitud, int z) {
  final n = 1 << z;
  final latitudAcotada = latitud.clamp(-85.05112878, 85.05112878);
  final radianes = latitudAcotada * math.pi / 180.0;
  final fila = ((1.0 -
              math.log(math.tan(radianes) + 1.0 / math.cos(radianes)) /
                  math.pi) /
          2.0 *
          n)
      .floor();
  return fila.clamp(0, n - 1);
}

/// Rectángulo en grados (sur ≤ norte, oeste ≤ este).
class RectanguloGeo {
  const RectanguloGeo({
    required this.sur,
    required this.oeste,
    required this.norte,
    required this.este,
  });

  /// El rectángulo más pequeño que contiene todos los [puntos].
  factory RectanguloGeo.envolvente(Iterable<LatLng> puntos) {
    var sur = double.infinity, norte = -double.infinity;
    var oeste = double.infinity, este = -double.infinity;
    for (final punto in puntos) {
      sur = math.min(sur, punto.latitude);
      norte = math.max(norte, punto.latitude);
      oeste = math.min(oeste, punto.longitude);
      este = math.max(este, punto.longitude);
    }
    if (sur == double.infinity) {
      throw ArgumentError('Hace falta al menos un punto');
    }
    return RectanguloGeo(sur: sur, oeste: oeste, norte: norte, este: este);
  }

  final double sur;
  final double oeste;
  final double norte;
  final double este;

  /// El mismo rectángulo con [metros] más por cada lado.
  RectanguloGeo ampliado(double metros) {
    final gradosLatitud = metros / (radioTierraMetros * math.pi / 180.0);
    final latitudMedia = (sur + norte) / 2 * math.pi / 180.0;
    final gradosLongitud =
        gradosLatitud / math.max(math.cos(latitudMedia), 0.01);
    return RectanguloGeo(
      sur: sur - gradosLatitud,
      oeste: oeste - gradosLongitud,
      norte: norte + gradosLatitud,
      este: este + gradosLongitud,
    );
  }

  /// Teselas del zoom [z] que tocan el rectángulo.
  Iterable<TeselaXYZ> teselas(int z) sync* {
    final columnaOeste = columnaTesela(oeste, z);
    final columnaEste = columnaTesela(este, z);
    final filaNorte = filaTesela(norte, z);
    final filaSur = filaTesela(sur, z);
    for (var x = columnaOeste; x <= columnaEste; x++) {
      for (var y = filaNorte; y <= filaSur; y++) {
        yield TeselaXYZ(z, x, y);
      }
    }
  }

  /// Cuántas teselas del zoom [z] tocan el rectángulo.
  int contarTeselas(int z) =>
      (columnaTesela(este, z) - columnaTesela(oeste, z) + 1) *
      (filaTesela(sur, z) - filaTesela(norte, z) + 1);

  @override
  String toString() => 'RectanguloGeo($sur, $oeste, $norte, $este)';
}

/// Teselas de todos los [rectangulos] entre [zoomMinimo] y [zoomMaximo],
/// sin repetir las que comparten dos rectángulos, y de menos a más zoom
/// (así, si la descarga se corta, lo bajado ya sirve para ver la finca
/// entera aunque sea con menos detalle).
List<TeselaXYZ> teselasDeRectangulos(
  Iterable<RectanguloGeo> rectangulos, {
  int zoomMinimo = zoomMinimoDescarga,
  int zoomMaximo = zoomMaximoDescarga,
}) {
  final resultado = <TeselaXYZ>[];
  for (var z = zoomMinimo; z <= zoomMaximo; z++) {
    final vistas = <TeselaXYZ>{};
    for (final rectangulo in rectangulos) {
      for (final tesela in rectangulo.teselas(z)) {
        if (vistas.add(tesela)) resultado.add(tesela);
      }
    }
  }
  return resultado;
}

/// Bytes que ocuparán, más o menos, [numeroTeselas] teselas del PNOA.
int estimarBytesTeselas(int numeroTeselas) =>
    numeroTeselas * bytesMedioTeselaPnoa;

/// Megabytes redondeados hacia arriba (para enseñar: «unos 74 MB»).
int megabytesHaciaArriba(int bytes) =>
    bytes <= 0 ? 0 : (bytes / (1024 * 1024)).ceil();

/// Lo que se sabe de una finca para decidir qué trozo de mapa bajar: su
/// centro y superficie, y todo lo dibujado en ella (esquinas de las zonas y
/// puntos de infraestructura).
class FincaParaDescarga {
  const FincaParaDescarga({
    required this.nombre,
    this.centro,
    this.superficieHa = 0,
    this.puntosDibujados = const [],
  });

  final String nombre;
  final LatLng? centro;
  final double superficieHa;
  final List<LatLng> puntosDibujados;
}

/// Un rectángulo por finca (no uno que las abarque todas: Zunbeltz y La
/// Planilla están a unos 6 km y el hueco entre ellas, a zoom 19, serían
/// miles de teselas que nadie mira), con [margenMetros] por cada lado.
///
/// Si la finca no tiene nada dibujado se usa un cuadrado de su superficie
/// alrededor del centro (500 m de lado si tampoco se sabe la superficie).
/// Una finca sin centro ni dibujo no da rectángulo.
List<RectanguloGeo> rectangulosDeFincas(
  Iterable<FincaParaDescarga> fincas, {
  double margenMetros = margenDescargaMetros,
}) {
  final rectangulos = <RectanguloGeo>[];
  for (final finca in fincas) {
    if (finca.puntosDibujados.isNotEmpty) {
      rectangulos.add(RectanguloGeo.envolvente(finca.puntosDibujados)
          .ampliado(margenMetros));
    } else if (finca.centro != null) {
      final ladoMetros = finca.superficieHa > 0
          ? math.sqrt(finca.superficieHa * 10000)
          : 500.0;
      rectangulos.add(RectanguloGeo.envolvente([finca.centro!])
          .ampliado(ladoMetros / 2 + margenMetros));
    }
  }
  return rectangulos;
}
