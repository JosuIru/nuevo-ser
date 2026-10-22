/// Unidades de ganado mayor (UGM) y carga ganadera.
///
/// PROVISIONAL: coeficientes por especie y edad de la «Tabla de equivalencias
/// en UGM por cabeza y especie» de la Junta de Andalucía (registro de
/// explotaciones; bovino, ovino, caprino, equino, porcino en extensivo y
/// aves), comprobada el 2026-10-22. Otras normas usan tablas distintas (la
/// PAC y sus ecorregímenes, la certificación ecológica): para un trámite,
/// manda la tabla de ese trámite. Sirve para ver la carga de cada pieza,
/// no para declararla.
library;

/// Fuente de los coeficientes, para rotularla en pantalla y en los PDF.
const String fuenteCoeficientesUgm =
    'Tabla de equivalencias en UGM por cabeza y especie (Junta de Andalucía)';

/// Meses cumplidos entre [nacimiento] y [ahora] (de calendario).
int mesesCumplidos(DateTime nacimiento, DateTime ahora) {
  var meses =
      (ahora.year - nacimiento.year) * 12 + ahora.month - nacimiento.month;
  if (ahora.day < nacimiento.day) meses--;
  return meses < 0 ? 0 : meses;
}

/// UGM de una cabeza. Sin fecha de nacimiento se toma como adulta. Una
/// especie sin coeficiente (o «varias») cuenta 0.
double ugmPorCabeza({
  required String especie,
  String sexo = '',
  int? fechaNacimientoMs,
  required DateTime ahora,
}) {
  final meses = fechaNacimientoMs == null
      ? null
      : mesesCumplidos(
          DateTime.fromMillisecondsSinceEpoch(fechaNacimientoMs), ahora);
  final adulto = meses == null || meses >= 12;
  switch (especie) {
    case 'vacuno':
      if (meses == null || meses >= 24) return 1.0;
      return meses < 6 ? 0.2 : 0.6;
    case 'ovino':
    case 'caprino':
      if (!adulto) return meses < 4 ? 0.05 : 0.10;
      return sexo == 'macho' ? 0.12 : 0.15;
    case 'equino':
      if (meses == null || meses >= 12) return 1.0;
      return meses < 6 ? 0.2 : 0.5;
    case 'porcino':
      // Extensivo: verraco 0,30; el resto como «cerdo de 20 a 150 kg».
      return adulto && sexo == 'macho' ? 0.30 : 0.25;
    case 'aves':
      return 0.015; // «Otras aves».
    default:
      return 0;
  }
}

/// UGM por hectárea, o null sin superficie.
double? cargaPorHectarea(double ugm, double? hectareas) =>
    hectareas == null || hectareas <= 0 ? null : ugm / hectareas;
