import 'dart:math' as math;

import 'package:fichas_imprimibles/fichas_imprimibles.dart';
import 'package:test/test.dart';

/// Ejecuta un generador con una semilla y devuelve sus ejercicios.
List<Ejercicio> _muestras(String id, {int semilla = 7, int cantidad = 40}) {
  final azar = math.Random(semilla);
  return List.generate(cantidad, (_) => plantillasPorHabilidad[id]!.generar(azar));
}

void main() {
  final catalogo = cargarCatalogo(rutaSkillsPorDefecto(localizarRaizPaquete()!));

  group('utilidades', () {
    test('fracciones', () {
      expect((Fraccion(1, 2) + Fraccion(1, 3)).texto, '5/6');
      expect((Fraccion(1, 2) - Fraccion(3, 4)).texto, '−1/4');
      expect((Fraccion(2, 3) / Fraccion(4, 5)).texto, '5/6');
      expect(Fraccion(6, 8).simplificada().texto, '3/4');
      expect(Fraccion(3, -4).texto, '−3/4');
      expect(Fraccion(8, 4).simplificada().texto, '2');
    });

    test('formato español de números', () {
      expect(formatearDecimal(2.5), '2,5');
      expect(formatearDecimal(0.1 + 0.2), '0,3');
      expect(formatearDecimal(-1.25), '−1,25');
      expect(formatearDecimal(3.0), '3');
      expect(formatearEntero(2500), '2500');
      expect(formatearEntero(12500), '12 500');
      expect(formatearEntero(-7), '−7');
    });

    test('hash estable (no depende de la ejecución)', () {
      expect(hashEstable('FR.10#1'), hashEstable('FR.10#1'));
      expect(hashEstable('FR.10#1'), isNot(hashEstable('FR.10#2')));
      expect(hashEstable(''), 0x811c9dc5);
    });
  });

  group('todas las plantillas', () {
    for (final plantilla in plantillasPorHabilidad.values) {
      test('${plantilla.idHabilidad}: deterministas, con texto y solución', () {
        final primera = _muestras(plantilla.idHabilidad).map((e) => e.clave).toList();
        final segunda = _muestras(plantilla.idHabilidad).map((e) => e.clave).toList();
        expect(primera, segunda, reason: 'misma semilla, mismos ejercicios');

        for (final ejercicio in _muestras(plantilla.idHabilidad, semilla: 99)) {
          expect(ejercicio.enunciado.trim(), isNotEmpty);
          expect(ejercicio.solucion.trim(), isNotEmpty);
          expect(ejercicio.renglones, inInclusiveRange(1, 6));
          final todo = '${ejercicio.enunciado} ${ejercicio.destacado ?? ''} ${ejercicio.solucion}';
          expect(todo, isNot(contains('NaN')));
          expect(todo, isNot(contains('Infinity')));
          expect(todo, isNot(contains('null')));
          // Coma decimal española: nada de «2.5».
          expect(RegExp(r'\d\.\d').hasMatch(todo), isFalse, reason: todo);
        }
        expect(plantilla.descripcion.length, greaterThan(40));
        expect(plantilla.preguntaExplicalo, matches(RegExp(r'[?.]$')));
      });
    }
  });

  group('contenido de la ficha', () {
    test('misma semilla = misma ficha; otra semilla, otra ficha', () {
      final habilidad = catalogo.porId('FR.10')!;
      String huella(int semilla) => generarContenidoFicha(catalogo, habilidad, semilla: semilla)
          .ejercicios
          .map((e) => e.clave)
          .join('\n');
      expect(huella(1), huella(1));
      expect(huella(1), isNot(huella(2)));
    });

    test('tres ejercicios distintos por ficha', () {
      for (final id in plantillasPorHabilidad.keys) {
        final ficha = generarContenidoFicha(catalogo, catalogo.porId(id)!);
        expect(ficha.ejercicios, hasLength(3), reason: id);
        expect(ficha.ejercicios.map((e) => e.clave).toSet(), hasLength(3), reason: id);
      }
    });

    test('la ficha no depende del lote en que se pide', () {
      final sola = generarContenidoFicha(catalogo, catalogo.porId('DEC.04')!, semilla: 5);
      generarContenidoFicha(catalogo, catalogo.porId('FR.10')!, semilla: 5);
      final otraVez = generarContenidoFicha(catalogo, catalogo.porId('DEC.04')!, semilla: 5);
      expect(sola.ejercicios.map((e) => e.clave), otraVez.ejercicios.map((e) => e.clave));
    });
  });

  group('soluciones correctas en casos concretos', () {
    test('FR.10 simplifica a forma irreducible', () {
      for (final ejercicio in _muestras('FR.10')) {
        final partes = ejercicio.solucion.split('/').map(int.parse).toList();
        expect(mcd(partes[0], partes[1]), 1);
      }
    });

    test('DEC.09 redondea a las décimas', () {
      for (final ejercicio in _muestras('DEC.09')) {
        final original = double.parse(ejercicio.destacado!.split(' ').first.replaceAll(',', '.'));
        final redondeado = double.parse(ejercicio.solucion.replaceAll(',', '.'));
        expect((original - redondeado).abs(), lessThanOrEqualTo(0.05 + 1e-9));
      }
    });

    test('DIV.05 marca como primos solo los primos', () {
      for (final ejercicio in _muestras('DIV.05')) {
        final rodeados = ejercicio.solucion.split(', ').map(int.parse);
        expect(rodeados, isNotEmpty);
        for (final numero in rodeados) {
          expect([2, 3, 5, 7].where((p) => p < numero && numero % p == 0), isEmpty);
        }
      }
    });

    test('factorización y regla de tres', () {
      expect(factorizacion(60), '2^{2} · 3 · 5');
      expect(factorizacion(13), '13');
      for (final ejercicio in _muestras('PROP.03')) {
        expect(int.parse(ejercicio.solucion), greaterThan(0));
      }
    });

    test('OP.01: la solución respeta la jerarquía', () {
      for (final ejercicio in _muestras('OP.01')) {
        final expresion = ejercicio.destacado!.replaceAll(' =', '');
        expect(formatearEntero(_evaluar(expresion)), ejercicio.solucion, reason: expresion);
      }
    });

    test('EST.03: la media de los datos es exacta y coincide', () {
      for (final ejercicio in _muestras('EST.03')) {
        final datos = ejercicio.destacado!.split(',').map((d) => int.parse(d.trim())).toList();
        final suma = datos.reduce((a, b) => a + b);
        expect(suma % datos.length, 0);
        expect(ejercicio.solucion, '${suma ~/ datos.length}');
      }
    });

    test('polinomios con signos y exponentes bien escritos', () {
      expect(formatearPolinomio({2: 3, 1: -2, 0: 1}), '3x^{2} − 2x + 1');
      expect(formatearPolinomio({2: -1, 0: -9}), '−x^{2} − 9');
      expect(formatearPolinomio({1: 1, 0: 0}), 'x');
      expect(formatearPolinomio({3: 0}), '0');
    });

    test('ALG.10: las soluciones anulan la ecuación', () {
      for (final ejercicio in _muestras('ALG.10')) {
        final soluciones = RegExp(r'x = (−?\d+)')
            .allMatches(ejercicio.solucion)
            .map((m) => int.parse(m[1]!.replaceAll('−', '-')))
            .toList();
        expect(soluciones, hasLength(2));
        final suma = soluciones[0] + soluciones[1];
        final producto = soluciones[0] * soluciones[1];
        expect(ejercicio.destacado, '${formatearPolinomio({2: 1, 1: -suma, 0: producto})} = 0');
      }
    });

    test('palabras de números y fracciones', () {
      expect(numeroEnPalabras(21, femenino: true), 'veintiuna');
      expect(numeroEnPalabras(31, femenino: true), 'treinta y una');
      expect(numeroEnPalabras(16), 'dieciséis');
      expect(fraccionEnPalabras(3, 5), 'tres quintos');
      expect(fraccionEnPalabras(1, 2), 'un medio');
    });
  });
}

/// Evaluador mínimo con jerarquía (enteros, + − × : y paréntesis) para
/// comprobar OP.01 por un camino distinto al del generador.
int _evaluar(String expresion) {
  final fichas = RegExp(r'\d+|[+−×:()]').allMatches(expresion).map((m) => m[0]!).toList();
  var posicion = 0;
  late int Function() suma;
  int factor() {
    final ficha = fichas[posicion++];
    if (ficha == '(') {
      final valor = suma();
      posicion++;
      return valor;
    }
    return int.parse(ficha);
  }

  int producto() {
    var valor = factor();
    while (posicion < fichas.length && (fichas[posicion] == '×' || fichas[posicion] == ':')) {
      final operador = fichas[posicion++];
      final derecho = factor();
      valor = operador == '×' ? valor * derecho : valor ~/ derecho;
    }
    return valor;
  }

  suma = () {
    var valor = producto();
    while (posicion < fichas.length && (fichas[posicion] == '+' || fichas[posicion] == '−')) {
      final operador = fichas[posicion++];
      final derecho = producto();
      valor = operador == '+' ? valor + derecho : valor - derecho;
    }
    return valor;
  };
  return suma();
}
