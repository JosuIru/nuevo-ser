import 'package:concejo/dominio/asunto.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  testWidgets('la lista enseña primero lo que se decide ahora', (tester) async {
    await tester.pumpWidget(AppConcejo(
        estado: estadoDeEjemplo(hoy: _hoy), idioma: const Locale('es')));
    await tester.pumpAndSettle();
    expect(find.text('Se decide ahora'), findsOneWidget);
    expect(find.text('¿Pasamos las fiestas a septiembre?'), findsOneWidget);
    // Lo ya decidido va al final de la lista.
    await tester.scrollUntilVisible(
        find.text('Horario del local vecinal'), 200);
    expect(find.text('Decidido'), findsOneWidget);
  });

  testWidgets('votar sí en las fiestas y no poder votar otra vez',
      (tester) async {
    final estado = estadoDeEjemplo(hoy: _hoy);
    expect(estado.asunto('fiestas').faseEn(_hoy), FaseAsunto.decision);
    await tester
        .pumpWidget(AppConcejo(estado: estado, idioma: const Locale('es')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Pasamos las fiestas a septiembre?'));
    await tester.pumpAndSettle();
    // Abre directamente en «Decidir» porque está en fase de decisión.
    expect(find.text('Enviar mi voto'), findsOneWidget);

    await tester.tap(find.text('Sí'));
    await tester.pump();
    await tester.tap(find.text('Enviar mi voto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Ya has participado. Gracias.'), findsOneWidget);
    expect(estado.urna('fiestas').haParticipado('ane'), isTrue);
    expect(estado.urna('fiestas').papeletas.single.personaUid, isNull);
  });

  testWidgets('el resultado del local enseña la opción más aceptada',
      (tester) async {
    await tester.pumpWidget(AppConcejo(
        estado: estadoDeEjemplo(hoy: _hoy), idioma: const Locale('es')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('Horario del local vecinal'), 200);
    await tester.tap(find.text('Horario del local vecinal'));
    await tester.pumpAndSettle();
    // 4 en la app + 1 en papel; «hasta las 23:00» la aceptan 4.
    expect(find.text('Han participado 5 personas'), findsOneWidget);
    expect(find.text('Más aceptada'), findsOneWidget);
  });

  testWidgets('arranca en euskera', (tester) async {
    await tester.pumpWidget(AppConcejo(
        estado: estadoDeEjemplo(hoy: _hoy), idioma: const Locale('eu')));
    await tester.pumpAndSettle();
    expect(find.text('Orain erabakitzen da'), findsOneWidget);
    expect(find.text('Egin da?'), findsOneWidget);
  });
}
