// Las pantallas nuevas se montan sin errores de diseño (desbordes,
// excepciones) en móvil, con datos de ejemplo.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/amortizacion.dart';
import 'package:solera_zunbeltz/modelos/aviso_campo.dart';
import 'package:solera_zunbeltz/modelos/convenio.dart';
import 'package:solera_zunbeltz/modelos/peticion_tarea.dart';
import 'package:solera_zunbeltz/modelos/agenda.dart';
import 'package:solera_zunbeltz/pantallas/nueva_tarea.dart';
import 'package:solera_zunbeltz/pantallas/nuevo_apunte.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_calculadora.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_contactos.dart';
import 'package:solera_zunbeltz/pantallas/nuevo_aviso.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_convenio.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_inicio.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_inventario.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_peticiones.dart';

import 'bd_en_memoria.dart';
import 'package:solera_zunbeltz/pantallas/proyecto_detalle.dart';
import 'package:solera_zunbeltz/pantallas/nueva_comercializacion.dart';

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
    final bienId = await bd.guardarBien(BienAmortizable(
        nombre: 'Corral móvil con kit de enganche y ruedas para 60-90 m²',
        grupo: 'instalaciones', precioUnidadCentimos: 1137542, unidades: 2));
    await bd.guardarUsoBien(UsoBien(proyectoId: proyectoId, bienId: bienId, imputacionPorcentaje: 50));
    await bd.guardarIncidencia(IncidenciaCumplimiento(proyectoId: proyectoId, nivel: 'grave', descripcion: 'Retraso'));
    await bd.guardarContacto(Contacto(nombre: 'Matadero de prueba', tipo: 'matadero', telefono: '948000000'));
    await bd.guardarRendimiento(RendimientoReferencia(nombre: 'Cordero — canal', rendimientoCanal: 50));
    await bd.guardarEscenario(EscenarioTransformacion(
        proyectoId: proyectoId, nombre: 'Despiece y venta directa', pesoVivoKg: 25,
        rendimientoCanal: 50, rendimientoProducto: 85, precioKgCentimos: 1600));
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

    testWidgets('Hoy enseña las noticias del sector sin sesión ($idioma)',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'zunbeltz.noticias_sector': jsonEncode({
          'actualizado_ms': DateTime.now().millisecondsSinceEpoch,
          'noticias': [
            {
              'id': 1,
              'titulo': 'Tractorada en Madrid',
              'entradilla': '',
              'enlace': 'https://uagn.es/a',
              'fecha_ms': DateTime.now().millisecondsSinceEpoch,
              'fuente': 'UAGN',
              'idioma': 'es',
            }
          ],
        }),
      });
      await montar(tester, const PantallaInicio(), idioma: idioma);
      await tester.tap(find.text(idioma == 'eu' ? 'Berriak' : 'Noticias').first);
      await tester.pumpAndSettle();
      expect(find.text('Tractorada en Madrid', skipOffstage: false), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Convenio: las seis pestañas ($idioma)', (tester) async {
      final proyecto = (await tester.runAsync(() => bd.obtenerProyecto(proyectoId)))!;
      await montar(tester, PantallaConvenio(proyecto: proyecto), idioma: idioma);
      for (var pestana = 0; pestana < 6; pestana++) {
        await tester.tap(find.byType(Tab).at(pestana));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'pestaña $pestana');
      }
    });
  }

  for (final idioma in ['es', 'eu']) {
    testWidgets('Inventario de bienes y su formulario ($idioma)', (tester) async {
      await montar(tester, const PantallaInventario(), idioma: idioma);
      expect(find.textContaining('kit de enganche'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await montar(tester, const FormularioBienAmortizable(), idioma: idioma);
      await tester.enterText(find.byType(TextField).at(1), '1.392,00');
      await tester.pump();
      // 1.392 € + 21 % = 1.684,32 €; entre 72 meses, 23,39 € al mes.
      expect(find.text('1684,32 €'), findsOneWidget);
      expect(find.text('23,39 €'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final idioma in ['es', 'eu']) {
    testWidgets('Nueva tarea desde una tarea tipo ($idioma)', (tester) async {
      final fincaId = (await tester.runAsync(() => bd.listarFincas()))!.first.id!;
      await montar(tester, NuevaTarea(fincaId: fincaId), idioma: idioma);
      await tester.tap(find.byIcon(Icons.list_alt_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text(idioma == 'eu' ? 'Abereen elikadura' : 'Alimentación del ganado').first);
      await tester.pumpAndSettle();
      expect(find.text(idioma == 'eu' ? 'Abereen elikadura' : 'Alimentación del ganado'), findsOneWidget,
          reason: 'el título queda escrito');
      expect(find.text(idioma == 'eu' ? 'Egunero' : 'Diaria'), findsOneWidget,
          reason: 'y la periodicidad sugerida');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Detalle de proyecto en apaisado: la cabecera se desplaza sin desbordar',
      (tester) async {
    final proyecto = (await tester.runAsync(() => bd.obtenerProyecto(proyectoId)))!;
    await montar(tester, ProyectoDetalle(proyecto: proyecto));
    tester.view.physicalSize = const Size(740, 360) * 3;
    await tester.pumpAndSettle();
    final desglose = find.byType(ExpansionTile);
    if (desglose.evaluate().isNotEmpty) {
      await tester.tap(desglose.first);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    for (var pestana = 0; pestana < 4; pestana++) {
      await tester.tap(find.byType(Tab).at(pestana));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'pestaña $pestana');
    }
  });

  testWidgets('Una venta con «1.200,00» se guarda como 1200 €, no como 0',
      (tester) async {
    await montar(tester, NuevaComercializacion(proyectoId: proyectoId));
    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), 'Queso');
    await tester.enterText(campos.last, '1.200,00');
    final guardar = find.byWidgetPredicate((widget) => widget is FilledButton);
    await tester.ensureVisible(guardar);
    await tester.tap(guardar);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 600)));
    await tester.pumpAndSettle();
    final ventas = await tester.runAsync(() => bd.listarComercializacion(proyectoId: proyectoId));
    expect(ventas!.map((venta) => venta.ingresoCentimos), contains(120000));
  });

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

  for (final idioma in ['es', 'eu']) {
    testWidgets('Contactos ($idioma)', (tester) async {
      await montar(tester, const PantallaContactos(), idioma: idioma);
      expect(find.text('Matadero de prueba'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Calculadora de transformación ($idioma)', (tester) async {
      final proyecto = (await tester.runAsync(() => bd.obtenerProyecto(proyectoId)))!;
      await montar(tester, PantallaCalculadora(proyecto: proyecto), idioma: idioma);
      await tester.enterText(find.byType(TextField).first, '30');
      await tester.pump();
      await tester.scrollUntilVisible(find.text('Despiece y venta directa'), 300,
          scrollable: find
              .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      expect(find.text('Despiece y venta directa'), findsOneWidget,
          reason: 'el camino guardado aparece para comparar');
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Formulario de contacto', (tester) async {
    await montar(tester, const FormularioContacto());
    expect(tester.takeException(), isNull);
  });
}
