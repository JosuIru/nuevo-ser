import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/dominio/composicion_cestas.dart';

void main() {
  test('con cosecha real se usa la real, por piezas si toca', () {
    final resultado = existenciasParaReparto(
      real: {5: (kg: 3.0, unidades: 0), 2: (kg: 1.0, unidades: 12)},
      prevista: {9: 10},
      porUnidades: (id) => id == 2,
    );
    expect(resultado.fuente, FuenteReparto.real);
    expect(resultado.existencias.map((e) => e.cultivoId), [2, 5]);
    expect(resultado.existencias.first.unidades, 12);
    expect(resultado.existencias.last.kg, 3);
  });

  test('sin piezas apuntadas, en kilos aunque se reparta por piezas', () {
    final resultado = existenciasParaReparto(
      real: {2: (kg: 1.5, unidades: 0)},
      prevista: const {},
      porUnidades: (_) => true,
    );
    expect(resultado.existencias.single.kg, 1.5);
  });

  test('sin real, la prevista en kilos; sin nada, nada', () {
    final prevista = existenciasParaReparto(
        real: const {}, prevista: {3: 4.5, 1: 0}, porUnidades: (_) => true);
    expect(prevista.fuente, FuenteReparto.prevista);
    expect(prevista.existencias.single.kg, 4.5);
    final nada = existenciasParaReparto(
        real: const {}, prevista: const {}, porUnidades: (_) => false);
    expect(nada.fuente, FuenteReparto.nada);
  });
}
