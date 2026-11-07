// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/plagas_huerta.csv
// Generado: 2026-11-07
// Filas: 32 (0 firmadas por persona, 27 con alguna revisión, 5 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class PlagaCatalogo {
  const PlagaCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.familias,
    required this.sintomas,
    required this.seguimiento,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final List<String> familias;
  final String sintomas;
  final String seguimiento;
  final String revisadoPor;
}

const List<PlagaCatalogo> catalogoPlagas = [
  PlagaCatalogo(
      id: 'pulgones',
      nombre: 'Pulgones',
      nombreCientifico:
          'Myzus persicae, Aphis gossypii, Aphis fabae, Macrosiphum euphorbiae, Nasonovia ribisnigri y otros',
      tipo: 'plaga',
      familias: [
        'solanaceas',
        'cucurbitaceas',
        'asteraceas',
        'fabaceas',
        'brasicaceas',
        'amarantaceas',
        'rosaceas'
      ],
      sintomas:
          'Colonias en brotes y hojas jóvenes; hojas enrolladas y deformadas, amarilleo y retraso del crecimiento; melaza y negrilla; transmiten virus',
      seguimiento:
          'Muestreos durante todo el cultivo, sobre todo en los bordes y cerca de puertas; trampas adhesivas amarillas para detectar los alados; vigilar el parasitismo',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 29 y F p. 83-85; Guía GIP hortícolas de hoja MAPA 2017, CE p. 30 y F p. 75-76; Guía GIP leguminosas MAPA 2021, CE p. 30 y F p. 93-95; Guía GIP cucurbitáceas MAPA 2023, CE p. 29; Guía GIP fresa y fresón MAPA 2019, CE p. 30; Guía GIP brásicas MAPA 2016, CE p. 34-35'),
  PlagaCatalogo(
      id: 'mosca_blanca',
      nombre: 'Moscas blancas',
      nombreCientifico:
          'Trialeurodes vaporariorum, Bemisia tabaci y Aleyrodes proletella (coles)',
      tipo: 'plaga',
      familias: ['solanaceas', 'cucurbitaceas', 'fabaceas', 'brasicaceas'],
      sintomas:
          'Larvas y adultos en el envés chupan savia: debilitamiento, clorosis y secado de hojas; melaza y negrilla; B. tabaci transmite el virus de la cuchara del tomate',
      seguimiento:
          'Muestreos durante todo el cultivo en el envés de las hojas; trampas adhesivas amarillas',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 30 y F p. 89-91; Guía GIP cucurbitáceas MAPA 2023, CE p. 30; Guía GIP leguminosas MAPA 2021, CE p. 29; Guía GIP brásicas MAPA 2016, CE p. 36'),
  PlagaCatalogo(
      id: 'arana_roja',
      nombre: 'Araña roja',
      nombreCientifico: 'Tetranychus spp.',
      tipo: 'plaga',
      familias: ['solanaceas', 'cucurbitaceas', 'fabaceas', 'rosaceas'],
      sintomas:
          'Punteado o manchas amarillentas en el haz de las hojas; con muchas, desecación y caída de hojas; sedas que cubren las colonias. Ataques en focos',
      seguimiento:
          'Muestreos periódicos durante todo el cultivo cerca de las malas hierbas y donde hubo ataques otros años',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 28 y F p. 71-72; Guía GIP cucurbitáceas MAPA 2023, CE p. 27; Guía GIP leguminosas MAPA 2021, CE p. 27; Guía GIP fresa y fresón MAPA 2019, CE p. 28'),
  PlagaCatalogo(
      id: 'trips',
      nombre: 'Trips',
      nombreCientifico: 'Frankliniella occidentalis y Thrips tabaci',
      tipo: 'plaga',
      familias: [
        'solanaceas',
        'cucurbitaceas',
        'asteraceas',
        'amarilidaceas',
        'fabaceas',
        'rosaceas'
      ],
      sintomas:
          'Tejido plateado o blanquecino que luego se necrosa en hojas y frutos; punteaduras de puesta en frutos; F. occidentalis transmite el virus del bronceado (TSWV)',
      seguimiento:
          'Revisar las flores y el envés de las hojas; trampas cromotrópicas azules o amarillas durante todo el ciclo',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 35 y F p. 125-126; Guía GIP liliáceas MAPA 2017, CE p. 28; Guía GIP hortícolas de hoja MAPA 2017, CE p. 29; Guía GIP cucurbitáceas MAPA 2023, CE p. 34; Guía GIP leguminosas MAPA 2021, CE p. 31; Guía GIP fresa y fresón MAPA 2019, CE p. 29'),
  PlagaCatalogo(
      id: 'tuta_absoluta',
      nombre: 'Polilla del tomate',
      nombreCientifico: 'Tuta absoluta',
      tipo: 'plaga',
      familias: ['solanaceas'],
      sintomas:
          'Galerías de las larvas en hojas (primero estrechas, luego anchas y secas), frutos y tallos',
      seguimiento:
          'Trampas para seguir el vuelo de adultos y observación directa de daños en la parcela',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 34 y F p. 119-121'),
  PlagaCatalogo(
      id: 'orugas_defoliadoras',
      nombre: 'Orugas (rosquillas y heliotis)',
      nombreCientifico:
          'Spodoptera exigua, Spodoptera littoralis, Helicoverpa armigera, Autographa gamma, Chrysodeixis chalcites',
      tipo: 'plaga',
      familias: [
        'solanaceas',
        'cucurbitaceas',
        'asteraceas',
        'fabaceas',
        'rosaceas'
      ],
      sintomas:
          'Comeduras en hojas (al principio respetan los nervios), pérdida de hoja; Helicoverpa hace cavidades en frutos junto al pedúnculo, con podredumbres',
      seguimiento:
          'Observación directa, sobre todo al principio del cultivo, cerca de hierbas silvestres y donde hubo otros años; trampas de feromona o de luz para el inicio del vuelo',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 32-33 y F p. 107-109 y 113-114; Guía GIP hortícolas de hoja MAPA 2017, CE p. 29; Guía GIP cucurbitáceas MAPA 2023, CE p. 31-32; Guía GIP leguminosas MAPA 2021, CE p. 28; Guía GIP fresa y fresón MAPA 2019, CE p. 27'),
  PlagaCatalogo(
      id: 'gusanos_grises',
      nombre: 'Gusanos grises',
      nombreCientifico: 'Agrotis spp.',
      tipo: 'plaga',
      familias: [
        'solanaceas',
        'asteraceas',
        'amarantaceas',
        'cucurbitaceas',
        'brasicaceas'
      ],
      sintomas:
          'Comeduras en el cuello y las raíces; en plántulas, tallo cortado del todo',
      seguimiento:
          'Observación de síntomas al principio del cultivo, cerca de hierbas silvestres y donde hubo otros años; trampas de feromona o de luz para el vuelo',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 31 y F p. 101-102; Guía GIP hortícolas de hoja MAPA 2017, CE p. 28; Guía GIP cucurbitáceas MAPA 2023, CE p. 33; Guía GIP patata MAPA 2015, CE p. 28; Guía GIP brásicas MAPA 2016, CE p. 27'),
  PlagaCatalogo(
      id: 'gusano_alambre',
      nombre: 'Gusano de alambre',
      nombreCientifico: 'Agriotes spp.',
      tipo: 'plaga',
      familias: ['solanaceas', 'asteraceas', 'amarantaceas'],
      sintomas:
          'Plántulas que se marchitan y mueren por una mordedura en la base del tallo; raíces y tubérculos con galerías',
      seguimiento:
          'Trampas de feromona para los adultos; cebos de patata troceada enterrada a unos 15 cm para las larvas',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, CE p. 27 y F p. 53-54; Guía GIP patata MAPA 2015, CE p. 27'),
  PlagaCatalogo(
      id: 'escarabajo_patata',
      nombre: 'Escarabajo de la patata',
      nombreCientifico: 'Leptinotarsa decemlineata',
      tipo: 'plaga',
      familias: ['solanaceas'],
      sintomas:
          'Larvas y adultos devoran la parte aérea; puede quedar solo el tallo',
      seguimiento:
          'Recorrer la parcela mirando el envés de los foliolos (puestas) y las larvas, visibles a simple vista',
      revisadoPor:
          'fuente_publica: Guía GIP patata MAPA 2015, CE p. 27 y F p. 49-50'),
  PlagaCatalogo(
      id: 'pulguilla_acelga',
      nombre: 'Pulguilla de la acelga y la remolacha',
      nombreCientifico: 'Chaetocnema tibialis',
      tipo: 'plaga',
      familias: ['amarantaceas'],
      sintomas:
          'Agujeros redondos de unos 2 mm en las hojas; daño mucho mayor en plantas muy jóvenes',
      seguimiento:
          'Inspección visual de adultos y daños en los periodos críticos',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, CE p. 32 y F p. 91-92'),
  PlagaCatalogo(
      id: 'mosca_remolacha',
      nombre: 'Mosca de la remolacha',
      nombreCientifico: 'Pegomyia betae',
      tipo: 'plaga',
      familias: ['amarantaceas'],
      sintomas:
          'Galerías en las hojas; en ataques fuertes, lagunas blanquecinas; a veces se ven las larvas al trasluz',
      seguimiento:
          'Observar galerías en las hojas; conocer los antecedentes de la parcela',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, CE p. 31 y F p. 87-88'),
  PlagaCatalogo(
      id: 'mosca_cebolla',
      nombre: 'Mosca de la cebolla',
      nombreCientifico: 'Delia antiqua',
      tipo: 'plaga',
      familias: ['amarilidaceas'],
      sintomas:
          'Larvas de primavera matan plántulas de cebolla; la segunda generación come los bulbos, que luego se pudren',
      seguimiento:
          'Trampas adhesivas, sobre todo en parcelas con daños en cultivos anteriores',
      revisadoPor:
          'fuente_publica: Guía GIP liliáceas MAPA 2017, CE p. 27 y F p. 45-46'),
  PlagaCatalogo(
      id: 'mosca_zanahoria',
      nombre: 'Mosca de la zanahoria',
      nombreCientifico: 'Psila rosae',
      tipo: 'plaga',
      familias: ['apiaceas'],
      sintomas:
          'Galerías de las larvas en la raíz; follaje rojizo y plantas atrasadas',
      seguimiento: 'Trampas adhesivas amarillas o naranjas',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'caracoles_babosas',
      nombre: 'Caracoles y babosas',
      nombreCientifico:
          'Helix sp., Theba sp., Limax sp., Deroceras sp. y otros',
      tipo: 'plaga',
      familias: [
        'brasicaceas',
        'asteraceas',
        'amarantaceas',
        'fabaceas',
        'rosaceas'
      ],
      sintomas:
          'Hojas mordisqueadas y brotes de plantas jóvenes comidos; marcas de baba seca plateada; excrementos que deprecian la cosecha',
      seguimiento:
          'Vigilar todo el ciclo, sobre todo con 15-20 °C y humedad alta (lluvias de primavera y otoño); revisión al menos semanal',
      revisadoPor:
          'fuente_publica: Guía GIP brásicas MAPA 2016, CE p. 39 y F p. 127-128 (solo coles; para el resto de familias no se ha leído fuente)'),
  PlagaCatalogo(
      id: 'mariposa_col',
      nombre: 'Mariposas de la col (orugas)',
      nombreCientifico: 'Pieris brassicae y Pieris rapae',
      tipo: 'plaga',
      familias: ['brasicaceas'],
      sintomas:
          'Orugas defoliadoras que agujerean las hojas y pueden dejar solo los nervios; en el cogollo perforan las hojas tiernas',
      seguimiento:
          'Presencia y porcentaje de orugas en el cultivo, al menos cada semana; trampas de feromona para los vuelos (primavera a otoño)',
      revisadoPor:
          'fuente_publica: Guía GIP brásicas MAPA 2016, CE p. 29 y F p. 77-78'),
  PlagaCatalogo(
      id: 'pulguilla_col',
      nombre: 'Pulguillas de las coles',
      nombreCientifico:
          'Phyllotreta nemorum, Phyllotreta cruciferae, Psylliodes sp.',
      tipo: 'plaga',
      familias: ['brasicaceas'],
      sintomas:
          'Agujeritos redondos de 1-2 mm en hojas tiernas y cotiledones; graves en semilleros y plantas jóvenes con tiempo cálido y seco',
      seguimiento:
          'Presencia y porcentaje de la plaga en el cultivo, al menos cada semana',
      revisadoPor:
          'fuente_publica: Guía GIP brásicas MAPA 2016, CE p. 37 y F p. 119-120'),
  PlagaCatalogo(
      id: 'hernia_col',
      nombre: 'Hernia de la col',
      nombreCientifico: 'Plasmodiophora brassicae',
      tipo: 'enfermedad',
      familias: ['brasicaceas'],
      sintomas:
          'Engrosamientos (hernias) en las raíces, claros al principio y luego negros y podridos; hojas que se marchitan a mediodía y se recuperan de noche; plantas atrasadas',
      seguimiento:
          'Comprobar las raíces al trasplante (sobre todo planta a raíz desnuda) y al principio del cultivo, en especial en suelos ácidos y frescos',
      revisadoPor:
          'fuente_publica: Guía GIP brásicas MAPA 2016, CE p. 44 y F p. 151-152'),
  PlagaCatalogo(
      id: 'mildiu_tomate_patata',
      nombre: 'Mildiu del tomate y la patata',
      nombreCientifico: 'Phytophthora infestans',
      tipo: 'enfermedad',
      familias: ['solanaceas'],
      sintomas:
          'Manchas aceitosas en hojas que se necrosan deprisa, con fieltro blanquecino en el envés; manchas pardas vítreas en frutos verdes; en patata, podredumbre seca rojiza del tubérculo',
      seguimiento:
          'Muestreos durante todo el cultivo en hojas, tallos y frutos; en patata, las primeras manchas suelen salir en hojas superiores o tallos',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 38 y F p. 147-148; Guía GIP patata MAPA 2015, CE p. 31 y F p. 81'),
  PlagaCatalogo(
      id: 'alternaria_solanaceas',
      nombre: 'Alternaria de las solanáceas',
      nombreCientifico: 'Alternaria solani',
      tipo: 'enfermedad',
      familias: ['solanaceas'],
      sintomas:
          'Manchas pardas circulares con anillos concéntricos y halo amarillo en hojas; chancro en el cuello de plantas jóvenes; frutos con lesiones oscuras y moho negro desde el cáliz',
      seguimiento:
          'Muestreos durante todo el cultivo en hojas, tallos y frutos; más sensible tras el trasplante y al engordar el fruto',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 38 y F p. 151-152; Guía GIP patata MAPA 2015, CE p. 32'),
  PlagaCatalogo(
      id: 'botritis',
      nombre: 'Podredumbre gris',
      nombreCientifico: 'Botrytis cinerea',
      tipo: 'enfermedad',
      familias: [
        'solanaceas',
        'cucurbitaceas',
        'asteraceas',
        'fabaceas',
        'amarilidaceas',
        'rosaceas'
      ],
      sintomas:
          'Podredumbres blandas cubiertas de moho gris en hojas, flores, tallos y frutos; caída de flores; marchitez por encima de lesiones del tallo',
      seguimiento:
          'Muestreos durante todo el cultivo en hojas, flores, tallos y frutos',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 38 y F p. 155-156; Guía GIP hortícolas de hoja MAPA 2017, CE p. 33; Guía GIP cucurbitáceas MAPA 2023, CE p. 37; Guía GIP leguminosas MAPA 2021, CE p. 34; Guía GIP liliáceas MAPA 2017, CE p. 30 (podredumbre del cuello); Guía GIP fresa y fresón MAPA 2019, CE p. 38'),
  PlagaCatalogo(
      id: 'oidiopsis',
      nombre: 'Oidiopsis',
      nombreCientifico: 'Leveillula taurica',
      tipo: 'enfermedad',
      familias: ['solanaceas'],
      sintomas:
          'Manchas amarillas entre nervios en el haz que se necrosan por el centro; fieltro blanquecino en el envés. Empieza en la parte baja y media de la planta',
      seguimiento: 'Muestreos durante todo el cultivo, en las hojas',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 40 y F p. 171-172'),
  PlagaCatalogo(
      id: 'oidio_cucurbitaceas',
      nombre: 'Oídio de las cucurbitáceas',
      nombreCientifico: 'Podosphaera fusca y Golovinomyces cichoracearum',
      tipo: 'enfermedad',
      familias: ['cucurbitaceas'],
      sintomas:
          'Manchas blancas pulverulentas en haz y envés que crecen hasta cubrir la planta (aspecto de ceniza); tallos y peciolos afectados se secan',
      seguimiento:
          'Observar plantas con síntomas; en invernadero, muestreos durante todo el cultivo',
      revisadoPor:
          'fuente_publica: Guía GIP cucurbitáceas MAPA 2023, CE p. 38 y F p. 145-146'),
  PlagaCatalogo(
      id: 'mildiu_cucurbitaceas',
      nombre: 'Mildiu de las cucurbitáceas',
      nombreCientifico: 'Pseudoperonospora cubensis',
      tipo: 'enfermedad',
      familias: ['cucurbitaceas'],
      sintomas:
          'Solo en hojas: manchas angulosas verde claro que amarillean, con fieltro gris violáceo en el envés; luego se necrosan',
      seguimiento:
          'Muestreos durante todo el cultivo en hojas, tallos y frutos',
      revisadoPor:
          'fuente_publica: Guía GIP cucurbitáceas MAPA 2023, CE p. 39 y F p. 149-150'),
  PlagaCatalogo(
      id: 'mildiu_lechuga',
      nombre: 'Mildiu de la lechuga',
      nombreCientifico: 'Bremia lactucae',
      tipo: 'enfermedad',
      familias: ['asteraceas'],
      sintomas:
          'Zonas amarillas en cotiledones; en plantas mayores, manchas amarillas limitadas por los nervios con masa blanquecina en el envés que pasan a marrones',
      seguimiento:
          'Vigilar las condiciones favorables (lluvia, invernadero) para decidir al inicio y durante los periodos de riesgo',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, CE p. 34 y F p. 103-104'),
  PlagaCatalogo(
      id: 'mildiu_acelga_espinaca',
      nombre: 'Mildiu de la acelga y la espinaca',
      nombreCientifico: 'Peronospora farinosa',
      tipo: 'enfermedad',
      familias: ['amarantaceas'],
      sintomas:
          'Manchas verde claro a amarillas en hojas viejas; hojas del cogollo engrosadas y oscuras; fieltro gris violáceo en el envés',
      seguimiento:
          'En los periodos de máximo riesgo, revisar las plantas para ver los primeros síntomas',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, CE p. 34 y F p. 107-108'),
  PlagaCatalogo(
      id: 'cercospora',
      nombre: 'Cercospora de la acelga y la remolacha',
      nombreCientifico: 'Cercospora beticola',
      tipo: 'enfermedad',
      familias: ['amarantaceas'],
      sintomas:
          'Manchas redondeadas marrón pálido a gris con halo pardo rojizo; capa gris con humedad; hojas que se secan',
      seguimiento:
          'Observación visual: las primeras infecciones son puntos rojizos en las hojas de fuera',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, CE p. 35 y F p. 115-116'),
  PlagaCatalogo(
      id: 'roya_ajo_puerro',
      nombre: 'Roya del ajo y el puerro',
      nombreCientifico: 'Puccinia porri',
      tipo: 'enfermedad',
      familias: ['amarilidaceas'],
      sintomas:
          'Manchas blanquecinas redondas en hojas y tallos sobre las que salen pústulas naranjas de 1-3 mm; luego telios oscuros',
      seguimiento:
          'Recorrer la parcela buscando rodales con síntomas en las hojas más jóvenes',
      revisadoPor:
          'fuente_publica: Guía GIP liliáceas MAPA 2017, CE p. 32 y F p. 97-98'),
  PlagaCatalogo(
      id: 'nematodos_agallas',
      nombre: 'Nematodos de agallas',
      nombreCientifico: 'Meloidogyne spp.',
      tipo: 'plaga',
      familias: ['solanaceas', 'cucurbitaceas', 'asteraceas', 'fabaceas'],
      sintomas:
          'Rodales de plantas atrasadas o amarillas; síntomas aéreos poco específicos; agallas en las raíces',
      seguimiento:
          'Antes de plantar, análisis de suelo; durante el cultivo, vigilar síntomas; al final, mirar las raíces',
      revisadoPor:
          'fuente_publica: Guía GIP solanáceas MAPA 2021, CE p. 36 y F p. 131-133; Guía GIP hortícolas de hoja MAPA 2017, CE p. 38; Guía GIP cucurbitáceas MAPA 2023, CE p. 35; Guía GIP leguminosas MAPA 2021, CE p. 32'),
  PlagaCatalogo(
      id: 'podredumbre_apical',
      nombre: 'Podredumbre apical (carencia de calcio)',
      nombreCientifico: '',
      tipo: 'carencia',
      familias: ['solanaceas', 'cucurbitaceas'],
      sintomas:
          'Mancha parda o negra, hundida y seca en la punta del fruto (tomate, pimiento)',
      seguimiento:
          'Vigilar los primeros frutos, sobre todo con riego irregular o calor',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'clorosis_ferrica',
      nombre: 'Clorosis férrica',
      nombreCientifico: '',
      tipo: 'carencia',
      familias: [
        'solanaceas',
        'cucurbitaceas',
        'amarantaceas',
        'rosaceas',
        'fabaceas'
      ],
      sintomas:
          'Hojas jóvenes amarillas con los nervios verdes; frecuente en suelos calizos',
      seguimiento:
          'Mirar las hojas nuevas; análisis de suelo (caliza activa, pH)',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'carencia_nitrogeno',
      nombre: 'Carencia de nitrógeno',
      nombreCientifico: '',
      tipo: 'carencia',
      familias: [
        'solanaceas',
        'cucurbitaceas',
        'asteraceas',
        'amarantaceas',
        'brasicaceas',
        'poaceas'
      ],
      sintomas:
          'Amarilleo general que empieza por las hojas viejas; plantas pequeñas y poco vigorosas',
      seguimiento:
          'Comparar el color y el vigor entre bancales; análisis de suelo',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'carencia_magnesio',
      nombre: 'Carencia de magnesio',
      nombreCientifico: '',
      tipo: 'carencia',
      familias: ['solanaceas', 'cucurbitaceas', 'amarantaceas', 'brasicaceas'],
      sintomas:
          'Amarilleo entre los nervios en las hojas viejas, que siguen con los nervios verdes',
      seguimiento: 'Mirar las hojas viejas; análisis de suelo o foliar',
      revisadoPor: ''),
];
