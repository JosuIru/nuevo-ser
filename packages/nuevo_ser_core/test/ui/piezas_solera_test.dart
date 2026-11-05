import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

const _paleta =
    PaletaSolera(primario: Color(0xFF7D2A2A), crema: Color(0xFFF6F0E6));

Widget _app(Widget hijo) =>
    MaterialApp(theme: temaSolera(_paleta), home: hijo);

void main() {
  testWidgets('la cabecera de Hoy enseña título, fecha y cifras sin desbordar',
      (tester) async {
    tester.view.physicalSize = const Size(720, 1600); // 360 dp de ancho
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(_app(Scaffold(
      body: ListView(children: [
        CabeceraHoySolera(
          titulo: 'Hoy',
          acciones: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu_book)),
          ],
          fecha: 'Jueves, 5 de noviembre',
          cifras: const [
            CifraCabecera(
                valor: '12', etiqueta: 'Partidas de leche hoy', detalle: '840 L'),
            CifraCabecera(valor: '3', etiqueta: 'Afinando'),
            CifraCabecera(valor: '27', etiqueta: 'Listas para vender'),
          ],
        ),
      ]),
    )));
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Jueves, 5 de noviembre'), findsOneWidget);
    expect(find.text('840 L'), findsOneWidget);
    // Los iconos de las acciones, del color del texto de la cabecera (no el
    // gris que el tema da a los IconButton).
    final contexto = tester.element(find.byIcon(Icons.menu_book));
    final colorIcono = IconTheme.of(contexto).color;
    final sobreCabecera =
        Theme.of(contexto).extension<ColoresSolera>()!.sobreCabecera;
    expect(colorIcono, sobreCabecera);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la barra de guardar reparte los botones y se pulsan',
      (tester) async {
    var guardado = 0;
    await tester.pumpWidget(_app(Scaffold(
      bottomNavigationBar: BarraGuardarSolera(botones: [
        OutlinedButton(onPressed: () {}, child: const Text('Guardar y otro')),
        FilledButton(
            onPressed: () => guardado++,
            child: textoOGuardando('Guardar', guardando: false)),
      ]),
    )));
    await tester.tap(find.text('Guardar'));
    expect(guardado, 1);
    final anchoUno = tester.getSize(find.byType(OutlinedButton)).width;
    final anchoOtro = tester.getSize(find.byType(FilledButton)).width;
    expect(anchoUno, closeTo(anchoOtro, 0.5));
  });

  testWidgets('textoOGuardando pone una rueda mientras guarda', (tester) async {
    await tester.pumpWidget(_app(Scaffold(
        body: textoOGuardando('Guardar', guardando: true))));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Guardar'), findsNothing);
  });
}
