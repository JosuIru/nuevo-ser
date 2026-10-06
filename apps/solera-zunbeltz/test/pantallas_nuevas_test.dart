// Las pantallas nuevas se montan sin errores de diseño (desbordes,
// excepciones) en móvil, con datos de ejemplo.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/aviso_campo.dart';
import 'package:solera_zunbeltz/modelos/convenio.dart';
import 'package:solera_zunbeltz/modelos/peticion_tarea.dart';
import 'package:solera_zunbeltz/pantallas/nuevo_apunte.dart';
import 'package:solera_zunbeltz/pantallas/nuevo_aviso.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_convenio.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_inicio.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_peticiones.dart';

import 'bd_en_memoria.dart';

Widget envolver(Widget pantalla, {String idioma = 'es'}) => MaterialApp(
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

void main() {
  late BaseDatosSoleraZunbeltz bd;
  late int proyectoId;

  setUpAll(() async {
    await initializeDateFormatting('es');
    await initializeDateFormatting('eu');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    bd = await abrirBdEnMemoria();
    BaseDatosSoleraZunbeltz.inyectarParaTests(await bd.basedatos);
    await bd.sembrarDemostracionSiVacia();
    proyectoId = (await bd.listarProyectos()).first.id!;
    await bd.guardarAviso(AvisoCampo(
        titulo: 'Oveja coja', gravedad: gravedadAlarma, categoria: categoriaAvisoGanado, fechaMs: 1));
    await bd.guardarPeticion(PeticionTarea(titulo: 'Falta pienso', urgente: true));
    await bd.guardarPartidaPresupuesto(PartidaPresupuesto(
        proyectoId: proyectoId, categoria: 'infraestructuras', asumidoPor: 'zunbeltz', importeCentimos: 900000));
    await bd.guardarAcompanamiento(Acompanamiento(proyectoId: proyectoId, tipo: 'formacion', asistencia: 'asistida'));
    await bd.guardarIncidencia(IncidenciaCumplimiento(proyectoId: proyectoId, nivel: 'grave', descripcion: 'Retraso'));
  });

  Future<void> montar(WidgetTester tester, Widget pantalla, {String idioma = 'es'}) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await tester.pumpWidget(envolver(pantalla, idioma: idioma));
      // La BD ffi trabaja en otro isolate: hay que dejar correr el tiempo real.
      await Future<void>.delayed(const Duration(milliseconds: 600));
    });
    await tester.pump();
  }

  for (final idioma in ['es', 'eu']) {
    testWidgets('Hoy como bandeja ($idioma)', (tester) async {
      await montar(tester, const PantallaInicio(), idioma: idioma);
      expect(find.byIcon(Icons.notification_important), findsWidgets,
          reason: 'la alarma abierta aparece arriba');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Convenio: las cinco pestañas ($idioma)', (tester) async {
      final proyecto = (await tester.runAsync(() => bd.obtenerProyecto(proyectoId)))!;
      await montar(tester, PantallaConvenio(proyecto: proyecto), idioma: idioma);
      for (var pestana = 0; pestana < 5; pestana++) {
        await tester.tap(find.byType(Tab).at(pestana));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'pestaña $pestana');
      }
    });
  }

  testWidgets('Dar un aviso', (tester) async {
    await montar(tester, const NuevoAviso());
    expect(find.text('Ganado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Peticiones', (tester) async {
    await montar(tester, const PantallaPeticiones());
    expect(find.text('Falta pienso'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Apunte de gasto con quién lo asume', (tester) async {
    await montar(tester, NuevoApunte(proyectoId: proyectoId, fincaId: 1));
    expect(tester.takeException(), isNull);
  });
}
