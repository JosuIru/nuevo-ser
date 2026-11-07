// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/viticultura/portainjertos.csv
// Generado: 2026-11-07
// Filas: 10 (0 revisadas, 10 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-viticultura && dart run tool/compilar_catalogos.dart

class Portainjerto {
  final String id;
  final String nombreCanonico;
  final String vigor;
  final int? toleranciaCalizaActivaPorcentaje;
  final String resistenciaSequia;
  final String notas;

  const Portainjerto({
    required this.id,
    required this.nombreCanonico,
    required this.vigor,
    this.toleranciaCalizaActivaPorcentaje,
    required this.resistenciaSequia,
    this.notas = '',
  });
}

const List<Portainjerto> catalogoPortainjertos = [
  Portainjerto(
    id: '110_r',
    nombreCanonico: '110 Richter',
    vigor: 'alto',
    toleranciaCalizaActivaPorcentaje: 17,
    resistenciaSequia: 'alta',
    notas: 'Suelos pobres y secos. Acelera la maduración. Resistencia media a filoxera.',
  ),
  Portainjerto(
    id: 'so4',
    nombreCanonico: 'SO4 (Selección Oppenheim 4)',
    vigor: 'medio_alto',
    toleranciaCalizaActivaPorcentaje: 15,
    resistenciaSequia: 'media',
    notas: 'Suelos profundos y húmedos. Sensible a sequía.',
  ),
  Portainjerto(
    id: '41_b',
    nombreCanonico: '41-B Millardet et de Grasset',
    vigor: 'medio',
    toleranciaCalizaActivaPorcentaje: 40,
    resistenciaSequia: 'media',
    notas: 'El más resistente a caliza activa. Suelos calizos del Jerez y similares.',
  ),
  Portainjerto(
    id: '1103_paulsen',
    nombreCanonico: '1103 Paulsen',
    vigor: 'alto',
    toleranciaCalizaActivaPorcentaje: 17,
    resistenciaSequia: 'alta',
    notas: 'Suelos pobres y secos. Vigor alto. Adaptación a clima mediterráneo.',
  ),
  Portainjerto(
    id: '161_49c',
    nombreCanonico: '161-49 Couderc',
    vigor: 'medio',
    toleranciaCalizaActivaPorcentaje: 25,
    resistenciaSequia: 'media',
    notas: 'Buena calidad y vigor moderado. Sensible a sequía extrema.',
  ),
  Portainjerto(
    id: 'ru_140',
    nombreCanonico: '140 Ruggeri',
    vigor: 'muy_alto',
    toleranciaCalizaActivaPorcentaje: 20,
    resistenciaSequia: 'muy_alta',
    notas: 'Resistente a sequía extrema. Suelos áridos andaluces.',
  ),
  Portainjerto(
    id: '420a',
    nombreCanonico: '420A Millardet et de Grasset',
    vigor: 'bajo',
    toleranciaCalizaActivaPorcentaje: 20,
    resistenciaSequia: 'baja',
    notas: 'Vigor bajo y calidad alta. Suelos frescos y profundos.',
  ),
  Portainjerto(
    id: '196_17',
    nombreCanonico: '196-17 Castel',
    vigor: 'medio',
    toleranciaCalizaActivaPorcentaje: 8,
    resistenciaSequia: 'media',
    notas: 'Suelos compactos. Tolerancia baja a caliza.',
  ),
  Portainjerto(
    id: '5bb',
    nombreCanonico: '5BB Kober',
    vigor: 'alto',
    toleranciaCalizaActivaPorcentaje: 20,
    resistenciaSequia: 'baja',
    notas: 'Suelos húmedos y profundos. Acelera la brotación.',
  ),
  Portainjerto(
    id: 'fercal',
    nombreCanonico: 'Fercal',
    vigor: 'medio',
    toleranciaCalizaActivaPorcentaje: 40,
    resistenciaSequia: 'media',
    notas: 'Resistente a caliza activa alta. Suelos calizos del centro y sur.',
  ),
];

Portainjerto? portainjertoPorId(String id) {
  for (final p in catalogoPortainjertos) {
    if (p.id == id) return p;
  }
  return null;
}

List<Portainjerto> buscarPortainjertos(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoPortainjertos.where((p) {
    return _normalizar(p.id).contains(q) ||
        _normalizar(p.nombreCanonico).contains(q);
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

