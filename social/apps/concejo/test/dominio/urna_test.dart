import 'dart:math';

import 'package:concejo/dominio/urna.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime.utc(2026, 11, 10, 18, 42, 13);

  test('nadie vota dos veces, ni en la app ni en persona', () {
    final urna = const Urna(asuntoUid: 'a1').votarEnLaApp(
      personaUid: 'ane',
      opcionesMarcadas: {votoSi},
      ahora: ahora,
      secreta: true,
    );
    expect(
      () => urna.votarEnLaApp(
          personaUid: 'ane',
          opcionesMarcadas: {votoNo},
          ahora: ahora,
          secreta: true),
      throwsA(isA<VotoDuplicado>()),
    );
    expect(
      () => urna.anotarVotoPresencial(personaUid: 'ane', mesaUid: 'm1'),
      throwsA(isA<VotoDuplicado>()),
    );
  });

  group('voto secreto', () {
    test('la papeleta no lleva persona y la hora va redondeada', () {
      final urna = const Urna(asuntoUid: 'a1').votarEnLaApp(
        personaUid: 'ane',
        opcionesMarcadas: {votoSi},
        ahora: ahora,
        secreta: true,
      );
      final papeleta = urna.papeletas.single;
      expect(papeleta.personaUid, isNull);
      expect(papeleta.horaRedondeada, DateTime.utc(2026, 11, 10, 18));
    });

    test('el orden de las papeletas no delata el orden de participación', () {
      // Con 30 votos, que la papeleta i sea la de la persona i en todas las
      // posiciones sería casualidad imposible si se mezclan.
      var urna = const Urna(asuntoUid: 'a1');
      final azar = Random(42);
      for (var i = 0; i < 30; i++) {
        urna = urna.votarEnLaApp(
          personaUid: 'p$i',
          opcionesMarcadas: {'opcion$i'},
          ahora: ahora,
          secreta: true,
          azar: azar,
        );
      }
      final enSuSitio = [
        for (var i = 0; i < 30; i++)
          if (urna.papeletas[i].opcionesMarcadas.single == 'opcion$i') i,
      ];
      expect(enSuSitio.length, lessThan(10));
    });

    test('en voto nominal la papeleta sí lleva persona y va en orden', () {
      final urna = const Urna(asuntoUid: 'a1')
          .votarEnLaApp(
              personaUid: 'ane',
              opcionesMarcadas: {votoSi},
              ahora: ahora,
              secreta: false)
          .votarEnLaApp(
              personaUid: 'iker',
              opcionesMarcadas: {votoNo},
              ahora: ahora,
              secreta: false);
      expect(urna.papeletas.map((p) => p.personaUid), ['ane', 'iker']);
    });
  });

  group('voto en persona', () {
    test('el conteo de la mesa lo firman dos personas distintas', () {
      expect(
        () => const Urna(asuntoUid: 'a1').anadirConteoPresencial(
          const ConteoPresencial(
            asuntoUid: 'a1',
            papeletasTotales: 1,
            marcasPorOpcion: {votoSi: 1},
            firmadoPorUids: ['m1', 'm1'],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('avisa si las papeletas en papel no cuadran con las personas anotadas',
        () {
      final urna = const Urna(asuntoUid: 'a1')
          .anotarVotoPresencial(personaUid: 'abuela', mesaUid: 'm1')
          .anotarVotoPresencial(personaUid: 'vecino', mesaUid: 'm1')
          .anadirConteoPresencial(const ConteoPresencial(
            asuntoUid: 'a1',
            papeletasTotales: 3,
            marcasPorOpcion: {votoSi: 3},
            firmadoPorUids: ['m1', 'm2'],
          ));
      expect(urna.avisos(), [AvisoUrna.papeletasPresencialesNoCuadran]);
    });
  });
}
