// PROVISIONAL CORE — módulo transversal T2 (venta directa). Ver socio.dart.

/// Lunes (a medianoche, hora local) de la semana de [dia].
DateTime lunesDeSemana(DateTime dia) =>
    DateTime(dia.year, dia.month, dia.day - (dia.weekday - DateTime.monday));

/// Semanas enteras de [desde] a [hasta] (los dos se llevan a su lunes).
/// Redondea por horas para no fallar en los cambios de hora.
int semanasEntre(DateTime desde, DateTime hasta) {
  final horas = lunesDeSemana(hasta).difference(lunesDeSemana(desde)).inHours;
  return (horas / (24 * 7)).round();
}

/// Inicio y fin (ms, ambos incluidos) de la semana que empieza en [lunes].
(int, int) intervaloSemana(DateTime lunes) {
  final inicio = lunesDeSemana(lunes);
  final siguiente = DateTime(inicio.year, inicio.month, inicio.day + 7);
  return (inicio.millisecondsSinceEpoch, siguiente.millisecondsSinceEpoch - 1);
}

/// Número de semana ISO 8601 de [dia] (1-53).
int numeroSemanaIso(DateTime dia) {
  final jueves = DateTime(
      dia.year, dia.month, dia.day - (dia.weekday - DateTime.monday) + 3);
  final primerJueves = DateTime(jueves.year, 1, 4);
  return 1 + semanasEntre(primerJueves, jueves);
}
