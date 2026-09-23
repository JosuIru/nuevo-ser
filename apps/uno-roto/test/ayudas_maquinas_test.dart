import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/minijuegos/ayudas_maquinas.dart';
import 'package:uno_roto/dominio/minijuegos/balanza.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';

void main() {
  test('todas las habilidades de las máquinas tienen truco', () {
    for (final definicion in CatalogoMinijuegos.todos) {
      for (final habilidad in definicion.habilidades) {
        expect(trucosPorHabilidad.containsKey(habilidad), isTrue,
            reason: '${definicion.nombre}: $habilidad');
      }
    }
  });

  test('ejemplo del enunciado: 3x + 2 = x + 10', () {
    const ecuacion = EcuacionBalanza(idHabilidad: 'ALG.02', bolsasIzquierda: 3,
        pesasIzquierda: 2, bolsasDerecha: 1, pesasDerecha: 10, solucion: 4);
    final pasos = pasosDespejar(ecuacion);
    expect(pasos.map((p) => p.ecuacion), ['2x + 2 = 10', '2x = 8', 'x = 4']);
  });

  for (final id in ['ALG.01', 'ALG.02']) {
    test('$id: cada paso conserva el equilibrio y el último da la solución', () {
      for (var semilla = 0; semilla < 80; semilla++) {
        final ecuacion =
            GeneradorBalanza(azar: math.Random(semilla)).generar(id, dificultad: 3);
        final pasos = pasosDespejar(ecuacion);
        for (final paso in pasos) {
          final izquierda = paso.bolsasIzquierda * ecuacion.solucion + paso.pesasIzquierda;
          final derecha = paso.bolsasDerecha * ecuacion.solucion + paso.pesasDerecha;
          expect(izquierda, derecha, reason: '${ecuacion.texto} → ${paso.ecuacion}');
        }
        expect(pasos.last.ecuacion, 'x = ${ecuacion.solucion}');
        expect(pasos.last.valor, ecuacion.solucion);
      }
    });
  }
}
