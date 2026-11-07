// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/rotacion.csv
// Generado: 2026-11-07
// Filas: 12 (0 firmadas por persona, 10 con alguna revisión, 2 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class FamiliaRotacionCatalogo {
  const FamiliaRotacionCatalogo({
    required this.familiaId,
    required this.nombre,
    required this.aniosMinimos,
    required this.ejemplos,
    required this.revisadoPor,
    required this.notas,
  });

  final String familiaId;
  final String nombre;
  final int? aniosMinimos;
  final String ejemplos;
  final String revisadoPor;
  final String notas;
}

const List<FamiliaRotacionCatalogo> catalogoRotacion = [
  FamiliaRotacionCatalogo(
      familiaId: 'solanaceas',
      nombre: 'Solanáceas',
      aniosMinimos: 4,
      ejemplos: 'tomate|pimiento|berenjena|patata',
      revisadoPor:
          'fuente_publica: Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15 (plan a cuatro años)',
      notas:
          'Las guías GIP de solanáceas (2021) y de patata (2015) piden rotar pero no dan años para la familia (patata: «rotación amplia», CE p. 33)'),
  FamiliaRotacionCatalogo(
      familiaId: 'cucurbitaceas',
      nombre: 'Cucurbitáceas',
      aniosMinimos: 4,
      ejemplos: 'calabacín|pepino|calabaza|melón|sandía',
      revisadoPor:
          'fuente_publica: Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15 (plan a cuatro años); Guía GIP cucurbitáceas MAPA 2023, F p. 142 (chancro gomoso: rotaciones de mínimo 2 años)',
      notas:
          'La guía GIP da 2 años como mínimo para el chancro gomoso; se toma el plan de 4'),
  FamiliaRotacionCatalogo(
      familiaId: 'asteraceas',
      nombre: 'Asteráceas (compuestas)',
      aniosMinimos: 4,
      ejemplos: 'lechuga|escarola|alcachofa',
      revisadoPor:
          'fuente_publica: Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15 (plan a cuatro años)',
      notas:
          'La alcachofa es plurianual: va en parcela aparte ([GAR] p. 3). La guía GIP de hortícolas de hoja no da años para la lechuga'),
  FamiliaRotacionCatalogo(
      familiaId: 'amarantaceas',
      nombre: 'Amarantáceas (quenopodiáceas)',
      aniosMinimos: 4,
      ejemplos: 'acelga|espinaca|remolacha',
      revisadoPor:
          'fuente_publica: Guía GIP hortícolas de hoja MAPA 2017, F p. 108 (mildiu: rotación de mínimo 3 años) y F p. 116 (cercospora: más de 3 años sin acelga, remolacha ni espinaca); Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15',
      notas: '«Más de 3 años» se redondea a 4'),
  FamiliaRotacionCatalogo(
      familiaId: 'apiaceas',
      nombre: 'Apiáceas (umbelíferas)',
      aniosMinimos: 4,
      ejemplos: 'zanahoria|chirivía|apio|perejil',
      revisadoPor:
          'fuente_publica: Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15 (plan a cuatro años: zanahoria)',
      notas: 'No se ha leído ninguna guía GIP de umbelíferas'),
  FamiliaRotacionCatalogo(
      familiaId: 'amarilidaceas',
      nombre: 'Amarilidáceas (liliáceas)',
      aniosMinimos: 4,
      ejemplos: 'cebolla|ajo|puerro|cebolleta',
      revisadoPor:
          'fuente_publica: Guía GIP liliáceas MAPA 2017, F p. 46 (mosca de la cebolla: al menos dos años sin liliáceas) y F p. 98 (roya: al menos 3 años); Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15',
      notas:
          'La guía GIP da 2-3 años según el problema; se toma el plan de 4. Con podredumbre blanca, la guía avisa de que ni rotaciones de 4 a 10 años bastan (los esclerocios duran hasta 18 años en el suelo, F p. 89-90)'),
  FamiliaRotacionCatalogo(
      familiaId: 'fabaceas',
      nombre: 'Fabáceas (leguminosas)',
      aniosMinimos: 4,
      ejemplos: 'judía verde|haba|guisante|tirabeque',
      revisadoPor:
          'fuente_publica: Guía GIP leguminosas MAPA 2021, F p. 118 (antracnosis: no volver a la judía en al menos 4 años) y F p. 165 (rabia del haba y el guisante: 3 años con cultivos no susceptibles); Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15',
      notas: ''),
  FamiliaRotacionCatalogo(
      familiaId: 'brasicaceas',
      nombre: 'Brasicáceas (crucíferas)',
      aniosMinimos: 4,
      ejemplos: 'col|coliflor|brócoli|repollo|kale|rábano|nabo|rúcula',
      revisadoPor:
          'fuente_publica: Guía GIP brásicas MAPA 2016, F p. 161 (nerviación negra: con daños previos, al menos 3 campañas sin crucíferas); Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15 (plan a cuatro años: coles, nabo, rabanito)',
      notas:
          'La guía GIP da 3 campañas; se toma el plan de 4. Con hernia de la col la guía pide quitar restos de crucíferas y corregir la acidez, sin cifra de años (F p. 152)'),
  FamiliaRotacionCatalogo(
      familiaId: 'poaceas',
      nombre: 'Poáceas (gramíneas)',
      aniosMinimos: 4,
      ejemplos: 'maíz dulce',
      revisadoPor:
          'fuente_publica: Ayto. Madrid, Curso Huerto urbano ecológico 2023, p. III-15 (plan a cuatro años: maíz)',
      notas: ''),
  FamiliaRotacionCatalogo(
      familiaId: 'rosaceas',
      nombre: 'Rosáceas',
      aniosMinimos: 4,
      ejemplos: 'fresa',
      revisadoPor:
          'fuente_publica: Ayto. Madrid, Guía de métodos de asociación y rotación de cultivos, p. 3 del PDF (plurianuales como la fresa: rotar al cabo de 4 o 5 años)',
      notas:
          'Plurianual: mejor en parcela aparte, fuera de la rotación anual. La guía GIP de fresa no da años'),
  FamiliaRotacionCatalogo(
      familiaId: 'valerianaceas',
      nombre: 'Valerianáceas',
      aniosMinimos: 4,
      ejemplos: 'canónigo',
      revisadoPor: '',
      notas:
          'Sin fuente leída: valor conservador propio. (En la clasificación actual el canónigo está en Caprifoliáceas)'),
  FamiliaRotacionCatalogo(
      familiaId: 'boraginaceas',
      nombre: 'Boragináceas',
      aniosMinimos: 4,
      ejemplos: 'borraja',
      revisadoPor: '',
      notas: 'Sin fuente leída: valor conservador propio'),
];
