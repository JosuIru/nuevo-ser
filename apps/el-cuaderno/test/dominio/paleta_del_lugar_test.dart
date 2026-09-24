import 'package:el_cuaderno/dominio/fenologia.dart';
import 'package:el_cuaderno/dominio/paleta_del_lugar.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _pixeles(Map<List<int>, int> colores) => [
      for (final entrada in colores.entries)
        for (var i = 0; i < entrada.value; i++) ...[...entrada.key, 255],
    ];

void main() {
  test('el color más presente sale primero', () {
    final paleta = coloresDominantes(_pixeles({
      [40, 120, 40]: 300, // verde
      [200, 200, 230]: 100, // cielo
    }));
    expect(paleta.first, 0xFF287828);
    expect(paleta, hasLength(2));
  });

  test('colores casi iguales no se repiten', () {
    final paleta = coloresDominantes(_pixeles({
      [40, 120, 40]: 300,
      [44, 124, 44]: 290,
      [200, 90, 30]: 50,
    }));
    expect(paleta, hasLength(2));
  });

  test('los píxeles transparentes no cuentan', () {
    final pixeles = [0, 0, 0, 0, 0, 0, 0, 0, 10, 200, 10, 255];
    expect(coloresDominantes(pixeles), [0xFF0AC80A]);
  });

  test('determinista', () {
    final pixeles = _pixeles({
      [10, 20, 30]: 5,
      [200, 180, 160]: 5,
      [90, 140, 60]: 5,
    });
    expect(coloresDominantes(pixeles), coloresDominantes(pixeles));
  });

  test('una franja por estación con fotos, en orden desde primavera', () {
    final franjas = paletasPorEstacion([
      (fecha: DateTime(2026, 11, 2), colores: [0xFFAA6622]),
      (fecha: DateTime(2026, 4, 10), colores: [0xFF33AA33]),
      (fecha: DateTime(2026, 5, 1), colores: [0xFF3355AA]),
    ]);
    expect(franjas.map((f) => f.estacion), [Estacion.primavera, Estacion.otono]);
    expect(franjas.first.numeroFotos, 2);
    expect(franjas.first.colores, containsAll([0xFF33AA33, 0xFF3355AA]));
  });

  test('una foto sin colores no crea franja', () {
    expect(paletasPorEstacion([(fecha: DateTime(2026, 7, 1), colores: const <int>[])]), isEmpty);
  });
}
