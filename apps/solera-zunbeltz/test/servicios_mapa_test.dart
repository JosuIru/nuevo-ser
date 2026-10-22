import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:solera_zunbeltz/servicios/servicio_buscador_mapa.dart';
import 'package:solera_zunbeltz/servicios/servicio_catastro_navarra.dart';
import 'package:solera_zunbeltz/utiles/geodesia.dart';

String _fixture(String nombre) =>
    File('test/fixtures/servicios_mapa/$nombre').readAsStringSync();

void main() {
  group('Catastro de Navarra (IDENA)', () {
    test('lee la parcela 24-2 de Yerri con su paraje y su superficie', () {
      final parcela =
          parcelasDesdeGeoJson(_fixture('idena_parcela_en_punto.json')).single;
      expect(parcela.poligono, 24);
      expect(parcela.parcela, 2);
      expect(parcela.subparcela, '');
      expect(parcela.nombrePropuesto, 'Zunbeltz');
      expect(parcela.referencia, 'Valle De Yerri / Deierri 24-2');
      expect(parcela.superficieM2 / 10000, closeTo(229.36, 0.01));
      expect(
          superficieHectareas(parcela.contornos.single), closeTo(229.36, 0.5));
    });

    test('en un punto: parcela y subparcela; la consulta lleva el punto',
        () async {
      final pedidas = <Uri>[];
      final servicio =
          ServicioCatastroNavarra(cliente: MockClient((peticion) async {
        pedidas.add(peticion.url);
        final capa = peticion.url.queryParameters['typeNames']!;
        return http.Response(
            _fixture(capa.contains('Subpar')
                ? 'idena_subparcela_en_punto.json'
                : 'idena_parcela_en_punto.json'),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }));
      final parcelas = await servicio.enPunto(const LatLng(42.8226, -2.0315));
      expect(parcelas.map((p) => p.subparcela), ['', 'B']);
      expect(pedidas.first.queryParameters['CQL_FILTER'],
          'INTERSECTS(the_geom,SRID=4326;POINT(-2.0315 42.8226))');
    });

    test(
        'por referencia: filtro por municipio sin mayúsculas, polígono y parcela',
        () async {
      String? filtro;
      final servicio =
          ServicioCatastroNavarra(cliente: MockClient((peticion) async {
        filtro ??= peticion.url.queryParameters['CQL_FILTER'];
        return http.Response(_fixture('idena_yerri_13_1.json'), 200);
      }));
      final parcelas = await servicio.porReferencia(
          municipio: 'Yerri', poligono: 13, parcela: 1, conSubparcelas: false);
      expect(parcelas.single.nombrePropuesto, 'La Planilla');
      expect(filtro,
          "strToLowerCase(MUNICIPIO) LIKE '%yerri%' AND POLIGONO=13 AND PARCELA=1");
    });

    test('sin conexión lanza ErrorCatastro', () async {
      final servicio = ServicioCatastroNavarra(
          cliente: MockClient((_) async => throw const SocketException('no')));
      expect(() => servicio.enPunto(const LatLng(42.8, -2.0)),
          throwsA(isA<ErrorCatastro>()));
    });
  });

  group('Buscador (CartoCiudad)', () {
    test('candidatos con y sin coordenadas', () {
      final lugares = lugaresDesdeCandidatos(
          _fixture('cartociudad_candidatos_lezaun.json'));
      expect(lugares.first.texto, contains('Lezaun'));
      expect(lugares.first.posicion, isNull, reason: 'viene a 0,0');
      final paraje = lugaresDesdeCandidatos(
              _fixture('cartociudad_candidatos_zunbeltz.json'))
          .single;
      expect(paraje.tipo, 'ngbe');
      expect(paraje.posicion!.latitude, closeTo(42.8179, 0.001));
    });

    test('find da la posición de un municipio', () {
      final posicion =
          posicionDesdeFind(_fixture('cartociudad_find_lezaun.json'));
      expect(posicion!.latitude, closeTo(42.7934, 0.001));
      expect(posicion.longitude, closeTo(-2.0074, 0.001));
    });

    test('posicionDe pide find con tipo e id', () async {
      Uri? pedida;
      final servicio =
          ServicioBuscadorMapa(cliente: MockClient((peticion) async {
        pedida = peticion.url;
        return http.Response(_fixture('cartociudad_find_lezaun.json'), 200);
      }));
      final posicion = await servicio.posicionDe(const LugarEncontrado(
          texto: 'Lezaun, Navarra', tipo: 'Municipio', id: '31154'));
      expect(posicion, isNotNull);
      expect(pedida!.path, endsWith('/find'));
      expect(pedida!.queryParameters['id'], '31154');
    });
  

    test('Nominatim: lee nombre y posición', () {
      final lugar =
          lugaresDesdeNominatim(_fixture('nominatim_lezaun.json')).first;
      expect(lugar.texto, contains('Lezáun'));
      expect(lugar.posicion!.latitude, closeTo(42.78, 0.05));
      expect(lugar.posicion!.longitude, closeTo(-2.0, 0.05));
    });

    test('si CartoCiudad corta la conexión, busca en Nominatim', () async {
      final pedidas = <String>[];
      final servicio =
          ServicioBuscadorMapa(cliente: MockClient((peticion) async {
        pedidas.add(peticion.url.host);
        if (peticion.url.host == 'www.cartociudad.es') {
          throw const SocketException('Connection reset by peer');
        }
        return http.Response.bytes(
            File('test/fixtures/servicios_mapa/nominatim_lezaun.json')
                .readAsBytesSync(),
            200);
      }));
      final lugares = await servicio.buscar('Lezaun');
      expect(pedidas, ['www.cartociudad.es', 'nominatim.openstreetmap.org']);
      expect(lugares.single.posicion, isNotNull);
    });

    test('si fallan los dos, lanza', () async {
      final servicio = ServicioBuscadorMapa(
          cliente: MockClient((_) async => throw const SocketException('no')));
      expect(servicio.buscar('Lezaun'), throwsA(isA<SocketException>()));
    });
  });
}
