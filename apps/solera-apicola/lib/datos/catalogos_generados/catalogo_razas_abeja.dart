// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/apicola/razas_abeja.csv
// Generado: 2026-11-07
// Filas: 7 (0 revisadas, 7 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-apicola && dart run tool/compilar_catalogos.dart

class RazaAbeja {
  final String id;
  final String nombreCanonico;
  /// Subespecie taxonómica. Vacía para líneas comerciales (Buckfast) e híbridos.
  final String subespecie;
  final String origenGeografico;
  final List<String> sinonimias;
  final List<String> caracter;
  final String notas;

  const RazaAbeja({
    required this.id,
    required this.nombreCanonico,
    this.subespecie = '',
    required this.origenGeografico,
    this.sinonimias = const [],
    this.caracter = const [],
    this.notas = '',
  });
}

const List<RazaAbeja> catalogoRazasAbeja = [
  RazaAbeja(
    id: 'iberica',
    nombreCanonico: 'Abeja ibérica',
    subespecie: 'Apis mellifera iberiensis',
    origenGeografico: 'Península ibérica',
    sinonimias: ['negra ibérica', 'abeja peninsular'],
    caracter: ['Defensiva', 'enjambradora', 'adaptada al clima mediterráneo'],
    notas: 'Subespecie autóctona dominante en España y Portugal — la mejor adaptada al rango climático peninsular',
  ),
  RazaAbeja(
    id: 'carnica',
    nombreCanonico: 'Abeja carniola',
    subespecie: 'Apis mellifera carnica',
    origenGeografico: 'Eslovenia y los Alpes orientales',
    sinonimias: ['gris austríaca', 'abeja austríaca'],
    caracter: ['Mansa', 'baja propolización', 'enjambradora moderada'],
    notas: 'Muy difundida en apicultura comercial europea',
  ),
  RazaAbeja(
    id: 'ligustica',
    nombreCanonico: 'Abeja italiana',
    subespecie: 'Apis mellifera ligustica',
    origenGeografico: 'Italia peninsular',
    sinonimias: ['abeja amarilla', 'abeja italiana'],
    caracter: ['Mansa', 'alta postura', 'baja resistencia a varroa'],
    notas: 'Color amarillo característico — popular en producción de miel monofloral',
  ),
  RazaAbeja(
    id: 'mellifera_negra',
    nombreCanonico: 'Abeja negra europea',
    subespecie: 'Apis mellifera mellifera',
    origenGeografico: 'Europa central y atlántica',
    sinonimias: ['abeja negra del norte', 'black bee'],
    caracter: ['Defensiva', 'robusta', 'adaptada a climas fríos'],
    notas: 'Subespecie originaria del norte y oeste europeo — declinante por hibridación',
  ),
  RazaAbeja(
    id: 'caucasica',
    nombreCanonico: 'Abeja caucásica',
    subespecie: 'Apis mellifera caucasica',
    origenGeografico: 'Cáucaso',
    sinonimias: ['gris caucásica'],
    caracter: ['Mansa', 'propolizadora extrema', 'lengua larga'],
    notas: 'Lengua especialmente larga — accede a néctares profundos',
  ),
  RazaAbeja(
    id: 'buckfast',
    nombreCanonico: 'Buckfast',
    origenGeografico: 'Selección artificial (abadía de Buckfast — Reino Unido)',
    caracter: ['Mansa', 'productiva', 'baja enjambrazón', 'seleccionada por resistencias'],
    notas: 'Híbrido sintético seleccionado durante el siglo XX — no es subespecie sino línea comercial',
  ),
  RazaAbeja(
    id: 'hibrida_local',
    nombreCanonico: 'Híbrida local',
    origenGeografico: 'España (mestizaje natural)',
    sinonimias: ['mezcla', 'cruce de patio'],
    caracter: ['Variable según genética dominante'],
    notas: 'Cruce no controlado entre subespecies presentes en el colmenar — caso muy frecuente en explotaciones pequeñas',
  ),
];

RazaAbeja? razaAbejaPorId(String id) {
  for (final r in catalogoRazasAbeja) {
    if (r.id == id) return r;
  }
  return null;
}

/// Búsqueda fuzzy: id exacto > nombre canónico > subespecie > sinonimias.
List<RazaAbeja> buscarRazasAbeja(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoRazasAbeja.where((r) {
    if (r.id == consultaNormalizada) return true;
    if (_normalizar(r.nombreCanonico).contains(consultaNormalizada)) return true;
    if (r.subespecie.isNotEmpty && _normalizar(r.subespecie).contains(consultaNormalizada)) return true;
    for (final s in r.sinonimias) {
      if (_normalizar(s).contains(consultaNormalizada)) return true;
    }
    return false;
  }).toList();
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}

