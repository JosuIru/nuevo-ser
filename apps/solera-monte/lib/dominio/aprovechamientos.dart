import '../modelos/aprovechamiento.dart';

/// Umbrales estatales de «menor cuantía» de la Ley 43/2003, art. 37.2.b
/// (consolidado BOE, https://www.boe.es/buscar/act.php?id=BOE-A-2003-21339,
/// leído el 2026-11-07): «inferiores a 10 metros cúbicos de madera o a 20
/// estéreos de leñas, salvo que las comunidades autónomas establezcan para
/// su territorio cuantías menores». La app solo **avisa**: no decide si hace
/// falta autorización.
const double menorCuantiaMaderaM3 = 10;
const double menorCuantiaLenaEstereos = 20;

/// Avisos de un aprovechamiento. Nunca bloquean.
enum AvisoAprovechamiento {
  /// Madera o leña sin trámite apuntado.
  tramitePendiente,

  /// Pasa del umbral estatal de menor cuantía (la CA puede fijar otro).
  superaMenorCuantia,

  /// Se vende y ha terminado: art. 37.4, comunicar la cuantía obtenida en
  /// un mes como máximo.
  comunicarCuantia,

  /// Ese mes ya pasó sin que conste la comunicación.
  comunicacionVencida,
}

/// Fecha límite del art. 37.4 (un mes desde que termina); null si no aplica
/// o ya consta la comunicación.
DateTime? limiteComunicacionCuantia(Aprovechamiento aprovechamiento) {
  final fin = aprovechamiento.fechaFinMs;
  if (!aprovechamiento.esMaderableOLenoso ||
      !aprovechamiento.comercializado ||
      fin == null ||
      aprovechamiento.fechaComunicacionCuantiaMs != null) {
    return null;
  }
  final fecha = DateTime.fromMillisecondsSinceEpoch(fin);
  // Un mes natural; si el día no existe (31 de enero → febrero), el último.
  final ultimoDiaMesSiguiente = DateTime(fecha.year, fecha.month + 2, 0).day;
  return DateTime(fecha.year, fecha.month + 1,
      fecha.day > ultimoDiaMesSiguiente ? ultimoDiaMesSiguiente : fecha.day);
}

/// ¿Pasa del umbral estatal de menor cuantía? Mira lo obtenido o, si aún no
/// hay nada, lo previsto.
bool superaMenorCuantia(Aprovechamiento aprovechamiento) {
  if (!aprovechamiento.esMaderableOLenoso) return false;
  final cantidad = aprovechamiento.cantidad > 0
      ? aprovechamiento.cantidad
      : (aprovechamiento.cantidadPrevista ?? 0);
  return switch (aprovechamiento.unidad) {
    'm3' => cantidad >= menorCuantiaMaderaM3,
    'estereos' => cantidad >= menorCuantiaLenaEstereos,
    _ => false,
  };
}

List<AvisoAprovechamiento> avisosAprovechamiento(
    Aprovechamiento aprovechamiento, DateTime hoy) {
  final limite = limiteComunicacionCuantia(aprovechamiento);
  final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
  return [
    if (aprovechamiento.esMaderableOLenoso &&
        aprovechamiento.tramite == 'pendiente')
      AvisoAprovechamiento.tramitePendiente,
    if (superaMenorCuantia(aprovechamiento))
      AvisoAprovechamiento.superaMenorCuantia,
    if (limite != null && !hoySinHora.isAfter(limite))
      AvisoAprovechamiento.comunicarCuantia,
    if (limite != null && hoySinHora.isAfter(limite))
      AvisoAprovechamiento.comunicacionVencida,
  ];
}

/// Totales de una campaña por tipo y unidad (no se suman unidades
/// distintas).
Map<(String, String), double> totalesPorTipoYUnidad(
    List<Aprovechamiento> aprovechamientos) {
  final totales = <(String, String), double>{};
  for (final aprovechamiento in aprovechamientos) {
    totales.update((aprovechamiento.tipo, aprovechamiento.unidad),
        (valor) => valor + aprovechamiento.cantidad,
        ifAbsent: () => aprovechamiento.cantidad);
  }
  return totales;
}
