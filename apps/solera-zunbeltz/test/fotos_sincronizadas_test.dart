// Fotos sincronizadas: lógica pura (referencias, conversión ruta ↔ hash,
// criterio de red, esperas, reducción), BD (migración v18, cola de subida
// y bajada, entidades que suben y bajan con hashes), el servicio que mueve
// las fotos con un servidor falso, el cliente HTTP contra un servidor
// local y un viaje completo de un móvil a otro.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/punto_infraestructura.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';
import 'package:solera_zunbeltz/servicios/servicio_fotos_sync.dart';
import 'package:solera_zunbeltz/utiles/fotos_sincronizadas.dart';

import 'bd_en_memoria.dart';

/// JPEG de prueba de [ancho] × [alto] con un degradado (para que no
/// comprima a nada).
Uint8List jpegDePrueba(int ancho, int alto) {
  final imagen = img.Image(width: ancho, height: alto);
  for (final pixel in imagen) {
    pixel
      ..r = pixel.x * 255 ~/ ancho
      ..g = pixel.y * 255 ~/ alto
      ..b = 120;
  }
  return img.encodeJpg(imagen, quality: 95);
}

/// Servidor de fotos falso.
class TransporteFalso implements TransporteFotos {
  final Map<String, List<int>> fotos = {};
  bool sinEndpoint = false;
  bool fallar = false;
  int subidas = 0;

  @override
  Future<ResultadoSubidaFoto> subirFoto(String hash, List<int> bytes) async {
    if (sinEndpoint) return ResultadoSubidaFoto.sinEndpoint;
    if (fallar || hashFoto(bytes) != hash) return ResultadoSubidaFoto.fallo;
    subidas++;
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
  final hashA = 'a' * 64;
  final hashB = 'b' * 64;

  group('lógica pura', () {
    test('referencias foto:<hash>', () {
      expect(esHashFotoValido(hashA), isTrue);
      expect(esHashFotoValido('A' * 64), isFalse, reason: 'en minúsculas');
      expect(esHashFotoValido('a' * 63), isFalse);
      expect(referenciaFoto(hashA), 'foto:$hashA');
      expect(hashDeReferencia('foto:$hashA'), hashA);
      expect(hashDeReferencia('/data/fotos/1.jpg'), isNull);
      expect(hashDeReferencia('foto:nohash'), isNull);
      expect(hashFoto(utf8.encode('abc')),
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    });

    test('rutas → hashes: referencias y rutas preparadas, sin repetir', () {
      expect(
          hashesDeEntradasFoto([
            '/m/1.jpg',
            'foto:$hashB',
            '/m/sin-preparar.jpg',
            '/m/copia.jpg',
          ], {
            '/m/1.jpg': hashA,
            '/m/copia.jpg': hashA,
          }),
          [hashA, hashB]);
    });

    test('hashes → entradas: el fichero si lo hay, si no la referencia', () {
      expect(
          entradasFotoDeHashes(
              [hashA, hashB, 'basura', 7, hashA], {hashA: '/m/1.jpg'}),
          ['/m/1.jpg', 'foto:$hashB']);
    });

    test('al recibir no se pierden las fotos locales que no pudieron subir',
        () {
      expect(
          combinarFotosRecibidas(
            ['foto:$hashB'],
            ['/m/ya-subida.jpg', '/m/ilegible.heic', 'foto:$hashA'],
            {'/m/ya-subida.jpg'},
          ),
          ['foto:$hashB', '/m/ilegible.heic'],
          reason: 'la subida y la referencia las quitó otra persona; la '
              'ilegible nadie la conoce');
    });

    test('solo wifi o cable', () {
      expect(redPermiteTransferirFotos([ConnectivityResult.wifi]), isTrue);
      expect(redPermiteTransferirFotos([ConnectivityResult.ethernet]), isTrue);
      expect(
          redPermiteTransferirFotos(
              [ConnectivityResult.vpn, ConnectivityResult.wifi]),
          isTrue);
      expect(redPermiteTransferirFotos([ConnectivityResult.mobile]), isFalse);
      expect(redPermiteTransferirFotos([ConnectivityResult.vpn]), isFalse);
      expect(redPermiteTransferirFotos([ConnectivityResult.none]), isFalse);
      expect(redPermiteTransferirFotos(const []), isFalse);
    });

    test('esperas crecientes tras fallar, como mucho un día', () {
      expect(esperaTrasFallosFoto(0), Duration.zero);
      expect(esperaTrasFallosFoto(1), const Duration(minutes: 1));
      expect(esperaTrasFallosFoto(3), const Duration(minutes: 4));
      expect(esperaTrasFallosFoto(40), const Duration(days: 1));
      const minuto = 60000;
      expect(tocaReintentarFoto(0, 0, 10), isTrue);
      expect(tocaReintentarFoto(3, 1000, 1000 + 3 * minuto), isFalse);
      expect(tocaReintentarFoto(3, 1000, 1000 + 4 * minuto), isTrue);
      expect(tocaReintentarFoto(3, 9999999, 1000), isTrue,
          reason: 'reloj atrasado');
    });

    test('tipo por la cabecera real', () {
      expect(tipoMimeDeImagen(jpegDePrueba(4, 4)), 'image/jpeg');
      expect(tipoMimeDeImagen(img.encodePng(img.Image(width: 2, height: 2))),
          'image/png');
      expect(
          tipoMimeDeImagen(
              [...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits]),
          'image/webp');
      expect(tipoMimeDeImagen(utf8.encode('<?php')), isNull);
    });

    test('reducción: 1600 px de lado mayor, JPEG, sin EXIF', () {
      final apaisada = reducirFotoParaSubir(jpegDePrueba(2000, 1250))!;
      final leida = img.decodeJpg(apaisada)!;
      expect((leida.width, leida.height), (1600, 1000));
      expect(tipoMimeDeImagen(apaisada), 'image/jpeg');
      expect(leida.exif.isEmpty, isTrue);

      final vertical =
          img.decodeJpg(reducirFotoParaSubir(jpegDePrueba(700, 1680))!)!;
      expect((vertical.width, vertical.height), (667, 1600));

      final pequena =
          img.decodeJpg(reducirFotoParaSubir(jpegDePrueba(800, 600))!)!;
      expect((pequena.width, pequena.height), (800, 600),
          reason: 'no se agranda');

      expect(reducirFotoParaSubir(Uint8List.fromList(utf8.encode('nada'))),
          isNull);
      // Determinista: el mismo original da el mismo hash en cualquier móvil.
      final original = jpegDePrueba(1700, 900);
      expect(hashFoto(reducirFotoParaSubir(original)!),
          hashFoto(reducirFotoParaSubir(original)!));
    });

    test('reducción: gira según el EXIF', () {
      final imagen = img.Image(width: 40, height: 20)
        ..exif.imageIfd.orientation = 6;
      final girada =
          img.decodeJpg(reducirFotoParaSubir(img.encodeJpg(imagen))!)!;
      expect((girada.width, girada.height), (20, 40));
    });
  });

  group('BD', () {
    test('la migración v18 conserva las fotos y crea las tablas', () async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 17,
            singleInstance: false,
            onCreate: (d, v) async {
              await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
              await BaseDatosSoleraZunbeltz.migrarDesde(d, 1);
            },
          ));
      // migrarDesde(…, 1) ya aplica todo; se simula una BD de la v17
      // quitando lo de la v18 y volviendo a aplicarla.
      await db.execute('DROP TABLE fotos_sync');
      await db.execute('DROP TABLE rutas_fotos');
      await db.insert(
          'fincas', {'nombre': 'Zufía', 'rutas_fotos_json': '["/m/1.jpg"]'});
      await BaseDatosSoleraZunbeltz.aplicarMigracionV18(db);
      final bd = BaseDatosSoleraZunbeltz.paraTests(db);
      expect(await bd.rutasFotoSinPreparar(), ['/m/1.jpg']);
      expect(await bd.listarFotosPorSubir(), isEmpty);
      await db.close();
    });

    test('cola de subida: preparada → subida', () async {
      final bd = await abrirBdEnMemoria();
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      await bd.guardarPunto(PuntoInfraestructura(
          fincaId: fincaId,
          rutasFotosJson: jsonEncode(['/m/1.jpg', 'foto:$hashB'])));
      expect(await bd.rutasFotoSinPreparar(), ['/m/1.jpg']);
      await bd.registrarFotoPreparada(
          ruta: '/m/1.jpg', hash: hashA, rutaSubida: '/c/$hashA.jpg');
      expect(await bd.rutasFotoSinPreparar(), isEmpty);
      expect(
          (await bd.listarFotosPorSubir()).single.rutaSubida, '/c/$hashA.jpg');
      expect(await bd.rutaLocalDeFoto(hashA), '/m/1.jpg');
      await bd.anotarFalloFoto(hashA, ahoraMs: 50);
      expect((await bd.listarFotosPorSubir()).single.intentos, 1);
      await bd.marcarFotoSubida(hashA);
      expect(await bd.listarFotosPorSubir(), isEmpty);
      expect(await bd.rutaLocalDeFoto(hashA), '/m/1.jpg',
          reason: 'la que se ve sigue siendo el original');
    });

    test('cola de bajada: referencias sin fichero', () async {
      final bd = await abrirBdEnMemoria();
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      await bd.guardarTarea(TareaMantenimiento(
          fincaId: fincaId,
          rutasFotosAntesJson: jsonEncode(['foto:$hashA']),
          rutasFotosDespuesJson: jsonEncode(['foto:$hashB', '/m/x.jpg'])));
      expect({for (final f in await bd.listarFotosPorBajar()) f.hash},
          {hashA, hashB});
      await bd.anotarFalloFoto(hashA, ahoraMs: 10);
      final conFallo =
          (await bd.listarFotosPorBajar()).firstWhere((f) => f.hash == hashA);
      expect((conFallo.intentos, conFallo.ultimoIntentoMs), (1, 10));
      await bd.registrarFotoBajada(hashA, '/d/$hashA.jpg');
      expect([for (final f in await bd.listarFotosPorBajar()) f.hash], [hashB]);
      expect(await bd.rutaLocalDeFoto(hashA), '/d/$hashA.jpg');
      expect(await bd.rutasFotoSinPreparar(), ['/m/x.jpg']);
    });

    test('las entidades suben con hashes y bajan como referencias', () async {
      final bd = await abrirBdEnMemoria();
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      await bd.guardarPunto(PuntoInfraestructura(
          fincaId: fincaId,
          nombre: 'Abrevadero',
          rutasFotosJson:
              jsonEncode(['/m/1.jpg', 'foto:$hashB', '/m/sin-preparar.jpg'])));
      await bd.registrarFotoPreparada(
          ruta: '/m/1.jpg', hash: hashA, rutaSubida: '/c/a.jpg');
      final punto = (await bd.entidadesPendientesDeSubir(0))
          .firstWhere((e) => e['tipo'] == 'punto');
      final datos = punto['datos'] as Map;
      expect(datos['fotos'], [hashA, hashB]);
      expect(datos.containsKey('rutas_fotos_json'), isFalse,
          reason: 'las rutas del móvil no viajan');

      // Llega del servidor con otra foto: la conocida se ve por su fichero,
      // la nueva como referencia, y la que no se pudo preparar se queda.
      final uid = punto['uid'] as String;
      await bd.aplicarEntidadRemota({
        'tipo': 'punto',
        'uid': uid,
        'actualizado_ms': DateTime.now().millisecondsSinceEpoch + 1000,
        'datos': {
          'nombre': 'Abrevadero',
          'finca_uid': await bd.uidDeFila('fincas', fincaId),
          'fotos': [hashA, 'c' * 64],
        },
      });
      final local = (await bd.listarPuntos()).single;
      expect(jsonDecode(local.rutasFotosJson),
          ['/m/1.jpg', 'foto:${'c' * 64}', '/m/sin-preparar.jpg']);

      // Sin la clave `fotos` (app anterior): se quedan las de este móvil.
      await bd.aplicarEntidadRemota({
        'tipo': 'punto',
        'uid': uid,
        'actualizado_ms': DateTime.now().millisecondsSinceEpoch + 2000,
        'datos': {
          'nombre': 'Abrevadero viejo',
          'finca_uid': await bd.uidDeFila('fincas', fincaId),
        },
      });
      final sinClave = (await bd.listarPuntos()).single;
      expect(sinClave.nombre, 'Abrevadero viejo');
      expect(sinClave.rutasFotosJson, local.rutasFotosJson);
    });
  });

  group('servicio', () {
    late Directory carpeta;
    late BaseDatosSoleraZunbeltz bd;
    late TransporteFalso servidor;
    late ServicioFotosSync servicio;
    late int fincaId;

    setUp(() async {
      carpeta = await Directory.systemTemp.createTemp('szs-fotos-');
      bd = await abrirBdEnMemoria();
      servidor = TransporteFalso();
      servicio = ServicioFotosSync(
        bd: bd,
        transporte: servidor,
        directorioFotos: Directory('${carpeta.path}/fotos_sync'),
        reducir: (bytes) async => reducirFotoParaSubir(bytes, ladoMayor: 200),
      );
      fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
    });
    tearDown(() => carpeta.delete(recursive: true));

    Future<String> fotoEnElMovil(String nombre) async {
      final fichero = File('${carpeta.path}/$nombre.jpg');
      await fichero.writeAsBytes(jpegDePrueba(600, 400));
      return fichero.path;
    }

    test('prepara, sube y borra la copia; la segunda vez no hay nada',
        () async {
      final ruta = await fotoEnElMovil('abrevadero');
      await bd.guardarPunto(PuntoInfraestructura(
          fincaId: fincaId,
          rutasFotosJson: jsonEncode([ruta, '${carpeta.path}/perdida.jpg'])));
      expect(await servicio.prepararFotosLocales(), 1,
          reason: 'la perdida no se puede preparar');
      final pendiente = (await bd.listarFotosPorSubir()).single;
      final copia = File(pendiente.rutaSubida);
      expect(img.decodeJpg(await copia.readAsBytes())!.width, 200);
      expect(hashFoto(await copia.readAsBytes()), pendiente.hash);

      final resumen = await servicio.transferir();
      expect((resumen.subidas, resumen.fallidas), (1, 0));
      expect(servidor.fotos.keys, [pendiente.hash]);
      expect(await copia.exists(), isFalse,
          reason: 'la copia ya no hace falta');
      expect(await bd.listarFotosPorSubir(), isEmpty);
      expect(await servicio.prepararFotosLocales(), 0);
      expect((await servicio.transferir()).subidas, 0);
    });

    test('un plugin sin fotos deja todo pendiente sin contar fallos', () async {
      await bd.guardarPunto(PuntoInfraestructura(
          fincaId: fincaId,
          rutasFotosJson: jsonEncode([await fotoEnElMovil('uno')])));
      await servicio.prepararFotosLocales();
      servidor.sinEndpoint = true;
      final resumen = await servicio.transferir();
      expect(resumen.servidorSinFotos, isTrue);
      final pendiente = (await bd.listarFotosPorSubir()).single;
      expect(pendiente.intentos, 0);
      servidor.sinEndpoint = false;
      expect((await servicio.transferir()).subidas, 1,
          reason: 'al actualizar el plugin, sube');
    });

    test('lo que falla espera antes de reintentarse', () async {
      var ahora = DateTime(2026, 10, 23, 10);
      servicio = ServicioFotosSync(
        bd: bd,
        transporte: servidor,
        directorioFotos: Directory('${carpeta.path}/fotos_sync'),
        reducir: (bytes) async => reducirFotoParaSubir(bytes, ladoMayor: 200),
        reloj: () => ahora,
      );
      await bd.guardarPunto(PuntoInfraestructura(
          fincaId: fincaId,
          rutasFotosJson: jsonEncode([await fotoEnElMovil('uno')])));
      await servicio.prepararFotosLocales();
      servidor.fallar = true;
      expect((await servicio.transferir()).fallidas, 1);
      servidor.fallar = false;
      expect((await servicio.transferir()).subidas, 0, reason: 'aún no toca');
      ahora = ahora.add(const Duration(minutes: 2));
      expect((await servicio.transferir()).subidas, 1);
    });

    test('baja lo que falta y lo comprueba', () async {
      final bytes = jpegDePrueba(100, 80);
      final hash = hashFoto(bytes);
      servidor.fotos[hash] = bytes;
      await bd.guardarTarea(TareaMantenimiento(
          fincaId: fincaId,
          rutasFotosDespuesJson: jsonEncode(['foto:$hash', 'foto:$hashB'])));
      final resumen = await servicio.transferir();
      expect((resumen.bajadas, resumen.fallidas), (1, 1),
          reason: 'la B aún no la ha subido nadie');
      final ruta = await bd.rutaLocalDeFoto(hash);
      expect(await File(ruta!).readAsBytes(), bytes);
      expect([for (final f in await bd.listarFotosPorBajar()) f.hash], [hashB]);
      expect(await servicio.prepararFotosLocales(), 0,
          reason: 'una foto bajada no se vuelve a preparar ni a subir');
    });

    test('bajar ahora (la persona la pide) no espera a la cola', () async {
      final bytes = jpegDePrueba(50, 50);
      final hash = hashFoto(bytes);
      await bd.anotarFalloFoto(hash);
      servidor.fotos[hash] = bytes;
      final ruta = await servicio.bajarAhora(hash);
      expect(await File(ruta!).readAsBytes(), bytes);
      expect(await servicio.bajarAhora(hash), ruta, reason: 'ya la tiene');
      expect(await servicio.bajarAhora(hashA), isNull);
    });
  });

  group('cliente HTTP', () {
    late HttpServer servidor;
    late ClienteSyncZunbeltz cliente;
    final recibidas = <String, (HttpHeaders, List<int>)>{};
    var respuestaRuta = 200;
    var sinRuta = false;
    Uint8List? fotoQueDevuelve;

    setUp(() async {
      recibidas.clear();
      respuestaRuta = 200;
      sinRuta = false;
      fotoQueDevuelve = null;
      servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      servidor.listen((peticion) async {
        final cuerpo = await peticion.fold<List<int>>(
            [], (acumulado, trozo) => acumulado..addAll(trozo));
        recibidas['${peticion.method} ${peticion.uri.pathSegments.last}'] =
            (peticion.headers, cuerpo);
        final respuesta = peticion.response;
        if (sinRuta) {
          respuesta.statusCode = 404;
          respuesta.write('{"code":"rest_no_route","message":"No route"}');
        } else if (peticion.method == 'GET' && fotoQueDevuelve != null) {
          respuesta.headers.contentType = ContentType('image', 'jpeg');
          respuesta.add(fotoQueDevuelve!);
        } else {
          respuesta.statusCode = respuestaRuta;
          respuesta.write('{"error":"foto_no_encontrada"}');
        }
        await respuesta.close();
      });
      cliente = ClienteSyncZunbeltz(
          urlBase: 'http://127.0.0.1:${servidor.port}',
          token: 'token-de-prueba');
    });
    tearDown(() => servidor.close(force: true));

    test('sube los bytes en crudo con su tipo, el token y accept', () async {
      final bytes = jpegDePrueba(20, 20);
      final hash = hashFoto(bytes);
      respuestaRuta = 201;
      expect(await cliente.subirFoto(hash, bytes), ResultadoSubidaFoto.subida);
      final (cabeceras, cuerpo) = recibidas['POST $hash']!;
      expect(cuerpo, bytes);
      expect(cabeceras.contentType?.mimeType, 'image/jpeg');
      expect(cabeceras.value('x-zunbeltz-token'), 'token-de-prueba');
      expect(cabeceras.value('accept'), 'application/json');

      respuestaRuta = 413;
      expect(await cliente.subirFoto(hash, bytes), ResultadoSubidaFoto.fallo);
      sinRuta = true;
      expect(await cliente.subirFoto(hash, bytes),
          ResultadoSubidaFoto.sinEndpoint);
      expect(await cliente.subirFoto(hash, utf8.encode('no es foto')),
          ResultadoSubidaFoto.fallo,
          reason: 'ni se intenta');
    });

    test('baja y comprueba el hash', () async {
      final bytes = jpegDePrueba(20, 20);
      final hash = hashFoto(bytes);
      fotoQueDevuelve = bytes;
      expect((await cliente.bajarFoto(hash)).bytes, bytes);
      expect((await cliente.bajarFoto(hashA)).bytes, isNull,
          reason: 'lo recibido no es la foto pedida');
      fotoQueDevuelve = null;
      respuestaRuta = 404;
      final noEsta = await cliente.bajarFoto(hash);
      expect((noEsta.bytes, noEsta.sinEndpoint), (null, false));
      sinRuta = true;
      expect((await cliente.bajarFoto(hash)).sinEndpoint, isTrue);
    });

    test('sin servidor no lanza', () async {
      await servidor.close(force: true);
      expect(
          await cliente.subirFoto(
              hashFoto(jpegDePrueba(4, 4)), jpegDePrueba(4, 4)),
          ResultadoSubidaFoto.fallo);
      expect((await cliente.bajarFoto(hashA)).bytes, isNull);
    });
  });

  test('de un móvil a otro: el punto y la tarea llevan hashes, no rutas',
      () async {
    final carpeta = await Directory.systemTemp.createTemp('szs-viaje-');
    addTearDown(() => carpeta.delete(recursive: true));
    final fotos = TransporteFalso();
    final entidadesServidor = <Map<String, Object?>>[];
    final tareasServidor = <Map<String, Object?>>[];
    MockClient servidorSync() => MockClient((peticion) async {
          final cuerpo = jsonDecode(peticion.body) as Map;
          for (final e in cuerpo['entidades'] as List) {
            entidadesServidor
              ..removeWhere((x) => x['uid'] == e['uid'])
              ..add({...Map<String, Object?>.from(e as Map), 'revision': 1});
          }
          for (final t in cuerpo['tareas'] as List) {
            tareasServidor
              ..removeWhere((x) => x['uid'] == t['uid'])
              ..add(Map<String, Object?>.from(t as Map));
          }
          return http.Response(
              jsonEncode({
                'entidades': entidadesServidor,
                'revision': 1,
                'tareas': tareasServidor,
                'completo': true,
                'yo': {'uid': 'coord', 'nombre': 'Pablo', 'rol': 'coordinador'},
                'personas': [],
              }),
              200,
              headers: {'content-type': 'application/json'});
        });
    Future<void> sincronizar(BaseDatosSoleraZunbeltz bd, String nombre) async {
      final servicio = ServicioFotosSync(
        bd: bd,
        transporte: fotos,
        directorioFotos: Directory('${carpeta.path}/$nombre'),
        reducir: (bytes) async => reducirFotoParaSubir(bytes, ladoMayor: 100),
      );
      await servicio.prepararFotosLocales();
      await http.runWithClient(
          () => ClienteSyncZunbeltz(urlBase: 'https://z.test', token: 't')
              .sincronizar(bd),
          servidorSync);
      await servicio.transferir();
    }

    final movilA = await abrirBdEnMemoria();
    final rutaA = '${carpeta.path}/cierre.jpg';
    await File(rutaA).writeAsBytes(jpegDePrueba(300, 200));
    final fincaA = await movilA.guardarFinca(Finca(nombre: 'Zufía'));
    await movilA.guardarPunto(PuntoInfraestructura(
        fincaId: fincaA,
        nombre: 'Cierre',
        rutasFotosJson: jsonEncode([rutaA])));
    await movilA.guardarTarea(TareaMantenimiento(
        fincaId: fincaA,
        titulo: 'Reparar',
        rutasFotosAntesJson: jsonEncode([rutaA])));
    await sincronizar(movilA, 'a');

    final hash = fotos.fotos.keys.single;
    final puntoEnServidor =
        entidadesServidor.firstWhere((e) => e['tipo'] == 'punto');
    expect((puntoEnServidor['datos'] as Map)['fotos'], [hash]);
    expect(jsonEncode(entidadesServidor), isNot(contains(carpeta.path)),
        reason: 'ninguna ruta del móvil llega al servidor');
    expect(tareasServidor.single['fotos_antes'], [hash]);
    expect(fotos.subidas, 1,
        reason: 'la misma foto en dos sitios sube una vez');

    final movilB = await abrirBdEnMemoria();
    await sincronizar(movilB, 'b');
    final puntoB = (await movilB.listarPuntos()).single;
    final rutaEnB = await movilB.rutaLocalDeFoto(hash);
    expect(rutaEnB, startsWith('${carpeta.path}/b/'));
    expect(jsonDecode(puntoB.rutasFotosJson), ['foto:$hash'],
        reason: 'se guarda la referencia y se ve por la tabla');
    final tareaB = (await movilB.listarTareas()).single;
    expect(jsonDecode(tareaB.rutasFotosAntesJson), ['foto:$hash']);

    // En A sigue viéndose el original y vuelve a subir igual.
    await sincronizar(movilA, 'a');
    final puntoA = (await movilA.listarPuntos()).single;
    expect(jsonDecode(puntoA.rutasFotosJson), [rutaA]);
  });
}
