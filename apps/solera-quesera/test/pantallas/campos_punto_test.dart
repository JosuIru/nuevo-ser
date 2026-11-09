import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_quesera/datos/base_datos.dart';
import 'package:solera_quesera/pantallas/pantalla_lista_proveedores.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  setUp(entorno.preparar);
  tearDown(() async {
    await BaseDatosSoleraQuesera.instancia.cerrar();
    await entorno.limpiar();
  });

  testWidgets('la ficha de un proveedor nuevo ofrece marcar su punto',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(home: PantallaListaProveedores()));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    final marcarPunto = find.text(SoleraL10n.t('mapa.marcar_punto'));
    await tester.scrollUntilVisible(marcarPunto, 200,
        scrollable: find.byType(Scrollable).first);
    expect(marcarPunto, findsOneWidget);
  });
}
