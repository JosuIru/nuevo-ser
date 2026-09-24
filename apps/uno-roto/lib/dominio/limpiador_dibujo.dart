import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

/// El taller de dibujo: de la foto de un dibujo en papel al monstruo del
/// juego. Quita el papel (lo claro y poco saturado, aunque la luz no sea
/// pareja), deja el lápiz y los colores, y recorta a lo dibujado.
///
/// Sin paquetes de imagen: todo con `dart:ui`, así funciona igual en el
/// móvil que en los tests.

/// Píxeles RGBA con su tamaño.
class PixelesDibujo {
  final Uint8List rgba;
  final int ancho;
  final int alto;

  const PixelesDibujo(this.rgba, this.ancho, this.alto);
}

/// Quita el papel de [entrada] y recorta. Devuelve null si no queda
/// nada dibujado (foto en blanco, o sólo papel).
///
/// El brillo del papel se mide por zonas (el percentil 90 de cada una),
/// así una sombra o una luz que entra de lado siguen siendo papel.
PixelesDibujo? quitarPapel(PixelesDibujo entrada) {
  final rgba = entrada.rgba;
  final papel = _brilloDelPapelPorZonas(entrada);
  final salida = Uint8List.fromList(rgba);
  var minX = entrada.ancho, minY = entrada.alto, maxX = -1, maxY = -1;
  for (var y = 0; y < entrada.alto; y++) {
    for (var x = 0; x < entrada.ancho; x++) {
      final i = (y * entrada.ancho + x) * 4;
      final r = rgba[i], g = rgba[i + 1], b = rgba[i + 2];
      final saturacion = math.max(r, math.max(g, b)) - math.min(r, math.min(g, b));
      final brillo = _brillo(rgba, i);
      final papelAqui = papel(x, y);
      double opacidad;
      if (saturacion > 45) {
        opacidad = 1; // color: siempre es dibujo
      } else {
        // Hasta el 72 % del papel, trazo entero; desde el 88 %, papel;
        // entre medias, un borde suave para que no quede dentado.
        opacidad = ((papelAqui * 0.88 - brillo) / math.max(1, papelAqui * 0.16)).clamp(0.0, 1.0);
      }
      final alfa = (opacidad * rgba[i + 3]).round();
      salida[i + 3] = alfa;
      if (alfa > 128) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0) return null;
  // Un margen pequeño alrededor de lo dibujado.
  final margen = math.max(2, (math.max(maxX - minX, maxY - minY) * 0.04).round());
  minX = math.max(0, minX - margen);
  minY = math.max(0, minY - margen);
  maxX = math.min(entrada.ancho - 1, maxX + margen);
  maxY = math.min(entrada.alto - 1, maxY + margen);
  final ancho = maxX - minX + 1;
  final alto = maxY - minY + 1;
  final recortado = Uint8List(ancho * alto * 4);
  for (var y = 0; y < alto; y++) {
    final origen = ((minY + y) * entrada.ancho + minX) * 4;
    recortado.setRange(y * ancho * 4, (y + 1) * ancho * 4, salida, origen);
  }
  return PixelesDibujo(recortado, ancho, alto);
}

/// El brillo del papel en cada punto: la foto se parte en una rejilla de
/// 8 × 8 zonas; en cada una, el percentil 90 (lo más claro que no sea
/// un reflejo). Entre zonas se interpola, para que no haya escalones.
double Function(int x, int y) _brilloDelPapelPorZonas(PixelesDibujo entrada) {
  const zonas = 8;
  final anchoZona = math.max(1, (entrada.ancho / zonas).ceil());
  final altoZona = math.max(1, (entrada.alto / zonas).ceil());
  final columnas = (entrada.ancho / anchoZona).ceil();
  final filas = (entrada.alto / altoZona).ceil();
  final niveles = List<double>.filled(columnas * filas, 255);
  for (var fz = 0; fz < filas; fz++) {
    for (var cz = 0; cz < columnas; cz++) {
      final histograma = List<int>.filled(256, 0);
      var cuantos = 0;
      for (var y = fz * altoZona; y < math.min(entrada.alto, (fz + 1) * altoZona); y++) {
        for (var x = cz * anchoZona; x < math.min(entrada.ancho, (cz + 1) * anchoZona); x++) {
          histograma[_brillo(entrada.rgba, (y * entrada.ancho + x) * 4)]++;
          cuantos++;
        }
      }
      var acumulado = 0;
      for (var b = 0; b < 256; b++) {
        acumulado += histograma[b];
        if (acumulado >= cuantos * 0.9) {
          niveles[fz * columnas + cz] = b.toDouble();
          break;
        }
      }
    }
  }
  // Una zona casi toda dibujada no sabe cuál es su papel: se toma el de
  // la foto entera si el suyo sale mucho más oscuro.
  final ordenados = [...niveles]..sort();
  final general = ordenados[(ordenados.length * 0.75).floor().clamp(0, ordenados.length - 1)];
  for (var k = 0; k < niveles.length; k++) {
    if (niveles[k] < general * 0.75) niveles[k] = general;
  }
  double nivel(int cz, int fz) => niveles[fz.clamp(0, filas - 1) * columnas + cz.clamp(0, columnas - 1)];
  return (x, y) {
    final fx = x / anchoZona - 0.5;
    final fy = y / altoZona - 0.5;
    final cz = fx.floor();
    final fz = fy.floor();
    final tx = fx - cz;
    final ty = fy - fz;
    final arriba = nivel(cz, fz) * (1 - tx) + nivel(cz + 1, fz) * tx;
    final abajo = nivel(cz, fz + 1) * (1 - tx) + nivel(cz + 1, fz + 1) * tx;
    return arriba * (1 - ty) + abajo * ty;
  };
}

int _brillo(Uint8List rgba, int i) => (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;

/// De los bytes de una foto (JPG, PNG…) a un PNG limpio de como mucho
/// [ladoMaximo] px. Null si no hay dibujo que sacar.
Future<Uint8List?> limpiarDibujo(Uint8List bytesFoto, {int ladoMaximo = 600}) async {
  final codec = await ui.instantiateImageCodec(bytesFoto);
  final original = (await codec.getNextFrame()).image;
  final escala = math.min(1.0, ladoMaximo / math.max(original.width, original.height));
  final ancho = math.max(1, (original.width * escala).round());
  final alto = math.max(1, (original.height * escala).round());
  // Reescalado con un lienzo: el codec no siempre respeta el tamaño.
  final grabador = ui.PictureRecorder();
  ui.Canvas(grabador).drawImageRect(
    original,
    ui.Rect.fromLTWH(0, 0, original.width.toDouble(), original.height.toDouble()),
    ui.Rect.fromLTWH(0, 0, ancho.toDouble(), alto.toDouble()),
    ui.Paint()..filterQuality = ui.FilterQuality.medium,
  );
  final reducida = await grabador.endRecording().toImage(ancho, alto);
  final datos = await reducida.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (datos == null) return null;
  final limpio = quitarPapel(PixelesDibujo(datos.buffer.asUint8List(), ancho, alto));
  if (limpio == null) return null;
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(limpio.rgba, limpio.ancho, limpio.alto, ui.PixelFormat.rgba8888, completer.complete);
  final imagen = await completer.future;
  final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
  return png?.buffer.asUint8List();
}
