// Lo hecho sin usuario (modo local) no se sube al conectar una clave: se
// cuenta para avisar y se descarta. Si subiera, un borrado de prueba se
// aplicaría para todo el espacio con una clave de coordinación.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/estado/ajustes_sincronizacion.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/pantallas/pantalla_sincronizacion.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';

import 'bd_en_memoria.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('el espacio sembrado de serie no cuenta como cambio', () async {
    final bd = await abrirBdEnMemoria();
    expect(await bd.sembrarEspacioRealSiVacia(), isTrue);
    expect(await bd.listarZonas(), isNotEmpty);
    expect(await bd.contarCambiosSinSubir(), 0);
  });

  test('borrar o tocar lo sembrado cuenta; descartar lo vacía todo', () async {
    final bd = await abrirBdEnMemoria();
    await bd.sembrarEspacioRealSiVacia();
    final zonas = await bd.listarZonas();
    final puntos = await bd.listarPuntos();
    await bd.borrarZona(zonas.first.id!);
    await bd.borrarPunto(puntos.first.id!);
    final fincaId = (await bd.listarFincas()).first.id!;
    await bd.guardarTarea(TareaMantenimiento(
        fincaId: fincaId, titulo: 'Probar', estado: 'pendiente'));

    final cambios = await bd.contarCambiosSinSubir();
    expect(cambios, greaterThanOrEqualTo(3));
    expect(await bd.listarBorradosPendientes(), isNotEmpty);

    await bd.descartarCambiosSinSubir();

    expect(await bd.contarCambiosSinSubir(), 0);
    expect(await bd.listarBorradosPendientes(), isEmpty);
    expect(await bd.listarFincas(), isEmpty);
    expect(await bd.listarZonas(), isEmpty);
    expect(await bd.listarTareas(), isEmpty);
    // La siguiente sincronización es completa y empieza de cero.
    expect(await bd.leerEstadoSync('revision'), 0);
    expect(
        await bd.leerEstadoSync(SincronizacionBaseDatos.claveCompletaPedida),
        greaterThan(await bd
            .leerEstadoSync(SincronizacionBaseDatos.claveCompletaHecha)));
  });

  test('lo ya subido no cuenta: solo lo posterior al último envío', () async {
    final bd = await abrirBdEnMemoria();
    await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    expect(await bd.contarCambiosSinSubir(), 1);
    await bd.guardarEstadoSync(
        'subida_ms', DateTime.now().millisecondsSinceEpoch + 1000);
    expect(await bd.contarCambiosSinSubir(), 0);
  });

  group('pantalla', pruebasDePantalla);
}

// ─── La pantalla: aviso antes de conectar una clave ───

Widget _envolver(Widget pantalla) => MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('eu')],
      home: pantalla,
    );

void pruebasDePantalla() {
  late BaseDatosSoleraZunbeltz bd;

  setUp(() async {
    SharedPreferences.setMockInitialValues(
        {'flutter.zunbeltz.sync_url': 'http://servidor.invalido'});
    sqfliteFfiInit();
    bd = await abrirBdEnMemoria();
    BaseDatosSoleraZunbeltz.inyectarParaTests(await bd.basedatos);
    await bd.sembrarEspacioRealSiVacia();
    await bd.borrarZona((await bd.listarZonas()).first.id!);
  });

  Future<void> escribirClave(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      await tester.pumpWidget(_envolver(const PantallaSincronizacion()));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    await tester.tap(find.text('Clave de usuario'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'clave-de-coordinacion');
    await tester.tap(find.text('Guardar'));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
  }

  testWidgets('con cambios sin usuario, avisa; cancelar no guarda la clave',
      (tester) async {
    await escribirClave(tester);
    expect(find.text('Cambios hechos sin usuario'), findsOneWidget);
    expect(
        find.textContaining('hay 1 cambio hecho sin usuario'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(AjustesSincronizacion.cargarToken), '');
    expect(await tester.runAsync(bd.listarBorradosPendientes), isNotEmpty);
  });

  testWidgets('aceptar descarta lo local y guarda la clave', (tester) async {
    await escribirClave(tester);
    await tester.tap(find.text('Descartar y conectar'));
    // Descartar va a la BD ffi (otro isolate): tiempo real entre fotogramas.
    for (var vuelta = 0; vuelta < 8; vuelta++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }
    expect(await tester.runAsync(AjustesSincronizacion.cargarToken),
        'clave-de-coordinacion');
    expect(await tester.runAsync(bd.listarBorradosPendientes), isEmpty);
    expect(await tester.runAsync(bd.contarCambiosSinSubir), 0);
  });
}
