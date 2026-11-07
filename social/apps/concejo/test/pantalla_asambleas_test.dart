import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

EstadoConcejo _pueblo(String personaUid, DateTime Function() reloj) =>
    instantaneaDesdeJson(instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
        personaActualUid: personaUid, reloj: reloj);

Future<void> _abrirAsambleas(WidgetTester tester, EstadoConcejo estado) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Asambleas'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('una vecina ve la próxima y lo hablado en la pasada',
      (tester) async {
    await _abrirAsambleas(tester, _pueblo('maite', () => _hoy));
    expect(find.text('Asamblea de noviembre'), findsOneWidget);
    expect(find.text('Convocar asamblea'), findsNothing);

    await tester.tap(find.text('Asamblea de octubre'));
    await tester.pumpAndSettle();
    expect(find.text('Vinieron 13 personas: 4 con la app y 9 sin ella.'),
        findsOneWidget);
    expect(find.textContaining('Piden arreglar la fuente'), findsOneWidget);
    expect(find.text('Apuntar lo hablado'), findsNothing);
  });

  testWidgets('la mesa convoca una asamblea con un asunto y la anula',
      (tester) async {
    final estado = _pueblo('ane', () => _hoy);
    await _abrirAsambleas(tester, estado);

    await tester.tap(find.text('Convocar asamblea'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Lugar'), 'Frontón cubierto');
    await tester.tap(find.text('Añadir un asunto'));
    await tester.pumpAndSettle();
    await tester
        .tap(find.text('Normas para el uso de la leña del comunal').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convocar'));
    await tester.pumpAndSettle();

    final nueva =
        estado.sesiones.firstWhere((s) => s.lugar == 'Frontón cubierto');
    expect(nueva.puntos.map((p) => p.texto), [
      'Normas para el uso de la leña del comunal',
      'Ruegos y preguntas',
    ]);
    expect(nueva.puntos.first.asuntoUid, 'comunal');

    await tester.tap(find.textContaining('Frontón cubierto'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anular la asamblea'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Llueve en el frontón');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Anular la asamblea'));
    await tester.pumpAndSettle();
    expect(find.text('Anulada: Llueve en el frontón'), findsOneWidget);
  });

  testWidgets('el día de la asamblea, la mesa apunta quién vino',
      (tester) async {
    final estado = _pueblo('ane', () => DateTime(2026, 11, 14, 18));
    await _abrirAsambleas(tester, estado);
    await tester.tap(find.text('Asamblea de noviembre'));
    await tester.pumpAndSettle();

    final pili = find.widgetWithText(CheckboxListTile, 'Pili');
    await tester.ensureVisible(pili);
    await tester.pumpAndSettle();
    await tester.tap(pili);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    expect(estado.sesion('noviembre').asistentesUids, {'pili'});
    expect(estado.sesion('noviembre').asistentesSinApp, 1);
  });
}
