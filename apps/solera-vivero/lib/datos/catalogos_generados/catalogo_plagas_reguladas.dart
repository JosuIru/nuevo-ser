// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/vivero/plagas_reguladas_vivero.csv
// Generado: 2026-11-07
// Filas: 26 (0 firmadas por persona, 26 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-vivero && dart run tool/compilar_catalogos.dart

class PlagaReguladaCatalogo {
  const PlagaReguladaCatalogo({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.categoria,
    required this.generos,
    required this.sintomas,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String categoria;
  final List<String> generos;
  final String sintomas;
}

const List<PlagaReguladaCatalogo> catalogoPlagasReguladas = [
  PlagaReguladaCatalogo(id: 'xylella_fastidiosa', nombre: 'Xylella', nombreCientifico: 'Xylella fastidiosa', categoria: 'prioritaria', generos: ['Olea', 'Prunus', 'Lavandula', 'Salvia', 'Polygala', 'Nerium', 'Vitis', 'Citrus', 'Coffea'], sintomas: 'Quemado de bordes de hoja, secado de ramas; muchos huéspedes sin síntomas'),
  PlagaReguladaCatalogo(id: 'popillia_japonica', nombre: 'Escarabajo japonés', nombreCientifico: 'Popillia japonica', categoria: 'prioritaria', generos: ['Rosa', 'Vitis', 'Prunus', 'Malus', 'Tilia', 'Acer'], sintomas: 'Hojas esqueletizadas; adultos verde metálico con mechones blancos; larvas en el césped y el sustrato'),
  PlagaReguladaCatalogo(id: 'anoplophora_chinensis', nombre: 'Escarabajo de cuernos largos de los cítricos', nombreCientifico: 'Anoplophora chinensis', categoria: 'prioritaria', generos: ['Acer', 'Citrus', 'Malus', 'Platanus', 'Populus', 'Salix'], sintomas: 'Orificios de salida redondos en la base del tronco y las raíces'),
  PlagaReguladaCatalogo(id: 'anoplophora_glabripennis', nombre: 'Escarabajo asiático de cuernos largos', nombreCientifico: 'Anoplophora glabripennis', categoria: 'prioritaria', generos: ['Acer', 'Populus', 'Salix', 'Betula', 'Ulmus', 'Aesculus'], sintomas: 'Orificios de salida redondos en tronco y ramas; serrín'),
  PlagaReguladaCatalogo(id: 'agrilus_planipennis', nombre: 'Barrenador esmeralda del fresno', nombreCientifico: 'Agrilus planipennis', categoria: 'prioritaria', generos: ['Fraxinus'], sintomas: 'Orificios de salida en forma de D; galerías serpenteantes bajo la corteza'),
  PlagaReguladaCatalogo(id: 'aromia_bungii', nombre: 'Escarabajo de cuello rojo', nombreCientifico: 'Aromia bungii', categoria: 'prioritaria', generos: ['Prunus'], sintomas: 'Serrín en la base del tronco; orificios de salida ovalados'),
  PlagaReguladaCatalogo(id: 'bursaphelenchus_xylophilus', nombre: 'Nematodo de la madera del pino', nombreCientifico: 'Bursaphelenchus xylophilus', categoria: 'prioritaria', generos: ['Pinus'], sintomas: 'Marchitez rápida de las acículas y muerte del pino'),
  PlagaReguladaCatalogo(id: 'candidatus_liberibacter', nombre: 'Huanglongbing (enverdecimiento de los cítricos)', nombreCientifico: 'Candidatus Liberibacter spp.', categoria: 'prioritaria', generos: ['Citrus', 'Fortunella', 'Poncirus', 'Murraya'], sintomas: 'Moteado asimétrico de las hojas; brotes amarillos'),
  PlagaReguladaCatalogo(id: 'phyllosticta_citricarpa', nombre: 'Mancha negra de los cítricos', nombreCientifico: 'Phyllosticta citricarpa', categoria: 'prioritaria', generos: ['Citrus'], sintomas: 'Manchas negras en frutos y hojas'),
  PlagaReguladaCatalogo(id: 'spodoptera_frugiperda', nombre: 'Gusano cogollero', nombreCientifico: 'Spodoptera frugiperda', categoria: 'prioritaria', generos: ['Zea', 'Sorghum', 'Solanum', 'Capsicum'], sintomas: 'Orugas en los cogollos; hojas perforadas'),
  PlagaReguladaCatalogo(id: 'plum_pox_virus', nombre: 'Sharka', nombreCientifico: 'Plum pox virus', categoria: 'rnqp', generos: ['Prunus'], sintomas: 'Anillos y manchas cloróticas en hojas y frutos'),
  PlagaReguladaCatalogo(id: 'xanthomonas_arboricola_pruni', nombre: 'Mancha bacteriana de los frutales de hueso', nombreCientifico: 'Xanthomonas arboricola pv. pruni', categoria: 'rnqp', generos: ['Prunus'], sintomas: 'Manchas angulosas que se perforan; chancros'),
  PlagaReguladaCatalogo(id: 'erwinia_amylovora', nombre: 'Fuego bacteriano', nombreCientifico: 'Erwinia amylovora', categoria: 'rnqp', generos: ['Malus', 'Pyrus', 'Cydonia', 'Crataegus', 'Pyracantha', 'Cotoneaster', 'Sorbus', 'Amelanchier', 'Chaenomeles', 'Eriobotrya', 'Mespilus'], sintomas: 'Flores y brotes ennegrecidos como quemados, en cayado'),
  PlagaReguladaCatalogo(id: 'cryphonectria_parasitica', nombre: 'Chancro del castaño', nombreCientifico: 'Cryphonectria parasitica', categoria: 'rnqp', generos: ['Castanea'], sintomas: 'Chancros anaranjados en tronco y ramas; ramas secas'),
  PlagaReguladaCatalogo(id: 'dothistroma', nombre: 'Banda roja del pino', nombreCientifico: 'Dothistroma septosporum y D. pini', categoria: 'rnqp', generos: ['Pinus'], sintomas: 'Bandas rojas en las acículas; defoliación'),
  PlagaReguladaCatalogo(id: 'lecanosticta_acicola', nombre: 'Mancha parda del pino', nombreCientifico: 'Lecanosticta acicola', categoria: 'rnqp', generos: ['Pinus'], sintomas: 'Manchas pardas con halo amarillo en las acículas'),
  PlagaReguladaCatalogo(id: 'clavibacter_michiganensis', nombre: 'Chancro bacteriano del tomate', nombreCientifico: 'Clavibacter michiganensis subsp. michiganensis', categoria: 'rnqp', generos: ['Solanum lycopersicum'], sintomas: 'Marchitez unilateral; chancros en el tallo; ojo de perdiz en frutos'),
  PlagaReguladaCatalogo(id: 'xanthomonas_tomate_pimiento', nombre: 'Mancha bacteriana del tomate y el pimiento', nombreCientifico: 'Xanthomonas euvesicatoria, X. gardneri, X. perforans, X. vesicatoria', categoria: 'rnqp', generos: ['Solanum lycopersicum', 'Capsicum annuum'], sintomas: 'Manchas pequeñas, oscuras y grasientas en hojas y frutos'),
  PlagaReguladaCatalogo(id: 'virus_bronceado_tomate', nombre: 'Virus del bronceado del tomate', nombreCientifico: 'Tomato spotted wilt tospovirus', categoria: 'rnqp', generos: ['Solanum lycopersicum', 'Capsicum annuum'], sintomas: 'Bronceado y anillos necróticos en hojas; frutos con anillos'),
  PlagaReguladaCatalogo(id: 'virus_cuchara_tomate', nombre: 'Virus de la cuchara del tomate', nombreCientifico: 'Tomato yellow leaf curl virus', categoria: 'rnqp', generos: ['Solanum lycopersicum'], sintomas: 'Hojas pequeñas, amarillas y enrolladas hacia arriba; enanismo'),
  PlagaReguladaCatalogo(id: 'viroide_tuberculo_fusiforme', nombre: 'Viroide del tubérculo fusiforme de la patata', nombreCientifico: 'Potato spindle tuber viroid', categoria: 'rnqp', generos: ['Solanum lycopersicum', 'Capsicum annuum', 'Solanum tuberosum'], sintomas: 'Enanismo, hojas rizadas y cloróticas; a menudo sin síntomas'),
  PlagaReguladaCatalogo(id: 'virus_tristeza_citricos', nombre: 'Virus de la tristeza de los cítricos', nombreCientifico: 'Citrus tristeza virus', categoria: 'rnqp', generos: ['Citrus', 'Fortunella', 'Poncirus'], sintomas: 'Decaimiento; acanaladuras en la madera'),
  PlagaReguladaCatalogo(id: 'pseudomonas_savastanoi', nombre: 'Tuberculosis del olivo', nombreCientifico: 'Pseudomonas savastanoi pv. savastanoi', categoria: 'rnqp', generos: ['Olea'], sintomas: 'Tumores o verrugas en ramas y tronco'),
  PlagaReguladaCatalogo(id: 'virus_entrenudo_corto', nombre: 'Entrenudo corto de la vid', nombreCientifico: 'Grapevine fanleaf virus', categoria: 'rnqp', generos: ['Vitis'], sintomas: 'Hojas en abanico, entrenudos cortos y dobles'),
  PlagaReguladaCatalogo(id: 'xylophilus_ampelinus', nombre: 'Necrosis bacteriana de la vid', nombreCientifico: 'Xylophilus ampelinus', categoria: 'rnqp', generos: ['Vitis'], sintomas: 'Manchas y grietas en brotes; brotes secos'),
  PlagaReguladaCatalogo(id: 'verticillium_dahliae', nombre: 'Verticilosis', nombreCientifico: 'Verticillium dahliae', categoria: 'rnqp', generos: ['Olea', 'Prunus', 'Malus', 'Pyrus', 'Corylus', 'Humulus'], sintomas: 'Marchitez y seca de ramas; madera con estrías oscuras'),
];
