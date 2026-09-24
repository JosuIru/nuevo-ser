import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:las_versiones/vista/pintura/trazo_a_mano.dart';

void main() {
  const papel = Rect.fromLTWH(10, 20, 200, 120);

  test('misma semilla, mismo trazo', () {
    final a = trazoAMano(const [Offset(0, 0), Offset(100, 40)], semilla: 4);
    final b = trazoAMano(const [Offset(0, 0), Offset(100, 40)], semilla: 4);
    expect(a.getBounds(), b.getBounds());
  });

  test('el trazo acaba exactamente en el último punto', () {
    final trazo = trazoAMano(const [Offset(0, 0), Offset(100, 0)], amplitud: 3);
    final metrica = trazo.computeMetrics().single;
    final puntoFinal = metrica.getTangentForOffset(metrica.length)!.position;
    expect(puntoFinal.dx, closeTo(100, 1e-6));
    expect(puntoFinal.dy, closeTo(0, 1e-6));
  });

  test('el papel rasgado no se sale de su rectángulo', () {
    for (var semilla = 0; semilla < 30; semilla++) {
      final silueta = papelRasgado(papel,
          ladosRasgados: LadoPapel.values.toSet(), semilla: semilla);
      final limites = silueta.getBounds();
      expect(papel.inflate(1).contains(limites.topLeft), isTrue);
      expect(papel.inflate(1).contains(limites.bottomRight), isTrue);
    }
  });

  test('el rasgado entra hacia dentro, no hacia fuera', () {
    final silueta = papelRasgado(papel, ladosRasgados: {LadoPapel.abajo}, semilla: 2);
    expect(silueta.contains(papel.center), isTrue);
    expect(silueta.contains(Offset(papel.center.dx, papel.bottom + 3)), isFalse);
  });
}
