// Cosecha prevista y real de una semana, para componer las cestas. Lógica
// pura: la previsión es orientativa (kilos que apunta la persona repartidos
// por igual entre las semanas de cosecha del cultivo).

import '../modelos/cosecha.dart';
import '../modelos/siembra.dart';
import '../provisional_core/venta_directa/semanas.dart';

/// Ciclo de un cultivo para prever: días de siembra a primera cosecha y
/// semanas que dura la cosecha.
typedef CicloCultivo = ({int diasHastaCosecha, int semanasCosecha});

/// Primer día de cosecha previsto: el apuntado o, si no, la fecha de la
/// siembra más el ciclo. Null si no hay ninguno de los dos.
DateTime? inicioCosechaPrevisto(Siembra siembra, CicloCultivo? ciclo) {
  if (siembra.inicioCosechaPrevistaMs != null) {
    return DateTime.fromMillisecondsSinceEpoch(
        siembra.inicioCosechaPrevistaMs!);
  }
  if (ciclo == null) return null;
  final fecha = DateTime.fromMillisecondsSinceEpoch(siembra.fechaReferenciaMs);
  return DateTime(fecha.year, fecha.month, fecha.day + ciclo.diasHastaCosecha);
}

/// Kilos previstos por cultivo en la semana de [lunes]. Cuentan las
/// siembras con kilos previstos que no se han levantado antes de esa
/// semana. [cicloDe] da el ciclo del cultivo (por id de cultivo).
Map<int, double> cosechaPrevistaSemana({
  required List<Siembra> siembras,
  required DateTime lunes,
  required CicloCultivo? Function(int cultivoId) cicloDe,
}) {
  final semana = lunesDeSemana(lunes);
  final prevista = <int, double>{};
  for (final siembra in siembras) {
    final kilos = siembra.kgPrevistos;
    if (kilos == null || kilos <= 0) continue;
    if (siembra.fechaLevantadaMs != null &&
        DateTime.fromMillisecondsSinceEpoch(siembra.fechaLevantadaMs!)
            .isBefore(semana)) {
      continue;
    }
    final ciclo = cicloDe(siembra.cultivoId);
    final inicio = inicioCosechaPrevisto(siembra, ciclo);
    if (inicio == null) continue;
    final semanas = (ciclo?.semanasCosecha ?? 1).clamp(1, 52);
    final desdeInicio = semanasEntre(inicio, semana);
    if (lunesDeSemana(inicio).isAfter(semana) || desdeInicio >= semanas) {
      continue;
    }
    prevista[siembra.cultivoId] =
        (prevista[siembra.cultivoId] ?? 0) + kilos / semanas;
  }
  return prevista;
}

/// Cosecha real con destino «cestas» en la semana de [lunes], por cultivo:
/// kilos y piezas.
Map<int, ({double kg, int unidades})> cosechaRealParaCestas({
  required List<Cosecha> cosechas,
  required DateTime lunes,
}) {
  final (inicio, fin) = intervaloSemana(lunes);
  final real = <int, ({double kg, int unidades})>{};
  for (final cosecha in cosechas) {
    if (cosecha.destino != 'cestas') continue;
    if (cosecha.fechaMs < inicio || cosecha.fechaMs > fin) continue;
    final anterior = real[cosecha.cultivoId] ?? (kg: 0.0, unidades: 0);
    real[cosecha.cultivoId] = (
      kg: anterior.kg + cosecha.kg,
      unidades: anterior.unidades + (cosecha.unidades ?? 0),
    );
  }
  return real;
}
