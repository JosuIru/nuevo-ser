/// Unidades de ganado mayor (UGM) y carga ganadera, **por trámite**.
///
/// En Zunbeltz (`carga_ganadera.dart`, commit `92ade2b`) los coeficientes
/// eran fijos y de la Junta de Andalucía. Aquí cada trámite trae su tabla
/// (`content/ganadera/tabla_ugm.csv`, compilada a
/// `catalogoCoeficientesUgm`): para la PAC manda el anexo V del
/// RD 1048/2022, y para otro trámite, la suya. PROVISIONAL: sirve para ver la
/// carga de cada pieza, no para declararla.
library;

/// Trámite de la PAC: RD 1048/2022, anexo V.
const String tramitePac = 'pac';

/// Registro de explotaciones de la Junta de Andalucía (la tabla de Zunbeltz).
const String tramiteAndalucia = 'andalucia';

/// Una fila de una tabla UGM: para [especie], [sexos] (vacío = cualquiera)
/// y una edad en meses en [edadMinimaMeses, edadMaximaMeses).
class CoeficienteUgm {
  const CoeficienteUgm({
    required this.tramite,
    required this.especie,
    this.sexos = const {},
    this.edadMinimaMeses = 0,
    this.edadMaximaMeses,
    required this.ugm,
    this.categoria = '',
  });

  final String tramite;
  final String especie;
  final Set<String> sexos;
  final int edadMinimaMeses;

  /// Sin límite si es null.
  final int? edadMaximaMeses;
  final double ugm;

  /// Cómo lo llama la norma («Otras vacas, de dos años o más»).
  final String categoria;

  bool encaja(String especieBuscada, String sexo, int meses) =>
      especie == especieBuscada &&
      (sexos.isEmpty || sexos.contains(sexo)) &&
      meses >= edadMinimaMeses &&
      (edadMaximaMeses == null || meses < edadMaximaMeses!);
}

/// Las filas de un trámite, en el orden del catálogo.
List<CoeficienteUgm> tablaDeTramite(
        List<CoeficienteUgm> todas, String tramite) =>
    todas.where((fila) => fila.tramite == tramite).toList();

/// Meses cumplidos entre [nacimiento] y [ahora] (de calendario).
int mesesCumplidos(DateTime nacimiento, DateTime ahora) {
  var meses =
      (ahora.year - nacimiento.year) * 12 + ahora.month - nacimiento.month;
  if (ahora.day < nacimiento.day) meses--;
  return meses < 0 ? 0 : meses;
}

/// Edad que se toma sin fecha de nacimiento: adulto.
const int mesesSinFechaDeNacimiento = 1200;

/// UGM de una cabeza según [tabla] (las filas de un trámite): la primera
/// fila que encaja. Sin fecha de nacimiento se toma como adulta. Sin fila,
/// 0 (la especie no cuenta en ese trámite).
double ugmPorCabeza({
  required List<CoeficienteUgm> tabla,
  required String especie,
  String sexo = '',
  int? fechaNacimientoMs,
  required DateTime ahora,
}) {
  final meses = fechaNacimientoMs == null
      ? mesesSinFechaDeNacimiento
      : mesesCumplidos(
          DateTime.fromMillisecondsSinceEpoch(fechaNacimientoMs), ahora);
  for (final fila in tabla) {
    if (fila.encaja(especie, sexo, meses)) return fila.ugm;
  }
  return 0;
}

/// UGM por hectárea, o null sin superficie.
double? cargaPorHectarea(double ugm, double? hectareas) =>
    hectareas == null || hectareas <= 0 ? null : ugm / hectareas;
