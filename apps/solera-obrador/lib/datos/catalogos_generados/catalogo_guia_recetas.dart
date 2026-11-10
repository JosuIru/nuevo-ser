// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/obrador/guia_recetas.csv
// Generado: 2026-11-10
// Filas: 10 (0 firmadas por persona, 10 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

class RecetaGuia {
  const RecetaGuia({
    required this.id,
    required this.nombre,
    required this.denominacion,
    required this.esSubreceta,
    required this.hidratacionPorcentaje,
    required this.temperaturaMasaGrados,
    required this.mermaCoccionPorcentaje,
    required this.autolisis,
    required this.amasado,
    required this.primeraFermentacion,
    required this.formado,
    required this.fermentacionFinal,
    required this.coccion,
    required this.senalHecho,
    required this.notas,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String denominacion;
  final bool esSubreceta;
  final double hidratacionPorcentaje;
  final double temperaturaMasaGrados;
  final double mermaCoccionPorcentaje;
  final String autolisis;
  final String amasado;
  final String primeraFermentacion;
  final String formado;
  final String fermentacionFinal;
  final String coccion;
  final String senalHecho;
  final String notas;
  final String fuente;
  final String revisadoPor;
}

const List<RecetaGuia> catalogoGuiaRecetas = [
  RecetaGuia(
      id: 'rustico',
      nombre: 'Pan rústico de flama',
      denominacion: 'pan_comun',
      esSubreceta: false,
      hidratacionPorcentaje: 68.0,
      temperaturaMasaGrados: 24.0,
      mermaCoccionPorcentaje: 15.0,
      autolisis:
          'Opcional: 20-30 min solo con harina y agua, antes de la sal y la levadura',
      amasado:
          'Hasta desarrollo medio: la masa se despega del bol y estira una membrana algo irregular. 2-3 pliegues durante la primera fermentación completan el desarrollo',
      primeraFermentacion:
          '1,5-2 h a 24 °C, hasta que casi doble y esté abombada; más lenta si la masa está más fría',
      formado:
          'Dividir, bolear suave, reposar 15-20 min tapado y formar hogaza o barra con tensión en la superficie',
      fermentacionFinal:
          '45-75 min a 24 °C, hasta que la prueba del dedo deje una huella que vuelve despacio',
      coccion:
          'Horno a 240-250 °C con vapor los primeros 10-15 min; luego sin vapor a 220-230 °C. Unos 35-45 min una pieza de 700-800 g',
      senalHecho:
          'Corteza bien dorada, suena hueco al golpear la base; centro de la miga en torno a 96 °C',
      notas:
          'Pan de flama: más agua que el pan bregado y sin cilindros refinadores (RD 308/2019 art. 4.2). Con 1,8 % de sal sobre harina y una merma de cocción del 15 % queda bajo el máximo de sal del pan común; con 2 % lo superaría',
      fuente:
          'Hamelman, J., «Bread: A Baker\'s Book of Techniques and Recipes» (Wiley, 2.ª ed.); Real Decreto 308/2019 arts. 4.2 y 11.2.c (BOE-A-2019-6994); Cook\'s Illustrated, «Visual Guide to Judging Bread Doneness»',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'chapata',
      nombre: 'Chapata',
      denominacion: 'pan_comun',
      esSubreceta: false,
      hidratacionPorcentaje: 78.0,
      temperaturaMasaGrados: 24.0,
      mermaCoccionPorcentaje: 15.0,
      autolisis:
          'Recomendable: 20-30 min con harina y agua; ayuda a manejar una masa tan hidratada',
      amasado:
          'En amasadora a velocidad lenta y luego media; con masa tan blanda, mejor amasado corto y 3-4 pliegues en el bol cada 30 min',
      primeraFermentacion:
          '2-3 h a 24 °C con los pliegues, hasta que la masa esté hinchada y con burbujas visibles',
      formado:
          'Volcar sobre la mesa bien enharinada, cortar rectángulos sin desgasificar ni bolear; sin formado propiamente dicho',
      fermentacionFinal:
          '30-45 min sobre tela enharinada, con el lado enharinado hacia arriba',
      coccion:
          'Horno a 240-250 °C con vapor los primeros 10 min; 20-30 min en total según tamaño',
      senalHecho:
          'Corteza fina y dorada, piezas ligeras al levantarlas; miga en torno a 96 °C',
      notas:
          'Masa muy hidratada (alveolo grande e irregular). Se mancha mucho: harina abundante en la mesa y manos mojadas. Puede hacerse con poolish o biga (ver Fermentación)',
      fuente:
          'Hamelman, J., «Bread: A Baker\'s Book of Techniques and Recipes» (Wiley, 2.ª ed.), capítulo de ciabatta; Real Decreto 308/2019 art. 4.2 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'baguette',
      nombre: 'Barra tipo baguette',
      denominacion: 'pan_comun',
      esSubreceta: false,
      hidratacionPorcentaje: 68.0,
      temperaturaMasaGrados: 24.0,
      mermaCoccionPorcentaje: 20.0,
      autolisis:
          'Opcional: 20-30 min, técnica descrita por Raymond Calvel para este pan',
      amasado:
          'Amasado moderado: la masa queda lisa sin llegar al máximo desarrollo; 1-2 pliegues en la fermentación',
      primeraFermentacion:
          '1,5-2 h a 24 °C (o 12-16 h en frío si se usa menos levadura)',
      formado:
          'Dividir en piezas de 250-350 g, preformar en cilindro, reposar 15-20 min y alargar sin desgasificar del todo',
      fermentacionFinal:
          '45-60 min en tela con pliegues (couche), hasta que la prueba del dedo deje huella que vuelve despacio',
      coccion:
          'Greñar con varios cortes oblicuos y casi paralelos al eje; 240-250 °C con vapor los primeros 10 min, 20-25 min en total',
      senalHecho:
          'Corteza dorada y crujiente que cruje al enfriar; miga en torno a 96 °C',
      notas:
          'Pieza fina: pierde más agua al cocer, por eso la merma estimada es mayor y la sal más baja (1,6 % sobre harina) para no pasar del máximo del pan común. «Baguette» no es una denominación del RD 308/2019: es un pan de flama',
      fuente:
          'Calvel, R., «Le goût du pain» (Jérôme Villette); Hamelman, J., «Bread» (Wiley, 2.ª ed.); Real Decreto 308/2019 arts. 4.2 y 11.2.c (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'integral',
      nombre: 'Pan integral de trigo',
      denominacion: 'pan_integral',
      esSubreceta: false,
      hidratacionPorcentaje: 75.0,
      temperaturaMasaGrados: 25.0,
      mermaCoccionPorcentaje: 15.0,
      autolisis:
          'Recomendable: 30-60 min; el salvado se hidrata y la masa se maneja mejor',
      amasado:
          'Más corto y suave que una masa blanca; el salvado corta la red de gluten. Desarrollo medio',
      primeraFermentacion:
          '1,5-2 h a 25 °C; aumenta menos de volumen que una masa blanca',
      formado: 'Bolear o formar en molde con suavidad',
      fermentacionFinal:
          '45-60 min a 25 °C; no dejar que se pase: el salvado debilita la estructura',
      coccion:
          'Horno a 230-240 °C con vapor los primeros 10-15 min, luego 210-220 °C; unos 40-50 min una pieza de 800 g',
      senalHecho:
          'Corteza oscura, base que suena hueco; miga en torno a 96-98 °C',
      notas:
          'Solo con harina integral (si se mezcla con harina blanca deja de ser «pan integral»: hay que poner «elaborado con harina integral X %», RD 308/2019 arts. 4.3 y 14.1). La harina integral absorbe más agua: añade la última parte poco a poco',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de panes integrales; Real Decreto 308/2019 arts. 4.3 y 14.1 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'centeno',
      nombre: 'Pan de centeno',
      denominacion: 'pan_un_cereal',
      esSubreceta: false,
      hidratacionPorcentaje: 80.0,
      temperaturaMasaGrados: 28.0,
      mermaCoccionPorcentaje: 15.0,
      autolisis: 'No se usa: el centeno apenas forma gluten',
      amasado:
          'Solo mezclar hasta que esté homogénea (pegajosa, como un barro espeso); amasar más no la mejora',
      primeraFermentacion: '30-60 min a 28 °C tras mezclar',
      formado:
          'Con manos mojadas, formar sin buscar tensión o pasar a molde engrasado',
      fermentacionFinal:
          '40-60 min a 28 °C; está lista cuando aparecen grietas finas en la superficie',
      coccion:
          'Horno a 250 °C 10-15 min y luego 200-210 °C; unos 50-70 min una pieza de 1 kg en molde',
      senalHecho:
          'Base que suena hueco; reposar 12-24 h antes de cortar porque la miga sigue asentándose',
      notas:
          'Toda la harina de centeno, también la de la masa madre (refréscala con centeno): «pan de centeno» exige un solo cereal (RD 308/2019 art. 4.4). La acidez de la masa madre es lo que permite una miga estable en el centeno',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de panes de centeno; Real Decreto 308/2019 art. 4.4 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'molde',
      nombre: 'Pan de molde',
      denominacion: 'pan_especial',
      esSubreceta: false,
      hidratacionPorcentaje: 65.0,
      temperaturaMasaGrados: 26.0,
      mermaCoccionPorcentaje: 10.0,
      autolisis: 'No suele usarse',
      amasado:
          'Amasar hasta la prueba de la ventana (membrana fina y translúcida); la mantequilla se añade cuando la masa ya tiene cuerpo',
      primeraFermentacion: '1-1,5 h a 26 °C, hasta que doble',
      formado:
          'Desgasificar, formar un cilindro apretado (o dos bolas) y meter en el molde engrasado con la unión abajo',
      fermentacionFinal:
          '45-75 min a 26-28 °C, hasta que la masa asome por el borde del molde',
      coccion:
          'Horno a 180-200 °C sin vapor, 30-40 min un molde de 900 g; desmoldar enseguida',
      senalHecho:
          'Paredes doradas al desmoldar; centro de la miga en torno a 88-90 °C',
      notas:
          'Es pan especial: lleva leche, grasa y azúcar y se cuece en molde (RD 308/2019 arts. 5 y 11.3). Hidratación = agua + leche',
      fuente:
          'Suas, M., «Advanced Bread and Pastry» (Delmar Cengage); Real Decreto 308/2019 arts. 5 y 11.3 (BOE-A-2019-6994); Cook\'s Illustrated, «Visual Guide to Judging Bread Doneness»',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'brioche',
      nombre: 'Brioche',
      denominacion: 'pan_especial',
      esSubreceta: false,
      hidratacionPorcentaje: 60.0,
      temperaturaMasaGrados: 24.0,
      mermaCoccionPorcentaje: 10.0,
      autolisis: 'No se usa',
      amasado:
          'Amasar harina, huevo, leche, azúcar, sal y levadura hasta buen desarrollo; luego la mantequilla fría en trozos, poco a poco, hasta que la masa vuelva a despegarse. Vigilar que no pase de 24-26 °C',
      primeraFermentacion:
          '1 h a temperatura ambiente y después 8-16 h en nevera: la masa fría se forma mucho mejor',
      formado: 'Dividir y formar en frío (bolas, trenza o molde)',
      fermentacionFinal:
          '1,5-3 h a 26-28 °C (no más: la mantequilla se derrite), hasta que casi doble',
      coccion:
          'Pintar con huevo; horno a 170-180 °C sin vapor, 15-20 min piezas pequeñas y 30-40 min un molde grande',
      senalHecho: 'Color caoba uniforme; centro en torno a 88-90 °C',
      notas:
          'Masa enriquecida (mucha mantequilla y huevo): pan especial (RD 308/2019 art. 11.3). Hidratación = huevo + leche. Si se dora deprisa, cubrir con papel',
      fuente:
          'Suas, M., «Advanced Bread and Pastry» (Delmar Cengage); Hamelman, J., «Bread» (Wiley, 2.ª ed.); Real Decreto 308/2019 art. 11.3 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'focaccia',
      nombre: 'Focaccia',
      denominacion: 'pan_especial',
      esSubreceta: false,
      hidratacionPorcentaje: 75.0,
      temperaturaMasaGrados: 25.0,
      mermaCoccionPorcentaje: 12.0,
      autolisis: 'Opcional: 20-30 min',
      amasado:
          'Amasado corto y 3-4 pliegues durante la fermentación; el aceite se añade al final del amasado',
      primeraFermentacion: '1,5-2 h a 25 °C (o 12-24 h en nevera)',
      formado:
          'Extender en bandeja con aceite, sin forzar: si encoge, esperar 10-15 min y volver a estirar',
      fermentacionFinal:
          '30-60 min en la bandeja; hundir los dedos hasta el fondo justo antes de cocer y regar con aceite',
      coccion: 'Horno a 220-230 °C sin vapor, 20-25 min en bandeja',
      senalHecho: 'Base dorada y crujiente al levantarla con una espátula',
      notas:
          'Lleva aceite en la masa: pan especial (RD 308/2019 art. 11.3). El aceite de la bandeja y de encima no está en los porcentajes; añádelo a la receta si quieres contar su coste',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de focaccia; Real Decreto 308/2019 art. 11.3 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'empanada',
      nombre: 'Masa de empanada',
      denominacion: '',
      esSubreceta: true,
      hidratacionPorcentaje: 45.0,
      temperaturaMasaGrados: 24.0,
      mermaCoccionPorcentaje: 10.0,
      autolisis: 'No se usa',
      amasado:
          'Mezclar hasta una masa lisa y elástica que no se pegue a las manos; si hace falta, un poco más de agua o de harina',
      primeraFermentacion: '45-60 min tapada, hasta que crezca algo',
      formado:
          'Dividir en dos (base algo mayor que la tapa) y estirar fina con el rodillo',
      fermentacionFinal: '20-30 min ya rellena y cerrada, antes de pintarla',
      coccion:
          'Pintar con huevo y hacer un agujero en la tapa; horno a 180-200 °C, unos 35-45 min según tamaño',
      senalHecho:
          'Tapa y base doradas; la base no debe quedar pálida ni húmeda',
      notas:
          'Se guarda como subreceta (base para empanadas y empanadillas). El aceite puede ser el del sofrito del relleno. No es pan: no lleva denominación',
      fuente:
          'Consumer Eroski, «Las empanadas gallegas» (consumer.es); recetas de masa de empanada gallega publicadas en medios de cocina con harina, agua, aceite, sal y levadura en proporciones similares',
      revisadoPor: 'revision-ia: 2026-11-10'),
  RecetaGuia(
      id: 'masa_madre',
      nombre: 'Hogaza elaborada con masa madre',
      denominacion: 'pan_comun',
      esSubreceta: false,
      hidratacionPorcentaje: 72.0,
      temperaturaMasaGrados: 25.0,
      mermaCoccionPorcentaje: 15.0,
      autolisis:
          'Recomendable: 30-60 min con harina y agua antes de añadir la masa madre y la sal',
      amasado:
          'Desarrollo medio con 3-4 pliegues cada 30-45 min en la primera fermentación',
      primeraFermentacion:
          '3-5 h a 25 °C (más si hace frío), hasta que la masa crezca un 50-75 % y esté abombada y con burbujas',
      formado:
          'Preformar en bola, reposar 20-30 min y formar con tensión; al banneton enharinado con la unión arriba',
      fermentacionFinal:
          '1-3 h a 25 °C, o 8-16 h en nevera a unos 4 °C (se cuece directamente de la nevera)',
      coccion:
          'Greñar; olla de hierro precalentada a 250 °C, 20 min tapada y 20-25 min destapada a 230 °C',
      senalHecho:
          'Corteza oscura, base que suena hueco; miga en torno a 96-98 °C',
      notas:
          'Masa madre al 20 % de la harina (en el pico de actividad) y sin levadura: cumple el mínimo del 5 % de la mención «elaborado con masa madre» (RD 308/2019 art. 14.5), pero la mención exige además pH y acidez que solo un análisis confirma, y no admite aditivos. No llamarlo «de larga fermentación» si no cumple el art. 14.4',
      fuente:
          'Hamelman, J., «Bread» (Wiley, 2.ª ed.), capítulo de masa madre; Real Decreto 308/2019 arts. 14.4 y 14.5 (BOE-A-2019-6994)',
      revisadoPor: 'revision-ia: 2026-11-10'),
];
