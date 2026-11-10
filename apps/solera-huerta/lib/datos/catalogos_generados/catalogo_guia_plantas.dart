// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/guia_plantas.csv
// Generado: 2026-11-10
// Filas: 15 (0 firmadas por persona, 15 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class FichaGuiaPlanta {
  const FichaGuiaPlanta({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.queAporta,
    required this.cuandoSembrar,
    required this.cuidado,
    required this.fauna,
    required this.plagas,
    required this.cultivoId,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final String queAporta;
  final String cuandoSembrar;
  final String cuidado;
  final List<String> fauna;
  final List<String> plagas;
  final String cultivoId;
  final String fuente;
  final String revisadoPor;
}

const List<FichaGuiaPlanta> catalogoGuiaPlantas = [
  FichaGuiaPlanta(
      id: 'calendula',
      nombre: 'Caléndula',
      nombreCientifico: 'Calendula officinalis',
      tipo: 'flor_auxiliares',
      queAporta:
          'Según la guía de Madrid, atrae mariquitas, crisopas, chinches depredadoras, abejas y sírfidos.',
      cuandoSembrar:
          'Anual. Es de las flores de las que se recoge semilla con facilidad para el año siguiente.',
      cuidado:
          'Lo de que «repele nematodos» o «vigoriza» coles y tomates es tradición sin ensayo citado.',
      fauna: ['mariquitas', 'crisopas', 'orius', 'abejas', 'sirfidos'],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 9 del PDF; RHS School Gardening, «Tips on saving your own seeds», https://www.rhs.org.uk/education-learning/school-gardening/resources/planet-friendly/tips-on-saving-your-own-seeds',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'facelia',
      nombre: 'Facelia',
      nombreCientifico: 'Phacelia tanacetifolia',
      tipo: 'flor_auxiliares',
      queAporta:
          'Muy melífera: atrae fauna beneficiosa. Además hace de abono verde: mucha masa y raíces profundas que dejan el suelo más esponjoso.',
      cuandoSembrar:
          'En septiembre se puede intercalar una línea entre dos de repollo (guía de Madrid).',
      cuidado: '',
      fauna: ['abejas', 'sirfidos'],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 6 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'lobularia',
      nombre: 'Aliso marítimo',
      nombreCientifico: 'Lobularia maritima',
      tipo: 'flor_auxiliares',
      queAporta:
          'Florece casi sin parar y da alimento a la fauna auxiliar: la guía GIP de solanáceas lo propone para Necremnus tutae, parasitoide de la polilla del tomate. Intercalado en lechuga ecológica atrajo sírfidos que comen pulgón (USDA-ARS).',
      cuandoSembrar: '',
      cuidado:
          'Intercalado compite algo con la lechuga: en los ensayos salió algo más pequeña.',
      fauna: ['sirfidos'],
      plagas: ['pulgones', 'tuta_absoluta'],
      cultivoId: '',
      fuente:
          'MAPA, Guía GIP de solanáceas, 2021, p. 122 del PDF; USDA-ARS, «Flower Power Protects Organic Lettuce», Agricultural Research, enero 2014 (ensayos de E. B. Brennan, Biological Control 65, 2013)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'borraja_flor',
      nombre: 'Borraja en flor',
      nombreCientifico: 'Borago officinalis',
      tipo: 'flor_auxiliares',
      queAporta:
          'Atrae a polinizadores y a fauna depredadora de plagas (guía de Madrid).',
      cuandoSembrar: 'Como el cultivo: ver su ficha.',
      cuidado:
          'Lo de que repele nematodos o refuerza a las plantas vecinas es tradición sin ensayo citado.',
      fauna: ['abejas'],
      plagas: [],
      cultivoId: 'borraja',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 9 del PDF; Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'hinojo',
      nombre: 'Hinojo',
      nombreCientifico: 'Foeniculum vulgare',
      tipo: 'flor_auxiliares',
      queAporta:
          'Planta huésped de fauna auxiliar: mariquitas, arañas, taquínidos (moscas parásitas), avispas cazadoras y sírfidos.',
      cuandoSembrar: '',
      cuidado:
          'Ponlo aparte, a 1 m de las hortalizas: la guía de Madrid le atribuye efecto alelopático (frena a sus vecinas).',
      fauna: ['mariquitas', 'aranas', 'sirfidos'],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 9-10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'milenrama',
      nombre: 'Milenrama',
      nombreCientifico: 'Achillea millefolium',
      tipo: 'flor_auxiliares',
      queAporta:
          'Huésped de sírfidos, crisopas, mariquitas y avispillas parásitas del pulgón, la cochinilla y la mosca blanca.',
      cuandoSembrar: '',
      cuidado: '',
      fauna: [
        'sirfidos',
        'crisopas',
        'mariquitas',
        'avispillas_pulgon',
        'parasitoides_mosca_blanca'
      ],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'cosmos',
      nombre: 'Cosmos',
      nombreCientifico: 'Cosmos bipinnatus',
      tipo: 'flor_auxiliares',
      queAporta:
          'Atrae polinizadores y depredadores que de adultos comen polen: crisopas, sírfidos y avispas.',
      cuandoSembrar: '',
      cuidado:
          'Que «despiste» a la mariposa de la col es tradición sin ensayo citado.',
      fauna: ['crisopas', 'sirfidos', 'abejas'],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'tagetes',
      nombre: 'Tagetes',
      nombreCientifico: 'Tagetes spp.',
      tipo: 'cobertura',
      queAporta:
          'Sembrado denso como cultivo de cobertura, algunas variedades reducen los nematodos de agallas por una sustancia de sus raíces. También atrae polinizadores.',
      cuandoSembrar:
          'Al menos dos meses antes de la hortaliza que se quiere proteger (Universidad de Florida).',
      cuidado:
          'El efecto descrito es como cobertura densa, no con unas plantas sueltas entre la hortaliza, y cambia mucho de una variedad a otra.',
      fauna: ['abejas'],
      plagas: ['nematodos_agallas'],
      cultivoId: '',
      fuente:
          'UF/IFAS (Universidad de Florida), EDIS ENY-056/NG045, «Marigolds (Tagetes spp.) for Nematode Management», https://edis.ifas.ufl.edu/publication/NG045; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'aromaticas',
      nombre: 'Aromáticas mediterráneas',
      nombreCientifico: 'romero, tomillo, lavanda, orégano',
      tipo: 'flor_auxiliares',
      queAporta:
          'Melíferas: atraen polinizadores. El romero alimenta con su polen y néctar y cobija arañas y avispas parasitoides.',
      cuandoSembrar: '',
      cuidado:
          'Lo de que «repelen» plagas concretas es tradición sin ensayo citado.',
      fauna: ['abejas', 'aranas'],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'trebol',
      nombre: 'Trébol',
      nombreCientifico: 'Trifolium spp.',
      tipo: 'abono_verde',
      queAporta:
          'Leguminosa: fija nitrógeno. Como cobertura entre coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas). Trébol blanco con centeno o cebada es una mezcla clásica de abono verde.',
      cuandoSembrar: 'Febrero-abril (manual de Madrid).',
      cuidado: 'Es una leguminosa, de la familia de habas y guisantes.',
      fauna: ['sirfidos'],
      plagas: ['pulgones'],
      cultivoId: '',
      fuente:
          'MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 5 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 25',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'veza',
      nombre: 'Veza',
      nombreCientifico: 'Vicia sativa',
      tipo: 'abono_verde',
      queAporta:
          'Leguminosa que fija nitrógeno. Mezcla habitual con avena, que le hace de tutor (60 % leguminosa y 40 % gramínea).',
      cuandoSembrar: 'Septiembre-octubre (manual de Madrid).',
      cuidado: 'Es una leguminosa, de la familia de habas y guisantes.',
      fauna: [],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 5 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 25',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'mostaza',
      nombre: 'Mostaza blanca',
      nombreCientifico: 'Sinapis alba',
      tipo: 'abono_verde',
      queAporta:
          'Abono verde de crecimiento rápido que da mucha masa incluso en suelos pobres; sus raíces largas sacan nutrientes de capas profundas. La guía de Madrid le atribuye además efecto contra nematodos y Verticillium al enterrarla.',
      cuandoSembrar: 'Como los abonos verdes: en otoño o de febrero a abril.',
      cuidado:
          'Es una crucífera, de la familia de las coles: tenlo en cuenta en la rotación.',
      fauna: [],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 5-6 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'cereales',
      nombre: 'Centeno, avena y cebada',
      nombreCientifico: 'Secale cereale, Avena sativa, Hordeum vulgare',
      tipo: 'abono_verde',
      queAporta:
          'Gramíneas que ablandan el terreno y se asocian bien con las leguminosas; la avena frena las hierbas adventicias, incluso como paja.',
      cuandoSembrar:
          'Centeno en septiembre-octubre; avena en febrero-abril (manual de Madrid).',
      cuidado: '',
      fauna: [],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 5 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 25',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'alfalfa',
      nombre: 'Alfalfa',
      nombreCientifico: 'Medicago sativa',
      tipo: 'abono_verde',
      queAporta:
          'Cubierta duradera: sus raíces airean el suelo en profundidad, fija nitrógeno y es melífera (atrae polinizadores y depredadores de plagas).',
      cuandoSembrar: 'Febrero-abril (manual de Madrid).',
      cuidado: '',
      fauna: ['abejas'],
      plagas: [],
      cultivoId: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 6 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 25',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaPlanta(
      id: 'reservorio',
      nombre: 'Plantas reservorio y setos',
      nombreCientifico:
          'cereales, cerraja (Sonchus oleraceus), ortigas; en setos, bledo, cenizo, cadillo',
      tipo: 'reservorio',
      queAporta:
          'Tienen pulgones propios que no atacan al cultivo y sirven para criar fauna auxiliar (guía GIP de solanáceas). En los setos, bledo, cenizo o cadillo favorecen a sírfidos, mariquitas y crisopas (guía GIP de brásicas).',
      cuandoSembrar: '',
      cuidado:
          'No todas las «malas hierbas» ayudan: otras son reservorio de plagas, y la guía GIP pide controlarlas dentro del cultivo.',
      fauna: ['avispillas_pulgon', 'sirfidos', 'mariquitas', 'crisopas'],
      plagas: ['pulgones'],
      cultivoId: '',
      fuente:
          'MAPA, Guía GIP de solanáceas, 2021, p. 30 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
];
