// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/arbolado-urbano/plagas_urbanas.csv
// Generado: 2026-11-07
// Filas: 21 (0 revisadas, 21 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-arbolado-urbano && dart run tool/compilar_catalogos.dart

/// Categoría de la incidencia urbana.
enum TipoPlagaUrbana { plagaInsecto, enfermedadFungica, enfermedadBacteriana, plagaInvasora, trastornoAbiotico }

class PlagaUrbana {
  final String id;
  final String nombreComun;
  final String nombreCientifico;
  final TipoPlagaUrbana tipo;
  final List<String> especiesObjetivo;
  final String sintomas;
  final String ventanaAviso;
  final String manejoCultural;
  /// `true` para plagas de declaración obligatoria al servicio fitosanitario oficial.
  final bool declaracionOficial;
  /// `true` si afecta a la salud de viandantes (urticaria, alergias graves).
  final bool riesgoSanitarioPublico;
  final String notas;

  const PlagaUrbana({
    required this.id,
    required this.nombreComun,
    this.nombreCientifico = '',
    required this.tipo,
    this.especiesObjetivo = const [],
    this.sintomas = '',
    this.ventanaAviso = '',
    this.manejoCultural = '',
    this.declaracionOficial = false,
    this.riesgoSanitarioPublico = false,
    this.notas = '',
  });
}

const List<PlagaUrbana> catalogoPlagasUrbanas = [
  PlagaUrbana(
    id: 'procesionaria_pino',
    nombreComun: 'Procesionaria del pino',
    nombreCientifico: 'Thaumetopoea pityocampa',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['pino_pinonero', 'pino_carrasco'],
    sintomas: 'Bolsones blancos algodonosos en ramas|defoliación|orugas en procesión por el suelo en primavera',
    ventanaAviso: 'Otoño-invierno (bolsones)|primavera (procesiones)',
    manejoCultural: 'Trampas de feromonas en otoño|colocación de trampas de embudo descenso|destrucción manual de bolsones por personal con EPI|cinturón de cartón ondulado en el tronco',
    riesgoSanitarioPublico: true,
    notas: 'Las orugas tienen pelos urticantes que provocan reacciones graves en personas y animales — vigilancia activa en zonas escolares y paseos',
  ),
  PlagaUrbana(
    id: 'picudo_rojo',
    nombreComun: 'Picudo rojo de las palmeras',
    nombreCientifico: 'Rhynchophorus ferrugineus',
    tipo: TipoPlagaUrbana.plagaInvasora,
    especiesObjetivo: ['palmera_datilera', 'palmera_canaria'],
    sintomas: 'Hojas centrales colgantes|aspecto decapitado de la copa|aserrín característico en la base|orificios en estípite',
    ventanaAviso: 'Todo el año (más visible en verano)',
    manejoCultural: 'Trampeo masivo|saneamiento e incineración del material infectado|vigilancia de palmeras importadas',
    declaracionOficial: true,
    notas: 'DECLARACIÓN OBLIGATORIA. Especie regulada por Reglamento UE 2019/2072 y RD 526/2014.',
  ),
  PlagaUrbana(
    id: 'anthracnosis_platano',
    nombreComun: 'Anthracnosis del plátano',
    nombreCientifico: 'Apiognomonia veneta',
    tipo: TipoPlagaUrbana.enfermedadFungica,
    especiesObjetivo: ['platano_sombra'],
    sintomas: 'Manchas marrones angulares en hoja|defoliación temprana|necrosis de brotes',
    ventanaAviso: 'Primavera (pre-foliación) / verano húmedo',
    manejoCultural: 'Recogida y destrucción de hoja caída|favorecer ventilación de copa con poda selectiva|riego al pie evitando mojar hoja',
    notas: 'Enfermedad sistémica del plátano de sombra — combinable con poda sanitaria invernal',
  ),
  PlagaUrbana(
    id: 'oidio_platano',
    nombreComun: 'Oídio del plátano',
    nombreCientifico: 'Erysiphe platani',
    tipo: TipoPlagaUrbana.enfermedadFungica,
    especiesObjetivo: ['platano_sombra'],
    sintomas: 'Polvillo blanco en haz de la hoja|deformación foliar|defoliación parcial',
    ventanaAviso: 'Verano caluroso seco',
    manejoCultural: 'Aireación de copa por aclareo|riego abundante al pie',
    notas: 'Convive frecuentemente con la anthracnosis',
  ),
  PlagaUrbana(
    id: 'mancha_negra_peral',
    nombreComun: 'Mancha negra del peral ornamental',
    nombreCientifico: 'Stigmina carpophila',
    tipo: TipoPlagaUrbana.enfermedadFungica,
    especiesObjetivo: ['almendro_ornamental'],
    sintomas: 'Manchas circulares marrón-negras en hoja|caída prematura|frutos manchados',
    ventanaAviso: 'Primavera lluviosa',
    manejoCultural: 'Poda sanitaria de ramas afectadas|recogida de hoja caída|aclareo de copa',
    notas: 'También conocida como cribado en almendros',
  ),
  PlagaUrbana(
    id: 'lagarta_peluda',
    nombreComun: 'Lagarta peluda',
    nombreCientifico: 'Lymantria dispar',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['encina', 'melojo', 'olmo_comun'],
    sintomas: 'Defoliación severa de copa|orugas peludas grandes|masas de huevos cubiertas de pelos amarillos en tronco',
    ventanaAviso: 'Primavera-verano',
    manejoCultural: 'Destrucción de masas de huevos en invierno|trampas de feromonas|control biológico con Bacillus thuringiensis',
    riesgoSanitarioPublico: true,
    notas: 'Los pelos pueden causar urticaria en personas sensibles — vigilancia escolar',
  ),
  PlagaUrbana(
    id: 'escolitidos_olmo',
    nombreComun: 'Escolítidos del olmo',
    nombreCientifico: 'Scolytus scolytus',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['olmo_comun'],
    sintomas: 'Galerías subcorticales radiales|copas amarillentas|caída brusca de hoja',
    ventanaAviso: 'Verano',
    manejoCultural: 'Apeo y destrucción de árboles muertos|control biológico',
    notas: 'Vector principal de la grafiosis del olmo — más grave por la enfermedad que transmite que por daño directo',
  ),
  PlagaUrbana(
    id: 'grafiosis_olmo',
    nombreComun: 'Grafiosis del olmo',
    nombreCientifico: 'Ophiostoma novo-ulmi',
    tipo: TipoPlagaUrbana.enfermedadFungica,
    especiesObjetivo: ['olmo_comun'],
    sintomas: 'Marchitamiento de copa|amarilleamiento súbito|necrosis vascular interna marrón',
    ventanaAviso: 'Verano',
    manejoCultural: 'Apeo inmediato y destrucción de árboles afectados|sustitución por especies resistentes (olmo siberiano|melojo)',
    notas: 'Devastadora — ha eliminado los olmos comunes de muchas alineaciones históricas',
  ),
  PlagaUrbana(
    id: 'cochinilla_algodonosa',
    nombreComun: 'Cochinilla algodonosa',
    nombreCientifico: 'Planococcus citri',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['naranjo_amargo', 'laurel_indias', 'magnolio'],
    sintomas: 'Masas algodonosas blancas en envés y ramas|melaza pegajosa|negrilla secundaria',
    ventanaAviso: 'Todo el año (peor en primavera-verano)',
    manejoCultural: 'Lavado a presión de manguera|favorecer enemigos naturales (Cryptolaemus)|poda de aireación',
    notas: 'La negrilla (hongo secundario sobre la melaza) afecta a vehículos estacionados bajo el árbol',
  ),
  PlagaUrbana(
    id: 'mineradores_foliares',
    nombreComun: 'Mineradores foliares',
    nombreCientifico: 'Phyllonorycter spp',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['robinia', 'platano_sombra'],
    sintomas: 'Galerías serpenteantes blanquecinas en haz de la hoja|defoliación parcial',
    ventanaAviso: 'Primavera-verano',
    manejoCultural: 'Recogida de hoja caída en otoño|aireación de copa',
    notas: 'Daño estético más que sanitario en la mayoría de casos',
  ),
  PlagaUrbana(
    id: 'chancro_cipres',
    nombreComun: 'Chancro del ciprés',
    nombreCientifico: 'Seiridium cardinale',
    tipo: TipoPlagaUrbana.enfermedadFungica,
    especiesObjetivo: ['ciprés_mediterráneo'],
    sintomas: 'Ramas individuales que pierden el verde y se tornan rojizas|exudaciones de resina|cortezas con grietas alargadas',
    ventanaAviso: 'Primavera-verano',
    manejoCultural: 'Poda sanitaria de ramas afectadas con desinfección de tijera|sustituir cipreses muertos por especies resistentes',
    notas: 'Enfermedad clave del ciprés mediterráneo — vigilancia en cementerios y paseos formales',
  ),
  PlagaUrbana(
    id: 'fuego_bacteriano',
    nombreComun: 'Fuego bacteriano',
    nombreCientifico: 'Erwinia amylovora',
    tipo: TipoPlagaUrbana.enfermedadBacteriana,
    especiesObjetivo: ['almendro_ornamental'],
    sintomas: 'Brotes con aspecto quemado|encorvamiento en cayado|exudación bacteriana',
    ventanaAviso: 'Primavera-principios verano',
    manejoCultural: 'Poda sanitaria con desinfección de herramientas|destrucción del material podado por incineración',
    declaracionOficial: true,
    notas: 'DECLARACIÓN OBLIGATORIA. Regulado por RD 1201/1999 (programa nacional erradicación) y Reglamento UE 2019/2072 anexo II.',
  ),
  PlagaUrbana(
    id: 'psyla_acacia_constantinopla',
    nombreComun: 'Psyla de la acacia de Constantinopla',
    nombreCientifico: 'Acizzia jamatonica',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['acacia_constantinopla'],
    sintomas: 'Hojas pegajosas con melaza|amarilleo|negrilla secundaria',
    ventanaAviso: 'Verano',
    manejoCultural: 'Lavado de la copa con manguera|favorecer enemigos naturales',
    notas: 'Plaga frecuente en acacias de Constantinopla urbanas',
  ),
  PlagaUrbana(
    id: 'hongos_de_madera',
    nombreComun: 'Hongos de pudrición de madera',
    tipo: TipoPlagaUrbana.enfermedadFungica,
    sintomas: 'Cuerpos fructíferos en tronco o ramas (orejas|setas)|cavidades visibles|huecos en el tronco',
    ventanaAviso: 'Otoño tras lluvias',
    manejoCultural: 'Evaluación profesional VTA|consideración de poda saneamiento o tala según riesgo',
    notas: 'La presencia de cuerpos fructíferos siempre obliga a evaluación VTA por técnico cualificado',
  ),
  PlagaUrbana(
    id: 'salinidad_riego',
    nombreComun: 'Daño por salinidad',
    tipo: TipoPlagaUrbana.trastornoAbiotico,
    sintomas: 'Necrosis marginal en hoja|amarilleamiento|defoliación',
    ventanaAviso: 'Verano',
    manejoCultural: 'Lavado del bulbo radicular con riego abundante|sustitución de sustrato si es severo',
    notas: 'Frecuente en alcorques con sales acumuladas o cerca del mar',
  ),
  PlagaUrbana(
    id: 'heridas_sega',
    nombreComun: 'Heridas de máquina de siega',
    tipo: TipoPlagaUrbana.trastornoAbiotico,
    sintomas: 'Cortezas dañadas en la base del tronco|pérdida de cambium en zona afectada',
    ventanaAviso: 'Todo el año',
    manejoCultural: 'Protección con tutores de plástico o arena en el alcorque|formación del personal de jardinería',
    notas: 'Vía de entrada para hongos de pudrición — origen frecuente del declive del árbol',
  ),
  PlagaUrbana(
    id: 'golpe_calor_urbano',
    nombreComun: 'Golpe de calor urbano',
    tipo: TipoPlagaUrbana.trastornoAbiotico,
    sintomas: 'Quemaduras en hojas (especialmente expuestas al sur)|defoliación parcial',
    ventanaAviso: 'Verano',
    manejoCultural: 'Riego suplementario en olas de calor|sombreado temporal en árboles jóvenes',
    notas: 'Más grave en árboles plantados en alcorques sellados por asfalto',
  ),
  PlagaUrbana(
    id: 'fitotoxicidad_herbicida',
    nombreComun: 'Fitotoxicidad por herbicida',
    tipo: TipoPlagaUrbana.trastornoAbiotico,
    sintomas: 'Deformaciones foliares|encarrujamiento|amarilleo en mancha',
    ventanaAviso: 'Primavera-verano',
    manejoCultural: 'Mejor manejo de tratamientos en parterres y alcorques|formación de cuadrillas',
    notas: 'Frecuente cuando se aplican herbicidas en parterres adyacentes con deriva',
  ),
  PlagaUrbana(
    id: 'contaminacion_atmosferica',
    nombreComun: 'Daño por contaminación atmosférica',
    tipo: TipoPlagaUrbana.trastornoAbiotico,
    sintomas: 'Defoliación prematura|hojas pequeñas|crecimiento ralentizado',
    ventanaAviso: 'Verano (cumulativo)',
    manejoCultural: 'Riego abundante para lavar deposiciones|sustitución por especies tolerantes a contaminación (ginkgo|melojo)',
    notas: 'Más visible en alineaciones de alta densidad de tráfico',
  ),
  PlagaUrbana(
    id: 'xylella_arbolado',
    nombreComun: 'Xylella en arbolado ornamental',
    nombreCientifico: 'Xylella fastidiosa',
    tipo: TipoPlagaUrbana.enfermedadBacteriana,
    especiesObjetivo: ['olivo_ornamental', 'almendro_ornamental'],
    sintomas: 'Hojas con quemaduras marginales avanzando hacia el centro|ramas secas|decaimiento progresivo del árbol',
    ventanaAviso: 'Vector chinche escupidor (Philaenus spumarius). Detecciones en olivar Mallorca y Alicante.',
    manejoCultural: 'Erradicación de árboles sintomáticos y zona tampón|control vector con cubierta vegetal manejada|NO existe tratamiento curativo',
    declaracionOficial: true,
    notas: 'Plaga cuarentenaria UE. Aplicable a olivo ornamental y otros hospedantes urbanos.',
  ),
  PlagaUrbana(
    id: 'avispilla_castano',
    nombreComun: 'Avispilla del castaño',
    nombreCientifico: 'Dryocosmus kuriphilus',
    tipo: TipoPlagaUrbana.plagaInsecto,
    especiesObjetivo: ['castaño_indio', 'castaño_dulce'],
    sintomas: 'Agallas verdes y rojizas en hojas y brotes nuevos|crecimiento detenido|fructificación reducida|defoliación parcial',
    ventanaAviso: 'Primavera (eclosión)|verano (agallas visibles)',
    manejoCultural: 'Suelta de Torymus sinensis (parasitoide específico)|poda y destrucción de agallas|vigilancia de planta nueva importada',
    declaracionOficial: true,
    notas: 'Plaga cuarentenaria UE. Castaños ornamentales urbanos también afectados.',
  ),
];

PlagaUrbana? plagaUrbanaPorId(String id) {
  for (final p in catalogoPlagasUrbanas) {
    if (p.id == id) return p;
  }
  return null;
}

/// Plagas que afectan a una especie concreta. Útil para sugerir actuaciones
/// preventivas según el censo del ayuntamiento.
List<PlagaUrbana> plagasParaEspecie(String idEspecie) {
  return catalogoPlagasUrbanas
      .where((p) => p.especiesObjetivo.contains(idEspecie))
      .toList();
}

/// Plagas de declaración obligatoria — la app las destaca visualmente.
List<PlagaUrbana> patologiasDeclaracionObligatoria() {
  return catalogoPlagasUrbanas.where((p) => p.declaracionOficial).toList();
}

/// Plagas con riesgo sanitario público (procesionaria, lagarta peluda).
List<PlagaUrbana> plagasConRiesgoSanitarioPublico() {
  return catalogoPlagasUrbanas.where((p) => p.riesgoSanitarioPublico).toList();
}

/// Búsqueda fuzzy con fallback cruzado entre nombre común y científico.
PlagaUrbana? plagaUrbanaPorBusquedaFuzzy(String nombreComun, String nombreCientifico) {
  final consultaComun = _normalizar(nombreComun);
  final consultaCient = _normalizar(nombreCientifico);
  if (consultaComun.isEmpty && consultaCient.isEmpty) return null;
  for (final p in catalogoPlagasUrbanas) {
    if (consultaCient.isNotEmpty && p.nombreCientifico.isNotEmpty &&
        _normalizar(p.nombreCientifico).contains(consultaCient)) {
      return p;
    }
    if (consultaComun.isNotEmpty && _normalizar(p.nombreComun).contains(consultaComun)) {
      return p;
    }
  }
  for (final p in catalogoPlagasUrbanas) {
    if (consultaComun.isNotEmpty && p.nombreCientifico.isNotEmpty &&
        _normalizar(p.nombreCientifico).contains(consultaComun)) {
      return p;
    }
    if (consultaCient.isNotEmpty &&
        _normalizar(p.nombreComun).contains(consultaCient)) {
      return p;
    }
  }
  return null;
}

List<PlagaUrbana> buscarPlagasUrbanas(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoPlagasUrbanas.where((p) {
    return _normalizar(p.nombreComun).contains(consultaNormalizada) ||
        _normalizar(p.nombreCientifico).contains(consultaNormalizada) ||
        _normalizar(p.id).contains(consultaNormalizada);
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

