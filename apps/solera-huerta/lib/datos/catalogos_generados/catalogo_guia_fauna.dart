// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/guia_fauna.csv
// Generado: 2026-11-10
// Filas: 17 (0 firmadas por persona, 17 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class FichaGuiaFauna {
  const FichaGuiaFauna({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.grupo,
    required this.queHace,
    required this.comoReconocerla,
    required this.comoAtraerla,
    required this.plagas,
    required this.fuente,
    required this.revisadoPor,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String grupo;
  final String queHace;
  final String comoReconocerla;
  final String comoAtraerla;
  final List<String> plagas;
  final String fuente;
  final String revisadoPor;
}

const List<FichaGuiaFauna> catalogoGuiaFauna = [
  FichaGuiaFauna(
      id: 'mariquitas',
      nombre: 'Mariquitas',
      nombreCientifico:
          'Coccinella septempunctata, Adalia bipunctata y otros coccinélidos',
      grupo: 'insecto',
      queHace:
          'Adultos y larvas comen pulgones (y algunas cochinillas). Las guías GIP del MAPA las citan entre los depredadores de pulgones en solanáceas y brásicas.',
      comoReconocerla:
          'Adultos de tamaño y manchas muy variables (de ninguna a más de veinte). La larva no se parece al adulto: alargada, de hasta 12 mm, gris oscura o negra con manchas naranjas o blancas, a veces con espinas. Los huevos amarillos del escarabajo de la patata se confunden con los suyos: mira bien antes de quitarlos.',
      comoAtraerla:
          'Sitios resguardados para pasar el invierno (la guía de Madrid propone refugios para mariquitas), tolerar algunos pulgones y flores como el hinojo o la milenrama.',
      plagas: ['pulgones'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; MAPA, Guía GIP de solanáceas, 2021, p. 30 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 109 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42 y 44; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'sirfidos',
      nombre: 'Sírfidos (moscas de las flores)',
      nombreCientifico: 'familia Syrphidae',
      grupo: 'insecto',
      queHace:
          'Muchas de sus larvas comen pulgones. Los adultos toman néctar y polen y polinizan.',
      comoReconocerla:
          'Adulto: mosca con rayas que se queda suspendida en el aire. Larva: gusano sin patas, aplanado, de hasta 12 mm y a menudo semitransparente, metido entre las colonias de pulgón. No la confundas con una plaga.',
      comoAtraerla:
          'Flores abiertas con polen y néctar (aliso marítimo, facelia, hinojo, milenrama, caléndula). Una cobertura de trébol entre las coles aumenta su acción contra el pulgón (guía GIP de brásicas).',
      plagas: ['pulgones'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; MAPA, Guía GIP de brásicas, 2016, p. 108-109 del PDF; USDA-ARS, «Flower Power Protects Organic Lettuce», Agricultural Research, enero 2014 (ensayos de E. B. Brennan, Biological Control 65, 2013); Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 9-10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'crisopas',
      nombre: 'Crisopas',
      nombreCientifico: 'Chrysoperla carnea y otras',
      grupo: 'insecto',
      queHace:
          'Sus larvas comen pulgones y otros insectos pequeños. Las guías GIP la citan también contra la mosca blanca y contra los huevos y las orugas recién nacidas de heliotis.',
      comoReconocerla:
          'Adulto verde pálido con alas transparentes muy venadas. Larva de hasta 8 mm, afilada por detrás y con mandíbulas curvas; algunas se tapan con pieles vacías de pulgón.',
      comoAtraerla:
          'Grietas, hojarasca y arbustos de hoja perenne para pasar el invierno; flores como caléndula, cosmos o milenrama (guía de Madrid).',
      plagas: ['pulgones', 'mosca_blanca', 'orugas_defoliadoras'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; MAPA, Guía GIP de solanáceas, 2021, p. 30, 31 y 34 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 9-10 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'avispillas_pulgon',
      nombre: 'Avispillas parasitoides del pulgón',
      nombreCientifico: 'Aphidius, Aphelinus, Lysiphlebus…',
      grupo: 'insecto',
      queHace:
          'Ponen un huevo dentro de cada pulgón y la larva se lo come desde dentro. Según la guía GIP de solanáceas, con más del 60 % de pulgones parasitados no hace falta intervenir.',
      comoReconocerla:
          'Son diminutas y casi no se ven. Lo que se ve son las «momias»: pulgones hinchados, pardos o blanquecinos, a veces con el agujerito por el que salió la avispa. No las quites.',
      comoAtraerla:
          'Flores con néctar y polen. Las guías GIP proponen plantas reservorio con pulgones propios que no atacan al cultivo (cereales, cerraja, ortigas).',
      plagas: ['pulgones'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; MAPA, Guía GIP de solanáceas, 2021, p. 30 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 109 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'parasitoides_mosca_blanca',
      nombre: 'Avispillas de la mosca blanca',
      nombreCientifico: 'Encarsia formosa, Eretmocerus mundus…',
      grupo: 'insecto',
      queHace:
          'Parasitan las larvas de la mosca blanca. Eretmocerus mundus es el más extendido en el Mediterráneo en otoño; Encarsia formosa actúa sobre la mosca blanca de invernadero.',
      comoReconocerla:
          'Casi invisibles a simple vista: trabajan en el envés de las hojas, donde están las larvas de mosca blanca.',
      comoAtraerla:
          'Las guías GIP piden favorecer la fauna auxiliar evitando tratamientos innecesarios y dejar zonas sin cultivar cerca de las parcelas como reservorio.',
      plagas: ['mosca_blanca'],
      fuente:
          'MAPA, Guía GIP de solanáceas, 2021, p. 13 y 31 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 117 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'orius',
      nombre: 'Chinches Orius',
      nombreCientifico: 'Orius laevigatus, O. majusculus y otros antocóridos',
      grupo: 'insecto',
      queHace:
          'Chinches pequeñas que cazan trips; también comen huevos y orugas recién nacidas de heliotis y, a veces, larvas de mosca blanca.',
      comoReconocerla:
          'Son muy pequeñas. No todas las chinches son plaga: ante la duda, observa antes de actuar.',
      comoAtraerla:
          'Plantas con flor y polen; la guía de Madrid dice que la caléndula atrae «chinches depredadoras».',
      plagas: ['trips', 'orugas_defoliadoras', 'mosca_blanca'],
      fuente:
          'MAPA, Guía GIP de hortícolas de hoja, 2017, p. 74 del PDF (trips); MAPA, Guía GIP de solanáceas, 2021, p. 34 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 117 del PDF; Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 9 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'miridos',
      nombre: 'Chinches míridas depredadoras',
      nombreCientifico: 'Nesidiocoris tenuis, Macrolophus pygmaeus',
      grupo: 'insecto',
      queHace:
          'Depredadores de la mosca blanca y de la polilla del tomate (Tuta absoluta) en las solanáceas, según la guía GIP.',
      comoReconocerla:
          'Chinches que viven sobre las tomateras y otras solanáceas: no todas las chinches son plaga.',
      comoAtraerla:
          'Evitar tratamientos que no hagan falta: la guía GIP cuenta con su instalación natural en el cultivo.',
      plagas: ['mosca_blanca', 'tuta_absoluta'],
      fuente:
          'MAPA, Guía GIP de solanáceas, 2021, p. 31 y 35 del PDF; MAPA, Guía GIP de brásicas, 2016, p. 117 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'acaros_fitoseidos',
      nombre: 'Ácaros depredadores (fitoseidos)',
      nombreCientifico:
          'Phytoseiulus persimilis, Neoseiulus californicus, Amblyseius swirskii…',
      grupo: 'acaro',
      queHace:
          'Comen araña roja; algunos, como Amblyseius, también trips y mosca blanca.',
      comoReconocerla:
          'Diminutos: hace falta lupa. Conviven con las colonias de araña roja en el envés.',
      comoAtraerla:
          'Necesitan humedad: por debajo del 50 % de humedad relativa sus huevos no eclosionan (guía GIP de solanáceas).',
      plagas: ['arana_roja', 'trips', 'mosca_blanca'],
      fuente:
          'MAPA, Guía GIP de solanáceas, 2021, p. 31 y 74 del PDF; MAPA, Guía GIP de hortícolas de hoja, 2017, p. 74 del PDF (trips)',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'cecidomidos',
      nombre: 'Mosquitas depredadoras de pulgón',
      nombreCientifico: 'Aphidoletes aphidimyza',
      grupo: 'insecto',
      queHace: 'Sus larvas chupan el contenido de los pulgones.',
      comoReconocerla:
          'Larvas naranja-amarillentas de hasta 3 mm entre los pulgones. El adulto es una mosquita diminuta; la larva pupa en el suelo.',
      comoAtraerla:
          'Los adultos se alimentan de melaza: tolerar algunos pulgones les ayuda.',
      plagas: ['pulgones'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; MAPA, Guía GIP de solanáceas, 2021, p. 30 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'carabidos',
      nombre: 'Carábidos y estafilínidos (escarabajos de suelo)',
      nombreCientifico: 'familias Carabidae y Staphylinidae',
      grupo: 'insecto',
      queHace:
          'Cazadores del suelo: comen insectos y larvas que viven en él. La guía GIP de brásicas los cita contra las larvas y los huevos de la mosca de la col; algunos trepan a las plantas a comer pulgones.',
      comoReconocerla:
          'Escarabajos de hasta 25 mm, a menudo negros y a veces metálicos, que corren por el suelo.',
      comoAtraerla: 'Montones de leña, hojarasca y compost.',
      plagas: ['pulgones'],
      fuente:
          'RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; MAPA, Guía GIP de brásicas, 2016, p. 71 del PDF',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'tijeretas',
      nombre: 'Tijeretas',
      nombreCientifico: 'Forficula auricularia',
      grupo: 'insecto',
      queHace:
          'Omnívoras: la guía de Madrid y la RHS las cuentan entre los enemigos de los pulgones.',
      comoReconocerla: 'Insecto alargado con dos pinzas al final del cuerpo.',
      comoAtraerla:
          'Refugios: macetas boca abajo rellenas de heno o paja colgadas en los árboles (RHS).',
      plagas: ['pulgones'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'aranas',
      nombre: 'Arañas',
      nombreCientifico: 'orden Araneae',
      grupo: 'aracnido',
      queHace:
          'Cazadoras de insectos. La guía de Madrid las cuenta entre la fauna auxiliar que acogen el hinojo y el romero.',
      comoReconocerla:
          'No confundir con la «araña roja», que es un ácaro diminuto que deja telillas en el envés de las hojas y las mancha.',
      comoAtraerla: 'Aromáticas como el romero las cobijan (guía de Madrid).',
      plagas: [],
      fuente:
          'Ayto. Madrid, «Guía de métodos de asociación y rotación de cultivos», p. 10 del PDF; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 43-44',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'abejas',
      nombre: 'Abejorros y abejas solitarias',
      nombreCientifico: 'Bombus spp. y otras abejas silvestres',
      grupo: 'insecto',
      queHace: 'Polinizadores: se alimentan de néctar y polen.',
      comoReconocerla:
          'Abejorros: peludos, redondos, con rayas. Hay cientos de especies de abejas solitarias (más de 260 solo en Gran Bretaña), muy distintas entre sí.',
      comoAtraerla:
          'Flores ricas en néctar y polen de marzo a octubre. Para anidar: agujeros en madera, tallos huecos o «hoteles» de abejas (limpia o cambia los tubos cada dos años a finales de verano) y taludes soleados con tierra desnuda; los abejorros anidan en agujeros del suelo o al pie de setos y árboles.',
      plagas: [],
      fuente:
          'RHS, «Beneficial insects and bugs», https://www.rhs.org.uk/wildlife/beneficial-insects-and-bugs; RHS, fichas de hábitats para la fauna del jardín (setos, charcas, prados), https://www.rhs.org.uk/wildlife/in-gardens',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'aves',
      nombre: 'Herrerillos y otras aves insectívoras',
      nombreCientifico: 'Cyanistes caeruleus y otras',
      grupo: 'ave',
      queHace:
          'Los herrerillos comen pulgones (RHS); la guía de Madrid propone atraer aves insectívoras contra los gusanos grises.',
      comoReconocerla:
          'Ojo: gorriones y otras aves también pican los plantones de lechuga y de coles recién trasplantados; protégelos esos días con una malla.',
      comoAtraerla:
          'Cajas nido y comederos (guía de Madrid); árboles y arbustos de ramas densas.',
      plagas: ['pulgones', 'gusanos_grises'],
      fuente:
          'RHS, «Aphid predators», https://www.rhs.org.uk/biodiversity/aphid-predators; Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42 y 44; Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 y 5 del PDF; RHS, «Kale: grow your own», https://www.rhs.org.uk/vegetables/kale/grow-your-own; RHS, fichas de hábitats para la fauna del jardín (setos, charcas, prados), https://www.rhs.org.uk/wildlife/in-gardens',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'murcielagos',
      nombre: 'Murciélagos',
      nombreCientifico: 'Pipistrellus y otros murciélagos insectívoros',
      grupo: 'mamifero',
      queHace:
          'Cazan insectos de noche, polillas incluidas. En el Delta del Ebro, el murciélago de Cabrera (Pipistrellus pygmaeus) come la polilla barrenadora del arroz, y la plaga bajó tras instalar cajas refugio.',
      comoReconocerla: '',
      comoAtraerla:
          'Cajas refugio para murciélagos; árboles y arbustos con ramas densas y huecos.',
      plagas: [],
      fuente:
          'Puig-Montserrat, X. et al. (2015), «Pest control service provided by bats in Mediterranean rice paddies», Mammalian Biology 80: 237-245; RHS, fichas de hábitats para la fauna del jardín (setos, charcas, prados), https://www.rhs.org.uk/wildlife/in-gardens',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'erizos',
      nombre: 'Erizos',
      nombreCientifico: 'Erinaceus europaeus',
      grupo: 'mamifero',
      queHace:
          'La guía de Madrid los cita entre los depredadores de caracoles y babosas.',
      comoReconocerla: '',
      comoAtraerla:
          'Refugios para erizos (guía de Madrid) y setos con hojarasca. Si hay zanjas o charcas, una rampa para que puedan salir. Revisa la hierba alta antes de desbrozarla.',
      plagas: ['caracoles_babosas'],
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 42-43; RHS, fichas de hábitats para la fauna del jardín (setos, charcas, prados), https://www.rhs.org.uk/wildlife/in-gardens',
      revisadoPor: 'revision-ia: 2026-11-10'),
  FichaGuiaFauna(
      id: 'sapos',
      nombre: 'Sapos y ranas',
      nombreCientifico: 'anfibios (orden Anura)',
      grupo: 'anfibio',
      queHace:
          'Comen babosas y caracoles (guía de Madrid; la RHS resume: «las ranas se comen las babosas»).',
      comoReconocerla: '',
      comoAtraerla:
          'Una charca para criar; refugios húmedos y a la sombra hechos con tejas viejas cubiertas de tierra y musgo, o troncos amontonados. Revisa la hierba antes de desbrozar.',
      plagas: ['caracoles_babosas'],
      fuente:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 43; RHS, fichas de hábitats para la fauna del jardín (setos, charcas, prados), https://www.rhs.org.uk/wildlife/in-gardens',
      revisadoPor: 'revision-ia: 2026-11-10'),
];
