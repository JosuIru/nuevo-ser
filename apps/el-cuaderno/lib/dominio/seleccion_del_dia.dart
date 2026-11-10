import 'misterio.dart';
import 'pista_campo.dart';

/// Selectores deterministas de "lo del día" para que el home siempre
/// tenga contenido aunque el catálogo filtrado por estación + región
/// quede vacío:
///
/// - [seleccionarMisterioDelDia]: prioriza el catálogo filtrado al
///   contexto; si está vacío, cae al catálogo completo abierto; si
///   ambos están vacíos, devuelve null.
/// - [seleccionarPistaDelDia]: rota entre las pistas de campo
///   abiertas. Si la lista está vacía, devuelve null.
///
/// Ambos selectores son **deterministas por fecha**: el mismo día
/// (mismo año/mes/día) devuelve la misma selección sin importar
/// cuántas veces se invoque. Eso garantiza estabilidad pedagógica
/// — el niño puede compartir "hoy el cuaderno me ha propuesto X"
/// con otra niña del mismo lugar y verán lo mismo, y un mismo niño
/// no ve algo distinto cada vez que abre el home en el mismo día.
///
/// El cambio de día se produce a medianoche local del dispositivo,
/// sin push, sin notificación — el niño descubre la nueva propuesta
/// cuando vuelve a abrir el cuaderno.

/// Devuelve el Misterio destacado "para hoy" o `null` si no hay
/// candidatos. Estrategia:
///
/// 1. Si [candidatosEnContexto] tiene al menos un elemento, elige
///    uno determinísticamente con la semilla diaria. Es la opción
///    pedagógicamente preferida: estación y región encajan.
/// 2. Si no, cae a [fallbackEnteroAbierto] (toda la lista de
///    Misterios abiertos sin filtrar por contexto). Mejor proponer
///    algo fuera de temporada que dejar al niño con la pantalla
///    vacía — la página del Misterio le contará luego que toca
///    volver en otra estación (la sección "vuelve en X" ya
///    existente en `PantallaDetalleObservacion` + `PantallaPaginaMisterio`).
/// 3. Si ambas listas están vacías, devuelve `null`.
Misterio? seleccionarMisterioDelDia({
  required List<Misterio> candidatosEnContexto,
  required List<Misterio> fallbackEnteroAbierto,
  required DateTime fecha,
}) {
  final semilla = _semillaDelDia(fecha);
  if (candidatosEnContexto.isNotEmpty) {
    return candidatosEnContexto[semilla % candidatosEnContexto.length];
  }
  if (fallbackEnteroAbierto.isNotEmpty) {
    return fallbackEnteroAbierto[semilla % fallbackEnteroAbierto.length];
  }
  return null;
}

/// Devuelve la pista de campo del día o `null` si la lista está vacía.
/// Estrategia: hash determinista de la fecha módulo el tamaño de la
/// lista. Usa una semilla **distinta** a la del Misterio del día para
/// que las dos rotaciones no marchen siempre acopladas (que un niño
/// no vea siempre "Misterio X + pista Y" como par fijo).
PistaCampo? seleccionarPistaDelDia({
  required List<PistaCampo> pistas,
  required DateTime fecha,
}) {
  if (pistas.isEmpty) return null;
  // Semilla con un desfase primo respecto a la del Misterio para
  // desacoplar las dos rotaciones.
  final semilla = _semillaDelDia(fecha) * 7919;
  return pistas[semilla.abs() % pistas.length];
}

/// Semilla entera estable a partir de una fecha — solo año/mes/día,
/// la hora se descarta para que la misma fecha de calendario produzca
/// la misma semilla independientemente de cuándo del día se invoque.
int _semillaDelDia(DateTime fecha) {
  return fecha.year * 10000 + fecha.month * 100 + fecha.day;
}
