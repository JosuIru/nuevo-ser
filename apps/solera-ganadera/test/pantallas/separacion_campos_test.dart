import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_ganadera/pantallas/formularios_ganado.dart';
import 'package:solera_ganadera/pantallas/hoja_formulario.dart';
import 'package:solera_ganadera/pantallas/pantalla_manejo.dart';

Widget _app(Widget hijo) => MaterialApp(
      theme: temaSolera(
        const PaletaSolera(
            primario: Color(0xFF6B4E3D), crema: Color(0xFFF6F0E6)),
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
              desplegableCodigo(
                etiqueta: 'Código',
                valor: 'a',
                opciones: const ['a', 'b'],
                nombre: (codigo) => codigo,
                alCambiar: (_) {},
              ),
              campoConSugerencias(controladores[2], 'Raza', const ['Tudanca']),
              selectorLote(const [], null, (_) {}),
            ],
          ),
        ),
      ),
    );
    final cajas = find.byType(InputDecorator);
    expect(cajas, findsNWidgets(5));
    for (var indice = 0; indice < 4; indice++) {
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
