// Tareas con varias responsables: modelo, BD (migración v19), reparto en
// el alta («una compartida» / «una para cada persona»), sincronización y
// compatibilidad con datos sin lista. La política va en
// `politica_tareas_test.dart` (espejo de `tests/test_sync.php`).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/estado/sesion_espacio.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/pantallas/nueva_tarea.dart';
import 'package:solera_zunbeltz/pantallas/widgets/selector_responsables.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';
import 'package:solera_zunbeltz/utiles/responsables_tarea.dart';

import 'bd_en_memoria.dart';

const ane = PersonaEspacio(uid: 'ane', nombre: 'Ane', etiquetaRol: 'Tester');
const mikel =
    PersonaEspacio(uid: 'mikel', nombre: 'Mikel', etiquetaRol: 'Tester');
const coord =
    PersonaEspacio(uid: 'coord', nombre: 'Pablo', etiquetaRol: 'Coordinación');
const personas = [coord, ane, mikel];

const capacidadesCoordinacion = {
  capacidadVerTodasTareas,
  capacidadCrearTareas,
  capacidadEditarCualquierTarea,
  capacidadAsignarTareas,
};

void main() {
  group('modelo', () {
    test('sin lista vale la responsable de siempre (datos anteriores)', () {
      final antigua = TareaMantenimiento.fromMap(
          {'finca_id': 1, 'responsable_uid': 'ane', 'responsable': 'Ane'});
      expect(antigua.uidsResponsables, ['ane']);
      expect(antigua.tieneResponsable('ane'), isTrue);
      expect(antigua.sinResponsables, isFalse);
      expect(TareaMantenimiento(fincaId: 1).sinResponsables, isTrue);
    });

    test('la lista manda y la primera va en responsable_uid', () {
      final tarea = conResponsables(
          TareaMantenimiento(fincaId: 1), ['mikel', 'ane'], personas);
      final mapa = tarea.toMap();
      expect(mapa['responsable_uid'], 'mikel');
      expect(mapa['responsable'], 'Mikel, Ane');
      expect(mapa['responsables_uids'], '["mikel","ane"]');
      final leida = TareaMantenimiento.fromMap(mapa);
      expect(leida.uidsResponsables, ['mikel', 'ane']);
      expect(leida.tieneResponsable('ane'), isTrue);
      expect(leida.tieneResponsable(''), isFalse);
    });

    test('sin repetidas ni vacías; JSON roto = sin lista', () {
      expect(
          TareaMantenimiento(fincaId: 1, responsablesUids: ['a', '', 'a', 'b'])
              .uidsResponsables,
          ['a', 'b']);
      expect(decodificarUidsResponsables('no es json'), isEmpty);
      expect(decodificarUidsResponsables(null), isEmpty);
      expect(decodificarUidsResponsables(['x', 3, 'y']), ['x', 'y']);
    });

    test('columnas al asignar una tarea existente', () {
      expect(columnasResponsables(['ane', 'mikel'], personas), {
        'responsables_uids': '["ane","mikel"]',
        'responsable_uid': 'ane',
        'responsable': 'Ane, Mikel',
      });
      expect(columnasResponsables(const [], personas), {
        'responsables_uids': '[]',
        'responsable_uid': '',
        'responsable': '',
      });
    });
  });

  group('reparto en el alta', () {
    final base = TareaMantenimiento(
      uid: 'base',
      fincaId: 3,
      puntoId: 4,
      zonaId: 5,
      titulo: 'Alimentar',
      prioridad: 'alta',
      fechaObjetivoMs: 1000,
      recurrenciaDias: 1,
      rutasFotosAntesJson: '["a.jpg"]',
      creadoPorUid: 'coord',
    );

    test('compartida: una sola con todas', () {
      final tareas = tareasDelAlta(
          base, ['ane', 'mikel'], personas, RepartoTarea.compartida);
      expect(tareas, hasLength(1));
      expect(tareas.single.uid, 'base');
      expect(tareas.single.uidsResponsables, ['ane', 'mikel']);
      expect(tareas.single.responsable, 'Ane, Mikel');
    });

    test('una para cada persona: N iguales con uids distintos', () {
      final tareas = tareasDelAlta(
          base, ['ane', 'mikel', 'coord'], personas, RepartoTarea.unaParaCada);
      expect(tareas, hasLength(3));
      expect(tareas.map((tarea) => tarea.uid).toSet(), hasLength(3));
      expect(tareas.first.uid, 'base');
      expect([
        for (final tarea in tareas) tarea.uidsResponsables
      ], [
        ['ane'],
        ['mikel'],
        ['coord']
      ]);
      expect([for (final tarea in tareas) tarea.responsable],
          ['Ane', 'Mikel', 'Pablo']);
      for (final tarea in tareas) {
        expect(tarea.fincaId, 3);
        expect(tarea.puntoId, 4);
        expect(tarea.zonaId, 5);
        expect(tarea.titulo, 'Alimentar');
        expect(tarea.prioridad, 'alta');
        expect(tarea.fechaObjetivoMs, 1000);
        expect(tarea.recurrenciaDias, 1);
        expect(tarea.rutasFotosAntesJson, '["a.jpg"]');
        expect(tarea.creadoPorUid, 'coord');
      }
    });

    test('con una sola persona no hay nada que repartir', () {
      expect(tareasDelAlta(base, ['ane'], personas, RepartoTarea.unaParaCada),
          hasLength(1));
    });
  });

  group('base de datos', () {
    late BaseDatosSoleraZunbeltz bd;
    late int fincaId;
    setUp(() async {
      bd = await abrirBdEnMemoria();
      fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    });

    test('«Mis tareas» por uid encuentra también las compartidas', () async {
      await bd.guardarTarea(conResponsables(
          TareaMantenimiento(fincaId: fincaId, titulo: 'Compartida'),
          ['ane', 'mikel'],
          personas));
      await bd.guardarTarea(conResponsables(
          TareaMantenimiento(fincaId: fincaId, titulo: 'De Ane'),
          ['ane'],
          personas));
      final deMikel = await bd.listarTareas(responsableUid: 'mikel');
      expect(deMikel.map((tarea) => tarea.titulo), ['Compartida']);
      final deAne = await bd.listarTareas(responsableUid: 'ane');
      expect(deAne, hasLength(2));
    });

    test('la siguiente periódica hereda la lista', () async {
      final id = await bd.guardarTarea(conResponsables(
          TareaMantenimiento(
              fincaId: fincaId, titulo: 'Rellenar', recurrenciaDias: 7),
          ['ane', 'mikel'],
          personas));
      final siguienteId = await bd.marcarTareaHecha(id);
      final siguiente = await bd.obtenerTarea(siguienteId!);
      expect(siguiente!.uidsResponsables, ['ane', 'mikel']);
      expect(siguiente.responsable, 'Ane, Mikel');
      expect(siguiente.estado, 'pendiente');
    });

    test('migración v18 → v19: cada tarea pasa a tener su lista', () async {
      final dir = await Directory.systemTemp.createTemp('zunbeltz_mig19');
      final ruta = '${dir.path}/m19.db';
      sqfliteFfiInit();
      final v18 = await databaseFactoryFfi.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: 18,
          onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
          onCreate: (d, v) async {
            await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV6(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV7(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV8(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV9(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV10(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV11(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV12(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV13(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV14(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV15(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV16(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV17(d);
            await BaseDatosSoleraZunbeltz.aplicarMigracionV18(d);
          },
        ),
      );
      final idFinca = await v18.insert(
          'fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
      for (final (titulo, responsable) in [
        ('Asignada', 'ane'),
        ('General', '')
      ]) {
        await v18.insert(
            'tareas_mantenimiento',
            TareaMantenimiento(
                    fincaId: idFinca,
                    titulo: titulo,
                    responsableUid: responsable,
                    responsable: responsable.isEmpty ? '' : 'Ane')
                .toMap()
              ..remove('id')
              ..remove('responsables_uids'));
      }
      await v18.close();

      final v19 = await databaseFactoryFfi.openDatabase(
        ruta,
        options: OpenDatabaseOptions(
          version: BaseDatosSoleraZunbeltz.versionEsquema,
          onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
          onUpgrade: (d, anterior, actual) =>
              BaseDatosSoleraZunbeltz.migrarDesde(d, anterior),
        ),
      );
      final filas = await v19.query('tareas_mantenimiento',
          columns: ['titulo', 'responsables_uids'], orderBy: 'titulo');
      expect(filas, [
        {'titulo': 'Asignada', 'responsables_uids': '["ane"]'},
        {'titulo': 'General', 'responsables_uids': '[]'},
      ]);
      final migrada = BaseDatosSoleraZunbeltz.paraTests(v19);
      expect((await migrada.listarTareas(responsableUid: 'ane')).single.titulo,
          'Asignada');
      await v19.close();
      await dir.delete(recursive: true);
    });

    test('sync: la lista viaja entera y vuelve igual', () async {
      final tarea = conResponsables(
          TareaMantenimiento(
              uid: 'compartida', fincaId: fincaId, actualizadoMs: 5),
          ['ane', 'mikel'],
          personas);
      final json = ClienteSyncZunbeltz.tareaAJson(tarea, 'Zunbeltz');
      expect(json['responsables_uids'], ['ane', 'mikel']);
      expect(json['responsable_uid'], 'ane',
          reason: 'un plugin antiguo entiende la primera');
      expect(json['responsable'], 'Ane, Mikel');

      final vuelta = ClienteSyncZunbeltz.tareaDesdeJson(json, fincaId);
      await bd.upsertTareaRemota(vuelta);
      final guardada = await bd.obtenerTareaPorUid('compartida');
      expect(guardada!.uidsResponsables, ['ane', 'mikel']);

      // El servidor quita a una (last-write-wins): la lista llega entera.
      await bd.upsertTareaRemota(ClienteSyncZunbeltz.tareaDesdeJson({
        ...json,
        'responsables_uids': ['mikel'],
        'responsable_uid': 'mikel',
        'responsable': 'Mikel',
        'actualizado_ms': 9
      }, fincaId));
      expect((await bd.obtenerTareaPorUid('compartida'))!.uidsResponsables,
          ['mikel']);
    });

    test('sync con un plugin antiguo (sin lista): queda la primera', () async {
      final vieja = ClienteSyncZunbeltz.tareaDesdeJson({
        'uid': 'vieja',
        'responsable_uid': 'ane',
        'responsable': 'Ane',
        'actualizado_ms': 3,
      }, fincaId);
      expect(vieja.uidsResponsables, ['ane']);
      await bd.upsertTareaRemota(vieja);
      final guardada = await bd.obtenerTareaPorUid('vieja');
      expect(guardada!.uidsResponsables, ['ane']);
      expect(guardada.toMap()['responsables_uids'], '["ane"]');
    });
  });

  group('pantallas', () {
    late BaseDatosSoleraZunbeltz bd;
    late int fincaId;

    setUpAll(() async {
      await initializeDateFormatting('es');
      await initializeDateFormatting('eu');
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      bd = await abrirBdEnMemoria();
      BaseDatosSoleraZunbeltz.inyectarParaTests(await bd.basedatos);
      fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
      sesionEspacio.value = const SesionEspacio(
          persona: coord, capacidades: capacidadesCoordinacion);
      personasEspacio.value = personas;
    });

    tearDown(() {
      sesionEspacio.value = null;
      personasEspacio.value = const [];
    });

    Widget envolver(Widget pantalla, String idioma) => MaterialApp(
          locale: Locale(idioma),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('eu')],
          home: pantalla,
        );

    Future<void> esperarBd(WidgetTester tester) async {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)));
      await tester.pumpAndSettle();
    }

    Future<void> altaConDos(WidgetTester tester, String idioma,
        {required Key opcion}) async {
      tester.view.physicalSize = const Size(390, 844) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        await tester.pumpWidget(envolver(NuevaTarea(fincaId: fincaId), idioma));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();
      final textos = lookupAppLocalizations(Locale(idioma));
      await tester.enterText(find.byType(TextField).first, 'Alimentar');
      expect(find.text(textos.tareaResponsables), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('responsable-ane')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('responsable-mikel')));
      await tester.pump();
      final guardar = find.byIcon(Icons.save);
      await tester.scrollUntilVisible(guardar, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(guardar);
      await tester.pumpAndSettle();
      // La pregunta, en su idioma.
      expect(find.text(textos.tareaRepartoTitulo(2)), findsOneWidget);
      expect(find.text(textos.tareaRepartoCompartida), findsOneWidget);
      expect(find.text(textos.tareaRepartoCadaPersona), findsOneWidget);
      expect(tester.takeException(), isNull);
      // En euskera los textos son largos: la segunda opción puede pedir
      // desplazar el diálogo.
      await tester.ensureVisible(find.byKey(opcion));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(opcion));
      await esperarBd(tester);
    }

    for (final idioma in ['es', 'eu']) {
      testWidgets('alta con dos personas: una para cada una ($idioma)',
          (tester) async {
        await altaConDos(tester, idioma,
            opcion: const ValueKey('reparto-una-para-cada'));
        final tareas = (await tester.runAsync(() => bd.listarTareas()))!;
        expect(tareas, hasLength(2));
        expect(tareas.map((tarea) => tarea.uid).toSet(), hasLength(2));
        expect(tareas.map((tarea) => tarea.uidsResponsables.single).toSet(),
            {'ane', 'mikel'});
        expect(tareas.every((tarea) => tarea.titulo == 'Alimentar'), isTrue);
      });

      testWidgets('alta con dos personas: compartida ($idioma)',
          (tester) async {
        await altaConDos(tester, idioma,
            opcion: const ValueKey('reparto-compartida'));
        final tareas = (await tester.runAsync(() => bd.listarTareas()))!;
        expect(tareas.single.uidsResponsables, ['ane', 'mikel']);
        expect(tareas.single.responsable, 'Ane, Mikel');
      });

      testWidgets('el selector marca y desmarca ($idioma)', (tester) async {
        var elegidas = <String>['ane'];
        await tester.pumpWidget(envolver(
            Scaffold(
              body: StatefulBuilder(
                builder: (contexto, cambiar) => SelectorResponsables(
                  personas: personas,
                  elegidas: elegidas,
                  alCambiar: (nuevas) => cambiar(() => elegidas = nuevas),
                ),
              ),
            ),
            idioma));
        await tester.pumpAndSettle();
        final textos = lookupAppLocalizations(Locale(idioma));
        expect(find.text(textos.tareaResponsablesAyudaGeneral), findsOneWidget);
        expect(find.byType(FilterChip), findsNWidgets(3));
        await tester.tap(find.text('Mikel'));
        await tester.pump();
        expect(elegidas, ['ane', 'mikel']);
        await tester.tap(find.text('Ane'));
        await tester.pump();
        expect(elegidas, ['mikel']);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('una tester solo puede elegirse a sí misma', (tester) async {
      sesionEspacio.value = const SesionEspacio(
          persona: ane, capacidades: {capacidadCrearTareas});
      await tester.runAsync(() async {
        await tester.pumpWidget(envolver(NuevaTarea(fincaId: fincaId), 'es'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsOneWidget);
      expect(find.text('Ane'), findsOneWidget);
      expect(find.text('Mikel'), findsNothing);
    });
  });
}
