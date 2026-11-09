import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show codificarContorno;
import 'package:solera_sidra/datos/base_datos.dart';
import 'package:solera_sidra/estado/cambios_datos.dart';
import 'package:solera_sidra/modelos/embotellado.dart';
import 'package:solera_sidra/modelos/kupela.dart';
import 'package:solera_sidra/modelos/partida_manzana.dart';
import 'package:solera_sidra/modelos/pomarada.dart';
import 'package:solera_sidra/modelos/prensado.dart';
import 'package:solera_sidra/modelos/sagardotegi.dart';
import 'package:solera_sidra/modelos/sesion_txotx.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_sidra/pantallas/pantalla_ayuda.dart';
import 'package:solera_sidra/pantallas/pantalla_bodega.dart';
import 'package:solera_sidra/pantallas/pantalla_embotellados.dart';
import 'package:solera_sidra/pantallas/pantalla_hoy.dart';
import 'package:solera_sidra/pantallas/pantalla_kupela.dart';
import 'package:solera_sidra/pantallas/pantalla_mapa_pomaradas.dart';
import 'package:solera_sidra/pantallas/pantalla_partidas.dart';
import 'package:solera_sidra/pantallas/pantalla_pomaradas.dart';
import 'package:solera_sidra/pantallas/pantalla_prensados.dart';
import 'package:solera_sidra/pantallas/pantalla_txotx.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraSidra.instancia;

  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Pantalla alta: los formularios caben sin desplazar.
  void pantallaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> esperar(WidgetTester tester) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  /// Una kupela con 1000 l de mosto, 120 l servidos en el txotx de hoy y
  /// un lote de 100 botellas de 0,75 l.
  Future<int> bodegaDePrueba() async {
    final kupela = await baseDatos
        .guardarKupela(Kupela(codigo: 'K7', capacidadLitros: 5000));
    final partida = await baseDatos.guardarPartida(PartidaManzana(
        fechaEntregaMs: DateTime.now().millisecondsSinceEpoch - 100000,
        kilos: 1500,
        propia: false,
        proveedor: 'Auzoko baserria'));
    await baseDatos.guardarPrensado(
        Prensado(
            fechaMs: DateTime.now().millisecondsSinceEpoch - 90000,
            kupelaId: kupela,
            kilosFruta: 1500,
            litrosMosto: 1000),
        partidas: [partida]);
    await baseDatos.guardarSesionTxotx(SesionTxotx(
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        kupelaId: kupela,
        litrosServidos: 120));
    await baseDatos.guardarEmbotellado(Embotellado(
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        kupelaId: kupela,
        codigoLote: 'L-K7',
        botellas: 100));
    return kupela;
  }

  testWidgets('alta de una pomarada desde la lista', (tester) async {
    pantallaAlta(tester);
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaPomaradas()));
      // Primera apertura de la BD del fichero: con la máquina cargada tarda.
      await esperar(tester);
      await esperar(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await esperar(tester);
      await tester.enterText(find.byType(TextField).first, 'Goiko sagastia');
      final lista = find
          .descendant(
              of: find.byType(PantallaEditarPomarada),
              matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byType(FilledButton), 300,
          scrollable: lista);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await esperar(tester);
      await esperar(tester);
    });
    expect(find.text('Goiko sagastia'), findsOneWidget);
    expect((await tester.runAsync(baseDatos.listarPomaradas))!.single.cultivo,
        'manzano');
  });

  testWidgets('la ficha de pomarada ofrece marcar el punto y el área',
      (tester) async {
    pantallaAlta(tester);
    await tester.pumpWidget(const MaterialApp(home: PantallaEditarPomarada()));
    await tester.runAsync(() => esperar(tester));
    expect(find.text(SoleraL10n.t('mapa.marcar_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });

  test('una pomarada con área y sin punto sale en el centro del área', () {
    final pomarada = Pomarada(
        nombre: 'Área',
        contorno: codificarContorno(const [
          LatLng(43, -2),
          LatLng(43, -1.998),
          LatLng(43.002, -1.998),
          LatLng(43.002, -2),
        ]));
    final punto = puntoDePomarada(pomarada)!;
    expect(punto.latitude, closeTo(43.001, 1e-6));
    expect(punto.longitude, closeTo(-1.999, 1e-6));
    expect(puntoDePomarada(Pomarada(nombre: 'Sin')), isNull);
    expect(centroDePomaradas([pomarada]).latitude, closeTo(43.001, 1e-6));
  });

  testWidgets('el mapa de pomaradas pinta el área y abre la ficha',
      (tester) async {
    pantallaAlta(tester);
    await tester.runAsync(() async {
      await baseDatos.guardarPomarada(Pomarada(
          nombre: 'Goiko soroa',
          contorno: codificarContorno(const [
            LatLng(43, -2),
            LatLng(43, -1.998),
            LatLng(43.002, -1.998),
          ])));
      await tester.pumpWidget(
          const MaterialApp(home: PantallaMapaPomaradas(conTeselas: false)));
      await esperar(tester);
    });
    final marcador = find.byTooltip('Goiko soroa');
    expect(marcador, findsOneWidget);
    await tester.tap(marcador);
    // La ficha carga con un indicador: sin pumpAndSettle.
    await tester.runAsync(() async {
      for (var vuelta = 0; vuelta < 6; vuelta++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
    expect(find.byType(PantallaFichaPomarada), findsOneWidget);
    expect(find.text('Goiko soroa'), findsWidgets);
  });

  testWidgets('alta de una kupela desde la bodega', (tester) async {
    pantallaAlta(tester);
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaBodega()));
      await esperar(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await esperar(tester);
      await tester.enterText(find.byType(TextField).at(0), 'K1');
      await tester.enterText(find.byType(TextField).at(2), '12000');
      final hoja = find
          .descendant(
              of: find.byType(BottomSheet), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byType(FilledButton), 300,
          scrollable: hoja);
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await esperar(tester);
      await esperar(tester);
    });
    final kupelas = (await tester.runAsync(baseDatos.listarKupelas))!;
    expect(kupelas.single.codigo, 'K1');
    expect(kupelas.single.capacidadLitros, 12000);
    expect(find.text('K1'), findsOneWidget);
  });

  testWidgets('Hoy enseña la bienvenida y lo que hay en bodega',
      (tester) async {
    await tester.runAsync(() async {
      await bodegaDePrueba();
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text('Ongi etorri'), findsOneWidget);
    // 1000 − 120 − 75 = 805 l.
    expect(find.text('805 l'), findsWidgets);
    expect(find.text('K7'), findsWidgets);

    await tester.runAsync(() async {
      await baseDatos.guardarSagardotegi(Sagardotegi(nombre: 'Zelaia'));
      avisarCambioDatos();
      await esperar(tester);
    });
    expect(find.text('Zelaia'), findsOneWidget);
    expect(find.text('Ongi etorri'), findsNothing);
  });

  testWidgets('la bodega, el txotx, los prensados y los lotes se listan',
      (tester) async {
    late int kupela;
    await tester.runAsync(() async {
      kupela = await bodegaDePrueba();
    });
    for (final (pantalla, esperado) in [
      (const PantallaPartidas(), '1.500 kg · Auzoko baserria'),
      (const PantallaPrensados(), '1.500 kg → 1.000 l · K7'),
      (const PantallaEmbotellados(), 'L-K7 · 100 botellas'),
      (const PantallaTxotx(), '1 días de txotx · 120 l servidos'),
      (PantallaKupela(kupelaId: kupela), 'K7'),
    ]) {
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(home: pantalla));
        await esperar(tester);
      });
      expect(find.text(esperado), findsWidgets, reason: '$pantalla');
    }
  });

  test('cada apartado de la ayuda tiene título y texto en los cuatro idiomas',
      () {
    for (final (titulo, texto) in apartadosAyudaSidra) {
      for (final idioma in ['es', 'eu', 'ca', 'gl']) {
        expect(SoleraL10n.t(titulo, idioma: idioma), isNot(titulo));
        expect(SoleraL10n.t(texto, idioma: idioma), isNot(texto));
      }
    }
    expect(SoleraL10n.t('sidr.ayuda_limites_texto'), contains('alcohol'));
  });
}
