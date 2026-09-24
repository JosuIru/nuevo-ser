import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Fija el comportamiento del motor adaptativo con perfil P1 sobre
/// secuencias conocidas. Hace contrato — cualquier cambio aquí debe
/// reflejarse también en el espejo PHP (C8) o se considera regresión.
void main() {
  late MasteryEngine motor;

  setUp(() {
    motor = MasteryEngine();
  });

  EstadoHabilidad aplicar(EstadoHabilidad previo, SessionPayload p) {
    return motor.actualizarMaestria(previo: previo, payload: p);
  }

  SessionPayload acierto(DateTime instante, {double dificultad = 1.0, int dur = 5}) =>
      SessionPayload(
        acierto: true,
        dificultad: dificultad,
        duracionSegundos: dur,
        instante: instante,
      );

  SessionPayload fallo(DateTime instante, {double dificultad = 1.0, int dur = 5}) =>
      SessionPayload(
        acierto: false,
        dificultad: dificultad,
        duracionSegundos: dur,
        instante: instante,
      );

  test('estado inicial pasa a introducida tras un único intento de baja precisión', () {
    final inicial = EstadoHabilidad.inicial('FR.01');
    final t0 = DateTime(2026, 1, 1, 10);
    final tras = aplicar(inicial, fallo(t0));
    expect(tras.totalExposiciones, 1);
    expect(tras.precision, 0);
    // 1 fallo aislado con precisión 0 < 0.5 → introducida (no enDesarrollo).
    expect(tras.nivel, NivelMaestria.introducida);
  });

  test('precisión ponderada combina dificultades correctamente', () {
    final inicial = EstadoHabilidad.inicial('FR.01');
    final t0 = DateTime(2026, 1, 1, 10);
    // Dos intentos: acierto dif 2.0 (peso 2), fallo dif 1.0 (peso 1).
    // numerador = 1*2 + 0*1 = 2; denominador = 2 + 1 = 3 → 2/3 ≈ 0.6667.
    final tras1 = aplicar(inicial, acierto(t0, dificultad: 2.0));
    final tras2 = aplicar(tras1, fallo(t0.add(const Duration(seconds: 30)), dificultad: 1.0));
    expect(tras2.precision, closeTo(2 / 3, 1e-9));
    expect(tras2.nivel, NivelMaestria.enDesarrollo);
  });

  test('competente requiere precisión ≥0.75 y ≥3 sesiones consecutivas buenas', () {
    var estado = EstadoHabilidad.inicial('FR.05');
    // Tres sesiones separadas por >4h, cada una con un acierto claro.
    final base = DateTime(2026, 1, 1, 10);
    for (var i = 0; i < 3; i++) {
      final instante = base.add(Duration(hours: i * 5));
      estado = aplicar(estado, acierto(instante));
    }
    expect(estado.sesionesConsecutivasBuenas, 3);
    expect(estado.precision, 1.0);
    expect(estado.nivel, NivelMaestria.competente);
  });

  test('maestría requiere ≥0.90 + ≥20 exposiciones + ≥5 sesiones consecutivas', () {
    var estado = EstadoHabilidad.inicial('FR.05');
    final base = DateTime(2026, 1, 1, 10);
    // 20 aciertos repartidos en 5 sesiones (4 intentos por sesión, gap 5h).
    for (var sesion = 0; sesion < 5; sesion++) {
      for (var intento = 0; intento < 4; intento++) {
        final instante = base.add(
          Duration(hours: sesion * 5, seconds: intento * 30),
        );
        estado = aplicar(estado, acierto(instante));
      }
    }
    expect(estado.totalExposiciones, 20);
    expect(estado.sesionesConsecutivasBuenas, 5);
    expect(estado.precision, 1.0);
    expect(estado.nivel, NivelMaestria.maestria);
  });

  test('un fallo dentro de la misma sesión no resetea sesiones consecutivas', () {
    var estado = EstadoHabilidad.inicial('FR.05');
    final base = DateTime(2026, 1, 1, 10);
    // Sesión 1: acierto.
    estado = aplicar(estado, acierto(base));
    expect(estado.sesionesConsecutivasBuenas, 1);
    // Sesión 1 (mismo bloque, gap < 4h): fallo. No suma ni resetea.
    estado = aplicar(estado, fallo(base.add(const Duration(minutes: 10))));
    expect(estado.sesionesConsecutivasBuenas, 1);
  });

  test('una sesión nueva con precisión < 0.75 resetea el contador', () {
    var estado = EstadoHabilidad.inicial('FR.05');
    final base = DateTime(2026, 1, 1, 10);
    // Sesión 1: acierto.
    estado = aplicar(estado, acierto(base));
    expect(estado.sesionesConsecutivasBuenas, 1);
    // Sesión 2 (gap > 4h): un único fallo → precisión total 0.5 < 0.75 → reset.
    estado = aplicar(estado, fallo(base.add(const Duration(hours: 5))));
    expect(estado.sesionesConsecutivasBuenas, 0);
  });

  test('maxIntentosRecientes acota la ventana a los últimos 20 por defecto', () {
    var estado = EstadoHabilidad.inicial('FR.05');
    var instante = DateTime(2026, 1, 1, 10);
    // 25 intentos seguidos: deben quedar 20 en la ventana.
    for (var i = 0; i < 25; i++) {
      estado = aplicar(estado, acierto(instante));
      instante = instante.add(const Duration(seconds: 10));
    }
    expect(estado.intentosRecientes.length, 20);
    expect(estado.totalExposiciones, 25);
  });

  test('perfil desconocido lanza ArgumentError con mensaje útil', () {
    final inicial = EstadoHabilidad.inicial('FR.01');
    final payload = acierto(DateTime(2026, 1, 1, 10));
    expect(
      () => motor.actualizarMaestria(
        previo: inicial,
        payload: payload,
        idPerfil: 'PX',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message.toString(),
          'mensaje',
          contains('PX'),
        ),
      ),
    );
  });

  test('P4 sin pareja declarada/real guarda el intento pero no calibra', () {
    // P4 ya está implementado (AH.03 de Las Versiones). Un intento sin
    // confianzaDeclarada/fiabilidadReal no puede medir calibración:
    // se guarda por trazabilidad y la calibración queda en 0.
    final inicial = EstadoHabilidad.inicial('AH.03');
    final tras = motor.actualizarMaestria(
      previo: inicial,
      payload: acierto(DateTime(2026, 1, 1, 10)),
      idPerfil: 'P4',
      config: ProfileConfig.defaultP4,
    );
    expect(tras.precision, 0.0);
    expect(tras.totalExposiciones, 1);
    expect(tras.nivel, NivelMaestria.introducida);
  });
}
