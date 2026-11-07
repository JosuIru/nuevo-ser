// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/ganadera/especies.csv
// Generado: 2026-11-07
// Filas: 5 (0 firmadas por persona, 0 con alguna revisión, 5 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-ganadera && dart run tool/compilar_catalogos.dart

class EspecieCatalogo {
  const EspecieCatalogo(
      {required this.id,
      required this.nombreCientifico,
      required this.dispositivoHabitual});

  final String id;
  final String nombreCientifico;
  final String dispositivoHabitual;
}

const List<EspecieCatalogo> catalogoEspecies = [
  EspecieCatalogo(
      id: 'ovino',
      nombreCientifico: 'Ovis aries',
      dispositivoHabitual: 'crotal_electronico'),
  EspecieCatalogo(
      id: 'caprino',
      nombreCientifico: 'Capra hircus',
      dispositivoHabitual: 'crotal_electronico'),
  EspecieCatalogo(
      id: 'vacuno',
      nombreCientifico: 'Bos taurus',
      dispositivoHabitual: 'crotal'),
  EspecieCatalogo(
      id: 'porcino',
      nombreCientifico: 'Sus scrofa domesticus',
      dispositivoHabitual: 'crotal'),
  EspecieCatalogo(
      id: 'equino',
      nombreCientifico: 'Equus caballus',
      dispositivoHabitual: 'otro'),
];
