import 'dart:math' as math;

import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas del dominio DEC (decimales).

const _unidades = [
  'cero', 'uno', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', //
  'nueve', 'diez', 'once', 'doce', 'trece', 'catorce', 'quince', 'dieciséis',
  'diecisiete', 'dieciocho', 'diecinueve', 'veinte', 'veintiuno', 'veintidós',
  'veintitrés', 'veinticuatro', 'veinticinco', 'veintiséis', 'veintisiete',
  'veintiocho', 'veintinueve',
];
const _decenas = {
  3: 'treinta', 4: 'cuarenta', 5: 'cincuenta', 6: 'sesenta', 7: 'setenta', //
  8: 'ochenta', 9: 'noventa',
};

/// Número de 0 a 99 en palabras. Con [femenino], «una», «veintiuna»,
/// «treinta y una» (para décimas, centésimas…).
String numeroEnPalabras(int numero, {bool femenino = false}) {
  assert(numero >= 0 && numero < 100);
  String texto;
  if (numero < 30) {
    texto = _unidades[numero];
  } else {
    final decena = _decenas[numero ~/ 10]!;
    final unidad = numero % 10;
    texto = unidad == 0 ? decena : '$decena y ${_unidades[unidad]}';
  }
  if (femenino) {
    texto = texto.replaceFirst(RegExp(r'uno$'), 'una');
  }
  return texto;
}

const _nombresOrden = {1: 'décima', 2: 'centésima', 3: 'milésima'};

/// «tres unidades y siete centésimas», «veinticinco centésimas».
String decimalEnPalabras(int parteEntera, int parteDecimal, int cifrasDecimales) {
  final orden = _nombresOrden[cifrasDecimales]!;
  final textoDecimal =
      '${numeroEnPalabras(parteDecimal, femenino: true)} $orden${parteDecimal == 1 ? '' : 's'}';
  if (parteEntera == 0) return textoDecimal;
  final textoEntero = parteEntera == 1
      ? 'una unidad'
      : '${numeroEnPalabras(parteEntera, femenino: true)} unidades';
  return '$textoEntero y $textoDecimal';
}

/// Decimal con [cifras] decimales exactas, como entero escalado (para no
/// arrastrar errores de coma flotante en las soluciones).
class DecimalExacto {
  final int escalado;
  final int cifras;
  const DecimalExacto(this.escalado, this.cifras);

  double get valor => escalado / math.pow(10, cifras);
  String get texto => formatearDecimal(valor, cifras: cifras);
}

DecimalExacto _decimal(math.Random azar, {int enteroMaximo = 20, int cifras = 2}) {
  final factor = math.pow(10, cifras).toInt();
  return DecimalExacto(azar.entre(0, enteroMaximo) * factor + azar.entre(1, factor - 1), cifras);
}

final List<PlantillaFicha> plantillasDecimales = [
  PlantillaFicha(
    idHabilidad: 'DEC.01',
    descripcion:
        'Un número decimal tiene una parte entera y, tras la coma, décimas (1/10), '
        'centésimas (1/100) y milésimas (1/1000). 3,07 son tres unidades y siete centésimas.',
    preguntaExplicalo: '¿Por qué 0,5 y 0,50 son el mismo número? ¿Y por qué 0,05 no lo es?',
    generar: (azar) {
      final cifras = azar.entre(1, 2);
      final maximo = cifras == 1 ? 9 : 99;
      final parteDecimal = azar.entre(1, maximo);
      final parteEntera = azar.nextInt(3) == 0 ? 0 : azar.entre(1, 15);
      final numero = '$parteEntera,${parteDecimal.toString().padLeft(cifras, '0')}';
      final palabras = decimalEnPalabras(parteEntera, parteDecimal, cifras);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Escribe con cifras:',
          destacado: palabras,
          solucion: numero,
          renglones: 1,
        );
      }
      return Ejercicio(
        enunciado: 'Escribe con palabras:',
        destacado: numero,
        solucion: palabras,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.02',
    descripcion:
        'Para comparar decimales se mira primero la parte entera; si es igual, las décimas; '
        'luego las centésimas… Tener más cifras no hace a un número más grande: 0,4 > 0,35.',
    preguntaExplicalo: 'Alguien dice que 0,35 es mayor que 0,4 porque 35 es más que 4. ¿Qué le dirías?',
    generar: (azar) {
      // Sesgo hacia el error típico: el número con más cifras no es el mayor.
      final entero = azar.entre(0, 9);
      final decimas = azar.entre(2, 9);
      final corto = DecimalExacto(entero * 10 + decimas, 1);
      // Con centésimas de verdad (no «1,10»), y menor que el corto.
      final largo = DecimalExacto(entero * 100 + azar.entre(0, decimas - 1) * 10 + azar.entre(1, 9), 2);
      final (primero, segundo) = azar.nextBool() ? (corto, largo) : (largo, corto);
      final comparacion = primero.valor.compareTo(segundo.valor);
      return Ejercicio(
        enunciado: 'Escribe <, = o > en el hueco:',
        destacado: '${primero.texto}   ___   ${segundo.texto}',
        solucion: comparacion < 0 ? '<' : (comparacion == 0 ? '=' : '>'),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.03',
    descripcion:
        'Para ordenar decimales, compáralos cifra a cifra empezando por la izquierda. Si te '
        'ayuda, añade ceros al final para que todos tengan las mismas cifras: 0,5 = 0,50.',
    preguntaExplicalo: '¿Para qué sirve añadir ceros al final al ordenar decimales? ¿Cambia el número?',
    generar: (azar) {
      final entero = azar.entre(0, 3);
      final valores = <DecimalExacto>[];
      while (valores.length < 3) {
        final cifras = azar.entre(1, 3);
        final candidato = DecimalExacto(
            entero * math.pow(10, cifras).toInt() + azar.entre(1, math.pow(10, cifras).toInt() - 1),
            cifras);
        if (valores.every((v) => v.valor != candidato.valor)) valores.add(candidato);
      }
      final ordenados = [...valores]..sort((a, b) => a.valor.compareTo(b.valor));
      return Ejercicio(
        enunciado: 'Ordena de menor a mayor:',
        destacado: valores.map((v) => v.texto).join('     '),
        solucion: ordenados.map((v) => v.texto).join(' < '),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.04',
    descripcion:
        'Para sumar o restar decimales se colocan uno debajo de otro con las comas alineadas, '
        'y se opera como con números enteros. La coma del resultado va en la misma columna.',
    preguntaExplicalo: '¿Qué pasa si no pones las comas una debajo de la otra? Pon un ejemplo.',
    generar: (azar) {
      final primero = _decimal(azar, cifras: azar.entre(1, 2));
      final segundo = _decimal(azar, enteroMaximo: 9, cifras: azar.entre(1, 2));
      final sumar = azar.nextBool() || primero.valor < segundo.valor;
      final resultado = sumar ? primero.valor + segundo.valor : primero.valor - segundo.valor;
      return Ejercicio(
        enunciado: 'Calcula. Colócalos en columna con las comas alineadas:',
        destacado: '${primero.texto} ${sumar ? '+' : '−'} ${segundo.texto} =',
        solucion: formatearDecimal(resultado, cifras: 2),
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.05',
    descripcion:
        'Para multiplicar un decimal por un número natural, multiplica sin la coma y después '
        'pon en el resultado tantas cifras decimales como tenía el decimal.',
    preguntaExplicalo: '¿Por qué 0,3 × 4 da 1,2 y no 12? Explícalo con dinero o con medidas.',
    generar: (azar) {
      final decimal = _decimal(azar, enteroMaximo: 12, cifras: azar.entre(1, 2));
      final natural = azar.entre(2, 9);
      return Ejercicio(
        enunciado: 'Multiplica:',
        destacado: '${decimal.texto} × $natural =',
        solucion: formatearDecimal(decimal.valor * natural, cifras: 2),
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.06',
    descripcion:
        'Para multiplicar dos decimales, multiplica sin las comas y pon en el resultado tantas '
        'cifras decimales como sumen los dos factores. 1,2 × 0,3 = 0,36.',
    preguntaExplicalo: '¿Por qué al multiplicar por 0,5 el resultado se hace más pequeño?',
    generar: (azar) {
      final primero = _decimal(azar, enteroMaximo: 9, cifras: 1);
      final segundo = _decimal(azar, enteroMaximo: 5, cifras: 1);
      return Ejercicio(
        enunciado: 'Multiplica:',
        destacado: '${primero.texto} × ${segundo.texto} =',
        solucion: formatearDecimal(primero.valor * segundo.valor, cifras: 2),
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.07',
    descripcion:
        'Para dividir entre un decimal, quita la coma del divisor multiplicando los dos números '
        'por 10, 100…: el cociente no cambia. 4,8 : 0,4 = 48 : 4 = 12.',
    preguntaExplicalo: '¿Por qué se puede multiplicar por 10 los dos números de una división sin cambiar el resultado?',
    generar: (azar) {
      final divisor = DecimalExacto(azar.entre(2, 9), azar.entre(1, 2) == 1 ? 1 : 0);
      final cociente = azar.entre(2, 15);
      // El dividendo siempre lleva una cifra decimal: 4,8 : 0,4 o 4,8 : 4.
      final dividendo = DecimalExacto(divisor.escalado * cociente, 1);
      final divisorTexto = divisor.cifras == 0 ? '${divisor.escalado}' : divisor.texto;
      return Ejercicio(
        enunciado: 'Divide:',
        destacado: '${dividendo.texto} : $divisorTexto =',
        solucion: divisor.cifras == 0
            ? formatearDecimal(cociente / 10, cifras: 1)
            : '$cociente',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.08',
    descripcion:
        'Una fracción es una división: 3/4 = 3 : 4 = 0,75. Con denominadores 2, 4, 5, 10, 20, '
        '25 o 100 sale un decimal exacto y corto.',
    preguntaExplicalo: '¿Por qué 1/4 es 0,25 y no 0,4? Explícalo con monedas de euro.',
    generar: (azar) {
      final denominador = azar.elegir([2, 4, 5, 10, 20, 25, 100]);
      var numerador = azar.entre(1, denominador - 1);
      if (denominador == 100) numerador = azar.entre(1, 99);
      final fraccion = Fraccion(numerador, denominador).simplificada();
      return Ejercicio(
        enunciado: 'Escribe como número decimal:',
        destacado: '${fraccion.texto} =',
        solucion: formatearDecimal(fraccion.valor, cifras: 2),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'DEC.09',
    descripcion:
        'Para redondear a las décimas, mira la cifra de las centésimas: si es 5 o más, la '
        'décima sube uno; si es menos de 5, se queda igual. 2,37 se redondea a 2,4 y 2,34, a 2,3.',
    preguntaExplicalo: '¿Para qué sirve redondear? Piensa en un caso de la vida en que lo hagas.',
    generar: (azar) {
      final numero = _decimal(azar, enteroMaximo: 30, cifras: 2);
      // Mismo criterio que el juego: redondeo «hacia arriba» en el 5.
      final redondeado = (numero.escalado + 5) ~/ 10;
      return Ejercicio(
        enunciado: 'Redondea a las décimas:',
        destacado: '${numero.texto}  ≈  ___',
        solucion: formatearDecimalFijo(redondeado / 10, 1),
        renglones: 1,
      );
    },
  ),
];
