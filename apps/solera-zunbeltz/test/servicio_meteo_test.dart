// Previsión meteo: lectura de la respuesta real de Open-Meteo (fixture
// capturada sobre Zunbeltz), avisos, THI y caché sin conexión.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solera_zunbeltz/servicios/servicio_meteo.dart';
import 'package:solera_zunbeltz/utiles/descripcion_tiempo.dart';

void main() {
  final respuestaReal =
      File('test/fixtures/open_meteo_zunbeltz.json').readAsStringSync();
  // La fixture se capturó el 2026-09-23 a las 11:15 (hora local).
  final momentoCaptura = DateTime(2026, 9, 23, 11, 15);

  PrevisionMeteo leer() => PrevisionMeteo.desdeJson(
      jsonDecode(respuestaReal) as Map<String, dynamic>,
      actualizado: momentoCaptura);

  group('Lectura de la respuesta', () {
    test('separa días pasados y futuros', () {
      final prevision = leer();
      expect(prevision.todosLosDias, hasLength(14));
      final futuros = prevision.diasDesde(momentoCaptura);
      expect(futuros, hasLength(7));
      expect(futuros.first.fecha, DateTime(2026, 9, 23));
    });

    test('condiciones actuales, altitud y amanecer', () {
      final prevision = leer();
      expect(prevision.actual?.temperatura, 19.6);
      expect(prevision.actual?.direccionVientoGrados, 135);
      expect(prevision.altitudM, 1028);
      final hoy = prevision.diasDesde(momentoCaptura).first;
      expect(hoy.amanecer, DateTime(2026, 9, 23, 7, 56));
      expect(hoy.horasDeLuz, const Duration(hours: 12, minutes: 7));
      expect(hoy.thiMax, isNotNull);
    });

    test('próximas horas empiezan en la hora en curso', () {
      final horas = leer().proximasHoras(momentoCaptura);
      expect(horas, hasLength(24));
      expect(horas.first.hora, DateTime(2026, 9, 23, 11));
    });

    test('lluvia de los días anteriores y balance previsto', () {
      final prevision = leer();
      expect(prevision.lluviaDiasAnteriores(momentoCaptura), 0);
      expect(prevision.evapotranspiracionPrevista(momentoCaptura),
          greaterThan(0));
    });
  });

  group('Avisos', () {
    test('tormenta, nieve y estrés por calor', () {
      final tormentoso = DiaMeteo(
          fecha: DateTime(2026, 7, 1), codigoTiempo: 95, tempMax: 20);
      expect(tormentoso.tormenta, isTrue);
      expect(tormentoso.buenDiaManejo, isFalse);

      final nevado =
          DiaMeteo(fecha: DateTime(2026, 1, 1), nieveCm: 2, tempMax: 6);
      expect(nevado.nieve, isTrue);
      expect(nevado.buenDiaManejo, isFalse);

      final caluroso = DiaMeteo(fecha: DateTime(2026, 7, 1), thiMax: 76, tempMax: 28);
      expect(caluroso.buenDiaManejo, isFalse);
      expect(caluroso.estresCalor, isTrue);
    });

    test('THI de la fórmula NRC', () {
      // 30 °C y 50 %: 86 − (0,55 − 0,275) × (54 − 26) = 78,3.
      expect(indiceTemperaturaHumedad(30, 50), closeTo(78.3, 0.001));
      expect(indiceTemperaturaHumedad(15, 60), lessThan(umbralThiEstresCalor));
      expect(umbralThiEstresCalor, 75);
    });
  });

  group('Descripciones', () {
    test('códigos WMO y dirección del viento', () {
      expect(descripcionTiempo(0, 'es'), 'Despejado');
      expect(descripcionTiempo(95, 'eu'), 'Ekaitza');
      expect(familiaTiempo(81), FamiliaTiempo.lluvia);
      expect(familiaTiempo(73), FamiliaTiempo.nieve);
      expect(direccionViento(135, 'es'), 'SE');
      expect(direccionViento(350, 'es'), 'N');
      expect(direccionViento(300, 'eu'), 'IM');
    });
  });

  group('Caché sin conexión', () {
    test('sin red devuelve la última previsión guardada', () async {
      SharedPreferences.setMockInitialValues({});
      final conRed = ServicioMeteo(
          cliente: MockClient((_) async => http.Response.bytes(
              utf8.encode(respuestaReal), 200)));
      final primero = await conRed.obtener(latitud: 42.793, longitud: -1.958);
      expect(primero.desdeCache, isFalse);

      final sinRed = ServicioMeteo(
          cliente: MockClient((_) async => throw const SocketException('x')));
      final segundo = await sinRed.obtener(latitud: 42.793, longitud: -1.958);
      expect(segundo.desdeCache, isTrue);
      expect(segundo.prevision.actual?.temperatura, 19.6);
    });

    test('sin red ni caché lanza MeteoException', () async {
      SharedPreferences.setMockInitialValues({});
      final sinRed = ServicioMeteo(
          cliente: MockClient((_) async => http.Response('', 500)));
      expect(sinRed.obtener(latitud: 1, longitud: 1),
          throwsA(isA<MeteoException>()));
    });
  });
}
