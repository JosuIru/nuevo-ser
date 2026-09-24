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

  /// Dónde empieza este recorte en la imagen de la que salió.
  final int x;
  final int y;

  const PixelesDibujo(this.rgba, this.ancho, this.alto, {this.x = 0, this.y = 0});
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
      // Lo casi transparente, fuera del todo: no suma nada y ensucia.
      salida[i + 3] = alfa <= 40 ? 0 : alfa;
    }
  }
  _quitarManchasSobrantes(salida, entrada.ancho, entrada.alto);
  for (var y = 0; y < entrada.alto; y++) {
    for (var x = 0; x < entrada.ancho; x++) {
      if (salida[(y * entrada.ancho + x) * 4 + 3] > 128) {
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
  return PixelesDibujo(recortado, ancho, alto, x: minX, y: minY);
}

/// Quita, por manchas conectadas (lo que no es transparente):
/// - las diminutas (motas del papel, puntitos del escáner), que además
///   estirarían el recorte;
/// - las grises u oscuras que tocan el borde de la foto: la mesa, la
///   sombra de la hoja o el marco del escáner. Las de color que tocan el
///   borde se quedan: un paisaje puede pintarse hasta el borde;
/// - las pequeñas y lejos del dibujo principal (la mancha más grande):
///   el nombre escrito en una esquina, una marca suelta. Lo que está
///   cerca o dentro (ojos, detalles) y lo grande (una luna) se queda.
void _quitarManchasSobrantes(Uint8List rgba, int ancho, int alto) {
  final total = ancho * alto;
  final minimo = math.max(12, (total * 0.00015).round());
  final visitado = Uint8List(total);
  final cola = <int>[];
  final manchas = <_Mancha>[];
  for (var inicio = 0; inicio < total; inicio++) {
    if (visitado[inicio] == 1 || rgba[inicio * 4 + 3] == 0) continue;
    // Recorre la mancha entera.
    cola
      ..clear()
      ..add(inicio);
    visitado[inicio] = 1;
    var tocaBorde = false;
    var sumaSaturacion = 0;
    for (var k = 0; k < cola.length; k++) {
      final p = cola[k];
      final x = p % ancho;
      final y = p ~/ ancho;
      if (x == 0 || y == 0 || x == ancho - 1 || y == alto - 1) tocaBorde = true;
      final i = p * 4;
      sumaSaturacion += math.max(rgba[i], math.max(rgba[i + 1], rgba[i + 2])) -
          math.min(rgba[i], math.min(rgba[i + 1], rgba[i + 2]));
      for (final vecino in [
        if (x > 0) p - 1,
        if (x < ancho - 1) p + 1,
        if (y > 0) p - ancho,
        if (y < alto - 1) p + ancho,
      ]) {
        if (visitado[vecino] == 0 && rgba[vecino * 4 + 3] > 0) {
          visitado[vecino] = 1;
          cola.add(vecino);
        }
      }
    }
    final pequena = cola.length < minimo;
    final bordeSinColor = tocaBorde && sumaSaturacion / cola.length < 30;
    final marco = _esMarco(cola, ancho, alto);
    if (pequena || bordeSinColor || marco) {
      for (final p in cola) {
        rgba[p * 4 + 3] = 0;
      }
    } else {
      manchas.add(_Mancha(List.of(cola), ancho));
    }
  }
  if (manchas.isEmpty) return;
  manchas.sort((a, b) => b.pixeles.length.compareTo(a.pixeles.length));
  final principal = manchas.first;
  // La zona del dibujo: la mancha principal con un margen del 15 %.
  final margenX = (principal.maxX - principal.minX) * 0.15;
  final margenY = (principal.maxY - principal.minY) * 0.15;
  final zona = (
    minX: principal.minX - margenX,
    maxX: principal.maxX + margenX,
    minY: principal.minY - margenY,
    maxY: principal.maxY + margenY,
  );
  for (final mancha in manchas.skip(1)) {
    if (mancha.pixeles.length >= principal.pixeles.length * 0.08) continue;
    // Lejos: la mayor parte de sus píxeles, fuera de la zona del dibujo
    // (así cuenta también una línea fina que cruza la hoja entera).
    var dentro = 0;
    for (final p in mancha.pixeles) {
      final x = p % ancho;
      final y = p ~/ ancho;
      if (x >= zona.minX && x <= zona.maxX && y >= zona.minY && y <= zona.maxY) dentro++;
    }
    if (dentro < mancha.pixeles.length / 2) {
      for (final p in mancha.pixeles) {
        rgba[p * 4 + 3] = 0;
      }
    }
  }
}

/// Una línea que recorre más de media hoja y apenas llena su rectángulo:
/// el marco del escáner o el borde de la hoja, no un trazo del dibujo.
bool _esMarco(List<int> pixeles, int ancho, int alto) {
  final mancha = _Mancha(pixeles, ancho);
  final anchoMancha = mancha.maxX - mancha.minX + 1;
  final altoMancha = mancha.maxY - mancha.minY + 1;
  final larga = anchoMancha > ancho * 0.5 && altoMancha > alto * 0.5;
  return larga && pixeles.length < anchoMancha * altoMancha * 0.03;
}

/// Una mancha conectada: sus píxeles y su rectángulo.
class _Mancha {
  final List<int> pixeles;
  late final int minX, maxX, minY, maxY;

  _Mancha(this.pixeles, int ancho) {
    var x0 = 1 << 30, x1 = -1, y0 = 1 << 30, y1 = -1;
    for (final p in pixeles) {
      final x = p % ancho;
      final y = p ~/ ancho;
      if (x < x0) x0 = x;
      if (x > x1) x1 = x;
      if (y < y0) y0 = y;
      if (y > y1) y1 = y;
    }
    minX = x0;
    maxX = x1;
    minY = y0;
    maxY = y1;
  }
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

/// La foto reducida a [ladoMaximo] px como mucho, y recortada a
/// [recorte] (en fracciones de la foto, de 0 a 1) si lo hay.
Future<PixelesDibujo?> _reducir(Uint8List bytesFoto, int ladoMaximo, ui.Rect? recorte) async {
  final codec = await ui.instantiateImageCodec(bytesFoto);
  final original = (await codec.getNextFrame()).image;
  final zona = recorte == null
      ? ui.Rect.fromLTWH(0, 0, original.width.toDouble(), original.height.toDouble())
      : ui.Rect.fromLTRB(
          recorte.left.clamp(0.0, 1.0) * original.width,
          recorte.top.clamp(0.0, 1.0) * original.height,
          recorte.right.clamp(0.0, 1.0) * original.width,
          recorte.bottom.clamp(0.0, 1.0) * original.height,
        );
  if (zona.width < 2 || zona.height < 2) return null;
  final escala = math.min(1.0, ladoMaximo / math.max(zona.width, zona.height));
  final ancho = math.max(1, (zona.width * escala).round());
  final alto = math.max(1, (zona.height * escala).round());
  // Reescalado con un lienzo: el codec no siempre respeta el tamaño.
  final grabador = ui.PictureRecorder();
  ui.Canvas(grabador).drawImageRect(
    original,
    zona,
    ui.Rect.fromLTWH(0, 0, ancho.toDouble(), alto.toDouble()),
    ui.Paint()..filterQuality = ui.FilterQuality.medium,
  );
  final reducida = await grabador.endRecording().toImage(ancho, alto);
  final datos = await reducida.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (datos == null) return null;
  return PixelesDibujo(datos.buffer.asUint8List(), ancho, alto);
}

/// El encuadre que el juego propone para la foto: lo dibujado, en
/// fracciones de la foto (0 a 1). Null si no encuentra dibujo.
Future<ui.Rect?> encuadreSugerido(Uint8List bytesFoto) async {
  final foto = await _reducir(bytesFoto, 600, null);
  if (foto == null) return null;
  final limpio = quitarPapel(foto);
  if (limpio == null) return null;
  return ui.Rect.fromLTWH(
    limpio.x / foto.ancho,
    limpio.y / foto.alto,
    limpio.ancho / foto.ancho,
    limpio.alto / foto.alto,
  );
}

/// De los bytes de una foto (JPG, PNG…) a un PNG limpio de como mucho
/// [ladoMaximo] px. Con [recorte] (el encuadre elegido, en fracciones de
/// la foto) se limpia sólo esa parte. Null si no hay dibujo que sacar.
Future<Uint8List?> limpiarDibujo(Uint8List bytesFoto, {int ladoMaximo = 600, ui.Rect? recorte}) async {
  final foto = await _reducir(bytesFoto, ladoMaximo, recorte);
  if (foto == null) return null;
  final limpio = quitarPapel(foto);
  if (limpio == null) return null;
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(limpio.rgba, limpio.ancho, limpio.alto, ui.PixelFormat.rgba8888, completer.complete);
  final imagen = await completer.future;
  final png = await imagen.toByteData(format: ui.ImageByteFormat.png);
  return png?.buffer.asUint8List();
}
