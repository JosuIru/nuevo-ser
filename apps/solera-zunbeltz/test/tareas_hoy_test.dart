// Listas de tareas de la pantalla Hoy (vencidas, esta semana, mías).

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/politica_espacio.dart';
import 'package:solera_zunbeltz/utiles/tareas_hoy.dart';

void main() {
  final ahora = DateTime(2026, 11, 4, 10);
  int dia(int desplazamiento) =>
      DateTime(2026, 11, 4 + desplazamiento, 12).millisecondsSinceEpoch;
  final tester = PoliticaEspacio(SesionEspacio(
      persona: PersonaEspacio(uid: 'ane', nombre: 'Ane'),
      capacidades: {capacidadEnviarPeticiones}));
  final coordinacion = PoliticaEspacio(SesionEspacio(
      persona: PersonaEspacio(uid: 'coord', nombre: 'Coord'),
      capacidades: {capacidadGestionarProyectos}));

  TareaMantenimiento tarea(String titulo,
          {int? fecha,
          String estado = 'pendiente',
          String prioridad = 'media',
          List<String> responsables = const []}) =>
      TareaMantenimiento(
          fincaId: 1,
          titulo: titulo,
          fechaObjetivoMs: fecha,
          estado: estado,
          prioridad: prioridad,
          responsablesUids: responsables);

  final tareas = [
    tarea('vencida general', fecha: dia(-3)),
    tarea('vencida ajena', fecha: dia(-1), responsables: ['otra']),
    tarea('vencida hecha', fecha: dia(-2), estado: 'hecha'),
    tarea('hoy baja', fecha: dia(0), prioridad: 'baja'),
    tarea('hoy alta', fecha: dia(0), prioridad: 'alta'),
    tarea('dentro de 6 días', fecha: dia(6), responsables: ['ane']),
    tarea('dentro de 7 días', fecha: dia(7)),
    tarea('mía sin fecha', responsables: ['ane', 'otra']),
  ];

  List<String> titulos(FiltroTareasHoy filtro, PoliticaEspacio politica) =>
      tareasDeHoy(tareas, filtro, ahora, politica)
          .map((tarea) => tarea.titulo)
          .toList();

  test('vencidas: una tester no ve las de otras; coordinación, todas', () {
    expect(titulos(FiltroTareasHoy.vencidas, tester), ['vencida general']);
    expect(titulos(FiltroTareasHoy.vencidas, coordinacion),
        ['vencida general', 'vencida ajena']);
  });

  test('esta semana: hoy y los 6 días siguientes, alta antes que baja', () {
    expect(titulos(FiltroTareasHoy.semana, tester),
        ['hoy alta', 'hoy baja', 'dentro de 6 días']);
  });

  test('mías: las que llevo, con fecha antes que sin ella', () {
    expect(titulos(FiltroTareasHoy.mias, tester),
        ['dentro de 6 días', 'mía sin fecha']);
    expect(titulos(FiltroTareasHoy.mias, const PoliticaEspacio(null)), isEmpty);
  });
}
