import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/logos_entidades.dart';
import 'package:solera_zunbeltz/modelos/entidad_colaboradora.dart';
import 'package:solera_zunbeltz/pantallas/widgets/logos_entidades.dart';
import 'package:solera_zunbeltz/servicios/servicio_logos_entidades.dart';

Map<String, Object?> _entidad(String clave,
        {String grupo = 'apoyan', bool logoPropio = false}) =>
    {
      'clave': clave,
      'nombre': 'Entidad $clave',
      'grupo': grupo,
      'enlace': 'https://$clave.eus',
      'logo_url': 'https://app.zunbeltz.com/logos/$clave.png',
      'logo_propio': logoPropio,
    };

void main() {
  group('EntidadColaboradora.desdeJson', () {
    test('lee todos los campos y vuelve igual con aJson', () {
      final entidad = EntidadColaboradora.desdeJson(_entidad('upna'))!;
      expect(entidad.nombre, 'Entidad upna');
      expect(entidad.aJson(), _entidad('upna'));
    });

    test('descarta lo que no sirve y los enlaces que no son web', () {
      expect(EntidadColaboradora.desdeJson({..._entidad('a'), 'clave': ''}),
          isNull);
      expect(EntidadColaboradora.desdeJson({'clave': 'b', 'nombre': 'B'}),
          isNull);
      final conEnlaceRaro = EntidadColaboradora.desdeJson(
          {..._entidad('c'), 'enlace': 'javascript:alert(1)'})!;
      expect(conEnlaceRaro.enlace, '');
    });
  });

  test('la lista de partida tiene un logo empaquetado para cada entidad', () {
    expect(entidadesDePartida, hasLength(19));
    for (final entidad in entidadesDePartida) {
      expect(clavesLogosEmpaquetados, contains(entidad.clave));
      expect(GrupoEntidades.desdeCodigo(entidad.grupo), isNotNull);
    }
  });

  group('ServicioLogosEntidades', () {
    late List<http.Request> peticiones;
    late http.Response Function() responder;

    ServicioLogosEntidades servicio() => ServicioLogosEntidades(
          cliente: MockClient((peticion) async {
            peticiones.add(peticion);
            return responder();
          }),
        );

    setUp(() async {
      peticiones = [];
      responder = () => http.Response(
          jsonEncode({
            'entidades': [_entidad('andia', grupo: 'impulsan'), 'basura'],
          }),
          200);
      SharedPreferences.setMockInitialValues({});
      await ServicioLogosEntidades.olvidarGuardadas();
      SharedPreferences.setMockInitialValues(
          {'zunbeltz.sync_url': 'https://app.zunbeltz.com/'});
    });

    test('sin servidor, la lista de partida', () async {
      SharedPreferences.setMockInitialValues({});
      final entidades = await servicio().actualizar(forzar: true);
      expect(entidades, same(entidadesDePartida));
      expect(peticiones, isEmpty);
    });

    test('baja la lista del panel, la guarda y no repregunta enseguida',
        () async {
      final entidades = await servicio().actualizar();
      expect(entidades.map((entidad) => entidad.clave), ['andia']);
      expect(peticiones.single.url.toString(),
          'https://app.zunbeltz.com/wp-json/solera-zunbeltz/v1/entidades');

      ServicioLogosEntidades.actuales.value = entidadesDePartida;
      final guardadas = await servicio().actualizar();
      expect(guardadas.map((entidad) => entidad.clave), ['andia']);
      expect(peticiones, hasLength(1));
    });

    test('si el servidor falla o es antiguo (404), se queda con lo que hay',
        () async {
      responder = () => http.Response('', 404);
      final entidades = await servicio().actualizar(forzar: true);
      expect(entidades, same(entidadesDePartida));
    });
  });

  testWidgets(
      'logo empaquetado salvo que coordinación suba otro; rótulos en euskera',
      (tester) async {
    ServicioLogosEntidades.actuales.value = [
      EntidadColaboradora.desdeJson(_entidad('andia', grupo: 'impulsan'))!,
      EntidadColaboradora.desdeJson(
          _entidad('upna', grupo: 'colaboran', logoPropio: true))!,
      EntidadColaboradora.desdeJson(_entidad('nueva', grupo: 'colaboran'))!,
    ];
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('eu'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es'), Locale('eu')],
      home: Scaffold(body: LogosEntidadesPorGrupo()),
    ));

    expect(find.text('Proiektuaren bultzatzaileak'), findsOneWidget);
    expect(find.text('Laguntzaileak'), findsOneWidget);
    expect(find.text('Proiektuaren babesleak'), findsNothing);

    final imagenes = tester.widgetList<Image>(find.byType(Image)).toList();
    final fuentes = imagenes.map((imagen) => imagen.image).toList();
    expect(fuentes.whereType<AssetImage>().map((fuente) => fuente.assetName),
        ['assets/logos/andia.png']);
    expect(fuentes.whereType<NetworkImage>().map((fuente) => fuente.url), [
      'https://app.zunbeltz.com/logos/upna.png',
      'https://app.zunbeltz.com/logos/nueva.png',
    ]);
    ServicioLogosEntidades.actuales.value = entidadesDePartida;
  });
}
