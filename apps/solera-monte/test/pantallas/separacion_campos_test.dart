import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show PaletaSolera, separacionCamposSolera, temaSolera;
import 'package:solera_monte/branding.dart';
import 'package:solera_monte/pantallas/campo_catalogo.dart';
import 'package:solera_monte/pantallas/hoja_formulario.dart';

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
      primario: colorPrimarioMonte, crema: colorCremaMonte));

  testWidgets('los campos de una hoja no quedan pegados', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final texto = TextEditingController();
    final numero = TextEditingController();
    final especie = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: tema,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => mostrarHojaFormulario(
              context,
              titulo: 'Prueba',
              controladores: [texto, numero, especie],
              construir: (_) => [
                campoTexto(texto, 'Texto'),
                campoNumero(numero, 'Número'),
                CampoCatalogo(
                    controlador: especie,
                    opciones: const [(id: 'pino', nombre: 'Pino')],
                    etiqueta: 'Especie'),
                selectorId(
                    etiqueta: 'Rodal',
                    valor: null,
                    opciones: const [(1, 'R1')],
                    alCambiar: (_) {}),
                campoTexto(TextEditingController(), 'Notas', lineas: 2),
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
    comprobarSeparacion(tester, 5);
  });
}
