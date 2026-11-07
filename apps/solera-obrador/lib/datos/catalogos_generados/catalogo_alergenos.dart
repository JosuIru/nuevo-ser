// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/obrador/alergenos.csv
// Generado: 2026-11-07
// Filas: 14 (0 firmadas por persona, 14 con alguna revisión, 0 sin revisar)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-obrador && dart run tool/compilar_catalogos.dart

class AlergenoCatalogo {
  const AlergenoCatalogo(
      {required this.id, required this.nombre, required this.ejemplos});

  final String id;
  final String nombre;
  final String ejemplos;
}

const List<AlergenoCatalogo> catalogoAlergenos = [
  AlergenoCatalogo(
      id: 'gluten',
      nombre: 'Cereales con gluten',
      ejemplos: 'trigo (espelta, kamut), centeno, cebada, avena e híbridos'),
  AlergenoCatalogo(
      id: 'crustaceos',
      nombre: 'Crustáceos',
      ejemplos: 'gambas, langostinos, cangrejos'),
  AlergenoCatalogo(
      id: 'huevos', nombre: 'Huevos', ejemplos: 'huevo y derivados'),
  AlergenoCatalogo(
      id: 'pescado', nombre: 'Pescado', ejemplos: 'pescado y derivados'),
  AlergenoCatalogo(
      id: 'cacahuetes',
      nombre: 'Cacahuetes',
      ejemplos: 'cacahuete y derivados'),
  AlergenoCatalogo(id: 'soja', nombre: 'Soja', ejemplos: 'soja y derivados'),
  AlergenoCatalogo(
      id: 'lacteos',
      nombre: 'Leche',
      ejemplos: 'leche y derivados, incluida la lactosa'),
  AlergenoCatalogo(
      id: 'frutos_cascara',
      nombre: 'Frutos de cáscara',
      ejemplos:
          'almendra, avellana, nuez, anacardo, pacana, nuez de Brasil, pistacho, macadamia'),
  AlergenoCatalogo(id: 'apio', nombre: 'Apio', ejemplos: 'apio y derivados'),
  AlergenoCatalogo(
      id: 'mostaza', nombre: 'Mostaza', ejemplos: 'mostaza y derivados'),
  AlergenoCatalogo(
      id: 'sesamo', nombre: 'Granos de sésamo', ejemplos: 'sésamo y derivados'),
  AlergenoCatalogo(
      id: 'sulfitos',
      nombre: 'Dióxido de azufre y sulfitos',
      ejemplos: 'en concentraciones superiores a 10 mg/kg o 10 mg/l'),
  AlergenoCatalogo(
      id: 'altramuces', nombre: 'Altramuces', ejemplos: 'altramuz y derivados'),
  AlergenoCatalogo(
      id: 'moluscos',
      nombre: 'Moluscos',
      ejemplos: 'mejillones, almejas, calamares'),
];
