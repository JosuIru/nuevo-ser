import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show PaletaSolera, separacionCamposSolera, temaSolera;
import 'package:solera_obrador/branding.dart';
import 'package:solera_obrador/pantallas/hoja_formulario.dart';
import 'package:solera_obrador/pantallas/pantalla_ingredientes.dart';

/// Comprueba que entre cada campo y el siguiente queda, al menos, la
/// separación común de los formularios.
void comprobarSeparacion(WidgetTester tester, int camposEsperados) {
  final cajas = find.byType(InputDecorator);
  expect(cajas, findsNWidgets(camposEsperados));
  for (var indice = 0; indice + 1 < camposEsperados; indice++) {
    final hueco = tester.getRect(cajas.at(indice + 1)).top -
        tester.getRect(cajas.at(indice)).bottom;
    expect(hueco, greaterThanOrEqualTo(separacionCamposSolera),
        reason: 'entre el campo $indice y el ${indice + 1}');
  }
}

void main() {
  final tema = temaSolera(const PaletaSolera(
      primario: colorPrimarioObrador, crema: colorCremaObrador));

  testWidgets('los campos de una hoja no quedan pegados', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final texto = TextEditingController();
    final numero = TextEditingController();
    final otro = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: tema,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => mostrarHojaFormulario(
              context,
              titulo: 'Prueba',
              controladores: [texto, numero, otro],
              construir: (_) => [
                campoTexto(texto, 'Texto'),
                campoNumero(numero, 'Número'),
                campoTexto(otro, 'Otro'),
              ],
              guardar: () async => true,
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    comprobarSeparacion(tester, 3);
  });

  testWidgets('la ficha de un ingrediente nuevo separa sus campos',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        MaterialApp(theme: tema, home: const PantallaEditarIngrediente()));
    await tester.pumpAndSettle();
    // Nombre (autocompletado), proveedor, precio y sal.
    comprobarSeparacion(tester, 4);
  });
}
