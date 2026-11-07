// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/viticultura/materias_activas.csv
// Generado: 2026-11-07
// Filas: 16 (0 revisadas, 16 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-viticultura && dart run tool/compilar_catalogos.dart

class MateriaActiva {
  final String id;
  final String nombreCanonico;
  /// IDs de plagas en `catalogo_plagas_vid.dart` para las que está autorizada.
  final List<String> plagasObjetivo;
  final String tipoAccion;
  /// Plazo de seguridad orientativo en días. ⚠ Verificar etiqueta del producto.
  final int plazoSeguridadOrientativoDias;
  final bool autorizadaEcologico;
  final String notas;

  const MateriaActiva({
    required this.id,
    required this.nombreCanonico,
    required this.plagasObjetivo,
    required this.tipoAccion,
    required this.plazoSeguridadOrientativoDias,
    required this.autorizadaEcologico,
    this.notas = '',
  });
}

const List<MateriaActiva> catalogoMateriasActivas = [
  MateriaActiva(
    id: 'azufre',
    nombreCanonico: 'Azufre',
    plagasObjetivo: ['oidio'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: true,
    notas: 'Mojable o espolvoreo. PS habitual no procede–5 d; algún producto 7 d y uno 28 d (la fila usa el máximo): verificar etiqueta. No aplicar con temperaturas elevadas (riesgo de fitotoxicidad).',
  ),
  MateriaActiva(
    id: 'sulfato_cobre',
    nombreCanonico: 'Sulfato cuprocálcico (caldo bordelés)',
    plagasObjetivo: ['mildiu'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 21,
    autorizadaEcologico: true,
    notas: 'PS 3–21 d según producto. Límite UE: máx. 28 kg Cu/ha en 7 años (Reg. 2018/1981); los Estados miembros pueden fijar un máximo anual ≤4 kg/ha.',
  ),
  MateriaActiva(
    id: 'hidroxido_cobre',
    nombreCanonico: 'Hidróxido de cobre',
    plagasObjetivo: ['mildiu'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: true,
    notas: 'PS 7–21 d en productos solo con hidróxido; hasta 28 d en alguna mezcla. Mismo límite UE de Cu: 28 kg/ha en 7 años.',
  ),
  MateriaActiva(
    id: 'oxicloruro_cobre',
    nombreCanonico: 'Oxicloruro de cobre',
    plagasObjetivo: ['mildiu'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: true,
    notas: 'Alternativa cúprica. PS 15–21 d en productos solo con oxicloruro; hasta 28 d en alguna mezcla. Mismo límite UE de Cu: 28 kg/ha en 7 años.',
  ),
  MateriaActiva(
    id: 'folpet',
    nombreCanonico: 'Folpet',
    plagasObjetivo: ['mildiu', 'black_rot'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'Preventivo de amplio espectro. PS 28 d en vid de vinificación; vid de mesa hasta 56/70 d (56 solo; 70 en mezclas). Verificar etiqueta.',
  ),
  MateriaActiva(
    id: 'fosetil_aluminio',
    nombreCanonico: 'Fosetil-aluminio',
    plagasObjetivo: ['mildiu'],
    tipoAccion: 'sistemico',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'Sistémico ascendente y descendente. PS 28 d.',
  ),
  MateriaActiva(
    id: 'azoxistrobin',
    nombreCanonico: 'Azoxistrobin',
    plagasObjetivo: ['mildiu', 'oidio'],
    tipoAccion: 'sistemico',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'Estrobilurina. PS 21 d solo; hasta 28 d en mezclas. Resistencia cruzada — alternar con otros modos de acción.',
  ),
  MateriaActiva(
    id: 'tebuconazol',
    nombreCanonico: 'Tebuconazol',
    plagasObjetivo: ['oidio'],
    tipoAccion: 'sistemico',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'Triazol. PS 7–21 d solo; hasta 28 d en mezclas. Candidato a sustitución; aprobación UE prorrogada hasta 31/07/2028.',
  ),
  MateriaActiva(
    id: 'penconazol',
    nombreCanonico: 'Penconazol',
    plagasObjetivo: ['oidio'],
    tipoAccion: 'sistemico',
    plazoSeguridadOrientativoDias: 14,
    autorizadaEcologico: false,
    notas: 'Triazol clásico para oídio. PS 14 d.',
  ),
  MateriaActiva(
    id: 'boscalid',
    nombreCanonico: 'Boscalid',
    plagasObjetivo: ['oidio'],
    tipoAccion: 'translaminar',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'SDHI. En vid solo autorizado contra oídio (no contra botritis). PS 28 d. Mezclas registradas con kresoxim-metil o piraclostrobin.',
  ),
  MateriaActiva(
    id: 'fluopiram',
    nombreCanonico: 'Fluopiram',
    plagasObjetivo: ['botritis', 'oidio'],
    tipoAccion: 'translaminar',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'SDHI. PS 3–28 d según producto. Bajo riesgo de resistencia si se rota.',
  ),
  MateriaActiva(
    id: 'ciprodinil',
    nombreCanonico: 'Ciprodinil',
    plagasObjetivo: ['botritis'],
    tipoAccion: 'sistemico',
    plazoSeguridadOrientativoDias: 28,
    autorizadaEcologico: false,
    notas: 'Anilinopirimidina. PS 21 d en vinificación y 7 d en mesa; hasta 28 d en mezcla con tebuconazol.',
  ),
  MateriaActiva(
    id: 'fludioxonil',
    nombreCanonico: 'Fludioxonil',
    plagasObjetivo: ['botritis'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 21,
    autorizadaEcologico: false,
    notas: 'En vid solo en mezcla con ciprodinil. PS 21 d en vinificación y 7 d en mesa.',
  ),
  MateriaActiva(
    id: 'bacillus_thuringiensis_kurstaki',
    nombreCanonico: 'Bacillus thuringiensis kurstaki',
    plagasObjetivo: ['polilla_racimo'],
    tipoAccion: 'biologico',
    plazoSeguridadOrientativoDias: 0,
    autorizadaEcologico: true,
    notas: 'Solo eficaz contra larvas pequeñas. PS no procede.',
  ),
  MateriaActiva(
    id: 'spinosad',
    nombreCanonico: 'Spinosad',
    plagasObjetivo: ['polilla_racimo'],
    tipoAccion: 'contacto',
    plazoSeguridadOrientativoDias: 14,
    autorizadaEcologico: true,
    notas: 'Origen microbiano. PS 14 d. Sin condiciones específicas en el anexo I de 2021/1165. Muy tóxico para abejas: respetar las mitigaciones de la etiqueta.',
  ),
  MateriaActiva(
    id: 'aceite_parafinico',
    nombreCanonico: 'Aceite parafínico',
    plagasObjetivo: ['acaros_eriofidos'],
    tipoAccion: 'fisico',
    plazoSeguridadOrientativoDias: 1,
    autorizadaEcologico: true,
    notas: 'Acción física. PS no procede–1 d.',
  ),
];

MateriaActiva? materiaActivaPorId(String id) {
  for (final m in catalogoMateriasActivas) {
    if (m.id == id) return m;
  }
  return null;
}

/// Filtra materias activas por plaga objetivo. Útil cuando el viticultor
/// abre un tratamiento desde una incidencia concreta y quiere ver qué
/// materias están autorizadas para esa plaga.
List<MateriaActiva> materiasParaPlaga(String idPlaga) {
  return catalogoMateriasActivas
      .where((m) => m.plagasObjetivo.contains(idPlaga))
      .toList();
}
