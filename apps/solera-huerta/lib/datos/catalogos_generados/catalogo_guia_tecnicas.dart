// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/guia_tecnicas.csv
// Generado: 2026-11-10
// Filas: 15 (0 firmadas por persona, 15 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class FichaGuiaTecnica {
  const FichaGuiaTecnica({
    required this.id,
    required this.titulo,
    required this.resumen,
    required this.pasos,
    required this.truco,
    required this.enlaceApp,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String titulo;
  final String resumen;
  final List<String> pasos;
  final String truco;
  final String enlaceApp;
  final String fuente;
  final String revisadoPor;
}

const List<FichaGuiaTecnica> catalogoGuiaTecnicas = [
  FichaGuiaTecnica(
      id: 'acolchado',
      titulo: 'Acolchado',
      resumen:
          'Cubrir el suelo con paja, hojas o compost mantiene la humedad, protege del sol y frena las hierbas.',
      pasos: [
        'Tras trasplantar en época cálida, acolcha: pierdes menos agua y salen menos hierbas',
        'Pimiento: acolchado de paja; berenjena: una buena capa de compost desde mayo',
        'Mantén el suelo cubierto todo el año, con cultivo, abono verde o acolchado'
      ],
      truco:
          'Compostaje laminar: sobre el bancal, capas de material verde tapadas siempre por otra de seco, de 30 cm como máximo; en 4-5 meses el bancal está listo para plantar.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 6 del PDF; Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 y 5 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 15, 24 y 31',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'compost',
      titulo: 'Compost',
      resumen:
          'Los restos del huerto y de la cocina se convierten en abono gracias a microorganismos que necesitan aire, humedad y una mezcla equilibrada.',
      pasos: [
        'Por cada pala de material seco (ramas finas, hojas secas, paja, cartón sin tinta), tres de material verde (restos de verdura, hierba, posos de café)',
        'Voltea dos o tres veces al mes para airearlo',
        'La primera semana sube a 50 °C y puede llegar a 70 °C: ese calor elimina patógenos y semillas',
        'Si huele a amoniaco, sobra verde: añade seco. Si no se calienta, falta verde. Si está seco, humedécelo'
      ],
      truco:
          'No eches carne, huesos, comida preparada ni excrementos de mascotas: atraen ratas.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 22-25',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'vermicompost',
      titulo: 'Vermicompost',
      resumen:
          'La lombriz roja convierte los restos de cocina en humus en un vermicompostador de bandejas.',
      pasos: [
        'Dos compartimentos comunicados y una tapa; abajo, papel de periódico o fibra de coco y 5 cm de estiércol fermentado o compost',
        'Unos 250 g de restos vegetales al día: verdura, cáscaras de huevo, posos de café (poco), papel sin tinta',
        'Nada de restos animales, comida preparada, papel satinado, muchos cítricos ni cebollas',
        'Humedad por encima del 60 % sin encharcar; siempre a la sombra (con más de 30 °C mueren) y resguardado con frío (por debajo de 5 °C)',
        'Para sacar el humus, pon comida en la bandeja de arriba: en unos días las lombrices suben'
      ],
      truco:
          'El humus está listo cuando es negro, esponjoso y se deshace en la mano.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 21',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'semillero',
      titulo: 'Semillero',
      resumen:
          'Sembrar en bandejas o macetas para tener planta fuerte cuando llegue el buen tiempo.',
      pasos: [
        'Bandejas alveoladas o envases reutilizados con agujeros abajo',
        'Sustrato: arena de río y compost fino a partes iguales, o fibra de coco con compost y algo de perlita; evita los sustratos con turba',
        'Entierra la semilla como mucho al doble de su tamaño',
        'Una o dos semillas por alveolo, sustrato siempre húmedo y 15-25 °C para germinar',
        'Al menos 6 horas de sol al día: si no, la planta se «ahíla» (tallo largo y débil)',
        'Etiqueta cada siembra con la fecha, la especie y la variedad'
      ],
      truco:
          'Si a los 15 días no ha nacido nada, el lote venía mal; apio y perejil pueden tardar hasta 30 días.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 28-29; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 4-5 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'endurecer_trasplantar',
      titulo: 'Endurecer y trasplantar',
      resumen: 'Pasar la planta del semillero al huerto sin que lo note.',
      pasos: [
        'Trasplanta con 3-4 hojas verdaderas y 10-15 cm de alto (en cebollas y puerros, con el grosor de un lápiz)',
        'Antes, endurece el plantel: sácalo al exterior cuando el tiempo lo permita para que se acostumbre al aire y al sol',
        'Trasplanta a primera hora o por la tarde, nunca con calor fuerte',
        'Hoyo algo mayor que el cepellón; el cuello sin enterrar, salvo en tomates y coles',
        'Riega abundante sin mojar las hojas, y acolcha si hace calor'
      ],
      truco:
          'Si todavía puede helar, pasa la plántula a una maceta mayor y déjala dentro: es el repicado.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 29; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 5-6 del PDF; RHS, «Kale: grow your own», https://www.rhs.org.uk/vegetables/kale/grow-your-own',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'semilla_propia',
      titulo: 'Guardar tu propia semilla',
      resumen:
          'Las variedades locales y ecológicas se pueden reproducir; las híbridas F1, no.',
      pasos: [
        'Evita las semillas F1 si quieres guardar semilla: su descendencia sale distinta y menos fértil',
        'Elige como portagranos las plantas más sanas',
        'Fáciles: judías y guisantes secos en la planta; lechuga, espinaca y acelga subidas a flor; la caléndula',
        'Puerro, cebolla, zanahoria y chirivía florecen y dan semilla al segundo año',
        'Se cruzan con facilidad: calabacín y calabaza entre sí (los hijos salen deformes) y las albahacas; judías de variedades distintas pueden mezclarse',
        'Tomate y pepino: fermenta la semilla tres días para quitar la gelatina, enjuágala y sécala',
        'Recoge en día seco y guarda en sobres de papel etiquetados (nombre y fecha), en sitio fresco y seco'
      ],
      truco:
          'Las semillas de cucurbitáceas, lechuga y berenjena germinan mejor con dos años. Y un calabacín o calabaza amargo no se come: es más probable en plantas de semilla propia cruzada.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 2 y 6 del PDF; RHS School Gardening, «Tips on saving your own seeds», https://www.rhs.org.uk/education-learning/school-gardening/resources/planet-friendly/tips-on-saving-your-own-seeds; RHS, «Courgette, marrow and squash problems», https://www.rhs.org.uk/problems/courgette-marrow-pumpkin-and-squash',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'riego',
      titulo: 'Riego: cuándo y cómo',
      resumen: 'Mantener la tierra húmeda pero con descansos para que respire.',
      pasos: [
        'Primavera y verano: muy temprano por la mañana o al anochecer, para perder menos agua y no quemar hojas',
        'Otoño e invierno: a media mañana (de diez a una), para que el agua no se hiele',
        'Mejor goteo que aspersión o manta: moja solo donde hace falta, salen menos hierbas y hay menos hongos en las hojas',
        'En macetas, riegos más frecuentes y pequeños',
        'Poco riego: ajo y cebolleta. Regular: tomate, pimiento, judía, zanahoria, pepino. Abundante: puerro, coles, apio, alcachofa, calabacín'
      ],
      truco:
          'Un acolchado mantiene la humedad, y con un programador el goteo riega aunque no estés.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 31-32',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'rotacion',
      titulo: 'Rotación de cultivos',
      resumen:
          'Cambiar cada año lo que va en cada bancal para no agotar el suelo ni acumular plagas y enfermedades.',
      pasos: [
        'No repitas familia botánica en el mismo sitio: comparten exigencias y plagas',
        'Tras los muy exigentes (frutos, coles, patata) vienen los de exigencia media (hojas, puerro) y luego los poco exigentes (raíces y leguminosas)',
        'Alterna raíces superficiales y profundas',
        'Mete leguminosas o un abono verde cada 3-4 años',
        'Las plurianuales (alcachofa, fresa, espárrago) van en una parcela aparte'
      ],
      truco:
          'La app lo hace por ti: la ficha del bancal dice qué familias no pueden volver todavía y te avisa al planificar una siembra. Abajo tienes los años mínimos que usa.',
      enlaceApp: 'rotacion',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 2-3 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 15',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'asociaciones',
      titulo: 'Asociaciones: qué hay de cierto',
      resumen:
          'Cultivar juntas plantas que se complementan funciona, pero muchas parejas famosas son tradición sin ensayos.',
      pasos: [
        'Con base: combinar ciclos cortos y largos, raíces y alturas distintas, y poner flores que alimentan a la fauna auxiliar',
        'Con ensayo o guía técnica: trébol entre coles (más sírfidos), aliso marítimo entre lechugas o tomates (sírfidos y parasitoides), la milpa de maíz, judía y calabaza',
        'Las tablas de «favorables» y «desfavorables» de esta guía vienen de la tradición hortícola (guía de Madrid): úsalas como orientación',
        'La RHS reconoce que buena parte de los beneficios se apoya en observaciones, no en estudios'
      ],
      truco:
          'Si pruebas una asociación, apúntalo en las notas de la siembra y compara con otro bancal.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 7 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 108 del PDF; USDA-ARS, «Flower Power Protects Organic Lettuce», Agricultural Research, enero 2014 (ensayos de E. B. Brennan, Biological Control 65, 2013); RHS, G. Barter, «Three ways to use companion planting», https://www.rhs.org.uk/advice/grow-your-own/features/companion-planting',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'bancales',
      titulo: 'Bancales: no pisar la tierra',
      resumen:
          'Organizar el huerto en bancales que se trabajan desde los pasillos evita apelmazar la tierra.',
      pasos: [
        'Bancales de 1,5 m de ancho como máximo y de 4 a 6 m de largo, con pasillos de 50 cm o más',
        'Elevados: echa la tierra de los pasillos sobre el bancal hasta 25-50 cm de alto',
        'O delimitados con maderas de 30-40 cm, para que nadie pise dentro',
        'Si prefieres caballones, 60-70 cm de centro a centro, mejor de este a oeste'
      ],
      truco:
          'Un huerto nuevo no tiene buen suelo: se consigue con los años, añadiendo materia orgánica.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 11-12',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'heladas',
      titulo: 'Heladas, frío y calor',
      resumen:
          'La temporada de cultivo va de la última helada de primavera a la primera de otoño.',
      pasos: [
        'Pregunta a quien cultiva en tu zona por las fechas de helada',
        'Los cultivos de verano (solanáceas y cucurbitáceas) no soportan heladas: semillero protegido y trasplante cuando ya no hiela',
        'Si siembras cuando aún puede helar, cubre con manta térmica y plástico',
        'Un minitúnel con arcos de tubo de riego y plástico o manta térmica, o una caja de poliespán con tapa, hacen de invernadero',
        'En verano, hojas como la rúcula agradecen media sombra'
      ],
      truco:
          'Refrán del manual de Madrid: «A la helada de abril, hambre ha de seguir»: no te adelantes con los cultivos de verano.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 10, 28 y 47; Ayto. Madrid, «Guía de reproducción de semilleros y planteles», p. 4 del PDF; RHS, «Salad leaves: grow your own», https://www.rhs.org.uk/vegetables/salad-leaves/grow-your-own',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'trampas_color',
      titulo: 'Trampas de color para vigilar',
      resumen:
          'Placas adhesivas que sirven para detectar a tiempo la llegada de una plaga.',
      pasos: [
        'Amarillas: detectan pulgones con alas y mosca blanca; se ponen desde el inicio del cultivo',
        'Azules: trips (en invernadero, según la guía GIP)',
        'Revísalas cada semana y apunta lo que veas como observación en la ficha del bancal'
      ],
      truco:
          'Una trampa con capturas es la señal para mirar las plantas con más atención, no para tratar.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42-43; MAPA, Guía GIP de solanáceas, 2021, p. 30-31 del PDF; MAPA, Guía GIP de hortícolas de hoja, 2017, p. 74 del PDF (trips)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'labores',
      titulo: 'Aclareo, aporcado y escarda',
      resumen:
          'Pequeñas labores que deciden el tamaño y la salud de la cosecha.',
      pasos: [
        'Aclarar: tras una siembra directa densa (zanahoria, rabanito), deja solo las plántulas más fuertes a su distancia',
        'Aporcar: arrimar tierra al tallo para que no se tumbe, tapar tubérculos que asoman (patata) o blanquear (puerro, apio, escarola)',
        'Binar: romper la costra de la superficie para que entren el agua y el aire',
        'Escardar: arranca la hierba entera, con raíz'
      ],
      truco:
          'Antes de escardar, mira qué hierbas salen: ortigas y hierba mora indican un suelo rico en nitrógeno; ranúnculos, acederas y llantenes, un suelo pesado.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 32-33',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'abono_verde',
      titulo: 'Abono verde',
      resumen:
          'Sembrar plantas que no se cosechan sino que se entierran para mejorar el suelo.',
      pasos: [
        'Siembra en otoño, tras los cultivos de verano, o de febrero a abril para preparar la primavera',
        'Mezcla habitual: leguminosa (veza, guisante, trébol) con gramínea (avena, centeno, cebada)',
        'Siega al empezar a florecer, lo más a ras posible',
        'Entierra superficialmente (10-15 cm) o déjalo como acolchado; en suelos pesados y húmedos, deja que se seque dos semanas antes'
      ],
      truco: 'Las especies concretas están en «Plantas que ayudan».',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 4-5 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 25',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaTecnica(
      id: 'refugios_fauna',
      titulo: 'Refugios para la fauna auxiliar',
      resumen:
          'La fauna que controla las plagas necesita dónde vivir y pasar el invierno.',
      pasos: [
        'Cajas nido para aves insectívoras y refugios para erizos y mariquitas',
        'Montones de leña, hojarasca y compost para escarabajos de suelo y otros cazadores',
        'Deja tallos secos y flores que granen para los insectos que pasan el invierno',
        'Zonas sin cultivar cerca del huerto: son reservorio de fauna auxiliar',
        'Evita herbicidas, fungicidas e insecticidas'
      ],
      truco:
          'Las plagas suelen crecer en primavera antes de que lleguen sus enemigos naturales: un poco de paciencia les da tiempo.',
      enlaceApp: '',
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42; RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; RHS, fichas de hábitats para la fauna del jardín (setos, charcas, prados), https://www.rhs.org.uk/wildlife/in-gardens; RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; MAPA, Guía GIP de solanáceas, 2021, p. 13 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
];
