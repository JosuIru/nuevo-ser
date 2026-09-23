// La pantalla del tiempo se dibuja a tamaño de móvil, con la respuesta real
// de Open-Meteo, sin desbordes, y muestra sus bloques; sin red y sin caché
// ofrece reintentar.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_meteo.dart';
import 'package:solera_zunbeltz/servicios/servicio_meteo.dart';

Widget _app(ServicioMeteo servicio, Locale idioma) => MaterialApp(
      locale: idioma,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PantallaMeteo(
        fincas: const [],
        servicio: servicio,
        // Momento en que se capturó la fixture.
        reloj: () => DateTime(2026, 9, 23, 11, 15),
      ),
    );

void main() {
  final respuestaReal =
      File('test/fixtures/open_meteo_zunbeltz.json').readAsStringSync();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final idioma in const [Locale('es'), Locale('eu')]) {
    testWidgets('Dibuja la previsión en móvil (${idioma.languageCode})',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      final servicio = ServicioMeteo(
          cliente: MockClient((_) async =>
              http.Response.bytes(utf8.encode(respuestaReal), 200)));
      await tester.pumpWidget(_app(servicio, idioma));
      await tester.pumpAndSettle();

      final textos = lookupAppLocalizations(idioma);
      expect(find.text(textos.meteoAhora), findsOneWidget);
      expect(find.text(textos.meteoProximasHoras), findsOneWidget);

      // Baja hasta los días y abre el primero: tampoco debe desbordar.
      await tester.scrollUntilVisible(find.text(textos.meteoDiasTitulo), 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      expect(find.text(textos.meteoThi), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Sin red ni caché ofrece reintentar', (tester) async {
    final servicio =
        ServicioMeteo(cliente: MockClient((_) async => http.Response('', 503)));
    await tester.pumpWidget(_app(servicio, const Locale('es')));
    await tester.pumpAndSettle();
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
