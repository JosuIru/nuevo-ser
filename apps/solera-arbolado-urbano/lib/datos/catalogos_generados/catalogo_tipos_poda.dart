// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/arbolado-urbano/tipos_poda.csv
// Generado: 2026-11-07
// Filas: 12 (0 revisadas, 12 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR INGENIERO TÉCNICO FORESTAL.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-arbolado-urbano && dart run tool/compilar_catalogos.dart

/// Intensidad de la poda — orientativa para evaluar el impacto sobre el árbol.
enum IntensidadPoda { baja, media, alta, muyAlta, variable }

class TipoPoda {
  final String id;
  final String nombreCanonico;
  final String descripcion;
  final String epocaRecomendada;
  final IntensidadPoda intensidad;
  /// `true` si la práctica está en debate técnico — el técnico debe justificar su uso.
  final bool controvertida;
  final String notas;

  const TipoPoda({
    required this.id,
    required this.nombreCanonico,
    required this.descripcion,
    required this.epocaRecomendada,
    required this.intensidad,
    this.controvertida = false,
    this.notas = '',
  });
}

const List<TipoPoda> catalogoTiposPoda = [
  TipoPoda(
    id: 'formacion',
    nombreCanonico: 'Poda de formación',
    descripcion: 'Modela la estructura del árbol joven|elimina chupones|equilibra la copa',
    epocaRecomendada: 'Otoño-invierno (savia parada) en años 2-5 desde plantación',
    intensidad: IntensidadPoda.media,
    notas: 'Poda crítica para definir la estructura adulta del árbol — invertir tiempo aquí ahorra problemas en décadas posteriores',
  ),
  TipoPoda(
    id: 'mantenimiento',
    nombreCanonico: 'Poda de mantenimiento',
    descripcion: 'Eliminación de ramas mal orientadas|limpieza ligera|estabilización anual',
    epocaRecomendada: 'Otoño-invierno (savia parada)',
    intensidad: IntensidadPoda.baja,
    notas: 'Poda anual ligera que preserva el porte natural del árbol',
  ),
  TipoPoda(
    id: 'saneamiento',
    nombreCanonico: 'Poda de saneamiento',
    descripcion: 'Eliminación de madera muerta|enferma o rota',
    epocaRecomendada: 'Cualquier época si hay urgencia sanitaria|preferiblemente otoño',
    intensidad: IntensidadPoda.media,
    notas: 'También llamada limpieza en algunos pliegos',
  ),
  TipoPoda(
    id: 'refaldado',
    nombreCanonico: 'Refaldado',
    descripcion: 'Subir la copa eliminando ramas bajas para visibilidad de tráfico|peatonal o señalización',
    epocaRecomendada: 'Otoño-invierno',
    intensidad: IntensidadPoda.media,
    notas: 'Necesario en alineaciones junto a viario y carriles bus. Mantener al menos 2/3 de copa',
  ),
  TipoPoda(
    id: 'descopado',
    nombreCanonico: 'Descopado',
    descripcion: 'Eliminación de la cima del árbol manteniendo el tronco principal',
    epocaRecomendada: 'Cualquier época por urgencia',
    intensidad: IntensidadPoda.muyAlta,
    controvertida: true,
    notas: 'CONTROVERTIDA — modifica permanentemente el porte natural. Ayuntamientos modernos la han abandonado salvo emergencia. Genera rebrotes débiles peligrosos a futuro',
  ),
  TipoPoda(
    id: 'terciado',
    nombreCanonico: 'Terciado',
    descripcion: 'Reducción a un tercio del volumen de copa',
    epocaRecomendada: 'Otoño-invierno',
    intensidad: IntensidadPoda.alta,
    controvertida: true,
    notas: 'CONTROVERTIDA — práctica histórica española. Asociada a estrés del árbol y aparición de chupones masivos',
  ),
  TipoPoda(
    id: 'aterrazado',
    nombreCanonico: 'Aterrazado / Poda drástica',
    descripcion: 'Reducción muy severa de la copa con cortes grandes',
    epocaRecomendada: 'Otoño-invierno por urgencia',
    intensidad: IntensidadPoda.muyAlta,
    controvertida: true,
    notas: 'CONTROVERTIDA — debate intenso en jardinería ibérica. Produce heridas grandes mal cicatrizables. Reservada para emergencias por riesgo',
  ),
  TipoPoda(
    id: 'drenaje_copa',
    nombreCanonico: 'Drenaje de copa / Aclareo',
    descripcion: 'Eliminación selectiva de ramas para abrir la copa y facilitar paso del aire y luz',
    epocaRecomendada: 'Otoño-invierno',
    intensidad: IntensidadPoda.media,
    notas: 'Pieza clave en lucha contra anthracnosis y oídio. Preserva la silueta del árbol',
  ),
  TipoPoda(
    id: 'poda_seguridad',
    nombreCanonico: 'Poda de seguridad',
    descripcion: 'Eliminación de ramas con riesgo de caída inmediato',
    epocaRecomendada: 'Cualquier época por urgencia',
    intensidad: IntensidadPoda.variable,
    notas: 'Reactiva — tras temporal o tras detección de riesgo VTA elevado',
  ),
  TipoPoda(
    id: 'poda_arquitectonica',
    nombreCanonico: 'Poda arquitectónica / Formal',
    descripcion: 'Mantenimiento de formas geométricas (parasol|setos en altura|topiaria)',
    epocaRecomendada: 'Anual o bianual según la forma',
    intensidad: IntensidadPoda.alta,
    notas: 'Requiere personal experto. Frecuente en plataneras de arquitectura formal',
  ),
  TipoPoda(
    id: 'desbroce_chupones',
    nombreCanonico: 'Desbroce de chupones',
    descripcion: 'Eliminación de los chupones del tronco y zona inferior',
    epocaRecomendada: 'Primavera-verano',
    intensidad: IntensidadPoda.baja,
    notas: 'Operación frecuente en árboles jóvenes y tras podas drásticas',
  ),
  TipoPoda(
    id: 'trasmoche',
    nombreCanonico: 'Trasmoche / Desmocha',
    descripcion: 'Poda tradicional de cabeza para producir madera o forraje (NO típicamente urbana)',
    epocaRecomendada: 'Otoño-invierno',
    intensidad: IntensidadPoda.muyAlta,
    controvertida: true,
    notas: 'Práctica rural histórica. Inadecuada en arbolado urbano salvo restauración patrimonial intencionada',
  ),
];

TipoPoda? tipoPodaPorId(String id) {
  for (final t in catalogoTiposPoda) {
    if (t.id == id) return t;
  }
  return null;
}

List<TipoPoda> tiposPodaNoControvertidos() {
  return catalogoTiposPoda.where((t) => !t.controvertida).toList();
}

List<TipoPoda> buscarTiposPoda(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoTiposPoda.where((t) {
    return _normalizar(t.id).contains(consultaNormalizada) ||
        _normalizar(t.nombreCanonico).contains(consultaNormalizada);
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

