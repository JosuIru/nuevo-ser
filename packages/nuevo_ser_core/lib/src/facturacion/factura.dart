/// Factura emitida — conforme al Reglamento de Facturación
/// (RD 1619/2012) español. Modelo común de la Suite Solera (agro,
/// viticultura, apícola, arbolado urbano y quesera tenían copias
/// idénticas en `lib/modelos/factura.dart`).
///
/// `numeroFactura` sigue una serie secuencial (ej. 2026-0001,
/// 2026-0002...). El receptor puede ser un tercero con NIF (modelo 347)
/// o un particular (venta directa, NIF opcional).
///
/// `lineasJson` guarda el detalle de líneas de la factura:
/// `[{"descripcion", "cantidad", "precioUnitario", "importe"}]`.
///
/// `estado`: emitida / pagada / vencida / anulada.
///
/// **Formato de BD fijo**: [toMap] y [Factura.fromMap] leen y escriben
/// exactamente las columnas de la tabla `facturas` que las apps ya
/// tienen con datos guardados. No cambiar nombres ni valores por defecto.
class Factura {
  final int? id;
  final String numeroFactura;
  final int fechaEmisionMs;
  final int? fechaVencimientoMs;
  final int? fechaPagoMs;
  final String clienteNombre;
  final String clienteNif;
  final String clienteDireccion;
  final String lineasJson;
  final double baseImponible;
  final double ivaPorcentaje;
  final double total;
  final String estado;
  final String notas;
  final int fechaCreacionMs;

  Factura({
    this.id,
    required this.numeroFactura,
    required this.fechaEmisionMs,
    this.fechaVencimientoMs,
    this.fechaPagoMs,
    this.clienteNombre = '',
    this.clienteNif = '',
    this.clienteDireccion = '',
    this.lineasJson = '[]',
    this.baseImponible = 0,
    this.ivaPorcentaje = 10,
    this.total = 0,
    this.estado = 'emitida',
    this.notas = '',
    required this.fechaCreacionMs,
  });

  /// Cuota de IVA calculada sobre la base imponible (no se guarda).
  double get cuotaIva => baseImponible * ivaPorcentaje / 100;

  Map<String, Object?> toMap() => {
        'id': id,
        'numero_factura': numeroFactura,
        'fecha_emision_ms': fechaEmisionMs,
        'fecha_vencimiento_ms': fechaVencimientoMs,
        'fecha_pago_ms': fechaPagoMs,
        'cliente_nombre': clienteNombre,
        'cliente_nif': clienteNif,
        'cliente_direccion': clienteDireccion,
        'lineas_json': lineasJson,
        'base_imponible': baseImponible,
        'iva_porcentaje': ivaPorcentaje,
        'total': total,
        'estado': estado,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory Factura.fromMap(Map<String, Object?> mapa) => Factura(
        id: mapa['id'] as int?,
        numeroFactura: (mapa['numero_factura'] as String?) ?? '',
        fechaEmisionMs: mapa['fecha_emision_ms'] as int,
        fechaVencimientoMs: mapa['fecha_vencimiento_ms'] as int?,
        fechaPagoMs: mapa['fecha_pago_ms'] as int?,
        clienteNombre: (mapa['cliente_nombre'] as String?) ?? '',
        clienteNif: (mapa['cliente_nif'] as String?) ?? '',
        clienteDireccion: (mapa['cliente_direccion'] as String?) ?? '',
        lineasJson: (mapa['lineas_json'] as String?) ?? '[]',
        baseImponible: (mapa['base_imponible'] as num?)?.toDouble() ?? 0,
        ivaPorcentaje: (mapa['iva_porcentaje'] as num?)?.toDouble() ?? 10,
        total: (mapa['total'] as num?)?.toDouble() ?? 0,
        estado: (mapa['estado'] as String?) ?? 'emitida',
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
