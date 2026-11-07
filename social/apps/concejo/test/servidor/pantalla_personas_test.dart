import 'package:concejo/main.dart';
import 'package:concejo/servidor/almacen_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'servidor_de_prueba.dart';

void main() {
  testWidgets('la mesa saca el código de una vecina y da de alta a otra',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final servidor = ServidorDePrueba()..yo = 'ane';
    await tester.pumpWidget(RaizConcejo(
        almacen: AlmacenEnMemoria(),
        clienteHttp: servidor.cliente(),
        idioma: const Locale('es')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Dirección que te ha dado la mesa'),
        'pueblo.eus');
    await tester.enterText(
        find.widgetWithText(TextField, 'Tu código'), servidor.codigoValido);
    await tester.pump();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Personas'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.widgetWithText(ListTile, 'Pili'),
        matching: find.text('Sacar código')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sacar código'));
    await tester.pumpAndSettle();
    expect(find.text('Código de Pili'), findsOneWidget);
    expect(find.text('ABCD-EFGH-JKMN'), findsOneWidget);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
    expect(servidor.codigosSacados, ['pili']);

    // Alta: primero se envía el alta y después se pide su código.
    await tester.tap(find.text('Dar de alta a alguien'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Maritxu');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sacar código'));
    await tester.pumpAndSettle();
    expect(find.text('Código de Maritxu'), findsOneWidget);
    expect(servidor.verdad.personas.any((p) => p.nombre == 'Maritxu'), isTrue);
    expect(servidor.codigosSacados, hasLength(2));

    await tester.pumpWidget(const SizedBox());
  });
}
