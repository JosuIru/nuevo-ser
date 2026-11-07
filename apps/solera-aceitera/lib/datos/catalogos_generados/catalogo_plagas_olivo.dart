// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aceitera/plagas_olivo.csv
// Generado: 2026-11-07
// Filas: 25 (0 firmadas por persona, 25 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aceitera && dart run tool/compilar_catalogos.dart

/// Tipo de patología. Para el formulario de incidencia los
/// `abiotico` se mapean a `otro` (no hay distinción en BD).
enum TipoPatologiaOlivo { plaga, enfermedad, fisiologico, abiotico }

class PlagaOlivo {
  final String id;
  final String nombreComun;
  final String nombreCientifico;
  final TipoPatologiaOlivo tipo;
  final String sintomas;
  final String condicionesFavorables;
  final String manejoCultural;
  /// `true` para enfermedades reguladas de declaración obligatoria
  /// a Servicios Fitosanitarios CCAA (Xylella, Verticillium en
  /// algunas zonas). La app las destaca con banner rojo.
  final bool declaracionOficial;

  const PlagaOlivo({
    required this.id,
    required this.nombreComun,
    this.nombreCientifico = '',
    required this.tipo,
    this.sintomas = '',
    this.condicionesFavorables = '',
    this.manejoCultural = '',
    this.declaracionOficial = false,
  });
}

const List<PlagaOlivo> catalogoPlagasOlivo = [
  PlagaOlivo(
    id: 'mosca_olivo',
    nombreComun: 'Mosca del olivo',
    nombreCientifico: 'Bactrocera oleae',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Larvas en el interior de la aceituna; galerías y agujeros de salida.',
    condicionesFavorables: 'Veranos suaves y húmedos; aceitunas en envero-madurez.',
    manejoCultural: 'Monitoreo con mosqueros amarillos; trampeo masivo; adelantar recolección.',
  ),
  PlagaOlivo(
    id: 'prays_olivo',
    nombreComun: 'Polilla del olivo',
    nombreCientifico: 'Prays oleae',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Tres generaciones: filófaga (hoja); antófaga (flor); carpófaga (fruto).',
    condicionesFavorables: 'Primaveras templadas; floraciones tardías.',
    manejoCultural: 'Confusión sexual; control biológico (Chrysoperla); favorecer fauna auxiliar.',
  ),
  PlagaOlivo(
    id: 'repilo',
    nombreComun: 'Repilo',
    nombreCientifico: 'Spilocaea oleaginea',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Manchas circulares oscuras con halo amarillento en hojas y caída prematura.',
    condicionesFavorables: 'Otoños lluviosos; rocíos prolongados; alta densidad de copa.',
    manejoCultural: 'Aclareo de copa para airear; cosecha higiénica; cubiertas vegetales bajas.',
  ),
  PlagaOlivo(
    id: 'verticilosis',
    nombreComun: 'Verticilosis del olivo',
    nombreCientifico: 'Verticillium dahliae',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Marchitez de ramas enteras (apoplejía o defoliación lenta) sin recuperación.',
    condicionesFavorables: 'Suelos contaminados; rotación con algodón/solanáceas; encharcamiento.',
    manejoCultural: 'Variedades tolerantes; certificar plantón libre; eliminar restos vegetales contaminados.',
    declaracionOficial: true,
  ),
  PlagaOlivo(
    id: 'tuberculosis_olivo',
    nombreComun: 'Tuberculosis del olivo',
    nombreCientifico: 'Pseudomonas savastanoi',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Tumores leñosos en ramas y tronco que rompen la corteza.',
    condicionesFavorables: 'Lluvia y heladas que abren heridas; herramientas sin desinfectar.',
    manejoCultural: 'Podar en seco; desinfectar tijeras; eliminar madera afectada.',
  ),
  PlagaOlivo(
    id: 'xylella',
    nombreComun: 'Xylella (decaimiento rápido del olivo)',
    nombreCientifico: 'Xylella fastidiosa',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Decaimiento rápido y muerte progresiva del olivo; necrosis de ramas y secado de hojas.',
    condicionesFavorables: 'Vectores chupadores de savia (cercópidos); zonas costeras templadas.',
    manejoCultural: 'Prospección obligatoria; arranque y destrucción en zona delimitada; vigilancia fitosanitaria oficial.',
    declaracionOficial: true,
  ),
  PlagaOlivo(
    id: 'cochinilla_tizne',
    nombreComun: 'Cochinilla y negrilla',
    nombreCientifico: 'Saissetia oleae',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Cochinillas en hojas + capa negra de hongo saprófito (negrilla).',
    condicionesFavorables: 'Copas densas; humedad alta; ausencia de fauna auxiliar.',
    manejoCultural: 'Aclarar copa; favorecer hormigas y predadores naturales; lavado tras melaza intensa.',
  ),
  PlagaOlivo(
    id: 'glifodes',
    nombreComun: 'Glifodes / barreno del olivo',
    nombreCientifico: 'Palpita unionalis',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Larvas que devoran brotes tiernos y hojas en el extremo.',
    condicionesFavorables: 'Otoños cálidos; brotaciones tardías.',
    manejoCultural: 'Monitoreo con feromonas; control biológico; podas equilibradas.',
  ),
  PlagaOlivo(
    id: 'algodoncillo',
    nombreComun: 'Algodoncillo',
    nombreCientifico: 'Euphyllura olivina',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Masas algodonosas en inflorescencias; aborto floral si la población es alta.',
    condicionesFavorables: 'Primaveras secas; inflorescencias prolongadas.',
    manejoCultural: 'Aclareo de copa; control con auxiliares.',
  ),
  PlagaOlivo(
    id: 'taladrillo_olivo',
    nombreComun: 'Taladrillo del olivo',
    nombreCientifico: 'Phloeotribus scarabaeoides',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Galerías en ramillos; debilitamiento de árboles ya estresados.',
    condicionesFavorables: 'Madera de poda sin retirar; sequía prolongada.',
    manejoCultural: 'Quemar/retirar restos de poda en febrero-marzo (trampas naturales).',
  ),
  PlagaOlivo(
    id: 'antracnosis_olivo',
    nombreComun: 'Antracnosis (aceituna jabonosa)',
    nombreCientifico: 'Colletotrichum spp.',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Manchas oscuras blandas en aceitunas; aceite turbio con alta acidez.',
    condicionesFavorables: 'Aceitunas heridas; humedad en madurez; recolecciones tardías.',
    manejoCultural: 'Adelantar recolección de fruto afectado; separación en almazara; aclareo de copa.',
  ),
  PlagaOlivo(
    id: 'emplomado',
    nombreComun: 'Emplomado del olivo',
    nombreCientifico: 'Pseudocercospora cladosporioides',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Manchas plomizas grisáceas en envés de hojas; defoliación lenta.',
    condicionesFavorables: 'Veranos secos seguidos de otoños lluviosos.',
    manejoCultural: 'Aclareo de copa; cubiertas vegetales bajas; manejo similar al repilo.',
  ),
  PlagaOlivo(
    id: 'escudete',
    nombreComun: 'Escudete',
    nombreCientifico: 'Camarosporium dalmaticum',
    tipo: TipoPatologiaOlivo.enfermedad,
    sintomas: 'Manchas necróticas circulares en aceitunas tras lluvias estivales.',
    condicionesFavorables: 'Lluvias en verano-otoño con aceituna desarrollada.',
    manejoCultural: 'Cosecha higiénica; separación en báscula; variedades menos sensibles.',
  ),
  PlagaOlivo(
    id: 'mosquito_olivo',
    nombreComun: 'Mosquito del olivo',
    nombreCientifico: 'Dasineura oleae',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Agallas en hojas y brotes nuevos; deformación de la masa foliar.',
    condicionesFavorables: 'Brotaciones primaverales prolongadas.',
    manejoCultural: 'Control con fauna auxiliar; podas que renueven madera afectada.',
  ),
  PlagaOlivo(
    id: 'caracoles_olivar',
    nombreComun: 'Caracoles en olivar',
    nombreCientifico: 'Cernuella spp.',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Daños en hojas tiernas y partes bajas; obstaculizan la recolección manual.',
    condicionesFavorables: 'Otoños y primaveras húmedas; suelos con cubierta densa.',
    manejoCultural: 'Manejo de cubierta vegetal; siega antes de la subida; trampeo en cuadrillas.',
  ),
  PlagaOlivo(
    id: 'gusano_blanco',
    nombreComun: 'Gusano blanco / gallina ciega',
    nombreCientifico: 'Melolontha spp.',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Larvas que devoran raíces; debilitamiento general del olivo joven.',
    condicionesFavorables: 'Suelos arenosos; abundancia de materia orgánica fresca.',
    manejoCultural: 'Laboreo somero en marzo; control biológico con hongos entomopatógenos.',
  ),
  PlagaOlivo(
    id: 'helada_invernal',
    nombreComun: 'Helada invernal',
    tipo: TipoPatologiaOlivo.abiotico,
    sintomas: 'Necrosis de ramas finas; defoliación; en casos extremos muerte del árbol.',
    condicionesFavorables: 'Temperaturas <-7 °C en olivos no aclimatados.',
    manejoCultural: 'Variedades resistentes; vasos abiertos en zonas frías; podas posteriores a heladas.',
  ),
  PlagaOlivo(
    id: 'sequia_severa',
    nombreComun: 'Sequía severa',
    tipo: TipoPatologiaOlivo.abiotico,
    sintomas: 'Defoliación; aceitunas pequeñas o caída prematura; reducción de rendimiento graso.',
    condicionesFavorables: 'Veranos secos prolongados; suelos sin reserva de agua.',
    manejoCultural: 'Cubiertas vegetales muertas; goteo deficitario; podas de equilibrio.',
  ),
  PlagaOlivo(
    id: 'viento_levante_olivar',
    nombreComun: 'Viento de levante / poniente severo',
    tipo: TipoPatologiaOlivo.abiotico,
    sintomas: 'Caída de aceituna verde; daños mecánicos en ramillos; deshidratación.',
    condicionesFavorables: 'Vientos secos con rachas >60 km/h.',
    manejoCultural: 'Setos cortavientos; recolección anticipada en sectores expuestos.',
  ),
  PlagaOlivo(
    id: 'clorosis_ferrica',
    nombreComun: 'Clorosis férrica',
    tipo: TipoPatologiaOlivo.fisiologico,
    sintomas: 'Hojas jóvenes amarillentas con nervadura verde; reducción de vigor.',
    condicionesFavorables: 'Suelos calizos con pH alto; encharcamiento que limita la absorción de Fe.',
    manejoCultural: 'Quelatos de hierro al suelo; corrección de drenaje; abono foliar específico.',
  ),
  PlagaOlivo(
    id: 'defoliacion_otoñal',
    nombreComun: 'Defoliación otoñal mixta',
    tipo: TipoPatologiaOlivo.fisiologico,
    sintomas: 'Caída masiva de hoja vieja antes de la floración siguiente.',
    condicionesFavorables: 'Estrés hídrico/repilo previos; cargas de cosecha elevadas.',
    manejoCultural: 'Equilibrio entre carga y vigor; aclareo; manejo conjunto de repilo.',
  ),
  PlagaOlivo(
    id: 'ceratoceria',
    nombreComun: 'Cochinilla violeta',
    nombreCientifico: 'Parlatoria oleae',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Costras en ramas y aceitunas; depreciación de fruto de mesa.',
    condicionesFavorables: 'Olivares densos con copas no aireadas.',
    manejoCultural: 'Aclareo de copa; control con auxiliares; aceites de invierno autorizados.',
  ),
  PlagaOlivo(
    id: 'abigarrado_aceituna',
    nombreComun: 'Abigarrado / mancha estrellada',
    tipo: TipoPatologiaOlivo.fisiologico,
    sintomas: 'Manchas estrelladas claras en aceituna verde-envero; sin afectar al aceite.',
    condicionesFavorables: 'Cambios bruscos de temperatura tras lluvias en verano.',
    manejoCultural: 'Sin acción específica — incidencia estética.',
  ),
  PlagaOlivo(
    id: 'arañuela_amarilla',
    nombreComun: 'Arañuela del olivo',
    nombreCientifico: 'Tetranychus urticae',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Punteado clorótico en hojas y telilla fina en envés.',
    condicionesFavorables: 'Veranos secos y polvorientos; ausencia de fauna auxiliar.',
    manejoCultural: 'Riegos por aspersión puntuales que limpien follaje; control con depredadores.',
  ),
  PlagaOlivo(
    id: 'seca_de_brotes_xilebori',
    nombreComun: 'Seca de brotes por escolítidos',
    nombreCientifico: 'Xyleborus spp.',
    tipo: TipoPatologiaOlivo.plaga,
    sintomas: 'Galerías muy finas en ramillos; secado puntual de extremos.',
    condicionesFavorables: 'Olivos debilitados por estrés hídrico o heladas previas.',
    manejoCultural: 'Vigilancia tras estrés; retirada y quema de ramillos afectados.',
  ),
];

PlagaOlivo? plagaOlivoPorId(String id) {
  for (final p in catalogoPlagasOlivo) {
    if (p.id == id) return p;
  }
  return null;
}

/// Plagas de declaración obligatoria — la app las destaca con banner rojo.
List<PlagaOlivo> patologiasDeclaracionObligatoria() {
  return catalogoPlagasOlivo.where((p) => p.declaracionOficial).toList();
}

List<PlagaOlivo> buscarPlagasOlivo(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoPlagasOlivo.where((p) {
    return _normalizar(p.nombreComun).contains(q) ||
        _normalizar(p.nombreCientifico).contains(q) ||
        _normalizar(p.id).contains(q);
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

