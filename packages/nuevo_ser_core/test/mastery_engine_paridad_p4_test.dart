import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Test de paridad Dart/PHP del motor adaptativo, perfil P4 (calibración
/// epistémica). Consume `test/fixtures/motor_p4.json`. El test PHP equivalente
/// (`wp-plugin/nuevo-ser-core/tests/test_paridad_motor_p4.php`) lee la
/// misma fixture y aplica las mismas comprobaciones — si los dos pasan,
/// hay paridad bit a bit.
void main() {
  group('paridad Dart/PHP — motor P4 (calibración epistémica)', () {
    late List<dynamic> casos;

    setUpAll(() {
      final fixture = File('test/fixtures/motor_p4.json').readAsStringSync();
      casos = (jsonDecode(fixture) as Map<String, dynamic>)['casos'] as List;
    });

    test('todos los casos coinciden con el motor P4 + defaultP4', () {
      final motor = MasteryEngine();
      for (final caso in casos.cast<Map<String, dynamic>>()) {
        final nombre = caso['nombre'] as String;
        var estado = _estadoDesdeJson(caso['estado_inicial'] as Map<String, dynamic>);
        for (final p in (caso['secuencia'] as List).cast<Map<String, dynamic>>()) {
          estado = motor.actualizarMaestria(
            previo: estado,
            payload: SessionPayload(
              acierto: p['acierto'] as bool,
              dificultad: (p['dificultad'] as num).toDouble(),
              duracionSegundos: (p['duracionSegundos'] as num).toInt(),
              instante: DateTime.parse(p['instante'] as String),
              confianzaDeclarada: (p['confianzaDeclarada'] as num?)?.toDouble(),
              fiabilidadReal: (p['fiabilidadReal'] as num?)?.toDouble(),
            ),
            idPerfil: idPerfilP4,
            config: ProfileConfig.defaultP4,
          );
        }
        final esperado = _estadoDesdeJson(caso['esperado_final'] as Map<String, dynamic>);
        _expectarIgualdad(estado, esperado, nombre);
      }
    });
  });
}

EstadoHabilidad _estadoDesdeJson(Map<String, dynamic> json) {
  final intentos = (json['ir'] as List)
      .cast<Map<String, dynamic>>()
      .map((m) => IntentoHabilidad(
            instante: DateTime.parse(m['t'] as String),
            acierto: m['a'] as bool,
            dificultad: (m['d'] as num).toDouble(),
            duracionSegundos: (m['s'] as num).toInt(),
            confianzaDeclarada: (m['cd'] as num?)?.toDouble(),
            fiabilidadReal: (m['fr'] as num?)?.toDouble(),
          ))
      .toList();
  return EstadoHabilidad(
    identificadorHabilidad: json['id'] as String,
    nivel: NivelMaestriaEntero.desdeValor(json['nv'] as int),
    precision: (json['pr'] as num).toDouble(),
    tiempoMedianoSeg: (json['tm'] as num).toDouble(),
    ultimaPractica: DateTime.parse(json['up'] as String),
    sesionesConsecutivasBuenas: json['scb'] as int,
    totalExposiciones: json['te'] as int,
    intentosRecientes: intentos,
  );
}

void _expectarIgualdad(EstadoHabilidad obtenido, EstadoHabilidad esperado, String nombre) {
  expect(obtenido.identificadorHabilidad, esperado.identificadorHabilidad,
      reason: '[$nombre] id');
  expect(obtenido.nivel, esperado.nivel, reason: '[$nombre] nivel');
  expect(obtenido.precision, closeTo(esperado.precision, 1e-9),
      reason: '[$nombre] precision (calibración)');
  expect(obtenido.tiempoMedianoSeg, closeTo(esperado.tiempoMedianoSeg, 1e-9),
      reason: '[$nombre] tiempoMediano');
  expect(obtenido.ultimaPractica.toIso8601String(),
      esperado.ultimaPractica.toIso8601String(),
      reason: '[$nombre] ultimaPractica');
  expect(obtenido.sesionesConsecutivasBuenas,
      esperado.sesionesConsecutivasBuenas,
      reason: '[$nombre] sesionesConsecutivasBuenas');
  expect(obtenido.totalExposiciones, esperado.totalExposiciones,
      reason: '[$nombre] totalExposiciones');
  expect(obtenido.intentosRecientes.length, esperado.intentosRecientes.length,
      reason: '[$nombre] intentosRecientes.length');
  for (var i = 0; i < esperado.intentosRecientes.length; i++) {
    final o = obtenido.intentosRecientes[i];
    final e = esperado.intentosRecientes[i];
    expect(o.instante.toIso8601String(), e.instante.toIso8601String(),
        reason: '[$nombre] ir[$i].t');
    expect(o.acierto, e.acierto, reason: '[$nombre] ir[$i].a');
    expect(o.dificultad, closeTo(e.dificultad, 1e-9),
        reason: '[$nombre] ir[$i].d');
    expect(o.duracionSegundos, e.duracionSegundos,
        reason: '[$nombre] ir[$i].s');
    expect(o.confianzaDeclarada, e.confianzaDeclarada, reason: '[$nombre] ir[$i].cd');
    expect(o.fiabilidadReal, e.fiabilidadReal, reason: '[$nombre] ir[$i].fr');
  }
}
