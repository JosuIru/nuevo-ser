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
  'DIV.06', 'DIV.07', // Engranajes
  'FR.04', 'FR.05', 'FR.06', 'FR.07', 'FR.08', 'DEC.03', // Esclusas
  'GEO.02', 'GEO.03', 'GEO.04', 'MED.05', // Planos
  'EST.05', 'EST.06', // Las redes
  'EST.01', 'EST.03', 'EST.04', // Nivelar
  'FUN.01', 'ALG.03', // La caja negra
  'ARI.04', 'ARI.05', // El pozo
  'PROP.01', 'PROP.02', 'PROP.03', 'PROP.06', 'PROP.07', // Pinturas
  'MED.04', 'GEO.01', 'GEO.07', // Rebote
  'MED.01', 'MED.02', 'MED.03', // El taller del relojero
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
    case 'MED.04':
      final llega = 5 * entre(3, 16);
      return EjemploResuelto('$llega°', [
        PasoEjemplo('El rayo llega al espejo con {g}°.', {'g': '$llega'}),
        PasoEjemplo('Rebota como una pelota: sale con los mismos {g}°, hacia el otro lado.', {'g': '$llega'}),
      ]);
    case 'GEO.01':
      final grados = const [35, 90, 120, 180, 60, 145][azar.nextInt(6)];
      final conclusion = grados < 90
          ? '{g}° es menos que 90°: agudo.'
          : (grados == 90 ? '{g}° es justo una esquina: recto.' : (grados < 180 ? '{g}° está entre 90° y 180°: obtuso.' : '{g}° es una línea recta: llano.'));
      return EjemploResuelto('$grados°', [
        PasoEjemplo('Compáralo con 90° (una esquina) y con 180° (una recta).'),
        PasoEjemplo(conclusion, {'g': '$grados'}),
      ]);
    case 'GEO.07':
      final distancia = entre(1, 3);
      return EjemploResuelto('[ ]  |  [ ]', [
        PasoEjemplo('Un cuadro está a {d} del espejo.', {'d': '$distancia'}),
        PasoEjemplo('Su reflejo, a {d} del espejo por el otro lado, en la misma fila.', {'d': '$distancia'}),
      ]);
    case 'MED.01':
      final cm = entre(105, 290);
      return EjemploResuelto('$cm cm = ? m', [
        PasoEjemplo('100 cm son 1 m.'),
        PasoEjemplo('{c} cm = {m} m {r} cm = {d} m.',
            {'c': '$cm', 'm': '${cm ~/ 100}', 'r': '${cm % 100}', 'd': '${cm ~/ 100},${(cm % 100).toString().padLeft(2, '0')}'}),
      ]);
    case 'MED.02':
      final gramos = 50 * entre(21, 59);
      final decimal = '${gramos ~/ 1000},${(gramos % 1000).toString().padLeft(3, '0').replaceAll(RegExp(r'0+$'), '')}';
      return EjemploResuelto('$gramos g = ? kg', [
        PasoEjemplo('1000 g son 1 kg.'),
        PasoEjemplo('{g} g = {k} kg y {r} g = {d} kg.',
            {'g': '$gramos', 'k': '${gramos ~/ 1000}', 'r': '${gramos % 1000}', 'd': decimal}),
      ]);
    case 'MED.03':
      final hora = entre(8, 20);
      final minutos = 5 * entre(6, 11);
      final suma = 5 * entre(4, 11);
      final total = minutos + suma;
      return EjemploResuelto('$hora:${minutos.toString().padLeft(2, '0')} + $suma min', [
        PasoEjemplo('Minutos: {a} + {b} = {t}.', {'a': '$minutos', 'b': '$suma', 't': '$total'}),
        PasoEjemplo('{t} minutos son 1 hora y {r} minutos: las {h}:{m}.',
            {'t': '$total', 'r': '${total - 60}', 'h': '${hora + 1}', 'm': (total - 60).toString().padLeft(2, '0')}),
      ]);
    case 'ARI.04':
      final inicio = entre(1, 6);
      final baja = entre(inicio + 1, inicio + 8);
      return EjemploResuelto('$inicio − $baja', [
        PasoEjemplo('Desde la {a}, baja {a} plantas y llegas al suelo (0).', {'a': '$inicio'}),
        PasoEjemplo('Te quedan {r} por bajar: acabas en la −{r}.', {'r': '${baja - inicio}'}),
      ]);
    case 'ARI.05':
      final a = -entre(2, 8);
      final b = entre(2, 8);
      return EjemploResuelto('¿$a → $b?', [
        PasoEjemplo('De la {a} al suelo hay {x} plantas.', {'a': '$a', 'x': '${-a}'}),
        PasoEjemplo('Del suelo a la {b}, {b} más: {x} + {b} = {r}.', {'b': '$b', 'x': '${-a}', 'r': '${b - a}'}),
      ]);
    case 'PROP.01':
      final a = entre(1, 4);
      final b = a + entre(1, 3);
      final k = entre(2, 4);
      return EjemploResuelto('¿$a : $b = ${a * k} : ${b * k}?', [
        PasoEjemplo('{a} × {k} = {x} y {b} × {k} = {y}.', {'a': '$a', 'b': '$b', 'k': '$k', 'x': '${a * k}', 'y': '${b * k}'}),
        PasoEjemplo('Los dos por el mismo número: misma razón, mismo color.'),
      ]);
    case 'PROP.02':
      final a = entre(1, 3);
      final b = a + entre(1, 3);
      final k = entre(2, 5);
      return EjemploResuelto('$a : $b → ${(a + b) * k}', [
        PasoEjemplo('Cada tanda lleva {a} + {b} = {t} botes.', {'a': '$a', 'b': '$b', 't': '${a + b}'}),
        PasoEjemplo('{n} ÷ {t} = {k} tandas.', {'n': '${(a + b) * k}', 't': '${a + b}', 'k': '$k'}),
        PasoEjemplo('Azul: {a} × {k} = {x}. Amarillo: {b} × {k} = {y}.',
            {'a': '$a', 'b': '$b', 'k': '$k', 'x': '${a * k}', 'y': '${b * k}'}),
      ]);
    case 'PROP.03':
      final a = entre(1, 3);
      final b = a + entre(1, 3);
      final k = entre(2, 5);
      return EjemploResuelto('$a : $b = ${a * k} : ?', [
        PasoEjemplo('De {a} a {x} se ha multiplicado por {k}.', {'a': '$a', 'x': '${a * k}', 'k': '$k'}),
        PasoEjemplo('El otro, igual: {b} × {k} = {y}.', {'b': '$b', 'k': '$k', 'y': '${b * k}'}),
      ]);
    case 'PROP.06':
      final porcentaje = const [10, 20, 25, 50][azar.nextInt(4)];
      final paso = 100 ~/ _mcd(porcentaje, 100);
      final precio = paso * entre(2, 8);
      final descuento = precio * porcentaje ~/ 100;
      return EjemploResuelto('$precio € − $porcentaje %', [
        PasoEjemplo('El {p} % de {x} € es {d} €.', {'p': '$porcentaje', 'x': '$precio', 'd': '$descuento'}),
        PasoEjemplo('Se resta: {x} − {d} = {r} €.', {'x': '$precio', 'd': '$descuento', 'r': '${precio - descuento}'}),
      ]);
    case 'PROP.07':
      final escala = const [2, 5, 10, 20][azar.nextInt(4)];
      final cm = entre(2, 9);
      return EjemploResuelto('1 cm = $escala m · $cm cm', [
        PasoEjemplo('Cada centímetro son {e} m.', {'e': '$escala'}),
        PasoEjemplo('{c} × {e} = {r} m.', {'c': '$cm', 'e': '$escala', 'r': '${cm * escala}'}),
      ]);
    case 'FUN.01':
      final a = entre(2, 4);
      final b = entre(1, 6);
      int y(int x) => a * x + b;
      return EjemploResuelto('1 → ${y(1)}   2 → ${y(2)}   3 → ${y(3)}', [
        PasoEjemplo('Cada vez que entra uno más, sale {a} más: la regla multiplica por {a}.', {'a': '$a'}),
        PasoEjemplo('{a} × 1 = {p}, pero sale {s}: además suma {b}.', {'a': '$a', 'p': '$a', 's': '${y(1)}', 'b': '$b'}),
        PasoEjemplo('La regla: × {a} y + {b}. Si entra 10, sale {r}.', {'a': '$a', 'b': '$b', 'r': '${y(10)}'}),
      ]);
    case 'ALG.03':
      final azul = entre(2, 8);
      final rojo = azul + entre(1, 6);
      return EjemploResuelto('x + y = ${rojo + azul}   x − y = ${rojo - azul}', [
        PasoEjemplo('Suma las dos: la y se va y quedan dos x = {s}.', {'s': '${2 * rojo}'}),
        PasoEjemplo('Una x: {s} ÷ 2 = {r}. Y la y: {t} − {r} = {z}.',
            {'s': '${2 * rojo}', 'r': '$rojo', 't': '${rojo + azul}', 'z': '$azul'}),
      ]);
    case 'EST.01':
      final a = entre(4, 9);
      final b = entre(1, a - 1);
      return EjemploResuelto('A = $a · B = $b', [
        PasoEjemplo('La barra A llega a la línea del {a} en el eje; la B, a la del {b}.', {'a': '$a', 'b': '$b'}),
        PasoEjemplo('A tiene {a} − {b} = {r} más que B.', {'a': '$a', 'b': '$b', 'r': '${a - b}'}),
      ]);
    case 'EST.03':
      List<int> datos;
      do {
        datos = [for (var i = 0; i < 4; i++) entre(1, 9)];
      } while (datos.reduce((x, y) => x + y) % 4 != 0);
      final suma = datos.reduce((x, y) => x + y);
      return EjemploResuelto(datos.join(', '), [
        PasoEjemplo('Suma todo: {s}.', {'s': '${datos.join(' + ')} = $suma'}),
        PasoEjemplo('Reparte entre {n}: {s} ÷ {n} = {m}.', {'s': '$suma', 'n': '4', 'm': '${suma ~/ 4}'}),
      ]);
    case 'EST.04':
      final datos = [for (var i = 0; i < 5; i++) entre(1, 9)];
      final ordenados = [...datos]..sort();
      return EjemploResuelto(datos.join(', '), [
        PasoEjemplo('Ordena de menor a mayor: {o}.', {'o': ordenados.join(', ')}),
        PasoEjemplo('El del medio (el tercero de cinco) es la mediana: {m}.', {'m': '${ordenados[2]}'}),
      ]);
    case 'EST.05':
      final pares = const [((3, 8), (5, 16)), ((2, 5), (3, 10)), ((4, 12), (3, 6)), ((5, 20), (2, 6))];
      final ((a, t), (b, s)) = pares[azar.nextInt(pares.length)];
      final mejor = a * s > b * t ? '$a de $t' : '$b de $s';
      return EjemploResuelto('¿$a de $t o $b de $s?', [
        PasoEjemplo('Escribe cada red como fracción: {f} y {g}.', {'f': '$a/$t', 'g': '$b/$s'}),
        PasoEjemplo('Multiplica en cruz: {a} × {s} = {x} y {b} × {t} = {y}.',
            {'a': '$a', 's': '$s', 'x': '${a * s}', 'b': '$b', 't': '$t', 'y': '${b * t}'}),
        PasoEjemplo('Gana la del producto mayor: {m}.', {'m': mejor}),
      ]);
    case 'EST.06':
      final casos = const [(1, 4), (3, 10), (2, 5), (7, 20), (3, 4)];
      final (a, t) = casos[azar.nextInt(casos.length)];
      final factor = 100 ~/ t;
      final porcentaje = a * factor;
      final decimal = porcentaje % 10 == 0 ? '0,${porcentaje ~/ 10}' : '0,$porcentaje';
      return EjemploResuelto('$a de $t', [
        PasoEjemplo('Como fracción: {f}.', {'f': '$a/$t'}),
        PasoEjemplo('Multiplica arriba y abajo por {m}: {g}.', {'m': '$factor', 'g': '$porcentaje/100'}),
        PasoEjemplo('Como decimal, {d}; como porcentaje, {p} %.', {'d': decimal, 'p': '$porcentaje'}),
      ]);
    case 'GEO.03':
      final ancho = entre(3, 8);
      final alto = entre(2, 6);
      return EjemploResuelto('$ancho m × $alto m', [
        PasoEjemplo('Una fila tiene {a} cuadros y hay {h} filas.', {'a': '$ancho', 'h': '$alto'}),
        PasoEjemplo('Área: {a} × {h} = {r} m².', {'a': '$ancho', 'h': '$alto', 'r': '${ancho * alto}'}),
      ]);
    case 'GEO.02':
      final area = const [12, 16, 18, 20, 24, 30, 36][azar.nextInt(7)];
      final formas = [
        for (var a = 1; a <= area; a++)
          if (area % a == 0 && a <= area ~/ a) (a, area ~/ a),
      ];
      final mejor = formas.last;
      return EjemploResuelto('$area m²', [
        for (final (a, b) in formas)
          PasoEjemplo('{a} × {b}: valla de {p} m.', {'a': '$a', 'b': '$b', 'p': '${2 * (a + b)}'}),
        PasoEjemplo('La más cuadrada, {a} × {b}, gasta menos valla.', {'a': '${mejor.$1}', 'b': '${mejor.$2}'}),
      ]);
    case 'GEO.04':
      final base = entre(2, 8);
      final altura = entre(2, 6) * (base.isOdd ? 2 : 1);
      return EjemploResuelto('△ $base m × $altura m', [
        PasoEjemplo('El rectángulo que lo contiene: {b} × {h} = {r} m².',
            {'b': '$base', 'h': '$altura', 'r': '${base * altura}'}),
        PasoEjemplo('El triángulo es la mitad: {r} ÷ 2 = {t} m².',
            {'r': '${base * altura}', 't': '${base * altura ~/ 2}'}),
      ]);
    case 'MED.05':
      final m2 = entre(3, 40);
      return EjemploResuelto('${m2 * 100} dm² = ? m²', [
        PasoEjemplo('1 m² = 10 dm × 10 dm = 100 dm².'),
        PasoEjemplo('{d} ÷ 100 = {m} m².', {'d': '${m2 * 100}', 'm': '$m2'}),
      ]);
    case 'FR.04':
      final d = entre(3, 9);
      var n = entre(1, d * 2 - 1);
      if (n == d) n++;
      return EjemploResuelto('¿$n/$d > 1?', [
        PasoEjemplo('Compara el de arriba con el de abajo: {n} y {d}.', {'n': '$n', 'd': '$d'}),
        PasoEjemplo(n > d ? '{n} es mayor que {d}: {f} es más que 1.' : '{n} es menor que {d}: {f} es menos que 1.',
            {'n': '$n', 'd': '$d', 'f': '$n/$d'}),
      ]);
    case 'FR.05':
      final d = entre(5, 12);
      final a = entre(1, d - 2);
      final b = entre(a + 1, d - 1);
      return EjemploResuelto('¿$a/$d o $b/$d?', [
        PasoEjemplo('Mismo denominador ({d}): mira sólo los de arriba.', {'d': '$d'}),
        PasoEjemplo('{b} > {a}: {f} es la mayor.', {'a': '$a', 'b': '$b', 'f': '$b/$d'}),
      ]);
    case 'FR.06':
      final n = entre(1, 4);
      final d1 = entre(n + 1, 8);
      final d2 = entre(d1 + 1, 12);
      return EjemploResuelto('¿$n/$d1 o $n/$d2?', [
        PasoEjemplo('Mismo numerador ({n}): mira los de abajo.', {'n': '$n'}),
        PasoEjemplo('Partido en {a}, cada trozo es más grande que partido en {b}: {f} es la mayor.',
            {'a': '$d1', 'b': '$d2', 'f': '$n/$d1'}),
      ]);
    case 'FR.07':
      int a, b, c, d;
      do {
        b = entre(3, 9);
        d = entre(3, 9);
        a = entre(1, b - 1);
        c = entre(1, d - 1);
      } while (b == d || a * d == c * b);
      final mayor = a * d > c * b ? '$a/$b' : '$c/$d';
      return EjemploResuelto('¿$a/$b o $c/$d?', [
        PasoEjemplo('Multiplica en cruz: {a} × {d} = {x} y {c} × {b} = {y}.',
            {'a': '$a', 'b': '$b', 'c': '$c', 'd': '$d', 'x': '${a * d}', 'y': '${c * b}'}),
        PasoEjemplo('El producto mayor va con la fracción mayor: {f}.', {'f': mayor}),
      ]);
    case 'FR.08':
      final fracciones = <(int, int)>[];
      final valores = <double>{};
      while (fracciones.length < 3) {
        final d = entre(2, 10);
        final n = entre(1, d - 1);
        if (!valores.add(n / d)) continue;
        fracciones.add((n, d));
      }
      String decimal(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
      final ordenadas = [...fracciones]..sort((x, y) => (x.$1 / x.$2).compareTo(y.$1 / y.$2));
      return EjemploResuelto(fracciones.map((f) => '${f.$1}/${f.$2}').join('   '), [
        for (final (n, d) in fracciones)
          PasoEjemplo('{f} ≈ {v}', {'f': '$n/$d', 'v': decimal(n / d)}),
        PasoEjemplo('De menor a mayor: {orden}.',
            {'orden': ordenadas.map((f) => '${f.$1}/${f.$2}').join(' < ')}),
      ]);
    case 'DEC.03':
      final b = entre(2, 9);
      var a = entre(11, 49);
      if (a == b * 10) a++; // que no sean el mismo número
      final corta = '0,$b';
      final larga = '0,${a.toString().padLeft(2, '0')}';
      final mayor = b * 10 > a ? corta : larga;
      return EjemploResuelto('¿$larga o $corta?', [
        PasoEjemplo('Iguala las cifras con ceros: {a} y {b}0.', {'a': larga, 'b': corta}),
        PasoEjemplo('Compara las décimas y luego las centésimas: {m} es la mayor.', {'m': mayor}),
      ]);
    case 'DIV.07':
      final pares = const [(4, 6), (6, 8), (4, 10), (6, 9), (8, 12), (6, 10), (9, 12)];
      final (a, b) = pares[azar.nextInt(pares.length)];
      final resultado = a ~/ _mcd(a, b) * b;
      String multiplos(int n) => [for (var k = 1; k * n <= resultado; k++) '${k * n}'].join(', ');
      return EjemploResuelto('mcm($a, $b)', [
        PasoEjemplo('Múltiplos de {a}: {lista}.', {'a': '$a', 'lista': multiplos(a)}),
        PasoEjemplo('Múltiplos de {a}: {lista}.', {'a': '$b', 'lista': multiplos(b)}),
        PasoEjemplo('El primero que está en las dos listas: {r}.', {'r': '$resultado'}),
      ]);
    case 'DIV.06':
      final pares = const [(12, 18), (8, 12), (18, 24), (20, 30), (16, 24), (15, 25)];
      final (a, b) = pares[azar.nextInt(pares.length)];
      String divisores(int n) => [for (var d = 1; d <= n; d++) if (n % d == 0) '$d'].join(', ');
      return EjemploResuelto('mcd($a, $b)', [
        PasoEjemplo('Divisores de {a}: {lista}.', {'a': '$a', 'lista': divisores(a)}),
        PasoEjemplo('Divisores de {a}: {lista}.', {'a': '$b', 'lista': divisores(b)}),
        PasoEjemplo('El mayor que está en las dos listas: {r}.', {'r': '${_mcd(a, b)}'}),
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
