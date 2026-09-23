import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/canales.dart' show Celda;
import 'package:uno_roto/dominio/minijuegos/planos.dart';

void main() {
  test('rectángulo entre dos esquinas en cualquier orden', () {
    final r = Rectangulo.entre(const Celda(4, 6), const Celda(1, 2));
    expect((r.columna, r.fila, r.ancho, r.alto), (2, 1, 5, 4));
    expect(r.area, 20);
    expect(r.perimetro, 18);
  });

  test('óptimos: menor perímetro para un área y mayor área para un perímetro', () {
    expect(PartidaPlanos.perimetroMinimo(24), 20); // 4 × 6 (5 × … no)
    expect(PartidaPlanos.perimetroMinimo(36), 24); // 6 × 6
    expect(PartidaPlanos.areaMaxima(20), 25); // 5 × 5
    expect(PartidaPlanos.areaMaxima(18), 20); // 4 × 5
  });

  for (final tipo in TipoEncargo.values) {
    for (final dificultad in [1, 2, 3]) {
      test('$tipo en dificultad $dificultad: siempre hay una solución colocable', () {
        for (var semilla = 0; semilla < 30; semilla++) {
          final partida = PartidaPlanos(
              tipo: tipo, dificultad: dificultad, azar: math.Random(semilla));
          final soluciones = partida.solucionesColocables();
          expect(soluciones, isNotEmpty, reason: 'semilla $semilla');
          expect(partida.evaluar(soluciones.first), ResultadoPlano.bien);
        }
      });
    }
  }

  test('evaluar explica el tipo de error', () {
    final partida = PartidaPlanos(
        tipo: TipoEncargo.areaMinimoPerimetro, dificultad: 1, azar: math.Random(2));
    final area = partida.encargo.valor;
    // Una forma con esa área pero no la óptima (1 × n o la más alargada).
    final formas = [
      for (final (a, h) in PartidaPlanos.medidasPosibles())
        if (a * h == area) (a, h),
    ]..sort((x, y) => (x.$1 + x.$2).compareTo(y.$1 + y.$2));
    final alargada = formas.last;
    expect(partida.evaluar(Rectangulo(0, 0, alargada.$1, alargada.$2)), ResultadoPlano.noOptimo);
    expect(partida.evaluar(Rectangulo(0, 0, 1, 1)), ResultadoPlano.areaDistinta);
    expect(partida.evaluar(const Rectangulo(8, 0, 5, 1)), ResultadoPlano.fuera);
  });

  test('triángulo: la mitad del rectángulo; unidades: 100 dm² = 1 m²', () {
    final triangulo = PartidaPlanos(tipo: TipoEncargo.triangulo, dificultad: 1, azar: math.Random(1));
    expect(triangulo.encargo.areaPedida, triangulo.encargo.valor * 2);
    final unidades = PartidaPlanos(tipo: TipoEncargo.unidades, dificultad: 1, azar: math.Random(1));
    expect(unidades.encargo.valor % 100, 0);
    expect(unidades.encargo.areaPedida, unidades.encargo.valor ~/ 100);
  });

  test('la maleza no deja construir encima y, si crece, nunca cierra la última salida', () {
    final partida = PartidaPlanos(
        tipo: TipoEncargo.areaMinimoPerimetro, dificultad: 3, malezaViva: true, azar: math.Random(9));
    expect(partida.maleza, isNotEmpty);
    final hierba = partida.maleza.first;
    expect(partida.evaluar(Rectangulo(hierba.columna, hierba.fila, 1, 1)), ResultadoPlano.sobreMaleza);
    for (var i = 0; i < 40; i++) {
      partida.crecerMaleza();
      expect(partida.solucionesColocables(), isNotEmpty);
    }
  });
}
