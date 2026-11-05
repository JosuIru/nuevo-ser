import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../branding.dart';

/// Euros enteros con separador de miles: «6.480 €».
String eurosRedondos(int centimos) =>
    '${NumberFormat.decimalPattern('es').format((centimos / 100).round())} €';

/// «+1.360 €» / «−640 €»: euros enteros con su signo.
String eurosConSigno(int centimos) {
  if ((centimos / 100).round() == 0) return '0 €';
  return '${centimos > 0 ? '+' : '−'}${eurosRedondos(centimos.abs())}';
}

/// Colores del reparto de gastos: la persona tester en salvia y Zunbeltz
/// en pino (en oscuro, la salvia apagada para que se distingan).
({Color tester, Color zunbeltz}) coloresReparto(BuildContext context) {
  final esquema = context.esquemaZunbeltz;
  final oscuro = esquema.brightness == Brightness.dark;
  return (
    tester:
        oscuro ? colorCuadroSalvia.withValues(alpha: 0.4) : colorCuadroSalvia,
    zunbeltz: oscuro ? esquema.primary : colorCuadroPino,
  );
}

/// Una casilla por mes del test; las pasadas, en pino.
class BarraMesesTest extends StatelessWidget {
  const BarraMesesTest(
      {super.key, required this.hechos, required this.totales});

  final int hechos;
  final int totales;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final hecho = esquema.brightness == Brightness.dark
        ? colorCuadroSalvia
        : colorCuadroPino;
    // Más de 36 casillas no se distinguen: una barra continua.
    if (totales > 36) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: hechos / totales,
          minHeight: 8,
          color: hecho,
          backgroundColor: esquema.surfaceContainerHighest,
        ),
      );
    }
    return Row(children: [
      for (var indice = 0; indice < totales; indice++) ...[
        if (indice > 0) const SizedBox(width: 3),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: indice < hechos ? hecho : esquema.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    ]);
  }
}

/// Barra partida en dos: lo que asume la persona tester y Zunbeltz.
class BarraRepartoGastos extends StatelessWidget {
  const BarraRepartoGastos(
      {super.key,
      required this.tester,
      required this.zunbeltz,
      this.alto = 12});

  final int tester;
  final int zunbeltz;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final colores = coloresReparto(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(alto / 2),
      child: SizedBox(
        height: alto,
        child: Row(children: [
          if (tester > 0)
            Expanded(flex: tester, child: Container(color: colores.tester)),
          if (tester > 0 && zunbeltz > 0) const SizedBox(width: 3),
          if (zunbeltz > 0)
            Expanded(flex: zunbeltz, child: Container(color: colores.zunbeltz)),
        ]),
      ),
    );
  }
}

/// Barra de lo gastado frente a lo previsto (esmeralda; roja si se pasa).
class BarraPrevisto extends StatelessWidget {
  const BarraPrevisto({super.key, required this.real, required this.previsto});

  final int real;
  final int previsto;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final pasado = previsto > 0 && real > previsto;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value:
            previsto <= 0 ? (real > 0 ? 1 : 0) : (real / previsto).clamp(0, 1),
        minHeight: 8,
        color:
            pasado ? context.coloresZunbeltz.bloqueada : colorCuadroEsmeralda,
        backgroundColor: esquema.surfaceContainerHighest,
      ),
    );
  }
}
