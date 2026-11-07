/// Categorías de ingreso y de gasto de una explotación ganadera extensiva
/// (identificadores; el nombre visible sale de `gana.categoria_<id>`).
const List<String> categoriasIngreso = [
  'venta_animales',
  'venta_carne',
  'venta_leche',
  'venta_lana',
  'ayudas',
  'otros_ingresos',
];
const List<String> categoriasGasto = [
  'piensos_forraje',
  'veterinario',
  'medicamentos',
  'arrendamiento_pastos',
  'combustible',
  'maquinaria',
  'seguros',
  'otros_gastos',
];

/// Cómo se cobra o paga: con IVA (régimen general) o con la compensación a
/// tanto alzado del REAGP (solo en ingresos).
const String regimenIva = 'iva';
const String regimenReagp = 'reagp';

/// Tipos de IVA que ofrece la app. PROVISIONAL: el de cada operación lo
/// confirma el asesor fiscal (BLOQUEOS-PENDIENTES.md).
const List<double> tiposIvaPorcentaje = [0, 4, 10, 21];

/// Compensación REAGP de las actividades ganaderas que la app propone.
/// **Por verificar** con el asesor fiscal en la Ley 37/1992, art. 130 (y las
/// normas que la cambian cada año): editable en cada apunte.
const double compensacionReagpGanaderaPorDefecto = 10.5;

/// Un apunte del libro de ingresos y gastos. Importes en céntimos.
class ApunteEconomico {
  ApunteEconomico({
    this.id,
    required this.esIngreso,
    required this.fechaMs,
    required this.concepto,
    required this.categoria,
    required this.baseCentimos,
    this.regimen = regimenIva,
    this.porcentaje = 0,
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

  /// [regimenIva] o [regimenReagp].
  final String regimen;

  /// Tipo de IVA o porcentaje de compensación REAGP.
  final double porcentaje;
  final String tercero;
  final String notas;

  bool get esReagp => regimen == regimenReagp;

  /// Cuota de IVA o compensación.
  int get cuotaCentimos => (baseCentimos * porcentaje / 100).round();

  int get totalCentimos => baseCentimos + cuotaCentimos;

  Map<String, Object?> toMap() => {
        'id': id,
        'es_ingreso': esIngreso ? 1 : 0,
        'fecha_ms': fechaMs,
        'concepto': concepto,
        'categoria': categoria,
        'base_centimos': baseCentimos,
        'regimen': regimen,
        'porcentaje': porcentaje,
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
        regimen: (mapa['regimen'] as String?) ?? regimenIva,
        porcentaje: (mapa['porcentaje'] as num?)?.toDouble() ?? 0,
        tercero: (mapa['tercero'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
