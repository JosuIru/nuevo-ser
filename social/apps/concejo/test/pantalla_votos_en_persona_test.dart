import 'package:concejo/dominio/recuento.dart';
import 'package:concejo/dominio/urna.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  testWidgets('la mesa anota votos en papel, da de alta y pasa el conteo',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final estado = estadoDeEjemplo(hoy: _hoy);
    await tester
        .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Pasamos las fiestas a septiembre?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Votos en persona'));
    await tester.pumpAndSettle();

    // Pili vota en papel.
    await tester.tap(find.descendant(
        of: find.widgetWithText(ListTile, 'Pili'),
        matching: find.text('Anotar')));
    await tester.pumpAndSettle();
    expect(find.text('1 persona anotada en persona'), findsOneWidget);

    // Maritxu no estaba en la lista.
    await tester.tap(find.text('No está en la lista: darla de alta'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Maritxu');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Anotar'));
    await tester.pumpAndSettle();
    expect(find.text('2 personas anotadas en persona'), findsOneWidget);

    await tester.tap(find.text('Pasar el conteo de las papeletas'));
    await tester.pumpAndSettle();
    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), '1'); // Sí
    await tester.enterText(campos.at(1), '1'); // No
    await tester.pump();
    // El total viene propuesto: tantas como personas anotadas.
    expect(find.widgetWithText(TextField, '2'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mikel').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar el conteo'));
    await tester.pumpAndSettle();

    final urna = estado.urna('fiestas');
    expect(urna.conteosPresenciales.single.firmadoPorUids, ['ane', 'mikel']);
    expect(urna.avisos(), isEmpty);
    final resultado = contarVotacion(estado.asunto('fiestas').reglas, urna);
    expect((resultado.si, resultado.no), (1, 1));
    expect(urna.haParticipado('pili'), isTrue);
    expect(estado.personas.any((p) => p.nombre == 'Maritxu'), isTrue);
    expect(
        urna.participaciones
            .every((p) => p.canal == CanalParticipacion.presencial),
        isTrue);
  });
}
