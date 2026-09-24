import 'dart:math' as math;

/// La hornada (segunda sala de Rexán): el horno de los Tejados saca
/// bandejas de panes redondos cortados en trozos iguales. Los pedidos
/// llegan escritos de cualquier manera y hay que empaquetar justo lo que
/// piden, tocando los trozos.
///
/// 1. Fracción como parte de un todo (FR.01) y leerla (FR.02): «3/4 de
///    pan» con la bandeja cortada en cuartos.
/// 2. Impropias y mixtos (FR.12, FR.13): «11/4» son 2 panes y 3 cuartos;
///    «2 y 3/4» son 11 cuartos. Los Impropios (del bestiario) parecen más
///    pequeños de lo que son.
/// 3. Bandeja y pedido en trozos distintos: amplificar (FR.11: 3/4 con
///    la bandeja en octavos) o simplificar (FR.10: 6/8 con la bandeja en
///    cuartos).
enum TipoPedido { parte, leer, impropia, mixto, amplificar, simplificar }

class PedidoHornada {
  final TipoPedido tipo;

  /// En cuántos trozos está cortado cada pan de la bandeja.
  final int cortes;

  /// Panes en la bandeja.
  final int panes;

  /// Lo pedido, escrito (p. ej. «11/4», «2 y 3/4», «6/8»).
  final String escrito;

  /// Trozos de la bandeja que hay que empaquetar.
  final int trozos;

  /// Leer: cuatro escrituras y la buena (la caja ya viene llena).
  final List<String> opciones;

  const PedidoHornada({
    required this.tipo,
    required this.cortes,
    required this.panes,
    required this.escrito,
    required this.trozos,
    this.opciones = const [],
  });

  String get idHabilidad => switch (tipo) {
        TipoPedido.parte => 'FR.01',
        TipoPedido.leer => 'FR.02',
        TipoPedido.impropia => 'FR.12',
        TipoPedido.mixto => 'FR.13',
        TipoPedido.amplificar => 'FR.11',
        TipoPedido.simplificar => 'FR.10',
      };
}

int _mcd(int a, int b) => b == 0 ? a : _mcd(b, a % b);

class GeneradorHornada {
  final math.Random _azar;

  GeneradorHornada({math.Random? azar}) : _azar = azar ?? math.Random();

  int _entre(int minimo, int maximo) => minimo + _azar.nextInt(maximo - minimo + 1);

  PedidoHornada generar(TipoPedido tipo, {int dificultad = 1}) {
    final cortesPosibles = dificultad == 1 ? const [2, 3, 4] : const [3, 4, 5, 6, 8];
    switch (tipo) {
      case TipoPedido.parte:
        final d = cortesPosibles[_azar.nextInt(cortesPosibles.length)];
        final n = _entre(1, d - 1);
        return PedidoHornada(tipo: tipo, cortes: d, panes: 1, escrito: '$n/$d', trozos: n);
      case TipoPedido.leer:
        final d = cortesPosibles[_azar.nextInt(cortesPosibles.length)];
        final n = _entre(1, d - 1);
        // Errores: contar los que quedan, darle la vuelta, "n de más".
        final opciones = <String>{'$n/$d', '${d - n}/$d', '$d/$n', '$n/${d + n}'};
        for (var extra = d + 1; opciones.length < 4; extra++) {
          opciones.add('$n/$extra');
        }
        return PedidoHornada(
          tipo: tipo,
          cortes: d,
          panes: 1,
          escrito: '$n/$d',
          trozos: n,
          opciones: opciones.take(4).toList()..shuffle(_azar),
        );
      case TipoPedido.impropia || TipoPedido.mixto:
        final d = cortesPosibles[_azar.nextInt(cortesPosibles.length)];
        final enteros = _entre(1, 2);
        final resto = _entre(1, d - 1);
        final trozos = enteros * d + resto;
        return PedidoHornada(
          tipo: tipo,
          cortes: d,
          panes: enteros + 1,
          escrito: tipo == TipoPedido.impropia ? '$trozos/$d' : '$enteros y $resto/$d',
          trozos: trozos,
        );
      case TipoPedido.amplificar:
        // Pedido en su forma corta, bandeja en trozos más pequeños.
        final d = const [2, 3, 4][_azar.nextInt(3)];
        final factor = d == 4 ? 2 : _entre(2, 3);
        var n = _entre(1, d - 1);
        while (_mcd(n, d) != 1) {
          n = _entre(1, d - 1);
        }
        return PedidoHornada(tipo: tipo, cortes: d * factor, panes: 1, escrito: '$n/$d', trozos: n * factor);
      case TipoPedido.simplificar:
        // Pedido "largo", bandeja en trozos grandes.
        final d = const [2, 3, 4][_azar.nextInt(3)];
        final factor = _entre(2, 3);
        var n = _entre(1, d - 1);
        while (_mcd(n, d) != 1) {
          n = _entre(1, d - 1);
        }
        return PedidoHornada(
            tipo: tipo, cortes: d, panes: 1, escrito: '${n * factor}/${d * factor}', trozos: n);
    }
  }
}
