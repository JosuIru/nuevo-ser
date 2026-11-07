import 'dart:math' as math;

import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas del dominio ARI (aritmética: sumas, potencias, raíces, enteros
/// con signo y notación científica).

final List<PlantillaFicha> plantillasAritmetica = [
  PlantillaFicha(
    idHabilidad: 'ARI.01',
    descripcion:
        'Sumar es juntar. Para sumar de cabeza ayuda descomponer y buscar la decena redonda: así '
        'la cuenta es más fácil.\n'
        'Ejemplo: 27 + 38 = 27 + 3 + 35 = 30 + 35 = 65.',
    preguntaExplicalo: '¿Qué truco usas tú para sumar de cabeza? Explícalo con un ejemplo.',
    generar: (azar) {
      final cantidadSumandos = azar.entre(2, 3);
      final sumandos = List.generate(cantidadSumandos, (_) => azar.entre(6, cantidadSumandos == 2 ? 89 : 29));
      return Ejercicio(
        enunciado: 'Suma de cabeza y escribe cómo lo has pensado:',
        destacado: '${sumandos.join(' + ')} =',
        solucion: '${sumandos.reduce((a, b) => a + b)}',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.02',
    descripcion:
        'Una potencia es una multiplicación repetida. El número de abajo (base) es el que se '
        'multiplica; el pequeño de arriba (exponente), cuántas veces aparece.\n'
        'Ejemplo: 2^{5} = 2 × 2 × 2 × 2 × 2 = 32.',
    preguntaExplicalo: '¿Por qué 2^{3} no es lo mismo que 2 × 3? Explícalo.',
    generar: (azar) {
      final base = azar.entre(2, 10);
      final exponente = base <= 3 ? azar.entre(2, 6) : (base == 10 ? azar.entre(2, 6) : azar.entre(2, 3));
      final valor = math.pow(base, exponente).toInt();
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Calcula:',
          destacado: '${potencia('$base', exponente)} =',
          solucion: formatearEntero(valor),
          renglones: 2,
        );
      }
      return Ejercicio(
        enunciado: 'Escribe como potencia y calcula su valor:',
        destacado: '${List.filled(exponente, '$base').join(' × ')} =',
        solucion: '${potencia('$base', exponente)} = ${formatearEntero(valor)}',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.03',
    descripcion:
        'La raíz cuadrada de un número es el que, multiplicado por sí mismo, da ese número. Los '
        'números como 49 se llaman cuadrados perfectos.\n'
        'Ejemplo: √49 = 7 porque 7 · 7 = 49.',
    preguntaExplicalo: '¿Qué tiene que ver la raíz cuadrada con el lado de un cuadrado? Haz un dibujo.',
    generar: (azar) {
      final raiz = azar.entre(2, 20);
      if (azar.nextInt(3) == 0) {
        return Ejercicio(
          enunciado: 'Un cuadrado tiene ${raiz * raiz} cm² de área. ¿Cuánto mide su lado?',
          solucion: '$raiz cm',
          renglones: 2,
        );
      }
      return Ejercicio(
        enunciado: 'Calcula y comprueba multiplicando:',
        destacado: '√${raiz * raiz} =',
        solucion: '$raiz',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.04',
    descripcion:
        'Los números enteros pueden ser positivos o negativos. Sumar un negativo es como restar; '
        'restar un negativo es como sumar.\n'
        'Ejemplo: 5 − (−3) = 5 + 3 = 8, y −2 + (−4) = −2 − 4 = −6.',
    preguntaExplicalo: '¿Por qué restar un número negativo hace que el resultado sea más grande?',
    generar: (azar) {
      final primero = azar.conSignoNoNulo(15);
      // Al menos un negativo: dos positivos no ejercitan la habilidad.
      final segundo = primero > 0 ? -azar.entre(1, 15) : azar.conSignoNoNulo(15);
      final suma = azar.nextBool();
      final resultado = suma ? primero + segundo : primero - segundo;
      return Ejercicio(
        enunciado: azar.nextInt(3) == 0
            ? 'Calcula. Si te ayuda, piensa en temperaturas o en una recta numérica:'
            : 'Calcula:',
        destacado: '${formatearEntero(primero)} ${suma ? '+' : '−'} ${enteroOperando(segundo)} =',
        solucion: formatearEntero(resultado),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.05',
    descripcion:
        'El valor absoluto de un número es su distancia al 0, sin importar el signo. Por eso nunca '
        'es negativo.\n'
        'Ejemplo: |−7| = 7 y |7| = 7.',
    preguntaExplicalo: '¿Por qué el valor absoluto nunca puede ser negativo?',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final numero = azar.conSignoNoNulo(30);
        return Ejercicio(
          enunciado: 'Calcula:',
          destacado: '|${formatearEntero(numero)}| =',
          solucion: '${numero.abs()}',
          renglones: 1,
        );
      }
      if (tipo == 1) {
        final distancia = azar.entre(1, 12);
        return Ejercicio(
          enunciado: '¿Qué números enteros tienen valor absoluto $distancia?',
          solucion: '$distancia y ${formatearEntero(-distancia)}',
          renglones: 1,
        );
      }
      final numeros = <int>{};
      while (numeros.length < 5) {
        numeros.add(azar.conSignoNoNulo(12));
      }
      final lista = numeros.toList();
      final ordenados = [...lista]..sort((a, b) => a.abs() != b.abs() ? a.abs().compareTo(b.abs()) : a.compareTo(b));
      return Ejercicio(
        enunciado: 'Ordena de menor a mayor valor absoluto:',
        destacado: lista.map(formatearEntero).join('     '),
        solucion: ordenados.map(formatearEntero).join(', '),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.06',
    descripcion:
        'Para multiplicar o dividir enteros, primero opera sin signos y luego pon el signo: si '
        'los dos tienen el mismo signo, positivo; si tienen signos distintos, negativo.\n'
        'Ejemplo: (−4) · (−3) = 12 y 12 : (−3) = −4.',
    preguntaExplicalo: 'Inventa una situación de la vida en la que se multiplique un número negativo.',
    generar: (azar) {
      final primero = azar.conSignoNoNulo(12);
      final magnitudSegundo = azar.entre(2, 9);
      final segundo = primero > 0 || azar.nextBool() ? -magnitudSegundo : magnitudSegundo;
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Calcula:',
          destacado: '${formatearEntero(primero)} · ${enteroOperando(segundo)} =',
          solucion: formatearEntero(primero * segundo),
          renglones: 1,
        );
      }
      return Ejercicio(
        enunciado: 'Calcula:',
        destacado: '${formatearEntero(primero * segundo)} : ${enteroOperando(segundo)} =',
        solucion: formatearEntero(primero),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.07',
    descripcion:
        'Con enteros, el orden es el de siempre: paréntesis, multiplicaciones y divisiones, sumas y '
        'restas. Un menos delante de un paréntesis cambia el signo de todo lo de dentro.\n'
        'Ejemplo: 5 − (2 − 7) = 5 − 2 + 7 = 10, y −3 + 2 · (−4) = −3 − 8 = −11.',
    preguntaExplicalo: '¿Qué le pasa a lo de dentro de un paréntesis si delante hay un signo menos?',
    generar: (azar) {
      final a = azar.conSignoNoNulo(9);
      final b = azar.conSignoNoNulo(6);
      final c = azar.conSignoNoNulo(6);
      final d = azar.conSignoNoNulo(9);
      final forma = azar.nextInt(3);
      final (expresion, valor) = switch (forma) {
        0 => ('${formatearEntero(a)} + ${enteroOperando(b)} · ${enteroOperando(c)}', a + b * c),
        1 => ('${formatearEntero(a)} − (${formatearEntero(b)} + ${enteroOperando(d)})', a - (b + d)),
        _ => ('${enteroOperando(b)} · (${formatearEntero(a)} − ${enteroOperando(c)}) + ${enteroOperando(d)}',
            b * (a - c) + d),
      };
      return Ejercicio(
        enunciado: 'Calcula paso a paso:',
        destacado: '$expresion =',
        solucion: formatearEntero(valor),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.08',
    descripcion:
        'Con la misma base: al multiplicar potencias se suman los exponentes; al dividir, se restan; '
        'en una potencia de potencia, se multiplican. Y cualquier número (no 0) elevado a 0 da 1.\n'
        'Ejemplo: 3^{4} · 3^{2} = 3^{6}, 5^{7} : 5^{3} = 5^{4} y (2^{3})^{2} = 2^{6}.',
    preguntaExplicalo: '¿Por qué 2^{5} · 2^{3} es 2^{8} y no 2^{15}? Escríbelo con multiplicaciones.',
    generar: (azar) {
      final base = azar.entre(2, 7);
      final m = azar.entre(2, 7);
      final n = azar.entre(2, 5);
      final b = '$base';
      final forma = azar.nextInt(3);
      final (expresion, exponente) = switch (forma) {
        0 => ('${potencia(b, m)} · ${potencia(b, n)}', m + n),
        1 => ('${potencia(b, m + n)} : ${potencia(b, n)}', m),
        _ => ('(${potencia(b, m)})^{$n}', m * n),
      };
      return Ejercicio(
        enunciado: 'Escribe como una sola potencia:',
        destacado: '$expresion =',
        solucion: potencia(b, exponente),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ARI.09',
    descripcion:
        'Un exponente negativo da la inversa: 10^{−3} = 1/1000 = 0,001. En notación científica se '
        'escribe una sola cifra (no 0) antes de la coma por una potencia de 10.\n'
        'Ejemplo: 2^{−3} = 1/2^{3} = 1/8, y 3 500 000 = 3,5 · 10^{6}.',
    preguntaExplicalo: '¿Para qué sirve la notación científica? Piensa en el tamaño de una bacteria o de una galaxia.',
    generar: (azar) {
      // Uno de cada tres: exponente negativo con base pequeña («2^{−3} = 1/8»).
      if (azar.nextInt(3) == 0) {
        final base = azar.entre(2, 5);
        final exponente = azar.entre(1, 3);
        return Ejercicio(
          enunciado: 'Escribe como fracción:',
          destacado: '${potencia('$base', -exponente)} =',
          solucion: '1/${math.pow(base, exponente).toInt()}',
          renglones: 2,
        );
      }
      final cifras = azar.entre(11, 99);
      final mantisa = cifras / 10;
      final esGrande = azar.nextBool();
      final exponente = esGrande ? azar.entre(3, 9) : -azar.entre(2, 6);
      final numero = mantisa * math.pow(10, exponente);
      final escrito = esGrande
          ? formatearEntero(numero.round())
          : formatearDecimal(numero, cifras: 8);
      final cientifica = '${formatearDecimal(mantisa)} · ${potencia('10', exponente)}';
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Escribe en notación científica:',
          destacado: '$escrito =',
          solucion: cientifica,
          renglones: 2,
        );
      }
      return Ejercicio(
        enunciado: 'Escribe el número completo:',
        destacado: '$cientifica =',
        solucion: escrito,
        renglones: 2,
      );
    },
  ),
];
