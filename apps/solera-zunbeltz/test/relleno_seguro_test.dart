// Los formularios dejan sitio a la barra de navegación del sistema, para que
// el botón Guardar no quede tapado en móviles de pantalla completa.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/pantallas/widgets/relleno_seguro.dart';

void main() {
  testWidgets('Suma el hueco inferior del sistema al relleno base',
      (tester) async {
    late EdgeInsets relleno;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(padding: EdgeInsets.only(bottom: 48)),
      child: Builder(builder: (context) {
        relleno = rellenoSobreBarraSistema(context, const EdgeInsets.all(16));
        return const SizedBox();
      }),
    ));
    expect(relleno, const EdgeInsets.fromLTRB(16, 16, 16, 64));
  });
}
