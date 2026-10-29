/// Catálogo semilla v1 de **productos fitosanitarios** o de manejo
/// reconocidos en el registro español del MAPA (BBDD de productos
/// fitosanitarios autorizados — https://www.mapa.gob.es).
///
/// **Hard limits explícitos:**
///
/// 1. **Es semilla curada, no exhaustiva.** Cubre productos
///    extendidos en agricultura ecológica/integrada de los cultivos
///    prioritarios de Larrea (frutales, olivar, vid, pistacho,
///    truficultura, dehesa). El registro oficial tiene **miles** de
///    productos comerciales — cada principio activo se vende bajo
///    decenas de marcas con sus propios números de registro.
///
/// 2. **Los `numeroRegistroEjemplo` son representativos del rango,
///    no del producto comercial concreto.** El agricultor debe
///    verificar el número de registro vigente del envase que está
///    usando antes de archivarlo en el Cuaderno de Explotación.
///
/// 3. **Pendiente de validación agronómica antes de publicación
///    pública.** Esta lista es punto de partida para que el formulario
///    de tratamiento autocomplete con productos típicos. Cualquier
///    expansión requiere consulta al hermano truficultor + agrónomo.
///
/// 4. **Sólo productos de bajo riesgo o ecológicos en v1.** Coherente
///    con el hard limit de Larrea de no recomendar productos
///    convencionales sin validación + BBDD MAPA viva (F4 backend).
class ProductoFitosanitario {
  final String id;
  final String nombreComercialEjemplo;
  final String materiaActiva;
  final String numeroRegistroEjemplo;
  final TipoFitosanitario tipo;
  final List<String> cultivosAutorizadosIds;
  final List<String> plagasAutorizadasIds;
  final String dosisRecomendada;
  final int plazoSeguridadDias;
  final bool ecologico;
  final String observaciones;

  const ProductoFitosanitario({
    required this.id,
    required this.nombreComercialEjemplo,
    required this.materiaActiva,
    required this.numeroRegistroEjemplo,
    required this.tipo,
    required this.cultivosAutorizadosIds,
    this.plagasAutorizadasIds = const [],
    this.dosisRecomendada = '',
    this.plazoSeguridadDias = 0,
    this.ecologico = false,
    this.observaciones = '',
  });

  /// Texto de búsqueda combinado: el agricultor a veces conoce el
  /// producto por nombre comercial, otras veces por materia activa.
  String get textoBusqueda =>
      '$nombreComercialEjemplo $materiaActiva $numeroRegistroEjemplo'.toLowerCase();

  bool autorizadoParaCultivo(String cultivoId) =>
      cultivosAutorizadosIds.contains(cultivoId) ||
      cultivosAutorizadosIds.contains('todos');
}

enum TipoFitosanitario {
  fungicida('Fungicida'),
  insecticida('Insecticida'),
  acaricida('Acaricida'),
  herbicida('Herbicida'),
  feromona('Feromona / atrayente'),
  bioestimulante('Bioestimulante / nutricional'),
  multiple('Múltiple');

  final String etiqueta;
  const TipoFitosanitario(this.etiqueta);
}

/// Lista semilla curada. Todos son productos ecológicos o de bajo
/// impacto autorizados de forma extendida en España. Para el campo
/// `cultivosAutorizadosIds` cruza con los ids de `catalogo_cultivos`.
const List<ProductoFitosanitario> catalogoFitosanitarios = [
  ProductoFitosanitario(
    id: 'caldo_bordeles',
    nombreComercialEjemplo: 'Caldo Bordelés',
    materiaActiva: 'Sulfato de cobre + cal',
    numeroRegistroEjemplo: '20XXX (verificar marca)',
    tipo: TipoFitosanitario.fungicida,
    cultivosAutorizadosIds: ['todos'],
    plagasAutorizadasIds: ['mildiu_vid', 'repilo_olivo', 'roya'],
    dosisRecomendada: '0,5–1 % sobre 1000 L/ha (ajustar por cultivo)',
    plazoSeguridadDias: 14,
    ecologico: true,
    observaciones: 'Fungicida polivalente histórico. Autorizado en producción ecológica con límite anual de cobre metal.',
  ),
  ProductoFitosanitario(
    id: 'hidroxido_cobre',
    nombreComercialEjemplo: 'Hidróxido cúprico',
    materiaActiva: 'Hidróxido de cobre',
    numeroRegistroEjemplo: '23XXX (verificar marca)',
    tipo: TipoFitosanitario.fungicida,
    cultivosAutorizadosIds: ['todos'],
    plagasAutorizadasIds: ['repilo_olivo', 'mildiu_vid'],
    dosisRecomendada: '1,5–4 kg/ha',
    plazoSeguridadDias: 14,
    ecologico: true,
    observaciones: 'Forma comercial alternativa al caldo bordelés con menor riesgo de fitotoxicidad.',
  ),
  ProductoFitosanitario(
    id: 'azufre_micronizado',
    nombreComercialEjemplo: 'Azufre micronizado',
    materiaActiva: 'Azufre',
    numeroRegistroEjemplo: '17XXX (verificar marca)',
    tipo: TipoFitosanitario.fungicida,
    cultivosAutorizadosIds: ['todos'],
    plagasAutorizadasIds: ['oidio_vid', 'oidio_frutales'],
    dosisRecomendada: '300–800 g/100 L (espolvoreo o mojable)',
    plazoSeguridadDias: 5,
    ecologico: true,
    observaciones: 'Polvo o pulverización contra oidios. Evitar aplicar con temperaturas > 30 °C.',
  ),
  ProductoFitosanitario(
    id: 'aceite_parafinico',
    nombreComercialEjemplo: 'Aceite mineral / parafínico',
    numeroRegistroEjemplo: '21XXX (verificar marca)',
    materiaActiva: 'Aceite mineral parafínico',
    tipo: TipoFitosanitario.insecticida,
    cultivosAutorizadosIds: ['olivo', 'almendro', 'manzano', 'peral', 'cerezo', 'limonero', 'naranjo'],
    plagasAutorizadasIds: ['cochinilla_olivo', 'cochinilla_caparreta', 'huevos_pulgon'],
    dosisRecomendada: '1,5–2 % en aplicación de invierno',
    plazoSeguridadDias: 0,
    ecologico: true,
    observaciones: 'Tratamiento de invierno por asfixia para huevos y formas invernantes.',
  ),
  ProductoFitosanitario(
    id: 'bacillus_thuringiensis',
    nombreComercialEjemplo: 'Bacillus thuringiensis kurstaki',
    materiaActiva: 'Bacillus thuringiensis var. kurstaki',
    numeroRegistroEjemplo: '24XXX (verificar marca)',
    tipo: TipoFitosanitario.insecticida,
    cultivosAutorizadosIds: ['olivo', 'manzano', 'peral', 'almendro', 'vid', 'cerezo', 'castano', 'encina', 'roble'],
    plagasAutorizadasIds: ['polilla_olivo', 'carpocapsa', 'lobesia', 'tortrix'],
    dosisRecomendada: '0,5–1 kg/ha según concentración',
    plazoSeguridadDias: 0,
    ecologico: true,
    observaciones: 'Bioinsecticida específico para larvas de lepidópteros. Aplicar al atardecer.',
  ),
  ProductoFitosanitario(
    id: 'spinosad',
    nombreComercialEjemplo: 'Spinosad',
    materiaActiva: 'Spinosad',
    numeroRegistroEjemplo: '25XXX (verificar marca)',
    tipo: TipoFitosanitario.insecticida,
    cultivosAutorizadosIds: ['olivo', 'manzano', 'peral', 'cerezo', 'almendro', 'limonero', 'naranjo'],
    plagasAutorizadasIds: ['mosca_olivo', 'mosca_fruta', 'carpocapsa'],
    dosisRecomendada: 'Cebo 1–2 L/ha (mosca olivo, parcheo)',
    plazoSeguridadDias: 7,
    ecologico: true,
    observaciones: 'Origen biológico (Saccharopolyspora spinosa). Tóxico para abejas — aplicar fuera de floración.',
  ),
  ProductoFitosanitario(
    id: 'jabon_potasico',
    nombreComercialEjemplo: 'Jabón potásico',
    materiaActiva: 'Sales potásicas de ácidos grasos',
    numeroRegistroEjemplo: '26XXX (verificar marca)',
    tipo: TipoFitosanitario.insecticida,
    cultivosAutorizadosIds: ['todos'],
    plagasAutorizadasIds: ['pulgon', 'mosca_blanca', 'cochinilla_blanda'],
    dosisRecomendada: '1,5–2 % en pulverización',
    plazoSeguridadDias: 0,
    ecologico: true,
    observaciones: 'Por contacto. Repetir cada 7–10 días si hay rebrote de la plaga.',
  ),
  ProductoFitosanitario(
    id: 'azadiractina_neem',
    nombreComercialEjemplo: 'Azadiractina (aceite de neem)',
    materiaActiva: 'Azadiractina',
    numeroRegistroEjemplo: '27XXX (verificar marca)',
    tipo: TipoFitosanitario.insecticida,
    cultivosAutorizadosIds: ['olivo', 'almendro', 'manzano', 'peral', 'cerezo', 'pistacho'],
    plagasAutorizadasIds: ['mosca_olivo', 'pulgon', 'trips'],
    dosisRecomendada: '0,2–0,3 % en pulverización',
    plazoSeguridadDias: 3,
    ecologico: true,
    observaciones: 'Regulador de crecimiento de origen natural. Eficaz en estadios larvarios tempranos.',
  ),
  ProductoFitosanitario(
    id: 'polisulfuro_calcio',
    nombreComercialEjemplo: 'Polisulfuro de calcio',
    materiaActiva: 'Polisulfuro cálcico',
    numeroRegistroEjemplo: '18XXX (verificar marca)',
    tipo: TipoFitosanitario.fungicida,
    cultivosAutorizadosIds: ['manzano', 'peral', 'cerezo', 'almendro', 'olivo'],
    plagasAutorizadasIds: ['oidio_frutales', 'moteado_manzano', 'roya'],
    dosisRecomendada: '2–4 L/ha en invernal, 1–2 L en vegetación',
    plazoSeguridadDias: 7,
    ecologico: true,
    observaciones: 'Caldo invernal histórico. Tiene también acción acaricida sobre formas hibernantes.',
  ),
  ProductoFitosanitario(
    id: 'feromona_lobesia',
    nombreComercialEjemplo: 'Difusores de feromona Lobesia (vid)',
    materiaActiva: 'Acetato de E,Z-7,9-dodecadienilo',
    numeroRegistroEjemplo: '28XXX (verificar marca)',
    tipo: TipoFitosanitario.feromona,
    cultivosAutorizadosIds: ['vid'],
    plagasAutorizadasIds: ['lobesia'],
    dosisRecomendada: '500 difusores/ha (confusión sexual)',
    plazoSeguridadDias: 0,
    ecologico: true,
    observaciones: 'Confusión sexual: parcela mínima recomendada 3 ha contiguas para eficacia.',
  ),
  ProductoFitosanitario(
    id: 'feromona_olivo',
    nombreComercialEjemplo: 'Difusores de feromona Prays oleae',
    materiaActiva: '(Z)-7-tetradecenal',
    numeroRegistroEjemplo: '28YYY (verificar marca)',
    tipo: TipoFitosanitario.feromona,
    cultivosAutorizadosIds: ['olivo'],
    plagasAutorizadasIds: ['polilla_olivo'],
    dosisRecomendada: '500 difusores/ha',
    plazoSeguridadDias: 0,
    ecologico: true,
    observaciones: 'Para confusión sexual de polilla del olivo. Combinable con Bacillus thuringiensis.',
  ),
];

/// Búsqueda flexible por texto (nombre comercial, materia activa o
/// fragmento de registro). Devuelve hasta `limite` resultados que
/// contengan el texto (case-insensitive). Si `cultivoId` viene
/// informado, prioriza los que están autorizados para ese cultivo.
List<ProductoFitosanitario> buscarFitosanitarios({
  required String texto,
  String? cultivoId,
  int limite = 8,
}) {
  final consulta = texto.trim().toLowerCase();
  if (consulta.isEmpty) return const [];
  final coincidencias = catalogoFitosanitarios
      .where((p) => p.textoBusqueda.contains(consulta))
      .toList();
  if (cultivoId != null) {
    coincidencias.sort((a, b) {
      final autA = a.autorizadoParaCultivo(cultivoId) ? 0 : 1;
      final autB = b.autorizadoParaCultivo(cultivoId) ? 0 : 1;
      return autA.compareTo(autB);
    });
  }
  return coincidencias.take(limite).toList();
}

ProductoFitosanitario? fitosanitarioPorRegistro(String registro) {
  final norm = registro.trim().toLowerCase();
  if (norm.isEmpty) return null;
  for (final p in catalogoFitosanitarios) {
    if (p.numeroRegistroEjemplo.toLowerCase() == norm) return p;
  }
  return null;
}
