import 'apunte_economico.dart';
import 'constantes.dart';
import 'convenio.dart';
import 'proyecto_test.dart';
import 'registro_comercializacion.dart';

/// Cuentas del proyecto según el convenio tester (art. 7):
///
/// - **Balance del test**: ingresos menos gastos directamente imputables a
///   la actividad, **sin amortizaciones**. Es el que se reparte.
/// - **Balance del proyecto**: con amortizaciones de infraestructuras y
///   materiales; informativo, para ver el coste real.
/// - **Reparto** del balance del test con los porcentajes del proyecto
///   (por defecto, beneficio 25 % Zunbeltz / 75 % tester; pérdida 50 / 50).
/// - **Quién asume** cada gasto y **previsto frente a real** por categoría.
///
/// Orientativo: no es contabilidad ni declaración fiscal.
class BalanceConvenio {
  BalanceConvenio._({
    required this.ingresosCentimos,
    required this.gastosTestCentimos,
    required this.amortizacionesCentimos,
    required this.gastosAsumidosTesterCentimos,
    required this.gastosAsumidosZunbeltzCentimos,
    required this.parteZunbeltzCentimos,
    required this.parteTesterCentimos,
    required this.previstoPorCategoria,
    required this.realPorCategoria,
    required this.previstoAsumidoZunbeltzCentimos,
  });

  factory BalanceConvenio.calcular({
    required ProyectoTest proyecto,
    required List<ApunteEconomico> apuntes,
    required List<RegistroComercializacion> ventas,
    List<PartidaPresupuesto> presupuesto = const [],
  }) {
    var ingresos = 0;
    for (final venta in ventas) {
      ingresos += venta.ingresoCentimos;
    }
    var gastosTest = 0;
    var amortizaciones = 0;
    var asumidosTester = 0;
    var asumidosZunbeltz = 0;
    final realPorCategoria = <String, int>{};
    for (final apunte in apuntes) {
      if (apunte.tipo == 'ingreso') {
        ingresos += apunte.importeCentimos;
        continue;
      }
      if (apunte.esAmortizacion) {
        amortizaciones += apunte.importeCentimos;
      } else {
        gastosTest += apunte.importeCentimos;
      }
      if (apunte.asumidoPor == asumidoPorZunbeltz) {
        asumidosZunbeltz += apunte.importeCentimos;
      } else {
        asumidosTester += apunte.importeCentimos;
      }
      realPorCategoria.update(
          apunte.categoria, (total) => total + apunte.importeCentimos,
          ifAbsent: () => apunte.importeCentimos);
    }

    final balanceTest = ingresos - gastosTest;
    final porcentajeZunbeltz = balanceTest >= 0
        ? proyecto.porcentajeBeneficioZunbeltz
        : proyecto.porcentajePerdidaZunbeltz;
    final parteZunbeltz = (balanceTest * porcentajeZunbeltz / 100).round();

    final previstoPorCategoria = <String, int>{};
    var previstoZunbeltz = 0;
    for (final partida in presupuesto) {
      previstoPorCategoria.update(
          partida.categoria, (total) => total + partida.importeCentimos,
          ifAbsent: () => partida.importeCentimos);
      if (partida.asumidoPor == asumidoPorZunbeltz) {
        previstoZunbeltz += partida.importeCentimos;
      }
    }

    return BalanceConvenio._(
      ingresosCentimos: ingresos,
      gastosTestCentimos: gastosTest,
      amortizacionesCentimos: amortizaciones,
      gastosAsumidosTesterCentimos: asumidosTester,
      gastosAsumidosZunbeltzCentimos: asumidosZunbeltz,
      parteZunbeltzCentimos: parteZunbeltz,
      parteTesterCentimos: balanceTest - parteZunbeltz,
      previstoPorCategoria: previstoPorCategoria,
      realPorCategoria: realPorCategoria,
      previstoAsumidoZunbeltzCentimos: previstoZunbeltz,
    );
  }

  final int ingresosCentimos;

  /// Gastos sin amortizaciones.
  final int gastosTestCentimos;
  final int amortizacionesCentimos;
  final int gastosAsumidosTesterCentimos;
  final int gastosAsumidosZunbeltzCentimos;

  /// Reparto del balance del test (negativo si es pérdida).
  final int parteZunbeltzCentimos;
  final int parteTesterCentimos;

  final Map<String, int> previstoPorCategoria;
  final Map<String, int> realPorCategoria;

  /// Lo que el presupuesto prevé que asuma Zunbeltz: base de la fianza.
  final int previstoAsumidoZunbeltzCentimos;

  int get balanceTestCentimos => ingresosCentimos - gastosTestCentimos;
  int get balanceProyectoCentimos =>
      balanceTestCentimos - amortizacionesCentimos;
  bool get hayBeneficio => balanceTestCentimos >= 0;

  /// Fianza de referencia: 10 % de lo que el presupuesto prevé que asuma
  /// Zunbeltz (convenio, anexo I). Orientativa: la cuantía final se pacta.
  int get fianzaReferenciaCentimos =>
      (previstoAsumidoZunbeltzCentimos * 10 / 100).round();

  /// Categorías con previsto o real, en el orden del catálogo de gastos.
  List<String> get categoriasComparadas {
    final presentes = {...previstoPorCategoria.keys, ...realPorCategoria.keys};
    return [
      for (final opcion in categoriasGasto)
        if (presentes.contains(opcion.codigo)) opcion.codigo,
      for (final codigo in presentes)
        if (!categoriasGasto.any((opcion) => opcion.codigo == codigo)) codigo,
    ];
  }
}

/// Estado de la fianza: lo depositado menos lo devuelto y lo retenido
/// (movimientos de retención más retenciones de las incidencias).
class EstadoFianza {
  EstadoFianza.calcular(List<MovimientoFianza> movimientos,
      List<IncidenciaCumplimiento> incidencias) {
    for (final movimiento in movimientos) {
      switch (movimiento.tipo) {
        case 'deposito':
          depositadoCentimos += movimiento.importeCentimos;
        case 'devolucion':
          devueltoCentimos += movimiento.importeCentimos;
        case 'retencion':
          retenidoCentimos += movimiento.importeCentimos;
      }
    }
    for (final incidencia in incidencias) {
      retenidoCentimos += incidencia.retencionCentimos;
    }
  }

  int depositadoCentimos = 0;
  int devueltoCentimos = 0;
  int retenidoCentimos = 0;

  int get pendienteCentimos =>
      depositadoCentimos - devueltoCentimos - retenidoCentimos;
}

/// Indicadores del anexo IV del convenio a partir del acompañamiento.
class IndicadoresAcompanamiento {
  IndicadoresAcompanamiento.calcular(
    List<Acompanamiento> actividades, {
    required DateTime inicio,
    required DateTime fin,
    DateTime? ahora,
  }) : meses = _mesesEntre(inicio, fin, ahora ?? DateTime.now()) {
    for (final actividad in actividades) {
      propuestas.update(actividad.tipo, (n) => n + 1, ifAbsent: () => 1);
      if (actividad.asistida) {
        asistidas.update(actividad.tipo, (n) => n + 1, ifAbsent: () => 1);
      }
      horas += actividad.horas ?? 0;
    }
  }

  /// Meses del periodo (al menos 1): el anexo pide una reunión y una visita
  /// a la finca al mes.
  final int meses;
  final Map<String, int> propuestas = {};
  final Map<String, int> asistidas = {};
  double horas = 0;

  int asistidasDe(String tipo) => asistidas[tipo] ?? 0;
  int propuestasDe(String tipo) => propuestas[tipo] ?? 0;

  /// Soporte integral: al menos una formación, una visita a explotación de
  /// referencia y un asesoramiento.
  bool get cumpleSoporteIntegral =>
      asistidasDe('formacion') >= 1 &&
      asistidasDe('visita_referencia') >= 1 &&
      asistidasDe('asesoramiento') >= 1;

  /// Difusión: al menos una visita recibida, un mercado y un medio.
  bool get cumpleDifusion =>
      asistidasDe('visita_recibida') >= 1 &&
      asistidasDe('mercado') >= 1 &&
      asistidasDe('difusion') >= 1;

  /// Seguimiento: una reunión y una visita a la finca por mes.
  bool get cumpleSeguimiento =>
      asistidasDe('reunion') >= meses && asistidasDe('visita_finca') >= meses;

  /// Venta y transformación: alguna búsqueda de canales o mercado.
  bool get cumpleVenta =>
      asistidasDe('busqueda_canales') >= 1 || asistidasDe('mercado') >= 1;

  /// Meses completos entre el inicio y el fin, contando el día final (del
  /// 1 de enero al 31 de diciembre son 12, no 11). Si el fin aún no ha
  /// llegado (fin previsto), solo cuenta hasta hoy: en el segundo mes de un
  /// proyecto de un año no se exigen las doce reuniones.
  static int _mesesEntre(DateTime inicio, DateTime fin, DateTime ahora) {
    final finEfectivo = fin.isAfter(ahora) ? ahora : fin;
    final finInclusivo =
        DateTime(finEfectivo.year, finEfectivo.month, finEfectivo.day + 1);
    var meses = (finInclusivo.year - inicio.year) * 12 +
        finInclusivo.month -
        inicio.month;
    if (finInclusivo.day < inicio.day) meses--;
    return meses < 1 ? 1 : meses;
  }
}
