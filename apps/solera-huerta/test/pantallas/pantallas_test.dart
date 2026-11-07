import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_huerta/datos/base_datos.dart';
import 'package:solera_huerta/modelos/bancal.dart';
import 'package:solera_huerta/modelos/cosecha.dart';
import 'package:solera_huerta/modelos/cultivo.dart';
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/modelos/siembra.dart';
import 'package:solera_huerta/pantallas/pantalla_ayuda.dart';
import 'package:solera_huerta/pantallas/pantalla_cestas.dart';
import 'package:solera_huerta/pantallas/pantalla_cuaderno.dart';
import 'package:solera_huerta/pantallas/pantalla_ficha_bancal.dart';
import 'package:solera_huerta/pantallas/pantalla_hoy.dart';
import 'package:solera_huerta/pantallas/pantalla_parcelas.dart';
import 'package:solera_huerta/pantallas/pantalla_socios.dart';
import 'package:solera_huerta/provisional_core/venta_directa/socio.dart';
import 'package:solera_huerta/provisional_core/venta_directa/suscripcion.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraHuerta.instancia;

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

  Future<void> pulsarGuardar(WidgetTester tester) async {
    final boton = find.widgetWithText(FilledButton, SoleraL10n.t('guardar'));
    await tester.scrollUntilVisible(boton, 300,
        scrollable: find
            .descendant(
                of: find.byType(BottomSheet), matching: find.byType(Scrollable))
            .first);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await esperar(tester);
  }

  Future<({int parcela, int bancal, int cultivo})> sembrado() async {
    final parcela = await baseDatos.guardarParcela(Parcela(nombre: 'Vega'));
    final bancal =
        await baseDatos.guardarBancal(Bancal(parcelaId: parcela, nombre: 'B1'));
    final cultivo = await baseDatos
        .guardarCultivo(Cultivo(especieId: 'Tomate', familiaId: 'solanaceas'));
    return (parcela: parcela, bancal: bancal, cultivo: cultivo);
  }

  testWidgets('alta de una parcela desde la lista', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaParcelas()));
      await esperar(tester, 200);
      expect(find.text(SoleraL10n.t('huer.sin_parcelas')), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'La Vega');
      await tester.enterText(find.byType(TextField).at(2), '0,8');
      await pulsarGuardar(tester);
      await esperar(tester, 200);
    });
    expect(find.text('La Vega'), findsOneWidget);
    final parcela = (await tester.runAsync(baseDatos.listarParcelas))!.single;
    expect((parcela.superficieHa, parcela.estadoEcologico), (0.8, 'ecologica'));
  });

  testWidgets('Hoy: primeros pasos sin parcelas', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('huer.primeros_pasos')), findsOneWidget);
  });

  testWidgets('Hoy: siembra planificada próxima', (tester) async {
    await tester.runAsync(() async {
      final ids = await sembrado();
      await baseDatos.guardarSiembra(Siembra(
          bancalId: ids.bancal,
          cultivoId: ids.cultivo,
          fechaPrevistaMs: DateTime.now()
              .add(const Duration(days: 3))
              .millisecondsSinceEpoch));
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester);
    });
    expect(find.text('Tomate'), findsOneWidget);
    expect(find.text(SoleraL10n.t('huer.cestas_esta_semana')), findsOneWidget);
  });

  testWidgets('ficha de bancal: familia bloqueada por la rotación',
      (tester) async {
    late int bancal;
    await tester.runAsync(() async {
      final ids = await sembrado();
      bancal = ids.bancal;
      await baseDatos.guardarSiembra(Siembra(
          bancalId: ids.bancal,
          cultivoId: ids.cultivo,
          fechaPrevistaMs: DateTime.now().millisecondsSinceEpoch,
          fechaRealMs: DateTime.now().millisecondsSinceEpoch));
      await tester
          .pumpWidget(MaterialApp(home: PantallaFichaBancal(bancalId: bancal)));
      await esperar(tester);
    });
    expect(find.text(SoleraL10n.t('huer.plan_rotacion')), findsOneWidget);
    expect(find.text('Tomate'), findsOneWidget);
  });

  testWidgets('cuaderno: alta de cosecha', (tester) async {
    await tester.runAsync(() async {
      await sembrado();
      await tester.pumpWidget(const MaterialApp(home: PantallaCuaderno()));
      await esperar(tester);
      await tester.tap(find.text(SoleraL10n.t('huer.cosechas')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(SoleraL10n.t('huer.nueva_cosecha')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, SoleraL10n.t('huer.kg')), '3,5');
      await pulsarGuardar(tester);
    });
    final cosecha = (await tester.runAsync(baseDatos.listarCosechas))!.single;
    expect((cosecha.kg, cosecha.destino), (3.5, 'cestas'));
  });

  testWidgets('socios: alta de un socio', (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(const MaterialApp(home: PantallaSocios()));
      await esperar(tester, 200);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Amaia');
      await pulsarGuardar(tester);
      await esperar(tester, 200);
    });
    expect(find.text('Amaia'), findsOneWidget);
  });

  testWidgets('cestas: propone el reparto con la cosecha real', (tester) async {
    await tester.runAsync(() async {
      final ids = await sembrado();
      for (final (nombre, tamano) in [('Ane', 'pequena'), ('Jon', 'grande')]) {
        final socio = await baseDatos.guardarSocio(Socio(nombre: nombre));
        await baseDatos.guardarSuscripcion(Suscripcion(
            socioId: socio,
            tamano: tamano,
            fechaInicioMs: DateTime(2026).millisecondsSinceEpoch));
      }
      await baseDatos.guardarCosecha(Cosecha(
          bancalId: ids.bancal,
          cultivoId: ids.cultivo,
          fechaMs: DateTime.now().millisecondsSinceEpoch,
          kg: 6));
      await tester.pumpWidget(const MaterialApp(home: PantallaCestas()));
      await esperar(tester);
      await tester.tap(find.text(SoleraL10n.t('huer.proponer_reparto')));
      await esperar(tester);
    });
    final lineas = (await tester.runAsync(baseDatos.listarLineasCesta))!;
    expect(lineas.map((linea) => linea.kg).toList()..sort(), [2.0, 4.0]);
  });

  testWidgets('ayuda: todos los apartados, con lo que la app no hace',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PantallaAyuda()));
    expect(
        find.byType(ExpansionTile), findsNWidgets(apartadosAyudaHuerta.length));
    expect(
        find.text(SoleraL10n.t('huer.ayuda_limites_titulo')), findsOneWidget);
  });
}
