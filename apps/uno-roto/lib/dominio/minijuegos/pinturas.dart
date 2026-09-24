import 'dart:math' as math;

/// Pinturas (segunda sala de Rexán): los toldos del Mercado se han
/// desteñido. Cada puesto encarga su color con una receta («2 de azul por
/// cada 3 de amarillo») y hay que preparar lo que pide.
///
/// 1. Reconocer razones (PROP.01): ¿qué cubo tiene el mismo verde?
/// 2. Escalar la receta (PROP.02, PROP.03): 15 botes con 2:3, o «ya hay 6
///    de azul, ¿cuánto amarillo?». El color de la cubeta enseña la razón.
/// 3. La escala del plano del Mercado (PROP.07) y las rebajas (PROP.06).
///
/// Los Desteñidos (el monstruo): si el encargo se entrega mal, el toldo
/// se queda gris. Se puede repintar.
enum TipoPintura { reconocer, escalarTotal, escalarParte, escala, rebaja }

class Receta {
  final int azul;
  final int amarillo;

  const Receta(this.azul, this.amarillo);

  int get total => azul + amarillo;

  /// Mismo color: misma razón.
  bool mismoColor(int a, int b) => a * amarillo == b * azul;
}

class RetoPinturas {
  final TipoPintura tipo;
  final Receta receta;

  /// Reconocer: cubos (azul, amarillo) propuestos.
  final List<(int, int)> cubos;

  /// escalarTotal: botes en total. escalarParte: botes de azul que ya hay.
  /// escala: centímetros en el plano. rebaja: precio en euros.
  final int dato;

  /// escala: metros por centímetro. rebaja: porcentaje de descuento.
  final int dato2;

  /// Reconocer: índice del cubo bueno. El resto: el número pedido.
  final int respuesta;

  /// Escala y rebaja: cuatro opciones.
  final List<int> opciones;

  const RetoPinturas({
    required this.tipo,
    required this.receta,
    required this.respuesta,
    this.cubos = const [],
    this.dato = 0,
    this.dato2 = 0,
    this.opciones = const [],
  });

  String get idHabilidad => switch (tipo) {
        TipoPintura.reconocer => 'PROP.01',
        TipoPintura.escalarTotal => 'PROP.02',
        TipoPintura.escalarParte => 'PROP.03',
        TipoPintura.escala => 'PROP.07',
        TipoPintura.rebaja => 'PROP.06',
      };
}

int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);

class GeneradorPinturas {
  final math.Random _azar;

  GeneradorPinturas({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  Receta _receta() {
    while (true) {
      final azul = _entre(1, 4);
      final amarillo = _entre(2, 5);
      if (azul != amarillo && _mcd(azul, amarillo) == 1) return Receta(azul, amarillo);
    }
  }

  RetoPinturas generar(TipoPintura tipo, {int dificultad = 1}) {
    final receta = _receta();
    final maximoFactor = switch (dificultad) { 1 => 3, 2 => 5, _ => 7 };
    switch (tipo) {
      case TipoPintura.reconocer:
        final factor = _entre(2, maximoFactor);
        final buena = (receta.azul * factor, receta.amarillo * factor);
        // Errores típicos: sumar lo mismo a los dos (2:3 → 4:5), darle la
        // vuelta (3:2) y otra casi igual.
        final malas = <(int, int)>{
          (receta.azul + factor, receta.amarillo + factor),
          (receta.amarillo * factor, receta.azul * factor),
          (receta.azul * factor, receta.amarillo * factor + 1),
          (receta.azul * factor + 1, receta.amarillo * factor),
        }..removeWhere((c) => receta.mismoColor(c.$1, c.$2));
        final cubos = [buena, ...malas.take(3)]..shuffle(_azar);
        return RetoPinturas(
          tipo: tipo,
          receta: receta,
          cubos: cubos,
          respuesta: cubos.indexOf(buena),
        );
      case TipoPintura.escalarTotal:
        final factor = _entre(2, maximoFactor);
        return RetoPinturas(
          tipo: tipo,
          receta: receta,
          dato: receta.total * factor,
          respuesta: receta.azul * factor,
        );
      case TipoPintura.escalarParte:
        final factor = _entre(2, maximoFactor);
        return RetoPinturas(
          tipo: tipo,
          receta: receta,
          dato: receta.azul * factor,
          respuesta: receta.amarillo * factor,
        );
      case TipoPintura.escala:
        final metrosPorCm = const [2, 5, 10, 20, 50][_azar.nextInt(dificultad == 1 ? 3 : 5)];
        final cm = _entre(3, 12);
        final metros = cm * metrosPorCm;
        return RetoPinturas(
          tipo: tipo,
          receta: receta,
          dato: cm,
          dato2: metrosPorCm,
          respuesta: metros,
          opciones: _opciones(metros, [cm + metrosPorCm, metros * 10, metros ~/ 10, metrosPorCm]),
        );
      case TipoPintura.rebaja:
        final porcentaje = const [10, 20, 25, 50][_azar.nextInt(dificultad == 1 ? 2 : 4)];
        final paso = 100 ~/ _mcd(porcentaje, 100);
        final precio = paso * _entre(2, 60 ~/ paso + 1);
        final descuento = precio * porcentaje ~/ 100;
        final final_ = precio - descuento;
        return RetoPinturas(
          tipo: tipo,
          receta: receta,
          dato: precio,
          dato2: porcentaje,
          respuesta: final_,
          // Quedarse con el descuento, sumarlo, restar el número del %.
          opciones: _opciones(final_, [descuento, precio + descuento, precio - porcentaje, final_ + 1]),
        );
    }
  }

  List<int> _opciones(int respuesta, List<int> errores) {
    final elegidas = <int>{respuesta};
    for (final error in errores) {
      if (elegidas.length == 4) break;
      if (error > 0) elegidas.add(error);
    }
    var desfase = 2;
    while (elegidas.length < 4) {
      final vecino = respuesta + (desfase.isEven ? desfase : -desfase);
      if (vecino > 0) elegidas.add(vecino);
      desfase++;
    }
    return elegidas.toList()..shuffle(_azar);
  }
}
