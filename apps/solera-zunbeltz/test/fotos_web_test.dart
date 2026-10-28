// Fotos en la versión web: se guardan en la BD (`fotos_web`), las
// entidades las llevan como `foto:<hash>` y suben y bajan con el mismo
// transporte que en el móvil.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';
import 'package:solera_zunbeltz/servicios/servicio_fotos_web.dart';
import 'package:solera_zunbeltz/utiles/fotos_sincronizadas.dart';

import 'bd_en_memoria.dart';

Uint8List jpegDePrueba(int ancho, int alto, {bool conExif = false}) {
  final imagen = img.Image(width: ancho, height: alto);
  for (final pixel in imagen) {
    pixel
      ..r = pixel.x * 255 ~/ ancho
      ..g = pixel.y * 255 ~/ alto
      ..b = 120;
  }
  if (conExif) imagen.exif.imageIfd['Make'] = img.IfdValueAscii('Movil');
  return img.encodeJpg(imagen, quality: 90);
}

class TransporteFalso implements TransporteFotos {
  final Map<String, List<int>> fotos = {};
  bool sinEndpoint = false;
  bool fallar = false;

  @override
  Future<ResultadoSubidaFoto> subirFoto(String hash, List<int> bytes) async {
    if (sinEndpoint) return ResultadoSubidaFoto.sinEndpoint;
    if (fallar || hashFoto(bytes) != hash) return ResultadoSubidaFoto.fallo;
    fotos[hash] = bytes;
    return ResultadoSubidaFoto.subida;
  }

  @override
  Future<ResultadoBajadaFoto> bajarFoto(String hash) async {
    if (sinEndpoint) return const ResultadoBajadaFoto.sinEndpoint();
    final bytes = fotos[hash];
    if (fallar || bytes == null) return const ResultadoBajadaFoto.fallo();
    return ResultadoBajadaFoto.bajada(bytes);
  }
}

void main() {
  group('fotoWebListaParaSubir', () {
    test('un JPEG pequeño sin EXIF va tal cual', () {
      expect(fotoWebListaParaSubir(jpegDePrueba(200, 100)), isTrue);
    });

    test('con EXIF (posición GPS posible), PNG o enorme, se reduce', () {
      expect(fotoWebListaParaSubir(jpegDePrueba(200, 100, conExif: true)),
          isFalse);
      expect(
          fotoWebListaParaSubir(
              img.encodePng(img.Image(width: 10, height: 10))),
          isFalse);
      final enorme = Uint8List(maximoBytesFotoWebSinReducir + 1)
        ..setAll(0, jpegDePrueba(20, 20));
      expect(fotoWebListaParaSubir(enorme), isFalse);
    });
  });

  group('guardarFotoElegida', () {
    test('guarda los bytes y devuelve la referencia por su hash', () async {
      final bd = await abrirBdEnMemoria();
      final original = jpegDePrueba(300, 200);
      final referencia = await guardarFotoElegida(bd, original);

      expect(referencia, referenciaFoto(hashFoto(original)));
      expect(await bd.bytesFotoWeb(hashFoto(original)), original);
      expect(
          (await bd.listarFotosWebPorSubir()).single.hash, hashFoto(original));
      expect(await bd.contarFotosWebPorSubir(), 1);
    });

    test('una con EXIF se guarda reducida y sin EXIF', () async {
      final bd = await abrirBdEnMemoria();
      final referencia =
          await guardarFotoElegida(bd, jpegDePrueba(2400, 1200, conExif: true));
      final bytes = await bd.bytesFotoWeb(hashDeReferencia(referencia!)!);
      final leida = img.decodeJpg(bytes!)!;
      expect(leida.width, ladoMayorFotoSubida);
      expect(leida.exif.imageIfd['Make'], isNull);
      expect(fotoWebListaParaSubir(bytes), isTrue);
    });

    test('lo que no es una imagen no se guarda', () async {
      final bd = await abrirBdEnMemoria();
      expect(
          await guardarFotoElegida(bd, Uint8List.fromList([1, 2, 3])), isNull);
      expect(await bd.contarFotosWebPorSubir(), 0);
    });
  });

  group('ServicioFotosWeb.transferir', () {
    test('sube lo pendiente y baja lo que una ficha referencia', () async {
      final bd = await abrirBdEnMemoria();
      final servidor = TransporteFalso();
      final propia = jpegDePrueba(100, 100);
      await guardarFotoElegida(bd, propia);
      final ajena = jpegDePrueba(120, 80);
      servidor.fotos[hashFoto(ajena)] = ajena;
      await (await bd.basedatos).insert('fincas', {
        'nombre': 'Zunbeltz',
        'rutas_fotos_json': '["${referenciaFoto(hashFoto(ajena))}"]',
      });
      expect((await bd.listarFotosPorBajar()).single.hash, hashFoto(ajena));

      final resumen =
          await ServicioFotosWeb(bd: bd, transporte: servidor).transferir();

      expect(resumen.subidas, 1);
      expect(resumen.bajadas, 1);
      expect(servidor.fotos[hashFoto(propia)], propia);
      expect(await bd.contarFotosWebPorSubir(), 0);
      expect(await bd.bytesFotoWeb(hashFoto(ajena)), ajena);
      expect(await bd.listarFotosPorBajar(), isEmpty);
    });

    test('si falla, espera antes de reintentar; sin endpoint, nada', () async {
      final bd = await abrirBdEnMemoria();
      final servidor = TransporteFalso()..fallar = true;
      var ahora = DateTime(2026, 10, 28, 10);
      final servicio =
          ServicioFotosWeb(bd: bd, transporte: servidor, reloj: () => ahora);
      await guardarFotoElegida(bd, jpegDePrueba(50, 50));

      expect((await servicio.transferir()).fallidas, 1);
      expect((await servicio.transferir()).fallidas, 0,
          reason: 'aún no toca reintentar');
      servidor.fallar = false;
      ahora = ahora.add(const Duration(minutes: 2));
      expect((await servicio.transferir()).subidas, 1);

      await guardarFotoElegida(bd, jpegDePrueba(60, 60));
      servidor.sinEndpoint = true;
      expect((await servicio.transferir()).servidorSinFotos, isTrue);
      expect(await bd.contarFotosWebPorSubir(), 1);
    });

    test('bajarAhora guarda la foto para la próxima vez', () async {
      final bd = await abrirBdEnMemoria();
      final servidor = TransporteFalso();
      final foto = jpegDePrueba(40, 40);
      servidor.fotos[hashFoto(foto)] = foto;
      final servicio = ServicioFotosWeb(bd: bd, transporte: servidor);

      expect(await servicio.bajarAhora(hashFoto(foto)), foto);
      servidor.fotos.clear();
      expect(await servicio.bajarAhora(hashFoto(foto)), foto);
      expect(await bd.contarFotosWebPorSubir(), 0, reason: 'ya está subida');
    });
  });
}
