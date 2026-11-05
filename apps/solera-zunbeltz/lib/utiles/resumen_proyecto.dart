import 'dart:math' as math;

import '../modelos/amortizacion.dart' show mesesEntre;
import '../modelos/balance_convenio.dart';
import '../modelos/proyecto_test.dart';

/// En qué mes del test va un proyecto: «Mes 8 de 24».
///
/// [mesActual] empieza en 1 el día de inicio (0 si aún no ha empezado) y no
/// pasa de [mesesTotales]. [mesesTotales] es null si el proyecto no tiene
/// fecha de fin; se redondea hacia arriba (un test de 18 meses y medio
/// tiene 19 casillas). Null si no tiene fecha de inicio.
({int mesActual, int? mesesTotales})? mesDelTest(ProyectoTest proyecto,
    {DateTime? ahora}) {
  final inicioMs = proyecto.fechaInicioMs;
  if (inicioMs == null || inicioMs == 0) return null;
  final inicio = DateTime.fromMillisecondsSinceEpoch(inicioMs);
  final finMs = proyecto.fechaFinMs;
  final fin = finMs == null || finMs == 0
      ? null
      : DateTime.fromMillisecondsSinceEpoch(finMs);
  final hoy = ahora ?? DateTime.now();
  final totales =
      fin == null ? null : math.max(1, mesesEntre(inicio, fin).ceil());
  if (hoy.isBefore(inicio)) return (mesActual: 0, mesesTotales: totales);
  final hasta = fin != null && hoy.isAfter(fin) ? fin : hoy;
  var actual = mesesEntre(inicio, hasta).floor() + 1;
  if (totales != null) actual = math.min(actual, totales);
  return (mesActual: actual, mesesTotales: totales);
}

/// Qué parte de los gastos (amortizaciones incluidas) asume cada cual, en
/// porcentajes enteros que suman 100. Null si aún no hay gastos.
({int tester, int zunbeltz})? repartoDeGastos(BalanceConvenio balance) {
  final tester = balance.gastosAsumidosTesterCentimos;
  final zunbeltz = balance.gastosAsumidosZunbeltzCentimos;
  final total = tester + zunbeltz;
  if (total <= 0) return null;
  final porcentajeTester = (tester * 100 / total).round();
  return (tester: porcentajeTester, zunbeltz: 100 - porcentajeTester);
}
