// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/monte/plagas_forestales.csv
// Generado: 2026-11-07
// Filas: 19 (0 firmadas por persona, 19 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-monte && dart run tool/compilar_catalogos.dart

class PlagaForestal {
  const PlagaForestal({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.grupo,
    required this.generos,
    required this.especies,
    required this.organos,
    required this.sintomas,
    required this.aviso,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String grupo;
  final List<String> generos;
  final List<String> especies;
  final String organos;
  final String sintomas;
  final String aviso;
  final String revisadoPor;
}

const List<PlagaForestal> catalogoPlagas = [
  PlagaForestal(
      id: 'procesionaria_pino',
      nombre: 'Procesionaria del pino',
      nombreCientifico: 'Thaumetopoea pityocampa',
      grupo: 'defoliador',
      generos: ['pinus', 'cedrus'],
      especies: [],
      organos: 'Acículas',
      sintomas:
          'Bolsones de seda en la copa; las orugas comen las acículas de noche y, pasado el invierno, bajan en procesión a enterrarse',
      aviso: 'urticante',
      revisadoPor:
          'fuente_publica: ESMA 2025, p. 73 (orugas urticantes desde el tercer estadio)'),
  PlagaForestal(
      id: 'procesionaria_roble',
      nombre: 'Procesionaria del roble',
      nombreCientifico: 'Thaumetopoea processionea',
      grupo: 'defoliador',
      generos: ['quercus'],
      especies: [],
      organos: 'Hojas',
      sintomas:
          'Colonias de orugas gregarias y un bolsón fijo en el tronco de robles de hoja caduca; comen las hojas de noche',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 74'),
  PlagaForestal(
      id: 'lagarta_peluda',
      nombre: 'Lagarta peluda',
      nombreCientifico: 'Lymantria dispar',
      grupo: 'defoliador',
      generos: [
        'acer',
        'alnus',
        'arbutus',
        'betula',
        'castanea',
        'corylus',
        'fagus',
        'fraxinus',
        'pinus',
        'populus',
        'quercus',
        'salix',
        'ulmus'
      ],
      especies: [],
      organos: 'Hojas y yemas',
      sintomas:
          'Puestas en plastones sobre el tronco; las orugas comen yemas y hojas hasta defoliar el árbol; daños cíclicos',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 66'),
  PlagaForestal(
      id: 'lagarta_verde',
      nombre: 'Lagarta verde',
      nombreCientifico: 'Tortrix viridana',
      grupo: 'defoliador',
      generos: ['quercus'],
      especies: ['quercus_ilex'],
      organos: 'Brotes y hojas del año',
      sintomas:
          'Orugas dentro de las yemas y en refugios de hojas jóvenes unidas; daño en ventana; baja la producción de bellota',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 75'),
  PlagaForestal(
      id: 'gorgojo_eucalipto',
      nombre: 'Gorgojo del eucalipto',
      nombreCientifico: 'Gonipterus scutellatus',
      grupo: 'defoliador',
      generos: [],
      especies: ['eucalyptus_globulus', 'eucalyptus_nitens'],
      organos: 'Hojas, brotes apicales y yemas florales',
      sintomas:
          'Ootecas en las hojas nuevas; las larvas hacen daños lineales y los adultos comen la hoja entera; defoliaciones en la parte alta de la copa',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 65'),
  PlagaForestal(
      id: 'avispilla_castano',
      nombre: 'Avispilla del castaño',
      nombreCientifico: 'Dryocosmus kuriphilus',
      grupo: 'gallicola',
      generos: ['castanea'],
      especies: ['castanea_sativa'],
      organos: 'Yemas, brotes y amentos',
      sintomas:
          'Agallas en brotes, hojas y amentos; pérdida de vigor y de producción de castaña',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 82'),
  PlagaForestal(
      id: 'ips_acuminatus',
      nombre: 'Perforador Ips acuminatus',
      nombreCientifico: 'Ips acuminatus',
      grupo: 'perforador',
      generos: ['pinus'],
      especies: ['pinus_sylvestris'],
      organos: 'Ramas y tronco',
      sintomas:
          'Galerías bajo la corteza que anillan el fuste y matan el árbol; lo favorece la madera muerta fresca en el monte',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 96'),
  PlagaForestal(
      id: 'ips_sexdentatus',
      nombre: 'Perforador Ips sexdentatus',
      nombreCientifico: 'Ips sexdentatus',
      grupo: 'perforador',
      generos: ['pinus', 'abies', 'cedrus', 'larix', 'pseudotsuga'],
      especies: [],
      organos: 'Ramas y tronco',
      sintomas:
          'Galerías bajo la corteza que cortan la savia y matan el pie; lo favorecen la madera muerta fresca y los árboles débiles',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 97'),
  PlagaForestal(
      id: 'tomicus_piniperda',
      nombre: 'Perforador Tomicus piniperda',
      nombreCientifico: 'Tomicus piniperda',
      grupo: 'perforador',
      generos: ['pinus', 'abies', 'picea', 'larix'],
      especies: [],
      organos: 'Ramillos y tronco',
      sintomas:
          'Grumo de resina en el orificio de entrada; galería materna recta y vertical; los adultos nuevos secan los ramillos de la copa',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 102'),
  PlagaForestal(
      id: 'tomicus_minor',
      nombre: 'Perforador Tomicus minor',
      nombreCientifico: 'Tomicus minor',
      grupo: 'perforador',
      generos: ['pinus'],
      especies: ['pinus_sylvestris', 'pinus_nigra'],
      organos: 'Ramillos y tronco',
      sintomas:
          'Galería en forma de V abierta en el tronco; los adultos nuevos secan y tiran los ramillos terminales',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 101'),
  PlagaForestal(
      id: 'cerambyx',
      nombre: 'Cerambícidos (Cerambyx)',
      nombreCientifico: 'Cerambyx spp.',
      grupo: 'perforador',
      generos: ['quercus'],
      especies: [],
      organos: 'Ramas gruesas y tronco',
      sintomas:
          'Orificios de salida grandes, serrín acumulado y galerías en la albura; árboles debilitados que acaban rompiéndose',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 92'),
  PlagaForestal(
      id: 'coraebus_florentinus',
      nombre: 'Culebrilla de los Quercus',
      nombreCientifico: 'Coraebus florentinus',
      grupo: 'perforador',
      generos: [],
      especies: [
        'quercus_ilex',
        'quercus_suber',
        'quercus_faginea',
        'quercus_pyrenaica'
      ],
      organos: 'Ramas',
      sintomas:
          'Ramas medias anilladas que se secan: «fogonazos» pardo rojizos salpicados en la copa',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 93'),
  PlagaForestal(
      id: 'curculio_elephas',
      nombre: 'Balanino',
      nombreCientifico: 'Curculio elephas',
      grupo: 'carpofago',
      generos: ['quercus', 'castanea'],
      especies: [],
      organos: 'Frutos',
      sintomas:
          'Larva dentro de la bellota o la castaña; caída prematura y frutos más pequeños',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 94'),
  PlagaForestal(
      id: 'chancro_castano',
      nombre: 'Chancro del castaño',
      nombreCientifico: 'Cryphonectria parasitica',
      grupo: 'hongo',
      generos: ['castanea'],
      especies: ['castanea_sativa'],
      organos: 'Brotes, ramas y tronco',
      sintomas:
          'Cancros que anillan y matan brotes, ramas o el pie entero; las hojas de lo afectado toman un tono atabacado',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 30'),
  PlagaForestal(
      id: 'phytophthora_cinnamomi',
      nombre: 'Podredumbre radical (Phytophthora)',
      nombreCientifico: 'Phytophthora cinnamomi',
      grupo: 'oomiceto',
      generos: ['quercus', 'castanea'],
      especies: [],
      organos: 'Raíces',
      sintomas:
          'Pudrición de las raíces absorbentes con suelo encharcado; lesiones en la base del tallo y mancha ocre en el cuello; asociada a la seca',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 37'),
  PlagaForestal(
      id: 'banda_marron',
      nombre: 'Banda marrón del pino',
      nombreCientifico: 'Lecanosticta acicola',
      grupo: 'hongo',
      generos: ['pinus'],
      especies: ['pinus_radiata'],
      organos: 'Acículas',
      sintomas:
          'Pérdida prematura de acículas de todas las edades e intensas defoliaciones; con infecciones repetidas mueren los ramillos',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 35'),
  PlagaForestal(
      id: 'sphaeropsis_sapinea',
      nombre: 'Sphaeropsis del pino',
      nombreCientifico: 'Sphaeropsis sapinea',
      grupo: 'hongo',
      generos: ['pinus'],
      especies: [],
      organos: 'Acículas, brotes, piñas, ramas y tronco',
      sintomas:
          'Brotes apicales marchitos con acículas rojizas, madera azulada y resinosis; aparece sobre todo tras heridas (granizo)',
      aviso: '',
      revisadoPor: 'fuente_publica: ESMA 2025, p. 41'),
  PlagaForestal(
      id: 'nematodo_pino',
      nombre: 'Nematodo de la madera del pino',
      nombreCientifico: 'Bursaphelenchus xylophilus',
      grupo: 'nematodo',
      generos: ['pinus'],
      especies: [],
      organos: 'Madera',
      sintomas:
          'Plaga prioritaria de la Unión: ante pinos que se secan de golpe, avisar al servicio de sanidad forestal o vegetal de la comunidad autónoma',
      aviso: 'prioritaria_ue',
      revisadoPor:
          'revision-ia: Reglamento Delegado (UE) 2019/1702, anexo (EUR-Lex, leído el 2026-11-07)'),
  PlagaForestal(
      id: 'monochamus_galloprovincialis',
      nombre: 'Longicornio del pino',
      nombreCientifico: 'Monochamus galloprovincialis',
      grupo: 'perforador',
      generos: ['pinus'],
      especies: [],
      organos: 'Madera',
      sintomas: 'Vector del nematodo de la madera del pino',
      aviso: '',
      revisadoPor:
          'fuente_publica: CAIB Sanidad Forestal, ficha «Monochamus galloprovincialis, vector de propagación del nematodo de la madera del pino»'),
];
