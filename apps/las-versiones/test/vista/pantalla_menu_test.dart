import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:las_versiones/vista/pantalla_menu.dart';
import 'package:las_versiones/vista/pantalla_instrucciones.dart';
import 'package:las_versiones/vista/pantalla_creditos.dart';

PantallaMenu _menu({
  VoidCallback? alAbrirCuaderno,
  VoidCallback? alAbrirAvances,
  VoidCallback? alAbrirResumenes,
  VoidCallback? alAbrirAtico,
  VoidCallback? alAbrirCuenta,
  VoidCallback? alAbrirPerfiles,
  VoidCallback? alAbrirAjustesAudio,
  String? nombrePerfilActivo = 'Maren',
  bool sesionIniciada = false,
  ValueChanged<String>? alCambiarIdioma,
  String? idiomaActivo = 'es',
  Future<void> Function()? alResetearArchivo,
}) {
  return PantallaMenu(
    alAbrirCuaderno: alAbrirCuaderno ?? () {},
    alAbrirAvances: alAbrirAvances ?? () {},
    alAbrirResumenes: alAbrirResumenes ?? () {},
    alAbrirAtico: alAbrirAtico,
    alAbrirCuenta: alAbrirCuenta ?? () {},
    alAbrirPerfiles: alAbrirPerfiles ?? () {},
    alAbrirAjustesAudio: alAbrirAjustesAudio ?? () {},
    nombrePerfilActivo: nombrePerfilActivo,
    sesionIniciada: sesionIniciada,
    alCambiarIdioma: alCambiarIdioma ?? (_) {},
    idiomaActivo: idiomaActivo,
    alResetearArchivo: alResetearArchivo ?? (() async {}),
  );
}

void main() {
  group('PantallaMenu', () {
    setUp(() {
      // Viewport alto para que el ListView tenga todas las filas en
      // pantalla sin tener que scrollear en cada test.
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .physicalSize = const Size(900, 2400);
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .devicePixelRatio = 1.0;
    });
    tearDown(() {
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .resetPhysicalSize();
      TestWidgetsFlutterBinding.ensureInitialized()
          .platformDispatcher
          .views
          .first
          .resetDevicePixelRatio();
    });

    testWidgets(
      'render mínimo — los tres encabezados de bloque y todas las filas '
      'agrupadas (Cuaderno, Avances, Resúmenes, Cuenta, Idioma, '
      'Instrucciones, Créditos, Resetear, Salir)',
      (tester) async {
        await tester.pumpWidget(MaterialApp(home: _menu()));
        expect(find.text('MENÚ'), findsOneWidget);
        expect(find.text('MI ARCHIVO'), findsOneWidget);
        expect(find.text('MI CUENTA'), findsOneWidget);
        expect(find.text('AYUDA Y AJUSTES'), findsOneWidget);

        expect(find.text('Cuaderno'), findsOneWidget);
        expect(find.text('Avances'), findsOneWidget);
        expect(find.text('Resúmenes'), findsOneWidget);
        expect(find.text('Iniciar sesión'), findsOneWidget);
        expect(find.text('Idioma'), findsOneWidget);
        expect(find.text('Instrucciones'), findsOneWidget);
        expect(find.text('Créditos'), findsOneWidget);
        expect(find.text('Resetear Archivo'), findsOneWidget);
        expect(find.text('Salir'), findsOneWidget);
      },
    );

    testWidgets(
      'cuando hay sesión iniciada la fila de cuenta cambia su etiqueta '
      'de "Iniciar sesión" a "Sesión iniciada"',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: _menu(sesionIniciada: true),
        ));
        expect(find.text('Sesión iniciada'), findsOneWidget);
        expect(find.text('Iniciar sesión'), findsNothing);
      },
    );

    testWidgets(
      'tap en cada fila de "Mi archivo" dispara su callback',
      (tester) async {
        var cuaderno = 0, avances = 0, resumenes = 0, cuenta = 0;
        await tester.pumpWidget(MaterialApp(
          home: _menu(
            alAbrirCuaderno: () => cuaderno++,
            alAbrirAvances: () => avances++,
            alAbrirResumenes: () => resumenes++,
            alAbrirCuenta: () => cuenta++,
          ),
        ));

        await tester.tap(find.text('Cuaderno'));
        await tester.pump();
        await tester.tap(find.text('Avances'));
        await tester.pump();
        await tester.tap(find.text('Resúmenes'));
        await tester.pump();
        await tester.tap(find.text('Iniciar sesión'));
        await tester.pump();

        expect(cuaderno, 1);
        expect(avances, 1);
        expect(resumenes, 1);
        expect(cuenta, 1);
      },
    );

    testWidgets(
      'tap en Idioma abre diálogo trilingüe; elegir Euskara llama '
      'alCambiarIdioma con "eu" y cierra el diálogo',
      (tester) async {
        String? recibido;
        await tester.pumpWidget(MaterialApp(
          home: _menu(alCambiarIdioma: (codigo) => recibido = codigo),
        ));

        await tester.tap(find.text('Idioma'));
        await tester.pumpAndSettle();
        expect(find.text('Idioma de la app'), findsOneWidget);
        expect(find.text('Castellano'), findsOneWidget);
        expect(find.text('Euskara'), findsOneWidget);
        expect(find.text('Català'), findsOneWidget);

        await tester.tap(find.text('Euskara'));
        await tester.pumpAndSettle();

        expect(recibido, 'eu');
        expect(find.text('Idioma de la app'), findsNothing);
      },
    );

    testWidgets(
      'tap en Resetear Archivo abre diálogo de confirmación y SÍ, '
      'RESETEAR ejecuta el callback',
      (tester) async {
        var ejecutado = 0;
        await tester.pumpWidget(MaterialApp(
          home: _menu(alResetearArchivo: () async => ejecutado++),
        ));

        await tester.tap(find.text('Resetear Archivo'));
        await tester.pumpAndSettle();
        expect(find.text('¿Resetear el Archivo?'), findsOneWidget);

        await tester.tap(find.text('SÍ, RESETEAR'));
        await tester.pumpAndSettle();

        expect(ejecutado, 1);
      },
    );

    testWidgets(
      'tap en Instrucciones abre PantallaInstrucciones; tap en '
      'Créditos abre PantallaCreditos',
      (tester) async {
        await tester.pumpWidget(MaterialApp(home: _menu()));

        await tester.tap(find.text('Instrucciones'));
        await tester.pumpAndSettle();
        expect(find.byType(PantallaInstrucciones), findsOneWidget);
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Créditos'));
        await tester.pumpAndSettle();
        expect(find.byType(PantallaCreditos), findsOneWidget);
      },
    );
  });

  group('fila del ático', () {
    testWidgets('no aparece sin Brechas cerradas', (tester) async {
      await tester.pumpWidget(MaterialApp(home: _menu()));
      expect(find.text('El ático'), findsNothing);
    });

    testWidgets('aparece y abre con el callback', (tester) async {
      var abierto = false;
      await tester.pumpWidget(
          MaterialApp(home: _menu(alAbrirAtico: () => abierto = true)));
      await tester.tap(find.text('El ático'));
      expect(abierto, isTrue);
    });
  });
}
