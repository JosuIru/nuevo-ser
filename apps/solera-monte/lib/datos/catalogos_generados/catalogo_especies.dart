// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/monte/especies_forestales.csv
// Generado: 2026-11-07
// Filas: 41 (0 firmadas por persona, 41 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-monte && dart run tool/compilar_catalogos.dart

class EspecieForestal {
  const EspecieForestal({
    required this.id,
    required this.codigoIfn,
    required this.nombre,
    required this.nombreCientifico,
    required this.grupo,
    required this.revisadoPor,
  });

  final String id;
  final String codigoIfn;
  final String nombre;
  final String nombreCientifico;
  final String grupo;
  final String revisadoPor;
}

const List<EspecieForestal> catalogoEspecies = [
  EspecieForestal(
      id: 'pinus_sylvestris',
      codigoIfn: '021',
      nombre: 'Pino albar o silvestre',
      nombreCientifico: 'Pinus sylvestris',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'pinus_uncinata',
      codigoIfn: '022',
      nombre: 'Pino negro',
      nombreCientifico: 'Pinus uncinata',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'pinus_pinea',
      codigoIfn: '023',
      nombre: 'Pino piñonero',
      nombreCientifico: 'Pinus pinea',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'pinus_halepensis',
      codigoIfn: '024',
      nombre: 'Pino carrasco',
      nombreCientifico: 'Pinus halepensis',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'pinus_nigra',
      codigoIfn: '025',
      nombre: 'Pino salgareño',
      nombreCientifico: 'Pinus nigra',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'pinus_pinaster',
      codigoIfn: '026',
      nombre: 'Pino resinero o negral',
      nombreCientifico: 'Pinus pinaster',
      grupo: 'conifera',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68'),
  EspecieForestal(
      id: 'pinus_canariensis',
      codigoIfn: '027',
      nombre: 'Pino canario',
      nombreCientifico: 'Pinus canariensis',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'pinus_radiata',
      codigoIfn: '028',
      nombre: 'Pino insigne',
      nombreCientifico: 'Pinus radiata',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre ESMA 2025 p. 35'),
  EspecieForestal(
      id: 'abies_alba',
      codigoIfn: '031',
      nombre: 'Abeto',
      nombreCientifico: 'Abies alba',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'abies_pinsapo',
      codigoIfn: '032',
      nombre: 'Pinsapo',
      nombreCientifico: 'Abies pinsapo',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'picea_abies',
      codigoIfn: '033',
      nombre: 'Pícea',
      nombreCientifico: 'Picea abies',
      grupo: 'conifera',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68'),
  EspecieForestal(
      id: 'pseudotsuga_menziesii',
      codigoIfn: '034',
      nombre: 'Pino de Oregón',
      nombreCientifico: 'Pseudotsuga menziesii',
      grupo: 'conifera',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68'),
  EspecieForestal(
      id: 'larix_decidua',
      codigoIfn: '235',
      nombre: 'Alerce europeo',
      nombreCientifico: 'Larix decidua',
      grupo: 'conifera',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 71'),
  EspecieForestal(
      id: 'cedrus_atlantica',
      codigoIfn: '017',
      nombre: 'Cedro del Atlas',
      nombreCientifico: 'Cedrus atlantica',
      grupo: 'conifera',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 67'),
  EspecieForestal(
      id: 'juniperus_thurifera',
      codigoIfn: '038',
      nombre: 'Sabina albar',
      nombreCientifico: 'Juniperus thurifera',
      grupo: 'conifera',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'taxus_baccata',
      codigoIfn: '014',
      nombre: 'Tejo',
      nombreCientifico: 'Taxus baccata',
      grupo: 'conifera',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 67'),
  EspecieForestal(
      id: 'quercus_robur',
      codigoIfn: '041',
      nombre: 'Roble pedunculado',
      nombreCientifico: 'Quercus robur',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68'),
  EspecieForestal(
      id: 'quercus_petraea',
      codigoIfn: '042',
      nombre: 'Roble albar',
      nombreCientifico: 'Quercus petraea',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68'),
  EspecieForestal(
      id: 'quercus_pyrenaica',
      codigoIfn: '043',
      nombre: 'Melojo o rebollo',
      nombreCientifico: 'Quercus pyrenaica',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'quercus_faginea',
      codigoIfn: '044',
      nombre: 'Quejigo',
      nombreCientifico: 'Quercus faginea',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 68; nombre p. 30'),
  EspecieForestal(
      id: 'quercus_ilex',
      codigoIfn: '045',
      nombre: 'Encina',
      nombreCientifico: 'Quercus ilex ssp. ballota',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69; nombre p. 30'),
  EspecieForestal(
      id: 'quercus_suber',
      codigoIfn: '046',
      nombre: 'Alcornoque',
      nombreCientifico: 'Quercus suber',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69; nombre p. 30'),
  EspecieForestal(
      id: 'quercus_pubescens',
      codigoIfn: '243',
      nombre: 'Roble pubescente',
      nombreCientifico: 'Quercus pubescens',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 71'),
  EspecieForestal(
      id: 'quercus_rubra',
      codigoIfn: '048',
      nombre: 'Roble americano',
      nombreCientifico: 'Quercus rubra',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69'),
  EspecieForestal(
      id: 'fagus_sylvatica',
      codigoIfn: '071',
      nombre: 'Haya',
      nombreCientifico: 'Fagus sylvatica',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 70; nombre p. 30'),
  EspecieForestal(
      id: 'castanea_sativa',
      codigoIfn: '072',
      nombre: 'Castaño',
      nombreCientifico: 'Castanea sativa',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 70; nombre p. 30'),
  EspecieForestal(
      id: 'betula_alba',
      codigoIfn: '273',
      nombre: 'Abedul',
      nombreCientifico: 'Betula alba',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 72; nombre p. 30'),
  EspecieForestal(
      id: 'corylus_avellana',
      codigoIfn: '074',
      nombre: 'Avellano',
      nombreCientifico: 'Corylus avellana',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 70; nombre p. 30'),
  EspecieForestal(
      id: 'ilex_aquifolium',
      codigoIfn: '065',
      nombre: 'Acebo',
      nombreCientifico: 'Ilex aquifolium',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69; nombre p. 30'),
  EspecieForestal(
      id: 'arbutus_unedo',
      codigoIfn: '068',
      nombre: 'Madroño',
      nombreCientifico: 'Arbutus unedo',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69; nombre p. 30'),
  EspecieForestal(
      id: 'olea_europaea',
      codigoIfn: '066',
      nombre: 'Acebuche',
      nombreCientifico: 'Olea europaea',
      grupo: 'frondosa',
      revisadoPor:
          'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69; nombre p. 30'),
  EspecieForestal(
      id: 'fraxinus_excelsior',
      codigoIfn: '255',
      nombre: 'Fresno común',
      nombreCientifico: 'Fraxinus excelsior',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 71'),
  EspecieForestal(
      id: 'fraxinus_angustifolia',
      codigoIfn: '055',
      nombre: 'Fresno de hoja estrecha',
      nombreCientifico: 'Fraxinus angustifolia',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69'),
  EspecieForestal(
      id: 'alnus_glutinosa',
      codigoIfn: '054',
      nombre: 'Aliso',
      nombreCientifico: 'Alnus glutinosa',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69'),
  EspecieForestal(
      id: 'populus_nigra',
      codigoIfn: '058',
      nombre: 'Chopo',
      nombreCientifico: 'Populus nigra',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69'),
  EspecieForestal(
      id: 'acer_pseudoplatanus',
      codigoIfn: '576',
      nombre: 'Arce blanco',
      nombreCientifico: 'Acer pseudoplatanus',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 74'),
  EspecieForestal(
      id: 'sorbus_aucuparia',
      codigoIfn: '378',
      nombre: 'Serbal de cazadores',
      nombreCientifico: 'Sorbus aucuparia',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 73'),
  EspecieForestal(
      id: 'prunus_avium',
      codigoIfn: '395',
      nombre: 'Cerezo silvestre',
      nombreCientifico: 'Prunus avium',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 73'),
  EspecieForestal(
      id: 'juglans_regia',
      codigoIfn: '075',
      nombre: 'Nogal',
      nombreCientifico: 'Juglans regia',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 70'),
  EspecieForestal(
      id: 'eucalyptus_globulus',
      codigoIfn: '061',
      nombre: 'Eucalipto blanco',
      nombreCientifico: 'Eucalyptus globulus',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69'),
  EspecieForestal(
      id: 'eucalyptus_nitens',
      codigoIfn: '064',
      nombre: 'Eucalipto nitens',
      nombreCientifico: 'Eucalyptus nitens',
      grupo: 'frondosa',
      revisadoPor: 'fuente_publica: IFN4 documentador Sig, anexo 20, p. 69'),
];
