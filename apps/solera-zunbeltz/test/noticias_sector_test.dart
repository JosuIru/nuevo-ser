import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/noticia_sector.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_noticias_sector.dart';
import 'package:solera_zunbeltz/servicios/servicio_noticias_sector.dart';

Map<String, Object?> _noticia(int id, {String enlace = 'https://uagn.es/a'}) => {
      'id': id,
      'titulo': 'Noticia $id',
      'entradilla': 'Entradilla',
      'enlace': enlace,
      'fecha_ms': 1000 * id,
      'fuente': 'UAGN',
      'idioma': 'es',
      'fijada': id == 1,
    };

void main() {
  group('NoticiaSector.desdeJson', () {
    test('lee todos los campos y vuelve igual con aJson', () {
      final noticia = NoticiaSector.desdeJson(_noticia(1))!;
      expect(noticia.titulo, 'Noticia 1');
      expect(noticia.fuente, 'UAGN');
      expect(noticia.fijada, isTrue);
      expect(noticia.aJson(), _noticia(1));
    });

    test('descarta enlaces que no son web y noticias sin título', () {
      expect(NoticiaSector.desdeJson(_noticia(2, enlace: 'javascript:alert(1)')),
          isNull);
      expect(NoticiaSector.desdeJson({..._noticia(3), 'titulo': ''}), isNull);
      expect(NoticiaSector.desdeJson({'titulo': 'Sin enlace'}), isNull);
    });
  });

  group('ServicioNoticiasSector', () {
    late List<http.Request> peticiones;
    late http.Response Function() responder;

    ServicioNoticiasSector servicio() => ServicioNoticiasSector(
          cliente: MockClient((peticion) async {
            peticiones.add(peticion);
            return responder();
          }),
        );

    setUp(() {
      peticiones = [];
      responder = () => http.Response(
          jsonEncode({
            'noticias': [_noticia(1), _noticia(2), 'basura'],
          }),
          200);
      SharedPreferences.setMockInitialValues({
        'zunbeltz.sync_url': 'https://app.zunbeltz.com/',
        'zunbeltz.sync_token': 'token-ane',
      });
    });

    test('baja las noticias con el token y las guarda para sin cobertura',
        () async {
      final resultado = await servicio().actualizar();
      expect(resultado.noticias.map((noticia) => noticia.id), [1, 2]);
      expect(peticiones.single.url.toString(),
          'https://app.zunbeltz.com/wp-json/solera-zunbeltz/v1/noticias');
      expect(peticiones.single.headers['X-Zunbeltz-Token'], 'token-ane');

      final guardadas = await servicio().cargarGuardadas();
      expect(guardadas.noticias.map((noticia) => noticia.titulo),
          ['Noticia 1', 'Noticia 2']);
      expect(guardadas.actualizadoMs, greaterThan(0));
      expect(ServicioNoticiasSector.actuales.value.noticias, hasLength(2));
    });

    test('no vuelve a preguntar antes de media hora salvo que se fuerce',
        () async {
      final servicioNoticias = servicio();
      await servicioNoticias.actualizar();
      await servicioNoticias.actualizar();
      expect(peticiones, hasLength(1));
      await servicioNoticias.actualizar(forzar: true);
      expect(peticiones, hasLength(2));
    });

    test('si falla el servidor se queda con las guardadas', () async {
      await servicio().actualizar();
      responder = () => http.Response('error', 500);
      final resultado = await servicio().actualizar(forzar: true);
      expect(resultado.noticias, hasLength(2));
    });

    test('sin token también las pide (endpoint público), sin la cabecera',
        () async {
      SharedPreferences.setMockInitialValues(
          {'zunbeltz.sync_url': 'https://app.zunbeltz.com'});
      final resultado = await servicio().actualizar(forzar: true);
      expect(resultado.noticias, hasLength(2));
      expect(peticiones.single.headers.containsKey('X-Zunbeltz-Token'), isFalse);
    });

    test('sin servidor configurado no hace peticiones', () async {
      SharedPreferences.setMockInitialValues({});
      final resultado = await servicio().actualizar(forzar: true);
      expect(resultado.noticias, isEmpty);
      expect(peticiones, isEmpty);
    });
  });

  testWidgets('la pantalla enseña las noticias guardadas, sin red, en euskera',
      (tester) async {
    await initializeDateFormatting('eu');
    SharedPreferences.setMockInitialValues({
      'zunbeltz.noticias_sector': jsonEncode({
        'actualizado_ms': 1791244800000,
        'noticias': [_noticia(1), _noticia(2)],
      }),
    });
    final sinRed = ServicioNoticiasSector(
        cliente: MockClient((_) async => http.Response('', 500)));
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('eu'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu')],
      home: PantallaNoticiasSector(servicio: sinRed),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Sektoreko berriak'), findsOneWidget);
    expect(find.text('Noticia 1'), findsOneWidget);
    expect(find.text('Noticia 2'), findsOneWidget);
    expect(find.textContaining('Nabarmendua'), findsOneWidget,
        reason: 'la fijada lleva la marca de destacada');
    expect(find.text('Entradilla'), findsNWidgets(2));
  });
}
