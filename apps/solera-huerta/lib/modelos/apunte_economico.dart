/// Categorías de ingreso y de gasto (identificadores; el nombre visible
/// sale de `huer.categoria_<id>`). Las ventas van por canal: así sale el
/// margen de las cestas frente al mercado o los restaurantes.
const List<String> categoriasIngreso = [
  'venta_cestas',
  'venta_mercado',
  'venta_restaurantes',
  'venta_otros',
  'subvenciones',
  'otros_ingresos',
];
const List<String> categoriasGasto = [
  'semillas_plantel',
  'abonos_enmiendas',
  'fitosanitarios',
  'agua_riego',
  'certificacion',
  'envases_cestas',
  'gasoleo',
  'maquinaria',
  'mano_obra',
  'seguro',
  'otros_gastos',
];

/// Si la categoría es una venta de lo cosechado.
bool esCategoriaVenta(String categoria) => categoria.startsWith('venta_');

/// Tipos de IVA que ofrece la app. PROVISIONAL: el tipo de cada operación
/// lo confirma el asesor fiscal (BLOQUEOS-PENDIENTES.md).
const List<int> tiposIvaPorcentaje = [0, 4, 10, 21];

/// Un apunte del libro de ingresos y gastos. Importes en céntimos.
///
/// En REAGP no se repercute IVA; si el comprador es **empresario o
/// profesional**, paga además una compensación a tanto alzado sobre la base
/// ([compensacionReagpPorcentaje]); a un particular (socio de cestas, venta
/// en mercado) no se le carga ni IVA ni compensación (Ley 37/1992, art.
/// 130.Tres.1.º). En régimen general se repercute IVA ([tipoIvaPorcentaje]).
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
    this.compradorEmpresario = false,
    this.parcelaId,
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

  /// Solo en ventas en REAGP a empresarios o profesionales; 0 en el resto.
  final double compensacionReagpPorcentaje;

  /// El comprador es empresario o profesional (restaurante, tienda).
  final bool compradorEmpresario;

  /// Parcela a la que se imputa (opcional): margen por parcela.
  final int? parcelaId;
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
        'comprador_empresario': compradorEmpresario ? 1 : 0,
        'parcela_id': parcelaId,
        'tercero': tercero,
        'notas': notas,
      };

  factory ApunteEconomico.fromMap(Map<String, Object?> mapa) => ApunteEconomico(
        id: mapa['id'] as int?,
        esIngreso: (mapa['es_ingreso'] as int?) == 1,
        fechaMs: mapa['fecha_ms'] as int,
        concepto: (mapa['concepto'] as String?) ?? '',
        categoria: (mapa['categoria'] as String?) ?? 'otros_gastos',
        baseCentimos: (mapa['base_centimos'] as int?) ?? 0,
        tipoIvaPorcentaje: (mapa['tipo_iva_pct'] as int?) ?? 0,
        compensacionReagpPorcentaje:
            (mapa['compensacion_reagp_pct'] as num?)?.toDouble() ?? 0,
        compradorEmpresario: (mapa['comprador_empresario'] as int?) == 1,
        parcelaId: mapa['parcela_id'] as int?,
        tercero: (mapa['tercero'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
