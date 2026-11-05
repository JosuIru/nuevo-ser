// Tablero de tareas agrupado por sitio (pantalla 07 de la propuesta).

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/estado/ver_en_mapa.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/pantallas/tablero_tareas.dart';

import 'bd_en_memoria.dart';

void main() {
  late BaseDatosSoleraZunbeltz bd;

  setUpAll(() => initializeDateFormatting('es'));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    bd = await abrirBdEnMemoria();
    BaseDatosSoleraZunbeltz.inyectarParaTests(await bd.basedatos);
    await bd.sembrarEspacioRealSiVacia();
    peticionVerEnMapa.value = null;
  });

  Future<void> montar(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es'), Locale('eu')],
        home: Builder(
          builder: (contexto) => TextButton(
            onPressed: () => Navigator.of(contexto)
                .push(MaterialPageRoute(builder: (_) => const TableroTareas())),
            child: const Text('abrir'),
          ),
        ),
      ));
    });
    await tester.runAsync(() async {
      await tester.tap(find.text('abrir'));
      await tester.pump();
      // La BD ffi trabaja en otro isolate: hay que dejar correr el tiempo real.
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pumpAndSettle();
  }

  testWidgets(
      'agrupa por sitio y «Mapa» vuelve a las pestañas pidiendo el punto',
      (tester) async {
    await montar(tester);
    expect(find.text('Portillo norte (sierra de Urbasa)'), findsOneWidget);
    expect(find.textContaining('Abiertas'), findsOneWidget);
    await tester.tap(find.text('Mapa').first);
    await tester.pumpAndSettle();
    // Se ha cerrado el tablero y la petición lleva el punto del primer grupo.
    expect(find.byType(TableroTareas), findsNothing);
    expect(peticionVerEnMapa.value?.puntoId, isNotNull);
  });

  testWidgets('de partida no salen las hechas', (tester) async {
    final finca = (await tester.runAsync(bd.listarFincas))!.first;
    await tester.runAsync(() => bd.guardarTarea(TareaMantenimiento(
        fincaId: finca.id!, titulo: 'Ya hecha y cerrada', estado: 'hecha')));
    await montar(tester);
    expect(find.text('Ya hecha y cerrada'), findsNothing);
    await tester.tap(find.textContaining('Abiertas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Todos los estados').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Ya hecha y cerrada'), 300,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Ya hecha y cerrada'), findsOneWidget);
  });
}
