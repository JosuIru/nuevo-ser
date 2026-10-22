import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/src/facturacion/factura.dart';

void main() {
  // Fila tal como la guardan hoy agro/viticultura/apícola/arbolado/quesera
  // en la tabla `facturas` (sqflite devuelve int y double sueltos).
  final filaGuardada = <String, Object?>{
    'id': 7,
    'numero_factura': '2026-0003',
    'fecha_emision_ms': 1767225600000,
    'fecha_vencimiento_ms': 1769817600000,
    'fecha_pago_ms': null,
    'cliente_nombre': 'Bodega Ejemplo S.L.',
    'cliente_nif': 'B12345678',
    'cliente_direccion': 'Calle Mayor 1, Estella',
    'lineas_json':
        '[{"descripcion":"Poda","cantidad":2.5,"precioUnitario":40.0,"importe":100.0}]',
    'base_imponible': 100.0,
    'iva_porcentaje': 21.0,
    'total': 121.0,
    'estado': 'emitida',
    'notas': '',
    'fecha_creacion_ms': 1767225600000,
  };

  test('ida y vuelta: fromMap → toMap devuelve exactamente la misma fila', () {
    final factura = Factura.fromMap(filaGuardada);
    expect(factura.toMap(), equals(filaGuardada));
    expect(factura.cuotaIva, closeTo(21, 1e-9));
  });

  test('columnas que faltan o en null toman los valores de siempre', () {
    final factura = Factura.fromMap({'fecha_emision_ms': 1, 'total': 5});
    expect(factura.numeroFactura, '');
    expect(factura.lineasJson, '[]');
    expect(factura.ivaPorcentaje, 10);
    expect(factura.total, 5.0);
    expect(factura.estado, 'emitida');
    expect(factura.fechaCreacionMs, 0);
  });

  test('toMap guarda las mismas columnas que las apps (sin id al insertar)',
      () {
    final factura = Factura(
        numeroFactura: '2026-0001', fechaEmisionMs: 10, fechaCreacionMs: 10);
    final mapa = factura.toMap()..remove('id');
    expect(mapa.keys.toSet(), filaGuardada.keys.toSet()..remove('id'));
    expect(mapa['iva_porcentaje'], 10.0);
  });
}
