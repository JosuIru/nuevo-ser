// Mapa sin cobertura: cuentas de teselas, cola de descarga y caché en disco
// (con un cliente HTTP falso: nada sale a la red).

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:solera_zunbeltz/servicios/cache_teselas.dart';
import 'package:solera_zunbeltz/servicios/mapa_sin_cobertura.dart';
import 'package:solera_zunbeltz/servicios/proveedor_teselas_cacheadas.dart';
import 'package:solera_zunbeltz/utiles/cola_descarga_teselas.dart';
import 'package:solera_zunbeltz/utiles/teselas_mapa.dart';

import 'bd_en_memoria.dart';

const centroZunbeltz = LatLng(42.8226, -2.0315);
const centroPlanilla = LatLng(42.7707, -2.0144);

/// Un JPEG mínimo (para el validador basta la cabecera) distinto por [marca].
Uint8List jpegFalso(int marca, {int relleno = 16}) => Uint8List.fromList(
    [0xFF, 0xD8, 0xFF, 0xE0, marca, ...List.filled(relleno, marca), 0xFF]);

void main() {
  group('teselas de un rectángulo', () {
    test('Zunbeltz y La Planilla caen en las teselas conocidas', () {
      // Comprobado con la fórmula de OSM (y, para el z17 de Zunbeltz,
      // pidiéndosela al WMTS del IGN).
      const casosZunbeltz = {
        12: (2024, 1507),
        15: (16199, 12062),
        17: (64796, 48250),
        19: (259185, 193002),
      };
      const casosPlanilla = {
        12: (2025, 1508),
        15: (16200, 12069),
        17: (64802, 48276),
        19: (259210, 193105),
      };
      for (final MapEntry(key: z, value: (x, y)) in casosZunbeltz.entries) {
        expect(columnaTesela(centroZunbeltz.longitude, z), x, reason: 'z$z');
        expect(filaTesela(centroZunbeltz.latitude, z), y, reason: 'z$z');
      }
      for (final MapEntry(key: z, value: (x, y)) in casosPlanilla.entries) {
        expect(columnaTesela(centroPlanilla.longitude, z), x, reason: 'z$z');
        expect(filaTesela(centroPlanilla.latitude, z), y, reason: 'z$z');
      }
    });

    test('un rectángulo de un punto es una tesela por zoom', () {
      final punto = RectanguloGeo.envolvente([centroZunbeltz]);
      for (var z = 12; z <= 19; z++) {
        expect(punto.contarTeselas(z), 1);
        expect(punto.teselas(z).single,
            TeselaXYZ(z, columnaTesela(-2.0315, z), filaTesela(42.8226, z)));
      }
    });

    test('ampliar 400 m por lado: unas 800 m más de ancho y de alto', () {
      final ampliado = RectanguloGeo.envolvente([centroZunbeltz]).ampliado(400);
      // 1° de latitud ≈ 111,2 km; 1° de longitud a 42,8° ≈ 81,6 km.
      expect((ampliado.norte - ampliado.sur) * 111195, closeTo(800, 1));
      expect((ampliado.este - ampliado.oeste) * 81600, closeTo(800, 5));
      // A z19 una tesela mide ~56 m aquí: unas 15 × 15.
      expect(ampliado.contarTeselas(19), inInclusiveRange(14 * 14, 16 * 16));
      expect(ampliado.teselas(19).length, ampliado.contarTeselas(19));
    });

    test('las teselas compartidas por dos rectángulos no se repiten', () {
      final a = RectanguloGeo.envolvente([centroZunbeltz]).ampliado(300);
      final teselas = teselasDeRectangulos([a, a]);
      expect(teselas.toSet().length, teselas.length);
      var porZoom = 0;
      for (var z = 12; z <= 19; z++) {
        porZoom += a.contarTeselas(z);
      }
      expect(teselas, hasLength(porZoom));
      // De menos a más zoom.
      expect(teselas.first.z, 12);
      expect(teselas.last.z, 19);
    });

    test('finca sin dibujo: cuadrado de su superficie alrededor del centro',
        () {
      final rectangulos = rectangulosDeFincas([
        const FincaParaDescarga(
            nombre: 'Cuadrada', centro: centroZunbeltz, superficieHa: 100),
        const FincaParaDescarga(nombre: 'Sin sitio'),
      ], margenMetros: 0);
      expect(rectangulos, hasLength(1));
      // 100 ha = 1 km × 1 km.
      final alto = (rectangulos.single.norte - rectangulos.single.sur) * 111195;
      expect(alto, closeTo(1000, 2));
    });

    test('las fincas reales: un rectángulo por finca, unos 100 MB', () async {
      final bd = await abrirBdEnMemoria();
      await bd.sembrarEspacioRealSiVacia();
      final fincas = fincasParaDescarga(await bd.listarFincas(),
          await bd.listarZonas(), await bd.listarPuntos());
      expect(fincas.map((f) => f.nombre),
          containsAll(['Zunbeltz', 'La Planilla']));
      final rectangulos = rectangulosDeFincas(fincas);
      expect(rectangulos, hasLength(fincas.length));
      bool contiene(RectanguloGeo r, LatLng p) =>
          p.latitude >= r.sur &&
          p.latitude <= r.norte &&
          p.longitude >= r.oeste &&
          p.longitude <= r.este;
      expect(
          rectangulos.where((r) => contiene(r, centroZunbeltz)), hasLength(1));
      expect(
          rectangulos.where((r) => contiene(r, centroPlanilla)), hasLength(1));

      final teselas = teselasDeRectangulos(rectangulos);
      final megas = megabytesHaciaArriba(estimarBytesTeselas(teselas.length));
      // ignore: avoid_print
      print('Fincas reales: ${teselas.length} teselas (z12-19), '
          '~$megas MB; por finca: ${[
        for (var i = 0; i < fincas.length; i++)
          '${fincas[i].nombre} ${teselasDeRectangulos([rectangulos[i]]).length}'
      ].join(', ')}');
      expect(teselas.length, inInclusiveRange(2000, 15000));
      expect(megas, lessThan(topeBytesCacheVista ~/ (1024 * 1024)));

      // Un único rectángulo que abarcara las dos saldría bastante más caro.
      final todo = RectanguloGeo.envolvente([
        for (final r in rectangulos) ...[
          LatLng(r.sur, r.oeste),
          LatLng(r.norte, r.este),
        ]
      ]);
      expect(teselasDeRectangulos([todo]).length,
          greaterThan(teselas.length * 1.5));
    });

    test('estimación de tamaño', () {
      expect(estimarBytesTeselas(0), 0);
      expect(estimarBytesTeselas(1000), 1000 * bytesMedioTeselaPnoa);
      expect(megabytesHaciaArriba(0), 0);
      expect(megabytesHaciaArriba(1), 1);
      expect(megabytesHaciaArriba(1024 * 1024), 1);
      expect(megabytesHaciaArriba(1024 * 1024 + 1), 2);
      expect(tamanoLegible(500 * 1024), '500 KB');
      expect(tamanoLegible((12.4 * 1024 * 1024).round()), '12,4 MB');
      expect(tamanoLegible(topeBytesCacheVista), '200 MB');
    });
  });

  group('cola de descarga', () {
    List<TeselaXYZ> teselas(int n) =>
        [for (var i = 0; i < n; i++) TeselaXYZ(19, i, 0)];

    test('no pasa de la concurrencia pedida y las baja todas', () async {
      var enVuelo = 0, maximo = 0;
      final cola = ColaDescargaTeselas(
        teselas: teselas(30),
        concurrencia: 4,
        descargar: (_) async {
          enVuelo++;
          maximo = enVuelo > maximo ? enVuelo : maximo;
          await Future<void>.delayed(const Duration(milliseconds: 2));
          enVuelo--;
          return ResultadoIntentoTesela.hecha;
        },
      );
      expect(await cola.ejecutar(), FinDescargaTeselas.completada);
      expect(maximo, 4);
      expect(cola.progreso.hechas, 30);
      expect(cola.progreso.fraccion, 1);
    });

    test('reintenta lo pasajero con esperas crecientes; lo definitivo no',
        () async {
      final esperas = <Duration>[];
      final intentos = <TeselaXYZ, int>{};
      final cola = ColaDescargaTeselas(
        teselas: teselas(3),
        concurrencia: 1,
        dormir: (espera) async => esperas.add(espera),
        descargar: (tesela) async {
          final n = intentos[tesela] = (intentos[tesela] ?? 0) + 1;
          return switch (tesela.x) {
            0 => n < 3
                ? ResultadoIntentoTesela.reintentable
                : ResultadoIntentoTesela.hecha,
            1 => ResultadoIntentoTesela.definitivo,
            _ => throw const SocketException('sin red'),
          };
        },
      );
      expect(await cola.ejecutar(), FinDescargaTeselas.completada);
      expect(intentos[const TeselaXYZ(19, 0, 0)], 3);
      expect(intentos[const TeselaXYZ(19, 1, 0)], 1);
      // Un fallo imprevisto cuenta como pasajero, pero con tope.
      expect(intentos[const TeselaXYZ(19, 2, 0)], 4);
      expect(cola.progreso.hechas, 1);
      expect(cola.progreso.fallidas, 2);
      expect(esperas, const [
        Duration(seconds: 2), Duration(seconds: 8), // tesela 0
        Duration(seconds: 2), Duration(seconds: 8), Duration(seconds: 30),
      ]);
    });

    test('cancelar corta también la espera de un reintento', () async {
      final esperaLarga = Completer<void>();
      var llamadas = 0;
      final cola = ColaDescargaTeselas(
        teselas: teselas(50),
        concurrencia: 2,
        dormir: (_) => esperaLarga.future, // no termina nunca sola
        descargar: (_) async {
          llamadas++;
          return ResultadoIntentoTesela.reintentable;
        },
      );
      final fin = cola.ejecutar();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      cola.cancelar();
      expect(await fin, FinDescargaTeselas.cancelada);
      // Las dos en vuelo se quedan sin contar (se bajarán al reanudar).
      expect(llamadas, 2);
      expect(cola.progreso.intentadas, 0);
    });

    test('demasiados fallos seguidos: para en vez de martillear', () async {
      var llamadas = 0;
      final cola = ColaDescargaTeselas(
        teselas: teselas(100),
        concurrencia: 1,
        maxFallosSeguidos: 5,
        maxIntentos: 2,
        dormir: (_) async {},
        descargar: (_) async {
          llamadas++;
          return ResultadoIntentoTesela.reintentable;
        },
      );
      expect(await cola.ejecutar(), FinDescargaTeselas.demasiadosFallos);
      expect(cola.progreso.fallidas, 5);
      expect(llamadas, 10);
    });

    test('sin wifi a mitad: para', () async {
      var wifi = true;
      final cola = ColaDescargaTeselas(
        teselas: teselas(20),
        concurrencia: 1,
        puedeSeguir: () async => wifi,
        descargar: (tesela) async {
          if (tesela.x == 4) wifi = false;
          return ResultadoIntentoTesela.hecha;
        },
      );
      expect(await cola.ejecutar(), FinDescargaTeselas.sinWifi);
      expect(cola.progreso.hechas, 5);
    });
  });

  group('caché en disco', () {
    late Directory carpeta;
    late DateTime ahora;
    setUp(() async {
      carpeta = await Directory.systemTemp.createTemp('teselas_test_');
      ahora = DateTime(2026, 10, 24, 12);
    });
    tearDown(() async {
      if (await carpeta.exists()) await carpeta.delete(recursive: true);
    });

    AlmacenTeselas almacen({int tope = topeBytesCacheVista}) => AlmacenTeselas(
          () async => carpeta,
          topeBytesVista: tope,
          reloj: () => ahora,
        );

    const tesela = TeselaXYZ(17, 64796, 48250);
    const peticion = PeticionTesela(
      capa: 'pnoa',
      tesela: tesela,
      url: 'https://ign.test/17/64796/48250',
      capaRespaldo: 'esri',
      urlRespaldo: 'https://esri.test/17/48250/64796',
    );

    test('con red: la baja, la guarda y la siguiente vez no pide nada',
        () async {
      final pedidas = <String>[];
      final obtenedor = ObtenedorTeselas(
        almacen: almacen(),
        hayConexion: () async => true,
        cliente: MockClient((peticionHttp) async {
          pedidas.add(peticionHttp.url.toString());
          expect(peticionHttp.headers['User-Agent'], 'prueba');
          return http.Response.bytes(jpegFalso(1), 200);
        }),
      );
      const conCabecera = PeticionTesela(
          capa: 'pnoa',
          tesela: tesela,
          url: 'https://ign.test/a',
          cabeceras: {'User-Agent': 'prueba'});
      expect(await obtenedor.obtener(conCabecera), jpegFalso(1));
      expect(await obtenedor.obtener(conCabecera), jpegFalso(1));
      expect(pedidas, ['https://ign.test/a']);
    });

    test('sin red: sirve de caché sin llamar a la red, aunque esté caducada',
        () async {
      final disco = almacen();
      await disco.guardar('pnoa', tesela, jpegFalso(7));
      ahora = ahora.add(const Duration(days: 400));
      var llamadas = 0;
      final obtenedor = ObtenedorTeselas(
        almacen: disco,
        hayConexion: () async => false,
        cliente: MockClient((_) async {
          llamadas++;
          return http.Response('', 500);
        }),
      );
      expect(await obtenedor.obtener(peticion), jpegFalso(7));
      expect(llamadas, 0);
    });

    test('sin red y sin guardar: falla al momento, sin probar el respaldo',
        () async {
      var llamadas = 0;
      final obtenedor = ObtenedorTeselas(
        almacen: almacen(),
        hayConexion: () async => false,
        cliente: MockClient((_) async {
          llamadas++;
          return http.Response.bytes(jpegFalso(1), 200);
        }),
      );
      final reloj = Stopwatch()..start();
      await expectLater(
          obtenedor.obtener(peticion), throwsA(isA<TeselaNoDisponible>()));
      expect(reloj.elapsed, lessThan(const Duration(seconds: 1)));
      expect(llamadas, 0);
    });

    test('sin red: si solo está la del respaldo, sirve esa', () async {
      final disco = almacen();
      await disco.guardar('esri', tesela, jpegFalso(3));
      final obtenedor = ObtenedorTeselas(
        almacen: disco,
        hayConexion: () async => false,
        cliente: MockClient((_) async => http.Response('', 500)),
      );
      expect(await obtenedor.obtener(peticion), jpegFalso(3));
    });

    test('caducada y con red: se renueva; si el servidor falla, la vieja',
        () async {
      final disco = almacen();
      await disco.guardar('pnoa', tesela, jpegFalso(1));
      ahora = ahora.add(caducidadTeselas + const Duration(days: 1));
      var responde = true;
      final pedidas = <String>[];
      final obtenedor = ObtenedorTeselas(
        almacen: disco,
        hayConexion: () async => true,
        cliente: MockClient((p) async {
          pedidas.add(p.url.host);
          return responde
              ? http.Response.bytes(jpegFalso(2), 200)
              : http.Response('caído', 503);
        }),
      );
      expect(await obtenedor.obtener(peticion), jpegFalso(2));
      ahora = ahora.add(caducidadTeselas + const Duration(days: 1));
      responde = false;
      // Mejor la ortofoto vieja que otra imagen: no se pide a Esri.
      expect(await obtenedor.obtener(peticion), jpegFalso(2));
      expect(pedidas, ['ign.test', 'ign.test']);
    });

    test('el IGN falla: respaldo una vez; tras 3 fallos, directo al respaldo',
        () async {
      final pedidas = <String>[];
      final obtenedor = ObtenedorTeselas(
        almacen: almacen(),
        hayConexion: () async => true,
        reloj: () => ahora,
        cliente: MockClient((p) async {
          pedidas.add(p.url.host);
          return p.url.host == 'ign.test'
              ? http.Response('<html>error</html>', 200) // no es imagen
              : http.Response.bytes(jpegFalso(9), 200);
        }),
      );
      for (var x = 0; x < 5; x++) {
        final p = PeticionTesela(
          capa: 'pnoa',
          tesela: TeselaXYZ(17, x, 0),
          url: 'https://ign.test/$x',
          capaRespaldo: 'esri',
          urlRespaldo: 'https://esri.test/$x',
        );
        expect(await obtenedor.obtener(p), jpegFalso(9));
      }
      expect(pedidas, [
        'ign.test', 'esri.test', //
        'ign.test', 'esri.test',
        'ign.test', 'esri.test',
        'esri.test', 'esri.test', // capa dada por caída
      ]);
      // Lo de Esri se guarda en su carpeta, no como si fuera el PNOA.
      expect(await almacen().leer('pnoa', const TeselaXYZ(17, 0, 0)), isNull);
      expect(
          await almacen().leer('esri', const TeselaXYZ(17, 0, 0)), isNotNull);
    });

    test(
        'corte de red (el sistema dice que hay, pero no llega): '
        'las siguientes salen de caché sin esperar', () async {
      final disco = almacen();
      await disco.guardar('osm', const TeselaXYZ(15, 1, 1), jpegFalso(5));
      var llamadas = 0;
      final obtenedor = ObtenedorTeselas(
        almacen: disco,
        hayConexion: () async => true,
        reloj: () => ahora,
        cliente: MockClient((_) async {
          llamadas++;
          throw const SocketException('Network is unreachable');
        }),
      );
      PeticionTesela osm(int x) => PeticionTesela(
          capa: 'osm', tesela: TeselaXYZ(15, x, 1), url: 'https://osm.test/$x');
      await expectLater(
          obtenedor.obtener(osm(0)), throwsA(isA<TeselaNoDisponible>()));
      expect(obtenedor.redCortada, isTrue);
      // Caducada para obligarla a ir a la red si pudiera.
      await File('${carpeta.path}/vista/osm/15/1/1')
          .setLastModified(DateTime(2020));
      expect(await obtenedor.obtener(osm(1)), jpegFalso(5));
      await expectLater(
          obtenedor.obtener(osm(2)), throwsA(isA<TeselaNoDisponible>()));
      expect(llamadas, 1);
      obtenedor.olvidarCortes(); // vuelve la red
      expect(obtenedor.redCortada, isFalse);
    });

    test('tope: se expulsa lo más antiguo de lo visto, nunca lo descargado',
        () async {
      final disco = almacen(tope: 1000);
      final bytes = jpegFalso(1, relleno: 300); // ~307 bytes
      await disco.guardar('pnoa', const TeselaXYZ(19, 0, 0), bytes,
          descargada: true);
      for (var x = 0; x < 6; x++) {
        final t = TeselaXYZ(19, x, 1);
        await disco.guardar('pnoa', t, bytes);
        // Fechas distintas para saber cuál es la más antigua.
        final ruta = '${carpeta.path}/vista/pnoa/19/$x/1';
        await File(ruta).setLastModified(DateTime(2026, 1, 1 + x));
      }
      final tamano = await disco.tamano();
      expect(tamano.bytesVista, lessThanOrEqualTo(1000));
      expect(tamano.teselasDescargadas, 1);
      // Las últimas siguen; las primeras se fueron.
      expect(await disco.leer('pnoa', const TeselaXYZ(19, 5, 1)), isNotNull);
      expect(await disco.leer('pnoa', const TeselaXYZ(19, 0, 1)), isNull);
      expect(await disco.leer('pnoa', const TeselaXYZ(19, 0, 0)), isNotNull);
    });

    test('bajar a propósito: a «descargadas», y quita la copia de lo visto',
        () async {
      final disco = almacen();
      await disco.guardar('pnoa', tesela, jpegFalso(1));
      final estados = [200, 404, 503, 429];
      var i = 0;
      final obtenedor = ObtenedorTeselas(
        almacen: disco,
        hayConexion: () async => true,
        cliente: MockClient((_) async {
          final estado = estados[i++];
          return estado == 200
              ? http.Response.bytes(jpegFalso(2), 200)
              : http.Response('', estado);
        }),
      );
      expect(await obtenedor.bajarYGuardar('pnoa', tesela, 'https://ign.test'),
          ResultadoIntentoTesela.hecha);
      expect(await disco.tieneDescargadaVigente('pnoa', tesela), isTrue);
      final tamano = await disco.tamano();
      expect(tamano.teselasVista, 0);
      expect(tamano.teselasDescargadas, 1);
      expect((await disco.leer('pnoa', tesela))!.descargada, isTrue);
      expect(await obtenedor.bajarYGuardar('pnoa', tesela, 'https://ign.test'),
          ResultadoIntentoTesela.definitivo);
      expect(await obtenedor.bajarYGuardar('pnoa', tesela, 'https://ign.test'),
          ResultadoIntentoTesela.reintentable);
      expect(await obtenedor.bajarYGuardar('pnoa', tesela, 'https://ign.test'),
          ResultadoIntentoTesela.reintentable);

      // Caducada: la descarga la vuelve a pedir.
      ahora = ahora.add(caducidadTeselas + const Duration(days: 1));
      expect(await disco.tieneDescargadaVigente('pnoa', tesela), isFalse);
      await disco.borrarDescargadas();
      expect((await disco.tamano()).teselasDescargadas, 0);
    });

    test('el gestor reanuda: solo planifica lo que falta y lo baja', () async {
      final disco = almacen();
      final pedidas = <String>[];
      final obtenedor = ObtenedorTeselas(
        almacen: disco,
        hayConexion: () async => true,
        cliente: MockClient((p) async {
          pedidas.add(p.url.toString());
          return http.Response.bytes(jpegFalso(4), 200);
        }),
      );
      final gestor = GestorDescargaMapa(
        almacen: disco,
        obtenedor: obtenedor,
        hayWifi: () async => true,
      );
      const finca = [
        FincaParaDescarga(nombre: 'Prueba', centro: centroZunbeltz)
      ];
      final plan = await gestor.planificar(finca);
      expect(plan.nombresFincas, ['Prueba']);
      // Se baja una parte «a mano», como si se hubiera cortado.
      for (final t in plan.pendientes.take(10)) {
        await disco.guardar('pnoa', t, jpegFalso(4), descargada: true);
      }
      final replan = await gestor.planificar(finca);
      expect(replan.totalTeselas, plan.totalTeselas);
      expect(replan.yaDescargadas, 10);
      expect(await gestor.iniciar(replan), FinDescargaTeselas.completada);
      expect(pedidas, hasLength(plan.totalTeselas - 10));
      expect(pedidas.first, contains('ign.es/wmts/pnoa-ma'));
      expect((await gestor.planificar(finca)).nadaQueBajar, isTrue);
    });
  });

  test('el TileProvider pide al obtenedor la tesela y su respaldo', () {
    final obtenedor = ObtenedorTeselas(
      almacen: AlmacenTeselas(() async => Directory.systemTemp),
      hayConexion: () async => false,
      cliente: MockClient((_) async => http.Response('', 500)),
    );
    final proveedor = ProveedorTeselasCacheadas(
        obtenedor: obtenedor, capa: capaPnoa, capaRespaldo: capaEsri);
    final capa = TileLayer(
      urlTemplate: urlOrtofotoPnoa,
      fallbackUrl: urlOrtofotoEsri,
      tileProvider: proveedor,
      userAgentPackageName: paqueteAgenteUsuario,
    );
    final imagen = proveedor.getImage(TileCoordinates(64796, 48250, 17), capa)
        as ImagenTeselaCacheada;
    expect(imagen.peticion.tesela, tesela17);
    expect(imagen.peticion.url, urlDeTesela(urlOrtofotoPnoa, tesela17));
    expect(imagen.peticion.url, contains('TileMatrix=17&TileRow=48250'));
    expect(imagen.peticion.urlRespaldo, endsWith('/tile/17/48250/64796'));
    expect(imagen.peticion.capaRespaldo, capaEsri);
    expect(imagen.peticion.cabeceras['User-Agent'],
        contains(paqueteAgenteUsuario));

    final sinRespaldo =
        ProveedorTeselasCacheadas(obtenedor: obtenedor, capa: capaOsm).getImage(
            TileCoordinates(1, 2, 3),
            TileLayer(urlTemplate: urlCallejeroOsm)) as ImagenTeselaCacheada;
    expect(sinRespaldo.peticion.urlRespaldo, isNull);
    expect(
        sinRespaldo.peticion.url, 'https://tile.openstreetmap.org/3/1/2.png');
  });
}

const tesela17 = TeselaXYZ(17, 64796, 48250);
