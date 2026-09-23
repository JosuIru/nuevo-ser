import 'dart:math' as math;

import 'retos_calculo.dart';

/// Ejemplos resueltos para la ayuda de las máquinas: un problema
/// PARECIDO al que el niño tiene delante (misma habilidad, otros
/// números), resuelto paso a paso. Nunca el suyo: así aprende el método
/// sin que se le dé la respuesta, y la maestría sigue siendo honesta.
///
/// Los pasos son plantillas en castellano con marcadores `{a}`, `{b}`…
/// (se traducen con `traducirNarrativa` y luego se sustituyen).
class PasoEjemplo {
  final String plantilla;
  final Map<String, String> valores;

  const PasoEjemplo(this.plantilla, [this.valores = const {}]);

  /// La plantilla (ya traducida) con los valores puestos.
  String rellenar(String plantillaTraducida) {
    var texto = plantillaTraducida;
    valores.forEach((clave, valor) => texto = texto.replaceAll('{$clave}', valor));
    return texto;
  }
}

class EjemploResuelto {
  final String enunciado;
  final List<PasoEjemplo> pasos;

  const EjemploResuelto(this.enunciado, this.pasos);
}

/// Habilidades con ejemplo resuelto.
const habilidadesConEjemplo = {
  'ARI.01', 'OP.01', 'ARI.02', 'FR.22', 'PROP.04', // cálculo
  'FR.14', 'FR.16', 'DEC.04', // sumas de Puentes y Encaje
  'FR.09', 'DEC.08', 'PROP.05', // equivalencias de Parejas
  'DIV.01', 'DIV.03', 'DIV.04', 'DIV.05', 'DEC.02', 'FR.03', // reglas
};

/// Un ejemplo parecido para [idHabilidad], o null si no hay. [parametro]
/// es el de la regla en juego (el divisor de "múltiplos de 4"). Si el
/// ejemplo sale igual que [evitar] (el enunciado del niño), se busca otro.
EjemploResuelto? ejemploParecido(
  String idHabilidad, {
  int dificultad = 1,
  int? parametro,
  String? evitar,
  math.Random? azar,
}) {
  final aleatorio = azar ?? math.Random();
  for (var intento = 0; intento < 20; intento++) {
    final ejemplo = _ejemplo(idHabilidad, dificultad.clamp(1, 3), parametro, aleatorio);
    if (ejemplo == null) return null;
    if (ejemplo.enunciado != evitar) return ejemplo;
  }
  return null;
}

EjemploResuelto? _ejemplo(String id, int dificultad, int? parametro, math.Random azar) {
  int entre(int minimo, int maximo) => minimo + azar.nextInt(maximo - minimo + 1);
  switch (id) {
    case 'ARI.01' || 'OP.01' || 'ARI.02' || 'FR.22' || 'PROP.04':
      final reto = GeneradorRetosCalculo(azar: azar).generar(id, dificultad: dificultad);
      return _explicarCalculo(reto);
    case 'FR.14':
      final d = [4, 5, 6, 8, 10][azar.nextInt(5)];
      final a = entre(1, d - 2);
      final b = entre(1, d - 1 - a);
      return EjemploResuelto('$a/$d + $b/$d', [
        PasoEjemplo('Tienen el mismo denominador ({d}): se queda igual.', {'d': '$d'}),
        PasoEjemplo('Suma los de arriba: {a} + {b} = {s}.', {'a': '$a', 'b': '$b', 's': '${a + b}'}),
        PasoEjemplo('Resultado: {r}.', {'r': '${a + b}/$d'}),
      ]);
    case 'FR.16':
      final pares = const [(2, 3), (2, 4), (3, 4), (2, 6), (3, 6), (4, 6), (3, 12), (4, 12)];
      final (d1, d2) = pares[azar.nextInt(pares.length)];
      final a = entre(1, d1 - 1);
      final b = entre(1, d2 - 1);
      final comun = _mcm(d1, d2);
      final a2 = a * comun ~/ d1;
      final b2 = b * comun ~/ d2;
      return EjemploResuelto('$a/$d1 + $b/$d2', [
        PasoEjemplo('Busca un denominador que sirva para los dos: {c}.', {'c': '$comun'}),
        PasoEjemplo('{f} = {g}, multiplicando arriba y abajo por {m}.',
            {'f': '$a/$d1', 'g': '$a2/$comun', 'm': '${comun ~/ d1}'}),
        PasoEjemplo('{f} = {g}, multiplicando arriba y abajo por {m}.',
            {'f': '$b/$d2', 'g': '$b2/$comun', 'm': '${comun ~/ d2}'}),
        PasoEjemplo('Ahora suma los de arriba: {a} + {b} = {s}. Resultado: {r}.',
            {'a': '$a2', 'b': '$b2', 's': '${a2 + b2}', 'r': '${a2 + b2}/$comun'}),
      ]);
    case 'DEC.04':
      final a = entre(2, 9);
      final b = entre(11 - a, 9); // se pasa de 10 décimas: hay que llevarse una
      final suma = a + b;
      return EjemploResuelto('0,$a + 0,$b', [
        PasoEjemplo('Pon las comas una debajo de otra: son décimas.'),
        PasoEjemplo('Suma las décimas: {a} + {b} = {s} décimas.', {'a': '$a', 'b': '$b', 's': '$suma'}),
        PasoEjemplo('10 décimas son 1 unidad: {s} décimas = {r}.',
            {'s': '$suma', 'r': '${suma ~/ 10},${suma % 10}'}),
      ]);
    case 'FR.09':
      final d = [2, 3, 4, 5][azar.nextInt(4)];
      final n = entre(1, d - 1);
      final factor = entre(2, dificultad >= 2 ? 5 : 3);
      return EjemploResuelto('$n/$d = ?', [
        PasoEjemplo('Multiplica arriba y abajo por el mismo número, por ejemplo {m}.', {'m': '$factor'}),
        PasoEjemplo('Arriba: {n} × {m} = {a}. Abajo: {d} × {m} = {b}.',
            {'n': '$n', 'd': '$d', 'm': '$factor', 'a': '${n * factor}', 'b': '${d * factor}'}),
        PasoEjemplo('{f} y {g} valen lo mismo.', {'f': '$n/$d', 'g': '${n * factor}/${d * factor}'}),
      ]);
    case 'DEC.08' || 'PROP.05':
      final valores = const [(1, 2), (1, 4), (3, 4), (1, 5), (2, 5), (3, 5), (1, 10), (7, 10)];
      final (n, d) = valores[azar.nextInt(valores.length)];
      final factor = 100 ~/ d;
      final centesimas = n * factor;
      final decimal = _decimal(centesimas);
      return EjemploResuelto('$n/$d', [
        PasoEjemplo('Busca cuánto hay que multiplicar {d} para llegar a 100: {m}.',
            {'d': '$d', 'm': '$factor'}),
        PasoEjemplo('{f} = {g}.', {'f': '$n/$d', 'g': '$centesimas/100'}),
        if (id == 'DEC.08')
          PasoEjemplo('{c} centésimas se escriben {r}.', {'c': '$centesimas', 'r': decimal})
        else
          PasoEjemplo('{c} de cada 100 es el {r}.', {'c': '$centesimas', 'r': '$centesimas %'}),
      ]);
    case 'DIV.01' || 'DIV.03' || 'DIV.04':
      final n = parametro ?? (id == 'DIV.03' ? 5 : (id == 'DIV.04' ? 4 : 3));
      final x = entre(3, 12) * n + (azar.nextBool() ? 0 : entre(1, n - 1));
      final cociente = x ~/ n;
      final resto = x % n;
      return EjemploResuelto('¿$x ÷ $n?', [
        PasoEjemplo('Divide {x} entre {n}: {n} × {q} = {p}.',
            {'x': '$x', 'n': '$n', 'q': '$cociente', 'p': '${cociente * n}'}),
        if (resto == 0)
          PasoEjemplo('No sobra nada: {x} es múltiplo de {n}.', {'x': '$x', 'n': '$n'})
        else
          PasoEjemplo('Sobran {r}: {x} no es múltiplo de {n}.', {'r': '$resto', 'x': '$x', 'n': '$n'}),
      ]);
    case 'DIV.05':
      final x = entre(11, dificultad >= 2 ? 59 : 39);
      final divisor = [2, 3, 5, 7].where((p) => p < x && x % p == 0).firstOrNull;
      return EjemploResuelto('¿$x?', [
        PasoEjemplo('Prueba a dividir {x} entre 2, 3, 5 y 7.', {'x': '$x'}),
        if (divisor != null)
          PasoEjemplo('{x} ÷ {p} = {q}, exacto: no es primo.',
              {'x': '$x', 'p': '$divisor', 'q': '${x ~/ divisor}'})
        else
          PasoEjemplo('Ninguna división es exacta: {x} es primo.', {'x': '$x'}),
      ]);
    case 'DEC.02':
      final centesimas = entre(5, 95);
      final texto = _decimal(centesimas);
      final decimas = centesimas ~/ 10;
      return EjemploResuelto('¿$texto > 0,5?', [
        PasoEjemplo('Escribe 0,5 como 0,50 para comparar cifra a cifra.'),
        if (decimas != 5)
          PasoEjemplo(
              decimas > 5
                  ? 'Décimas: {a} es mayor que 5, así que {x} es mayor que 0,5.'
                  : 'Décimas: {a} es menor que 5, así que {x} es menor que 0,5.',
              {'a': '$decimas', 'x': texto})
        else
          PasoEjemplo(
              centesimas > 50
                  ? 'Las décimas empatan (5): mira las centésimas. {x} es mayor que 0,5.'
                  : 'Las décimas empatan (5): mira las centésimas. {x} es igual a 0,5.',
              {'x': texto}),
      ]);
    case 'FR.03':
      final d = entre(3, dificultad >= 2 ? 12 : 8);
      var n = entre(1, d - 1);
      if (n * 2 == d) n = n + 1 < d ? n + 1 : n - 1;
      final mitad = d / 2;
      final textoMitad = d.isEven ? '${d ~/ 2}' : mitad.toString().replaceAll('.', ',');
      return EjemploResuelto('¿$n/$d > 1/2?', [
        PasoEjemplo('La mitad de {d} es {m}.', {'d': '$d', 'm': textoMitad}),
        PasoEjemplo(
            n > mitad
                ? '{n} es más que {m}: {f} es mayor que 1/2.'
                : '{n} es menos que {m}: {f} es menor que 1/2.',
            {'n': '$n', 'm': textoMitad, 'f': '$n/$d'}),
      ]);
  }
  return null;
}

/// Explica un reto de cálculo leyendo su enunciado.
EjemploResuelto? _explicarCalculo(RetoCalculo reto) {
  final e = reto.enunciado;
  final r = '${reto.respuesta}';
  switch (reto.idHabilidad) {
    case 'ARI.01':
      final [a, b] = e.split(' + ').map(int.parse).toList();
      if (a < 10 && b < 10) {
        return EjemploResuelto(e, [
          PasoEjemplo('Empieza por el mayor y cuenta lo que falta: {m} y {k} más.',
              {'m': '${math.max(a, b)}', 'k': '${math.min(a, b)}'}),
          PasoEjemplo('{m} + {k} = {r}.', {'m': '${math.max(a, b)}', 'k': '${math.min(a, b)}', 'r': r}),
        ]);
      }
      final decenas = (a ~/ 10 + b ~/ 10) * 10;
      final unidades = a % 10 + b % 10;
      return EjemploResuelto(e, [
        PasoEjemplo('Decenas: {a} + {b} = {s}.',
            {'a': '${a ~/ 10 * 10}', 'b': '${b ~/ 10 * 10}', 's': '$decenas'}),
        PasoEjemplo('Unidades: {a} + {b} = {s}.', {'a': '${a % 10}', 'b': '${b % 10}', 's': '$unidades'}),
        PasoEjemplo('Junta las dos: {a} + {b} = {r}.', {'a': '$decenas', 'b': '$unidades', 'r': r}),
      ]);
    case 'OP.01':
      if (e.startsWith('(')) {
        final partes = RegExp(r'\d+').allMatches(e).map((m) => int.parse(m[0]!)).toList();
        final [a, b, c] = partes;
        return EjemploResuelto(e, [
          PasoEjemplo('Primero el paréntesis: {a} + {b} = {s}.', {'a': '$a', 'b': '$b', 's': '${a + b}'}),
          PasoEjemplo('Luego multiplica: {s} × {c} = {r}.', {'s': '${a + b}', 'c': '$c', 'r': r}),
        ]);
      }
      final partes = RegExp(r'\d+').allMatches(e).map((m) => int.parse(m[0]!)).toList();
      final [a, b, c] = partes;
      return EjemploResuelto(e, [
        PasoEjemplo('Primero la multiplicación: {b} × {c} = {m}.', {'b': '$b', 'c': '$c', 'm': '${b * c}'}),
        PasoEjemplo('Luego la suma: {a} + {m} = {r}.', {'a': '$a', 'm': '${b * c}', 'r': r}),
      ]);
    case 'ARI.02':
      final base = int.parse(e.substring(0, e.length - 1));
      if (e.endsWith('³')) {
        return EjemploResuelto(e, [
          PasoEjemplo('{e} es {b} × {b} × {b}.', {'e': e, 'b': '$base'}),
          PasoEjemplo('{b} × {b} = {c}; {c} × {b} = {r}.',
              {'b': '$base', 'c': '${base * base}', 'r': r}),
        ]);
      }
      return EjemploResuelto(e, [
        PasoEjemplo('{e} es {b} × {b} (no {b} × 2).', {'e': e, 'b': '$base'}),
        PasoEjemplo('{b} × {b} = {r}.', {'b': '$base', 'r': r}),
      ]);
    case 'FR.22':
      final partes = RegExp(r'\d+').allMatches(e).map((m) => int.parse(m[0]!)).toList();
      final [n, d, cantidad] = partes;
      final parte = cantidad ~/ d;
      return EjemploResuelto(e, [
        PasoEjemplo('Divide {q} entre {d}: sale {u}. Eso es 1/{d}.',
            {'q': '$cantidad', 'd': '$d', 'u': '$parte'}),
        if (n > 1)
          PasoEjemplo('Quieres {n} partes: {u} × {n} = {r}.', {'n': '$n', 'u': '$parte', 'r': r})
        else
          PasoEjemplo('Sólo quieres una parte: {r}.', {'r': r}),
      ]);
    case 'PROP.04':
      final partes = RegExp(r'\d+').allMatches(e).map((m) => int.parse(m[0]!)).toList();
      final [p, cantidad] = partes;
      final q = '$cantidad';
      return EjemploResuelto(e, switch (p) {
        50 => [PasoEjemplo('El 50 % es la mitad: {q} ÷ 2 = {r}.', {'q': q, 'r': r})],
        10 => [PasoEjemplo('El 10 % es dividir entre 10: {q} ÷ 10 = {r}.', {'q': q, 'r': r})],
        25 => [PasoEjemplo('El 25 % es la cuarta parte: {q} ÷ 4 = {r}.', {'q': q, 'r': r})],
        75 => [
            PasoEjemplo('El 25 % es la cuarta parte: {q} ÷ 4 = {t}.', {'q': q, 't': '${cantidad ~/ 4}'}),
            PasoEjemplo('El 75 % son tres cuartas partes: {t} × 3 = {r}.', {'t': '${cantidad ~/ 4}', 'r': r}),
          ],
        20 => [
            PasoEjemplo('El 10 % es dividir entre 10: {q} ÷ 10 = {r}.', {'q': q, 'r': '${cantidad ~/ 10}'}),
            PasoEjemplo('El 20 % es el doble: {t} × 2 = {r}.', {'t': '${cantidad ~/ 10}', 'r': r}),
          ],
        _ => [
            PasoEjemplo('Calcula {p} de cada 100: {q} × {p} ÷ 100 = {r}.', {'p': '$p', 'q': q, 'r': r}),
          ],
      });
  }
  return null;
}

String _decimal(int centesimas) {
  final texto = '${centesimas ~/ 100},${(centesimas % 100).toString().padLeft(2, '0')}';
  return texto.endsWith('0') ? texto.substring(0, texto.length - 1) : texto;
}

int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);
int _mcm(int a, int b) => a ~/ _mcd(a, b) * b;
