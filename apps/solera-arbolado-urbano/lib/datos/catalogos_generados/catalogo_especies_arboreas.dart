// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/arbolado-urbano/especies_arboreas.csv
// Generado: 2026-11-07
// Filas: 40 (0 revisadas, 40 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-arbolado-urbano && dart run tool/compilar_catalogos.dart

/// Familia botánica simplificada para arbolado urbano.
enum FamiliaEspecieArborea { caducifolio, perenneCaducifolio, perenne, palmacea, conifera }

/// Tolerancia del árbol a la poda — orientativo para programación de actuaciones.
enum ToleranciaPoda { alta, media, baja }

class EspecieArborea {
  final String id;
  final String nombreCanonico;
  final String nombreCientifico;
  final FamiliaEspecieArborea familia;
  final double alturaMaxMetros;
  final String usoUrbanoTipico;
  final ToleranciaPoda toleranciaPoda;
  final String notas;

  const EspecieArborea({
    required this.id,
    required this.nombreCanonico,
    required this.nombreCientifico,
    required this.familia,
    required this.alturaMaxMetros,
    this.usoUrbanoTipico = '',
    required this.toleranciaPoda,
    this.notas = '',
  });
}

const List<EspecieArborea> catalogoEspeciesArboreas = [
  EspecieArborea(
    id: 'platano_sombra',
    nombreCanonico: 'Plátano de sombra',
    nombreCientifico: 'Platanus × hispanica',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 30.0,
    usoUrbanoTipico: 'Alineación de paseos y avenidas anchas',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Especie urbana más frecuente en España. Susceptible a anthracnosis y oídio. Hoja grande y alérgena para algunas personas',
  ),
  EspecieArborea(
    id: 'tilo',
    nombreCanonico: 'Tilo común',
    nombreCientifico: 'Tilia platyphyllos',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Parque y avenida de orden alto',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Aroma floral en junio. Atrae abejas — vigilar piquera con apicultura urbana',
  ),
  EspecieArborea(
    id: 'fresno_comun',
    nombreCanonico: 'Fresno común',
    nombreCientifico: 'Fraxinus excelsior',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 30.0,
    usoUrbanoTipico: 'Parque y ribera urbana',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Hoja compuesta. Buen porte de copa',
  ),
  EspecieArborea(
    id: 'acer_negundo',
    nombreCanonico: 'Arce negundo',
    nombreCientifico: 'Acer negundo',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Plaza pequeña y alineación urbana',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Crecimiento rápido — requiere poda anual de mantenimiento',
  ),
  EspecieArborea(
    id: 'almendro_ornamental',
    nombreCanonico: 'Almendro ornamental',
    nombreCientifico: 'Prunus dulcis',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 8.0,
    usoUrbanoTipico: 'Plaza y parque pequeño',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración temprana de gran valor ornamental. Susceptible a chancro',
  ),
  EspecieArborea(
    id: 'pino_pinonero',
    nombreCanonico: 'Pino piñonero',
    nombreCientifico: 'Pinus pinea',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Parque y zona ajardinada amplia',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Riesgo procesionaria del pino. Copa parasol característica',
  ),
  EspecieArborea(
    id: 'pino_carrasco',
    nombreCanonico: 'Pino carrasco',
    nombreCientifico: 'Pinus halepensis',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Parque mediterráneo',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Riesgo procesionaria. Adaptado a clima seco',
  ),
  EspecieArborea(
    id: 'palmera_datilera',
    nombreCanonico: 'Palmera datilera',
    nombreCientifico: 'Phoenix dactylifera',
    familia: FamiliaEspecieArborea.palmacea,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Avenida y plaza monumental',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Vector picudo rojo — DECLARACIÓN OBLIGATORIA si se confirma plaga',
  ),
  EspecieArborea(
    id: 'palmera_canaria',
    nombreCanonico: 'Palmera canaria',
    nombreCientifico: 'Phoenix canariensis',
    familia: FamiliaEspecieArborea.palmacea,
    alturaMaxMetros: 18.0,
    usoUrbanoTipico: 'Avenida y plaza monumental',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Vector picudo rojo — DECLARACIÓN OBLIGATORIA si se confirma plaga. Más sensible que la datilera',
  ),
  EspecieArborea(
    id: 'naranjo_amargo',
    nombreCanonico: 'Naranjo amargo',
    nombreCientifico: 'Citrus aurantium',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 10.0,
    usoUrbanoTipico: 'Alineación cálida (Andalucía y Levante)',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Frutos no comestibles. Aroma del azahar característico de Sevilla',
  ),
  EspecieArborea(
    id: 'jacaranda',
    nombreCanonico: 'Jacarandá',
    nombreCientifico: 'Jacaranda mimosifolia',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Plaza y avenida ornamental',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración violeta espectacular en mayo-junio. Sensible a heladas tardías',
  ),
  EspecieArborea(
    id: 'robinia',
    nombreCanonico: 'Robinia / Falsa acacia',
    nombreCientifico: 'Robinia pseudoacacia',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Parque y alineación rústica',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Especie invasora en algunas zonas — vigilar regeneración',
  ),
  EspecieArborea(
    id: 'ciprés_mediterráneo',
    nombreCanonico: 'Ciprés mediterráneo',
    nombreCientifico: 'Cupressus sempervirens',
    familia: FamiliaEspecieArborea.conifera,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Cementerio y zona conmemorativa',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Forma columnar característica. Sensible al chancro del ciprés',
  ),
  EspecieArborea(
    id: 'encina',
    nombreCanonico: 'Encina',
    nombreCientifico: 'Quercus ilex',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Parque amplio y zona naturalizada',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Especie autóctona de gran valor ecológico. Crecimiento muy lento',
  ),
  EspecieArborea(
    id: 'melojo',
    nombreCanonico: 'Melojo / Roble rebollo',
    nombreCientifico: 'Quercus pyrenaica',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Parque amplio y zona naturalizada del norte ibérico',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Especie autóctona. Hoja persistente seca durante el invierno',
  ),
  EspecieArborea(
    id: 'olmo_siberiano',
    nombreCanonico: 'Olmo siberiano',
    nombreCientifico: 'Ulmus pumila',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 18.0,
    usoUrbanoTipico: 'Alineación urbana',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Resistente a grafiosis (al contrario que el olmo común). Crecimiento rápido',
  ),
  EspecieArborea(
    id: 'catalpa',
    nombreCanonico: 'Catalpa',
    nombreCientifico: 'Catalpa bignonioides',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Plaza y parque pequeño',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Hoja muy grande — sombra densa. Vainas largas tras floración',
  ),
  EspecieArborea(
    id: 'liquidambar',
    nombreCanonico: 'Liquidámbar',
    nombreCientifico: 'Liquidambar styraciflua',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Alineación urbana ornamental',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Otoñada espectacular en rojos y púrpuras',
  ),
  EspecieArborea(
    id: 'ginkgo',
    nombreCanonico: 'Ginkgo / Árbol del Cuarenta Escudos',
    nombreCientifico: 'Ginkgo biloba',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Alineación urbana ornamental',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Macho preferible — la hembra produce frutos malolientes. Resistencia muy alta a contaminación',
  ),
  EspecieArborea(
    id: 'fresno_de_flor',
    nombreCanonico: 'Fresno de flor / Fresno florido',
    nombreCientifico: 'Fraxinus ornus',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Alineación y plaza',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración blanca cremosa muy ornamental. Más pequeño que el fresno común',
  ),
  EspecieArborea(
    id: 'celtis_almez',
    nombreCanonico: 'Almez / Latonero',
    nombreCientifico: 'Celtis australis',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Alineación tradicional ibérica',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Especie clásica del paseo mediterráneo. Frutos comestibles',
  ),
  EspecieArborea(
    id: 'lagerstroemia',
    nombreCanonico: 'Júpiter / Crespón',
    nombreCientifico: 'Lagerstroemia indica',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 8.0,
    usoUrbanoTipico: 'Plaza y rotonda',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Floración estival prolongada (julio-septiembre). Tolera podas drásticas',
  ),
  EspecieArborea(
    id: 'sophora',
    nombreCanonico: 'Sófora del Japón',
    nombreCientifico: 'Styphnolobium japonicum',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Alineación urbana ornamental',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración blanca tardía (julio-agosto). Madera resistente',
  ),
  EspecieArborea(
    id: 'paulownia',
    nombreCanonico: 'Paulownia',
    nombreCientifico: 'Paulownia tomentosa',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Plaza y parque',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Crecimiento muy rápido. Floración violeta en mayo. Especie invasora — vigilar',
  ),
  EspecieArborea(
    id: 'celindo',
    nombreCanonico: 'Celindo / Pittósporo',
    nombreCientifico: 'Pittosporum tobira',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 5.0,
    usoUrbanoTipico: 'Seto formal y plaza pequeña',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Más arbusto-árbol pequeño que árbol urbano clásico. Tolera podas frecuentes',
  ),
  EspecieArborea(
    id: 'brachychiton',
    nombreCanonico: 'Braquiquito / Árbol botella',
    nombreCientifico: 'Brachychiton populneus',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Alineación cálida sur peninsular',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Hoja persistente de aspecto trémulo (como álamo). Tolera sequía',
  ),
  EspecieArborea(
    id: 'melia',
    nombreCanonico: 'Cinamomo',
    nombreCientifico: 'Melia azedarach',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Alineación cálida y plaza',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración lila aromática. Frutos tóxicos — vigilar paseos infantiles',
  ),
  EspecieArborea(
    id: 'laurel',
    nombreCanonico: 'Laurel',
    nombreCientifico: 'Laurus nobilis',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 10.0,
    usoUrbanoTipico: 'Plaza y alineación corta',
    toleranciaPoda: ToleranciaPoda.alta,
    notas: 'Hoja aromática perenne. Tolera podas formales (formas cónicas)',
  ),
  EspecieArborea(
    id: 'arce_japones',
    nombreCanonico: 'Arce palmado / Arce japonés',
    nombreCientifico: 'Acer palmatum',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 8.0,
    usoUrbanoTipico: 'Jardín ornamental y plaza pequeña',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Otoñada espectacular. Sensible a sol directo intenso',
  ),
  EspecieArborea(
    id: 'abedul',
    nombreCanonico: 'Abedul',
    nombreCientifico: 'Betula pendula',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Parque del norte ibérico',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Polen muy alérgeno. Corteza ornamental blanca',
  ),
  EspecieArborea(
    id: 'chopo_lombardo',
    nombreCanonico: 'Chopo lombardo',
    nombreCientifico: 'Populus nigra var italica',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 30.0,
    usoUrbanoTipico: 'Alineación de gran porte',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Crecimiento muy rápido. Raíces invasivas — vigilar cercanía a saneamiento',
  ),
  EspecieArborea(
    id: 'sauce_lloron',
    nombreCanonico: 'Sauce llorón',
    nombreCientifico: 'Salix babylonica',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 15.0,
    usoUrbanoTipico: 'Parque junto al agua',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Mejor cerca de cursos de agua. Sensible a sequía',
  ),
  EspecieArborea(
    id: 'laurel_indias',
    nombreCanonico: 'Laurel de Indias / Ficus',
    nombreCientifico: 'Ficus microcarpa',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Alineación cálida sur peninsular',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Raíces aéreas y subterráneas muy invasivas — vigilar pavimentación. Sensible a heladas',
  ),
  EspecieArborea(
    id: 'magnolio',
    nombreCanonico: 'Magnolio',
    nombreCientifico: 'Magnolia grandiflora',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 20.0,
    usoUrbanoTipico: 'Parque ornamental',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Hoja grande perenne. Floración blanca aromática espectacular',
  ),
  EspecieArborea(
    id: 'araucaria',
    nombreCanonico: 'Araucaria',
    nombreCientifico: 'Araucaria heterophylla',
    familia: FamiliaEspecieArborea.conifera,
    alturaMaxMetros: 30.0,
    usoUrbanoTipico: 'Parque histórico y zona costera',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Crecimiento lento. Característica del paisaje urbano de algunas ciudades costeras',
  ),
  EspecieArborea(
    id: 'cedro_himalaya',
    nombreCanonico: 'Cedro del Himalaya',
    nombreCientifico: 'Cedrus deodara',
    familia: FamiliaEspecieArborea.conifera,
    alturaMaxMetros: 30.0,
    usoUrbanoTipico: 'Parque amplio',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Porte espectacular. Crecimiento moderado',
  ),
  EspecieArborea(
    id: 'olmo_comun',
    nombreCanonico: 'Olmo común',
    nombreCientifico: 'Ulmus minor',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 25.0,
    usoUrbanoTipico: 'Alineación tradicional (en declive por grafiosis)',
    toleranciaPoda: ToleranciaPoda.baja,
    notas: 'Susceptible a grafiosis — vigilar muerte súbita. Sustituido frecuentemente por olmo siberiano',
  ),
  EspecieArborea(
    id: 'araguaney',
    nombreCanonico: 'Araguaney / Tipuana',
    nombreCientifico: 'Tipuana tipu',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 18.0,
    usoUrbanoTipico: 'Alineación sur peninsular',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración amarilla estival. Frutos en sámara',
  ),
  EspecieArborea(
    id: 'falso_pimiento',
    nombreCanonico: 'Falso pimiento',
    nombreCientifico: 'Schinus molle',
    familia: FamiliaEspecieArborea.perenne,
    alturaMaxMetros: 12.0,
    usoUrbanoTipico: 'Alineación cálida y parque',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Aspecto llorón. Tolera sequía. Frutos rojos pequeños',
  ),
  EspecieArborea(
    id: 'acacia_constantinopla',
    nombreCanonico: 'Acacia de Constantinopla / Albizia',
    nombreCientifico: 'Albizia julibrissin',
    familia: FamiliaEspecieArborea.caducifolio,
    alturaMaxMetros: 12.0,
    usoUrbanoTipico: 'Alineación y plaza ornamental',
    toleranciaPoda: ToleranciaPoda.media,
    notas: 'Floración rosada filiforme característica en julio',
  ),
];

EspecieArborea? especiePorId(String id) {
  for (final e in catalogoEspeciesArboreas) {
    if (e.id == id) return e;
  }
  return null;
}

/// Búsqueda fuzzy: id exacto > nombre canónico > nombre científico.
List<EspecieArborea> buscarEspecies(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoEspeciesArboreas.where((e) {
    if (e.id == consultaNormalizada) return true;
    if (_normalizar(e.nombreCanonico).contains(consultaNormalizada)) return true;
    if (_normalizar(e.nombreCientifico).contains(consultaNormalizada)) return true;
    return false;
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

