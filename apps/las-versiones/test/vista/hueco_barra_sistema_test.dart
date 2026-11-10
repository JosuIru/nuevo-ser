import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:las_versiones/vista/pantalla_menu.dart';

/// Barra de navegación de Android de 48 px lógicos (edge-to-edge,
/// Android 15+, targetSdk ≥ 35): el último botón tiene que quedar por
/// encima al llegar al final del scroll.
const double alturaBarraSistema = 48;

void simularBarraSistema(WidgetTester tester) {
  final escala = tester.view.devicePixelRatio;
  tester.view.viewPadding =
      FakeViewPadding(bottom: alturaBarraSistema * escala);
  tester.view.padding = FakeViewPadding(bottom: alturaBarraSistema * escala);
  addTearDown(tester.view.reset);
}

double altoPantalla(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

void main() {
  testWidgets('menú: «Salir», la última fila, queda sobre la barra del sistema',
      (tester) async {
    simularBarraSistema(tester);
    await tester.pumpWidget(MaterialApp(
      home: PantallaMenu(
        alAbrirCuaderno: () {},
        alAbrirAvances: () {},
        alAbrirResumenes: () {},
        alAbrirCuenta: () {},
        alAbrirPerfiles: () {},
        alAbrirAjustesAudio: () {},
        nombrePerfilActivo: 'Maren',
        sesionIniciada: false,
        alCambiarIdioma: (_) {},
        idiomaActivo: 'es',
        alResetearArchivo: () async {},
      ),
    ));

    for (var vuelta = 0; vuelta < 5; vuelta++) {
      final posicion =
          tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      posicion.jumpTo(posicion.maxScrollExtent);
      await tester.pump();
    }

    // Se mide el subtítulo, lo más bajo de la fila «Salir».
    final abajoSalir =
        tester.getRect(find.textContaining('Cierra la app')).bottom;
    expect(abajoSalir,
        lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema));
  });
}
