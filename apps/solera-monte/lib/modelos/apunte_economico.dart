/// Categorías de ingreso y de gasto del monte (identificadores; el nombre
/// visible sale de `mont.categoria_<id>`). PROVISIONAL hasta el asesor fiscal.
const List<String> categoriasIngreso = [
  'venta_madera',
  'venta_lena',
  'lotes_vecinales',
  'pastos',
  'caza',
  'hongos_frutos',
  'otros_aprovechamientos',
  'ayudas',
  'otros_ingresos',
];
const List<String> categoriasGasto = [
  'trabajos_selvicolas',
  'prevencion_incendios',
  'pistas',
  'repoblacion',
  'asistencia_tecnica',
  'certificacion',
  'seguros',
  'tasas_tramites',
  'gestion_comunidad',
  'otros_gastos',
];

/// Tipos de IVA que ofrece la app. PROVISIONAL: el tipo de cada operación
/// lo confirma el asesor fiscal (BLOQUEOS-PENDIENTES.md).
const List<int> tiposIvaPorcentaje = [0, 4, 10, 21];

/// Un apunte del libro de ingresos y gastos del monte. Importes en céntimos.
///
/// En una venta en régimen especial agrario (REAGP) no se repercute IVA:
/// el comprador paga una **compensación** a tanto alzado sobre la base
/// ([compensacionReagpPorcentaje]). Solo lo propone la app a un particular
/// en REAGP; la fiscalidad de una comunidad de montes o de una junta
/// vecinal está **por verificar**.
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
    this.rodalId,
    this.aprovechamientoId,
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

  /// Solo en ventas de un particular en REAGP; 0 en el resto.
  final double compensacionReagpPorcentaje;

  /// Rodal o aprovechamiento al que se imputa (opcional).
  final int? rodalId;
  final int? aprovechamientoId;

  /// Comprador, rematante, empresa o administración.
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
        'rodal_id': rodalId,
        'aprovechamiento_id': aprovechamientoId,
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
        rodalId: mapa['rodal_id'] as int?,
        aprovechamientoId: mapa['aprovechamiento_id'] as int?,
        tercero: (mapa['tercero'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
