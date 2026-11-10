import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_arbolado_urbano/modelos/zona.dart';
import 'package:solera_arbolado_urbano/pantallas/pantalla_editar_zona.dart';

void main() {
  testWidgets('la ficha de la zona ofrece marcar su área', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarZona()));
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('mapa.marcar_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
  });

  testWidgets('sin nombre no se guarda', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarZona()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(SoleraL10n.t('guardar')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        SoleraL10n.tf('arb.campo_obligatorio', {
          'campo': SoleraL10n.t('arb.nombre'),
        }),
      ),
      findsOneWidget,
    );
  });

  testWidgets('el código municipal de la zona se ve y se edita', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaEditarZona(
          zona: Zona(
            id: 3,
            nombre: 'Paseo del Valle',
            codigoMunicipal: 'PASEO-VALLE',
            fechaCreacionMs: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(SoleraL10n.t('arb.codigo_municipal')), findsOneWidget);
    expect(find.text('PASEO-VALLE'), findsOneWidget);
  });
}
