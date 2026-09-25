import 'package:flutter/material.dart';

import '../../nucleo/paleta.dart';

/// Tarjeta-candidato genérica usada en los puzzles de elección entre
/// 4 valores numéricos. Replica el estilo del catálogo (borde violeta
/// base → azul al tocar → exitoSuave o rosaAcento al revelar).
/// Compartida por las pantallas de Era 3.
class TarjetaNumero extends StatelessWidget {
  final String valor;
  final bool seleccionado;
  final bool marcarCorrecto;
  final bool marcarIncorrecto;
  final bool marcarPista;
  final VoidCallback alTocar;

  const TarjetaNumero({
    super.key,
    required this.valor,
    required this.seleccionado,
    required this.marcarCorrecto,
    required this.marcarIncorrecto,
    required this.alTocar,
    this.marcarPista = false,
  });

  @override
  Widget build(BuildContext contexto) {
    final colorBorde = marcarCorrecto
        ? PaletaNeon.exitoSuave
        : marcarIncorrecto
            ? PaletaNeon.rosaAcento
            : seleccionado
                ? PaletaNeon.azulNeon
                : marcarPista
                    ? PaletaNeon.exitoSuave.withOpacity(0.6)
                    : PaletaNeon.violetaBase;
    final brilloIntenso = marcarCorrecto || marcarIncorrecto || seleccionado;
    return GestureDetector(
      onTap: alTocar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: PaletaNeon.fondoMedio.withOpacity(0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorBorde, width: 1.6),
          boxShadow: brilloIntenso
              ? [
                  BoxShadow(
                    color: colorBorde.withOpacity(0.4),
                    blurRadius: 18,
                  ),
                ]
              : marcarPista
                  ? [
                      BoxShadow(
                        color: PaletaNeon.exitoSuave.withOpacity(0.35),
                        blurRadius: 16,
                      ),
                    ]
                  : const [],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                style: TextStyle(
                  color: marcarCorrecto
                      ? PaletaNeon.exitoSuave
                      : marcarIncorrecto
                          ? PaletaNeon.rosaAcento
                          : PaletaNeon.textoPrincipal,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
