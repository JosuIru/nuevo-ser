import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_core/src/calibration/nivel_confianza.dart';

IntentoHabilidad _afirmacion(NivelConfianza declarada, NivelConfianza real,
        {double dificultad = 1.0}) =>
    IntentoHabilidad(
      instante: DateTime.utc(2026, 9, 24),
      acierto: declarada == real,
      dificultad: dificultad,
      duracionSegundos: 5,
      confianzaDeclarada: declarada.valorFiabilidad,
      fiabilidadReal: real.valorFiabilidad,
    );

void main() {
  const solido = NivelConfianza.solido;
  const probable = NivelConfianza.probable;
  const disputado = NivelConfianza.disputado;

  group('calibración (doc 02 de Las Versiones §4.1)', () {
    test('todo en su nivel: calibración 1', () {
      expect(
          P4Calibration.calibracionDe([
            _afirmacion(solido, solido),
            _afirmacion(probable, probable),
            _afirmacion(disputado, disputado),
          ]),
          1.0);
    });

    test('sin sobreconfianza es exactamente el Brier invertido del doc', () {
      // Timidez: Probable donde era Sólido (error 0.25) + un acierto.
      expect(
          P4Calibration.calibracionDe([
            _afirmacion(probable, solido),
            _afirmacion(solido, solido),
          ]),
          closeTo(1 - 0.25 / 2, 1e-12));
    });

    test('la sobreconfianza pesa el doble que la subconfianza', () {
      final sobreconfiada = P4Calibration.calibracionDe([
        _afirmacion(solido, disputado),
        _afirmacion(solido, solido),
        _afirmacion(probable, probable),
      ]);
      final subconfiada = P4Calibration.calibracionDe([
        _afirmacion(disputado, solido),
        _afirmacion(solido, solido),
        _afirmacion(probable, probable),
      ]);
      // Ejemplo de la ficha de AH.03 (liberto Marco Tulio): sin
      // penalización daría 2/3; con ella, 1 − 2/4.
      expect(sobreconfiada, closeTo(0.5, 1e-12));
      expect(subconfiada, closeTo(1 - 1 / 3, 1e-12));
      expect(sobreconfiada, lessThan(subconfiada));
    });

    test('la dificultad pondera', () {
      expect(
          P4Calibration.calibracionDe([
            _afirmacion(disputado, solido, dificultad: 2.0),
            _afirmacion(solido, solido),
          ]),
          closeTo(1 - 2 / 3, 1e-12));
    });

    test('siempre en [0, 1]', () {
      expect(
          P4Calibration.calibracionDe([_afirmacion(solido, disputado, dificultad: 2.0)]),
          0.0);
    });
  });

  group('niveles con defaultP4', () {
    final motor = MasteryEngine();

    EstadoHabilidad jugar(List<(NivelConfianza, NivelConfianza)> afirmaciones,
        {required DateTime desde, EstadoHabilidad? previo, Duration entre = Duration.zero}) {
      var estado = previo ?? EstadoHabilidad.inicial('AH.03');
      var instante = desde;
      for (final (declarada, real) in afirmaciones) {
        estado = motor.actualizarMaestria(
          previo: estado,
          idPerfil: idPerfilP4,
          config: ProfileConfig.defaultP4,
          payload: SessionPayload(
            acierto: declarada == real,
            dificultad: 1.0,
            duracionSegundos: 6,
            instante: instante,
            confianzaDeclarada: declarada.valorFiabilidad,
            fiabilidadReal: real.valorFiabilidad,
          ),
        );
        instante = instante.add(entre);
      }
      return estado;
    }

    test('calibración baja (< 0.55) se queda en introducida', () {
      final estado = jugar([(solido, disputado), (solido, disputado)],
          desde: DateTime.utc(2026, 9, 1, 10));
      expect(estado.precision, 0.0);
      expect(estado.nivel, NivelMaestria.introducida);
    });

    test('bien calibrada en una sesión: en desarrollo (competente pide 3 sesiones)', () {
      final estado = jugar([(solido, solido), (probable, probable), (disputado, disputado)],
          desde: DateTime.utc(2026, 9, 1, 10));
      expect(estado.precision, 1.0);
      expect(estado.nivel, NivelMaestria.enDesarrollo);
    });

    test('tres sesiones buenas: competente; maestría exige 30 afirmaciones', () {
      EstadoHabilidad? estado;
      for (var sesion = 0; sesion < 3; sesion++) {
        estado = jugar([(solido, solido), (probable, probable)],
            desde: DateTime.utc(2026, 9, 1 + sesion, 10), previo: estado);
      }
      expect(estado!.sesionesConsecutivasBuenas, 3);
      expect(estado.nivel, NivelMaestria.competente);
      expect(estado.totalExposiciones, lessThan(30));
    });

    test('el JSON conserva cd y fr', () {
      final estado = jugar([(probable, solido)], desde: DateTime.utc(2026, 9, 1, 10));
      final json = estado.intentosRecientes.single.aJson();
      expect(json['cd'], 0.5);
      expect(json['fr'], 1.0);
      final vuelta = IntentoHabilidad.desdeJson(json);
      expect(vuelta.confianzaDeclarada, 0.5);
      expect(vuelta.fiabilidadReal, 1.0);
    });
  });
}
