// Un mismo test puede ser de dos personas (petición de Pablo, 2026-11-09):
// `personas_uids` con todas y `persona_uid` con la primera, para las apps
// y el servidor anteriores.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/estado/sesion_espacio.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/pantallas/nuevo_proyecto.dart';

import 'bd_en_memoria.dart';

const ane = PersonaEspacio(uid: 'ane', nombre: 'Ane', etiquetaRol: 'Tester');
const mikel =
    PersonaEspacio(uid: 'mikel', nombre: 'Mikel', etiquetaRol: 'Tester');
const coord = PersonaEspacio(
    uid: 'coord',
    nombre: 'Pablo',
    rol: 'coordinador',
    etiquetaRol: 'Coordinación');

void main() {
  setUpAll(sqfliteFfiInit);

  group('modelo', () {
    test('las dos personas van y vuelven; persona_uid es la primera', () {
      final proyecto = ProyectoTest(
          nombre: 'Quesería',
          persona: 'Ane, Mikel',
          personaUid: 'ane',
          personasUids: const ['ane', 'mikel']);
      final mapa = proyecto.toMap();
      expect(mapa['persona_uid'], 'ane');
      expect(jsonDecode(mapa['personas_uids'] as String), ['ane', 'mikel']);
      final leido = ProyectoTest.fromMap(mapa);
      expect(leido.uidsTester, ['ane', 'mikel']);
      expect(leido.esDeTester('mikel'), isTrue);
      expect(leido.esDeTester('jon'), isFalse);
      expect(leido.esDeTester(''), isFalse);
    });

    test('un proyecto de antes (sin lista) es de su persona_uid', () {
      final leido = ProyectoTest.fromMap(
          {'nombre': 'Viejo', 'persona_uid': 'ane', 'personas_uids': ''});
      expect(leido.uidsTester, ['ane']);
      expect(ProyectoTest.fromMap({'nombre': 'Sin nadie'}).uidsTester, isEmpty);
    });

    test('si una app anterior cambió persona_uid, manda persona_uid', () {
      final leido = ProyectoTest.fromMap({
        'nombre': 'Cambiado',
        'persona_uid': 'jon',
        'personas_uids': '["ane","mikel"]',
      });
      expect(leido.uidsTester, ['jon']);
    });
  });

  group('base de datos y sincronización', () {
    test('se guarda, se lee y sube con las dos', () async {
      final bd = await abrirBdEnMemoria();
      final id = await bd.guardarProyecto(ProyectoTest(
          nombre: 'Huerta',
          personaUid: 'ane',
          personasUids: const ['ane', 'mikel']));
      expect((await bd.obtenerProyecto(id))!.uidsTester, ['ane', 'mikel']);

      final subida = (await bd.entidadesPendientesDeSubir(0))
          .singleWhere((entidad) => entidad['tipo'] == 'proyecto');
      final datos = subida['datos'] as Map;
      expect(datos['persona_uid'], 'ane');
      expect(jsonDecode(datos['personas_uids'] as String), ['ane', 'mikel']);
    });

    test('al bajar, la lista del servidor se guarda', () async {
      final bd = await abrirBdEnMemoria();
      await bd.aplicarEntidadRemota({
        'tipo': 'proyecto',
        'uid': 'p-1',
        'actualizado_ms': 10,
        'datos': {
          'nombre': 'Ovino',
          'persona': 'Ane, Mikel',
          'persona_uid': 'ane',
          'personas_uids': '["ane","mikel"]',
        },
      });
      expect((await bd.listarProyectos()).single.uidsTester, ['ane', 'mikel']);
    });

    test('migración desde v20: lo que había sigue siendo de su persona',
        () async {
      final carpeta = await Directory.systemTemp.createTemp('zunbeltz_v21_');
      final ruta = '${carpeta.path}/bd.db';
      final v20 = await databaseFactoryFfi.openDatabase(ruta,
          options: OpenDatabaseOptions(
            version: 20,
            onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
            onCreate: (d, v) async {
              await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
              // Hasta la v20 (lo que había antes de este cambio).
              await BaseDatosSoleraZunbeltz.migrarDesde(d, 1);
            },
          ));
      // migrarDesde ya llega a la última; se quita la columna nueva para
      // simular una BD v20 de verdad.
      await v20.execute('ALTER TABLE proyectos_test DROP COLUMN personas_uids');
      await v20.insert('proyectos_test', {
        'nombre': 'De antes',
        'persona_uid': 'ane',
        'uid': 'p-viejo',
      });
      await v20.close();

      final v21 = await databaseFactoryFfi.openDatabase(ruta,
          options: OpenDatabaseOptions(
            version: BaseDatosSoleraZunbeltz.versionEsquema,
            onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
            onUpgrade: (d, anterior, actual) =>
                BaseDatosSoleraZunbeltz.migrarDesde(d, anterior),
          ));
      final bd = BaseDatosSoleraZunbeltz.paraTests(v21);
      final proyecto = (await bd.listarProyectos()).single;
      expect(proyecto.nombre, 'De antes');
      expect(proyecto.uidsTester, ['ane']);
      await v21.close();
      await carpeta.delete(recursive: true);
    });
  });

  group('formulario', () {
    late BaseDatosSoleraZunbeltz bd;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      bd = await abrirBdEnMemoria();
      BaseDatosSoleraZunbeltz.inyectarParaTests(await bd.basedatos);
      sesionEspacio.value = const SesionEspacio(
          persona: coord, capacidades: {capacidadGestionarProyectos});
      personasEspacio.value = const [coord, ane, mikel];
    });

    tearDown(() {
      sesionEspacio.value = null;
      personasEspacio.value = const [];
    });

    testWidgets('se marcan dos personas tester y se guardan las dos',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('es'), Locale('eu')],
        home: NuevoProyecto(fincas: []),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Personas tester'), findsOneWidget);
      expect(find.byKey(const ValueKey('responsable-coord')), findsNothing,
          reason: 'coordinación no sale entre las personas tester');

      await tester.enterText(find.byType(TextField).first, 'Quesería a medias');
      await tester.tap(find.byKey(const ValueKey('responsable-ane')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('responsable-mikel')));
      await tester.pump();
      await tester.tap(find.text('Guardar'));
      for (var vuelta = 0; vuelta < 6; vuelta++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pump();
      }

      final proyecto = (await tester.runAsync(bd.listarProyectos))!.single;
      expect(proyecto.uidsTester, ['ane', 'mikel']);
      expect(proyecto.personaUid, 'ane');
      expect(proyecto.persona, 'Ane, Mikel');
    });
  });
}
