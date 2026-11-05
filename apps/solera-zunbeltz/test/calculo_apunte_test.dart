import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/modelos/indicadores_seguimiento.dart';
import 'package:solera_zunbeltz/utiles/calculo_apunte.dart';

void main() {
  test('300 kg × 0,42 € con el 10 %: 126 + 12,60 = 138,60', () {
    final cuentas =
        cuentasApunte(cantidad: 300, precioSinIva: 0.42, ivaPorcentaje: 10);
    expect(cuentas, (base: 12600, cuota: 1260, total: 13860));
  });

  test('sin cantidad, el precio es el importe', () {
    expect(cuentasApunte(precioSinIva: 50, ivaPorcentaje: 21),
        (base: 5000, cuota: 1050, total: 6050));
  });

  test('sin IVA, total y base son lo mismo', () {
    expect(cuentasApunte(cantidad: 3, precioSinIva: 1.5, ivaPorcentaje: 0),
        (base: 450, cuota: 0, total: 450));
  });

  test('la cuota coincide con la que saca el informe del total', () {
    for (final (cantidad, precio, iva) in [
      (7.0, 0.33, 10),
      (13.0, 2.17, 21),
      (1.0, 0.99, 4),
    ]) {
      final cuentas = cuentasApunte(
          cantidad: cantidad, precioSinIva: precio, ivaPorcentaje: iva);
      expect(cuentas.cuota, cuotaIva(cuentas.total, iva));
      expect(cuentas.base + cuentas.cuota, cuentas.total);
    }
  });
}
