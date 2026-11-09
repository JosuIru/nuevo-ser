// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/aromaticas/guia_especies.csv
// Generado: 2026-11-09
// Filas: 27 (0 firmadas por persona, 0 con alguna revisión, 27 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-aromaticas && dart run tool/compilar_catalogos.dart

class FichaGuiaEspecie {
  const FichaGuiaEspecie({
    required this.id,
    required this.rasgos,
    required this.habitat,
    required this.tituloWikipedia,
    required this.revisadoPor,
  });

  final String id;
  final List<String> rasgos;
  final String habitat;
  final String tituloWikipedia;
  final String revisadoPor;
}

const List<FichaGuiaEspecie> catalogoGuia = [
  FichaGuiaEspecie(
      id: 'lavanda',
      rasgos: [
        'Mata de 30-60 cm, hojas estrechas, grisáceas y de borde enrollado',
        'Espiga corta y compacta en un tallo floral sin ramificar',
        'Flor violeta azulada, cáliz con una pequeña lengüeta en la punta',
        'Brácteas de la espiga anchas, en forma de rombo'
      ],
      habitat:
          'Montaña media y alta (por encima de 700-800 m), en suelos calizos secos y soleados; muy cultivada',
      tituloWikipedia: 'Lavandula angustifolia',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'lavandin',
      rasgos: [
        'Mata más grande y vigorosa que la lavanda (hasta 1 m)',
        'Tallos florales largos, a menudo con dos espigas laterales bajo la principal',
        'Espiga más larga y menos densa que la de la lavanda',
        'Es un híbrido estéril: solo se encuentra cultivado o escapado de cultivo'
      ],
      habitat:
          'Cultivo en secanos de altiplano y meseta; rara vez aparece de forma natural donde conviven lavanda y espliego',
      tituloWikipedia: 'Lavandula × intermedia',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'espliego',
      rasgos: [
        'Hojas más anchas que las de la lavanda, grisáceas y algo espatuladas',
        'Tallos florales largos y ramificados, con espigas laterales',
        'Brácteas estrechas, lineares (no anchas como en la lavanda)',
        'Olor más alcanforado que el de la lavanda'
      ],
      habitat:
          'Matorrales y claros de encinar y quejigar en suelos calizos, de baja a media montaña',
      tituloWikipedia: 'Lavandula latifolia',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'cantueso',
      rasgos: [
        'Espiga corta y gruesa coronada por un penacho de brácteas violetas grandes, como orejas',
        'Hojas estrechas y grises',
        'Florece en primavera, antes que las otras lavandas'
      ],
      habitat:
          'Jarales y matorrales sobre suelos ácidos (granitos, pizarras), en la mitad occidental y el sur de la Península',
      tituloWikipedia: 'Lavandula stoechas',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'romero',
      rasgos: [
        'Arbusto de hasta 1,5 m, siempre verde',
        'Hojas lineares, verde oscuro por el haz y blanquecinas por el envés, con el borde enrollado',
        'Flores azul pálido en las axilas de las hojas, casi todo el año',
        'Olor resinoso al frotar las hojas'
      ],
      habitat:
          'Matorral mediterráneo en suelos secos, sobre todo calizos, desde la costa a la media montaña',
      tituloWikipedia: 'Salvia rosmarinus',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'tomillo_comun',
      rasgos: [
        'Mata pequeña (10-30 cm), leñosa y muy ramificada',
        'Hojas diminutas con el borde enrollado y el envés blanco y peludo',
        'Flores blancas o rosadas en cabezuelas al final de las ramas',
        'Hay muchos tomillos parecidos: para la especie hay que mirar hojas y cáliz con lupa'
      ],
      habitat:
          'Matorrales secos y soleados sobre suelos calizos de la mitad oriental de la Península; muy cultivado',
      tituloWikipedia: 'Thymus vulgaris',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'tomillo_salsero',
      rasgos: [
        'Mata baja con tallos finos y erguidos',
        'Hojas lineares con pestañas (pelos largos) en la base',
        'Flores blanquecinas en verticilos separados a lo largo del tallo, no en cabezuela compacta'
      ],
      habitat:
          'Matorrales secos y claros de bosque, en suelos calizos y silíceos, en buena parte de la Península',
      tituloWikipedia: 'Thymus zygis',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'tomillo_blanco',
      rasgos: [
        'Mata de 20-50 cm, de aspecto grisáceo',
        'Inflorescencia en cabezuela redonda y blanquecina, muy peluda',
        'Brácteas anchas y blanquecinas que esconden las flores',
        'Olor más suave y alcanforado que el del tomillo común'
      ],
      habitat:
          'Matorrales y claros sobre suelos ácidos y arenosos del centro y el oeste peninsular',
      tituloWikipedia: 'Thymus mastichina',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'salvia',
      rasgos: [
        'Mata de 30-70 cm con tallos cuadrados',
        'Hojas ovaladas, gris verdosas, de superficie rugosa y aterciopelada',
        'Flores violetas grandes, con dos labios, en verticilos'
      ],
      habitat:
          'Sobre todo cultivada en huertos y jardines; es originaria del Mediterráneo oriental',
      tituloWikipedia: 'Salvia officinalis',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'salvia_espanola',
      rasgos: [
        'Mata baja de hojas más estrechas y alargadas que las de la salvia',
        'Hojas grises y algo peludas, menos rugosas que en la salvia',
        'Flores violeta azulado en verticilos separados'
      ],
      habitat:
          'Matorrales y claros de encinar en suelos calizos de montaña media del centro y el este',
      tituloWikipedia: 'Salvia lavandulifolia',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'salvia_esclarea',
      rasgos: [
        'Planta bienal alta (hasta 1 m), robusta y peluda',
        'Hojas basales muy grandes, ovaladas y rugosas',
        'Brácteas grandes, rosadas o lilas, que destacan más que las flores',
        'Olor intenso y algo pegajosa al tacto'
      ],
      habitat: 'Cultivada; escapada en bordes de caminos y terrenos removidos',
      tituloWikipedia: 'Salvia sclarea',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'oregano',
      rasgos: [
        'Herbácea vivaz de 30-60 cm, con tallos rojizos',
        'Hojas ovaladas, opuestas, algo peludas',
        'Flores pequeñas rosadas o blancas en ramilletes planos, con brácteas purpúreas'
      ],
      habitat:
          'Bordes de bosque, setos y claros, en suelos frescos, sobre todo en la mitad norte y en montaña',
      tituloWikipedia: 'Origanum vulgare',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'ajedrea',
      rasgos: [
        'Mata pequeña y leñosa de 20-40 cm',
        'Hojas estrechas, rígidas y puntiagudas, con puntitos glandulares',
        'Flores blancas o rosadas pequeñas en las axilas de las hojas, al final del verano'
      ],
      habitat:
          'Roquedos, pedregales y matorrales secos en suelos calizos de montaña',
      tituloWikipedia: 'Satureja montana',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'hisopo',
      rasgos: [
        'Mata de 30-60 cm con tallos erguidos',
        'Hojas lineares, verde oscuro',
        'Flores azul intenso en espigas alargadas por un solo lado del tallo'
      ],
      habitat:
          'Pedregales y laderas soleadas calizas de montaña; también cultivado',
      tituloWikipedia: 'Hyssopus officinalis',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'melisa',
      rasgos: [
        'Herbácea vivaz de 30-80 cm, tallos cuadrados',
        'Hojas ovaladas, dentadas, verde claro, parecidas a las de una ortiga sin pelos urticantes',
        'Olor a limón al frotar las hojas',
        'Flores pequeñas blancas en las axilas'
      ],
      habitat:
          'Cultivada; escapada en lugares frescos y sombríos, cerca de huertos y casas',
      tituloWikipedia: 'Melissa officinalis',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'menta_piperita',
      rasgos: [
        'Herbácea vivaz con tallos cuadrados, a menudo rojizos',
        'Hojas lanceoladas, dentadas, con un pequeño pecíolo',
        'Flores lilas en espigas terminales',
        'Es un híbrido: se multiplica por estolones y se encuentra cultivada'
      ],
      habitat: 'Cultivo en suelos frescos y húmedos; escapada junto a acequias',
      tituloWikipedia: 'Mentha × piperita',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'hierba_luisa',
      rasgos: [
        'Arbusto de 1-3 m',
        'Hojas lanceoladas, ásperas, en grupos de tres o cuatro en cada nudo',
        'Olor a limón intenso al frotar las hojas',
        'Flores diminutas blancas o lilas en panículas'
      ],
      habitat:
          'Cultivada en huertos y jardines; es de origen sudamericano y sensible a las heladas',
      tituloWikipedia: 'Aloysia citrodora',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'albahaca',
      rasgos: [
        'Herbácea anual de 20-60 cm',
        'Hojas ovaladas, brillantes, algo carnosas',
        'Flores blancas en espigas al final de los tallos',
        'Muere con la primera helada'
      ],
      habitat: 'Solo cultivada (huerto, maceta, invernadero)',
      tituloWikipedia: 'Ocimum basilicum',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'estragon',
      rasgos: [
        'Herbácea vivaz de hasta 1 m, sin olor fuerte a ajenjo',
        'Hojas lineares, enteras, verde brillante',
        'Flores diminutas amarillentas en cabezuelas colgantes'
      ],
      habitat:
          'Cultivado; la forma francesa casi no da semilla y se multiplica por división',
      tituloWikipedia: 'Artemisia dracunculus',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'hinojo',
      rasgos: [
        'Herbácea alta (1-2 m), tallo liso y verde azulado, sin manchas',
        'Hojas divididas en filamentos muy finos, como pelos',
        'Umbelas de flores amarillas',
        'Olor a anís al frotar cualquier parte: la cicuta tiene el tallo con manchas púrpuras y huele mal'
      ],
      habitat:
          'Bordes de caminos, cunetas y terrenos baldíos de clima suave, sobre todo cerca de la costa y en el sur',
      tituloWikipedia: 'Foeniculum vulgare',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'manzanilla',
      rasgos: [
        'Herbácea anual de 20-50 cm, de hojas muy divididas',
        'Capítulos con lígulas blancas y centro amarillo',
        'El centro del capítulo es cónico y está hueco por dentro (se ve al cortarlo); en las especies parecidas está lleno',
        'Olor dulce característico'
      ],
      habitat:
          'Campos de cultivo, barbechos y bordes de caminos; también cultivada',
      tituloWikipedia: 'Matricaria chamomilla',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'milenrama',
      rasgos: [
        'Herbácea vivaz de 20-60 cm',
        'Hojas muy divididas en segmentos finos, como plumas',
        'Flores pequeñas blancas o rosadas reunidas en corimbos planos'
      ],
      habitat:
          'Prados, pastos y bordes de caminos, sobre todo en la mitad norte y en montaña',
      tituloWikipedia: 'Achillea millefolium',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'hiperico',
      rasgos: [
        'Herbácea vivaz de 30-80 cm, con dos líneas salientes a lo largo del tallo',
        'Hojas pequeñas que, a contraluz, muestran muchos puntitos translúcidos',
        'Flores amarillas de cinco pétalos con puntos negros en el borde',
        'Al frotar las flores dejan un tinte rojizo'
      ],
      habitat:
          'Bordes de caminos, claros de bosque y prados secos, en casi toda la Península',
      tituloWikipedia: 'Hypericum perforatum',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'jara',
      rasgos: [
        'Arbusto de 1-2,5 m, pegajoso y con olor a resina',
        'Hojas lanceoladas, verde oscuro y brillantes por el haz, como barnizadas',
        'Flores blancas grandes (hasta 10 cm), a menudo con una mancha púrpura en la base de cada pétalo'
      ],
      habitat:
          'Jarales sobre suelos ácidos (pizarras, granitos) del centro, el oeste y el sur',
      tituloWikipedia: 'Cistus ladanifer',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'te_de_roca',
      rasgos: [
        'Mata pequeña y pegajosa de 10-30 cm',
        'Hojas estrechas y algo carnosas',
        'Cabezuelas pequeñas amarillas, sin lígulas'
      ],
      habitat:
          'Grietas de roquedos y paredes calizas, en montaña del este y el sur',
      tituloWikipedia: 'Chiliadenus glutinosus',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'genciana',
      rasgos: [
        'Herbácea grande (hasta 1,5 m) que tarda años en florecer',
        'Hojas grandes, ovaladas, con nervios paralelos muy marcados, OPUESTAS (de dos en dos)',
        'Flores amarillas en grupos en las axilas de las hojas superiores',
        'El vedegambre (Veratrum album), muy tóxico, tiene las hojas ALTERNAS y plegadas: no se distinguen bien sin flor'
      ],
      habitat:
          'Pastos y prados de alta montaña (Pirineo, Cordillera Cantábrica, Sistema Ibérico)',
      tituloWikipedia: 'Gentiana lutea',
      revisadoPor: ''),
  FichaGuiaEspecie(
      id: 'arnica',
      rasgos: [
        'Herbácea vivaz de 20-60 cm',
        'Roseta basal de hojas ovaladas, con pares de hojas opuestas en el tallo',
        'Capítulos amarillo anaranjado grandes, con lígulas algo desflecadas'
      ],
      habitat:
          'Pastos de montaña en suelos ácidos (Pirineo, Cordillera Cantábrica, montañas del noroeste)',
      tituloWikipedia: 'Arnica montana',
      revisadoPor: ''),
];
