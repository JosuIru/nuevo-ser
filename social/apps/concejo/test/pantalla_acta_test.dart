import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);
void main() {
  testWidgets('dos personas de la mesa firman el acta desde el resultado',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final estado = estadoDeEjemplo(hoy: _hoy);
    await tester
        .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
    await tester.pumpAndSettle();

    final titulo = find.text('Horario del local vecinal');
    await tester.scrollUntilVisible(titulo, 200);
    // Que no quede debajo del botón flotante.
    await Scrollable.ensureVisible(tester.element(titulo), alignment: 0.3);
    await tester.pumpAndSettle();
    await tester.tap(titulo);
    // Un asunto cerrado se abre por el resultado.
    await tester.pumpAndSettle();

    final firmar = find.text('Firmar el acta');
    await tester.ensureVisible(firmar);
    await tester.pumpAndSettle();
    expect(find.text('Borrador: sin firmas de la mesa'), findsOneWidget);
    expect(find.text('Votos en persona'), findsOneWidget);
    await tester.tap(firmar);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Firmar'));
    await tester.pumpAndSettle();

    expect(find.text('Borrador: tiene 1 de las 2 firmas de la mesa'),
        findsOneWidget);
    expect(find.text('Retirar mi firma'), findsOneWidget);
    // Con una firma, el conteo en papel ya no se toca.
    expect(find.text('Votos en persona'), findsNothing);

    estado.verComo('mikel');
    await tester.pumpAndSettle();
    await tester.ensureVisible(firmar);
    await tester.pumpAndSettle();
    await tester.tap(firmar);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Firmar'));
    await tester.pumpAndSettle();

    expect(find.text('Acta firmada por Ane y Mikel.'), findsOneWidget);
    expect(find.text('Firmar el acta'), findsNothing);
    expect(find.text('Retirar mi firma'), findsNothing);
    expect(estado.acta('txoko').definitiva, isTrue);
  });
}
