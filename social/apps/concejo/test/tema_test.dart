import 'package:concejo/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brillo in Brightness.values) {
    test('el texto se lee sobre el fondo ($brillo)', () {
      final tema = temaConcejo(brillo);
      final estilos = tema.textTheme;
      for (final estilo in [
        estilos.titleMedium,
        estilos.bodyMedium,
        estilos.bodySmall,
        estilos.bodyLarge,
        estilos.titleLarge,
      ]) {
        expect(estilo!.color, isNotNull, reason: '$estilo');
        final contraste = (estilo.color!.computeLuminance() -
                tema.colorScheme.surface.computeLuminance())
            .abs();
        expect(contraste, greaterThan(0.4), reason: '$estilo');
      }
      // Y algo más grande de lo normal.
      expect(estilos.bodyMedium!.fontSize, closeTo(14 * 1.08, 0.01));
    });
  }
}
