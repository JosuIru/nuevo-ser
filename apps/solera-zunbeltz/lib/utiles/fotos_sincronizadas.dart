/// Fotos que viajan entre los móviles a través del WordPress de Zunbeltz.
///
/// En la BD local cada entidad guarda sus fotos como lista JSON
/// (`rutas_fotos_json`, formato de `GestorFotos` del core). Cada elemento
/// es una de estas dos cosas:
///
/// - **una ruta de fichero** de este móvil (una foto hecha aquí, o una foto
///   de otro móvil que ya se ha bajado);
/// - **una referencia** `foto:<sha256>` a una foto que este móvil no tiene
///   (todavía) en un fichero: llegó de otro móvil y aún no se ha bajado.
///
/// Al servidor solo viajan **hashes** SHA-256 de la copia reducida
/// (`fotos: [hash, …]` en los datos de la entidad): nunca rutas locales.
/// La correspondencia hash ↔ fichero vive en la BD (`fotos_sync` y
/// `rutas_fotos`, ver `datos/base_datos_fotos.dart`).
///
/// Aquí solo hay funciones puras, con tests (`test/fotos_sincronizadas_test.dart`).
library;

import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

/// Prefijo de una referencia a una foto que no está en un fichero local.
const String prefijoReferenciaFoto = 'foto:';

/// Lado mayor de la copia que se sube (px).
const int ladoMayorFotoSubida = 1600;

/// Calidad JPEG de la copia que se sube (objetivo: unos 300 KB).
const int calidadJpegFotoSubida = 80;

final RegExp _expresionHash = RegExp(r'^[0-9a-f]{64}$');

/// ¿Es [texto] un SHA-256 en hexadecimal (minúsculas)?
bool esHashFotoValido(String texto) => _expresionHash.hasMatch(texto);

bool esReferenciaFoto(String entrada) =>
    entrada.startsWith(prefijoReferenciaFoto) &&
    esHashFotoValido(entrada.substring(prefijoReferenciaFoto.length));

String referenciaFoto(String hash) => '$prefijoReferenciaFoto$hash';

/// Hash de una referencia `foto:<hash>`, o `null` si [entrada] es una ruta.
String? hashDeReferencia(String entrada) => esReferenciaFoto(entrada)
    ? entrada.substring(prefijoReferenciaFoto.length)
    : null;

/// SHA-256 en hexadecimal de los bytes de una foto (el nombre con que la
/// guarda el servidor).
String hashFoto(List<int> bytes) => sha256.convert(bytes).toString();

/// Lo que viaja al servidor: el hash de cada entrada. Una referencia da su
/// hash; una ruta, el de su copia reducida según [hashPorRuta]. Una ruta
/// sin hash (fichero perdido, foto que no se pudo leer) no viaja. Sin
/// repetidos y en el mismo orden.
List<String> hashesDeEntradasFoto(
    List<String> entradas, Map<String, String> hashPorRuta) {
  final hashes = <String>[];
  for (final entrada in entradas) {
    final hash = hashDeReferencia(entrada) ?? hashPorRuta[entrada];
    if (hash != null && esHashFotoValido(hash) && !hashes.contains(hash)) {
      hashes.add(hash);
    }
  }
  return hashes;
}

/// Lo que se guarda en local al recibir [hashes] del servidor: la ruta del
/// fichero si este móvil lo tiene ([rutaPorHash]), si no la referencia
/// `foto:<hash>`. Los hashes mal formados se descartan.
List<String> entradasFotoDeHashes(
    Iterable<Object?> hashes, Map<String, String> rutaPorHash) {
  final entradas = <String>[];
  for (final valor in hashes) {
    if (valor is! String || !esHashFotoValido(valor)) continue;
    final ruta = rutaPorHash[valor];
    final entrada =
        (ruta == null || ruta.isEmpty) ? referenciaFoto(valor) : ruta;
    if (!entradas.contains(entrada)) entradas.add(entrada);
  }
  return entradas;
}

/// Al recibir las fotos de una entidad ([recibidas], ya en entradas
/// locales): se añaden las fotos de este móvil ([localesActuales]) que
/// nunca se pudieron preparar para subir (no están en [rutasConHash]: el
/// fichero no se pudo leer). El servidor no las conoce, así que no puede
/// haberlas quitado nadie, y sin esto desaparecerían de la ficha.
List<String> combinarFotosRecibidas(List<String> recibidas,
    List<String> localesActuales, Set<String> rutasConHash) {
  final combinadas = [...recibidas];
  for (final entrada in localesActuales) {
    if (entrada.isEmpty ||
        esReferenciaFoto(entrada) ||
        rutasConHash.contains(entrada) ||
        combinadas.contains(entrada)) {
      continue;
    }
    combinadas.add(entrada);
  }
  return combinadas;
}

/// ¿Se pueden pasar fotos con esta conexión? Solo con wifi o cable (red que
/// no se paga por megas). Con datos móviles, sin red o con algo que no se
/// sabe qué es (solo VPN, bluetooth), no: las fotos esperan y los datos se
/// sincronizan igual.
bool redPermiteTransferirFotos(Iterable<ConnectivityResult> conexiones) =>
    conexiones.any((conexion) =>
        conexion == ConnectivityResult.wifi ||
        conexion == ConnectivityResult.ethernet);

/// Espera antes de volver a intentar subir o bajar una foto que ha fallado
/// [intentos] veces: 1, 2, 4… minutos, como mucho un día.
Duration esperaTrasFallosFoto(int intentos) {
  if (intentos <= 0) return Duration.zero;
  final minutos = 1 << (intentos - 1).clamp(0, 11);
  return Duration(minutes: minutos.clamp(1, 24 * 60));
}

/// ¿Toca volver a intentarlo? Pura.
bool tocaReintentarFoto(int intentos, int ultimoIntentoMs, int ahoraMs) =>
    intentos <= 0 ||
    ahoraMs - ultimoIntentoMs >=
        esperaTrasFallosFoto(intentos).inMilliseconds ||
    // Reloj corregido hacia atrás: no esperar hasta alcanzarlo.
    ultimoIntentoMs > ahoraMs;

/// Tipo de imagen según su cabecera real (no según la extensión): el mismo
/// criterio que aplica el servidor. `null` si no es JPEG, PNG ni WebP.
String? tipoMimeDeImagen(List<int> bytes) {
  bool empiezaPor(List<int> firma, [int desde = 0]) {
    if (bytes.length < desde + firma.length) return false;
    for (var i = 0; i < firma.length; i++) {
      if (bytes[desde + i] != firma[i]) return false;
    }
    return true;
  }

  if (empiezaPor(const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (empiezaPor(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'image/png';
  }
  if (empiezaPor('RIFF'.codeUnits) && empiezaPor('WEBP'.codeUnits, 8)) {
    return 'image/webp';
  }
  return null;
}

/// Copia para subir: girada según su EXIF, con el lado mayor reducido a
/// [ladoMayor] px (si lo pasa) y en JPEG de calidad [calidad], sin EXIF
/// (ni GPS ni modelo del móvil). `null` si no se puede leer la imagen.
///
/// Es lenta con fotos grandes (decodifica en Dart): llamarla fuera del
/// hilo de la interfaz (`Isolate.run`).
Uint8List? reducirFotoParaSubir(Uint8List original,
    {int ladoMayor = ladoMayorFotoSubida,
    int calidad = calidadJpegFotoSubida}) {
  final img.Image? leida;
  try {
    leida = img.decodeImage(original);
  } catch (_) {
    return null;
  }
  if (leida == null) return null;
  var imagen = img.bakeOrientation(leida);
  final mayor = imagen.width > imagen.height ? imagen.width : imagen.height;
  if (mayor > ladoMayor) {
    imagen = imagen.width >= imagen.height
        ? img.copyResize(imagen,
            width: ladoMayor, interpolation: img.Interpolation.average)
        : img.copyResize(imagen,
            height: ladoMayor, interpolation: img.Interpolation.average);
  }
  imagen.exif = img.ExifData();
  return img.encodeJpg(imagen, quality: calidad);
}
