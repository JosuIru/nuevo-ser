import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DiaMeteoAgro, PrevisionAgro;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solera_huerta/dominio/avisos_tiempo.dart';
import 'package:solera_huerta/estado/aviso_helada_programado.dart';
import 'package:solera_huerta/pantallas/tarjeta_tiempo.dart';
import 'package:solera_huerta/servicios/tiempo_huerta.dart';

class _ProgramadorDePrueba implements ProgramadorAvisos {
  bool permiso = true;
  final programados = <int, ({DateTime cuando, String cuerpo})>{};
  var cancelaciones = 0;

  @override
  Future<bool> pedirPermiso() async => permiso;

  @override
  Future<void> programar({
    required int id,
    required DateTime cuando,
    required String titulo,
    required String cuerpo,
  }) async =>
      programados[id] = (cuando: cuando, cuerpo: cuerpo);

  @override
  Future<void> cancelar(int id) async {
    cancelaciones++;
    programados.remove(id);
  }
}

void main() {
  setUpAll(() => initializeDateFormatting());
  final ahora = DateTime(2026, 4, 20, 18);
  const lugar = LatLng(42.8, -1.6);

  group('TiempoHuerta', () {
    test('guarda la previsión una hora por lugar', () async {
      var llamadas = 0;
      final tiempo = TiempoHuerta(
          obtener: ({required double latitud, required double longitud}) async {
        llamadas++;
        return PrevisionAgro(
          latitud: latitud,
          longitud: longitud,
          actualizado: ahora,
          dias: [
            DiaMeteoAgro(
                fecha: DateTime(2026, 4, 21),
                tempMin: -1,
                tempMax: 15,
                lluviaMm: 0),
          ],
        );
      });
      final primera = await tiempo.prevision(lugar, ahora: ahora);
      expect(primera!.single.minimaC, -1);
      await tiempo.prevision(lugar,
          ahora: ahora.add(const Duration(minutes: 59)));
      expect(llamadas, 1);
      await tiempo.prevision(lugar, ahora: ahora.add(const Duration(hours: 1)));
      expect(llamadas, 2);
    });

    test('sin red devuelve null', () async {
      final tiempo = TiempoHuerta(
          obtener: ({required double latitud, required double longitud}) =>
              Future.error(Exception('sin red')));
      expect(await tiempo.prevision(lugar, ahora: ahora), isNull);
    });
  });

  group('recordatorio de helada', () {
    late _ProgramadorDePrueba programador;
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      programador = _ProgramadorDePrueba();
      programadorAvisosHuerta = programador;
      avisarHeladas.value = false;
    });
    tearDown(() => programadorAvisosHuerta = const ProgramadorAvisosNulo());

    AvisoHeladaHuerta helada(List<String> sensibles) => AvisoHeladaHuerta(
        fecha: DateTime(2026, 4, 22),
        minimaC: -2,
        diasDesdeHoy: 2,
        cultivosSensibles: sensibles);

    Future<DateTime?> reprogramar(AvisoHeladaHuerta? aviso) =>
        reprogramarAvisoHelada(
            helada: aviso,
            titulo: (_) => 'Helada',
            cuerpo: (h) => h.cultivosSensibles.join(', '),
            ahora: ahora);

    test('apagado: solo cancela', () async {
      expect(await reprogramar(helada(['Tomate'])), isNull);
      expect(programador.programados, isEmpty);
      expect(programador.cancelaciones, 1);
    });

    test('encendido: víspera a las 20:00 con id estable, y se reemplaza',
        () async {
      expect(await cambiarAvisarHeladas(true), isTrue);
      expect(await reprogramar(helada(['Tomate'])), DateTime(2026, 4, 21, 20));
      await reprogramar(helada(['Tomate', 'Pimiento']));
      expect(programador.programados.keys, [idAvisoHeladaHuerta]);
      expect(programador.programados[idAvisoHeladaHuerta]!.cuerpo,
          'Tomate, Pimiento');
      // Ya no hay helada: se quita.
      await reprogramar(null);
      expect(programador.programados, isEmpty);
    });

    test('sin nada sensible no se avisa', () async {
      await cambiarAvisarHeladas(true);
      expect(await reprogramar(helada(const [])), isNull);
    });

    test('sin permiso queda apagado', () async {
      programador.permiso = false;
      expect(await cambiarAvisarHeladas(true), isFalse);
      expect(avisarHeladas.value, isFalse);
    });
  });

  group('TarjetaTiempo', () {
    Future<void> pintar(WidgetTester tester, EstadoTiempoHoy estado) =>
        tester.pumpWidget(
            MaterialApp(home: Scaffold(body: TarjetaTiempo(estado: estado))));

    testWidgets('sin avisos no ocupa sitio', (tester) async {
      await pintar(tester, EstadoTiempoHoy.nada);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('sin ubicación, una línea discreta', (tester) async {
      await pintar(tester, const EstadoTiempoHoy(sinUbicacion: true));
      expect(
          find.byKey(const ValueKey('tiempo-sin-ubicacion')), findsOneWidget);
    });

    testWidgets('helada, calor y riego con la fuente', (tester) async {
      await pintar(
          tester,
          EstadoTiempoHoy(
              avisos: AvisosTiempoHuerta(
            helada: AvisoHeladaHuerta(
                fecha: DateTime(2026, 4, 21),
                minimaC: -2,
                diasDesdeHoy: 1,
                cultivosSensibles: const ['Tomate']),
            calor: AvisoCalorHuerta(
                fecha: DateTime(2026, 4, 25), maximaC: 37, esOla: true),
            diasSinLluvia: 6,
          )));
      expect(find.byKey(const ValueKey('tarjeta-tiempo')), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
      expect(find.textContaining('Tomate'), findsOneWidget);
      expect(find.textContaining('Open-Meteo'), findsOneWidget);
    });
  });
}
