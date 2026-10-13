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
    this.partida = '',
    this.concepto = '',
    this.importeCentimos = 0,
    this.ivaPorcentaje = 0,
    this.fechaMs = 0,
    this.notas = '',
    this.fechaCreacionMs = 0,
    this.asumidoPor = asumidoPorTester,
  });

  final int? id;
  final int fincaId;

  /// Proyecto de test al que pertenece (opcional).
  final int? proyectoId;

  /// Código de categoría: el bloque de gasto (`categoriasGasto`) o la
  /// categoría de ingreso (`categoriasIngreso`).
  final String categoria;

  /// Partida dentro del bloque de gasto: código de `partidasGasto` o texto
  /// propio del proyecto. Vacía en los ingresos.
  final String partida;

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
  /// balance del proyecto pero no en el del test. Es el bloque VI.
  bool get esAmortizacion =>
      tipo == 'gasto' && categoria == categoriaAmortizacion;

  Map<String, Object?> toMap() => {
        'id': id,
        'finca_id': fincaId,
        'proyecto_id': proyectoId,
        'tipo': tipo,
        'categoria': categoria,
        'partida': partida,
        'concepto': concepto,
        'importe_centimos': importeCentimos,
        'iva_porcentaje': ivaPorcentaje,
        'fecha_ms': fechaMs,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'asumido_por': asumidoPor,
        'es_amortizacion': esAmortizacion ? 1 : 0,
      };

  factory ApunteEconomico.fromMap(Map<String, Object?> mapa) {
    final tipo = (mapa['tipo'] as String?) ?? tipoApuntePorDefecto;
    var categoria = (mapa['categoria'] as String?) ?? '';
    var partida = (mapa['partida'] as String?) ?? '';
    if (tipo == 'gasto') {
      (categoria, partida) = normalizarCategoriaGasto(categoria, partida,
          ((mapa['es_amortizacion'] as int?) ?? 0) != 0);
    }
    return ApunteEconomico(
        id: mapa['id'] as int?,
        fincaId: (mapa['finca_id'] as int?) ?? 0,
        proyectoId: mapa['proyecto_id'] as int?,
        tipo: tipo,
        categoria: categoria,
        partida: partida,
        concepto: (mapa['concepto'] as String?) ?? '',
        importeCentimos: (mapa['importe_centimos'] as int?) ?? 0,
        ivaPorcentaje: (mapa['iva_porcentaje'] as int?) ?? 0,
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
        asumidoPor: (mapa['asumido_por'] as String?) ?? asumidoPorTester,
      );
  }
}
