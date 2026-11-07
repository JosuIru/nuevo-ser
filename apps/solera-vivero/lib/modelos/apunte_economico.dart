/// Categorías de ingreso y de gasto (identificadores; el nombre visible
/// sale de `vive.categoria_<id>`). Las ventas de planta no se apuntan aquí:
/// salen de las salidas con importe.
const List<String> categoriasIngreso = [
  'otras_ventas',
  'subvenciones',
  'otros_ingresos',
];
const List<String> categoriasGasto = [
  'semillas_material',
  'sustratos_macetas',
  'fitosanitarios',
  'abonos',
  'agua_energia',
  'mano_obra',
  'maquinaria',
  'tasas_sanidad_vegetal',
  'seguro',
  'otros_gastos',
];

/// Tipos de IVA que ofrece la app. PROVISIONAL: el tipo de cada operación
/// lo confirma el asesor fiscal (BLOQUEOS-PENDIENTES.md).
const List<int> tiposIvaPorcentaje = [0, 4, 10, 21];

/// Un apunte del libro de ingresos y gastos. Importes en céntimos.
/// (Copiado de Frutal sin la parcela.)
class ApunteEconomico {
  ApunteEconomico({
    this.id,
    required this.esIngreso,
    required this.fechaMs,
    required this.concepto,
    required this.categoria,
    required this.baseCentimos,
    this.tipoIvaPorcentaje = 0,
    this.compensacionReagpPorcentaje = 0,
    this.tercero = '',
    this.notas = '',
  });

  final int? id;
  final bool esIngreso;
  final int fechaMs;
  final String concepto;
  final String categoria;

  /// Base imponible, sin IVA ni compensación.
  final int baseCentimos;
  final int tipoIvaPorcentaje;

  /// Solo en ingresos de venta en REAGP; 0 en el resto.
  final double compensacionReagpPorcentaje;
  final String tercero;
  final String notas;

  int get cuotaIvaCentimos => (baseCentimos * tipoIvaPorcentaje / 100).round();

  int get compensacionReagpCentimos =>
      (baseCentimos * compensacionReagpPorcentaje / 100).round();

  /// Lo que se cobra o se paga: base + IVA + compensación.
  int get totalCentimos =>
      baseCentimos + cuotaIvaCentimos + compensacionReagpCentimos;

  Map<String, Object?> toMap() => {
        'id': id,
        'es_ingreso': esIngreso ? 1 : 0,
        'fecha_ms': fechaMs,
        'concepto': concepto,
        'categoria': categoria,
        'base_centimos': baseCentimos,
        'tipo_iva_pct': tipoIvaPorcentaje,
        'compensacion_reagp_pct': compensacionReagpPorcentaje,
        'tercero': tercero,
        'notas': notas,
      };

  factory ApunteEconomico.fromMap(Map<String, Object?> mapa) => ApunteEconomico(
        id: mapa['id'] as int?,
        esIngreso: (mapa['es_ingreso'] as int?) == 1,
        fechaMs: mapa['fecha_ms'] as int,
        concepto: mapa['concepto'] as String,
        categoria: mapa['categoria'] as String,
        baseCentimos: mapa['base_centimos'] as int,
        tipoIvaPorcentaje: (mapa['tipo_iva_pct'] as int?) ?? 0,
        compensacionReagpPorcentaje:
            (mapa['compensacion_reagp_pct'] as num?)?.toDouble() ?? 0,
        tercero: (mapa['tercero'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
