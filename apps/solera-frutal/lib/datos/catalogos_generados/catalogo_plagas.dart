// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/frutal/plagas_frutal.csv
// Generado: 2026-11-07
// Filas: 20 (0 firmadas por persona, 13 con alguna revisión, 7 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-frutal && dart run tool/compilar_catalogos.dart

class PlagaCatalogo {
  const PlagaCatalogo({
    required this.id,
    required this.especies,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.sintomas,
    required this.seguimiento,
    required this.umbral,
    required this.revisadoPor,
  });

  final String id;
  final List<String> especies;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final String sintomas;
  final String seguimiento;
  final String umbral;
  final String revisadoPor;
}

const List<PlagaCatalogo> catalogoPlagas = [
  PlagaCatalogo(
      id: 'eurytoma_amygdali',
      especies: ['almendro'],
      nombre: 'Avispilla del almendro',
      nombreCientifico: 'Eurytoma amygdali',
      tipo: 'plaga',
      sintomas:
          'Frutos vacíos, marrones y más pequeños que quedan en el árbol tras la recolección; la larva está dentro',
      seguimiento:
          'En fincas afectadas, trampas en febrero-marzo con frutos infectados para ver el vuelo de adultos',
      umbral:
          'Presencia de adultos en vuelo. Si se ven los primeros frutos afectados, actuar el año siguiente: el riesgo es alto',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 29 y F p. 81'),
  PlagaCatalogo(
      id: 'capnodis_tenebrionis',
      especies: ['almendro'],
      nombre: 'Gusano cabezudo',
      nombreCientifico: 'Capnodis tenebrionis',
      tipo: 'plaga',
      sintomas:
          'Árboles o rodales debilitados que se secan; las larvas hacen galerías en las raíces',
      seguimiento: 'Vigilar síntomas y presencia de adultos o larvas',
      umbral:
          'No existe umbral. Intervención contra los adultos invernantes (final de invierno-principio de primavera) y en verano para evitar las puestas',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 30 y F p. 85'),
  PlagaCatalogo(
      id: 'pulgones',
      especies: ['almendro', 'avellano'],
      nombre: 'Pulgones',
      nombreCientifico:
          'Myzus persicae, Hyalopterus amygdali (almendro); Myzocallis coryli, Corylobium avellanae (avellano)',
      tipo: 'plaga',
      sintomas: 'Hojas enrolladas, melaza y negrilla',
      seguimiento:
          'En invierno, la puesta; desde la brotación, las primeras colonias',
      umbral:
          'Almendro: 5 % de brotes ocupados en vegetación. Avellano: primeras colonias establecidas. Tratamiento invernal solo si el año anterior hubo afectación fuerte',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 27-28 y F p. 61-65; Guía GIP avellano MAPA 2015, CE p. 28 y F p. 59'),
  PlagaCatalogo(
      id: 'monilia',
      especies: ['almendro'],
      nombre: 'Monilia',
      nombreCientifico: 'Monilinia spp.',
      tipo: 'enfermedad',
      sintomas: 'Flores secas adheridas, frutos momificados, chancros con goma',
      seguimiento:
          'Observación visual; riesgo según el inóculo y la meteorología en floración',
      umbral:
          'Preventivo durante la floración según el riesgo; en parcelas afectadas, desde el inicio de la floración hasta la caída de pétalos',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 32 y F p. 105'),
  PlagaCatalogo(
      id: 'cribado',
      especies: ['almendro'],
      nombre: 'Cribado o perdigonado',
      nombreCientifico: 'Wilsonomyces carpophilus (Stigmina carpophila)',
      tipo: 'enfermedad',
      sintomas: 'Manchas rojo-marrones que se perforan; chancros con goma',
      seguimiento: 'Visual en hojas, frutos y ramas',
      umbral:
          'Preventivo desde la prefloración (estado C/D) al cuajado (estado H); en otoño, al 50 % de caída de hojas',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 33 y F p. 109'),
  PlagaCatalogo(
      id: 'lepra_almendro',
      especies: ['almendro'],
      nombre: 'Lepra o abolladura',
      nombreCientifico: 'Taphrina deformans',
      tipo: 'enfermedad',
      sintomas: 'Hojas onduladas y rojizas, brotes curvados',
      seguimiento: 'Visual en hojas y frutos',
      umbral:
          'Preventivo al inicio de la brotación, de C/D a H; con ataques fuertes, también en otoño al 50 % de caída de hojas',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 33 y F p. 113'),
  PlagaCatalogo(
      id: 'mancha_ocre',
      especies: ['almendro'],
      nombre: 'Mancha ocre',
      nombreCientifico: 'Polystigma ochraceum',
      tipo: 'enfermedad',
      sintomas: 'Manchas amarillo-marrones que pasan a rojizas; defoliación',
      seguimiento: 'Visual en primavera',
      umbral:
          'Primeros síntomas en primavera; intervención desde la caída de pétalos hasta finales de mayo si hay humedad o lluvias',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 34 y F p. 117'),
  PlagaCatalogo(
      id: 'chancro_almendro',
      especies: ['almendro'],
      nombre: 'Chancro o Fusicoccum',
      nombreCientifico: 'Phomopsis amygdali (Diaporthe amygdali)',
      tipo: 'enfermedad',
      sintomas: 'Seca de brotes; chancros ovalados alrededor de las yemas',
      seguimiento: 'Visual en ramas',
      umbral:
          'Preventivo en primavera; intervención en mayo-junio y a la caída de hoja',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 34 y F p. 121'),
  PlagaCatalogo(
      id: 'mancha_bacteriana_almendro',
      especies: ['almendro'],
      nombre: 'Mancha bacteriana',
      nombreCientifico: 'Xanthomonas arboricola pv. pruni',
      tipo: 'enfermedad',
      sintomas: 'Manchas necróticas poligonales con halo',
      seguimiento: 'Síntomas y análisis de laboratorio',
      umbral:
          'Preventivo en floración; según la afectación, a la caída de hoja y en prefloración',
      revisadoPor:
          'fuente_publica: Guía GIP almendro MAPA 2015, CE p. 38 y F p. 145'),
  PlagaCatalogo(
      id: 'balanino_avellano',
      especies: ['avellano'],
      nombre: 'Balanino o diablo del avellano',
      nombreCientifico: 'Curculio nucum',
      tipo: 'plaga',
      sintomas: 'La picada del adulto en el fruto inmaduro provoca su aborto',
      seguimiento:
          'Golpeo (frappage) en mayo-junio, de madrugada, en las cuatro orientaciones',
      umbral:
          'Tratar a partir de 4 individuos por 100 golpes (100 ramas), con embudo de 45×74 cm. Máximo 2 aplicaciones por campaña',
      revisadoPor:
          'fuente_publica: Guía GIP avellano MAPA 2015, CE p. 27 y F p. 47'),
  PlagaCatalogo(
      id: 'eriofido_avellano',
      especies: ['avellano'],
      nombre: 'Badoc o eriófido de las yemas',
      nombreCientifico: 'Phytoptus avellanae',
      tipo: 'plaga',
      sintomas: 'Yemas hipertrofiadas que no brotan',
      seguimiento: 'En enero-febrero, porcentaje de yemas atacadas',
      umbral:
          'A partir del 15 % de yemas atacadas, tratar con la brotación entre la tercera y la sexta hoja. Máximo 1 aplicación',
      revisadoPor:
          'fuente_publica: Guía GIP avellano MAPA 2015, CE p. 29 y F p. 67'),
  PlagaCatalogo(
      id: 'chinches_avellano',
      especies: ['avellano'],
      nombre: 'Chinches',
      nombreCientifico: 'Nezara viridula, Pantilius tunicatus',
      tipo: 'plaga',
      sintomas: 'Ataques puntuales y esporádicos',
      seguimiento:
          'Visual; golpeo en mayo-junio y en septiembre-octubre para P. tunicatus',
      umbral: 'No hay un umbral definido',
      revisadoPor:
          'fuente_publica: Guía GIP avellano MAPA 2015, CE p. 30 y F p. 75'),
  PlagaCatalogo(
      id: 'bacteriosis_avellano',
      especies: ['avellano'],
      nombre: 'Bacteriosis del avellano',
      nombreCientifico: 'Xanthomonas arboricola pv. corylina',
      tipo: 'enfermedad',
      sintomas: 'Necrosis foliar con halo; chancros en brotes',
      seguimiento: 'Síntomas y confirmación en laboratorio',
      umbral:
          'No hay umbral ni método directo de lucha; preventivos a la caída de hoja y al inicio de la brotación',
      revisadoPor:
          'fuente_publica: Guía GIP avellano MAPA 2015, CE p. 32 y F p. 95'),
  PlagaCatalogo(
      id: 'carpocapsa_nogal',
      especies: ['nogal'],
      nombre: 'Carpocapsa del nogal',
      nombreCientifico: 'Cydia pomonella',
      tipo: 'plaga',
      sintomas: 'Frutos agusanados que caen antes de tiempo',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'bacteriosis_nogal',
      especies: ['nogal'],
      nombre: 'Bacteriosis del nogal',
      nombreCientifico: 'Xanthomonas arboricola pv. juglandis',
      tipo: 'enfermedad',
      sintomas: 'Manchas negras en hojas y frutos',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'cydia_castano',
      especies: ['castano'],
      nombre: 'Agusanado de la castaña',
      nombreCientifico: 'Cydia splendana, C. fagiglandana',
      tipo: 'plaga',
      sintomas: 'Castañas con orificio y galería de la oruga',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'gorgojo_castano',
      especies: ['castano'],
      nombre: 'Gorgojo de la castaña',
      nombreCientifico: 'Curculio elephas',
      tipo: 'plaga',
      sintomas: 'Castañas con larva de gorgojo',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'chancro_castano',
      especies: ['castano'],
      nombre: 'Chancro del castaño',
      nombreCientifico: 'Cryphonectria parasitica',
      tipo: 'enfermedad',
      sintomas: 'Chancros anaranjados en la corteza; seca de ramas',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'tinta_castano',
      especies: ['castano'],
      nombre: 'Tinta del castaño',
      nombreCientifico: 'Phytophthora spp.',
      tipo: 'enfermedad',
      sintomas: 'Decaimiento del árbol; exudado negro en el cuello',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
  PlagaCatalogo(
      id: 'avispilla_castano',
      especies: ['castano'],
      nombre: 'Avispilla del castaño',
      nombreCientifico: 'Dryocosmus kuriphilus',
      tipo: 'plaga',
      sintomas: 'Agallas en yemas y hojas',
      seguimiento: '',
      umbral: '',
      revisadoPor: ''),
];
