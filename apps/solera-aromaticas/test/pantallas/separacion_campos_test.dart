import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show PaletaSolera, separacionCamposSolera, temaSolera;
import 'package:solera_aromaticas/dominio/catalogos.dart';
import 'package:solera_aromaticas/pantallas/campo_catalogo.dart';
import 'package:solera_aromaticas/pantallas/hoja_formulario.dart';
import 'package:solera_aromaticas/pantallas/pantalla_editar_origen.dart';

final _tema = temaSolera(
    const PaletaSolera(primario: Color(0xFF6B5B95), crema: Color(0xFFF6F0E6)));

/// Comprueba que entre cada campo y el siguiente (en vertical) queda al
/// menos la separación común. Los de una misma fila no cuentan.
void comprobarSeparacion(WidgetTester tester, {int minimoCampos = 2}) {
  final cajas = find.byType(InputDecorator);
  final rectangulos = [
    for (var indice = 0; indice < cajas.evaluate().length; indice++)
      tester.getRect(cajas.at(indice)),
  ]..sort((a, b) => a.top.compareTo(b.top));
  expect(rectangulos.length, greaterThanOrEqualTo(minimoCampos));
  for (var indice = 1; indice < rectangulos.length; indice++) {
    final anterior = rectangulos[indice - 1];
    final actual = rectangulos[indice];
    if (actual.top < anterior.bottom) continue; // misma fila
    expect(actual.top - anterior.bottom,
        greaterThanOrEqualTo(separacionCamposSolera),
        reason: 'campo ${indice + 1} pegado al anterior');
  }
}

void main() {
  testWidgets('los campos de la hoja de formulario no van pegados',
      (tester) async {
    final controladores = List.generate(3, (_) => TextEditingController());
    addTearDown(() {
      for (final controlador in controladores) {
        controlador.dispose();
      }
    });
    await tester.pumpWidget(MaterialApp(
      theme: _tema,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => mostrarHojaFormulario(
              context,
              titulo: 'Alta',
              construir: (_) => [
                campoTexto(controladores[0], 'Nombre'),
                CampoCatalogo(
                    controlador: controladores[1],
                    opciones: const <OpcionCatalogo>[],
                    etiqueta: 'Especie'),
                campoNumero(controladores[2], 'Kilos', ayuda: 'Frescos'),
              ],
              guardar: () async => false,
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    comprobarSeparacion(tester, minimoCampos: 3);
  });

  testWidgets('la ficha de parcela separa sus campos', (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: _tema, home: const PantallaEditarParcela()));
    await tester.pumpAndSettle();
    comprobarSeparacion(tester, minimoCampos: 4);
  });
}
