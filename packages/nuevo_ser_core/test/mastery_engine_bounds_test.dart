// Casos borde del dispatcher de MasteryEngine. Complementan
// `mastery_engine_test.dart` (subidas de nivel + paridad PHP) con tests
// específicos sobre la inyección de perfiles y la robustez del
// dispatcher ante mapas vacíos o ids inválidos.
//
// Motivación: la auditoría 2026-05-12 (riesgo R3) señaló que el
// constructor acepta `Map<String, MasteryProfile>?` con default no-vacío
// pero no había evidencia explícita de qué pasa si se inyecta `{}`.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

void main() {
  group('MasteryEngine — inyección de perfiles', () {
    test('perfiles inyectado como mapa vacío: cualquier id lanza ArgumentError', () {
      final motor = MasteryEngine(perfiles: const {});
      final inicial = EstadoHabilidad.inicial('FR.01');
      final payload = SessionPayload(
        acierto: true,
        dificultad: 1.0,
        duracionSegundos: 5,
        instante: DateTime(2026, 1, 1, 10),
      );

      expect(
        () => motor.actualizarMaestria(
          previo: inicial,
          payload: payload,
          // P1 no está en el mapa porque inyectamos {}.
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message.toString(),
            'mensaje',
            allOf(contains('P1'), contains('Perfil')),
          ),
        ),
        reason: 'Map vacío no debe colapsar silenciosamente al default',
      );
    });

    test('perfil custom registrado por id se invoca', () {
      final motor = MasteryEngine(perfiles: {
        'CUSTOM': const _PerfilDeCero(),
      });
      final inicial = EstadoHabilidad.inicial('FR.01');
      final payload = SessionPayload(
        acierto: true,
        dificultad: 1.0,
        duracionSegundos: 5,
        instante: DateTime(2026, 1, 1, 10),
      );

      final tras = motor.actualizarMaestria(
        previo: inicial,
        payload: payload,
        idPerfil: 'CUSTOM',
      );

      expect(tras.precision, 0.0,
          reason: '_PerfilDeCero siempre devuelve precision 0');
    });

    test('motor con default registra exactamente P1, P2, P3, P4', () {
      final motor = MasteryEngine();
      // P1 funciona.
      expect(() => motor.perfil('P1'), returnsNormally);
      // P2 funciona.
      expect(() => motor.perfil('P2'), returnsNormally);
      // P3 funciona.
      expect(() => motor.perfil('P3'), returnsNormally);
      // P4 funciona (calibración epistémica, AH.03).
      expect(() => motor.perfil('P4'), returnsNormally);
      // P5 no.
      expect(
        () => motor.perfil('P5'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('id de perfil null cae al default P1', () {
      final motor = MasteryEngine();
      final inicial = EstadoHabilidad.inicial('FR.01');
      final payload = SessionPayload(
        acierto: true,
        dificultad: 1.0,
        duracionSegundos: 5,
        instante: DateTime(2026, 1, 1, 10),
      );

      // No pasamos idPerfil → debe usar P1 sin lanzar.
      final tras = motor.actualizarMaestria(
        previo: inicial,
        payload: payload,
      );
      expect(tras.totalExposiciones, 1);
    });
  });
}

/// Perfil de prueba: siempre devuelve `precision: 0`. Sirve para
/// verificar que el dispatcher invoca al perfil correcto sin tocar la
/// lógica de los perfiles reales.
class _PerfilDeCero implements MasteryProfile {
  const _PerfilDeCero();

  @override
  String get id => 'CUSTOM';

  @override
  ScoreResult compute({
    required SessionPayload payload,
    required EstadoHabilidad previo,
    required ProfileConfig config,
  }) {
    return ScoreResult(
      precision: 0.0,
      tiempoMedianoSeg: payload.duracionSegundos.toDouble(),
      sesionesConsecutivasBuenas: 0,
      totalExposiciones: previo.totalExposiciones + 1,
      intentosRecientes: previo.intentosRecientes,
    );
  }

  @override
  NivelMaestria levelFromScore({
    required ScoreResult score,
    required ProfileConfig config,
    required NivelMaestria nivelPrevio,
  }) {
    return NivelMaestria.inexplorada;
  }
}
