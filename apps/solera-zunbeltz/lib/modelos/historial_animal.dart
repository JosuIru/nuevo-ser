import 'ganado.dart';

/// La línea de tiempo de un animal: lo que le ha pasado, del momento más
/// reciente al más antiguo. Pura (se prueba sin BD ni pantallas).
///
/// Qué entra:
/// - su **nacimiento**, si se sabe;
/// - lo que se le ha hecho **a él** (curas, saneamientos, pesajes, partos,
///   incidencias), siempre;
/// - los **movimientos** y el manejo **de su rebaño** mientras estaba en él.
///   Los cambios de rebaño de un animal no quedan registrados (solo se
///   guarda en qué rebaño está ahora), así que se cuenta desde que nació
///   (o desde siempre, si no se sabe) hasta su baja: lo que hizo su rebaño
///   actual antes de que entrara saldría también. Si algún día se apuntan
///   los cambios de rebaño, acotar aquí;
/// - su **baja** (venta, muerte…), si la tiene.
enum TipoHitoAnimal { nacimiento, movimientoRebano, evento, baja }

class HitoAnimal {
  const HitoAnimal({
    required this.tipo,
    required this.fechaMs,
    this.movimiento,
    this.evento,
  });

  final TipoHitoAnimal tipo;
  final int fechaMs;

  /// En un [TipoHitoAnimal.movimientoRebano].
  final MovimientoGanado? movimiento;

  /// En un [TipoHitoAnimal.evento].
  final EventoGanado? evento;

  /// El evento se hizo al rebaño entero, no solo a este animal.
  bool get delRebano =>
      tipo == TipoHitoAnimal.movimientoRebano ||
      (evento != null && evento!.animalId == null);
}

/// A igual fecha, lo que acaba arriba: la baja, luego lo hecho, luego los
/// movimientos y, abajo del todo, el nacimiento.
int _pesoMismaFecha(TipoHitoAnimal tipo) => switch (tipo) {
      TipoHitoAnimal.baja => 3,
      TipoHitoAnimal.evento => 2,
      TipoHitoAnimal.movimientoRebano => 1,
      TipoHitoAnimal.nacimiento => 0,
    };

DateTime _dia(int ms) {
  final fecha = DateTime.fromMillisecondsSinceEpoch(ms);
  return DateTime(fecha.year, fecha.month, fecha.day);
}

/// Compone la línea de tiempo de [animal] con los [movimientos] de su
/// rebaño y los [eventos] suyos y de su rebaño (lo que da
/// `listarEventosGanado(animalId:, loteId:)`). Lo de otros animales que
/// venga en [eventos] se descarta.
List<HitoAnimal> historialDeAnimal({
  required Animal animal,
  required Iterable<MovimientoGanado> movimientos,
  required Iterable<EventoGanado> eventos,
}) {
  final nacimiento = animal.fechaNacimientoMs;
  final baja = animal.activo ? null : animal.fechaBajaMs;
  // Por días, para que un movimiento del mismo día del nacimiento o de la
  // baja (con hora distinta) cuente.
  bool dentroDeSuVida(int fechaMs) {
    final dia = _dia(fechaMs);
    if (nacimiento != null && dia.isBefore(_dia(nacimiento))) return false;
    if (baja != null && dia.isAfter(_dia(baja))) return false;
    return true;
  }

  final hitos = <HitoAnimal>[
    if (nacimiento != null)
      HitoAnimal(tipo: TipoHitoAnimal.nacimiento, fechaMs: nacimiento),
    for (final evento in eventos)
      if (animal.id != null && evento.animalId == animal.id)
        HitoAnimal(
            tipo: TipoHitoAnimal.evento, fechaMs: evento.fechaMs, evento: evento)
      else if (evento.animalId == null &&
          evento.loteId != null &&
          evento.loteId == animal.loteId &&
          dentroDeSuVida(evento.fechaMs))
        HitoAnimal(
            tipo: TipoHitoAnimal.evento, fechaMs: evento.fechaMs, evento: evento),
    for (final movimiento in movimientos)
      if (movimiento.loteId == animal.loteId &&
          dentroDeSuVida(movimiento.fechaMs))
        HitoAnimal(
            tipo: TipoHitoAnimal.movimientoRebano,
            fechaMs: movimiento.fechaMs,
            movimiento: movimiento),
    if (baja != null) HitoAnimal(tipo: TipoHitoAnimal.baja, fechaMs: baja),
  ];
  hitos.sort((a, b) {
    final porDia = _dia(b.fechaMs).compareTo(_dia(a.fechaMs));
    if (porDia != 0) return porDia;
    final porTipo = _pesoMismaFecha(b.tipo).compareTo(_pesoMismaFecha(a.tipo));
    if (porTipo != 0) return porTipo;
    final porHora = b.fechaMs.compareTo(a.fechaMs);
    if (porHora != 0) return porHora;
    final idA = a.evento?.id ?? a.movimiento?.id ?? 0;
    final idB = b.evento?.id ?? b.movimiento?.id ?? 0;
    return idB.compareTo(idA);
  });
  return hitos;
}
