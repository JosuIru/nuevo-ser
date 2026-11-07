// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/vivero/plagas_vivero.csv
// Generado: 2026-11-07
// Filas: 17 (0 firmadas por persona, 17 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-vivero && dart run tool/compilar_catalogos.dart

class PlagaCatalogo {
  const PlagaCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.sintomas,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final String sintomas;
}

const List<PlagaCatalogo> catalogoPlagas = [
  PlagaCatalogo(
      id: 'pulgones',
      nombre: 'Pulgones',
      nombreCientifico: 'Aphididae (Myzus persicae y otros)',
      tipo: 'plaga',
      sintomas: 'Colonias en brotes tiernos, hojas enrolladas, melaza'),
  PlagaCatalogo(
      id: 'mosca_blanca',
      nombre: 'Mosca blanca',
      nombreCientifico: 'Bemisia tabaci, Trialeurodes vaporariorum',
      tipo: 'plaga',
      sintomas:
          'Adultos blancos en el envés que vuelan al mover la planta; melaza y negrilla'),
  PlagaCatalogo(
      id: 'trips',
      nombre: 'Trips',
      nombreCientifico: 'Thysanoptera (Frankliniella occidentalis y otros)',
      tipo: 'plaga',
      sintomas:
          'Punteado plateado en hojas; flores deformadas; vectores de virus'),
  PlagaCatalogo(
      id: 'arana_roja',
      nombre: 'Araña roja',
      nombreCientifico: 'Tetranychus spp.',
      tipo: 'plaga',
      sintomas: 'Punteado amarillento, telillas finas en el envés'),
  PlagaCatalogo(
      id: 'minadores',
      nombre: 'Minadores de hoja',
      nombreCientifico: 'Liriomyza spp.',
      tipo: 'plaga',
      sintomas: 'Galerías serpenteantes en las hojas'),
  PlagaCatalogo(
      id: 'orugas',
      nombre: 'Orugas (lepidópteros)',
      nombreCientifico: 'Spodoptera, Helicoverpa, Agrotis y otros',
      tipo: 'plaga',
      sintomas:
          'Hojas comidas, excrementos, plántulas cortadas a ras de suelo'),
  PlagaCatalogo(
      id: 'procesionaria',
      nombre: 'Procesionaria',
      nombreCientifico: 'Thaumetopoea spp.',
      tipo: 'plaga',
      sintomas: 'Bolsones de seda en las puntas de las ramas; orugas en fila'),
  PlagaCatalogo(
      id: 'tuta_absoluta',
      nombre: 'Polilla del tomate',
      nombreCientifico: 'Tuta absoluta',
      tipo: 'plaga',
      sintomas: 'Minas en hojas y galerías en frutos de tomate'),
  PlagaCatalogo(
      id: 'babosas_caracoles',
      nombre: 'Babosas y caracoles',
      nombreCientifico: 'Gastropoda',
      tipo: 'plaga',
      sintomas: 'Hojas comidas con bordes irregulares y rastro de baba'),
  PlagaCatalogo(
      id: 'oidio',
      nombre: 'Oídio',
      nombreCientifico: 'Erysiphaceae (Erysiphe, Podosphaera, Leveillula)',
      tipo: 'enfermedad',
      sintomas: 'Polvo blanco en hojas y brotes'),
  PlagaCatalogo(
      id: 'mildiu',
      nombre: 'Mildiu',
      nombreCientifico:
          'Peronosporaceae (Peronospora, Bremia, Phytophthora infestans)',
      tipo: 'enfermedad',
      sintomas: 'Manchas aceitosas en el haz y pelusa grisácea en el envés'),
  PlagaCatalogo(
      id: 'botritis',
      nombre: 'Podredumbre gris',
      nombreCientifico: 'Botrytis cinerea',
      tipo: 'enfermedad',
      sintomas:
          'Podredumbre blanda con moho gris, sobre todo con humedad alta'),
  PlagaCatalogo(
      id: 'roya',
      nombre: 'Roya',
      nombreCientifico: 'Pucciniaceae',
      tipo: 'enfermedad',
      sintomas: 'Pústulas anaranjadas o pardas en el envés'),
  PlagaCatalogo(
      id: 'pythium',
      nombre: 'Caída de plántulas (Pythium)',
      nombreCientifico: 'Pythium spp.',
      tipo: 'enfermedad',
      sintomas: 'Plántulas que se doblan por el cuello, podredumbre de raíz'),
  PlagaCatalogo(
      id: 'rhizoctonia',
      nombre: 'Rhizoctonia',
      nombreCientifico: 'Rhizoctonia solani',
      tipo: 'enfermedad',
      sintomas: 'Lesiones pardas en el cuello; caída de plántulas'),
  PlagaCatalogo(
      id: 'phytophthora',
      nombre: 'Phytophthora',
      nombreCientifico: 'Phytophthora spp.',
      tipo: 'enfermedad',
      sintomas: 'Podredumbre de cuello y raíz; marchitez'),
  PlagaCatalogo(
      id: 'fusarium',
      nombre: 'Fusariosis',
      nombreCientifico: 'Fusarium spp.',
      tipo: 'enfermedad',
      sintomas: 'Marchitez y amarilleo; vasos pardos al cortar el tallo'),
];
