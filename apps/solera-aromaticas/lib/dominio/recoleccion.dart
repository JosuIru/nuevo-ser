// Comprobaciones de una recolección silvestre frente a su permiso. Lógica
// pura, sin Flutter.
//
// La app **no decide** si una recolección es legal: compara lo apuntado con
// el permiso que la persona copió de su autorización y avisa. La norma la
// fija cada comunidad autónoma (Ley 42/2007, art. 61; ver CLAUDE.md).

import '../modelos/cosecha.dart';
import '../modelos/zona_recoleccion.dart';

/// Avisos posibles al apuntar o revisar una recolección.
enum AvisoRecoleccion {
  /// La zona no tiene número de permiso apuntado.
  sinPermiso,

  /// La fecha cae fuera de la vigencia del permiso.
  fueraDeVigencia,

  /// El permiso enumera especies y esta no está.
  especieNoIncluida,

  /// Con esta recolección se pasa del límite de kg del permiso.
  superaLimite,

  /// El catálogo marca la especie con alguna figura de protección o
  /// recolección regulada (no se anima a recolectarla).
  especieConProteccion,
}

/// kg frescos recolectados en [zona] dentro de su vigencia (todas las
/// especies). Si el permiso no tiene fechas, todo lo de la zona.
double kgRecolectadosEnVigencia(
    ZonaRecoleccion zona, Iterable<Cosecha> cosechas) {
  var total = 0.0;
  for (final cosecha in cosechas) {
    if (cosecha.zonaRecoleccionId != zona.id) continue;
    final fecha = DateTime.fromMillisecondsSinceEpoch(cosecha.fechaMs);
    if (!zona.dentroDeVigencia(fecha)) continue;
    total += cosecha.kgFrescos;
  }
  return total;
}

/// Avisos de una recolección nueva ([kgNuevos] de [especieId] el día
/// [fecha]) en [zona], dadas las recolecciones ya apuntadas ([previas]; si
/// la que se edita ya está guardada, se pasa sin ella).
List<AvisoRecoleccion> comprobarRecoleccion({
  required ZonaRecoleccion zona,
  required String especieId,
  required DateTime fecha,
  required double kgNuevos,
  required Iterable<Cosecha> previas,
  bool especieConProteccion = false,
}) {
  final avisos = <AvisoRecoleccion>[];
  if (especieConProteccion) avisos.add(AvisoRecoleccion.especieConProteccion);
  if (!zona.tienePermiso) {
    avisos.add(AvisoRecoleccion.sinPermiso);
    return avisos;
  }
  if (!zona.vigenteEn(fecha)) avisos.add(AvisoRecoleccion.fueraDeVigencia);
  if (zona.cubreEspecie(especieId) == false) {
    avisos.add(AvisoRecoleccion.especieNoIncluida);
  }
  final limite = zona.limiteKg;
  if (limite != null &&
      kgRecolectadosEnVigencia(zona, previas) + kgNuevos > limite) {
    avisos.add(AvisoRecoleccion.superaLimite);
  }
  return avisos;
}

/// Zonas cuyo permiso vence en los próximos [dias] días (o venció hace
/// menos de una semana), de la más urgente a la menos.
List<ZonaRecoleccion> permisosPorVencer(
    Iterable<ZonaRecoleccion> zonas, DateTime hoy,
    {int dias = 30}) {
  final proximas = [
    for (final zona in zonas)
      if (zona.tienePermiso &&
          zona.diasHastaFinVigencia(hoy) != null &&
          zona.diasHastaFinVigencia(hoy)! <= dias &&
          zona.diasHastaFinVigencia(hoy)! >= -7)
        zona,
  ];
  proximas.sort((a, b) =>
      a.diasHastaFinVigencia(hoy)!.compareTo(b.diasHastaFinVigencia(hoy)!));
  return proximas;
}
