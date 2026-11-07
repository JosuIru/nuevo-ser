/// Modelo de un plazo legal recurrente (calendario de obligaciones) de
/// la suite Larrea: solicitud única PAC, declaraciones INFOVI y AICA,
/// censo apícola REGA, modelos trimestrales de la AEAT…
///
/// Los datos viven en `content/solera/plazos.csv` (ver
/// `plazos_csv.dart`) y llevan sello PROVISIONAL hasta que un asesor
/// los revise. Este módulo solo calcula fechas: ni notifica ni decide
/// si una obligación aplica a un titular concreto (eso lo dice la nota
/// de cada plazo).
library;

/// Identificadores de las verticales de la suite Larrea a las que puede
/// aplicar un plazo. Coinciden con el sufijo de `apps/solera-<vertical>`
/// (con `_` en lugar de `-`), y `agro` es Larrea generalista.
const List<String> verticalesLarrea = [
  'agro',
  'viticultura',
  'apicola',
  'quesera',
  'aceitera',
  'arbolado_urbano',
];

/// Cómo se repite un plazo a lo largo del año.
sealed class PeriodicidadPlazo {
  const PeriodicidadPlazo();
}

/// Una vez al año, entre `diaInicio/mesInicio` y `diaFin/mesFin`, ambos
/// incluidos. Si el fin cae antes que el inicio en el calendario, la
/// ventana cruza el fin de año (p. ej. 15/11 – 15/02).
///
/// Un 29 de febrero se ajusta al 28 en los años no bisiestos: así se
/// expresa «antes del 1 de marzo».
final class PeriodicidadAnual extends PeriodicidadPlazo {
  const PeriodicidadAnual({
    required this.diaInicio,
    required this.mesInicio,
    required this.diaFin,
    required this.mesFin,
  });

  final int diaInicio;
  final int mesInicio;
  final int diaFin;
  final int mesFin;

  /// `true` si la ventana empieza un año y termina el siguiente.
  bool get cruzaFinDeAnio =>
      mesFin < mesInicio || (mesFin == mesInicio && diaFin < diaInicio);
}

/// Cada mes, del día 1 al `diaLimite` (incluido). Un día límite mayor
/// que los días del mes se ajusta al último día del mes.
final class PeriodicidadMensual extends PeriodicidadPlazo {
  const PeriodicidadMensual({required this.diaLimite});

  final int diaLimite;
}

/// Cada trimestre natural, en el mes siguiente a su cierre (abril, julio,
/// octubre y enero), del día 1 al `diaLimite`. El cuarto trimestre puede
/// tener su propio límite en enero (`diaLimiteCuartoTrimestre`, p. ej.
/// el 30 de enero de los modelos 303 y 130); si es `null` usa
/// `diaLimite`.
final class PeriodicidadTrimestral extends PeriodicidadPlazo {
  const PeriodicidadTrimestral({
    required this.diaLimite,
    this.diaLimiteCuartoTrimestre,
  });

  final int diaLimite;
  final int? diaLimiteCuartoTrimestre;
}

/// Un plazo legal recurrente con la norma que lo fija.
class PlazoLegal {
  const PlazoLegal({
    required this.identificador,
    required this.verticales,
    required this.nombreVisible,
    required this.normaCitada,
    required this.urlFuente,
    required this.periodicidad,
    this.antelacionAvisoDias = 0,
    this.nota = '',
  });

  /// Id estable en snake_case (p. ej. `pac_solicitud_unica`).
  final String identificador;

  /// Verticales de [verticalesLarrea] a las que aplica.
  final List<String> verticales;

  final String nombreVisible;

  /// Norma y artículo que fijan el plazo (p. ej. «RD 1048/2022, art. 108.2»).
  final String normaCitada;

  /// Enlace a la fuente pública consultada (BOE, AEAT…).
  final String urlFuente;

  final PeriodicidadPlazo periodicidad;

  /// Cuántos días antes del día límite empieza a avisar. 0 = solo el
  /// propio día límite.
  final int antelacionAvisoDias;

  /// Matices: quién está obligado, variaciones por comunidad autónoma…
  final String nota;

  bool aplicaA(String vertical) =>
      verticales.contains(vertical.trim().toLowerCase());

  @override
  String toString() => 'PlazoLegal($identificador)';
}

/// Una ocurrencia concreta de un plazo: del día [inicio] al día [fin]
/// (día límite), ambos incluidos y sin hora.
class OcurrenciaPlazo {
  const OcurrenciaPlazo({required this.inicio, required this.fin});

  final DateTime inicio;
  final DateTime fin;

  /// `true` si [fecha] (se ignora la hora) cae dentro de la ventana.
  bool estaAbierta(DateTime fecha) {
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    return !dia.isBefore(inicio) && !dia.isAfter(fin);
  }

  @override
  bool operator ==(Object other) =>
      other is OcurrenciaPlazo && other.inicio == inicio && other.fin == fin;

  @override
  int get hashCode => Object.hash(inicio, fin);

  @override
  String toString() => 'OcurrenciaPlazo($inicio – $fin)';
}

/// Un plazo que debe avisarse hoy, con su ocurrencia y los días que
/// faltan hasta el día límite (0 = hoy es el último día).
class AvisoPlazo {
  const AvisoPlazo({
    required this.plazo,
    required this.ocurrencia,
    required this.diasRestantes,
  });

  final PlazoLegal plazo;
  final OcurrenciaPlazo ocurrencia;
  final int diasRestantes;

  @override
  String toString() =>
      'AvisoPlazo(${plazo.identificador}, faltan $diasRestantes días)';
}
