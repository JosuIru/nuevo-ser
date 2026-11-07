/// Los 14 alérgenos de declaración obligatoria (Reglamento (UE)
/// 1169/2011, anexo II). Se guardan por su identificador; el nombre
/// visible sale de las traducciones (`obra.alergeno_<id>`).
const List<String> alergenosObligatorios = [
  'gluten',
  'crustaceos',
  'huevos',
  'pescado',
  'cacahuetes',
  'soja',
  'lacteos',
  'frutos_cascara',
  'apio',
  'mostaza',
  'sesamo',
  'sulfitos',
  'altramuces',
  'moluscos',
];

/// `{'gluten', 'sesamo'}` → `'gluten|sesamo'` (orden del anexo II).
String codificarAlergenos(Set<String> alergenos) =>
    alergenosObligatorios.where(alergenos.contains).join('|');

/// Inverso de [codificarAlergenos]; ignora identificadores desconocidos.
Set<String> decodificarAlergenos(String? texto) => (texto ?? '')
    .split('|')
    .map((parte) => parte.trim())
    .where(alergenosObligatorios.contains)
    .toSet();
