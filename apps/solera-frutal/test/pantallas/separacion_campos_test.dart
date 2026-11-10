import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_frutal/dominio/catalogos.dart';
import 'package:solera_frutal/pantallas/campo_catalogo.dart';
import 'package:solera_frutal/pantallas/hoja_formulario.dart';
import 'package:solera_frutal/pantallas/pantalla_parcelas.dart';

Widget _app(Widget hijo) => MaterialApp(
  theme: temaSolera(
    const PaletaSolera(primario: Color(0xFF7A5230), crema: Color(0xFFF6F0E6)),
  ),
  home: hijo,
);

/// Comprueba que entre los primeros [cuantos] campos seguidos hay al menos
/// la separación común del core.
void _comprobarSeparacion(WidgetTester tester, int cuantos) {
  final cajas = find.byType(InputDecorator);
  expect(cajas, findsAtLeastNWidgets(cuantos));
  for (var indice = 0; indice + 1 < cuantos; indice++) {
    final hueco =
        tester.getRect(cajas.at(indice + 1)).top -
        tester.getRect(cajas.at(indice)).bottom;
    expect(
      hueco,
      greaterThanOrEqualTo(separacionCamposSolera),
      reason: 'entre el campo $indice y el ${indice + 1}',
    );
  }
}

void main() {
  testWidgets('los helpers de campo dejan la separación común', (tester) async {
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
              selectorParcela(
                parcelas: const [],
                parcelaId: null,
                alCambiar: (_) {},
              ),
              CampoCatalogo(
                controlador: controladores[2],
                opciones: opcionesPlagas('almendro'),
                etiqueta: 'Catálogo',
              ),
            ],
          ),
        ),
      ),
    );
    _comprobarSeparacion(tester, 4);
  });

  testWidgets('la ficha de parcela no pega sus campos', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const PantallaEditarParcela()));
    await tester.pump();
    // Nombre, especie, variedad, superficie, marco, año y SIGPAC.
    _comprobarSeparacion(tester, 7);
  });
}
