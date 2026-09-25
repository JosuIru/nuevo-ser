import 'dart:math' as math;

import 'nivel_escolar.dart';

/// La prueba de nivel con Sora: unas diez preguntas para saber por dónde
/// empezar. No se enseñan puntos ni aciertos: al final sólo «empiezas
/// por aquí».
///
/// Una escalera por cursos: empieza en 5.º de Primaria; en cada curso se
/// hacen dos preguntas (y una tercera si falla una). Dos aciertos, sube;
/// si falla el primero, baja uno. El resultado es el curso por el que va:
/// el siguiente al último que supera (lo superado se da por sabido).

class PreguntaNivel {
  final NivelEscolar curso;

  /// Enunciado en castellano con `{a}`, `{b}`… (se traduce y luego se
  /// rellenan los datos).
  final String enunciado;
  final Map<String, String> datos;
  final String respuesta;
  final List<String> opciones;

  const PreguntaNivel({
    required this.curso,
    required this.enunciado,
    this.datos = const {},
    required this.respuesta,
    required this.opciones,
  });
}

/// Cómo va la prueba: qué curso se está probando, lo respondido y el
/// resultado cuando termina.
class PruebaNivel {
  final GeneradorPreguntasNivel _generador;

  /// El curso que se está probando.
  NivelEscolar cursoActual;

  /// El último curso superado (null: ninguno todavía).
  NivelEscolar? superado;

  int _aciertosEnCurso = 0;
  int _preguntasEnCurso = 0;
  int preguntasHechas = 0;
  bool terminada = false;
  late PreguntaNivel preguntaActual;

  static const maximoPreguntas = 12;

  PruebaNivel({math.Random? azar, NivelEscolar empezarEn = NivelEscolar.quintoPrimaria})
      : _generador = GeneradorPreguntasNivel(azar: azar),
        cursoActual = empezarEn {
    preguntaActual = _generador.pregunta(cursoActual);
  }

  /// Cursos que ya ha fallado: no se vuelven a probar.
  final Set<NivelEscolar> _fallados = {};

  /// El punto de partida que sale de la prueba (cuando está terminada):
  /// el curso por el que va, o sea, el siguiente al último que supera
  /// (lo superado se da por sabido). Si supera 2.º de ESO, 2.º de ESO.
  /// Si no supera ninguno, 4.º de Primaria.
  NivelEscolar get resultado {
    final ultimo = superado;
    if (ultimo == null) return NivelEscolar.values.first;
    return NivelEscolar.values[math.min(ultimo.index + 1, NivelEscolar.values.length - 1)];
  }

  /// Responde la pregunta actual. Devuelve si acertó (para el gesto de
  /// Sora; no se enseñan cuentas).
  bool responder(String opcion) {
    if (terminada) return false;
    final acierta = opcion == preguntaActual.respuesta;
    preguntasHechas++;
    _preguntasEnCurso++;
    if (acierta) _aciertosEnCurso++;
    final fallos = _preguntasEnCurso - _aciertosEnCurso;
    if (_aciertosEnCurso >= 2) {
      // Superado: sube (o termina si era el último).
      superado = cursoActual;
      final siguiente = cursoActual == NivelEscolar.values.last ? null : NivelEscolar.values[cursoActual.index + 1];
      if (siguiente == null || _fallados.contains(siguiente)) {
        terminada = true;
      } else {
        cursoActual = NivelEscolar.values[cursoActual.index + 1];
        _reiniciarCurso();
      }
    } else if (fallos >= 2) {
      _fallados.add(cursoActual);
      // No superado. Si nunca se superó ninguno y se puede bajar, baja
      // un curso; si no, termina aquí.
      if (superado == null && cursoActual.index > 0) {
        cursoActual = NivelEscolar.values[cursoActual.index - 1];
        _reiniciarCurso();
        // Si baja a uno que ya estaba por debajo de todo lo probado y
        // también lo falla, terminará en la siguiente vuelta.
      } else {
        terminada = true;
      }
    }
    if (preguntasHechas >= maximoPreguntas) terminada = true;
    if (!terminada) preguntaActual = _generador.pregunta(cursoActual);
    return acierta;
  }

  void _reiniciarCurso() {
    _aciertosEnCurso = 0;
    _preguntasEnCurso = 0;
  }
}

/// Preguntas de cada curso, con datos al azar y los errores típicos como
/// opciones. Tres modelos por curso.
class GeneradorPreguntasNivel {
  final math.Random _azar;

  GeneradorPreguntasNivel({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  PreguntaNivel pregunta(NivelEscolar curso) {
    final modelo = _azar.nextInt(3);
    return switch (curso) {
      NivelEscolar.cuartoPrimaria => _cuarto(modelo),
      NivelEscolar.quintoPrimaria => _quinto(modelo),
      NivelEscolar.sextoPrimaria => _sexto(modelo),
      NivelEscolar.primeroEso => _primeroEso(modelo),
      NivelEscolar.segundoEso => _segundoEso(modelo),
    };
  }

  String _decimal(int decimas) => decimas % 10 == 0 ? '${decimas ~/ 10}' : '${decimas ~/ 10},${decimas % 10}';

  PreguntaNivel _crear(NivelEscolar curso, String enunciado, Map<String, String> datos, String respuesta,
      List<String> errores) {
    final opciones = <String>{respuesta};
    for (final error in errores) {
      if (opciones.length == 4) break;
      opciones.add(error);
    }
    var extra = 1;
    while (opciones.length < 4) {
      final numero = int.tryParse(respuesta);
      opciones.add(numero != null ? '${numero + extra * 2}' : '$respuesta ($extra)');
      extra++;
    }
    return PreguntaNivel(
      curso: curso,
      enunciado: enunciado,
      datos: datos,
      respuesta: respuesta,
      opciones: opciones.toList()..shuffle(_azar),
    );
  }

  PreguntaNivel _cuarto(int modelo) {
    const curso = NivelEscolar.cuartoPrimaria;
    switch (modelo) {
      case 0:
        // Comparar fracciones unitarias: el error es elegir el denominador mayor.
        final a = _entre(2, 5);
        final b = a + _entre(2, 4);
        return _crear(curso, '¿Qué fracción es mayor?', const {}, '1/$a', ['1/$b', '$a/$b', 'Son iguales']);
      case 1:
        final a = _entre(12, 48);
        final b = _entre(11, 39);
        return _crear(curso, '¿Cuánto es {a} + {b}?', {'a': _decimal(a), 'b': _decimal(b)}, _decimal(a + b),
            [_decimal(a + b + 10), _decimal(a + b - 1), '${a + b}']);
      default:
        final horas = _entre(1, 3);
        return _crear(curso, '¿Cuántos minutos hay en {h} horas y cuarto?', {'h': '$horas'}, '${horas * 60 + 15}',
            ['${horas * 100 + 15}', '${horas * 60 + 25}', '${horas * 60 + 4}']);
    }
  }

  PreguntaNivel _quinto(int modelo) {
    const curso = NivelEscolar.quintoPrimaria;
    switch (modelo) {
      case 0:
        final k = _entre(2, 4);
        final n = [1, 3][_azar.nextInt(2)];
        final d = 4;
        return _crear(curso, 'Simplifica {f}.', {'f': '${n * k}/${d * k}'}, '$n/$d',
            ['${n * k}/$d', '$n/${d * k}', '${n * k - 1}/${d * k - 1}']);
      case 1:
        final a = _entre(12, 48);
        final k = _entre(2, 5);
        return _crear(curso, '¿Cuánto es {a} × {k}?', {'a': _decimal(a), 'k': '$k'}, _decimal(a * k),
            ['${a * k}', _decimal(a * k + 10), _decimal(a + k * 10)]);
      default:
        final total = 20 * _entre(2, 9);
        return _crear(curso, '¿Cuánto es el 25 % de {t}?', {'t': '$total'}, '${total ~/ 4}',
            ['${total - 25}', '${total ~/ 2}', '25']);
    }
  }

  PreguntaNivel _sexto(int modelo) {
    const curso = NivelEscolar.sextoPrimaria;
    switch (modelo) {
      case 0:
        // 1/a + 1/b: el error es sumar arriba y abajo.
        const pares = [[2, 3], [3, 4], [2, 5], [4, 6], [3, 5]];
        final [a, b] = pares[_azar.nextInt(pares.length)];
        var numerador = b + a;
        var denominador = a * b;
        final comun = _mcd(numerador, denominador);
        numerador ~/= comun;
        denominador ~/= comun;
        return _crear(curso, '¿Cuánto es {a} + {b}?', {'a': '1/$a', 'b': '1/$b'}, '$numerador/$denominador',
            ['2/${a + b}', '1/${a * b}', '2/${a * b}']);
      case 1:
        const pares = [[4, 6], [6, 8], [6, 9], [8, 12], [10, 15]];
        final [a, b] = pares[_azar.nextInt(pares.length)];
        final mcm = a * b ~/ _mcd(a, b);
        return _crear(curso, '¿Cuál es el mínimo común múltiplo de {a} y {b}?', {'a': '$a', 'b': '$b'}, '$mcm',
            ['${a * b}', '${_mcd(a, b)}', '${a + b}']);
      default:
        final base = _entre(2, 5);
        return _crear(curso, '¿Cuánto es {b} al cubo?', {'b': '$base'}, '${base * base * base}',
            ['${base * 3}', '${base * base}', '${base + 3}']);
    }
  }

  PreguntaNivel _primeroEso(int modelo) {
    const curso = NivelEscolar.primeroEso;
    switch (modelo) {
      case 0:
        final a = _entre(3, 9);
        final b = a + _entre(2, 8);
        return _crear(curso, '¿Cuánto es −{a} + {b} − {c}?', {'a': '$a', 'b': '$b', 'c': '${b + 1}'},
            _conSigno(-a - 1), [_conSigno(a + 1), _conSigno(-a + 2 * b + 1), _conSigno(a - 2 * b - 1)]);
      case 1:
        final x = _entre(2, 9);
        final a = _entre(2, 5);
        final b = _entre(1, 9);
        return _crear(curso, 'Si {a}x + {b} = {c}, ¿cuánto vale x?', {'a': '$a', 'b': '$b', 'c': '${a * x + b}'},
            '$x', ['${a * x + b - a}', '${x + 1}', '${(a * x + b + b) ~/ a}']);
      default:
        final lado = _entre(6, 15);
        return _crear(curso, '¿Cuál es la raíz cuadrada de {n}?', {'n': '${lado * lado}'}, '$lado',
            ['${lado * lado ~/ 2}', '${lado + 1}', '${lado - 1}']);
    }
  }

  PreguntaNivel _segundoEso(int modelo) {
    const curso = NivelEscolar.segundoEso;
    switch (modelo) {
      case 0:
        const ternas = [[6, 8, 10], [5, 12, 13], [9, 12, 15], [8, 15, 17]];
        final [a, b, c] = ternas[_azar.nextInt(ternas.length)];
        return _crear(curso, 'Un triángulo rectángulo tiene catetos de {a} y {b} cm. ¿Cuánto mide la hipotenusa?',
            {'a': '$a', 'b': '$b'}, '$c', ['${a + b}', '${c + 1}', '${(a + b) ~/ 2 + 2}']);
      case 1:
        final x = _entre(3, 9);
        final y = _entre(1, x - 1);
        return _crear(curso, 'Si x + y = {s} y x − y = {d}, ¿cuánto vale x?', {'s': '${x + y}', 'd': '${x - y}'},
            '$x', ['$y', '${x + y}', '${x - y}']);
      default:
        final m = _entre(2, 5);
        final n = _entre(1, 6);
        final x = _entre(2, 6);
        return _crear(curso, 'Si y = {m}x − {n}, ¿cuánto vale y cuando x = {x}?',
            {'m': '$m', 'n': '$n', 'x': '$x'}, '${m * x - n}', ['${m * x + n}', '${m * (x - n)}', '${m + x - n}']);
    }
  }

  static String _conSigno(int valor) => valor < 0 ? '−${-valor}' : '$valor';

  static int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);
}
