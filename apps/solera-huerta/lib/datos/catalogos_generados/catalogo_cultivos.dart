// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/huerta/cultivos_huerta.csv
// Generado: 2026-11-10
// Filas: 42 (0 firmadas por persona, 33 con alguna revisión, 9 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-huerta && dart run tool/compilar_catalogos.dart

class CultivoCatalogo {
  const CultivoCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.familiaId,
    required this.cicloDias,
    required this.semanasCosecha,
    required this.marco,
    required this.porUnidades,
    required this.revisadoPor,
    required this.sensibleHelada,
    required this.fuenteHelada,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String familiaId;
  final int? cicloDias;
  final int? semanasCosecha;
  final String marco;
  final bool? porUnidades;
  final String revisadoPor;
  final bool? sensibleHelada;
  final String fuenteHelada;
}

const List<CultivoCatalogo> catalogoCultivos = [
  CultivoCatalogo(
      id: 'tomate',
      nombre: 'Tomate',
      nombreCientifico: 'Solanum lycopersicum',
      familiaId: 'solanaceas',
      cicloDias: 60,
      semanasCosecha: 10,
      marco: '30 x 80 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 39: «no soportan las heladas»; Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6: «cuando ya no hiela»'),
  CultivoCatalogo(
      id: 'pimiento',
      nombre: 'Pimiento',
      nombreCientifico: 'Capsicum annuum',
      familiaId: 'solanaceas',
      cicloDias: 50,
      semanasCosecha: 10,
      marco: '60 x 80 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 39: «no soportan las heladas»'),
  CultivoCatalogo(
      id: 'berenjena',
      nombre: 'Berenjena',
      nombreCientifico: 'Solanum melongena',
      familiaId: 'solanaceas',
      cicloDias: 60,
      semanasCosecha: 8,
      marco: '60 x 80 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2: «trasplantar cuando haya pasado el frío, ya que es exigente en calor»'),
  CultivoCatalogo(
      id: 'patata',
      nombre: 'Patata',
      nombreCientifico: 'Solanum tuberosum',
      familiaId: 'solanaceas',
      cicloDias: 70,
      semanasCosecha: 3,
      marco: '30 x 50 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 38: «los brotes tiernos [...] no soportan las heladas»'),
  CultivoCatalogo(
      id: 'calabacin',
      nombre: 'Calabacín',
      nombreCientifico: 'Cucurbita pepo',
      familiaId: 'cucurbitaceas',
      cicloDias: 30,
      semanasCosecha: 10,
      marco: '100 x 100 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: se siembra «para evitar las últimas heladas del año»'),
  CultivoCatalogo(
      id: 'pepino',
      nombre: 'Pepino',
      nombreCientifico: 'Cucumis sativus',
      familiaId: 'cucurbitaceas',
      cicloDias: 50,
      semanasCosecha: 8,
      marco: '80 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 38: se siembra «para evitar las últimas heladas del año»'),
  CultivoCatalogo(
      id: 'calabaza',
      nombre: 'Calabaza',
      nombreCientifico: 'Cucurbita maxima|Cucurbita moschata',
      familiaId: 'cucurbitaceas',
      cicloDias: 60,
      semanasCosecha: 4,
      marco: '120 x 120 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: se siembra «para evitar las últimas heladas del año»'),
  CultivoCatalogo(
      id: 'melon',
      nombre: 'Melón',
      nombreCientifico: 'Cucumis melo',
      familiaId: 'cucurbitaceas',
      cicloDias: 90,
      semanasCosecha: 4,
      marco: '100 x 100 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'sandia',
      nombre: 'Sandía',
      nombreCientifico: 'Citrullus lanatus',
      familiaId: 'cucurbitaceas',
      cicloDias: 100,
      semanasCosecha: 4,
      marco: '100 x 100 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'lechuga',
      nombre: 'Lechuga',
      nombreCientifico: 'Lactuca sativa',
      familiaId: 'asteraceas',
      cicloDias: 40,
      semanasCosecha: 2,
      marco: '25 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'escarola',
      nombre: 'Escarola',
      nombreCientifico: 'Cichorium endivia',
      familiaId: 'asteraceas',
      cicloDias: 70,
      semanasCosecha: 3,
      marco: '25 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'alcachofa',
      nombre: 'Alcachofa',
      nombreCientifico: 'Cynara cardunculus var. scolymus',
      familiaId: 'asteraceas',
      cicloDias: null,
      semanasCosecha: 8,
      marco: '100 x 100 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 del PDF (solo marco)',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'acelga',
      nombre: 'Acelga',
      nombreCientifico: 'Beta vulgaris var. cicla',
      familiaId: 'amarantaceas',
      cicloDias: 60,
      semanasCosecha: 8,
      marco: '30 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'espinaca',
      nombre: 'Espinaca',
      nombreCientifico: 'Spinacia oleracea',
      familiaId: 'amarantaceas',
      cicloDias: 50,
      semanasCosecha: 3,
      marco: '20 x 40 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'remolacha',
      nombre: 'Remolacha',
      nombreCientifico: 'Beta vulgaris',
      familiaId: 'amarantaceas',
      cicloDias: 60,
      semanasCosecha: 6,
      marco: '30 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'zanahoria',
      nombre: 'Zanahoria',
      nombreCientifico: 'Daucus carota',
      familiaId: 'apiaceas',
      cicloDias: 70,
      semanasCosecha: 6,
      marco: '15 x 20 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'apio',
      nombre: 'Apio',
      nombreCientifico: 'Apium graveolens',
      familiaId: 'apiaceas',
      cicloDias: 60,
      semanasCosecha: 6,
      marco: '30 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'chirivia',
      nombre: 'Chirivía',
      nombreCientifico: 'Pastinaca sativa',
      familiaId: 'apiaceas',
      cicloDias: 120,
      semanasCosecha: 6,
      marco: '10 x 30 cm',
      porUnidades: false,
      revisadoPor: '',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'perejil',
      nombre: 'Perejil',
      nombreCientifico: 'Petroselinum crispum',
      familiaId: 'apiaceas',
      cicloDias: 70,
      semanasCosecha: 12,
      marco: '15 x 25 cm',
      porUnidades: true,
      revisadoPor: '',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'cebolla',
      nombre: 'Cebolla',
      nombreCientifico: 'Allium cepa',
      familiaId: 'amarilidaceas',
      cicloDias: 75,
      semanasCosecha: 4,
      marco: '15 x 20 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: «soportan las heladas»'),
  CultivoCatalogo(
      id: 'cebolleta',
      nombre: 'Cebolleta',
      nombreCientifico: 'Allium cepa',
      familiaId: 'amarilidaceas',
      cicloDias: null,
      semanasCosecha: 3,
      marco: '15 x 20 cm',
      porUnidades: true,
      revisadoPor: '',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: «soportan las heladas»'),
  CultivoCatalogo(
      id: 'ajo',
      nombre: 'Ajo',
      nombreCientifico: 'Allium sativum',
      familiaId: 'amarilidaceas',
      cicloDias: null,
      semanasCosecha: 3,
      marco: '10 x 20 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 del PDF (solo marco)',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 35: «aguantar fríos extremos»'),
  CultivoCatalogo(
      id: 'puerro',
      nombre: 'Puerro',
      nombreCientifico: 'Allium porrum',
      familiaId: 'amarilidaceas',
      cicloDias: 90,
      semanasCosecha: 8,
      marco: '15 x 20 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'judia_verde',
      nombre: 'Judía verde',
      nombreCientifico: 'Phaseolus vulgaris',
      familiaId: 'fabaceas',
      cicloDias: 40,
      semanasCosecha: 6,
      marco: '20 x 50 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 del PDF',
      sensibleHelada: true,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37: «no soporta las heladas tardías»'),
  CultivoCatalogo(
      id: 'haba',
      nombre: 'Haba',
      nombreCientifico: 'Vicia faba',
      familiaId: 'fabaceas',
      cicloDias: null,
      semanasCosecha: 4,
      marco: '20 x 50 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 del PDF (solo marco)',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37: una vez germinadas «las soportan»; Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026: «una vez nacidas soportan las heladas»'),
  CultivoCatalogo(
      id: 'tirabeque',
      nombre: 'Tirabeque (bisalto)',
      nombreCientifico: 'Pisum sativum var. saccharatum',
      familiaId: 'fabaceas',
      cicloDias: null,
      semanasCosecha: 4,
      marco: '20 x 80 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 2 del PDF (solo marco)',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'guisante',
      nombre: 'Guisante',
      nombreCientifico: 'Pisum sativum',
      familiaId: 'fabaceas',
      cicloDias: 90,
      semanasCosecha: 4,
      marco: '5 x 60 cm',
      porUnidades: false,
      revisadoPor: '',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 37: una vez germinados «las soportan»'),
  CultivoCatalogo(
      id: 'coliflor',
      nombre: 'Coliflor',
      nombreCientifico: 'Brassica oleracea var. botrytis',
      familiaId: 'brasicaceas',
      cicloDias: 90,
      semanasCosecha: 2,
      marco: '60 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: las coles «soportan las heladas tardías»'),
  CultivoCatalogo(
      id: 'brocoli',
      nombre: 'Brócoli',
      nombreCientifico: 'Brassica oleracea var. italica',
      familiaId: 'brasicaceas',
      cicloDias: 90,
      semanasCosecha: 4,
      marco: '60 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'romanesco',
      nombre: 'Romanesco',
      nombreCientifico: 'Brassica oleracea var. botrytis',
      familiaId: 'brasicaceas',
      cicloDias: 90,
      semanasCosecha: 2,
      marco: '60 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'repollo',
      nombre: 'Repollo',
      nombreCientifico: 'Brassica oleracea var. capitata',
      familiaId: 'brasicaceas',
      cicloDias: 60,
      semanasCosecha: 3,
      marco: '50 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: las coles «soportan las heladas tardías»'),
  CultivoCatalogo(
      id: 'col_lombarda',
      nombre: 'Col lombarda',
      nombreCientifico: 'Brassica oleracea var. capitata f. rubra',
      familiaId: 'brasicaceas',
      cicloDias: 60,
      semanasCosecha: 3,
      marco: '50 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: las coles «soportan las heladas tardías»'),
  CultivoCatalogo(
      id: 'col_rizada',
      nombre: 'Col rizada (de Milán)',
      nombreCientifico: 'Brassica oleracea var. sabauda',
      familiaId: 'brasicaceas',
      cicloDias: 60,
      semanasCosecha: 3,
      marco: '50 x 80 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'kale',
      nombre: 'Kale',
      nombreCientifico: 'Brassica oleracea var. sabellica',
      familiaId: 'brasicaceas',
      cicloDias: 60,
      semanasCosecha: 12,
      marco: '40 x 60 cm',
      porUnidades: true,
      revisadoPor: '',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'col_bruselas',
      nombre: 'Col de Bruselas',
      nombreCientifico: 'Brassica oleracea var. gemmifera',
      familiaId: 'brasicaceas',
      cicloDias: 120,
      semanasCosecha: 8,
      marco: '50 x 80 cm',
      porUnidades: false,
      revisadoPor: '',
      sensibleHelada: false,
      fuenteHelada:
          'Ayto. Madrid, «Curso Huerto urbano ecológico», 4.ª ed. 2023, p. 36: las coles «soportan las heladas tardías»'),
  CultivoCatalogo(
      id: 'rabano',
      nombre: 'Rábano',
      nombreCientifico: 'Raphanus sativus',
      familiaId: 'brasicaceas',
      cicloDias: 45,
      semanasCosecha: 2,
      marco: '15 x 20 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 6 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'nabo',
      nombre: 'Nabo',
      nombreCientifico: 'Brassica rapa subsp. rapa',
      familiaId: 'brasicaceas',
      cicloDias: 60,
      semanasCosecha: 4,
      marco: '10 x 30 cm',
      porUnidades: true,
      revisadoPor: '',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'rucula',
      nombre: 'Rúcula',
      nombreCientifico: 'Eruca vesicaria subsp. sativa',
      familiaId: 'brasicaceas',
      cicloDias: 30,
      semanasCosecha: 3,
      marco: '5 x 20 cm',
      porUnidades: true,
      revisadoPor: '',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'maiz_dulce',
      nombre: 'Maíz dulce',
      nombreCientifico: 'Zea mays var. saccharata',
      familiaId: 'poaceas',
      cicloDias: 70,
      semanasCosecha: 2,
      marco: '20 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 5 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'fresa',
      nombre: 'Fresa',
      nombreCientifico: 'Fragaria × ananassa',
      familiaId: 'rosaceas',
      cicloDias: null,
      semanasCosecha: 8,
      marco: '30 x 40 cm',
      porUnidades: false,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 4 del PDF (solo marco)',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'canonigo',
      nombre: 'Canónigo',
      nombreCientifico: 'Valerianella locusta',
      familiaId: 'valerianaceas',
      cicloDias: 60,
      semanasCosecha: 4,
      marco: '10 x 15 cm',
      porUnidades: false,
      revisadoPor: '',
      sensibleHelada: null,
      fuenteHelada: ''),
  CultivoCatalogo(
      id: 'borraja',
      nombre: 'Borraja',
      nombreCientifico: 'Borago officinalis',
      familiaId: 'boraginaceas',
      cicloDias: 45,
      semanasCosecha: 4,
      marco: '30 x 40 cm',
      porUnidades: true,
      revisadoPor:
          'fuente_publica: Ayto. Zaragoza (RHEAZ), «Los cultivos del huerto escolar», 2026, p. 3 del PDF',
      sensibleHelada: null,
      fuenteHelada: ''),
];
