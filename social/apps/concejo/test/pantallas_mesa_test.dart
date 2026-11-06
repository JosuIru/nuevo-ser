import 'package:concejo/dominio/asunto.dart';
import 'package:concejo/dominio/consentimiento.dart';
import 'package:concejo/dominio/debate.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

/// La lista vertical de la pantalla (los campos de texto de varias líneas
/// también son «scrollables» y confunden a scrollUntilVisible).
final _listaVertical = find
    .byWidgetPredicate((widget) =>
        widget is Scrollable && widget.axisDirection == AxisDirection.down)
    .first;

Future<void> _arrancar(WidgetTester tester, estado) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester
      .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la mesa crea un asunto y no lo puede abrir hasta completarlo',
      (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy);
    await _arrancar(tester, estado);

    await tester.tap(find.text('Nuevo asunto'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Título'), 'Arreglar el camino');
    await tester.enterText(
        find.widgetWithText(TextField, 'Resumen en tres líneas'),
        'Echar zahorra en los baches del camino del cementerio.');
    await tester.pump();

    final abrir = find.widgetWithText(FilledButton, 'Abrir el asunto');
    await tester.scrollUntilVisible(abrir, 300, scrollable: _listaVertical);
    // Falta el efecto sobre el entorno: el botón está desactivado y se dice qué falta.
    expect(tester.widget<FilledButton>(abrir).onPressed, isNull);
    expect(find.text('· el efecto sobre el entorno'), findsOneWidget);

    await tester.scrollUntilVisible(
        find.textContaining('Efecto sobre el entorno'), -300,
        scrollable: _listaVertical);
    await tester.enterText(
        find.widgetWithText(TextField, 'Efecto sobre el entorno'), 'Ninguno.');
    await tester.pump();
    await tester.scrollUntilVisible(abrir, 300, scrollable: _listaVertical);
    await tester.tap(abrir);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Abrir'));
    await tester.pumpAndSettle();

    final creado =
        estado.asuntos.firstWhere((a) => a.titulo == 'Arreglar el camino');
    expect(creado.abierto, isTrue);
    expect(creado.faseEn(_hoy), FaseAsunto.debate);
    expect(creado.creadoPorUid, 'ane');
  });

  testWidgets('una vecina no ve el botón de nuevo asunto', (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy)..verComo('maite');
    await _arrancar(tester, estado);
    expect(find.text('Nuevo asunto'), findsNothing);
  });

  testWidgets('la mesa publica una aportación sin nombre', (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy)..verComo('iker');
    estado.aportar('fiestas', TipoAportacion.duda, '¿Quién paga la orquesta?',
        anonima: true);
    estado.verComo('ane');
    await _arrancar(tester, estado);

    await tester.tap(find.text('¿Pasamos las fiestas a septiembre?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debate'));
    await tester.pumpAndSettle();
    final publicar = find.widgetWithText(TextButton, 'Publicar');
    await tester.ensureVisible(publicar);
    await tester.pumpAndSettle();
    await tester.tap(publicar);
    await tester.pumpAndSettle();
    expect(estado.debate('fiestas').pendientesDeModerar, isEmpty);
  });

  testWidgets('la mesa integra la objeción y cierra la vuelta', (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy);
    await _arrancar(tester, estado);

    await tester.tap(find.text('Normas para el uso de la leña del comunal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decidir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Integrar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last,
        'Las casas que solo se calientan con leña pueden pedir un segundo lote');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar la vuelta 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar'));
    await tester.pumpAndSettle();

    expect(estado.consentimiento('comunal').desenlace,
        DesenlaceConsentimiento.aprobada);
    expect(
        find.text('Aprobada por consentimiento: nadie mantiene una objeción.'),
        findsOneWidget);
  });
}
