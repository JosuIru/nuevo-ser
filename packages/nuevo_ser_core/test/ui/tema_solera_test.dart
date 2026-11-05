import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Los colores de marca y crema de las seis apps Larrea.
const paletasLarrea = {
  'agro': PaletaSolera(primario: Color(0xFF558B2F), crema: Color(0xFFF5F1E8)),
  'viticultura':
      PaletaSolera(primario: Color(0xFF7D2A2A), crema: Color(0xFFF6F0E6)),
  'apicola': PaletaSolera(primario: Color(0xFFB8860B), crema: Color(0xFFFAF6E8)),
  'arbolado':
      PaletaSolera(primario: Color(0xFF2E7D32), crema: Color(0xFFF4F8F0)),
  'quesera': PaletaSolera(primario: Color(0xFFC8923B), crema: Color(0xFFFDF6E8)),
  'aceitera':
      PaletaSolera(primario: Color(0xFF5C6B3A), crema: Color(0xFFF5EFE2)),
};

void main() {
  for (final MapEntry(key: app, value: paleta) in paletasLarrea.entries) {
    for (final oscuro in [false, true]) {
      final modo = oscuro ? 'oscuro' : 'claro';
      test('$app ($modo): texto legible sobre primario, superficie y acento', () {
        final tema = temaSolera(paleta, oscuro: oscuro);
        final esquema = tema.colorScheme;
        final propios = tema.extension<ColoresSolera>()!;
        expect(contrasteEntre(esquema.onPrimary, esquema.primary),
            greaterThanOrEqualTo(4.5));
        expect(contrasteEntre(esquema.onSurface, esquema.surface),
            greaterThanOrEqualTo(7));
        expect(contrasteEntre(esquema.onSurfaceVariant, esquema.surfaceContainerHigh),
            greaterThanOrEqualTo(4.5));
        expect(contrasteEntre(propios.sobreAcento, propios.acento),
            greaterThanOrEqualTo(3));
        expect(contrasteEntre(propios.sobreCabecera, propios.cabecera),
            greaterThanOrEqualTo(4.5));
      });
    }
  }

  test('el color de marca es el primario si se lee bien; si no, uno más oscuro',
      () {
    final viticultura = esquemaSolera(paletasLarrea['viticultura']!);
    expect(viticultura.primary, const Color(0xFF7D2A2A));
    expect(viticultura.surface, const Color(0xFFF6F0E6));
    final quesera = esquemaSolera(paletasLarrea['quesera']!);
    expect(quesera.primary, isNot(const Color(0xFFC8923B)));
    expect(quesera.primary.computeLuminance(),
        lessThan(const Color(0xFFC8923B).computeLuminance()));
  });

  testWidgets('context.coloresSolera lee la extensión del tema', (tester) async {
    late ColoresSolera leidos;
    await tester.pumpWidget(MaterialApp(
      theme: temaSolera(paletasLarrea['agro']!),
      home: Builder(builder: (context) {
        leidos = context.coloresSolera;
        return const SizedBox();
      }),
    ));
    expect(leidos.cabecera, temaSolera(paletasLarrea['agro']!).colorScheme.primary);
  });
}
