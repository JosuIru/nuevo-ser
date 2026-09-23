import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';

EstadoHabilidad? _estado(String id, NivelMaestria nivel) =>
    EstadoHabilidad.inicial(id).copiarCon(nivel: nivel);

void main() {
  final engranajes = CatalogoMinijuegos.de(IdMinijuego.engranajes);

  test('las máquinas de la segunda sala están separadas', () {
    expect(CatalogoMinijuegos.deLaSala(2), contains(engranajes));
    expect(CatalogoMinijuegos.deLaSala(1), isNot(contains(engranajes)));
    for (final definicion in CatalogoMinijuegos.deLaSala(2)) {
      expect(definicion.llaves, isNotEmpty, reason: definicion.nombre);
    }
  });

  test('sin las llaves dominadas, apagada y dice cuáles faltan', () {
    final disponibilidad = disponibilidadMinijuego(engranajes, {
      'DIV.01': _estado('DIV.01', NivelMaestria.competente),
      'DIV.05': _estado('DIV.05', NivelMaestria.enDesarrollo),
    });
    expect(disponibilidad.disponible, isFalse);
    expect(disponibilidad.llavesPendientes, ['DIV.05']);
    expect(segundaSalaAbierta({IdMinijuego.engranajes: disponibilidad}), isFalse);
  });

  test('con las llaves en competente o más, se enciende y trabaja todas sus habilidades', () {
    final disponibilidad = disponibilidadMinijuego(engranajes, {
      'DIV.01': _estado('DIV.01', NivelMaestria.maestria),
      'DIV.05': _estado('DIV.05', NivelMaestria.competente),
    });
    expect(disponibilidad.disponible, isTrue);
    expect(disponibilidad.llavesPendientes, isEmpty);
    expect(disponibilidad.habilidadesPracticadas, engranajes.habilidades);
    expect(disponibilidad.dificultad, 1); // aún no ha practicado MCM/MCD
    expect(segundaSalaAbierta({IdMinijuego.engranajes: disponibilidad}), isTrue);
  });

  test('la primera sala sigue abriéndose por haber practicado', () {
    final puentes = CatalogoMinijuegos.de(IdMinijuego.puentes);
    expect(disponibilidadMinijuego(puentes, {}).disponible, isFalse);
    expect(
        disponibilidadMinijuego(puentes, {'FR.14': _estado('FR.14', NivelMaestria.introducida)})
            .disponible,
        isTrue);
  });
}
