import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/main.dart';
import 'package:concejo/pantallas/ficha_asunto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  testWidgets('«Para ti» arriba, y el aviso se quita', (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy)..verComo('mikel');
    await tester
        .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
    await tester.pumpAndSettle();

    expect(find.text('Para ti'), findsOneWidget);
    final vencido = find.text('Compromiso que venció el 7 de noviembre: '
        'Poner el cartel con el horario nuevo en la puerta del local.');
    expect(vencido, findsOneWidget);

    await tester.tap(find.byTooltip('Quitar aviso'));
    await tester.pumpAndSettle();
    expect(vencido, findsNothing);
    expect(find.text('Para ti'), findsNothing);
  });

  testWidgets('«Nuevo» en la tarjeta hasta que se abre el asunto',
      (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy)..verComo('maite');
    await tester
        .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
    await tester.pumpAndSettle();
    // A una vecina, hoy, nada le pide actuar ya: no hay «Para ti».
    expect(find.text('Para ti'), findsNothing);
    const comunal = 'Normas para el uso de la leña del comunal';
    Finder etiquetaNuevo() => find.descendant(
        of: find.ancestor(of: find.text(comunal), matching: find.byType(Card)),
        matching: find.text('Nuevo'));
    await tester.ensureVisible(find.text(comunal));
    await tester.pumpAndSettle();
    expect(etiquetaNuevo(), findsOneWidget);

    await tester.tap(find.text(comunal));
    await tester.pumpAndSettle();
    expect(find.byType(FichaAsunto), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(comunal));
    expect(etiquetaNuevo(), findsNothing);
  });
}
