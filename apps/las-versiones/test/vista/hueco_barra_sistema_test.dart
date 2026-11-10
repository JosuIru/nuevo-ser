import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show GestorPerfiles;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_versiones/datos/repositorio_mosaico.dart';
import 'package:las_versiones/dominio/mosaico_arco_1.dart';
import 'package:las_versiones/dominio/mosaico_arco_2.dart';
import 'package:las_versiones/vista/pantalla_menu.dart';
import 'package:las_versiones/vista/pantalla_mosaico_arco_1.dart';
import 'package:las_versiones/vista/pantalla_mosaico_arco_2.dart';

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

/// Móvil corriente: 412 × 915 px lógicos, escala 3.
void simularMovil(WidgetTester tester) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(412 * 3, 915 * 3);
  simularBarraSistema(tester);
}

GestorPerfiles gestorDePrueba() => GestorPerfiles(
      namespace: 'nuevoser.lasversiones',
      sufijoNombreVisible: 'nombre_jugador',
      clavesGlobalesNoMigrables: const {'nuevoser.lasversiones.idioma_app'},
    );

/// Abre la hoja de confianza de cada pieza del Mosaico y comprueba que
/// cabe entera (sin desbordar) y que su último botón queda sobre la barra.
Future<void> recorrerHojasDeConfianza(
  WidgetTester tester,
  Widget pantalla,
  List<String> textosDePieza,
) async {
  await tester.pumpWidget(MaterialApp(home: pantalla));
  await tester.pumpAndSettle();
  for (final textoDePieza in textosDePieza) {
    final pieza = find.text(textoDePieza);
    await tester.scrollUntilVisible(pieza, 120,
        scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(pieza);
    await tester.pumpAndSettle();
    await tester.tap(pieza);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: textoDePieza);
    final ultimoBoton = find.text('DISPUTADO').last;
    expect(tester.getRect(ultimoBoton).bottom,
        lessThanOrEqualTo(altoPantalla(tester) - alturaBarraSistema),
        reason: textoDePieza);
    await tester.tap(ultimoBoton);
    await tester.pumpAndSettle();
  }
}

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

  group('hojas de confianza de los Mosaicos', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('M1: cada hoja cabe y su último botón queda sobre la barra',
        (tester) async {
      simularMovil(tester);
      await recorrerHojasDeConfianza(
        tester,
        PantallaMosaicoArco1(
          alEntregar: () async {},
          repoMosaico: RepositorioMosaico(gestor: gestorDePrueba()),
        ),
        [for (final vineta in MosaicoArco1.vinetas) vineta.pieDescriptivo],
      );
    });

    testWidgets('M2: cada hoja cabe y su último botón queda sobre la barra',
        (tester) async {
      simularMovil(tester);
      await recorrerHojasDeConfianza(
        tester,
        PantallaMosaicoArco2(
          alEntregar: () async {},
          repoMosaico: RepositorioMosaico(gestor: gestorDePrueba()),
        ),
        [for (final fragmento in MosaicoArco2.fragmentos) fragmento.textoLeido],
      );
    });
  });
}
