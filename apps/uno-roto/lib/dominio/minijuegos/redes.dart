import 'dart:math' as math;

/// Las redes (segunda sala de Rexán): los pescadores del Puerto necesitan
/// peces ámbar para las farolas. Cada red tiene su mezcla de peces.
///
/// Predecir y comprobar, sin apuestas ni premios:
/// 1. Mismo total de peces, distinto ámbar: ¿de qué red es más probable
///    sacar uno ámbar? (EST.05)
/// 2. Totales distintos: hay que comparar fracciones de verdad; a menudo
///    la red con más ámbar NO es la mejor (EST.05).
/// 3. La probabilidad escrita de tres maneras: fracción, decimal y
///    porcentaje (EST.06).
///
/// Después de elegir, la máquina echa la red veinte veces (con
/// devolución). Lo que cuenta es la decisión, no la tanda: si sale al
/// revés y la elección era buena, sigue siendo un acierto. El azar no
/// juzga la decisión.
enum TipoRetoRedes { elegirRed, notacion }

class Red {
  final int ambar;
  final int total;

  const Red(this.ambar, this.total);

  double get probabilidad => ambar / total;
}

class RetoRedes {
  final TipoRetoRedes tipo;
  final List<Red> redes;

  /// Elegir red: el índice de la mejor.
  final int? mejor;

  /// Notación: las opciones escritas y la buena.
  final List<String> opciones;
  final String? respuesta;

  const RetoRedes({
    required this.tipo,
    required this.redes,
    this.mejor,
    this.opciones = const [],
    this.respuesta,
  });

  String get idHabilidad => tipo == TipoRetoRedes.notacion ? 'EST.06' : 'EST.05';
}

int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);

/// La probabilidad a/t escrita como fracción simplificada, decimal o
/// porcentaje (t divide a 100: siempre exacta).
String comoFraccion(int a, int t) {
  final d = _mcd(a, t);
  return '${a ~/ d}/${t ~/ d}';
}

String comoPorcentaje(int a, int t) => '${a * 100 ~/ t} %';

String comoDecimal(int a, int t) {
  final centesimas = a * 100 ~/ t;
  final texto = '0,${centesimas.toString().padLeft(2, '0')}';
  return texto.endsWith('0') ? texto.substring(0, texto.length - 1) : texto;
}

class GeneradorRedes {
  final math.Random _azar;

  GeneradorRedes({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  RetoRedes generar(int nivel, {int dificultad = 1}) {
    final cuantasRedes = dificultad >= 3 ? 3 : 2;
    switch (nivel) {
      case 1:
        final total = _entre(5, dificultad == 1 ? 10 : 20);
        final ambares = <int>{};
        while (ambares.length < cuantasRedes) {
          ambares.add(_entre(1, total - 1));
        }
        final redes = [for (final a in ambares) Red(a, total)]..shuffle(_azar);
        return RetoRedes(tipo: TipoRetoRedes.elegirRed, redes: redes, mejor: _indiceMejor(redes));
      case 2:
        for (var intento = 0; intento < 500; intento++) {
          final redes = [
            for (var i = 0; i < cuantasRedes; i++) _redAlAzar(dificultad == 1 ? 12 : 20),
          ];
          final probabilidades = redes.map((r) => r.probabilidad).toList()..sort();
          // Que no empaten y que la diferencia se pueda ver con cuentas.
          var separadas = true;
          for (var i = 1; i < probabilidades.length; i++) {
            if (probabilidades[i] - probabilidades[i - 1] < 0.04) separadas = false;
          }
          if (!separadas || redes.map((r) => r.total).toSet().length < redes.length) continue;
          final mejor = _indiceMejor(redes);
          final masAmbar = _indiceMasAmbar(redes);
          // La trampa: casi siempre, la de más peces ámbar no es la mejor.
          if (masAmbar == mejor && _azar.nextDouble() < 0.9) continue;
          return RetoRedes(tipo: TipoRetoRedes.elegirRed, redes: redes, mejor: mejor);
        }
        return const RetoRedes(
            tipo: TipoRetoRedes.elegirRed, redes: [Red(3, 8), Red(5, 16)], mejor: 0);
      default:
        return _notacion(dificultad);
    }
  }

  Red _redAlAzar(int maximoTotal) {
    final total = _entre(4, maximoTotal);
    return Red(_entre(1, total - 1), total);
  }

  int _indiceMejor(List<Red> redes) {
    var mejor = 0;
    for (var i = 1; i < redes.length; i++) {
      if (redes[i].probabilidad > redes[mejor].probabilidad) mejor = i;
    }
    return mejor;
  }

  int _indiceMasAmbar(List<Red> redes) {
    var mas = 0;
    for (var i = 1; i < redes.length; i++) {
      if (redes[i].ambar > redes[mas].ambar) mas = i;
    }
    return mas;
  }

  RetoRedes _notacion(int dificultad) {
    // Totales que dividen a 100: decimal y porcentaje exactos.
    const totales = [4, 5, 10, 20, 25];
    for (var intento = 0; intento < 500; intento++) {
      final total = totales[_azar.nextInt(dificultad == 1 ? 3 : totales.length)];
      final ambar = _entre(1, total - 1);
      final escrituras = [comoFraccion, comoDecimal, comoPorcentaje];
      String escribir(int a, int t) => escrituras[_azar.nextInt(escrituras.length)](a, t);
      final buena = escribir(ambar, total);
      // Errores típicos: contar los que no son ámbar, ámbar contra el
      // resto (razón en vez de probabilidad) y "a peces = a %".
      final valores = <double>{ambar / total};
      final opciones = <String>[buena];
      void anadir(String texto, double valor) {
        if (valores.any((v) => (v - valor).abs() < 1e-9) || opciones.contains(texto)) return;
        valores.add(valor);
        opciones.add(texto);
      }

      anadir(escribir(total - ambar, total), (total - ambar) / total);
      if (total - ambar > ambar) anadir('$ambar/${total - ambar}', ambar / (total - ambar));
      anadir('$ambar %', ambar / 100);
      for (var extra = 0; opciones.length < 4 && extra < 20; extra++) {
        final otro = _entre(1, total - 1);
        anadir(escribir(otro, total), otro / total);
      }
      if (opciones.length < 4) continue;
      opciones.shuffle(_azar);
      return RetoRedes(
        tipo: TipoRetoRedes.notacion,
        redes: [Red(ambar, total)],
        opciones: opciones.take(4).toList(),
        respuesta: buena,
      );
    }
    return const RetoRedes(
      tipo: TipoRetoRedes.notacion,
      redes: [Red(1, 4)],
      opciones: ['25 %', '0,75', '1/3', '1 %'],
      respuesta: '25 %',
    );
  }
}

/// Veinte lances con devolución: true si sale ámbar.
List<bool> lanzar(Red red, int veces, math.Random azar) =>
    [for (var i = 0; i < veces; i++) azar.nextInt(red.total) < red.ambar];
