/// Reglas de la ganadería ecológica sobre tratamientos veterinarios.
///
/// Reglamento (UE) 2018/848, anexo II, parte II, punto 1.5 (comprobado el
/// 2026-10-22 con la circular de ganadería ecológica de la Junta de
/// Extremadura y la consulta de la Comisión sobre ese reglamento):
/// - tras un medicamento veterinario alopático de síntesis química (los
///   antibióticos incluidos) el tiempo de espera es el **doble** del legal y
///   como mínimo **48 horas**;
/// - más de **tres** tratamientos de ese tipo en **12 meses** (más de
///   **uno** si la vida productiva es menor de un año) y el animal o el lote
///   deja de poder venderse como ecológico y vuelve a conversión;
/// - no cuentan las vacunas, los antiparasitarios ni los tratamientos de los
///   programas de erradicación obligatoria (el «saneamiento» de la app).
///
/// PROVISIONAL hasta que lo revise CPAEN/NNPEK. Si no se sabe la clase del
/// medicamento, la app hace lo prudente: dobla el plazo y lo cuenta.
library;

import 'constantes.dart';
import 'ganado.dart';

const String claseAlopatico = 'alopatico';
const String claseAntiparasitario = 'antiparasitario';
const String claseVacuna = 'vacuna';
const String claseNatural = 'natural';

/// Clase del medicamento de un tratamiento ('' = sin indicar).
const List<OpcionCatalogo> clasesMedicamento = [
  OpcionCatalogo(
      claseAlopatico,
      'Alopático de síntesis química (antibióticos incluidos)',
      'Sintesi kimikoko alopatikoa (antibiotikoak barne)'),
  OpcionCatalogo(claseAntiparasitario, 'Antiparasitario', 'Antiparasitarioa'),
  OpcionCatalogo(claseVacuna, 'Vacuna', 'Txertoa'),
  OpcionCatalogo(claseNatural, 'Fitoterapia, homeopatía u oligoelementos',
      'Fitoterapia, homeopatia edo oligoelementuak'),
];

/// ¿Dobla el tiempo de espera en ecológico? Alopáticos y antiparasitarios
/// químicos sí; vacunas y remedios naturales no; sin indicar, por prudencia,
/// sí.
bool claseDoblaEspera(String clase) =>
    clase != claseVacuna && clase != claseNatural;

/// Días de espera que valen para vender como ecológico: el doble del legal
/// y como mínimo 2 días (48 h). Fuera de ecológico, el legal.
int plazoEfectivoDias(int diasLegales,
    {required bool ecologico, required String clase}) {
  if (!ecologico || !claseDoblaEspera(clase)) return diasLegales;
  final doble = diasLegales * 2;
  return doble < 2 ? 2 : doble;
}

/// Un evento con sus plazos ya ajustados a ecológico (si [ecologico]). Solo
/// los eventos con medicamento se ajustan.
EventoGanado eventoConPlazosEfectivos(EventoGanado evento,
    {required bool ecologico}) {
  if (!ecologico || !tiposEventoConMedicamento.contains(evento.tipo)) {
    return evento;
  }
  int ajustar(int dias) =>
      plazoEfectivoDias(dias, ecologico: true, clase: evento.claseMedicamento);
  final mapa = evento.toMap()
    ..['plazo_supresion_carne_dias'] = ajustar(evento.plazoSupresionCarneDias)
    ..['plazo_supresion_leche_dias'] = ajustar(evento.plazoSupresionLecheDias);
  return EventoGanado.fromMap(mapa);
}

/// ¿Cuenta para el límite de tratamientos? Solo los tratamientos (no el
/// saneamiento) que no son vacuna, antiparasitario ni remedio natural.
bool cuentaParaLimiteEcologico(EventoGanado evento) =>
    evento.tipo == tipoEventoTratamiento &&
    evento.claseMedicamento != claseVacuna &&
    evento.claseMedicamento != claseAntiparasitario &&
    evento.claseMedicamento != claseNatural;

/// Cómo va un animal o un lote ecológico respecto al límite.
class EstadoTratamientosEcologico {
  const EstadoTratamientosEcologico(
      {required this.tratamientos, required this.limite});

  /// Tratamientos que cuentan en los últimos 12 meses.
  final int tratamientos;

  /// 3, o 1 con vida productiva menor de un año.
  final int limite;

  /// Ha superado el límite: ya no se puede vender como ecológico.
  bool get superado => tratamientos > limite;

  /// Está en el límite: uno más y lo supera.
  bool get enElLimite => tratamientos == limite;
}

/// Tratamientos que cuentan en los 12 meses anteriores a [ahora] (desde el
/// mismo día del año anterior, incluido).
EstadoTratamientosEcologico estadoTratamientosEcologico(
    Iterable<EventoGanado> eventos, DateTime ahora,
    {required bool cicloCorto}) {
  final desde = DateTime(ahora.year - 1, ahora.month, ahora.day);
  final cuenta = eventos
      .where(cuentaParaLimiteEcologico)
      .where((evento) =>
          !DateTime.fromMillisecondsSinceEpoch(evento.fechaMs).isBefore(desde))
      .length;
  return EstadoTratamientosEcologico(
      tratamientos: cuenta, limite: cicloCorto ? 1 : 3);
}
