// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/guia_cultivos.csv
// Generado: 2026-11-10
// Filas: 42 (0 firmadas por persona, 42 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class FichaGuiaCultivo {
  const FichaGuiaCultivo({
    required this.id,
    required this.calendario,
    required this.mesesSemillero,
    required this.mesesDirecta,
    required this.mesesTrasplante,
    required this.siembra,
    required this.riego,
    required this.cosecha,
    required this.asociacionesFavorables,
    required this.asociacionesDesfavorables,
    required this.notaAsociaciones,
    required this.plagas,
    required this.curiosidad,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String calendario;
  final List<String> mesesSemillero;
  final List<String> mesesDirecta;
  final List<String> mesesTrasplante;
  final String siembra;
  final String riego;
  final String cosecha;
  final List<String> asociacionesFavorables;
  final List<String> asociacionesDesfavorables;
  final String notaAsociaciones;
  final List<String> plagas;
  final String curiosidad;
  final String fuente;
  final String revisadoPor;
}

const List<FichaGuiaCultivo> catalogoGuiaCultivos = [
  FichaGuiaCultivo(
      id: 'tomate',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-4'],
      mesesDirecta: [],
      mesesTrasplante: ['4-6'],
      siembra:
          'Semillero protegido en febrero-abril y trasplante de abril a junio, cuando ya no hiela. Salvo los cherry, se poda dejando una sola guía que se entutora.',
      riego:
          'Regular: el riego irregular favorece la podredumbre apical. La guía de Madrid cuenta que alternar varios días sin riego con un riego abundante mejora el sabor.',
      cosecha:
          'A los 60-70 días del trasplante (algo menos los cherry); se recogen frutos durante 1-3 meses, hasta el frío.',
      asociacionesFavorables: [
        'Albahaca',
        'cebolla',
        'perejil',
        'apio',
        'judia_verde',
        'puerro',
        'Coles',
        'ajo',
        'lechuga',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['patata', 'pepino'],
      notaAsociaciones:
          'Mejor no juntar ni encadenar cultivos de la misma familia: comparten exigencias y plagas y enfermedades (principio de la guía de Madrid; la app avisa en la rotación). Con respaldo técnico: el aliso marítimo (Lobularia) en flor alimenta a Necremnus tutae, parasitoide de la polilla del tomate (guía GIP de solanáceas).',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'tuta_absoluta',
        'orugas_defoliadoras',
        'mildiu_tomate_patata',
        'alternaria_solanaceas',
        'oidiopsis',
        'podredumbre_apical',
        'nematodos_agallas'
      ],
      curiosidad:
          'Madura después de cosecharlo si ya ha «pintado» la punta de su color definitivo.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 39; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de solanáceas, 2021, p. 122 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'pimiento',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-4'],
      mesesDirecta: [],
      mesesTrasplante: ['4-6'],
      siembra:
          'Semillero protegido en febrero-abril y trasplante de abril a junio. Agradece tierra bien aireada, compost joven y un acolchado de paja; conviene quitar ramas y flores por debajo de la cruz.',
      riego:
          'Es la solanácea más exigente en riego, sobre todo desde la floración, y tiene que ser constante: si no, aparece la podredumbre apical.',
      cosecha:
          'Desde 50-60 días los de tipo padrón hasta 80-120 los que se cosechan en rojo.',
      asociacionesFavorables: [
        'ajo',
        'Albahaca',
        'berenjena',
        'Coles',
        'lechuga',
        'rabano',
        'tomate',
        'puerro'
      ],
      asociacionesDesfavorables: ['patata', 'pepino'],
      notaAsociaciones:
          'Mejor no juntar ni encadenar cultivos de la misma familia: comparten exigencias y plagas y enfermedades (principio de la guía de Madrid; la app avisa en la rotación).',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'trips',
        'orugas_defoliadoras',
        'oidiopsis',
        'podredumbre_apical'
      ],
      curiosidad:
          'Los de tipo padrón se empiezan a coger a los 50-60 días; los que se dejan madurar en rojo tardan 80-120.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'berenjena',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-4'],
      mesesDirecta: [],
      mesesTrasplante: ['4-5'],
      siembra:
          'Semillero protegido en febrero-abril y trasplante en abril-mayo, cuando ha pasado el frío: es exigente en calor. Le gustan los suelos muy fértiles; se puede acolchar con compost desde mayo.',
      riego: 'Sensible al encharcamiento; crece lenta al principio.',
      cosecha:
          'Unos 2 meses desde el trasplante. Se cogen cuando se ponen algo brillantes, antes de que cambien de color y formen semilla, porque amargan.',
      asociacionesFavorables: [
        'ajo',
        'borraja',
        'cebolla',
        'Coles',
        'escarola',
        'espinaca',
        'lechuga',
        'puerro'
      ],
      asociacionesDesfavorables: ['patata', 'pepino', 'pimiento', 'tomate'],
      notaAsociaciones:
          'Mejor no juntar ni encadenar cultivos de la misma familia: comparten exigencias y plagas y enfermedades (principio de la guía de Madrid; la app avisa en la rotación).',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'trips',
        'escarabajo_patata'
      ],
      curiosidad:
          'Con una poda de formación se acelera la cosecha; en Madrid se deja una sola flor por grupo para frutos más grandes.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 35-36; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'patata',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['2-3'],
      mesesTrasplante: [],
      siembra:
          'Se planta el tubérculo entero o en trozos con brotes, en febrero-marzo (Zaragoza; en Madrid a mediados de abril, porque el brote no soporta heladas). Antes, compost maduro; necesita tierra mullida (aporcar o acolchar).',
      riego:
          'No regar hasta que brote. Evitar mojar las plantas y los encharcamientos (hongos). Cortar el riego cuando las plantas amarillean.',
      cosecha:
          'Entre 70 y 120 días tras la plantación según sean tempranas o tardías. La piel no debe desprenderse al cogerlas.',
      asociacionesFavorables: [
        'ajo',
        'apio',
        'Coles',
        'espinaca',
        'guisante',
        'haba',
        'judia_verde',
        'rabano',
        'zanahoria'
      ],
      asociacionesDesfavorables: [
        'berenjena',
        'pepino',
        'calabaza',
        'remolacha',
        'tomate'
      ],
      notaAsociaciones:
          'Mejor no juntar ni encadenar cultivos de la misma familia: comparten exigencias y plagas y enfermedades (principio de la guía de Madrid; la app avisa en la rotación). La tabla de Madrid pone el maíz a la vez como favorable y desfavorable: se ha quitado.',
      plagas: [
        'escarabajo_patata',
        'mildiu_tomate_patata',
        'gusano_alambre',
        'gusanos_grises',
        'pulgones'
      ],
      curiosidad:
          'Los huevos del escarabajo de la patata son amarillos y ovalados y se confunden con los de mariquita: mira bien antes de quitarlos.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 38 y 44; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'calabacin',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-3'],
      mesesDirecta: ['4-6'],
      mesesTrasplante: ['4-5'],
      siembra:
          'Semillero en febrero-marzo o siembra directa de abril a junio (varias semillas por golpe). Pide espacio, agua y compost joven.',
      riego:
          'Abundante; es sensible a la falta de luz y necesita buena ventilación.',
      cosecha:
          'A partir de un mes desde el trasplante. Cógelos antes de que hagan semilla; en Madrid, cuando aún no ha caído el resto de la flor.',
      asociacionesFavorables: [
        'Albahaca',
        'cebolla',
        'Coles',
        'guisante',
        'judia_verde',
        'lechuga',
        'maiz_dulce'
      ],
      asociacionesDesfavorables: ['patata'],
      notaAsociaciones:
          'Las «tres hermanas» o milpa (maíz, judía y calabaza) es una asociación tradicional de América: el maíz hace de tutor a la judía y da sombra a la calabaza, que cubre el suelo.',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'oidio_cucurbitaceas',
        'mildiu_cucurbitaceas',
        'caracoles_babosas'
      ],
      curiosidad:
          'Tiene problemas de polinización si está solo: mejor poner varias plantas.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'pepino',
      calendario: 'Zaragoza',
      mesesSemillero: ['3-5'],
      mesesDirecta: [],
      mesesTrasplante: ['5-7'],
      siembra:
          'Semillero protegido en marzo-mayo y trasplante de mayo a julio. Se puede entutorar o dejar rastrero. No tolera los suelos muy salinos.',
      riego:
          'Constante: si el suelo se seca del todo la planta sufre, y la sequía da frutos amargos.',
      cosecha:
          'Desde unos 50 días de la siembra. Cosecha cada 2-3 días antes de que forme semilla: si no, la planta se agota.',
      asociacionesFavorables: [
        'ajo',
        'Albahaca',
        'apio',
        'Coles',
        'judia_verde',
        'guisante',
        'Girasol',
        'cebolla',
        'lechuga',
        'rabano'
      ],
      asociacionesDesfavorables: ['patata', 'tomate'],
      notaAsociaciones: '',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'oidio_cucurbitaceas',
        'mildiu_cucurbitaceas'
      ],
      curiosidad: 'La sequía hace los pepinos amargos (guía de Madrid).',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 38; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'calabaza',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-3'],
      mesesDirecta: ['4-6'],
      mesesTrasplante: ['4-5'],
      siembra:
          'Semillero en febrero-marzo o siembra directa de abril a junio. Planta rústica que pide bastante espacio (puede trepar); se poda despuntando la guía y los brotes laterales.',
      riego: 'Aguanta el verano con menos agua que otros cultivos.',
      cosecha:
          'De 2 a 4 meses desde el trasplante según la variedad; en Madrid se recogen en octubre-noviembre con la planta seca.',
      asociacionesFavorables: [
        'Albahaca',
        'cebolla',
        'Coles',
        'guisante',
        'judia_verde',
        'lechuga',
        'maiz_dulce'
      ],
      asociacionesDesfavorables: ['patata'],
      notaAsociaciones:
          'Las «tres hermanas» o milpa (maíz, judía y calabaza) es una asociación tradicional de América: el maíz hace de tutor a la judía y da sombra a la calabaza, que cubre el suelo.',
      plagas: ['pulgones', 'oidio_cucurbitaceas', 'mildiu_cucurbitaceas'],
      curiosidad:
          'Secadas unos días al sol, las calabazas se conservan unos seis meses en la despensa.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'melon',
      calendario: 'Zaragoza',
      mesesSemillero: ['3-4'],
      mesesDirecta: [],
      mesesTrasplante: ['5-6'],
      siembra:
          'Semillero en marzo-abril y trasplante en mayo-junio. Rastrero de verano: necesita espacio, mucho sol y buenos aportes de compost joven. Se poda como la calabaza.',
      riego:
          'Si se riega por goteo, mojar bastante volumen de tierra (por ejemplo, dos tubos). Cuando los frutos son grandes, reducir el riego hasta cortarlo.',
      cosecha:
          'Entre 90 y 120 días desde la siembra. Está maduro cuando el pedúnculo se seca y la piel empieza a agrietarse.',
      asociacionesFavorables: [
        'ajo',
        'cebolla',
        'Coles',
        'espinaca',
        'guisante',
        'judia_verde',
        'lechuga',
        'maiz_dulce',
        'puerro',
        'rabano'
      ],
      asociacionesDesfavorables: ['calabacin', 'pepino', 'calabaza'],
      notaAsociaciones: '',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'oidio_cucurbitaceas',
        'mildiu_cucurbitaceas'
      ],
      curiosidad:
          'El pedúnculo seco y la piel que se agrieta avisan de que está maduro.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'sandia',
      calendario: 'Zaragoza',
      mesesSemillero: ['3-4'],
      mesesDirecta: [],
      mesesTrasplante: ['5-6'],
      siembra:
          'Semillero en marzo-abril y trasplante en mayo-junio. Más vigorosa que el melón y mejor adaptada al calor; ocupa aún más espacio y la poda importa menos.',
      riego:
          'En suelos profundos es más autónoma que el melón. No regar en exceso cuando los frutos tienen buen tamaño: se rajan.',
      cosecha: 'Tras unos 100-140 días de la siembra.',
      asociacionesFavorables: [
        'ajo',
        'cebolla',
        'Coles',
        'espinaca',
        'guisante',
        'judia_verde',
        'lechuga',
        'maiz_dulce',
        'puerro',
        'rabano'
      ],
      asociacionesDesfavorables: ['calabacin', 'pepino', 'calabaza'],
      notaAsociaciones: '',
      plagas: [
        'pulgones',
        'mosca_blanca',
        'arana_roja',
        'oidio_cucurbitaceas',
        'mildiu_cucurbitaceas'
      ],
      curiosidad:
          'Madura, el zarcillo más cercano se seca y la parte que apoya en el suelo pasa de blanca a amarilla.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'lechuga',
      calendario: 'Zaragoza',
      mesesSemillero: ['1-5', '8-11'],
      mesesDirecta: [],
      mesesTrasplante: ['2-11'],
      siembra:
          'Semillero casi todo el año (enero-mayo y agosto-noviembre) y trasplante de febrero a noviembre. Hay variedades para cada época: plantarla en su fecha es su mayor exigencia.',
      riego: 'Constante.',
      cosecha:
          'Desde unos 40 días del trasplante hasta 60-70 según la época, antes de que suba a flor. Con el calor de julio-agosto se «entalla» (florece).',
      asociacionesFavorables: [
        'ajo',
        'cebolla',
        'fresa',
        'nabo',
        'tomate',
        'judia_verde',
        'rabano',
        'Coles',
        'remolacha',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['perejil', 'apio', 'Girasol'],
      notaAsociaciones:
          'Con respaldo técnico: en ensayos del USDA-ARS en California, intercalar aliso marítimo (Lobularia) entre lechugas atrajo sírfidos que se comen el pulgón; a cambio, la lechuga salió algo más pequeña.',
      plagas: [
        'pulgones',
        'caracoles_babosas',
        'mildiu_lechuga',
        'gusanos_grises',
        'trips',
        'botritis'
      ],
      curiosidad:
          'En la ciudad, las lechugas pequeñas atraen a gorriones y otras aves, además de caracoles y babosas.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 38; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); USDA-ARS, «Flower Power Protects Organic Lettuce», Agricultural Research, enero 2014 (ensayos de E. B. Brennan, Biological Control 65, 2013)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'escarola',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-7'],
      mesesDirecta: [],
      mesesTrasplante: ['7-9'],
      siembra:
          'Semillero en junio-julio y trasplante de julio a septiembre: es la hoja de otoño-invierno, más ruda que la lechuga.',
      riego: '',
      cosecha:
          'A partir de 70-80 días del trasplante; aguanta el invierno en tierra.',
      asociacionesFavorables: [
        'ajo',
        'berenjena',
        'cebolla',
        'Coles',
        'fresa',
        'nabo',
        'puerro'
      ],
      asociacionesDesfavorables: [],
      notaAsociaciones: '',
      plagas: ['pulgones', 'caracoles_babosas', 'mildiu_lechuga'],
      curiosidad:
          'Se blanquea 5-20 días antes de comerla, atándola o tapándola, para quitarle amargor.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'alcachofa',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: [],
      mesesTrasplante: ['6-8'],
      siembra:
          'Se reproduce por esquejes de raíz («zuecas») que se plantan en verano para que estén bien desarrolladas al llegar el invierno. Plurianual: mejor en una parcela aparte de la rotación.',
      riego: 'Abundante; necesita espacio, agua y tierra profunda y fértil.',
      cosecha: 'En primavera, antes de que empiecen a ahuecarse.',
      asociacionesFavorables: [
        'cebolla',
        'Coles',
        'haba',
        'lechuga',
        'guisante'
      ],
      asociacionesDesfavorables: ['patata'],
      notaAsociaciones: '',
      plagas: ['pulgones', 'caracoles_babosas'],
      curiosidad:
          'Las plurianuales (alcachofa, fresa, espárrago) se cambian de sitio cada 4-5 años en lugar de rotar cada temporada.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); Ayto. Madrid, guía de asociación y rotación, p. 3 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'acelga',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-3'],
      mesesDirecta: ['4-10'],
      mesesTrasplante: ['4-11'],
      siembra:
          'Semillero en febrero-marzo, o siembra directa de abril a octubre. En Madrid se aconseja la siembra directa porque tras el trasplante suele subirse a flor.',
      riego: 'Regular. En verano las hojas salen más bastas.',
      cosecha:
          'A los 60-90 días del trasplante, por hojas o la planta entera. Si pasa el invierno, rebrota y da hojas en marzo-abril.',
      asociacionesFavorables: [
        'cebolla',
        'judia_verde',
        'lechuga',
        'nabo',
        'rabano',
        'zanahoria'
      ],
      asociacionesDesfavorables: [
        'Albahaca',
        'espinaca',
        'Espárrago',
        'puerro',
        'remolacha',
        'tomate'
      ],
      notaAsociaciones:
          'Tradición recogida en la guía de Madrid: «el olor de las cebollas aleja a las babosas de las acelgas». No hemos encontrado ensayos que lo comprueben.',
      plagas: [
        'pulguilla_acelga',
        'caracoles_babosas',
        'mildiu_acelga_espinaca',
        'cercospora',
        'mosca_remolacha',
        'pulgones'
      ],
      curiosidad:
          'Acelga y remolacha son la misma especie, Beta vulgaris: la selección de miles de años sacó una para hojas y otra para raíz.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 35; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 2 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'espinaca',
      calendario: 'Zaragoza',
      mesesSemillero: ['1-2', '8-9'],
      mesesDirecta: [],
      mesesTrasplante: ['3-4', '9-10'],
      siembra:
          'Semillero en enero-febrero y agosto-septiembre, con trasplante en marzo-abril y septiembre-octubre; en Madrid también siembra directa casi todo el año salvo el frío extremo. Hay variedades de primavera y de otoño-invierno.',
      riego:
          'Humedad constante: sus raíces son flojas; evitar compactación y encharcamiento.',
      cosecha:
          'Mejor la planta entera a los 50-80 días de la siembra, aunque también por hojas.',
      asociacionesFavorables: [
        'apio',
        'berenjena',
        'borraja',
        'Coles',
        'escarola',
        'fresa',
        'haba',
        'pimiento',
        'rabano',
        'puerro'
      ],
      asociacionesDesfavorables: ['acelga', 'remolacha'],
      notaAsociaciones:
          'Tradición recogida en la guía de Madrid: asociadas con espinacas, las habas serían menos atractivas para el pulgón negro. Sin ensayos que lo respalden.',
      plagas: [
        'caracoles_babosas',
        'mildiu_acelga_espinaca',
        'pulgones',
        'mosca_remolacha'
      ],
      curiosidad:
          'Es «la prima delicada y fina de la acelga»: misma familia, ciclo más rápido y raíces más delicadas.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'remolacha',
      calendario: 'Zaragoza',
      mesesSemillero: ['2', '7-9'],
      mesesDirecta: ['8-9'],
      mesesTrasplante: ['3-4', '8-10'],
      siembra:
          'Semillero en febrero y julio-septiembre, o siembra directa en agosto-septiembre. Crece mejor en otoño-invierno; favorece que crezca rápido con compost joven y escardas al principio.',
      riego: 'Regular.',
      cosecha:
          'Se va cosechando desde los 60 días del trasplante. Con calor o más de 120 días en tierra pierde calidad.',
      asociacionesFavorables: [
        'apio',
        'ajo',
        'cebolla',
        'Coles',
        'judia_verde',
        'lechuga',
        'puerro',
        'pepino'
      ],
      asociacionesDesfavorables: ['zanahoria', 'espinaca'],
      notaAsociaciones: '',
      plagas: ['pulguilla_acelga', 'cercospora', 'mosca_remolacha'],
      curiosidad:
          'En la rotación cuenta como raíz, aunque sea de la familia de la acelga.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); Ayto. Madrid, guía de asociación y rotación, p. 3 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'zanahoria',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['3-5', '8-10'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa en marzo-mayo y agosto-octubre, a chorrillo y luego aclarando. Tarda dos o más semanas en germinar: hay que tenerla limpia de hierba. La falsa siembra ayuda. Suelo suelto y sin obstáculos para que no se deformen.',
      riego: 'Regular; abonar solo con un poco de compost muy maduro.',
      cosecha:
          'Entre 70 y 120 días según la variedad y el ciclo. Aguantan bien en tierra en invierno.',
      asociacionesFavorables: [
        'cebolla',
        'guisante',
        'judia_verde',
        'lechuga',
        'rabano',
        'patata',
        'puerro',
        'tomate'
      ],
      asociacionesDesfavorables: ['remolacha', 'Apiáceas'],
      notaAsociaciones:
          'La pareja zanahoria-cebolla «contra la mosca de la zanahoria» es muy citada; la RHS la menciona sin estudio que la respalde.',
      plagas: ['mosca_zanahoria'],
      curiosidad:
          'Se aporcan para que las raíces que asoman no se pongan verdes.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 39; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); RHS, «Three sisters», https://www.rhs.org.uk/advice/grow-your-own/features/three-sisters',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'apio',
      calendario: 'Zaragoza',
      mesesSemillero: ['5-8'],
      mesesDirecta: [],
      mesesTrasplante: ['6-10'],
      siembra:
          'Semillero de mayo a agosto y trasplante de junio a octubre. Crece despacio al principio: mantenlo sin hierba hasta que cubra el espacio. Puede tardar hasta 30 días en germinar.',
      riego:
          'Abundante: tierra húmeda sin encharcar y sin materia orgánica fresca.',
      cosecha:
          'A partir de 2-3 meses del trasplante; aguanta el invierno en tierra.',
      asociacionesFavorables: [
        'Coles',
        'guisante',
        'judia_verde',
        'lechuga',
        'pepino',
        'puerro',
        'rabano',
        'tomate'
      ],
      asociacionesDesfavorables: ['zanahoria', 'patata'],
      notaAsociaciones: '',
      plagas: ['mosca_zanahoria'],
      curiosidad: 'Se puede blanquear 10-15 días antes de cosecharlo.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 5 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'chirivia',
      calendario: 'RHS (Reino Unido)',
      mesesSemillero: [],
      mesesDirecta: [],
      mesesTrasplante: [],
      siembra:
          'Siembra directa (no tolera el trasplante por su raíz pivotante), en surcos de 1 cm y con el suelo ya templado; la RHS habla de marzo a principios de mayo en su clima. Usa semilla del año: la vieja germina mal. Germina en 14-30 días y de forma irregular.',
      riego:
          'Regar las plantas jóvenes en épocas secas; luego humedad uniforme para que las raíces no se agrieten.',
      cosecha:
          'Cuando las hojas empiezan a secarse, a finales de verano u otoño; puede quedarse en tierra en invierno.',
      asociacionesFavorables: [],
      asociacionesDesfavorables: [],
      notaAsociaciones: '',
      plagas: ['mosca_zanahoria'],
      curiosidad:
          'La RHS aconseja esperar a la primera helada fuerte: intensifica el dulzor.',
      fuente:
          'RHS, «Parsnips: grow your own», https://www.rhs.org.uk/vegetables/parsnips/grow-your-own; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 3 del PDF (siembra directa)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'perejil',
      calendario: 'Madrid',
      mesesSemillero: ['1-3'],
      mesesDirecta: ['3-10'],
      mesesTrasplante: ['3-5'],
      siembra:
          'Semillero en enero-marzo con trasplante en marzo-mayo, o siembra directa de marzo a octubre (a voleo). Marco 20 x 20 cm.',
      riego: '',
      cosecha: 'Por hojas, según se necesite.',
      asociacionesFavorables: [
        'berenjena',
        'cebolla',
        'Espárrago',
        'pimiento',
        'rabano',
        'tomate'
      ],
      asociacionesDesfavorables: ['guisante', 'lechuga'],
      notaAsociaciones:
          'La guía de Madrid dice que el perejil perjudica a la lechuga, también si se planta donde antes hubo perejil. Es tradición sin ensayo citado.',
      plagas: ['mosca_zanahoria'],
      curiosidad:
          'Junto con el apio, es de lo que más tarda en germinar: hasta 30 días.',
      fuente:
          'Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 8 del PDF (calendario y marcos); Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 5 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'cebolla',
      calendario: 'Zaragoza',
      mesesSemillero: ['1', '7-8', '11-12'],
      mesesDirecta: [],
      mesesTrasplante: ['2-4', '9-12'],
      siembra:
          'Semilleros en invierno o verano y trasplante en febrero-abril (cebollas tempranas) o septiembre-diciembre. Planta rústica si no tiene competencia: con la hierba controlada, solo regar y esperar.',
      riego:
          'Reducir el riego poco a poco cuando el bulbo tiene el tamaño buscado, hasta secarla.',
      cosecha: 'Entre 2,5 y 5 meses según la variedad y el ciclo.',
      asociacionesFavorables: [
        'fresa',
        'chirivia',
        'lechuga',
        'puerro',
        'perejil',
        'tomate',
        'remolacha',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['guisante', 'haba', 'judia_verde', 'patata'],
      notaAsociaciones:
          'La guía de Madrid desaconseja juntar leguminosas con ajo, cebolla y puerro porque inhibirían las bacterias fijadoras de nitrógeno; no cita ensayo.',
      plagas: ['mosca_cebolla', 'trips', 'botritis'],
      curiosidad:
          'Cuando termina el ciclo, el cuello se pone «modorro» (blando y doblado).',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'cebolleta',
      calendario: 'Madrid',
      mesesSemillero: ['11-4'],
      mesesDirecta: [],
      mesesTrasplante: ['2-3'],
      siembra:
          'Es la cebolla cogida antes de tiempo. En Madrid, semillero protegido de noviembre a abril y trasplante a mediados de febrero o marzo, porque soporta las heladas; mejor variedades tipo fuentes o babosa.',
      riego: 'Poco riego (tabla de Madrid).',
      cosecha: 'En junio-julio (Madrid), antes de que engorde el bulbo.',
      asociacionesFavorables: [],
      asociacionesDesfavorables: [],
      notaAsociaciones: '',
      plagas: ['mosca_cebolla', 'trips', 'botritis'],
      curiosidad:
          'No es otra especie: es cebolla (Allium cepa) cosechada joven.',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'ajo',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['8-1'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa de los dientes con la punta hacia arriba (Zaragoza: de agosto a enero; Madrid: noviembre-diciembre). Dientes separados para cabezas; la cabeza entera para un manojo de ajetes.',
      riego:
          'Poco. Escardar; no mojar las hojas. En Madrid no se riega el último mes antes de arrancarlos.',
      cosecha:
          'Ajetes a los 2-3 meses. Cabezas en junio-julio, con las hojas secas; se secan 20 días en manojos en un sitio seco y aireado.',
      asociacionesFavorables: [
        'berenjena',
        'cebolla',
        'fresa',
        'lechuga',
        'pepino',
        'pimiento',
        'tomate'
      ],
      asociacionesDesfavorables: [
        'Coles',
        'guisante',
        'haba',
        'judia_verde',
        'puerro'
      ],
      notaAsociaciones: '',
      plagas: ['roya_ajo_puerro', 'trips'],
      curiosidad:
          'Es quizá la hortaliza más rústica: aguanta fríos extremos y largas sequías.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 35; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'puerro',
      calendario: 'Zaragoza',
      mesesSemillero: ['1-2', '5-6', '12'],
      mesesDirecta: [],
      mesesTrasplante: ['3-4', '6-8'],
      siembra:
          'Semillero en invierno o mayo-junio y trasplante en marzo-abril o junio-agosto. Hay variedades verdes de primavera y azules de otoño-invierno.',
      riego: 'Abundante: engordan a base de agua si se mantienen sin hierba.',
      cosecha:
          'Desde 90 días (variedades de primavera) hasta 180 (de invierno). En primavera sacan un tallo central duro y suben a flor.',
      asociacionesFavorables: [
        'apio',
        'espinaca',
        'Espárrago',
        'fresa',
        'tomate',
        'zanahoria'
      ],
      asociacionesDesfavorables: [
        'ajo',
        'Coles',
        'guisante',
        'haba',
        'judia_verde',
        'lechuga',
        'rabano',
        'remolacha'
      ],
      notaAsociaciones: '',
      plagas: ['roya_ajo_puerro', 'trips', 'mosca_cebolla'],
      curiosidad: 'Se aporcan para que la base salga más blanca y tierna.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'judia_verde',
      calendario: 'Zaragoza',
      mesesSemillero: ['3', '7-8'],
      mesesDirecta: ['4', '7-8'],
      mesesTrasplante: ['4', '8'],
      siembra:
          'Siembra directa en abril o julio-agosto (o semillero poco antes). Sembrar sin calor fuerte sobre tierra húmeda y tapar con tierra seca; el mismo día, unas macetas para reponer fallos. Las de mata alta necesitan tutor o red.',
      riego:
          'Regular. Necesita más de 15 °C para crecer, pero a sus flores no les gustan más de 30 °C.',
      cosecha:
          'Unos 40-60 días desde la siembra. Coger las vainas cada 2-3 días, sin dejar que granen.',
      asociacionesFavorables: [
        'calabacin',
        'calabaza',
        'Coles',
        'fresa',
        'lechuga',
        'rabano',
        'maiz_dulce',
        'tomate',
        'zanahoria'
      ],
      asociacionesDesfavorables: [
        'ajo',
        'cebolla',
        'guisante',
        'haba',
        'puerro',
        'remolacha'
      ],
      notaAsociaciones:
          'Las «tres hermanas» o milpa (maíz, judía y calabaza) es una asociación tradicional de América: el maíz hace de tutor a la judía y da sombra a la calabaza, que cubre el suelo.',
      plagas: ['pulgones', 'arana_roja', 'mosca_blanca', 'trips'],
      curiosidad:
          'Solo en la Comunidad de Madrid se cultivan 48 variedades locales de judías.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'haba',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['9-11'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa en otoño sobre tierra regada, enterrando la semilla 8-10 cm y tapando con tierra seca; no regar hasta que nazca. Una vez nacidas soportan las heladas. Se aporcan 2 o 3 veces.',
      riego: 'Regular.',
      cosecha:
          'Vainas en primavera con el grano mediano: más finas y la cosecha dura más.',
      asociacionesFavorables: [
        'apio',
        'espinaca',
        'lechuga',
        'maiz_dulce',
        'patata',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['ajo', 'Coles', 'puerro'],
      notaAsociaciones:
          'Tradición recogida en la guía de Madrid: junto a espinacas serían menos atractivas para el pulgón negro. Sin ensayos que lo respalden.',
      plagas: ['pulgones'],
      curiosidad: 'Es muy apetecible para el pulgón: por eso no se abona.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37-38; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'tirabeque',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['9-11'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa en otoño, cuando ya no hace calor, sobre tierra bien regada, tapando con tierra seca o mantillo hasta que germine. Necesita tutor.',
      riego: 'Regar lo justo para evitar hongos.',
      cosecha:
          'En primavera, cuando las vainas alcanzan su largura final, sin dejar que la semilla crezca mucho.',
      asociacionesFavorables: [],
      asociacionesDesfavorables: [],
      notaAsociaciones: '',
      plagas: ['pulgones', 'arana_roja'],
      curiosidad:
          'Tradicionalmente se entutora con ramas clavadas en el suelo.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y calendario p. 7 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'guisante',
      calendario: 'Madrid',
      mesesSemillero: [],
      mesesDirecta: ['2-4', '10-11'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa en febrero-abril y octubre-noviembre. Las heladas fuertes retrasan la germinación, pero una vez nacido las soporta. Entutorado colectivo: dos tutores en los extremos y cuerdas a varias alturas.',
      riego: 'Regular.',
      cosecha:
          'Desde junio-julio (Madrid), cogiendo las vainas llenas de semillas grandes y bien formadas.',
      asociacionesFavorables: [
        'apio',
        'pepino',
        'lechuga',
        'Coles',
        'nabo',
        'rabano',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['ajo', 'cebolla', 'judia_verde', 'puerro'],
      notaAsociaciones: '',
      plagas: ['pulgones', 'arana_roja'],
      curiosidad: 'Trepa sola agarrándose con sus zarcillos a las cuerdas.',
      fuente:
          'Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 8 del PDF (calendario y marcos); Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'coliflor',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-8'],
      mesesDirecta: [],
      mesesTrasplante: ['7-10'],
      siembra:
          'Semillero en verano y trasplante de verano a otoño (Zaragoza). En Madrid, semilleros en enero-febrero y junio-agosto. Protege el plantón recién trasplantado: es irresistible para las aves.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Unos 90 días; mejor variedades tempranas. Tras 8-16 hojas forma el cogollo. Se cosecha cuando las hojas dejan ver el cogollo.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'Coliflor, brócoli, repollo, lombarda o kale son la misma especie, Brassica oleracea, seleccionada de distintas maneras.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 2 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'brocoli',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-8'],
      mesesDirecta: [],
      mesesTrasplante: ['7-10'],
      siembra:
          'Semillero en verano y trasplante de verano a otoño (Zaragoza). En Madrid, semilleros en enero-febrero y junio-agosto. Protege el plantón recién trasplantado: es irresistible para las aves.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Unos 90 días; antes de que se abran las flores. Luego da brotes laterales.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'Lo que comemos son flores sin abrir: por eso se corta antes de que se abran.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'romanesco',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-8'],
      mesesDirecta: [],
      mesesTrasplante: ['7-10'],
      siembra:
          'Semillero en verano y trasplante de verano a otoño (Zaragoza). En Madrid, semilleros en enero-febrero y junio-agosto. Protege el plantón recién trasplantado: es irresistible para las aves.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Unos 90 días; mejor variedades tempranas. Tras 8-16 hojas forma el cogollo. Se cosecha cuando las hojas dejan ver el cogollo.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'Botánicamente es una coliflor (Brassica oleracea var. botrytis): mismos cuidados y mismo calendario.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'repollo',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-8'],
      mesesDirecta: [],
      mesesTrasplante: ['7-10'],
      siembra:
          'Semillero en verano y trasplante de verano a otoño (Zaragoza). En Madrid, semilleros en enero-febrero y junio-agosto. Protege el plantón recién trasplantado: es irresistible para las aves.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Entre 60 y 120 días según la variedad, antes de que la cabeza empiece a ahuecarse.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col',
        'mosca_blanca'
      ],
      curiosidad:
          'Menos exigente en nutrientes que la coliflor pero más en sol: por eso va mejor en cultivos de primavera.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'col_lombarda',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-8'],
      mesesDirecta: [],
      mesesTrasplante: ['7-10'],
      siembra:
          'Semillero en verano y trasplante de verano a otoño (Zaragoza). En Madrid, semilleros en enero-febrero y junio-agosto. Protege el plantón recién trasplantado: es irresistible para las aves.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Entre 60 y 120 días según la variedad, antes de que la cabeza empiece a ahuecarse.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'Es un repollo de hojas moradas: la misma especie y los mismos cuidados.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'col_rizada',
      calendario: 'Zaragoza',
      mesesSemillero: ['6-8'],
      mesesDirecta: [],
      mesesTrasplante: ['7-10'],
      siembra:
          'Semillero en verano y trasplante de verano a otoño (Zaragoza). En Madrid, semilleros en enero-febrero y junio-agosto. Protege el plantón recién trasplantado: es irresistible para las aves.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Entre 60 y 120 días según la variedad, antes de que la cabeza empiece a ahuecarse.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'A las orugas y pulguillas les gusta meterse entre sus hojas rizadas: revísalas a menudo.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'kale',
      calendario: 'RHS (Reino Unido)',
      mesesSemillero: [],
      mesesDirecta: [],
      mesesTrasplante: [],
      siembra:
          'La RHS siembra de marzo a junio (semillero o en su sitio) y trasplanta a finales de primavera con 10-15 cm, tras endurecer el plantón. Separación de 30 a 60 cm según la variedad. En el calendario de Madrid cuenta como col.',
      riego: 'Regular hasta que arraiga; luego solo en sequías largas.',
      cosecha:
          'Desde septiembre, 2-3 hojas de abajo por planta; la cosecha dura de otoño a primavera y cortar a menudo hace brotar hojas nuevas.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'Es de las hortalizas de hoja más resistentes al frío. Como es bienal, florece en su segundo año.',
      fuente:
          'RHS, «Kale: grow your own», https://www.rhs.org.uk/vegetables/kale/grow-your-own; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 8 del PDF (calendario y marcos); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'col_bruselas',
      calendario: 'Madrid',
      mesesSemillero: ['7-12'],
      mesesDirecta: [],
      mesesTrasplante: ['5'],
      siembra:
          'En Madrid, semillero de julio a fin de año y trasplante en mayo. Al acogollar pesan: hay que recalzar el tallo. Retira hojas y restos para que no se pudran.',
      riego: 'Abundante (coles en la tabla de Madrid).',
      cosecha:
          'Poco a poco de octubre a enero, cuando las coles tienen buen tamaño.',
      asociacionesFavorables: [
        'cebolla',
        'espinaca',
        'pepino',
        'guisante',
        'lechuga',
        'judia_verde',
        'remolacha',
        'tomate'
      ],
      asociacionesDesfavorables: ['fresa', 'haba'],
      notaAsociaciones:
          'Con respaldo técnico: una cobertura de trébol entre las coles altera la conducta del pulgón y aumenta su control por sírfidos (guía GIP de brásicas del MAPA). La guía de Madrid propone además una línea de facelia entre dos de repollo sembrada en septiembre.',
      plagas: [
        'mariposa_col',
        'pulguilla_col',
        'pulgones',
        'caracoles_babosas',
        'hernia_col'
      ],
      curiosidad:
          'Para acelerar la maduración, en Madrid podan las plantas en otoño.',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36-37; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31 (tabla de riego); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'rabano',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['3-5', '9-10'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa en marzo-mayo y septiembre-octubre, escalonando para alargar la cosecha. Mantén una densidad adecuada (aclarar) para regular el tamaño.',
      riego:
          'Regular: los riegos irregulares pueden adelantar la subida a flor.',
      cosecha:
          'Desde 45-50 días de la siembra. Si no se cosechan, suben a flor y pierden calidad.',
      asociacionesFavorables: [
        'calabacin',
        'Coles',
        'espinaca',
        'fresa',
        'guisante',
        'lechuga',
        'judia_verde',
        'perejil',
        'pepino'
      ],
      asociacionesDesfavorables: ['nabo', 'puerro'],
      notaAsociaciones: '',
      plagas: ['pulguilla_col'],
      curiosidad:
          'En la rotación cuenta como raíz aunque sea crucífera, como el nabo.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); Ayto. Madrid, guía de asociación y rotación, p. 3 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'nabo',
      calendario: 'Madrid',
      mesesSemillero: [],
      mesesDirecta: ['3-5', '7-10'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa en marzo-mayo y julio-octubre (Madrid). Marco 20 x 15 cm.',
      riego: 'Regular.',
      cosecha: 'Los de otoño se recogen a finales de esa estación (Madrid).',
      asociacionesFavorables: [
        'Coles',
        'espinaca',
        'guisante',
        'lechuga',
        'puerro',
        'pepino',
        'remolacha',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['rabano'],
      notaAsociaciones: '',
      plagas: ['pulguilla_col'],
      curiosidad: 'Es crucífera, pero en la rotación se trata como raíz.',
      fuente:
          'Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 8 del PDF (calendario y marcos); Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 47; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'rucula',
      calendario: 'Madrid',
      mesesSemillero: [],
      mesesDirecta: ['2-10'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa de febrero a octubre (Madrid), en surcos de 1 cm o a voleo; mejor en tandas pequeñas cada pocas semanas. En verano, a media sombra.',
      riego:
          'Regular: el calor y la sequía la hacen florecer antes de tiempo, y entonces amarga.',
      cosecha:
          'Desde que tiene unos 10 cm, cortando las hojas de fuera; cada siembra da dos o tres cortes.',
      asociacionesFavorables: [
        'berenjena',
        'cebolla',
        'pepino',
        'pimiento',
        'tomate',
        'zanahoria'
      ],
      asociacionesDesfavorables: ['Coles', 'rabano', 'nabo'],
      notaAsociaciones: '',
      plagas: ['pulguilla_col'],
      curiosidad: 'Tiene sabor picante; el canónigo, en cambio, es suave.',
      fuente:
          'Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 8 del PDF (calendario y marcos); RHS, «Salad leaves: grow your own», https://www.rhs.org.uk/vegetables/salad-leaves/grow-your-own; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'maiz_dulce',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: ['5-7'],
      mesesTrasplante: [],
      siembra:
          'Siembra directa de mayo a julio. Exigente en calor, agua y nutrientes (compost joven); da 1 o 2 mazorcas por planta. No subestimes su altura: da sombra a sus vecinas.',
      riego: 'Exigente en agua.',
      cosecha:
          'Para comer tierno, cuando las barbas cambian de color (unos 70-90 días). Para palomitas o semilla, grano y planta secos (unos 120 días).',
      asociacionesFavorables: [
        'calabacin',
        'calabaza',
        'guisante',
        'judia_verde',
        'pepino',
        'melon',
        'sandia'
      ],
      asociacionesDesfavorables: ['remolacha', 'Girasol', 'patata', 'apio'],
      notaAsociaciones:
          'Las «tres hermanas» o milpa (maíz, judía y calabaza) es una asociación tradicional de América: el maíz hace de tutor a la judía y da sombra a la calabaza, que cubre el suelo.',
      plagas: [],
      curiosidad:
          'Las variedades de palomitas son distintas de las de grano tierno: elige según cómo lo vayas a comer.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones); Ayto. Madrid, guía de asociación y rotación, p. 7 del PDF (las tres hermanas)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'fresa',
      calendario: 'Zaragoza',
      mesesSemillero: [],
      mesesDirecta: [],
      mesesTrasplante: ['2-4', '11-12'],
      siembra:
          'Se planta en febrero-abril o noviembre-diciembre. Mejor en macetas o parterres con sustrato adecuado; aclarar plantas cada cierto tiempo. Se reproduce por estolones. Plurianual: fuera de la rotación anual.',
      riego: 'Constante.',
      cosecha: 'En primavera, cuando los frutos se ponen rojos.',
      asociacionesFavorables: [
        'ajo',
        'borraja',
        'cebolla',
        'espinaca',
        'judia_verde',
        'lechuga',
        'nabo',
        'puerro',
        'Tomillo'
      ],
      asociacionesDesfavorables: ['Coles'],
      notaAsociaciones: '',
      plagas: ['pulgones', 'arana_roja', 'caracoles_babosas', 'botritis'],
      curiosidad:
          'Se multiplica por estolones: tallos que echan raíz al tocar el suelo. Conviene renovar las plantas cada 3 o 4 años.',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 y calendario p. 7 del PDF; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 9 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», pp. 8-9 del PDF (tabla de asociaciones)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'canonigo',
      calendario: 'RHS (Reino Unido)',
      mesesSemillero: [],
      mesesDirecta: [],
      mesesTrasplante: [],
      siembra:
          'La RHS lo trata como las demás hojas de ensalada: siembra al aire libre de mediados de primavera a finales de verano, y en otoño bajo protección.',
      riego: '',
      cosecha: 'Hojas exteriores desde que la roseta tiene unos 10 cm.',
      asociacionesFavorables: [],
      asociacionesDesfavorables: [],
      notaAsociaciones: '',
      plagas: [],
      curiosidad:
          'Es una planta rústica de roseta: con variedades para el frío se puede cosechar casi todo el año.',
      fuente:
          'RHS, «Salad leaves: grow your own», https://www.rhs.org.uk/vegetables/salad-leaves/grow-your-own',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaCultivo(
      id: 'borraja',
      calendario: 'Zaragoza',
      mesesSemillero: ['2-4', '7-8'],
      mesesDirecta: [],
      mesesTrasplante: ['4-5', '8-10'],
      siembra:
          'Semillero en febrero-abril o julio-agosto y trasplante en primavera u otoño. Hay que entenderla como una planta silvestre: le gustan la primavera y el otoño y huye del calor fuerte. Evita plantarla muy pronto en primavera.',
      riego: 'Constante, sin mojar las hojas (es sensible a los hongos).',
      cosecha:
          'Entre 1,5 meses (primavera) y 3 (invierno) desde el trasplante, antes de que suba a flor, porque amarga.',
      asociacionesFavorables: [],
      asociacionesDesfavorables: [],
      notaAsociaciones: '',
      plagas: [],
      curiosidad:
          'Con cambios bruscos o estrés se sube a flor; en flor atrae a polinizadores (ver «Plantas que ayudan»).',
      fuente:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y calendario p. 7 del PDF; Ayto. Madrid, guía de asociación y rotación, p. 9 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
];
