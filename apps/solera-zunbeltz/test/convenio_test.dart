// Economía y seguimiento del convenio tester: balances del test y del
// proyecto, reparto, fianza e indicadores del anexo IV.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/l10n/app_localizations.dart';
import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/balance_convenio.dart';
import 'package:solera_zunbeltz/modelos/convenio.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/modelos/registro_comercializacion.dart';
import 'package:solera_zunbeltz/modelos/rentabilidad_proyecto.dart';
import 'package:solera_zunbeltz/servicios/generador_informe_proyecto.dart';

import 'bd_en_memoria.dart';

ApunteEconomico gasto(int euros, String categoria,
        {String asumidoPor = 'tester', bool amortizacion = false}) =>
    ApunteEconomico(
        fincaId: 1,
        tipo: 'gasto',
        categoria: categoria,
        importeCentimos: euros * 100,
        asumidoPor: asumidoPor,
        esAmortizacion: amortizacion);

void main() {
  final proyecto = ProyectoTest(nombre: 'Quesería');

  test('balance del test sin amortizaciones; del proyecto, con ellas', () {
    final balance = BalanceConvenio.calcular(
      proyecto: proyecto,
      ventas: [RegistroComercializacion(proyectoId: 1, ingresoCentimos: 300000)],
      apuntes: [
        gasto(1000, 'alimentacion'),
        gasto(400, 'infraestructuras', asumidoPor: 'zunbeltz', amortizacion: true),
        ApunteEconomico(fincaId: 1, tipo: 'ingreso', importeCentimos: 20000),
      ],
    );
    expect(balance.ingresosCentimos, 320000);
    expect(balance.balanceTestCentimos, 220000);
    expect(balance.balanceProyectoCentimos, 180000);
    expect(balance.gastosAsumidosZunbeltzCentimos, 40000);
    expect(balance.gastosAsumidosTesterCentimos, 100000);
  });

  test('reparto: beneficio 25/75, pérdida 50/50 por defecto', () {
    final conBeneficio = BalanceConvenio.calcular(
        proyecto: proyecto,
        ventas: [RegistroComercializacion(proyectoId: 1, ingresoCentimos: 100000)],
        apuntes: const []);
    expect(conBeneficio.parteZunbeltzCentimos, 25000);
    expect(conBeneficio.parteTesterCentimos, 75000);

    final conPerdida = BalanceConvenio.calcular(
        proyecto: proyecto, ventas: const [], apuntes: [gasto(200, 'sanidad')]);
    expect(conPerdida.hayBeneficio, isFalse);
    expect(conPerdida.parteZunbeltzCentimos, -10000);
    expect(conPerdida.parteTesterCentimos, -10000);

    final pactado = BalanceConvenio.calcular(
        proyecto: ProyectoTest(porcentajeBeneficioZunbeltz: 10),
        ventas: [RegistroComercializacion(proyectoId: 1, ingresoCentimos: 100000)],
        apuntes: const []);
    expect(pactado.parteZunbeltzCentimos, 10000, reason: 'porcentaje pactado por escrito');
  });

  test('previsto frente a real y fianza de referencia', () {
    final balance = BalanceConvenio.calcular(
      proyecto: proyecto,
      ventas: const [],
      apuntes: [gasto(300, 'alimentacion')],
      presupuesto: [
        PartidaPresupuesto(proyectoId: 1, categoria: 'alimentacion', importeCentimos: 50000),
        PartidaPresupuesto(
            proyectoId: 1, categoria: 'infraestructuras', asumidoPor: 'zunbeltz', importeCentimos: 800000),
      ],
    );
    expect(balance.previstoPorCategoria['alimentacion'], 50000);
    expect(balance.realPorCategoria['alimentacion'], 30000);
    expect(balance.categoriasComparadas, ['alimentacion', 'infraestructuras']);
    expect(balance.fianzaReferenciaCentimos, 80000, reason: '10 % de lo que asume Zunbeltz');
  });

  test('fianza: depositado menos devuelto y retenido (incidencias incluidas)', () {
    final estado = EstadoFianza.calcular([
      MovimientoFianza(proyectoId: 1, tipo: 'deposito', importeCentimos: 80000),
      MovimientoFianza(proyectoId: 1, tipo: 'devolucion', importeCentimos: 30000),
    ], [
      IncidenciaCumplimiento(proyectoId: 1, nivel: 'grave', retencionCentimos: 10000),
    ]);
    expect(estado.retenidoCentimos, 10000);
    expect(estado.pendienteCentimos, 40000);
  });

  test('indicadores del anexo IV', () {
    Acompanamiento a(String tipo, {String asistencia = 'asistida'}) =>
        Acompanamiento(proyectoId: 1, tipo: tipo, asistencia: asistencia);
    final indicadores = IndicadoresAcompanamiento.calcular([
      a('formacion'),
      a('visita_referencia'),
      a('asesoramiento'),
      a('reunion'),
      a('reunion'),
      a('visita_finca'),
      a('visita_finca', asistencia: 'no_asistida'),
      a('mercado'),
    ], inicio: DateTime(2026, 1, 15), fin: DateTime(2026, 3, 20));
    expect(indicadores.meses, 2);
    expect(indicadores.cumpleSoporteIntegral, isTrue);
    expect(indicadores.cumpleSeguimiento, isFalse, reason: 'falta una visita a la finca');
    expect(indicadores.propuestasDe('visita_finca'), 2);
    expect(indicadores.cumpleVenta, isTrue);
    expect(indicadores.cumpleDifusion, isFalse);
  });

  test('BD: el seguimiento del convenio cuelga del proyecto y se borra con él', () async {
    final bd = await abrirBdEnMemoria();
    await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final proyectoId = await bd.guardarProyecto(ProyectoTest(nombre: 'Quesería'));
    await bd.guardarPartidaPresupuesto(
        PartidaPresupuesto(proyectoId: proyectoId, categoria: 'ganado', importeCentimos: 100));
    await bd.guardarMovimientoFianza(MovimientoFianza(proyectoId: proyectoId, importeCentimos: 50));
    await bd.guardarAcompanamiento(Acompanamiento(proyectoId: proyectoId, tipo: 'reunion'));
    await bd.guardarIncidencia(IncidenciaCumplimiento(proyectoId: proyectoId, nivel: 'leve'));
    expect((await bd.listarPresupuesto(proyectoId)).single.categoria, 'ganado');
    expect((await bd.listarIncidencias(proyectoId)).single.nivel, 'leve');

    await bd.borrarProyecto(proyectoId);
    expect(await bd.listarAcompanamientos(proyectoId), isEmpty);
    final lapidas = (await bd.listarBorradosPendientes()).map((l) => l.tipo).toSet();
    expect(lapidas, containsAll(['proyecto', 'partida_presupuesto', 'movimiento_fianza', 'acompanamiento', 'incidencia_cumplimiento']));
  });

  test('el informe del proyecto sale con el convenio, en borrador o definitivo',
      () async {
    await initializeDateFormatting('es');
    final textos = await AppLocalizations.delegate.load(const Locale('es'));
    for (final definitivo in [false, true]) {
      final documento = await generarInformeProyectoPdf(
        textos: textos,
        idioma: 'es',
        proyecto: proyecto,
        rentabilidad: const RentabilidadProyecto(),
        comercializacion: const [],
        validaciones: const [],
        actividades: const [],
        balance: BalanceConvenio.calcular(
            proyecto: proyecto, apuntes: [gasto(10, 'ganado')], ventas: const []),
        fianza: EstadoFianza.calcular(const [], const []),
        indicadores: IndicadoresAcompanamiento.calcular(const [],
            inicio: DateTime(2026, 1, 1), fin: DateTime(2026, 6, 1)),
        incidencias: [IncidenciaCumplimiento(proyectoId: 1, nivel: 'grave')],
        definitivo: definitivo,
      );
      expect(String.fromCharCodes(documento.bytes.take(5)), '%PDF-');
    }
  });
}
