import 'dart:math' as math;

/// El taller del relojero (segunda sala de Rexán): el taller de la
/// Industria recibe encargos de medida. Cada ronda, un banco:
///
/// - Regla (MED.01): cortar «1,35 m» con piezas de m, dm y cm.
/// - Báscula (MED.02): llegar a «1,75 kg» con pesas de kg y g.
/// - Probetas (MED.02): llenar «1,35 l» con vasos de l, ml y dl.
/// - Reloj (MED.03): «son las 10:40; ¿qué hora será dentro de 1 h 35
///   min?», con paso de hora y de medianoche.
///
/// Los Cambiados (el monstruo): piezas escritas en otra unidad (una pesa
/// de «0,5 kg» junto a una de «500 g»: son la misma). Hay que leerlas bien.
enum Banco { regla, bascula, probetas, reloj }

class Pieza {
  final String etiqueta;

  /// En la unidad base del banco: cm, g o ml.
  final int valor;

  const Pieza(this.etiqueta, this.valor);
}

class RetoTaller {
  final Banco banco;

  /// Lo que se pide, escrito (p. ej. «1,75 kg»), y su valor en la unidad
  /// base (1750 g). En el reloj: la hora de partida y cuánto se suma.
  final String objetivo;
  final int objetivoBase;
  final List<Pieza> piezas;

  /// Reloj: minutos desde las 00:00 de partida y minutos a sumar.
  final int inicio;
  final int suma;

  /// Reloj: la hora buena en minutos y cuatro opciones (en minutos, o
  /// negativas para las horas imposibles tipo «11:75», codificadas).
  final int respuesta;
  final List<String> opciones;
  final String? opcionBuena;

  const RetoTaller({
    required this.banco,
    this.objetivo = '',
    this.objetivoBase = 0,
    this.piezas = const [],
    this.inicio = 0,
    this.suma = 0,
    this.respuesta = 0,
    this.opciones = const [],
    this.opcionBuena,
  });

  String get idHabilidad => switch (banco) {
        Banco.regla => 'MED.01',
        Banco.bascula || Banco.probetas => 'MED.02',
        Banco.reloj => 'MED.03',
      };
}

String _decimal(int enteros, int resto, int cifras) {
  if (resto == 0) return '$enteros';
  var texto = resto.toString().padLeft(cifras, '0');
  while (texto.endsWith('0')) {
    texto = texto.substring(0, texto.length - 1);
  }
  return '$enteros,$texto';
}

/// Una cantidad en la unidad base escrita de forma mixta: 1750 g →
/// «1 kg 750 g»; 135 cm → «1 m 35 cm».
String enUnidadesMixtas(Banco banco, int base) {
  final (grande, pequena, factor) = switch (banco) {
    Banco.regla => ('m', 'cm', 100),
    Banco.bascula => ('kg', 'g', 1000),
    Banco.probetas => ('l', 'ml', 1000),
    Banco.reloj => ('h', 'min', 60),
  };
  final enteros = base ~/ factor;
  final resto = base % factor;
  if (enteros == 0) return '$resto $pequena';
  if (resto == 0) return '$enteros $grande';
  return '$enteros $grande $resto $pequena';
}

String horaDe(int minutos) {
  final m = minutos % (24 * 60);
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}

class GeneradorTaller {
  final math.Random _azar;

  GeneradorTaller({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoTaller generar(Banco banco, {int dificultad = 1}) {
    switch (banco) {
      case Banco.regla:
        final base = dificultad == 1 ? 10 * _entre(3, 25) : _entre(21, 290);
        final escrito = switch (_azar.nextInt(3)) {
          0 => '${_decimal(base ~/ 100, base % 100, 2)} m',
          1 => enUnidadesMixtas(Banco.regla, base),
          _ => '$base cm',
        };
        return RetoTaller(
          banco: banco,
          objetivo: escrito,
          objetivoBase: base,
          piezas: _conCambiados(dificultad, const [
            Pieza('1 m', 100),
            Pieza('5 dm', 50),
            Pieza('1 dm', 10),
            Pieza('5 cm', 5),
            Pieza('1 cm', 1),
          ], const {'5 dm': '50 cm', '1 dm': '10 cm', '1 m': '100 cm'}),
        );
      case Banco.bascula:
        final base = 50 * _entre(3, dificultad == 1 ? 40 : 70);
        return RetoTaller(
          banco: banco,
          objetivo: _escritoKiloLitro(base, 'kg', 'g'),
          objetivoBase: base,
          piezas: _conCambiados(dificultad, const [
            Pieza('1 kg', 1000),
            Pieza('500 g', 500),
            Pieza('250 g', 250),
            Pieza('100 g', 100),
            Pieza('50 g', 50),
          ], const {'500 g': '0,5 kg', '250 g': '0,25 kg', '100 g': '0,1 kg'}),
        );
      case Banco.probetas:
        final base = 50 * _entre(3, dificultad == 1 ? 40 : 60);
        return RetoTaller(
          banco: banco,
          objetivo: _escritoKiloLitro(base, 'l', 'ml'),
          objetivoBase: base,
          piezas: _conCambiados(dificultad, const [
            Pieza('1 l', 1000),
            Pieza('500 ml', 500),
            Pieza('250 ml', 250),
            Pieza('1 dl', 100),
            Pieza('50 ml', 50),
          ], const {'500 ml': '0,5 l', '1 dl': '100 ml', '250 ml': '0,25 l'}),
        );
      case Banco.reloj:
        final paso = dificultad == 1 ? 5 : 5;
        int inicio;
        int suma;
        while (true) {
          inicio = paso * _entre(0, 24 * 60 ~/ paso - 1);
          suma = paso * _entre(3, dificultad == 1 ? 24 : 40);
          final fin = inicio + suma;
          final cruzaHora = (inicio % 60) + (suma % 60) >= 60;
          final cruzaDia = fin >= 24 * 60;
          if (dificultad == 1 && (cruzaDia || !cruzaHora && _azar.nextBool())) continue;
          if (dificultad == 2 && (!cruzaHora || cruzaDia)) continue;
          if (dificultad >= 3 && !cruzaHora) continue;
          break;
        }
        final fin = inicio + suma;
        final buena = horaDe(fin);
        // Errores típicos: no pasar los minutos a horas (11:75), llevarse
        // de más, tratar 1 h 30 min como 1,30 h, olvidar las horas.
        final sinLlevar =
            '${((inicio ~/ 60 + suma ~/ 60) % 24).toString().padLeft(2, '0')}:${(inicio % 60 + suma % 60).toString().padLeft(2, '0')}';
        final opciones = <String>{
          buena,
          if (sinLlevar != buena) sinLlevar,
          horaDe(fin + 60),
          horaDe(fin - 60),
          horaDe(inicio + suma % 60),
        }.toList();
        var extra = 1;
        while (opciones.length < 4) {
          final otra = horaDe(fin + 10 * extra++);
          if (!opciones.contains(otra)) opciones.add(otra);
        }
        final elegidas = [buena, ...opciones.where((o) => o != buena).take(3)]..shuffle(_azar);
        return RetoTaller(
          banco: banco,
          inicio: inicio,
          suma: suma,
          respuesta: fin % (24 * 60),
          opciones: elegidas,
          opcionBuena: buena,
        );
    }
  }

  String _escritoKiloLitro(int base, String grande, String pequena) => switch (_azar.nextInt(3)) {
        0 => '${_decimal(base ~/ 1000, base % 1000, 3)} $grande',
        1 => base >= 1000
            ? enUnidadesMixtas(grande == 'kg' ? Banco.bascula : Banco.probetas, base)
            : '$base $pequena',
        _ => '$base $pequena',
      };

  /// Los Cambiados: desde dificultad 2, algunas piezas llevan la etiqueta
  /// en otra unidad (el mismo valor).
  List<Pieza> _conCambiados(int dificultad, List<Pieza> piezas, Map<String, String> otraEscritura) {
    if (dificultad < 2) return piezas;
    return [
      for (final pieza in piezas)
        otraEscritura.containsKey(pieza.etiqueta) && _azar.nextBool()
            ? Pieza(otraEscritura[pieza.etiqueta]!, pieza.valor)
            : pieza,
    ];
  }
}
