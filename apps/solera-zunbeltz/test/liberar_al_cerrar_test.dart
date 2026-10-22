// Los controladores de texto de un diálogo abierto desde una función se
// liberan cuando el diálogo termina de cerrarse (no justo tras el `await`,
// que rompe: la animación de cierre todavía pinta los campos).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/pantallas/widgets/liberar_al_cerrar.dart';

void main() {
  testWidgets('se leen tras el await y se liberan al cerrar, sin errores',
      (tester) async {
    late BuildContext contextoPantalla;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (contexto) {
      contextoPantalla = contexto;
      return const Scaffold();
    })));

    final controlador = TextEditingController(text: 'hola');
    String? leido;
    Future<void> abrirDialogo() async {
      await showDialog<bool>(
        context: contextoPantalla,
        builder: (contexto) => LiberarAlCerrar(
          controladores: [controlador],
          child: AlertDialog(
            content: TextField(controller: controlador, autofocus: true),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(contexto, true),
                  child: const Text('Vale')),
            ],
          ),
        ),
      );
      leido = controlador.text;
    }

    abrirDialogo();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'agur');
    await tester.tap(find.text('Vale'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(leido, 'agur');
    // Liberado: ya no admite escuchas.
    expect(() => controlador.addListener(() {}), throwsFlutterError);
  });
}
