// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aceitera/fitosanitarios_olivar.csv
// Generado: 2026-11-07
// Filas: 18 (0 firmadas por persona, 18 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aceitera && dart run tool/compilar_catalogos.dart

class FitosanitarioOlivar {
  final String id;
  final String nombreCanonico;
  /// IDs de plagas_olivo para las que está autorizada.
  final List<String> plagasObjetivo;
  /// insecticida / fungicida / acaricida / herbicida / biorracional.
  final String tipoAccion;
  /// Plazo de seguridad orientativo en días.
  /// ⚠ Verificar etiqueta del producto comercial vigente.
  final int plazoSeguridadOrientativoDias;
  final bool autorizadaEcologico;
  final String notas;

  const FitosanitarioOlivar({
    required this.id,
    required this.nombreCanonico,
    required this.plagasObjetivo,
    required this.tipoAccion,
    required this.plazoSeguridadOrientativoDias,
    required this.autorizadaEcologico,
    this.notas = '',
  });
}

const List<FitosanitarioOlivar> catalogoFitosanitariosOlivar = [
  FitosanitarioOlivar(
    id: 'spinosad',
    nombreCanonico: 'Spinosad',
    plagasObjetivo: ['mosca_olivo'],
    tipoAccion: 'insecticida',
    plazoSeguridadOrientativoDias: 7,
    autorizadaEcologico: true,
    notas: 'Solo formulación en cebo contra mosca del olivo (PS 7 d). Sin uso autorizado contra prays en olivo.',
  ),
  FitosanitarioOlivar(
    id: 'deltametrina',
    nombreCanonico: 'Deltametrina',
    plagasObjetivo: ['mosca_olivo', 'cochinilla_tizne'],
    tipoAccion: 'insecticida',
    plazoSeguridadOrientativoDias: 7,
    autorizadaEcologico: false,
    notas: 'Piretroide. PS 7 d en pulverización (3 d en algún producto de verdeo); trampas y atrayentes: PS no procede. Revisar restricciones por DOP y residuos.',
  ),
  FitosanitarioOlivar(
    id: 'caolin',
    nombreCanonico: 'Caolín en polvo',
    plagasObjetivo: ['mosca_olivo', 'prays_olivo'],
    tipoAccion: 'insecticida',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: true,
    notas: 'Barrera mineral física que reduce la oviposición. PS no procede–28 d según producto: verificar etiqueta.',
  ),
  FitosanitarioOlivar(
    id: 'proteina_hidrolizada',
    nombreCanonico: 'Proteína hidrolizada',
    plagasObjetivo: ['mosca_olivo'],
    tipoAccion: 'biorracional',
    plazoSeguridadOrientativoDias: 0,
    autorizadaEcologico: true,
    notas: 'Cebo atrayente en mezcla con insecticida en parcheo. PS y nº de aplicaciones = los del insecticida con que se mezcle (el 0 no aplica por sí solo).',
  ),
  FitosanitarioOlivar(
    id: 'oxicloruro_cobre',
    nombreCanonico: 'Oxicloruro de cobre',
    plagasObjetivo: ['repilo', 'emplomado', 'tuberculosis_olivo'],
    tipoAccion: 'fungicida',
    plazoSeguridadOrientativoDias: 15,
    autorizadaEcologico: true,
    notas: 'Cúprico. PS 14–15 d. Límite UE para toda la producción (no solo ecológica): máx. 28 kg Cu/ha en 7 años (Reg. 2018/1981).',
  ),
  FitosanitarioOlivar(
    id: 'hidroxido_cobre',
    nombreCanonico: 'Hidróxido de cobre',
    plagasObjetivo: ['repilo', 'tuberculosis_olivo', 'antracnosis_olivo'],
    tipoAccion: 'fungicida',
    plazoSeguridadOrientativoDias: 15,
    autorizadaEcologico: true,
    notas: 'Cúprico. PS 14–15 d. Sin uso autorizado en emplomado. Límite UE: máx. 28 kg Cu/ha en 7 años.',
  ),
  FitosanitarioOlivar(
    id: 'sulfato_cobre',
    nombreCanonico: 'Sulfato cuprocálcico (caldo bordelés) / sulfato tribásico de cobre',
    plagasObjetivo: ['repilo', 'tuberculosis_olivo', 'emplomado', 'antracnosis_olivo'],
    tipoAccion: 'fungicida',
    plazoSeguridadOrientativoDias: 20,
    autorizadaEcologico: true,
    notas: 'Cúprico (el sulfato de cobre simple no está aprobado). PS 14–20 d según producto. Límite UE: máx. 28 kg Cu/ha en 7 años. Precaución por fitotoxicidad en hojas jóvenes.',
  ),
  FitosanitarioOlivar(
    id: 'dodina',
    nombreCanonico: 'Dodina',
    plagasObjetivo: ['repilo', 'antracnosis_olivo'],
    tipoAccion: 'fungicida',
    plazoSeguridadOrientativoDias: 7,
    autorizadaEcologico: false,
    notas: 'Curativo y preventivo. PS 7 d (no procede en algún producto). Sin uso autorizado en emplomado.',
  ),
  FitosanitarioOlivar(
    id: 'azufre_micronizado',
    nombreCanonico: 'Azufre micronizado',
    plagasObjetivo: ['arañuela_amarilla', 'cochinilla_tizne'],
    tipoAccion: 'fungicida',
    plazoSeguridadOrientativoDias: 14,
    autorizadaEcologico: true,
    notas: 'Fungicida y acaricida. PS no procede–3 d en productos solo con azufre; hasta 14 d en mezclas con cobre. Contra la negrilla (fumagina) y no contra la cochinilla. Precaución con temperaturas altas.',
  ),
  FitosanitarioOlivar(
    id: 'piretrinas_naturales',
    nombreCanonico: 'Piretrinas naturales',
    plagasObjetivo: ['prays_olivo'],
    tipoAccion: 'insecticida',
    plazoSeguridadOrientativoDias: 5,
    autorizadaEcologico: true,
    notas: 'Origen vegetal (pelitre). PS 5 d. Sin uso autorizado en cochinilla. Fotodegradación rápida.',
  ),
  FitosanitarioOlivar(
    id: 'bacillus_thuringiensis',
    nombreCanonico: 'Bacillus thuringiensis',
    plagasObjetivo: ['prays_olivo', 'glifodes'],
    tipoAccion: 'biorracional',
    plazoSeguridadOrientativoDias: 0,
    autorizadaEcologico: true,
    notas: 'Bioinsecticida específico contra orugas. PS no procede.',
  ),
  FitosanitarioOlivar(
    id: 'beauveria_bassiana',
    nombreCanonico: 'Beauveria bassiana',
    plagasObjetivo: ['mosca_olivo'],
    tipoAccion: 'biorracional',
    plazoSeguridadOrientativoDias: 0,
    autorizadaEcologico: true,
    notas: 'Hongo entomopatógeno (cepa ATCC 74040) autorizado solo contra mosca del olivo. Eficacia dependiente de humedad.',
  ),
  FitosanitarioOlivar(
    id: 'glifosato',
    nombreCanonico: 'Glifosato',
    plagasObjetivo: [],
    tipoAccion: 'herbicida',
    plazoSeguridadOrientativoDias: 60,
    autorizadaEcologico: false,
    notas: 'Herbicida sistémico para calle/ruedo. PS 7–28 d en productos solo con glifosato; 60 d en mezclas con MCPA: verificar etiqueta.',
  ),
  FitosanitarioOlivar(
    id: 'oxifluorfen',
    nombreCanonico: 'Oxifluorfen',
    plagasObjetivo: [],
    tipoAccion: 'herbicida',
    plazoSeguridadOrientativoDias: 21,
    autorizadaEcologico: false,
    notas: 'Herbicida residual. PS 7 d sin aceituna en suelo y 14–21 d con aceituna caída según producto. Candidato a sustitución.',
  ),
  FitosanitarioOlivar(
    id: 'mcpa',
    nombreCanonico: 'MCPA',
    plagasObjetivo: [],
    tipoAccion: 'herbicida',
    plazoSeguridadOrientativoDias: 60,
    autorizadaEcologico: false,
    notas: 'Herbicida hormonal para dicotiledóneas; usar sin viento. PS no procede en productos solo con MCPA; 60 d en mezclas con glifosato.',
  ),
  FitosanitarioOlivar(
    id: 'acido_pelargonico',
    nombreCanonico: 'Ácido pelargónico',
    plagasObjetivo: [],
    tipoAccion: 'herbicida',
    plazoSeguridadOrientativoDias: 1,
    autorizadaEcologico: false,
    notas: 'Herbicida de contacto. No admitido en ecológico (el anexo I de 2021/1165 excluye los ácidos grasos como herbicida). PS no procede–1 d.',
  ),
  FitosanitarioOlivar(
    id: 'aceite_invierno',
    nombreCanonico: 'Aceite parafínico de invierno',
    plagasObjetivo: ['cochinilla_tizne', 'algodoncillo'],
    tipoAccion: 'insecticida',
    plazoSeguridadOrientativoDias: 0,
    autorizadaEcologico: true,
    notas: 'Asfixia mecánica de cochinillas; aplicar en parada vegetativa. PS no procede. Sin uso autorizado en cochinilla violeta (Parlatoria).',
  ),
  FitosanitarioOlivar(
    id: 'fosfonato_potasico',
    nombreCanonico: 'Fosfonato potásico',
    plagasObjetivo: ['repilo'],
    tipoAccion: 'fungicida',
    plazoSeguridadOrientativoDias: 15,
    autorizadaEcologico: false,
    notas: 'Inductor de defensas. PS 15 d. No admitido en ecológico (no figura en el anexo I de 2021/1165).',
  ),
];

FitosanitarioOlivar? fitosanitarioOlivarPorId(String id) {
  for (final f in catalogoFitosanitariosOlivar) {
    if (f.id == id) return f;
  }
  return null;
}

/// Filtra sustancias activas autorizadas para una plaga concreta.
List<FitosanitarioOlivar> fitosanitariosParaPlaga(String idPlaga) {
  return catalogoFitosanitariosOlivar
      .where((f) => f.plagasObjetivo.contains(idPlaga))
      .toList();
}

List<FitosanitarioOlivar> buscarFitosanitariosOlivar(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoFitosanitariosOlivar.where((f) {
    return _normalizar(f.nombreCanonico).contains(q) ||
        _normalizar(f.id).contains(q);
  }).toList();
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}

