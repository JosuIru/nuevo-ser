import 'dart:math' as math;

import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas del dominio FR (fracciones), de 4.º de Primaria a 1.º de ESO.

const _partesSingular = {
  2: 'medio', 3: 'tercio', 4: 'cuarto', 5: 'quinto', 6: 'sexto', //
  7: 'séptimo', 8: 'octavo', 9: 'noveno', 10: 'décimo',
};

/// «tres quintos», «un medio», «cinco octavos».
String fraccionEnPalabras(int numerador, int denominador) {
  final parte = _partesSingular[denominador]!;
  if (numerador == 1) return 'un $parte';
  final numeral = _numeralesMasculinos[numerador];
  return '$numeral ${parte}s';
}

const _numeralesMasculinos = [
  'cero', 'un', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', //
  'ocho', 'nueve', 'diez', 'once',
];

Fraccion _propia(math.Random azar, {int denominadorMaximo = 10}) {
  final denominador = azar.entre(3, denominadorMaximo);
  return Fraccion(azar.entre(1, denominador - 1), denominador);
}

String _signoComparacion(int comparacion) =>
    comparacion < 0 ? '<' : (comparacion == 0 ? '=' : '>');

/// Tres fracciones distintas en valor.
List<Fraccion> _tresDistintas(math.Random azar, Fraccion Function() fabrica) {
  final elegidas = <Fraccion>[];
  while (elegidas.length < 3) {
    final candidata = fabrica();
    if (elegidas.every((f) => f.compareTo(candidata) != 0)) {
      elegidas.add(candidata);
    }
  }
  return elegidas;
}

const _repartos = [
  ('una pizza', 'trozos iguales', 'te comes'),
  ('una tableta de chocolate', 'onzas iguales', 'repartes'),
  ('un huerto', 'parcelas iguales', 'siembras de tomates'),
  ('una cuerda', 'tramos iguales', 'pintas de azul'),
  ('una caja de huevos', 'huecos', 'llenas'),
];

final List<PlantillaFicha> plantillasFracciones = [
  PlantillaFicha(
    idHabilidad: 'FR.01',
    descripcion:
        'Una fracción dice en cuántas partes iguales se ha partido algo (el número de abajo, '
        'el denominador) y cuántas de esas partes tomamos (el de arriba, el numerador).',
    preguntaExplicalo:
        'Si partes una hoja en 4 trozos que no son iguales y coges uno, ¿has cogido 1/4 de '
        'la hoja? Explica por qué.',
    generar: (azar) {
      final (objeto, partes, accion) = azar.elegir(_repartos);
      final total = azar.entre(3, 12);
      final tomadas = azar.entre(1, total - 1);
      return Ejercicio(
        enunciado: 'Se divide $objeto en $total $partes y $accion $tomadas. '
            '¿Qué fracción es? ¿Y qué fracción queda sin tocar? Puedes hacer un dibujo.',
        solucion: '$tomadas/$total; quedan ${total - tomadas}/$total',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.02',
    descripcion:
        'Las fracciones se leen con el numerador y el nombre de las partes: 3/5 se lee «tres '
        'quintos» y 1/2, «un medio». A partir de 11 se dice «onceavos», «doceavos»…',
    preguntaExplicalo:
        '¿Por qué crees que 1/4 se lee «un cuarto»? ¿Qué tiene que ver con partir algo en cuatro?',
    generar: (azar) {
      final denominador = azar.entre(2, 10);
      final numerador = azar.entre(1, denominador == 2 ? 1 : denominador - 1);
      final palabras = fraccionEnPalabras(numerador, denominador);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Escribe con cifras:',
          destacado: palabras,
          solucion: '$numerador/$denominador',
          renglones: 1,
        );
      }
      return Ejercicio(
        enunciado: 'Escribe con palabras:',
        destacado: '$numerador/$denominador',
        solucion: palabras,
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.03',
    descripcion:
        'Para saber si una fracción es más o menos que la mitad, mira si el numerador es '
        'más o menos que la mitad del denominador: 4/9 es menos que 1/2 porque 4 no llega a 4,5.',
    preguntaExplicalo: '¿Cómo sabes, sin dibujar, si una fracción es justo la mitad?',
    generar: (azar) {
      final denominador = azar.entre(3, 12);
      final numerador = azar.entre(1, denominador - 1);
      final comparacion = (2 * numerador).compareTo(denominador);
      return Ejercicio(
        enunciado: 'Escribe <, = o > en el hueco:',
        destacado: '$numerador/$denominador   ___   1/2',
        solucion: _signoComparacion(comparacion),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.04',
    descripcion:
        'Si el numerador es menor que el denominador, la fracción es menos que una unidad; '
        'si son iguales, es justo una unidad; si es mayor, es más que una unidad.',
    preguntaExplicalo: '¿Por qué 7/7 es lo mismo que 1? Pon un ejemplo con algo que se reparte.',
    generar: (azar) {
      final denominador = azar.entre(2, 10);
      final tipo = azar.nextInt(10);
      final numerador = tipo < 1
          ? denominador
          : (tipo < 5 ? azar.entre(1, denominador - 1) : azar.entre(denominador + 1, 2 * denominador + 3));
      return Ejercicio(
        enunciado: 'Escribe <, = o > en el hueco:',
        destacado: '$numerador/$denominador   ___   1',
        solucion: _signoComparacion(numerador.compareTo(denominador)),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.05',
    descripcion:
        'Si dos fracciones tienen el mismo denominador, las partes son del mismo tamaño: '
        'es mayor la que tiene más partes, es decir, el numerador más grande.',
    preguntaExplicalo: '¿Por qué con el mismo denominador basta con mirar el numerador?',
    generar: (azar) {
      final denominador = azar.entre(3, 12);
      final primero = azar.entre(1, denominador - 1);
      var segundo = azar.entre(1, denominador - 1);
      if (segundo == primero) segundo = primero == 1 ? 2 : primero - 1;
      return Ejercicio(
        enunciado: 'Escribe <, = o > en el hueco:',
        destacado: '$primero/$denominador   ___   $segundo/$denominador',
        solucion: _signoComparacion(primero.compareTo(segundo)),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.06',
    descripcion:
        'Si dos fracciones tienen el mismo numerador, tomamos el mismo número de partes; '
        'es mayor la de denominador más pequeño, porque sus partes son más grandes.',
    preguntaExplicalo:
        '¿Qué prefieres, 1/3 o 1/8 de una tarta? Explica por qué el número más grande abajo '
        'da un trozo más pequeño.',
    generar: (azar) {
      final numerador = azar.entre(1, 5);
      final primero = azar.entre(numerador + 1, 12);
      var segundo = azar.entre(numerador + 1, 12);
      if (segundo == primero) segundo = primero + 1;
      return Ejercicio(
        enunciado: 'Escribe <, = o > en el hueco:',
        destacado: '$numerador/$primero   ___   $numerador/$segundo',
        solucion: _signoComparacion(segundo.compareTo(primero)),
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.07',
    descripcion:
        'Para comparar dos fracciones cualesquiera, pásalas a un denominador común (o '
        'multiplica en cruz): así las partes son del mismo tamaño y se pueden contar.',
    preguntaExplicalo:
        'Alguien dice que 5/7 es mayor que 3/4 «porque 5 y 7 son más grandes». ¿Tiene razón? '
        '¿Cómo se lo explicarías?',
    generar: (azar) {
      late Fraccion primera, segunda;
      do {
        primera = _propia(azar);
        segunda = _propia(azar);
      } while (primera.denominador == segunda.denominador ||
          primera.numerador == segunda.numerador ||
          primera.compareTo(segunda) == 0);
      return Ejercicio(
        enunciado: 'Escribe <, = o > en el hueco. Escribe cómo lo has comprobado.',
        destacado: '${primera.texto}   ___   ${segunda.texto}',
        solucion: _signoComparacion(primera.compareTo(segunda)),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.08',
    descripcion:
        'Ordenar fracciones es compararlas de dos en dos. Ayuda pasarlas todas a un '
        'denominador común o compararlas con 1/2.',
    preguntaExplicalo: '¿Qué truco usas para ordenar fracciones que tienen denominadores distintos?',
    generar: (azar) {
      final fracciones = _tresDistintas(azar, () => _propia(azar, denominadorMaximo: 9));
      final ordenadas = [...fracciones]..sort((a, b) => a.compareTo(b));
      return Ejercicio(
        enunciado: 'Ordena de menor a mayor:',
        destacado: fracciones.map((f) => f.texto).join('     '),
        solucion: ordenadas.map((f) => f.texto).join(' < '),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.09',
    descripcion:
        'Dos fracciones son equivalentes si valen lo mismo, como 1/2 y 2/4. Se consiguen '
        'multiplicando (o dividiendo) el numerador y el denominador por el mismo número.',
    preguntaExplicalo: '¿Por qué 2/4 y 1/2 son la misma cantidad? Explícalo con un dibujo o con palabras.',
    generar: (azar) {
      final base = _propia(azar, denominadorMaximo: 6).simplificada();
      final factor = azar.entre(2, 5);
      final sonEquivalentes = azar.nextBool();
      final ajuste = sonEquivalentes ? 0 : (azar.nextBool() ? 1 : -1);
      final otra = Fraccion(
          math.max(1, base.numerador * factor + ajuste), base.denominador * factor);
      final resultado = base.compareTo(otra) == 0;
      return Ejercicio(
        enunciado: '¿Son equivalentes estas dos fracciones? Responde sí o no y explica cómo lo sabes.',
        destacado: '${base.texto}   y   ${otra.texto}',
        solucion: resultado ? 'sí' : 'no',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.10',
    descripcion:
        'Simplificar es escribir la misma fracción con números más pequeños, dividiendo '
        'numerador y denominador entre el mismo número, hasta que no se pueda más.',
    preguntaExplicalo: '¿Cómo sabes que una fracción ya no se puede simplificar más?',
    generar: (azar) {
      final reducida = _propia(azar, denominadorMaximo: 9).simplificada();
      final factor = azar.entre(2, 6);
      final objetivo = Fraccion(reducida.numerador * factor, reducida.denominador * factor);
      return Ejercicio(
        enunciado: 'Simplifica hasta la fracción más sencilla:',
        destacado: '${objetivo.texto} =',
        solucion: reducida.texto,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.11',
    descripcion:
        'Amplificar es multiplicar numerador y denominador por el mismo número: la fracción '
        'sigue valiendo lo mismo, solo cambia el tamaño de las partes.',
    preguntaExplicalo: 'Para completar 3/4 = ?/12, ¿por qué número multiplicas y por qué?',
    generar: (azar) {
      final base = _propia(azar, denominadorMaximo: 8).simplificada();
      final factor = azar.entre(2, 6);
      return Ejercicio(
        enunciado: 'Completa el número que falta:',
        destacado: '${base.texto} = ___/${base.denominador * factor}',
        solucion: '${base.numerador * factor}',
        renglones: 1,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.12',
    descripcion:
        'Una fracción impropia (numerador mayor que el denominador) vale más que 1. Se puede '
        'escribir como número mixto: unidades enteras y una fracción. 7/3 = 2 y 1/3.',
    preguntaExplicalo: '¿Qué tiene que ver la división con pasar 7/3 a número mixto?',
    generar: (azar) {
      final denominador = azar.entre(2, 9);
      final enteros = azar.entre(1, 5);
      final resto = azar.entre(1, denominador - 1);
      final numerador = enteros * denominador + resto;
      return Ejercicio(
        enunciado: 'Escribe como número mixto:',
        destacado: '$numerador/$denominador =',
        solucion: '$enteros y $resto/$denominador',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.13',
    descripcion:
        'Para pasar un número mixto a fracción, cada unidad entera son tantas partes como '
        'diga el denominador: 2 y 3/4 son 4 + 4 + 3 = 11 cuartos, 11/4.',
    preguntaExplicalo: '¿Por qué 2 y 3/4 no es 23/4? Explícalo con tus palabras.',
    generar: (azar) {
      final denominador = azar.entre(2, 9);
      final enteros = azar.entre(1, 5);
      final numerador = azar.entre(1, denominador - 1);
      return Ejercicio(
        enunciado: 'Escribe como fracción:',
        destacado: '$enteros y $numerador/$denominador =',
        solucion: '${enteros * denominador + numerador}/$denominador',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.14',
    descripcion:
        'Con el mismo denominador las partes son iguales: se suman los numeradores y el '
        'denominador se queda como está. 2/7 + 3/7 = 5/7.',
    preguntaExplicalo: '¿Por qué no se suman también los denominadores? Pon un ejemplo con una tarta.',
    generar: (azar) {
      final denominador = azar.entre(3, 12);
      final primero = azar.entre(1, denominador - 2);
      final segundo = azar.entre(1, denominador - primero);
      return Ejercicio(
        enunciado: 'Suma:',
        destacado: '$primero/$denominador + $segundo/$denominador =',
        solucion: '${primero + segundo}/$denominador',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.15',
    descripcion:
        'Con el mismo denominador se restan los numeradores y el denominador se queda igual. '
        '5/8 − 2/8 = 3/8.',
    preguntaExplicalo: 'Si tienes 5/8 de pizza y te comes 2/8, ¿qué ha cambiado y qué no?',
    generar: (azar) {
      final denominador = azar.entre(3, 12);
      final primero = azar.entre(2, denominador);
      final segundo = azar.entre(1, primero - 1);
      return Ejercicio(
        enunciado: 'Resta:',
        destacado: '$primero/$denominador − $segundo/$denominador =',
        solucion: '${primero - segundo}/$denominador',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.16',
    descripcion:
        'Para sumar fracciones con denominadores distintos, primero se buscan fracciones '
        'equivalentes con el mismo denominador (el m.c.m.) y luego se suman los numeradores.',
    preguntaExplicalo: '¿Por qué hay que buscar un denominador común antes de sumar?',
    generar: (azar) {
      late Fraccion primera, segunda;
      do {
        primera = _propia(azar, denominadorMaximo: 8).simplificada();
        segunda = _propia(azar, denominadorMaximo: 8).simplificada();
      } while (primera.denominador == segunda.denominador);
      return Ejercicio(
        enunciado: 'Suma y simplifica si se puede:',
        destacado: '${primera.texto} + ${segunda.texto} =',
        solucion: (primera + segunda).texto,
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.17',
    descripcion:
        'Para restar fracciones con denominadores distintos, se pasan a un denominador común '
        'y después se restan los numeradores.',
    preguntaExplicalo: 'Explica paso a paso cómo resolverías 1/2 − 1/3 a alguien que no sabe.',
    generar: (azar) {
      late Fraccion primera, segunda;
      do {
        primera = _propia(azar, denominadorMaximo: 8).simplificada();
        segunda = _propia(azar, denominadorMaximo: 8).simplificada();
      } while (primera.denominador == segunda.denominador || primera.compareTo(segunda) <= 0);
      return Ejercicio(
        enunciado: 'Resta y simplifica si se puede:',
        destacado: '${primera.texto} − ${segunda.texto} =',
        solucion: (primera - segunda).texto,
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.18',
    descripcion:
        'Multiplicar una fracción por un número natural es sumarla varias veces: se multiplica '
        'el numerador y el denominador se queda igual. 3 × 2/5 = 6/5.',
    preguntaExplicalo: '¿Por qué 3 × 2/5 es lo mismo que 2/5 + 2/5 + 2/5?',
    generar: (azar) {
      final fraccion = _propia(azar, denominadorMaximo: 9);
      final natural = azar.entre(2, 6);
      return Ejercicio(
        enunciado: 'Multiplica y simplifica si se puede:',
        destacado: '$natural × ${fraccion.texto} =',
        solucion: (Fraccion(natural, 1) * fraccion).texto,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.19',
    descripcion:
        'Para multiplicar dos fracciones se multiplican los numeradores entre sí y los '
        'denominadores entre sí. 2/3 × 4/5 = 8/15.',
    preguntaExplicalo:
        'Al multiplicar 1/2 × 1/3 sale un número más pequeño que los dos. ¿Por qué crees que pasa?',
    generar: (azar) {
      final primera = _propia(azar, denominadorMaximo: 7);
      final segunda = _propia(azar, denominadorMaximo: 7);
      return Ejercicio(
        enunciado: 'Multiplica y simplifica si se puede:',
        destacado: '${primera.texto} × ${segunda.texto} =',
        solucion: (primera * segunda).texto,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.20',
    descripcion:
        'Dividir una fracción entre un número natural es repartirla: se multiplica el '
        'denominador por ese número. 3/4 : 2 = 3/8.',
    preguntaExplicalo: 'Si repartes 1/2 pizza entre 3 personas, ¿cuánto le toca a cada una? ¿Por qué?',
    generar: (azar) {
      final fraccion = _propia(azar, denominadorMaximo: 9);
      final natural = azar.entre(2, 5);
      return Ejercicio(
        enunciado: 'Divide y simplifica si se puede:',
        destacado: '${fraccion.texto} : $natural =',
        solucion: (fraccion / Fraccion(natural, 1)).texto,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.21',
    descripcion:
        'Para dividir entre una fracción se multiplica por su inversa (la fracción dada la '
        'vuelta). 2/3 : 4/5 = 2/3 × 5/4 = 10/12 = 5/6.',
    preguntaExplicalo: '¿Cuántas veces cabe 1/4 en 1/2? ¿Qué tiene que ver con dividir fracciones?',
    generar: (azar) {
      final primera = _propia(azar, denominadorMaximo: 7);
      final segunda = _propia(azar, denominadorMaximo: 7);
      return Ejercicio(
        enunciado: 'Divide y simplifica si se puede:',
        destacado: '${primera.texto} : ${segunda.texto} =',
        solucion: (primera / segunda).texto,
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.22',
    descripcion:
        'Para calcular la fracción de una cantidad, se divide la cantidad entre el denominador '
        '(lo que vale una parte) y se multiplica por el numerador. 3/5 de 20 = 12.',
    preguntaExplicalo: '¿Por qué primero se divide entre el denominador? ¿Qué significa ese número?',
    generar: (azar) {
      final fraccion = _propia(azar, denominadorMaximo: 8);
      final cantidad = fraccion.denominador * azar.entre(2, 10);
      final cosa = azar.elegir([
        ('alumnos de una clase', 'van en bici al cole'),
        ('libros de la biblioteca de aula', 'son de aventuras'),
        ('semillas plantadas', 'han brotado'),
        ('metros de un camino', 'están asfaltados'),
      ]);
      final resultado = cantidad ~/ fraccion.denominador * fraccion.numerador;
      return Ejercicio(
        enunciado: 'De $cantidad ${cosa.$1}, ${fraccion.texto} ${cosa.$2}. ¿Cuántos son?',
        solucion: '$resultado',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'FR.23',
    descripcion:
        'Con fracciones con signo se usan las mismas reglas que con los enteros: menos por '
        'menos da más. Para sumar, denominador común; al final, simplifica.',
    preguntaExplicalo: '¿Es lo mismo −3/4 que 3/(−4) y que −(3/4)? Explica por qué.',
    generar: (azar) {
      // Fracciones ya irreducibles y no enteras: nada de «4/4».
      Fraccion conSigno() {
        while (true) {
          final candidata = Fraccion(azar.conSignoNoNulo(5), azar.entre(2, 6)).simplificada();
          if (candidata.denominador > 1) return candidata;
        }
      }

      final primera = conSigno();
      final segunda = conSigno();
      final operacion = azar.nextInt(4);
      final simbolo = ['+', '−', '·', ':'][operacion];
      final resultado = [
        primera + segunda,
        primera - segunda,
        primera * segunda,
        primera / segunda,
      ][operacion];
      return Ejercicio(
        enunciado: 'Calcula y simplifica:',
        destacado: '${primera.texto} $simbolo ${segunda.textoOperando} =',
        solucion: resultado.texto,
        renglones: 3,
      );
    },
  ),
];
