/// Categorías de ingreso y de gasto (identificadores; el nombre visible
/// sale de `obra.categoria_<id>`).
const List<String> categoriasIngreso = [
  'venta_mostrador',
  'venta_pedidos',
  'otros_ingresos'
];
const List<String> categoriasGasto = [
  'materia_prima',
  'envases',
  'energia',
  'alquiler',
  'personal',
  'maquinaria',
  'otros_gastos',
];

/// Tipos de IVA que ofrece la app. PROVISIONAL: el tipo de cada producto lo
/// confirma el asesor fiscal (BLOQUEOS-PENDIENTES.md).
const List<int> tiposIvaPorcentaje = [0, 4, 10, 21];

/// Un apunte del libro de ingresos y gastos. Importes en céntimos.
class ApunteEconomico {
  ApunteEconomico({
    this.id,
    required this.esIngreso,
    required this.fechaMs,
    required this.concepto,
    required this.categoria,
    required this.baseCentimos,
    this.tipoIvaPorcentaje = 0,
    this.tercero = '',
    this.notas = '',
  });

  final int? id;
  final bool esIngreso;
  final int fechaMs;
  final String concepto;
  final String categoria;

  /// Base imponible, sin IVA.
  final int baseCentimos;
  final int tipoIvaPorcentaje;
  final String tercero;
  final String notas;

  int get cuotaIvaCentimos => (baseCentimos * tipoIvaPorcentaje / 100).round();

  int get totalCentimos => baseCentimos + cuotaIvaCentimos;

  Map<String, Object?> toMap() => {
        'id': id,
        'es_ingreso': esIngreso ? 1 : 0,
        'fecha_ms': fechaMs,
        'concepto': concepto,
        'categoria': categoria,
        'base_centimos': baseCentimos,
        'tipo_iva_pct': tipoIvaPorcentaje,
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
        tercero: (mapa['tercero'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
