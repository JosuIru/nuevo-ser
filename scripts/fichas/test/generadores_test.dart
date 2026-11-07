import 'dart:math' as math;

import 'package:fichas_imprimibles/fichas_imprimibles.dart';
import 'package:test/test.dart';

/// Ejecuta un generador con una semilla y devuelve sus ejercicios.
List<Ejercicio> _muestras(String id, {int semilla = 7, int cantidad = 40}) {
  final azar = math.Random(semilla);
  return List.generate(cantidad, (_) => plantillasPorHabilidad[id]!.generar(azar));
}

/// Dominios ya revisados (revisión pedagógica 2026-11-07): las reglas
/// comunes se exigen solo a estos mientras se aplica la revisión.
const _dominiosRevisados = {'FR', 'DEC', 'PROP', 'DIV', 'OP', 'MED', 'GEO'};

bool _revisada(String id) => _dominiosRevisados.contains(id.split('.').first);

/// Todo lo que se imprime de una plantilla con [cantidad] ejercicios.
List<String> _textosImpresos(PlantillaFicha plantilla, {int cantidad = 200}) => [
      plantilla.descripcion,
      plantilla.preguntaExplicalo,
      for (final ejercicio in _muestras(plantilla.idHabilidad, semilla: 11, cantidad: cantidad)) ...[
        ejercicio.enunciado,
        ejercicio.destacado ?? '',
        ...(ejercicio.tabla ?? const <List<String>>[]).expand((fila) => fila),
      ],
    ];

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

  group('reglas comunes de la revisión', () {
    for (final plantilla in plantillasPorHabilidad.values.where((p) => _revisada(p.idHabilidad))) {
      final id = plantilla.idHabilidad;
      test('$id: la explicación trae una línea «Ejemplo: …»', () {
        expect(plantilla.descripcion, contains('Ejemplo: '));
      });

      test('$id: × en Primaria y · en ESO', () {
        final curso = catalogo.porId(id)!.curso!;
        final prohibido = curso.endsWith('P') ? '·' : '×';
        for (final texto in _textosImpresos(plantilla)) {
          expect(texto, isNot(contains(prohibido)), reason: '$id ($curso): $texto');
        }
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

  group('soluciones recalculadas desde el enunciado', () {
    test('PROP.05: el porcentaje es exactamente parte/total', () {
      final patron = RegExp(r'^De (\d+) .*?, (\d+) .*¿Qué porcentaje es\?$');
      for (final ejercicio in _muestras('PROP.05', semilla: 3, cantidad: 3000)) {
        final datos = patron.firstMatch(ejercicio.enunciado)!;
        final total = int.parse(datos.group(1)!);
        final parte = int.parse(datos.group(2)!);
        final porcentaje = int.parse(ejercicio.solucion.split(' ').first);
        expect(parte * 100, porcentaje * total, reason: ejercicio.enunciado);
      }
    });

    test('GEO.09: los triángulos existen (desigualdad triangular estricta)', () {
      final numeros = RegExp(r'(\d+) cm');
      for (final ejercicio in _muestras('GEO.09', semilla: 3, cantidad: 3000)) {
        if (!ejercicio.enunciado.startsWith('Un triángulo')) continue;
        final lados = numeros
            .allMatches(ejercicio.enunciado)
            .map((m) => int.parse(m.group(1)!))
            .toList()
          ..sort();
        expect(lados[0] + lados[1], greaterThan(lados[2]), reason: ejercicio.enunciado);
        expect(ejercicio.enunciado, isNot(contains('veces más grande')));
      }
    });

    test('DEC.02: a veces gana el decimal con más cifras y a veces el de menos', () {
      var ganaElLargo = 0, ganaElCorto = 0;
      for (final ejercicio in _muestras('DEC.02', semilla: 3, cantidad: 3000)) {
        final numeros = ejercicio.destacado!.split('___').map((n) => n.trim()).toList();
        final valores = numeros.map((n) => double.parse(n.replaceAll(',', '.'))).toList();
        final signo = valores[0] < valores[1] ? '<' : (valores[0] > valores[1] ? '>' : '=');
        expect(ejercicio.solucion, signo, reason: ejercicio.destacado);
        final mayor = valores[0] > valores[1] ? numeros[0] : numeros[1];
        final menor = valores[0] > valores[1] ? numeros[1] : numeros[0];
        if (mayor.length > menor.length) ganaElLargo++;
        if (mayor.length < menor.length) ganaElCorto++;
      }
      expect(ganaElLargo, greaterThan(600), reason: 'el error típico no debe premiarse siempre');
      expect(ganaElCorto, greaterThan(600));
    });

    test('DEC.07: el cociente es correcto y nunca trivial (nada de «3 : 3»)', () {
      for (final ejercicio in _muestras('DEC.07', semilla: 3, cantidad: 3000)) {
        final partes = ejercicio.destacado!.replaceAll(' =', '').split(' : ');
        final dividendo = double.parse(partes[0].replaceAll(',', '.'));
        final divisor = double.parse(partes[1].replaceAll(',', '.'));
        final cociente = double.parse(ejercicio.solucion.replaceAll(',', '.'));
        expect((dividendo / divisor - cociente).abs(), lessThan(1e-9), reason: ejercicio.destacado);
        expect(cociente, isNot(1), reason: ejercicio.destacado);
      }
    });

    test('PROP.03: precios y velocidades verosímiles, y la regla de tres cuadra', () {
      // Lo que vale una unidad en cada contexto, dentro de lo que se ve en la vida.
      final rangos = {
        'kg de manzanas': (2, 4),
        'cuadernos': (2, 6),
        'horas': (12, 20),
        'personas': (80, 120),
      };
      final numeros = RegExp(r'\d+');
      for (final ejercicio in _muestras('PROP.03', semilla: 3, cantidad: 3000)) {
        final contexto = rangos.keys.where(ejercicio.enunciado.contains).single;
        final valores = numeros.allMatches(ejercicio.enunciado).map((m) => int.parse(m[0]!)).toList();
        // Orden en el texto: manzanas/cuadernos/personas, a b c; ciclista, b a c.
        final (a, b, c) = contexto == 'horas'
            ? (valores[1], valores[0], valores[2])
            : (valores[0], valores[1], valores[2]);
        final porUnidad = b ~/ a;
        expect(b % a, 0, reason: ejercicio.enunciado);
        expect(porUnidad, inInclusiveRange(rangos[contexto]!.$1, rangos[contexto]!.$2),
            reason: ejercicio.enunciado);
        expect(ejercicio.solucion, '${c * porUnidad}');
      }
    });

    test('PROP.06 y PROP.09: euros con dos decimales y bicis de precio creíble', () {
      final euros = RegExp(r'^\d+(,\d\d)? €$');
      for (final id in ['PROP.06', 'PROP.09']) {
        for (final ejercicio in _muestras(id, semilla: 3, cantidad: 3000)) {
          expect(euros.hasMatch(ejercicio.solucion), isTrue, reason: '$id: ${ejercicio.solucion}');
          final bici = RegExp(r'^Una bici cuesta (\d+) €').firstMatch(ejercicio.enunciado);
          if (bici != null) expect(int.parse(bici[1]!), greaterThanOrEqualTo(80));
        }
      }
    });

    test('OP.02: en 6.º, ningún resultado negativo', () {
      for (final ejercicio in _muestras('OP.02', semilla: 3, cantidad: 3000)) {
        expect(ejercicio.solucion, isNot(startsWith('−')), reason: ejercicio.destacado);
      }
    });

    test('OP.03: dos operaciones combinadas, sin negativos y nunca 0', () {
      final operaciones = RegExp(r' [+−·] ');
      for (final ejercicio in _muestras('OP.03', semilla: 3, cantidad: 3000)) {
        final expresion = ejercicio.destacado!.replaceAll(' =', '');
        expect(operaciones.allMatches(expresion).length, greaterThanOrEqualTo(2), reason: expresion);
        expect(ejercicio.solucion, isNot(startsWith('−')), reason: expresion);
        expect(ejercicio.solucion, isNot('0'), reason: expresion);
      }
    });

    test('GEO.01: también clasifica ángulos, y bien', () {
      var deAngulos = 0;
      final angulo = RegExp(r'^Un ángulo mide (\d+)°');
      for (final ejercicio in _muestras('GEO.01', semilla: 3, cantidad: 3000)) {
        final datos = angulo.firstMatch(ejercicio.enunciado);
        if (datos == null) continue;
        deAngulos++;
        final grados = int.parse(datos[1]!);
        expect(ejercicio.solucion, grados < 90 ? 'agudo' : (grados == 90 ? 'recto' : 'obtuso'));
      }
      expect(deAngulos, greaterThan(600));
    });

    test('GEO.03: un rectángulo nunca tiene el largo igual al ancho', () {
      final medidas = RegExp(r'rectangular mide (\d+) m de largo y (\d+) m de ancho');
      var rectangulos = 0;
      for (final ejercicio in _muestras('GEO.03', semilla: 3, cantidad: 3000)) {
        final datos = medidas.firstMatch(ejercicio.enunciado);
        if (datos == null) continue;
        rectangulos++;
        final largo = int.parse(datos[1]!), ancho = int.parse(datos[2]!);
        expect(largo, greaterThan(ancho), reason: ejercicio.enunciado);
        expect(ejercicio.solucion, '${largo * ancho} m²');
      }
      expect(rectangulos, greaterThan(1000));
    });

    test('MED.03: duraciones creíbles y hora de fin correcta', () {
      final datos = RegExp(r'a las (\d+):(\d\d) y dura (\d+) minutos');
      for (final ejercicio in _muestras('MED.03', semilla: 3, cantidad: 3000)) {
        final encontrado = datos.firstMatch(ejercicio.enunciado);
        if (encontrado == null) continue;
        final duracion = int.parse(encontrado[3]!);
        expect(duracion, greaterThanOrEqualTo(60), reason: ejercicio.enunciado);
        final fin = int.parse(encontrado[1]!) * 60 + int.parse(encontrado[2]!) + duracion;
        expect(ejercicio.solucion, '${fin ~/ 60}:${(fin % 60).toString().padLeft(2, '0')}');
      }
    });

    test('FR.01: la pregunta dice de qué se pide la fracción', () {
      for (final ejercicio in _muestras('FR.01', semilla: 3, cantidad: 3000)) {
        expect(ejercicio.enunciado, contains('¿Qué fracción de'), reason: ejercicio.enunciado);
        expect(ejercicio.enunciado, isNot(contains('caja de huevos')));
      }
    });

    test('FR.22: la pregunta nombra lo que se cuenta (nada de «¿Cuántos son?»)', () {
      for (final ejercicio in _muestras('FR.22', semilla: 3, cantidad: 3000)) {
        expect(ejercicio.enunciado, isNot(contains('son?')), reason: ejercicio.enunciado);
        final datos = RegExp(r'^De l[oa]s (\d+) .*?, (\d+)/(\d+) ').firstMatch(ejercicio.enunciado)!;
        final cantidad = int.parse(datos.group(1)!);
        final fraccion = Fraccion(int.parse(datos.group(2)!), int.parse(datos.group(3)!));
        expect(ejercicio.solucion, '${cantidad * fraccion.numerador ~/ fraccion.denominador}');
      }
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
