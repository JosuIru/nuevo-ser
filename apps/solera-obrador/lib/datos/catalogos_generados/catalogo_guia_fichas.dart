// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/obrador/guia_fichas.csv
// Generado: 2026-11-10
// Filas: 41 (0 firmadas por persona, 41 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

class FichaGuiaObrador {
  const FichaGuiaObrador({
    required this.id,
    required this.seccion,
    required this.titulo,
    required this.parrafos,
    required this.calculadora,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String seccion;
  final String titulo;
  final List<String> parrafos;
  final String calculadora;
  final String fuente;
  final String revisadoPor;
}

const List<FichaGuiaObrador> catalogoGuiaFichas = [
  FichaGuiaObrador(
      id: 'levadura',
      seccion: 'fermentacion',
      titulo: 'Levadura fresca y seca',
      parrafos: [
        'La levadura de panadería (Saccharomyces cerevisiae) se vende fresca (prensada, en pastilla) o seca. La fresca se conserva en nevera y caduca en pocas semanas; la seca dura mucho más cerrada.',
        'La seca instantánea se usa aproximadamente a un tercio del peso de la fresca, y la seca activa algo más (en torno a la mitad); el envase de cada fabricante da su equivalencia. La instantánea se mezcla directamente con la harina; la activa suele hidratarse antes en agua templada.',
        'Más levadura acorta la fermentación pero da menos sabor; con poca levadura y más tiempo (o frío) el pan gana aroma.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread: A Baker\'s Book of Techniques and Recipes» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage); instrucciones de los fabricantes de levadura',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'masa_madre',
      seccion: 'fermentacion',
      titulo: 'Masa madre: qué es y cómo se mantiene',
      parrafos: [
        'La masa madre es una masa de harina y agua fermentada por levaduras y bacterias lácticas propias, que se mantiene viva con refrescos (RD 308/2019 la define en su art. 2). Da acidez, aroma y una fermentación más lenta que la levadura.',
        'Para mantenerla: guardar una pequeña parte en nevera y refrescarla con regularidad (al menos una vez por semana si está fría; a diario si está a temperatura ambiente). Antes de usarla, darle uno o dos refrescos a temperatura ambiente.',
        'Se usa en su pico: ha crecido, tiene la superficie abombada y llena de burbujas y huele ácido agradable. Si se ha hundido, ya ha pasado el pico; un refresco más la recupera.',
        'En la app, Hoy → Masa madre apunta cada refresco.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de masa madre; Real Decreto 308/2019 art. 2 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'refresco',
      seccion: 'fermentacion',
      titulo: 'Refrescos y proporciones',
      parrafos: [
        'Un refresco se escribe como masa madre : harina : agua, en peso. 1:1:1 (una parte de cada) llega al pico en pocas horas a temperatura ambiente; 1:2:2 tarda más; 1:5:5 o 1:10:10 permite dejarla toda la noche.',
        'Con el mismo peso de agua que de harina (100 % de hidratación) la masa madre es líquida; con un 50-60 % de agua es firme (más acética y más lenta).',
        'Para pasar de una de trigo a una de centeno basta refrescarla con centeno dos o tres veces.',
        'Cuanto más caliente, antes llega al pico: a 25-27 °C va mucho más deprisa que a 20 °C.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de masa madre; Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'poolish',
      seccion: 'fermentacion',
      titulo: 'Poolish',
      parrafos: [
        'Prefermento líquido: harina y agua a partes iguales (100 % de hidratación) con muy poca levadura, en torno al 0,1 % de la harina del poolish si va a fermentar 12-16 h a temperatura ambiente.',
        'Está listo cuando está lleno de burbujas, ha crecido y empieza a hundirse por el centro. Se añade a la masa final con el resto de ingredientes.',
        'Habitual en baguette y chapata: da extensibilidad y aroma. Al usarlo, la levadura de la masa final se reduce.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de prefermentos; Calvel, R., «Le goût du pain» (Jérôme Villette)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'biga',
      seccion: 'fermentacion',
      titulo: 'Biga',
      parrafos: [
        'Prefermento firme de tradición italiana: harina, agua (en torno al 50-60 % de la harina de la biga) y muy poca levadura, 12-16 h a temperatura ambiente fresca.',
        'Aporta fuerza y aroma; se usa en chapata y panes italianos. Se trocea al añadirla a la masa final para que se reparta.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de prefermentos; Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'masa_vieja',
      seccion: 'fermentacion',
      titulo: 'Masa vieja (masa fermentada)',
      parrafos: [
        'Un trozo de masa de pan del día anterior (con su sal y su levadura), guardado en nevera, que se añade a la masa nueva. Es el prefermento más sencillo en un obrador que amasa a diario.',
        'Suele añadirse en proporciones del 10-50 % sobre la harina de la masa final. Mejora el sabor y la conservación sin cambiar el proceso.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de prefermentos (pâte fermentée); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'autolisis',
      seccion: 'fermentacion',
      titulo: 'Autólisis',
      parrafos: [
        'Reposo de la harina con el agua, sin sal ni levadura, durante 20-60 min antes de amasar. Técnica descrita por el profesor Raymond Calvel.',
        'La harina se hidrata y el gluten empieza a formarse solo, así que el amasado es más corto y la masa más extensible. Útil en masas muy hidratadas e integrales.',
        'La sal y la levadura (o la masa madre) se añaden al terminar el reposo.'
      ],
      calculadora: '',
      fuente:
          'Calvel, R., «Le goût du pain» (Jérôme Villette); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'frio',
      seccion: 'fermentacion',
      titulo: 'Fermentación en frío (retardada)',
      parrafos: [
        'La masa (en bloque o ya formada) se guarda en nevera, en torno a 2-6 °C, para frenar la fermentación: permite repartir el trabajo y gana aroma y color de corteza.',
        'Lo más práctico suele ser retardar la pieza formada y cocerla al sacarla de la nevera. Con levadura conviene reducir la dosis si el retardo es largo.',
        'La mención «elaborado con larga fermentación» tiene requisitos legales: al menos 8 horas de fermentación de la masa a más de 4 °C entre el amasado y la cocción (RD 308/2019 art. 14.4). Una masa a 2-4 °C no suma esas horas.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Real Decreto 308/2019 art. 14.4 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'mencion_masa_madre',
      seccion: 'fermentacion',
      titulo: 'La mención «elaborado con masa madre»',
      parrafos: [
        'Solo puede ponerse si el pan lleva masa madre en al menos el 5 % del peso total de la harina de la masa final y ningún aditivo (RD 308/2019 art. 14.5).',
        'Además: la masa madre debe tener un pH menor de 4,2 y una acidez total titulable mayor de 6 antes de añadirla, y la masa antes de cocer y el pan, un pH menor de 4,8, solo por la acidificación de la masa madre. Esto se comprueba con un pHmetro o un laboratorio, no con la app.',
        'Se admite levadura en el amasado final hasta el 0,2 % del peso total de harina.'
      ],
      calculadora: '',
      fuente: 'Real Decreto 308/2019 art. 14.5 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'temperatura_tiempo',
      seccion: 'tiempos',
      titulo: 'Temperatura y tiempos',
      parrafos: [
        'La temperatura de la masa manda en los tiempos: con más calor la levadura y las bacterias trabajan más deprisa, y con frío más despacio. Por eso los tiempos de las recetas se dan para una temperatura de masa concreta.',
        'Mide la masa con un termómetro de pincho al acabar de amasar. Si sale más fría que la de la receta, la fermentación tardará más; si sale más caliente, menos (y se puede pasar).',
        'Para panes de masa blanca con levadura se suele buscar 24-26 °C; centeno con masa madre, algo más caliente; masas con mucha mantequilla, más frías para que no se derrita.',
        'Mira la masa más que el reloj: el volumen, las burbujas y la prueba del dedo dicen cuándo está.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); King Arthur Baking, «Dough Temperature» (kingarthurbaking.com/professional)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'temperatura_agua',
      seccion: 'tiempos',
      titulo: 'Temperatura del agua (fórmula)',
      parrafos: [
        'Para que la masa salga a la temperatura objetivo se ajusta la del agua, que es la más fácil de cambiar.',
        'Masa directa: temperatura del agua = objetivo × 3 − harina − ambiente − fricción.',
        'Con prefermento (poolish, biga, masa madre): objetivo × 4 − harina − ambiente − fricción − prefermento.',
        'Todas las temperaturas en °C. La fricción es el calor que añade el amasado: depende de la amasadora y del tiempo, y se mide (ver la ficha «Factor de fricción»). Amasando a mano es pequeña, de unos pocos grados.'
      ],
      calculadora: 'temperatura_agua',
      fuente:
          'King Arthur Baking, «Dough Temperature» (kingarthurbaking.com/professional); King Arthur Baking, «Desired dough temperature» (blog, 2018); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'friccion',
      seccion: 'tiempos',
      titulo: 'Factor de fricción',
      parrafos: [
        'Se calcula una vez por amasadora y por tipo de amasado: anota la temperatura de la harina, del ambiente y del agua, amasa como siempre y mide la masa al terminar.',
        'Fricción = temperatura de la masa × 3 − harina − ambiente − agua (con prefermento, × 4 y resta también la del prefermento).',
        'Repítelo si cambias de amasadora, de velocidad o de tiempo de amasado: ese valor es el que se pone en la fórmula del agua.'
      ],
      calculadora: '',
      fuente:
          'King Arthur Baking, «Determining the friction factor in baking» (blog, 2018); King Arthur Baking, «Dough Temperature» (kingarthurbaking.com/professional)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'ventana',
      seccion: 'tiempos',
      titulo: 'Prueba de la ventana',
      parrafos: [
        'Para saber si el gluten está desarrollado: coge un trozo de masa y estíralo poco a poco con los dedos. Si se forma una membrana fina y translúcida sin romperse, el desarrollo es completo.',
        'Si se rompe enseguida, falta amasado (o reposo). Las masas de pan rústico y masa madre no necesitan llegar a la ventana completa: los pliegues durante la fermentación terminan el trabajo. El pan de molde y el brioche, sí.',
        'No sirve para el centeno, que casi no forma gluten.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'dedo',
      seccion: 'tiempos',
      titulo: 'Prueba del dedo',
      parrafos: [
        'Para saber si la pieza formada está lista para el horno: hunde un dedo enharinado un centímetro en la masa.',
        'Si la huella vuelve enseguida, le falta fermentación. Si vuelve despacio y queda una pequeña marca, está lista. Si no vuelve y la masa se arruga o se hunde, está pasada: cuécela ya, sin greñar fuerte.',
        'En masas frías, recién sacadas de la nevera, la masa responde más despacio: compénsalo con la vista (volumen y burbujas).'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'punto_fermentacion',
      seccion: 'tiempos',
      titulo: 'Punto de la primera fermentación',
      parrafos: [
        'La primera fermentación (en bloque) termina cuando la masa ha crecido claramente (según la receta, del 50 % a casi el doble), está abombada, tiene burbujas en los lados y la superficie y ha perdido la pegajosidad del principio.',
        'Un recipiente recto y transparente con una marca del nivel inicial ayuda a ver cuánto ha crecido.',
        'Los pliegues durante esta fase dan fuerza a las masas blandas sin amasarlas más.'
      ],
      calculadora: '',
      fuente: 'Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'horno_domestico',
      seccion: 'coccion',
      titulo: 'Horno doméstico con vapor',
      parrafos: [
        'El vapor en los primeros minutos mantiene la superficie blanda para que el pan crezca (el greñado abra) y da una corteza brillante. Después hay que quitarlo para que la corteza se seque y dore.',
        'Formas de hacer vapor: una bandeja metálica en la base precalentada con el horno y agua (o hielo) al meter el pan; pulverizar las paredes; o cubrir la pieza (olla, bandeja invertida) para que su propio vapor la rodee. Cuidado con el cristal de la puerta y con las quemaduras de vapor.',
        'Precalentar bien: al menos 30-45 min, más con piedra. Los hornos domésticos pierden mucho calor al abrir la puerta.',
        'Pan rústico: 230-250 °C con vapor 10-15 min y luego sin vapor. Panes enriquecidos: 170-200 °C sin vapor.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'piedra_acero',
      seccion: 'coccion',
      titulo: 'Piedra o acero',
      parrafos: [
        'Una piedra refractaria o una plancha de acero acumulan calor y lo pasan de golpe a la base del pan, como la solera de un horno de pan: más subida y mejor base.',
        'Necesitan precalentarse mucho (en torno a 45-60 min). El acero calienta más deprisa que la piedra y transmite más: vigila que la base no se queme.',
        'El pan se desliza sobre ella con una pala enharinada o sobre papel de horno.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'olla_hierro',
      seccion: 'coccion',
      titulo: 'Olla de hierro (cocotte)',
      parrafos: [
        'La olla tapada encierra el vapor que suelta la propia masa: en un horno doméstico es la forma más sencilla de conseguir vapor y buena subida en hogazas.',
        'Precalentar la olla dentro del horno a 240-250 °C. Meter la masa sobre papel de horno (cuidado: quema), tapar, cocer unos 20 min, destapar y terminar 15-25 min a 220-230 °C hasta el color deseado.',
        'Solo sirve para piezas que caben en la olla; para barras, piedra y bandeja de vapor.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); King Arthur Baking, guías de horneado en olla (kingarthurbaking.com)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'horno_lena',
      seccion: 'coccion',
      titulo: 'Horno de leña',
      parrafos: [
        'El horno de leña se calienta encendiendo el fuego dentro; se retiran las brasas (o se apartan) y se cuece con el calor acumulado en la bóveda y la solera. El calor baja a lo largo de la hornada: primero las piezas que piden más temperatura, después las de menos (bollería, panes enriquecidos).',
        'La temperatura de la solera se comprueba con un termómetro de infrarrojos o con la experiencia (color de la bóveda, una pizca de harina que tuesta). La humedad se aporta mojando la solera o con un recipiente con agua.',
        'La denominación «pan de leña» o «pan de horno de leña» solo puede usarse si el pan se cuece en su totalidad en un horno de leña (RD 308/2019 art. 14.6).'
      ],
      calculadora: '',
      fuente:
          'Real Decreto 308/2019 art. 14.6 (BOE-A-2019-6994); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'conveccion',
      seccion: 'coccion',
      titulo: 'Horno de convección (aire)',
      parrafos: [
        'El ventilador reparte el calor y cuece más deprisa y más igual en varias bandejas, pero seca la superficie y puede frenar la subida y el greñado.',
        'Se suele bajar la temperatura unos 10-20 °C respecto a un horno estático y vigilar antes el color. Para pan rústico, si el horno lo permite, mejor sin aire los primeros minutos (con vapor) y con aire al final.',
        'Va bien para pan de molde, bollería y piezas pequeñas.'
      ],
      calculadora: '',
      fuente:
          'Suas, M., «Advanced Bread and Pastry» (Delmar Cengage); manuales de los fabricantes de hornos',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'hecho',
      seccion: 'coccion',
      titulo: 'Cómo saber que está hecho',
      parrafos: [
        'Color: corteza bien dorada; un pan pálido suele estar corto de horno.',
        'Sonido: al golpear la base suena hueco.',
        'Temperatura interna (termómetro de pincho en el centro): panes de masa magra (harina, agua, sal, levadura) en torno a 96-99 °C; panes enriquecidos (molde, brioche) en torno a 88-90 °C. La temperatura llega a esos valores antes de que la corteza esté hecha: mira también el color.',
        'Dejar enfriar sobre rejilla antes de cortar: la miga se asienta mientras se enfría (el centeno, 12-24 h).'
      ],
      calculadora: '',
      fuente:
          'Cook\'s Illustrated / America\'s Test Kitchen, «Visual Guide to Judging Bread Doneness»; Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'grenado',
      seccion: 'coccion',
      titulo: 'Greñado (corte)',
      parrafos: [
        'El corte en la superficie justo antes de cocer marca por dónde se abre el pan al crecer en el horno, en vez de reventar por cualquier lado.',
        'Cuchilla afilada (lame) inclinada unos 30-45° para que forme oreja; corte decidido, de unos milímetros de profundidad. Hacerlo con la pieza bien formada y en su punto de fermentación.',
        'Barras: varios cortes oblicuos, casi paralelos al eje, que se solapan un poco.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Calvel, R., «Le goût du pain» (Jérôme Villette)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'tipos_harina',
      seccion: 'harinas',
      titulo: 'Tipos de harina de trigo (cenizas)',
      parrafos: [
        'En España, la norma de calidad de las harinas es el Real Decreto 677/2016. Clasifica la harina de trigo por su contenido en cenizas sobre materia seca: harina flor o de baja extracción (hasta 0,50 %), harina de trigo a secas o de extracción media (0,50-0,80 %) y harina morena o de alta extracción (desde 0,80 % y menos del 2,5 %).',
        'Más cenizas significa más partes externas del grano: harina más oscura, más sabor y más absorción de agua, y menos fuerza aparente.',
        'Los «tipos» con número (45, 55, 65…) son la clasificación francesa; no son los de la norma española.'
      ],
      calculadora: '',
      fuente:
          'Real Decreto 677/2016, norma de calidad para las harinas, las sémolas y otros productos de la molienda de los cereales, arts. 2.6 y 4.1 (BOE-A-2016-11951)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'fuerza',
      seccion: 'harinas',
      titulo: 'Fuerza (W) y P/L',
      parrafos: [
        'La fuerza W se mide con el alveógrafo (en unidades de 10⁻⁴ J) e indica la capacidad de la masa para retener el gas. El anexo del RD 677/2016 define cuatro tipos por calidad panadera: gran fuerza (proteína ≥ 14,5 % y W ≥ 350), fuerza (≥ 12,5 % y W ≥ 250), media fuerza (≥ 10,5 % y W ≥ 150) y panificable (≥ 9 % y W ≥ 70). Indicar el tipo en la etiqueta es voluntario.',
        'El P/L (del mismo ensayo) relaciona tenacidad (P) y extensibilidad (L): más alto, masa más tenaz que cuesta estirar; más bajo, masa más extensible que se abre. No aparece en el real decreto: pídelo en la ficha técnica del molino.',
        'Pan común y rústico: panificable o media fuerza. Masas muy hidratadas, largas fermentaciones y bollería con mucha grasa: fuerza.'
      ],
      calculadora: '',
      fuente:
          'Real Decreto 677/2016, art. 4.1.a y anexo (BOE-A-2016-11951); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'integral_harina',
      seccion: 'harinas',
      titulo: 'Harina integral',
      parrafos: [
        'Según el RD 677/2016 (art. 2.7), harina integral es la que tiene la composición del grano entero del cereal, se muela de una vez o se recombinen después sus partes.',
        'Absorbe más agua que la blanca y el salvado corta la red de gluten: masas más pegajosas al principio, menos volumen y fermentación algo más rápida. Ayuda un reposo de autólisis largo.',
        'Se enrancia antes que la blanca: compra la que vayas a usar en poco tiempo y guárdala en sitio fresco.',
        'Para llamar al pan «integral» toda su harina debe ser integral (RD 308/2019 art. 4.3).'
      ],
      calculadora: '',
      fuente:
          'Real Decreto 677/2016 art. 2.7 (BOE-A-2016-11951); Real Decreto 308/2019 art. 4.3 (BOE-A-2019-6994); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'centeno_harina',
      seccion: 'harinas',
      titulo: 'Harina de centeno',
      parrafos: [
        'El centeno forma muy poco gluten: su miga se sostiene sobre todo por las pentosanas (gomas que retienen mucha agua) y necesita acidez para que el almidón no se degrade durante la cocción. Por eso el pan con mucho centeno se hace con masa madre.',
        'Masa pegajosa que no se amasa como la de trigo: se mezcla, se moldea con las manos mojadas y suele cocerse en molde o como hogaza baja.',
        'Con poco centeno (10-30 %) en una masa de trigo, aporta sabor y humedad sin cambiar mucho el proceso.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de panes de centeno; Cauvain, S., «Technology of Breadmaking» (Springer)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'espelta',
      seccion: 'harinas',
      titulo: 'Harina de espelta',
      parrafos: [
        'La espelta es un trigo (Triticum spelta). Su gluten es más extensible y menos tenaz que el del trigo común: la masa se desgarra si se amasa de más.',
        'Amasado más corto y suave, algo menos de agua que una harina de trigo de la misma extracción y no pasarse de fermentación.',
        'Un pan solo con harina de espelta puede llamarse «pan de espelta» (RD 308/2019 art. 4.4); si se mezcla con trigo hay que dar los porcentajes.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Real Decreto 308/2019 art. 4.4 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'absorcion',
      seccion: 'harinas',
      titulo: 'Absorción de agua',
      parrafos: [
        'Cada harina absorbe una cantidad distinta de agua: más con más proteína, más cenizas (integral, morena) y más almidón dañado; menos con harinas flojas. La misma receta con otra harina puede quedar blanda o dura.',
        'Al cambiar de harina o de saco, reserva un 5-10 % del agua y añádela poco a poco al final del amasado si la masa lo pide (en francés, bassinage).',
        'El molino da la absorción del farinógrafo en su ficha técnica: es la referencia para comparar harinas.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Cauvain, S., «Technology of Breadmaking» (Springer)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'miga_apelmazada',
      seccion: 'trucos',
      titulo: 'Miga apelmazada o húmeda',
      parrafos: [
        'Causas habituales: fermentación corta (sobre todo la final), masa demasiado fría, poco desarrollo del gluten, horno poco caliente o cortar el pan todavía caliente.',
        'Qué probar: comprobar la temperatura de la masa y alargar la fermentación hasta que la prueba del dedo dé el punto; precalentar más; cocer hasta la temperatura interna; esperar a que enfríe para cortar.',
        'En el centeno, la miga es densa por naturaleza: reposarlo 12-24 h antes de cortar.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Cauvain, S., «Technology of Breadmaking» (Springer)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'corteza_blanda',
      seccion: 'trucos',
      titulo: 'Corteza blanda o que se ablanda',
      parrafos: [
        'Causas: poco tiempo de horno, vapor durante toda la cocción, enfriar en bolsa o en un sitio húmedo, o una miga muy hidratada que suelta humedad hacia fuera.',
        'Qué probar: quitar el vapor a mitad de cocción, alargar el horno unos minutos (con la puerta entreabierta al final en horno doméstico), enfriar sobre rejilla y no embolsar hasta que esté frío del todo.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'corteza_palida',
      seccion: 'trucos',
      titulo: 'Corteza pálida',
      parrafos: [
        'Causas: horno poco caliente, falta de vapor al principio (la superficie se seca y no dora bien), o masa sobrefermentada que ha consumido sus azúcares.',
        'Qué probar: precalentar más tiempo y comprobar la temperatura con un termómetro de horno; dar vapor los primeros minutos; acortar la fermentación final. La fermentación en frío ayuda a dorar.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'pan_plano',
      seccion: 'trucos',
      titulo: 'Pan plano que se abre hacia los lados',
      parrafos: [
        'Causas: poca tensión al formar, sobrefermentación, masa demasiado hidratada para la harina, harina floja o poco desarrollo del gluten.',
        'Qué probar: formar con más tensión en la superficie, usar cesto o banneton, bajar algo el agua o subir la fuerza de la harina, dar más pliegues, y acortar la fermentación final.'
      ],
      calculadora: '',
      fuente: 'Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'grenado_no_abre',
      seccion: 'trucos',
      titulo: 'El greñado no abre',
      parrafos: [
        'Causas: corte poco profundo o vertical, masa sobrefermentada (no le queda fuerza para crecer en el horno), falta de vapor (la superficie se endurece antes de abrir) o una piel seca en la masa.',
        'Qué probar: cuchilla bien afilada e inclinada, cortar con decisión, cocer en el punto de la prueba del dedo, dar vapor y tapar la masa durante la fermentación para que no forme costra.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Calvel, R., «Le goût du pain» (Jérôme Villette)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'sobrefermentado',
      seccion: 'trucos',
      titulo: 'Masa sobrefermentada',
      parrafos: [
        'Señales: la masa se hunde o no vuelve al tocarla, huele muy alcohólica o muy ácida, la pieza se deshincha al greñar y sale plana con corteza pálida y alveolos grandes bajo la corteza.',
        'Qué hacer la próxima vez: menos levadura, masa más fría, menos tiempo o fermentación en frío. Con la masa ya pasada, cocerla cuanto antes y con cortes suaves; a veces puede volver a formarse y dejar una fermentación corta.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'subfermentado',
      seccion: 'trucos',
      titulo: 'Masa subfermentada',
      parrafos: [
        'Señales: la prueba del dedo vuelve enseguida, el pan revienta por los lados o por la base en el horno, la miga es densa con algunos agujeros grandes y la corteza muy oscura.',
        'Qué hacer: alargar la fermentación (sobre todo la final) o calentar la masa; comprobar que la levadura está viva y la masa madre en su pico.'
      ],
      calculadora: '',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.); Suas, M., «Advanced Bread and Pastry» (Delmar Cengage)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'masa_pegajosa',
      seccion: 'trucos',
      titulo: 'Masa pegajosa que no se maneja',
      parrafos: [
        'Al principio del amasado toda masa se pega: con el desarrollo del gluten se va despegando. No añadas harina enseguida.',
        'Si sigue pegajosa: puede faltar amasado o reposo (prueba la autólisis y los pliegues), sobrar agua para esa harina (reserva una parte del agua), estar la masa muy caliente, o ser una harina con mucho centeno o integral.',
        'Para manejarla: manos y rasqueta mojadas (o un poco de aceite) en vez de harina en la mesa.'
      ],
      calculadora: '',
      fuente: 'Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'sal_limite',
      seccion: 'trucos',
      titulo: 'Sal y máximo legal del pan común',
      parrafos: [
        'El pan común puede tener como máximo 1,31 g de sal por 100 g de pan (determinada por cloruros) o 1,66 g por 100 g si se calcula por el sodio total (RD 308/2019 art. 11.2.c). Se cuenta sobre el pan cocido, que pesa menos que la masa.',
        'Como orientación, con una masa de hidratación media y una merma de cocción del 15 %, en torno a un 1,8 % de sal sobre la harina queda cerca del límite; el 2 % habitual en recetas extranjeras lo supera. En piezas pequeñas (más merma) hace falta menos.',
        'La app estima la sal de cada receta con la merma que le pongas; la cifra legal la da el laboratorio.'
      ],
      calculadora: '',
      fuente: 'Real Decreto 308/2019 art. 11.2.c (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'nombres_requisitos',
      seccion: 'trucos',
      titulo: 'Nombres que tienen requisitos legales',
      parrafos: [
        'Algunas palabras del nombre del pan están reguladas por el RD 308/2019: «integral» (toda la harina integral, o el % al lado, arts. 4.3 y 14.1), «de centeno», «de espelta» y otros cereales (solo ese cereal, o los % de cada uno, art. 4.4), «multicereal» (art. 6), «elaborado con masa madre» (art. 14.5), «elaborado con larga fermentación» (art. 14.4), «de elaboración artesana» (arts. 10 y 14.3) y «pan de leña» (art. 14.6).',
        'El pan bregado, de miga dura o candeal exige cilindros refinadores (art. 4.1); sin ellos es pan de flama.',
        'Antes de usar una de estas palabras en una etiqueta, compruébalo con el texto consolidado en el BOE o con tu técnico.'
      ],
      calculadora: '',
      fuente:
          'Real Decreto 308/2019 arts. 4.1-4.4, 6, 10 y 14 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'conservacion',
      seccion: 'trucos',
      titulo: 'Conservación del pan',
      parrafos: [
        'El pan se endurece sobre todo porque el almidón de la miga se recristaliza (retrogradación), no solo porque se seque; ese proceso va más deprisa en la nevera que a temperatura ambiente.',
        'Para el día: en bolsa de tela o papel, con el corte hacia abajo. Las masas con masa madre, grasa o más hidratación tardan más en endurecerse.'
      ],
      calculadora: '',
      fuente:
          'Cauvain, S., «Technology of Breadmaking» (Springer); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'congelado',
      seccion: 'trucos',
      titulo: 'Congelar y regenerar',
      parrafos: [
        'Congelar el pan ya frío del todo, bien envuelto para que no se seque ni coja olores; mejor en piezas o rebanadas del tamaño que se vaya a usar.',
        'Para regenerarlo: descongelar envuelto y darle unos minutos de horno caliente para recuperar la corteza; las rebanadas pueden ir directas a la tostadora.',
        'Congelar pronto, el mismo día: el congelador para el endurecimiento, pero no lo revierte.'
      ],
      calculadora: '',
      fuente:
          'Cauvain, S., «Technology of Breadmaking» (Springer); Hamelman, J., «Bread» (Wiley, 2.ª ed.)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaObrador(
      id: 'conservas',
      seccion: 'trucos',
      titulo: 'Conservas y mermeladas: fuera de esta guía',
      parrafos: [
        'Esta guía no da tiempos ni temperaturas de tratamiento para conservas, mermeladas ni otros productos envasados: dependen del producto, del envase y del plan de autocontrol (APPCC) del obrador, y un error tiene consecuencias.',
        'Usa las indicaciones de tu autoridad sanitaria autonómica, de la AESAN y de tu técnico, y apunta los controles en Autocontrol.'
      ],
      calculadora: '',
      fuente:
          'Agencia Española de Seguridad Alimentaria y Nutrición (AESAN), aesan.gob.es; Reglamento (CE) 852/2004 relativo a la higiene de los productos alimenticios, art. 5 (APPCC)',
      revisadoPor: 'revision-ia: 2026-11-10'),
];
