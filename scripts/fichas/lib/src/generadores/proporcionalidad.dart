import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas del dominio PROP (proporcionalidad y porcentajes).

const _parejasRazon = [
  ('manzanas', 'naranjas'),
  ('chicas', 'chicos'),
  ('vasos de agua', 'cucharadas de cacao'),
  ('árboles', 'arbustos'),
  ('lápices', 'gomas'),
];

/// (magnitud A, magnitud B, plantilla, valores creíbles de B por cada A).
const _magnitudesDirectas = [
  ('kg de manzanas', '€', 'Si {a} {ma} cuestan {b} {mb}, ¿cuánto cuestan {c} {ma}?', [2, 3, 4]),
  ('cuadernos', '€', 'Si {a} {ma} cuestan {b} {mb}, ¿cuánto cuestan {c} {ma}?', [2, 3, 4, 5, 6]),
  ('horas', 'km',
      'Una ciclista recorre {b} {mb} en {a} {ma}. Al mismo ritmo, ¿cuántos km recorre en {c} {ma}?',
      [12, 14, 15, 16, 18, 20]),
  ('personas', 'g de pasta',
      'Para {a} {ma} hacen falta {b} {mb}. ¿Cuántos gramos hacen falta para {c} {ma}?',
      [80, 90, 100, 120]),
];

/// Euros como se escriben: «66 €» o «52,50 €» (nunca «52,5 €»).
String _euros(num cantidad) => cantidad == cantidad.roundToDouble()
    ? '${formatearEntero(cantidad.round())} €'
    : '${formatearDecimalFijo(cantidad, 2)} €';

final List<PlantillaFicha> plantillasProporcionalidad = [
  PlantillaFicha(
    idHabilidad: 'PROP.01',
    descripcion:
        'Una razón compara dos cantidades dividiéndolas.\n'
        'Ejemplo: si hay 12 manzanas y 8 naranjas, la razón es 12 : 8, que simplificada queda '
        '3 : 2: por cada 3 manzanas hay 2 naranjas.',
    preguntaExplicalo: '¿Qué significa decir que la razón de chicas a chicos de una clase es 1 : 1?',
    generar: (azar) {
      final (primera, segunda) = azar.elegir(_parejasRazon);
      late int a, b;
      do {
        final factor = azar.entre(2, 6);
        a = azar.entre(1, 6) * factor;
        b = azar.entre(1, 6) * factor;
      } while (a == b);
      final divisor = mcd(a, b);
      return Ejercicio(
        enunciado: 'Hay $a $primera y $b $segunda. Escribe la razón de $primera a $segunda '
            'y simplifícala.',
        solucion: '$a : $b = ${a ~/ divisor} : ${b ~/ divisor}',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.02',
    descripcion:
        'Dos magnitudes son directamente proporcionales si al multiplicar una por un número, '
        'la otra se multiplica por el mismo número. En la tabla, el cociente es siempre igual.\n'
        'Ejemplo: 1 kg cuesta 3 €, 2 kg cuestan 6 € y 5 kg, 15 €: 3 : 1 = 6 : 2 = 15 : 5 = 3.',
    preguntaExplicalo:
        'La edad y la altura de una persona, ¿son directamente proporcionales? ¿Por qué?',
    generar: (azar) {
      final constante = azar.entre(2, 9);
      final esProporcional = azar.nextBool();
      final sumando = azar.entre(1, 5);
      final valoresX = [1, 2, 3, 4, 5]..removeAt(azar.nextInt(5));
      final valoresY = [
        for (final x in valoresX) esProporcional ? x * constante : x * constante + sumando,
      ];
      final contexto = azar.elegir([
        ('Entradas', 'Precio (€)'),
        ('Minutos', 'Litros'),
        ('Paquetes', 'Galletas'),
      ]);
      return Ejercicio(
        enunciado: '¿Es una tabla de proporcionalidad directa? Responde sí o no y explica cómo lo has comprobado.',
        tabla: [
          [contexto.$1, ...valoresX.map((x) => '$x')],
          [contexto.$2, ...valoresY.map((y) => '$y')],
        ],
        solucion: esProporcional ? 'sí (constante $constante)' : 'no',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.03',
    descripcion:
        'La regla de tres sirve cuando dos magnitudes son directamente proporcionales: con tres '
        'datos se calcula el cuarto. Un camino es calcular primero lo que corresponde a 1.\n'
        'Ejemplo: si 4 cuadernos cuestan 12 €, 1 cuesta 12 : 4 = 3 €, y 7 cuestan 7 × 3 = 21 €.',
    preguntaExplicalo: '¿Cómo sabes si un problema se puede resolver con una regla de tres directa?',
    generar: (azar) {
      final (magnitudA, magnitudB, plantilla, valoresPorUnidad) = azar.elegir(_magnitudesDirectas);
      final porUnidad = azar.elegir(valoresPorUnidad);
      final a = azar.entre(2, 6);
      var c = azar.entre(2, 12);
      if (c == a) c++;
      final enunciado = plantilla
          .replaceAll('{a}', '$a')
          .replaceAll('{b}', '${a * porUnidad}')
          .replaceAll('{c}', '$c')
          .replaceAll('{ma}', magnitudA)
          .replaceAll('{mb}', magnitudB);
      return Ejercicio(enunciado: enunciado, solucion: '${c * porUnidad}', renglones: 3);
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.04',
    descripcion:
        'Un porcentaje es una fracción con denominador 100: el 25 % de algo son 25 de cada 100. '
        'Para calcularlo, multiplica la cantidad por el porcentaje y divide entre 100.\n'
        'Ejemplo: el 30 % de 60 es 60 × 30 : 100 = 18.',
    preguntaExplicalo: '¿Por qué el 50 % de una cantidad es la mitad? ¿Y el 25 %?',
    generar: (azar) {
      final porcentaje = azar.elegir([10, 20, 25, 30, 40, 50, 60, 75, 5, 15]);
      final cantidad = azar.entre(1, 20) * 20;
      return Ejercicio(
        enunciado: 'Calcula:',
        destacado: 'el $porcentaje % de $cantidad =',
        solucion: formatearDecimal(porcentaje * cantidad / 100),
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.05',
    descripcion:
        'Para saber qué porcentaje es una parte del total, divide la parte entre el total y '
        'multiplica por 100.\n'
        'Ejemplo: 12 de 50 son 12 : 50 × 100 = 24 %.',
    preguntaExplicalo: 'Si 30 de 30 alumnos traen almuerzo, ¿qué porcentaje es? ¿Por qué?',
    generar: (azar) {
      // Solo combinaciones con parte entera: 25 × 5 % daría 1,25.
      late int total, porcentaje;
      do {
        total = azar.elegir([20, 25, 40, 50, 80, 200]);
        porcentaje = azar.elegir([5, 10, 20, 25, 30, 40, 60, 75, 80]);
      } while (total * porcentaje % 100 != 0);
      final parte = total * porcentaje ~/ 100;
      final contexto = azar.elegir([
        ('preguntas de un test', 'están bien contestadas'),
        ('alumnos', 'vienen andando'),
        ('plantas del huerto', 'han dado flor'),
      ]);
      return Ejercicio(
        enunciado: 'De $total ${contexto.$1}, $parte ${contexto.$2}. ¿Qué porcentaje es?',
        solucion: '$porcentaje %',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.06',
    descripcion:
        'En un aumento del 10 % se suma al precio su 10 %; en un descuento del 10 %, se resta. '
        'También se puede multiplicar directamente por 1,10 o por 0,90.\n'
        'Ejemplo: un abrigo de 40 € con un 25 % de descuento: el 25 % de 40 es 10, y 40 − 10 = 30 €.',
    preguntaExplicalo: '¿Por qué un descuento del 20 % es lo mismo que pagar el 80 %?',
    generar: (azar) {
      final esAumento = azar.nextBool();
      // Una bici de menos de 80 € no es creíble; un abrigo, desde 20 €.
      final cantidad = (esAumento ? azar.entre(8, 40) : azar.entre(2, 30)) * 10;
      final porcentaje = azar.elegir([10, 20, 25, 50, 15, 30]);
      final variacion = cantidad * porcentaje / 100;
      final resultado = esAumento ? cantidad + variacion : cantidad - variacion;
      return Ejercicio(
        enunciado: esAumento
            ? 'Una bici cuesta $cantidad € y su precio sube un $porcentaje %. ¿Cuánto cuesta ahora?'
            : 'Un abrigo cuesta $cantidad € y tiene un descuento del $porcentaje %. ¿Cuánto se paga?',
        solucion: _euros(resultado),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.07',
    descripcion:
        'La escala de un mapa o plano dice cuántas veces se ha reducido la realidad: en escala '
        '1 : 500, 1 cm del plano son 500 cm (5 m) de verdad.\n'
        'Ejemplo: en un plano a escala 1 : 500, 3 cm son 1500 cm, es decir, 15 m.',
    preguntaExplicalo: '¿Qué mapa muestra más detalle, uno a escala 1 : 1000 o uno a 1 : 100 000? ¿Por qué?',
    generar: (azar) {
      final escala = azar.elegir([100, 200, 500, 1000, 50000, 100000]);
      final centimetros = azar.entre(2, 12);
      final realCm = centimetros * escala;
      final solucion = realCm >= 100000
          ? '${formatearDecimal(realCm / 100000)} km'
          : '${formatearDecimal(realCm / 100)} m';
      return Ejercicio(
        enunciado: 'En un ${escala >= 50000 ? 'mapa' : 'plano'} a escala 1 : ${formatearEntero(escala)}, '
            'dos puntos están a $centimetros cm. ¿A qué distancia están en la realidad? '
            'Da el resultado en ${escala >= 50000 ? 'km' : 'm'}.',
        solucion: solucion,
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.08',
    descripcion:
        'Dos magnitudes son inversamente proporcionales si, cuando una se duplica, la otra se '
        'reduce a la mitad. Su producto es siempre el mismo.\n'
        'Ejemplo: si 2 grifos llenan un depósito en 12 minutos, 4 grifos tardan 6 minutos '
        '(2 · 12 = 4 · 6 = 24).',
    preguntaExplicalo:
        'Si más personas pintan una valla, tardan menos. ¿Pasa siempre? ¿Hay algún límite? Explícalo.',
    generar: (azar) {
      const totales = [12, 24, 36, 48, 60];
      final producto = azar.elegir(totales);
      // Entre 2 y 12 personas o grifos: cantidades que se imaginan bien.
      final divisores = [for (var d = 2; d <= 12; d++) if (producto % d == 0 && producto ~/ d <= 30) d];
      final a = azar.elegir(divisores);
      late int c;
      do {
        c = azar.elegir(divisores);
      } while (c == a);
      final contexto = azar.nextBool()
          ? ('$a personas pintan una valla en ${producto ~/ a} horas. ¿Cuántas horas tardarían '
              '$c personas trabajando al mismo ritmo?', '${producto ~/ c} horas')
          : ('Con $a grifos iguales, un depósito se llena en ${producto ~/ a} minutos. '
              '¿Cuánto tarda con $c grifos?', '${producto ~/ c} minutos');
      return Ejercicio(enunciado: contexto.$1, solucion: contexto.$2, renglones: 3);
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.09',
    descripcion:
        'Cuando se aplican varios porcentajes seguidos, cada uno se calcula sobre el resultado '
        'del anterior. Por eso subir un 10 % y bajar un 10 % no deja el precio igual.\n'
        'Ejemplo: 200 € que suben un 20 % son 240 €; si después bajan un 25 %, quedan 240 − 60 = 180 €.',
    preguntaExplicalo: '¿Por qué subir un 10 % y después bajar un 10 % no te devuelve al precio inicial?',
    generar: (azar) {
      final inicial = azar.entre(1, 10) * 100;
      final primero = azar.elegir([10, 20, 25, 50]);
      final segundo = azar.elegir([10, 20, 25, 50]);
      final primeroSube = azar.nextBool();
      final segundoSube = azar.nextBool();
      final tras1 = inicial * (100 + (primeroSube ? primero : -primero)) / 100;
      final tras2 = tras1 * (100 + (segundoSube ? segundo : -segundo)) / 100;
      String verbo(bool sube) => sube ? 'sube' : 'baja';
      return Ejercicio(
        enunciado: 'Un precio de $inicial € ${verbo(primeroSube)} un $primero % y después '
            '${verbo(segundoSube)} un $segundo %. ¿Cuál es el precio final?',
        solucion: _euros(tras2),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'PROP.10',
    descripcion:
        'En un reparto proporcional, cada parte recibe según lo que aporta. Se suman las partes, '
        'se ve cuánto vale una parte y se multiplica.\n'
        'Ejemplo: 30 kg para quien trabaja 2 horas y quien trabaja 3 son 5 partes de 30 : 5 = 6 kg: '
        '12 kg y 18 kg.',
    preguntaExplicalo: '¿Te parece justo repartir según lo que ha trabajado cada uno? ¿Cuándo sí y cuándo no?',
    generar: (azar) {
      final parteA = azar.entre(2, 5);
      var parteB = azar.entre(2, 5);
      if (parteB == parteA) parteB++;
      final valorParte = azar.entre(2, 15);
      final total = (parteA + parteB) * valorParte;
      return Ejercicio(
        enunciado: 'Dos grupos recogen $total kg de aceitunas. El primero trabaja $parteA horas y '
            'el segundo $parteB. Repártelas en proporción a las horas.',
        solucion: '${parteA * valorParte} kg y ${parteB * valorParte} kg',
        renglones: 4,
      );
    },
  ),
];
