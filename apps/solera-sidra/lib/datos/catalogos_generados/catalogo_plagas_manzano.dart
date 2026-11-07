// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/sidra/plagas_manzano.csv
// Generado: 2026-11-07
// Filas: 18 (0 firmadas por persona, 18 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-sidra && dart run tool/compilar_catalogos.dart

class PlagaManzano {
  const PlagaManzano({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.tipo,
    required this.organismoRegulado,
    required this.sintomas,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String tipo;
  final bool organismoRegulado;
  final String sintomas;
}

const List<PlagaManzano> catalogoPlagasManzano = [
  PlagaManzano(
      id: 'moteado',
      nombre: 'Moteado o roña del manzano',
      nombreCientifico: 'Venturia inaequalis',
      tipo: 'hongo',
      organismoRegulado: false,
      sintomas:
          'Manchas verde oliva a pardas en hojas; manchas negras con costra y grietas en el fruto'),
  PlagaManzano(
      id: 'carpocapsa',
      nombre: 'Carpocapsa',
      nombreCientifico: 'Cydia pomonella',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Fruto agusanado: orificio con serrín pardo; galería hasta las pepitas'),
  PlagaManzano(
      id: 'pulgon_ceniciento',
      nombre: 'Pulgón ceniciento',
      nombreCientifico: 'Dysaphis plantaginea',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Colonias gris-rosadas; hojas muy enrolladas y deformadas en primavera; frutos pequeños y deformes'),
  PlagaManzano(
      id: 'pulgon_verde',
      nombre: 'Pulgón verde del manzano',
      nombreCientifico: 'Aphis pomi',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Colonias verdes en brotes tiernos; hojas algo rizadas y melaza'),
  PlagaManzano(
      id: 'pulgon_lanigero',
      nombre: 'Pulgón lanígero',
      nombreCientifico: 'Eriosoma lanigerum',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Masas algodonosas blancas en ramas, heridas y cuello; agallas en la madera'),
  PlagaManzano(
      id: 'pulgones',
      nombre: 'Pulgones (en general)',
      nombreCientifico: 'Aphididae',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Insectos pequeños en colonias sobre brotes y hojas; melaza y negrilla. En el registro, muchos productos figuran para «pulgones» sin especie'),
  PlagaManzano(
      id: 'chancro_europeo',
      nombre: 'Chancro europeo',
      nombreCientifico: 'Neonectria ditissima',
      tipo: 'hongo',
      organismoRegulado: false,
      sintomas:
          'Heridas hundidas en ramas con la corteza agrietada en anillos; puntos rojos (fructificaciones) en invierno'),
  PlagaManzano(
      id: 'oidio',
      nombre: 'Oídio del manzano',
      nombreCientifico: 'Podosphaera leucotricha',
      tipo: 'hongo',
      organismoRegulado: false,
      sintomas:
          'Polvo blanco en brotes y hojas, que quedan estrechas y quebradizas'),
  PlagaManzano(
      id: 'fuego_bacteriano',
      nombre: 'Fuego bacteriano',
      nombreCientifico: 'Erwinia amylovora',
      tipo: 'bacteria',
      organismoRegulado: true,
      sintomas:
          'Flores y brotes que se ennegrecen como quemados; punta del brote curvada en cayado; exudado'),
  PlagaManzano(
      id: 'acaro_rojo',
      nombre: 'Ácaro rojo de los frutales',
      nombreCientifico: 'Panonychus ulmi',
      tipo: 'acaro',
      organismoRegulado: false,
      sintomas:
          'Hojas bronceadas o plateadas; huevos rojos en la madera en invierno'),
  PlagaManzano(
      id: 'hoplocampa',
      nombre: 'Hoplocampa',
      nombreCientifico: 'Hoplocampa spp.',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Frutitos caídos en primavera con galería y olor a chinche; cicatriz en cinta en el fruto'),
  PlagaManzano(
      id: 'antonomo',
      nombre: 'Gorgojo de la flor del manzano',
      nombreCientifico: 'Anthonomus pomorum',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas: 'Botones florales que no abren y se secan como un clavo pardo'),
  PlagaManzano(
      id: 'monilia',
      nombre: 'Monilia',
      nombreCientifico: 'Monilinia spp.',
      tipo: 'hongo',
      organismoRegulado: false,
      sintomas:
          'Podredumbre parda del fruto con anillos de pústulas; frutos momificados en el árbol'),
  PlagaManzano(
      id: 'gloeosporiosis',
      nombre: 'Gloeosporiosis o antracnosis de las manzanas',
      nombreCientifico: 'Neofabraea spp.',
      tipo: 'hongo',
      organismoRegulado: false,
      sintomas:
          'Manchas pardas redondas y hundidas en el fruto, sobre todo en almacén'),
  PlagaManzano(
      id: 'capua',
      nombre: 'Capua',
      nombreCientifico: 'Adoxophyes orana',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Oruga verde que une hojas con seda y roe la piel del fruto en placas'),
  PlagaManzano(
      id: 'minadores',
      nombre: 'Minadores de hoja',
      nombreCientifico:
          'Leucoptera malifoliella / Phyllonorycter spp. / Lyonetia clerkella',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas: 'Galerías o manchas (minas) dentro de la hoja'),
  PlagaManzano(
      id: 'piojo_san_jose',
      nombre: 'Piojo de San José',
      nombreCientifico: 'Quadraspidiotus perniciosus',
      tipo: 'insecto',
      organismoRegulado: false,
      sintomas:
          'Escudos grises diminutos en la corteza; manchas rojas alrededor en el fruto'),
  PlagaManzano(
      id: 'phytophthora',
      nombre: 'Podredumbre de cuello',
      nombreCientifico: 'Phytophthora spp.',
      tipo: 'oomiceto',
      organismoRegulado: false,
      sintomas:
          'Corteza del cuello oscura y blanda; árbol que amarillea y decae'),
];
