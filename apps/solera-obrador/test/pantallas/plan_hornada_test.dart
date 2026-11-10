import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_avisos/nuevo_ser_avisos.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/dominio/planificador_hornada.dart';
import 'package:solera_obrador/dominio/tiempos_guia.dart';
import 'package:solera_obrador/modelos/masa_madre.dart';
import 'package:solera_obrador/modelos/plan_hornada.dart';
import 'package:solera_obrador/pantallas/pantalla_hoy.dart';
import 'package:solera_obrador/pantallas/pantalla_plan_hornada.dart';
import 'package:solera_obrador/servicios/avisos_obrador.dart';

import '../datos/soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraObrador.instancia;
  late ServicioAvisosEnMemoria avisos;

  setUpAll(initializeDateFormatting);
  setUp(() async {
    await entorno.preparar();
    avisos = ServicioAvisosEnMemoria();
    avisosObrador = avisos;
  });
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Deja pasar tiempo real (la BD) y pinta, sin esperar a que se calme
  /// (los indicadores de carga no se calman nunca).
  Future<void> esperar(WidgetTester tester, {Finder? hasta}) async {
    for (var vuelta = 0; vuelta < 50; vuelta++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      final listo = hasta == null
          ? vuelta >= 5
          : hasta.evaluate().isNotEmpty &&
              find.byType(CircularProgressIndicator).evaluate().isEmpty;
      if (listo) return;
    }
  }

  PlanHornada planDeManana() {
    final ahora = DateTime.now();
    final listo = DateTime(ahora.year, ahora.month, ahora.day + 2, 8);
    return PlanHornada(
      nombre: 'Rústico',
      recetaGuiaId: 'rustico',
      listoMs: listo.millisecondsSinceEpoch,
      temperaturaCocinaC: 22,
      fases: planificarHaciaAtras(
          plantilla: tiemposRecetasGuia['rustico']!,
          listoA: listo,
          temperaturaCocinaC: 22),
      creadoMs: 0,
    );
  }

  group('avisos del plan', () {
    test('uno por fase pendiente, con claves estables; quitar los borra',
        () async {
      final plan = planDeManana().copiar(id: 7);
      expect(
          await programarAvisosPlan(plan, servicio: avisos), plan.fases.length);
      final pendientes = await avisos.pendientes();
      expect(pendientes.first.clave, 'obrador.plan.7.0');
      expect(pendientes.first.cuando, plan.fases.first.inicio);
      // Marcar la primera y reprogramar: ya no avisa de ella.
      final hecha = plan.copiar(
          fases: marcarHechaYReplanificar(plan.fases, 0, plan.fases.first.fin));
      expect(await programarAvisosPlan(hecha, servicio: avisos),
          plan.fases.length - 1);
      await quitarAvisosPlan(7, servicio: avisos);
      expect(await avisos.pendientes(), isEmpty);
    });

    test('sin permiso no programa nada y no lanza', () async {
      avisos.permisoConcedido = false;
      expect(
          await programarAvisosPlan(planDeManana().copiar(id: 1),
              servicio: avisos),
          0);
    });

    test('recordatorio de refresco de la masa madre', () async {
      final ahora = DateTime(2026, 11, 10, 12);
      avisos.reloj = () => ahora;
      final masa = MasaMadre(
          id: 3, nombre: 'Centeno', creadaMs: 0, recordatorioHoras: 24);
      final cuando = await programarRecordatorioRefresco(
          masa, DateTime(2026, 11, 10, 9),
          servicio: avisos, ahora: ahora);
      expect(cuando, DateTime(2026, 11, 11, 9));
      expect((await avisos.pendientes()).single.clave, 'obrador.masa_madre.3');
      await programarRecordatorioRefresco(masa.conRecordatorio(null), null,
          servicio: avisos, ahora: ahora);
      expect(await avisos.pendientes(), isEmpty);
    });
  });

  testWidgets('planificar una receta de la guía, guardar y avisar',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
          home: PantallaPlanificarHornada(
              nombre: 'Rústico',
              plantilla: tiemposRecetasGuia['rustico']!,
              recetaGuiaId: 'rustico')));
      await tester.pumpAndSettle();
      expect(find.text(SoleraL10n.t('obra.plan_fase_amasado')),
          findsNothing); // las filas llevan hora delante
      expect(find.textContaining(SoleraL10n.t('obra.plan_fase_coccion')),
          findsOneWidget);
      final boton = find.text(SoleraL10n.t('obra.plan_guardar_avisar'));
      await tester.scrollUntilVisible(boton, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(boton);
      await esperar(tester, hasta: find.byType(PantallaPlanHornada));
    });
    final planes = (await tester.runAsync(baseDatos.listarPlanesEnCurso))!;
    expect(planes.single.recetaGuiaId, 'rustico');
    expect(planes.single.avisosProgramados, isTrue);
    expect((await tester.runAsync(avisos.pendientes))!.length,
        tiemposRecetasGuia['rustico']!.fases.length);
    expect(find.byType(PantallaPlanHornada), findsOneWidget);
  });

  testWidgets('Hoy enseña la siguiente fase del plan en curso', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.runAsync(() async {
      await baseDatos.guardarPlanHornada(planDeManana());
      await tester.pumpWidget(const MaterialApp(home: PantallaHoy()));
      await esperar(tester, hasta: find.text('Rústico'));
    });
    expect(find.text(SoleraL10n.t('obra.plan_en_curso')), findsOneWidget);
    expect(find.text('Rústico'), findsOneWidget);
    expect(find.textContaining(SoleraL10n.t('obra.plan_fase_amasado')),
        findsOneWidget);
  });

  testWidgets('marcar una fase hecha la guarda', (tester) async {
    late int planId;
    await tester.runAsync(() async {
      planId = await baseDatos.guardarPlanHornada(planDeManana());
      await tester
          .pumpWidget(MaterialApp(home: PantallaPlanHornada(planId: planId)));
      await esperar(tester, hasta: find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox).first);
      await esperar(tester,
          hasta: find.byWidgetPredicate(
              (widget) => widget is Checkbox && widget.value == true));
    });
    final plan =
        (await tester.runAsync(() => baseDatos.obtenerPlanHornada(planId)))!;
    expect(plan.fases.first.hecha, isTrue);
    // Hecha mucho antes de lo previsto: el resto se adelanta.
    expect(
        plan.fases[1].inicio.isBefore(planDeManana().fases[1].inicio), isTrue);
  });
}
