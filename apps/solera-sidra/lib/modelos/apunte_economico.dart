/// Categorías de ingreso. La primera es la única que puede ir al REAGP
/// (fruta propia vendida sin transformar); el resto es transformación o
/// servicio. PROVISIONAL hasta el asesor fiscal.
const List<String> categoriasIngreso = [
  'venta_manzana',
  'venta_sidra_botella',
  'venta_sidra_hosteleria',
  'venta_txotx',
  'venta_txakoli',
  'otros_ingresos',
];

const List<String> categoriasGasto = [
  'compra_manzana',
  'envases',
  'contraetiquetas_dop',
  'fitosanitarios',
  'energia',
  'personal',
  'maquinaria',
  'cuotas',
  'otros_gastos',
];

/// Categorías que son actividad agraria (fruta propia sin transformar).
const Set<String> categoriasActividadAgraria = {'venta_manzana'};

/// Tipos de IVA que ofrece la app. PROVISIONAL.
const List<int> tiposIvaPorcentaje = [0, 4, 10, 21];

/// Compensación del REAGP sobre la base, en %, para productos agrícolas
/// (LIVA art. 130.Tres; ver BLOQUEOS-PENDIENTES.md). PROVISIONAL.
const int porcentajeCompensacionReagpAgricola = 12;

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
    this.conCompensacionReagp = false,
    this.tercero = '',
    this.notas = '',
  });

  final int? id;
  final bool esIngreso;
  final int fechaMs;
  final String concepto;
  final String categoria;

  /// Base, sin IVA ni compensación.
  final int baseCentimos;
  final int tipoIvaPorcentaje;

  /// Venta de fruta propia en el REAGP: el comprador paga la compensación
  /// en vez del IVA.
  final bool conCompensacionReagp;
  final String tercero;
  final String notas;

  int get cuotaIvaCentimos => conCompensacionReagp
      ? 0
      : (baseCentimos * tipoIvaPorcentaje / 100).round();

  int get compensacionReagpCentimos => conCompensacionReagp
      ? (baseCentimos * porcentajeCompensacionReagpAgricola / 100).round()
      : 0;

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
        'compensacion_reagp': conCompensacionReagp ? 1 : 0,
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
        conCompensacionReagp: (mapa['compensacion_reagp'] as int?) == 1,
        tercero: (mapa['tercero'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
