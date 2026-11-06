import 'package:concejo/main.dart';
import 'package:concejo/servidor/almacen_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'servidor_de_prueba.dart';

void main() {
  testWidgets('entrar con el código y volver a abrir ya dentro',
      (tester) async {
    final servidor = ServidorDePrueba();
    final almacen = AlmacenEnMemoria();
    Widget raiz() => RaizConcejo(
        almacen: almacen,
        clienteHttp: servidor.cliente(),
        idioma: const Locale('es'));
    await tester.pumpWidget(raiz());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Dirección del pueblo'),
        'concejo.ejemplo.eus');
    await tester.enterText(
        find.widgetWithText(TextField, 'Tu código'), 'MAL-CODIGO');
    await tester.pump();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Ese código no vale. Revísalo o pide otro a la mesa.'),
        findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Tu código'), servidor.codigoValido);
    await tester.pump();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Concejo de Ejemplo'), findsOneWidget);
    // Fuera del ejemplo no se puede ver la app como otra persona.
    expect(find.byTooltip('Ver como…'), findsNothing);

    // Se cierra y se abre: entra directamente.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(raiz());
    await tester.pumpAndSettle();
    expect(find.text('Concejo de Ejemplo'), findsOneWidget);

    // Sin red, se avisa.
    servidor.conRed = false;
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Actualizar'));
    await tester.pumpAndSettle();
    expect(
        find.text('Sin conexión: lo que hagas se guarda y se enviará después.'),
        findsOneWidget);
    // Que se liberen los temporizadores.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ver el pueblo de ejemplo y salir', (tester) async {
    await tester.pumpWidget(
        RaizConcejo(almacen: AlmacenEnMemoria(), idioma: const Locale('es')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver el pueblo de ejemplo'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ver como…'), findsOneWidget);
    await tester.tap(find.byTooltip('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Entra en tu concejo'), findsOneWidget);
  });
}
