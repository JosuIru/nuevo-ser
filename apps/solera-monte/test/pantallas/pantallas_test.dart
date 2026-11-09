import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show CampoArea, CampoPunto, CapaBase, TextoCapaBase;
import 'package:solera_monte/datos/base_datos.dart';
import 'package:solera_monte/modelos/actuacion_plan.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';
import 'package:solera_monte/modelos/incendios.dart';
import 'package:solera_monte/modelos/monte.dart';
import 'package:solera_monte/modelos/rodal.dart';
import 'package:solera_monte/modelos/sorteo_lena.dart';
import 'package:solera_monte/pantallas/pantalla_aprovechamientos.dart';
import 'package:solera_monte/pantallas/pantalla_hoy.dart';
import 'package:solera_monte/pantallas/pantalla_mapa.dart';
import 'package:solera_monte/pantallas/pantalla_monte.dart';
import 'package:solera_monte/pantallas/pantalla_plan.dart';
import 'package:solera_monte/pantallas/pantalla_sorteo.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraMonte.instancia;

  setUpAll(initializeDateFormatting);
  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Deja correr la BD real (ffi) y repinta varias veces.
  Future<void> esperar(WidgetTester tester, [int milisegundos = 300]) async {
    for (var vuelta = 0; vuelta < 4; vuelta++) {
      await Future<void>.delayed(Duration(milliseconds: milisegundos ~/ 2));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Hoy: primeros pasos con el monte vacío', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('mont.primeros_pasos')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mont.catalogos_provisionales')),
        findsOneWidget);
  });

  testWidgets('Hoy: pide la época de peligro y avisa del trámite pendiente',
      (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarMonte(Monte(nombre: 'Monte de Ultzama'));
      await baseDatos.guardarAprovechamiento(Aprovechamiento(
          campanya: DateTime.now().year,
          tipo: 'lena',
          fechaInicioMs: DateTime.now().millisecondsSinceEpoch,
          cantidad: 30,
          unidad: 'estereos'));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text('Monte de Ultzama'), findsOneWidget);
    expect(
        find.text(SoleraL10n.t('mont.apunta_epoca_peligro')), findsOneWidget);
    expect(find.textContaining(SoleraL10n.t('mont.aviso_tramite_pendiente')),
        findsOneWidget);
  });

  testWidgets('alta de un rodal desde Monte', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaMonte()));
      await esperar(tester);
      await tester.tap(find.text(SoleraL10n.t('mont.nuevo_rodal')));
      await esperar(tester);
      await tester.enterText(find.byType(TextField).at(0), '1a');
      await tester.enterText(find.byType(TextField).at(2), 'Haya');
      await tester.enterText(find.byType(TextField).at(4), '3,5');
      final boton = find.widgetWithText(FilledButton, SoleraL10n.t('guardar'));
      await tester.scrollUntilVisible(boton, 300,
          scrollable: find.byType(Scrollable).last);
      await tester.tap(boton);
      await esperar(tester);
    });
    final rodal = (await tester.runAsync(baseDatos.listarRodales))!.single;
    expect(
        (rodal.codigo, rodal.especiePrincipalId, rodal.superficieDeclaradaHa),
        ('1a', 'fagus_sylvatica', 3.5));
    expect(find.text('1a'), findsOneWidget);
  });

  testWidgets('Monte lista rodales con superficie por especie e incendios',
      (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarRodal(Rodal(
          codigo: 'R1',
          nombre: 'Pinar',
          especiePrincipalId: 'pinus_sylvestris',
          superficieDeclaradaHa: 12));
      await baseDatos.guardarInfraestructura(
          InfraestructuraIncendios(tipo: 'punto_agua', nombre: 'Balsa alta'));
      await tester.pumpWidget(const MaterialApp(home: PantallaMonte()));
      await esperar(tester);
    });
    expect(find.text('R1 · Pinar'), findsOneWidget);
    expect(find.text('Pino albar o silvestre'), findsOneWidget);
    await tester.tap(find.text(SoleraL10n.t('mont.incendios')));
    await tester.pumpAndSettle();
    expect(find.text('Balsa alta'), findsOneWidget);
    expect(find.text(SoleraL10n.t('mont.sin_revisar')), findsOneWidget);
  });

  testWidgets('Plan enseña previsto frente a hecho', (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarActuacion(
          ActuacionPlan(anyoPrevisto: DateTime.now().year, tipo: 'desbroce'));
      await tester.pumpWidget(const MaterialApp(home: PantallaPlan()));
      await esperar(tester);
    });
    expect(
        find.text(SoleraL10n.tf(
            'mont.resumen_anyo', {'ejecutadas': '0', 'previstas': '1'})),
        findsOneWidget);
    expect(find.textContaining(SoleraL10n.t('mont.actuacion_desbroce')),
        findsOneWidget);
  });

  testWidgets('Aprovechamientos vacío lo explica', (tester) async {
    await tester.runAsync(() async {
      await tester
          .pumpWidget(const MaterialApp(home: PantallaAprovechamientos()));
      await esperar(tester);
    });
    expect(
        find.text(SoleraL10n.t('mont.sin_aprovechamientos')), findsOneWidget);
  });

  testWidgets('sorteo realizado: se comprueba al abrirlo', (tester) async {
    late int sorteoId;
    await tester.runAsync(() async {
      sorteoId = await baseDatos
          .guardarSorteo(SorteoLena(campanya: 2026, nombre: 'Suertes 2026'));
      await baseDatos.guardarLote(LoteLena(sorteoId: sorteoId, numero: 1));
      await baseDatos.guardarLote(LoteLena(sorteoId: sorteoId, numero: 2));
      await tester
          .pumpWidget(MaterialApp(home: PantallaSorteo(sorteoId: sorteoId)));
      await esperar(tester);
      await tester.enterText(
          find.byType(TextField).first, 'Casa Juana\nCasa Pello\nCasa Miren');
      await tester.tap(find.text(SoleraL10n.t('mont.cerrar_lista')));
      await esperar(tester, 100);
      await tester.tap(find.text(SoleraL10n.t('mont.aceptar')));
      await esperar(tester);
      final campoSemilla =
          find.widgetWithText(TextField, SoleraL10n.t('mont.semilla'));
      await tester.scrollUntilVisible(campoSemilla, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.enterText(campoSemilla, '04211');
      final sortear = find.text(SoleraL10n.t('mont.sortear'));
      await tester.scrollUntilVisible(sortear, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(sortear);
      await esperar(tester, 100);
      await tester.tap(find.text(SoleraL10n.t('mont.aceptar')));
      await esperar(tester);
    });
    final sorteo =
        (await tester.runAsync(() => baseDatos.obtenerSorteo(sorteoId)))!;
    expect((sorteo.realizado, sorteo.semilla), (true, '04211'));
    final lotes = (await tester
        .runAsync(() => baseDatos.listarLotes(sorteoId: sorteoId)))!;
    expect(lotes.every((lote) => lote.adjudicado), isTrue);
    final verificado = find.text(SoleraL10n.t('mont.sorteo_verificado'));
    await tester.scrollUntilVisible(verificado, 300,
        scrollable: find.byType(Scrollable).first);
    expect(verificado, findsOneWidget);
    expect(find.text(SoleraL10n.t('mont.lista_espera')), findsOneWidget);
  });

  testWidgets('la ficha del rodal ofrece marcar el área en el mapa',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaMonte()));
      await esperar(tester);
      await tester.tap(find.text(SoleraL10n.t('mont.nuevo_rodal')));
      await esperar(tester);
    });
    expect(find.byType(CampoArea), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.sin_area')), findsOneWidget);
  });

  testWidgets('mapa del monte: rodal con área, lista y cambio de capa',
      (tester) async {
    await tester.runAsync(() async {
      await baseDatos.guardarRodal(Rodal(
          codigo: 'R1',
          especiePrincipalId: 'pinus_sylvestris',
          contorno: const [
            LatLng(42.8, -1.6),
            LatLng(42.8009, -1.6),
            LatLng(42.8009, -1.59877),
            LatLng(42.8, -1.59877)
          ]));
      await tester.pumpWidget(
          const MaterialApp(home: PantallaMapaMonte(conTeselas: false)));
      await esperar(tester);
    });
    expect(find.textContaining('1,00 ha'), findsOneWidget);
    expect(find.text(CapaBase.callejero.atribucion), findsOneWidget);
    await tester.tap(find.byTooltip(SoleraL10n.t('mapa.cambiar_capa')));
    await tester.pump();
    expect(find.text(CapaBase.ortofoto.atribucion), findsOneWidget);
  });

  testWidgets('traza de una pista: añade la posición y mide la línea',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: PantallaTrazado(
      titulo: 'Pista',
      verticesIniciales: const [LatLng(42.0, -1.0)],
      leerGps: () async =>
          (posicion: const LatLng(42.009, -1.0), precisionMetros: 4.0),
    )));
    expect(find.textContaining('1 ${SoleraL10n.t('mont.puntos')} · 0 m'),
        findsOneWidget);
    await tester.tap(find.text(SoleraL10n.t('mont.anadir_punto_aqui')));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 ${SoleraL10n.t('mont.puntos')} · 1.00'),
        findsOneWidget);
  });

  testWidgets('punto de agua: ubicación con el campo común', (tester) async {
    late int id;
    await tester.runAsync(() async {
      id = await baseDatos.guardarInfraestructura(
          InfraestructuraIncendios(tipo: 'punto_agua', nombre: 'Balsa'));
      await tester.pumpWidget(
          MaterialApp(home: PantallaInfraestructura(infraestructuraId: id)));
      await esperar(tester);
    });
    expect(find.byType(CampoPunto), findsOneWidget);
    expect(find.text(SoleraL10n.t('mapa.marcar_punto')), findsOneWidget);
  });
}
