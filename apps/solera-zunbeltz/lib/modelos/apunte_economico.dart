import 'constantes.dart';

/// Un apunte económico simple del seguimiento: un ingreso o un gasto, con
/// concepto e importe. No es contabilidad fiscal (eso es FZ-8, REAGP, con
/// asesor) — solo el seguimiento de costes e ingresos que pide el testaje.
class ApunteEconomico {
  ApunteEconomico({
    this.id,
    required this.fincaId,
    this.proyectoId,
    this.tipo = tipoApuntePorDefecto,
    this.categoria = '',
    this.concepto = '',
    this.importeCentimos = 0,
    this.ivaPorcentaje = 0,
    this.fechaMs = 0,
    this.notas = '',
    this.fechaCreacionMs = 0,
    this.asumidoPor = asumidoPorTester,
    this.esAmortizacion = false,
  });

  final int? id;
  final int fincaId;

  /// Proyecto de test al que pertenece (opcional).
  final int? proyectoId;

  /// Código de categoría (`categoriasGasto` / `categoriasIngreso`).
  final String categoria;

  /// Tipo de IVA aplicado (%); 0 = sin IVA. El importe es el total (con IVA).
  final int ivaPorcentaje;

  /// Código de `tiposApunte` (ingreso / gasto).
  final String tipo;

  final String concepto;

  /// Importe en céntimos (entero, para evitar imprecisión de coma flotante).
  final int importeCentimos;

  final int fechaMs;
  final String notas;
  final int fechaCreacionMs;

  /// Quién asume el gasto: `tester` o `zunbeltz` (convenio, art. 7).
  final String asumidoPor;

  /// Cuota de amortización (infraestructura, material): cuenta en el
  /// balance del proyecto pero no en el del test.
  final bool esAmortizacion;

  Map<String, Object?> toMap() => {
        'id': id,
        'finca_id': fincaId,
        'proyecto_id': proyectoId,
        'tipo': tipo,
        'categoria': categoria,
        'concepto': concepto,
        'importe_centimos': importeCentimos,
        'iva_porcentaje': ivaPorcentaje,
        'fecha_ms': fechaMs,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'asumido_por': asumidoPor,
        'es_amortizacion': esAmortizacion ? 1 : 0,
      };

  factory ApunteEconomico.fromMap(Map<String, Object?> mapa) => ApunteEconomico(
        id: mapa['id'] as int?,
        fincaId: (mapa['finca_id'] as int?) ?? 0,
        proyectoId: mapa['proyecto_id'] as int?,
        tipo: (mapa['tipo'] as String?) ?? tipoApuntePorDefecto,
        categoria: (mapa['categoria'] as String?) ?? '',
        concepto: (mapa['concepto'] as String?) ?? '',
        importeCentimos: (mapa['importe_centimos'] as int?) ?? 0,
        ivaPorcentaje: (mapa['iva_porcentaje'] as int?) ?? 0,
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
        asumidoPor: (mapa['asumido_por'] as String?) ?? asumidoPorTester,
        esAmortizacion: ((mapa['es_amortizacion'] as int?) ?? 0) != 0,
      );
}
