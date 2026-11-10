import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solera_quesera/pantallas/pantalla_libro_economico.dart';

void main() {
  testWidgets('el libro económico se abre sin TabController de fuera',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaLibroEconomico()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(TabBar), findsOneWidget);
  });
}
