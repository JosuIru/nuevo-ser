import 'dart:math' as math;

import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas de los dominios DIV (divisibilidad y primos) y OP (operaciones
/// integradas).

bool esPrimo(int numero) {
  if (numero < 2) return false;
  for (var divisor = 2; divisor * divisor <= numero; divisor++) {
    if (numero % divisor == 0) return false;
  }
  return true;
}

List<int> divisoresDe(int numero) =>
    [for (var d = 1; d <= numero; d++) if (numero % d == 0) d];

/// «2^{2} · 3 · 5» para 60.
String factorizacion(int numero) {
  final factores = <int, int>{};
  var resto = numero;
  for (var primo = 2; resto > 1; primo++) {
    while (resto % primo == 0) {
      factores[primo] = (factores[primo] ?? 0) + 1;
      resto ~/= primo;
    }
  }
  return factores.entries
      .map((f) => f.value == 1 ? '${f.key}' : potencia('${f.key}', f.value))
      .join(' · ');
}

/// Rodear los divisibles entre [divisor] en una lista de seis números.
Ejercicio _rodearDivisibles(math.Random azar, int divisor, {int maximo = 999}) {
  final numeros = <int>{};
  // Al menos dos que sí y dos que no, para que haya que pensar.
  while (numeros.where((n) => n % divisor == 0).length < 2) {
    numeros.add(divisor * azar.entre(10, maximo ~/ divisor));
  }
  while (numeros.length < 6) {
    final candidato = azar.entre(100, maximo);
    if (candidato % divisor != 0 || numeros.where((n) => n % divisor != 0).length >= 3) {
      numeros.add(candidato);
    }
  }
  final lista = azar.barajar(numeros.toList());
  return Ejercicio(
    enunciado: 'Rodea los números divisibles entre $divisor sin hacer la división. '
        'Escribe qué criterio has usado.',
    destacado: lista.join('     '),
    solucion: lista.where((n) => n % divisor == 0).join(', '),
    renglones: 2,
  );
}

/// Expresión «a ○ b ○ c» con su valor respetando la jerarquía.
(String, int) _expresionJerarquia(math.Random azar) {
  while (true) {
    final a = azar.entre(2, 12);
    final b = azar.entre(2, 9);
    final c = azar.entre(2, 9);
    final forma = azar.nextInt(4);
    switch (forma) {
      case 0:
        final valor = a + b * c;
        if ((a + b) * c != valor) return ('$a + $b × $c', valor);
      case 1:
        // De izquierda a derecha daría (minuendo − b) × c: otro número.
        final minuendo = b * c + a;
        return ('$minuendo − $b × $c', a);
      case 2:
        final dividendo = b * c;
        final valor = a + dividendo ~/ b;
        if ((a + dividendo) % b != 0 || (a + dividendo) ~/ b != valor) {
          return ('$a + $dividendo : $b', valor);
        }
      default:
        final d = azar.entre(2, 5);
        return ('($a + $b) × $d − $c', (a + b) * d - c);
    }
  }
}

final List<PlantillaFicha> plantillasDivisibilidadOperaciones = [
  PlantillaFicha(
    idHabilidad: 'DIV.01',
    descripcion:
        'Los múltiplos de un número son los que salen al multiplicarlo por 1, 2, 3, 4… '
        'Los múltiplos de 4 son 4, 8, 12, 16… y no se acaban nunca.',
    preguntaExplicalo: '¿Por qué un número tiene infinitos múltiplos pero no infinitos divisores?',
    generar: (azar) {
      final numero = azar.entre(3, 15);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Escribe los seis primeros múltiplos de $numero.',
          solucion: List.generate(6, (i) => numero * (i + 1)).join(', '),
          renglones: 2,
        );
      }
      final candidato = numero * azar.entre(4, 12) + (azar.nextBool() ? 0 : azar.entre(1, numero - 1));
      return Ejercicio(
        enunciado: '¿Es $candidato múltiplo de $numero? Responde sí o no y explica por qué.',
        solucion: candidato % numero == 0 ? 'sí' : 'no',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.02',
    descripcion:
        'Los divisores de un número son los que lo dividen exactamente, sin resto. Se buscan '
        'por parejas: 18 = 1 × 18 = 2 × 9 = 3 × 6, así que sus divisores son 1, 2, 3, 6, 9 y 18.',
    preguntaExplicalo: '¿Cómo sabes que ya has encontrado todos los divisores de un número?',
    generar: (azar) {
      final numero = azar.elegir([12, 16, 18, 20, 24, 28, 30, 32, 36, 40, 42, 45, 48, 50, 60]);
      return Ejercicio(
        enunciado: 'Escribe todos los divisores de $numero.',
        solucion: divisoresDe(numero).join(', '),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.03',
    descripcion:
        'Un número es divisible entre 2 si acaba en cifra par; entre 5 si acaba en 0 o 5; '
        'entre 10 si acaba en 0; y entre 3 si la suma de sus cifras es múltiplo de 3.',
    preguntaExplicalo: '¿Por qué crees que basta mirar la última cifra para saber si un número es par?',
    generar: (azar) => _rodearDivisibles(azar, azar.elegir([2, 3, 5, 10])),
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.04',
    descripcion:
        'Divisible entre 4: sus dos últimas cifras forman un múltiplo de 4. Entre 9: la suma de '
        'sus cifras es múltiplo de 9. Entre 6: es divisible entre 2 y entre 3 a la vez.',
    preguntaExplicalo: '¿Por qué para ser divisible entre 6 hay que serlo entre 2 y entre 3?',
    generar: (azar) => _rodearDivisibles(azar, azar.elegir([4, 6, 9]), maximo: 2000),
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.05',
    descripcion:
        'Un número primo solo tiene dos divisores: el 1 y él mismo (2, 3, 5, 7, 11…). Si tiene '
        'más, es compuesto. El 1 no es primo ni compuesto.',
    preguntaExplicalo: '¿Por qué el 2 es el único número primo par?',
    generar: (azar) {
      final numeros = <int>{};
      while (numeros.length < 8) {
        numeros.add(azar.elegir([
          azar.entre(2, 60),
          azar.elegir([1, 9, 15, 21, 25, 27, 33, 35, 39, 49, 51, 57]),
        ]));
      }
      if (!numeros.any(esPrimo)) numeros.add(azar.elegir([13, 17, 23, 29, 31, 37]));
      final lista = numeros.toList()..sort();
      return Ejercicio(
        enunciado: 'Rodea los números primos:',
        destacado: lista.join('    '),
        solucion: lista.where(esPrimo).join(', '),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.06',
    descripcion:
        'El máximo común divisor (m.c.d.) de dos números es el mayor número que divide a los '
        'dos. Sirve para repartir en grupos iguales lo más grandes posible.',
    preguntaExplicalo: 'Pon un ejemplo de la vida real en el que necesites el m.c.d.',
    generar: (azar) {
      final comun = azar.entre(2, 9);
      late int a, b;
      do {
        a = comun * azar.entre(2, 8);
        b = comun * azar.entre(2, 8);
      } while (a == b);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Calcula el máximo común divisor:',
          destacado: 'm.c.d.($a, $b) =',
          solucion: '${mcd(a, b)}',
          renglones: 3,
        );
      }
      return Ejercicio(
        enunciado: 'Tenemos $a lápices rojos y $b azules. Queremos hacer paquetes iguales, '
            'lo más grandes posible, sin mezclar colores y sin que sobre ninguno. '
            '¿Cuántos lápices lleva cada paquete?',
        solucion: '${mcd(a, b)}',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.07',
    descripcion:
        'El mínimo común múltiplo (m.c.m.) de dos números es el menor número (distinto de 0) '
        'que es múltiplo de los dos. Sirve para saber cuándo vuelven a coincidir dos cosas.',
    preguntaExplicalo: '¿Por qué el m.c.m. de dos números nunca es menor que el mayor de ellos?',
    generar: (azar) {
      late int a, b;
      do {
        a = azar.entre(2, 15);
        b = azar.entre(2, 15);
      } while (a == b || mcm(a, b) > 120);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Calcula el mínimo común múltiplo:',
          destacado: 'm.c.m.($a, $b) =',
          solucion: '${mcm(a, b)}',
          renglones: 3,
        );
      }
      return Ejercicio(
        enunciado: 'Un autobús pasa cada $a minutos y otro cada $b. Si acaban de pasar juntos, '
            '¿dentro de cuántos minutos vuelven a coincidir?',
        solucion: '${mcm(a, b)} minutos',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DIV.08',
    descripcion:
        'Descomponer en factores primos es escribir un número como producto de primos: se '
        'divide entre 2, 3, 5, 7… hasta llegar a 1. 60 = 2^{2} · 3 · 5.',
    preguntaExplicalo: '¿Por qué cada número tiene una sola descomposición en factores primos?',
    generar: (azar) {
      final numero = azar.elegir([12, 18, 24, 30, 36, 40, 45, 48, 54, 60, 72, 84, 90, 100, 120, 150, 180]);
      return Ejercicio(
        enunciado: 'Descompón en factores primos:',
        destacado: '$numero =',
        solucion: factorizacion(numero),
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'OP.01',
    descripcion:
        'Cuando hay varias operaciones, primero se hace lo de dentro de los paréntesis, después '
        'multiplicaciones y divisiones, y al final sumas y restas, de izquierda a derecha.',
    preguntaExplicalo: '¿Por qué crees que hace falta un orden acordado para hacer las operaciones?',
    generar: (azar) {
      final (expresion, valor) = _expresionJerarquia(azar);
      return Ejercicio(
        enunciado: 'Calcula respetando el orden de las operaciones:',
        destacado: '$expresion =',
        solucion: formatearEntero(valor),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'OP.02',
    descripcion:
        'Con fracciones el orden es el mismo: paréntesis, luego multiplicaciones y divisiones, '
        'y al final sumas y restas. Simplifica cuando puedas para trabajar con números pequeños.',
    preguntaExplicalo: '¿Qué error se comete si en 1/2 + 1/4 × 2 se suma primero? Explícalo.',
    generar: (azar) {
      Fraccion propia() {
        final denominador = azar.entre(2, 6);
        return Fraccion(azar.entre(1, denominador - 1), denominador);
      }

      final a = propia(), b = propia(), c = propia();
      final forma = azar.nextInt(3);
      final (expresion, valor) = switch (forma) {
        0 => ('${a.texto} + ${b.texto} × ${c.texto}', a + b * c),
        1 => ('${a.texto} × ${b.texto} − ${c.texto}', a * b - c),
        _ => ('(${a.texto} + ${b.texto}) : ${c.texto}', (a + b) / c),
      };
      return Ejercicio(
        enunciado: 'Calcula y simplifica el resultado:',
        destacado: '$expresion =',
        solucion: valor.texto,
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'OP.03',
    descripcion:
        'Para operar con decimales y fracciones a la vez, pásalo todo a decimales o todo a '
        'fracciones. 0,5 = 1/2, 0,25 = 1/4, 0,75 = 3/4, 0,2 = 1/5.',
    preguntaExplicalo: '¿Cuándo te resulta más fácil pasar a fracciones y cuándo a decimales?',
    generar: (azar) {
      const fraccionesSencillas = [(1, 2), (1, 4), (3, 4), (1, 5), (2, 5), (3, 5), (1, 10), (3, 10)];
      final (numerador, denominador) = azar.elegir(fraccionesSencillas);
      final fraccion = Fraccion(numerador, denominador);
      final decimal = azar.entre(1, 9) / 10 + azar.entre(0, 2);
      final operacion = azar.nextInt(3);
      final textoDecimal = formatearDecimal(decimal);
      final (expresion, valor) = switch (operacion) {
        0 => ('$textoDecimal + ${fraccion.texto}', decimal + fraccion.valor),
        1 => ('${fraccion.texto} × $textoDecimal', fraccion.valor * decimal),
        // La resta siempre con el mayor delante: nada de negativos aquí.
        _ => decimal >= fraccion.valor
            ? ('$textoDecimal − ${fraccion.texto}', decimal - fraccion.valor)
            : ('${fraccion.texto} − $textoDecimal', fraccion.valor - decimal),
      };
      return Ejercicio(
        enunciado: 'Calcula. Da el resultado como número decimal:',
        destacado: '$expresion =',
        solucion: formatearDecimal(valor, cifras: 3),
        renglones: 3,
      );
    },
  ),
];
