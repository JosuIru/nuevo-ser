import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas de los dominios ALG (álgebra) y FUN (funciones). Las de
/// coordenadas y lectura de gráficas necesitan ejes dibujados y se saltan
/// en v0.1.

/// Polinomio en x a partir de {exponente: coeficiente}, de mayor a menor
/// grado: {2: 3, 1: −2, 0: 1} → «3x^{2} − 2x + 1».
String formatearPolinomio(Map<int, int> coeficientes, {String variable = 'x'}) {
  final exponentes = coeficientes.keys.where((e) => coeficientes[e] != 0).toList()
    ..sort((a, b) => b.compareTo(a));
  if (exponentes.isEmpty) return '0';
  final texto = StringBuffer();
  for (final exponente in exponentes) {
    final coeficiente = coeficientes[exponente]!;
    final esPrimero = texto.isEmpty;
    if (esPrimero) {
      if (coeficiente < 0) texto.write('−');
    } else {
      texto.write(coeficiente < 0 ? ' − ' : ' + ');
    }
    final absoluto = coeficiente.abs();
    final parteVariable = exponente == 0
        ? ''
        : (exponente == 1 ? variable : potencia(variable, exponente));
    if (absoluto != 1 || exponente == 0) texto.write(absoluto);
    texto.write(parteVariable);
  }
  return texto.toString();
}

/// «ax + b» con el signo bien puesto.
String _lineal(int a, int b, {String variable = 'x'}) =>
    formatearPolinomio({1: a, 0: b}, variable: variable);

const _palabrasMultiplo = {2: 'doble', 3: 'triple', 4: 'cuádruple', 5: 'quíntuple'};

final List<PlantillaFicha> plantillasAlgebraFunciones = [
  PlantillaFicha(
    idHabilidad: 'ALG.01',
    descripcion:
        'Una ecuación es una igualdad con un número escondido (la incógnita, x). Para encontrarlo, '
        'se hace lo mismo a los dos lados hasta dejar la x sola: si 3x + 2 = 14, entonces 3x = 12 y x = 4.',
    preguntaExplicalo: '¿Por qué hay que hacer lo mismo a los dos lados de una ecuación? Piensa en una balanza.',
    generar: (azar) {
      final a = azar.entre(2, 9);
      final x = azar.entre(-5, 12);
      final b = azar.conSignoNoNulo(15);
      return Ejercicio(
        enunciado: 'Resuelve y comprueba la solución:',
        destacado: '${_lineal(a, b)} = ${formatearEntero(a * x + b)}',
        solucion: 'x = ${formatearEntero(x)}',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.02',
    descripcion:
        'Si la x aparece a los dos lados, primero se juntan las x en un lado y los números en el otro. '
        'Si 5x − 3 = 2x + 9, entonces 3x = 12 y x = 4.',
    preguntaExplicalo: '¿Cómo compruebas que la solución de una ecuación es correcta?',
    generar: (azar) {
      late int a, c;
      do {
        a = azar.entre(2, 9);
        c = azar.entre(1, 8);
      } while (a == c);
      final x = azar.entre(-6, 10);
      final b = azar.conSignoNoNulo(12);
      final d = a * x + b - c * x;
      return Ejercicio(
        enunciado: 'Resuelve y comprueba la solución:',
        destacado: '${_lineal(a, b)} = ${_lineal(c, d)}',
        solucion: 'x = ${formatearEntero(x)}',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.03',
    descripcion:
        'Un sistema son dos ecuaciones con dos incógnitas (x e y) que se cumplen a la vez. Se '
        'resuelve por sustitución, igualación o reducción, y la solución es una pareja de números.',
    preguntaExplicalo: '¿Por qué hacen falta dos ecuaciones para encontrar dos incógnitas?',
    generar: (azar) {
      final x = azar.entre(-4, 8);
      final y = azar.entre(-4, 8);
      late int a, b, c, d;
      do {
        a = azar.entre(1, 4);
        b = azar.conSignoNoNulo(3);
        c = azar.entre(1, 4);
        d = azar.conSignoNoNulo(3);
      } while (a * d - b * c == 0);
      String ecuacion(int p, int q) =>
          '${formatearPolinomio({1: p}, variable: 'x')} ${q < 0 ? '−' : '+'} '
          '${q.abs() == 1 ? '' : q.abs()}y = ${formatearEntero(p * x + q * y)}';
      return Ejercicio(
        enunciado: 'Resuelve el sistema por el método que prefieras:',
        destacado: '${ecuacion(a, b)}\n${ecuacion(c, d)}',
        solucion: 'x = ${formatearEntero(x)}, y = ${formatearEntero(y)}',
        renglones: 5,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.04',
    descripcion:
        'El lenguaje algebraico usa letras para números que no conocemos. «El doble de un número '
        'más 3» se escribe 2x + 3; «la mitad de un número», x/2.',
    preguntaExplicalo: '¿Es lo mismo «el doble de un número más 3» que «el doble de un número más 3 unidades»? ¿Y que 2(x + 3)?',
    generar: (azar) {
      final k = azar.entre(2, 5);
      final b = azar.entre(1, 9);
      final opciones = <(String, String)>[
        ('el ${_palabrasMultiplo[k]} de un número más $b', '${k}x + $b'),
        ('el ${_palabrasMultiplo[k]} de un número menos $b', '${k}x − $b'),
        ('el ${_palabrasMultiplo[k]} de la suma de un número y $b', '$k(x + $b)'),
        ('la mitad de un número más $b', 'x/2 + $b'),
        ('un número más su ${_palabrasMultiplo[k]}', 'x + ${k}x = ${k + 1}x'),
        ('el cuadrado de un número menos $b', '${potencia('x', 2)} − $b'),
        ('dos números consecutivos', 'x  y  x + 1'),
        ('la edad de una persona dentro de $b años', 'x + $b'),
        ('el precio de $k cuadernos a x euros cada uno', '${k}x'),
      ];
      final (frase, expresion) = azar.elegir(opciones);
      return Ejercicio(
        enunciado: 'Escribe en lenguaje algebraico:',
        destacado: frase,
        solucion: expresion,
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.05',
    descripcion:
        'El valor numérico de una expresión es lo que vale cuando cambias la letra por un número. '
        'Si x = 2, entonces 3x + 1 = 3 · 2 + 1 = 7.',
    preguntaExplicalo: '¿Por qué al sustituir un número negativo conviene ponerlo entre paréntesis?',
    generar: (azar) {
      final coeficientes = {2: azar.entre(-3, 3), 1: azar.conSignoNoNulo(5), 0: azar.entre(-9, 9)};
      final x = azar.conSignoNoNulo(4);
      final valor = coeficientes.entries
          .map((e) => e.value * _potenciaEntera(x, e.key))
          .reduce((a, b) => a + b);
      return Ejercicio(
        enunciado: 'Calcula el valor de la expresión para x = ${formatearEntero(x)}:',
        destacado: formatearPolinomio(coeficientes),
        solucion: formatearEntero(valor),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.06',
    descripcion:
        'Un monomio es un número por letras, como 5x^{2}. Solo se pueden sumar monomios semejantes '
        '(misma parte de letras): 3x^{2} + 5x^{2} = 8x^{2}. Al multiplicar, se multiplican los números '
        'y se suman los exponentes.',
    preguntaExplicalo: '¿Por qué 3x + 2x^{2} no se puede juntar en un solo monomio?',
    generar: (azar) {
      final a = azar.conSignoNoNulo(7);
      final b = azar.conSignoNoNulo(7);
      final m = azar.entre(1, 4);
      final n = azar.entre(1, 4);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Opera:',
          destacado: '${formatearPolinomio({m: a})} ${b < 0 ? '−' : '+'} ${formatearPolinomio({m: b.abs()})} =',
          solucion: formatearPolinomio({m: a + b}),
          renglones: 1,
        );
      }
      return Ejercicio(
        enunciado: 'Multiplica:',
        destacado: '(${formatearPolinomio({m: a})}) · (${formatearPolinomio({n: b})}) =',
        solucion: formatearPolinomio({m + n: a * b}),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.07',
    descripcion:
        'Un polinomio es una suma de monomios, como 2x^{2} − 3x + 1. Para sumar o restar polinomios '
        'se juntan los términos del mismo grado.',
    preguntaExplicalo: 'Al restar un polinomio, ¿qué pasa con los signos de todos sus términos? ¿Por qué?',
    generar: (azar) {
      Map<int, int> polinomio() =>
          {2: azar.conSignoNoNulo(5), 1: azar.entre(-6, 6), 0: azar.entre(-9, 9)};
      final p = polinomio();
      final q = polinomio();
      final sumar = azar.nextBool();
      final resultado = {
        for (final e in [2, 1, 0]) e: sumar ? p[e]! + q[e]! : p[e]! - q[e]!,
      };
      return Ejercicio(
        enunciado: 'Si P(x) = ${formatearPolinomio(p)} y Q(x) = ${formatearPolinomio(q)}, calcula:',
        destacado: sumar ? 'P(x) + Q(x) =' : 'P(x) − Q(x) =',
        solucion: formatearPolinomio(resultado),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.08',
    descripcion:
        'Las identidades notables ahorran cuentas: (a + b)^{2} = a^{2} + 2ab + b^{2}; '
        '(a − b)^{2} = a^{2} − 2ab + b^{2}; (a + b)(a − b) = a^{2} − b^{2}.',
    preguntaExplicalo: '¿Por qué (x + 3)^{2} no es x^{2} + 9? Dibuja un cuadrado de lado x + 3.',
    generar: (azar) {
      final a = azar.entre(1, 9);
      final forma = azar.nextInt(3);
      final (expresion, desarrollo) = switch (forma) {
        0 => ('(x + $a)^{2}', formatearPolinomio({2: 1, 1: 2 * a, 0: a * a})),
        1 => ('(x − $a)^{2}', formatearPolinomio({2: 1, 1: -2 * a, 0: a * a})),
        _ => ('(x + $a)(x − $a)', formatearPolinomio({2: 1, 0: -a * a})),
      };
      return Ejercicio(
        enunciado: 'Desarrolla:',
        destacado: '$expresion =',
        solucion: desarrollo,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.09',
    descripcion:
        'Con paréntesis, primero se quitan multiplicando. Con denominadores, se multiplica toda la '
        'ecuación por el m.c.m. para que desaparezcan. Después, se resuelve como siempre.',
    preguntaExplicalo: 'Al quitar denominadores, ¿por qué hay que multiplicar todos los términos, también los que no tienen?',
    generar: (azar) {
      final x = azar.entre(-5, 10);
      if (azar.nextBool()) {
        final a = azar.entre(2, 5);
        final b = azar.conSignoNoNulo(6);
        final c = azar.entre(1, 4);
        return Ejercicio(
          enunciado: 'Resuelve:',
          destacado: '$a(${_lineal(1, b)}) ${c == 1 ? '+ x' : '+ ${c}x'} = ${formatearEntero(a * (x + b) + c * x)}',
          solucion: 'x = ${formatearEntero(x)}',
          renglones: 4,
        );
      }
      final denominador = azar.entre(2, 5);
      final xMultiplo = denominador * azar.entre(-2, 4);
      final b = azar.conSignoNoNulo(6);
      return Ejercicio(
        enunciado: 'Resuelve:',
        destacado: 'x/$denominador ${b < 0 ? '−' : '+'} ${b.abs()} = ${formatearEntero(xMultiplo ~/ denominador + b)}',
        solucion: 'x = ${formatearEntero(xMultiplo)}',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.10',
    descripcion:
        'Una ecuación de segundo grado tiene x^{2}. Puede tener dos, una o ninguna solución. Se '
        'resuelve con la fórmula x = (−b ± √(b^{2} − 4ac)) / 2a, o sacando factor común si falta un término.',
    preguntaExplicalo: '¿Por qué una ecuación de segundo grado puede tener dos soluciones? Comprueba con x^{2} = 9.',
    generar: (azar) {
      final r1 = azar.entre(-6, 6);
      late int r2;
      do {
        r2 = azar.entre(-6, 6);
      } while (r2 == r1);
      final ecuacion = formatearPolinomio({2: 1, 1: -(r1 + r2), 0: r1 * r2});
      final soluciones = [r1, r2]..sort();
      return Ejercicio(
        enunciado: 'Resuelve y comprueba las soluciones:',
        destacado: '$ecuacion = 0',
        solucion: 'x = ${formatearEntero(soluciones[0])}, x = ${formatearEntero(soluciones[1])}',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.11',
    descripcion:
        'Para resolver un problema con ecuaciones: elige qué es la x, escribe la ecuación con los '
        'datos, resuélvela y comprueba que la respuesta tiene sentido en el problema.',
    preguntaExplicalo: '¿Qué es lo más difícil de pasar un problema a ecuación? ¿Cómo lo haces tú?',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final edadPequeno = azar.entre(4, 14);
        final veces = azar.entre(2, 4);
        return Ejercicio(
          enunciado: 'Ane tiene ${veces == 2 ? 'el doble' : (veces == 3 ? 'el triple' : 'el cuádruple')} '
              'de edad que su prima. Entre las dos suman ${edadPequeno * (veces + 1)} años. '
              '¿Cuántos años tiene cada una?',
          solucion: 'prima $edadPequeno, Ane ${edadPequeno * veces}',
          renglones: 4,
        );
      }
      if (tipo == 1) {
        final primero = azar.entre(10, 60);
        return Ejercicio(
          enunciado: 'La suma de tres números consecutivos es ${3 * primero + 3}. ¿Qué números son?',
          solucion: '$primero, ${primero + 1} y ${primero + 2}',
          renglones: 4,
        );
      }
      final precio = azar.entre(2, 9);
      final cantidad = azar.entre(3, 8);
      final pagado = (precio * cantidad ~/ 10 + 1) * 10;
      return Ejercicio(
        enunciado: 'Compras $cantidad libretas iguales, pagas con $pagado € y te devuelven '
            '${pagado - precio * cantidad} €. ¿Cuánto cuesta cada libreta?',
        solucion: '$precio €',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'ALG.12',
    descripcion:
        'Si un problema tiene dos cantidades desconocidas, llama x a una e y a la otra, escribe '
        'dos ecuaciones con los datos y resuelve el sistema.',
    preguntaExplicalo: '¿Cómo sabes qué dos ecuaciones escribir en un problema con dos incógnitas?',
    generar: (azar) {
      if (azar.nextBool()) {
        final gallinas = azar.entre(3, 20);
        final conejos = azar.entre(3, 20);
        return Ejercicio(
          enunciado: 'En una granja hay gallinas y conejos. En total hay ${gallinas + conejos} cabezas '
              'y ${2 * gallinas + 4 * conejos} patas. ¿Cuántos animales hay de cada tipo?',
          solucion: '$gallinas gallinas y $conejos conejos',
          renglones: 5,
        );
      }
      final precioBocadillo = azar.entre(2, 5);
      final precioZumo = azar.entre(1, 3);
      final a = azar.entre(1, 3), b = azar.entre(1, 3);
      final c = azar.entre(1, 3);
      var d = azar.entre(1, 3);
      if (a * d == b * c) d = d == 3 ? 1 : d + 1;
      return Ejercicio(
        enunciado: 'En la cafetería de la excursión, $a bocadillo${a > 1 ? 's' : ''} y $b zumo${b > 1 ? 's' : ''} '
            'cuestan ${a * precioBocadillo + b * precioZumo} €, y $c bocadillo${c > 1 ? 's' : ''} y $d '
            'zumo${d > 1 ? 's' : ''} cuestan ${c * precioBocadillo + d * precioZumo} €. '
            '¿Cuánto cuesta cada cosa?',
        solucion: 'bocadillo $precioBocadillo €, zumo $precioZumo €',
        renglones: 5,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FUN.01',
    descripcion:
        'Una tabla corresponde a una función lineal (y = mx) si y es siempre el mismo múltiplo de x: '
        'al dividir y entre x sale siempre el mismo número, m.',
    preguntaExplicalo: '¿En qué se parece una función lineal a una tabla de proporcionalidad directa?',
    generar: (azar) {
      final m = azar.conSignoNoNulo(5);
      final esLineal = azar.nextBool();
      final n = esLineal ? 0 : azar.conSignoNoNulo(4);
      final valoresX = [1, 2, 3, 4, 5];
      return Ejercicio(
        enunciado: '¿Es una función lineal (y = mx)? Si lo es, escribe su fórmula.',
        tabla: [
          ['x', ...valoresX.map(formatearEntero)],
          ['y', ...valoresX.map((x) => formatearEntero(m * x + n))],
        ],
        solucion: esLineal ? 'sí: y = ${_lineal(m, 0)}' : 'no',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FUN.04',
    descripcion:
        'En una función afín y = mx + n, m es la pendiente (cuánto sube y cuando x aumenta 1) y n '
        'es la ordenada en el origen (el valor de y cuando x = 0). Si n = 0, es lineal.',
    preguntaExplicalo: '¿Qué significa que la pendiente sea negativa? Pon un ejemplo de la vida.',
    generar: (azar) {
      final m = azar.conSignoNoNulo(4);
      final n = azar.entre(-6, 6);
      final valoresX = [-2, -1, 0, 1, 2];
      return Ejercicio(
        enunciado: 'Completa la tabla de y = ${_lineal(m, n)}. ¿Cuál es la pendiente? ¿Y la ordenada en el origen?',
        tabla: [
          ['x', ...valoresX.map(formatearEntero)],
          ['y', ...valoresX.map((_) => '')],
        ],
        solucion: '${valoresX.map((x) => formatearEntero(m * x + n)).join(', ')}; m = ${formatearEntero(m)}, '
            'n = ${formatearEntero(n)}',
        renglones: 2,
      );
    },
  ),
];

int _potenciaEntera(int base, int exponente) {
  var resultado = 1;
  for (var i = 0; i < exponente; i++) {
    resultado *= base;
  }
  return resultado;
}

const motivosSinPlantillaAlgebraFunciones = {
  'FUN.02': 'las coordenadas cartesianas necesitan unos ejes dibujados (v0.1 no dibuja)',
  'FUN.03': 'leer una gráfica necesita la gráfica dibujada (v0.1 no dibuja)',
};
