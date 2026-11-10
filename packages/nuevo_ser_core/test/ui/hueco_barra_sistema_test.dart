import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Barra de navegación de Android de 48 px lógicos (edge-to-edge).
const double alturaBarraSistema = 48;

/// Teclado de 300 px lógicos.
const double alturaTeclado = 300;

/// Simula la barra del sistema y, si [conTeclado], el teclado abierto, como
/// lo reporta Android: con teclado, `padding` baja a 0 y `viewPadding` sigue.
void simularBarraSistema(WidgetTester tester, {bool conTeclado = false}) {
  final escala = tester.view.devicePixelRatio;
  tester.view.viewPadding =
      FakeViewPadding(bottom: alturaBarraSistema * escala);
  tester.view.padding =
      FakeViewPadding(bottom: conTeclado ? 0 : alturaBarraSistema * escala);
  if (conTeclado) {
    tester.view.viewInsets = FakeViewPadding(bottom: alturaTeclado * escala);
  }
  addTearDown(tester.view.reset);
}

double altoPantalla(WidgetTester tester) =>
    tester.view.physicalSize.height / tester.view.devicePixelRatio;

Future<void> abrirHoja(WidgetTester tester, Widget Function() contenido,
    {bool isScrollControlled = false}) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => mostrarHojaSolera<void>(
              context: context,
              isScrollControlled: isScrollControlled,
              margen: const EdgeInsets.all(16),
              builder: (_) => contenido(),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  group('rellenoInferiorSeguro', () {
    testWidgets('suma el hueco de la barra al padding de una lista',
        (tester) async {
      simularBarraSistema(tester);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ListView(
              padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
              children: [
                for (var indice = 0; indice < 30; indice++)
                  SizedBox(height: 60, child: Text('fila $indice')),
                FilledButton(onPressed: () {}, child: const Text('último')),
              ],
            ),
          ),
        ),
      ));
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      final abajoBoton = tester.getRect(find.byType(FilledButton)).bottom;
      expect(abajoBoton,
          lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema));
    });

    testWidgets('no suma nada si el Scaffold ya tiene bottomNavigationBar',
        (tester) async {
      simularBarraSistema(tester);
      late EdgeInsets margenCalculado;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: const SizedBox(height: 56),
          body: Builder(builder: (context) {
            margenCalculado =
                rellenoInferiorSeguro(context, const EdgeInsets.all(16));
            return const SizedBox.expand();
          }),
        ),
      ));
      expect(margenCalculado, const EdgeInsets.all(16));
    });

    testWidgets('dentro de un SafeArea no se suma dos veces', (tester) async {
      simularBarraSistema(tester);
      late EdgeInsets margenCalculado;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Builder(builder: (context) {
              margenCalculado =
                  rellenoInferiorSeguro(context, const EdgeInsets.all(16));
              return const SizedBox.expand();
            }),
          ),
        ),
      ));
      expect(margenCalculado, const EdgeInsets.all(16));
    });
  });

  group('mostrarHojaSolera', () {
    testWidgets('el botón de la hoja queda por encima de la barra',
        (tester) async {
      simularBarraSistema(tester);
      await abrirHoja(
          tester,
          () => Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('campo'),
                FilledButton(onPressed: () {}, child: const Text('Guardar')),
              ]));
      final abajoBoton = tester.getRect(find.byType(FilledButton)).bottom;
      expect(abajoBoton,
          moreOrLessEquals(altoPantalla(tester) - alturaBarraSistema - 16));
    });

    testWidgets('con teclado deja el hueco del teclado, sin sumar la barra',
        (tester) async {
      simularBarraSistema(tester, conTeclado: true);
      await abrirHoja(
          tester,
          () => Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('campo'),
                FilledButton(onPressed: () {}, child: const Text('Guardar')),
              ]),
          isScrollControlled: true);
      final abajoBoton = tester.getRect(find.byType(FilledButton)).bottom;
      expect(abajoBoton,
          moreOrLessEquals(altoPantalla(tester) - alturaTeclado - 16));
    });

    testWidgets('un SafeArea dentro de la hoja no vuelve a sumar el hueco',
        (tester) async {
      simularBarraSistema(tester);
      await abrirHoja(
          tester,
          () => SafeArea(
                child: FilledButton(
                    onPressed: () {}, child: const Text('Guardar')),
              ));
      final abajoBoton = tester.getRect(find.byType(FilledButton)).bottom;
      expect(abajoBoton,
          moreOrLessEquals(altoPantalla(tester) - alturaBarraSistema - 16));
    });
  });

  group('margenHojaSegura', () {
    testWidgets('toma el mayor entre teclado y barra', (tester) async {
      late EdgeInsets sinTeclado;
      late EdgeInsets conTeclado;
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(
          padding: EdgeInsets.only(bottom: alturaBarraSistema),
          viewPadding: EdgeInsets.only(bottom: alturaBarraSistema),
        ),
        child: Builder(builder: (context) {
          sinTeclado = margenHojaSegura(context, const EdgeInsets.all(16));
          return MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: alturaBarraSistema),
              viewPadding: EdgeInsets.only(bottom: alturaBarraSistema),
              viewInsets: EdgeInsets.only(bottom: alturaTeclado),
            ),
            child: Builder(builder: (contextoTeclado) {
              conTeclado =
                  margenHojaSegura(contextoTeclado, const EdgeInsets.all(16));
              return const SizedBox();
            }),
          );
        }),
      ));
      expect(sinTeclado.bottom, 16 + alturaBarraSistema);
      expect(conTeclado.bottom, 16 + alturaTeclado);
      expect(conTeclado.top, 16);
    });
  });
}
