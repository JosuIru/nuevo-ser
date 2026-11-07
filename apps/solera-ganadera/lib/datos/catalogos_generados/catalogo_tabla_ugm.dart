// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/ganadera/tabla_ugm.csv
// Generado: 2026-11-07
// Filas: 25 (0 firmadas por persona, 8 con alguna revisión, 17 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-ganadera && dart run tool/compilar_catalogos.dart

import '../../modelos/carga_ganadera.dart';

const List<CoeficienteUgm> catalogoCoeficientesUgm = [
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'vacuno',
      sexos: {},
      edadMinimaMeses: 0,
      edadMaximaMeses: 12,
      ugm: 0.4,
      categoria: 'De menos de 1 año'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'vacuno',
      sexos: {},
      edadMinimaMeses: 12,
      edadMaximaMeses: 24,
      ugm: 0.7,
      categoria: 'De un año a menos de dos años'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'vacuno',
      sexos: {'macho', 'castrado'},
      edadMinimaMeses: 24,
      ugm: 1.0,
      categoria: 'Machos, de dos años o más'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'vacuno',
      sexos: {},
      edadMinimaMeses: 24,
      ugm: 0.8,
      categoria: 'Novillas y otras vacas, de dos años o más'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'ovino',
      sexos: {},
      edadMinimaMeses: 0,
      ugm: 0.1,
      categoria: 'Ovinos y caprinos'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'caprino',
      sexos: {},
      edadMinimaMeses: 0,
      ugm: 0.1,
      categoria: 'Ovinos y caprinos'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'equino',
      sexos: {},
      edadMinimaMeses: 0,
      ugm: 0.8,
      categoria: 'Equinos'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'porcino',
      sexos: {'hembra'},
      edadMinimaMeses: 12,
      ugm: 0.5,
      categoria: 'Cerdas de cría>50 Kg (aproximación: hembra adulta)'),
  CoeficienteUgm(
      tramite: 'pac',
      especie: 'porcino',
      sexos: {},
      edadMinimaMeses: 0,
      ugm: 0.3,
      categoria: 'Otros cerdos'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'vacuno',
      sexos: {},
      edadMinimaMeses: 0,
      edadMaximaMeses: 6,
      ugm: 0.2,
      categoria: 'Vacuno de menos de 6 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'vacuno',
      sexos: {},
      edadMinimaMeses: 6,
      edadMaximaMeses: 24,
      ugm: 0.6,
      categoria: 'Vacuno de 6 a 24 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'vacuno',
      sexos: {},
      edadMinimaMeses: 24,
      ugm: 1.0,
      categoria: 'Vacuno de 24 meses o más'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'ovino',
      sexos: {},
      edadMinimaMeses: 0,
      edadMaximaMeses: 4,
      ugm: 0.05,
      categoria: 'Ovino de menos de 4 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'ovino',
      sexos: {},
      edadMinimaMeses: 4,
      edadMaximaMeses: 12,
      ugm: 0.1,
      categoria: 'Ovino de 4 a 12 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'ovino',
      sexos: {'macho', 'castrado'},
      edadMinimaMeses: 12,
      ugm: 0.12,
      categoria: 'Morueco'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'ovino',
      sexos: {},
      edadMinimaMeses: 12,
      ugm: 0.15,
      categoria: 'Oveja'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'caprino',
      sexos: {},
      edadMinimaMeses: 0,
      edadMaximaMeses: 4,
      ugm: 0.05,
      categoria: 'Caprino de menos de 4 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'caprino',
      sexos: {},
      edadMinimaMeses: 4,
      edadMaximaMeses: 12,
      ugm: 0.1,
      categoria: 'Caprino de 4 a 12 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'caprino',
      sexos: {'macho', 'castrado'},
      edadMinimaMeses: 12,
      ugm: 0.12,
      categoria: 'Macho cabrío'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'caprino',
      sexos: {},
      edadMinimaMeses: 12,
      ugm: 0.15,
      categoria: 'Cabra'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'equino',
      sexos: {},
      edadMinimaMeses: 0,
      edadMaximaMeses: 6,
      ugm: 0.2,
      categoria: 'Équido de menos de 6 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'equino',
      sexos: {},
      edadMinimaMeses: 6,
      edadMaximaMeses: 12,
      ugm: 0.5,
      categoria: 'Équido de 6 a 12 meses'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'equino',
      sexos: {},
      edadMinimaMeses: 12,
      ugm: 1.0,
      categoria: 'Équido adulto'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'porcino',
      sexos: {'macho'},
      edadMinimaMeses: 12,
      ugm: 0.3,
      categoria: 'Verraco (extensivo)'),
  CoeficienteUgm(
      tramite: 'andalucia',
      especie: 'porcino',
      sexos: {},
      edadMinimaMeses: 0,
      ugm: 0.25,
      categoria: 'Cerdo de 20 a 150 kg (extensivo)'),
];
