import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_huerta/dominio/catalogos.dart';
import 'package:solera_huerta/pantallas/campo_catalogo.dart';
import 'package:solera_huerta/pantallas/hoja_formulario.dart';

Widget _app(Widget hijo) => MaterialApp(
      theme: temaSolera(
        const PaletaSolera(
            primario: Color(0xFF4A7A2E), crema: Color(0xFFF6F0E6)),
      ),
      home: hijo,
    );

void main() {
  testWidgets('los campos de formulario seguidos no se pegan', (tester) async {
    final controladores = List.generate(3, (_) => TextEditingController());
    addTearDown(() {
      for (final controlador in controladores) {
        controlador.dispose();
      }
    });
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Column(
            children: [
              campoTexto(controladores[0], 'Texto'),
              campoNumero(controladores[1], 'Número'),
              desplegable<String>(
                etiqueta: 'Lista',
                valor: 'a',
                opciones: const ['a', 'b'],
                nombre: (opcion) => opcion,
                alCambiar: (_) {},
              ),
              CampoCatalogo(
                controlador: controladores[2],
                opciones: opcionesEspecies(),
                etiqueta: 'Especie',
              ),
            ],
          ),
        ),
      ),
    );
    final cajas = find.byType(InputDecorator);
    expect(cajas, findsNWidgets(4));
    for (var indice = 0; indice < 3; indice++) {
      final hueco = tester.getRect(cajas.at(indice + 1)).top -
          tester.getRect(cajas.at(indice)).bottom;
      expect(
        hueco,
        greaterThanOrEqualTo(separacionCamposSolera),
        reason: 'entre el campo $indice y el ${indice + 1}',
      );
    }
  });
}
