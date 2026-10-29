import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/src/ia/estado_clave_anthropic.dart';
import 'package:nuevo_ser_core/src/ia/pantalla_clave_anthropic.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const claveDePrueba = 'sk-ant-api03-abcdefghijklmnop';

  Future<void> montar(WidgetTester tester, Widget pantalla) async {
    // Pantalla alta para que el ListView construya todos los botones.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: pantalla));
    await tester.pumpAndSettle();
  }

  testWidgets('escribir y guardar pasa la clave al estado', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final estado = EstadoClaveAnthropic.paraApp('agro');
    await montar(
        tester,
        PantallaClaveAnthropic(
            estado: estado, nombreApp: 'Larrea', titulo: 'IA de prueba'));

    expect(find.text('IA de prueba'), findsOneWidget);
    expect(find.text('Probar la clave'), findsNothing);
    expect(find.text('Borrar'), findsNothing);

    await tester.enterText(
        find.byKey(const ValueKey('campo_clave_anthropic')), claveDePrueba);
    await tester.tap(find.text('Guardar clave'));
    await tester.pumpAndSettle();

    expect(estado.hayClave.value, isTrue);
    expect(await estado.cargar(), claveDePrueba);
    expect(find.text('Borrar'), findsOneWidget);

    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();
    expect(await estado.cargar(), isNull);
  });

  testWidgets('carga la clave ya guardada', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'solera_apicola.anthropic.clave': claveDePrueba});
    await montar(
        tester,
        PantallaClaveAnthropic(
            estado: EstadoClaveAnthropic.paraApp('solera_apicola')));
    final campo = tester.widget<TextField>(
        find.byKey(const ValueKey('campo_clave_anthropic')));
    expect(campo.controller!.text, claveDePrueba);
    expect(campo.obscureText, isTrue);
  });

  testWidgets('con probador muestra el botón y el resultado', (tester) async {
    SharedPreferences.setMockInitialValues({});
    String? claveRecibida;
    await montar(
      tester,
      PantallaClaveAnthropic(
        estado: EstadoClaveAnthropic.paraApp('agro'),
        probarClave: (clave) async {
          claveRecibida = clave;
          return 'Clave no válida';
        },
      ),
    );
    await tester.enterText(
        find.byKey(const ValueKey('campo_clave_anthropic')), claveDePrueba);
    await tester.tap(find.text('Probar la clave'));
    await tester.pumpAndSettle();
    expect(claveRecibida, claveDePrueba);
    expect(find.text('Clave no válida'), findsOneWidget);
  });
}
