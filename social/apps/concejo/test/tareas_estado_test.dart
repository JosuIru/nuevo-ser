import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/dominio/tarea.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

EstadoConcejo _pueblo(String personaUid, {DateTime? ahora}) =>
    instantaneaDesdeJson(instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
        personaActualUid: personaUid, reloj: () => ahora ?? _hoy);

Tarea _nueva({String uid = 'nueva', int plazas = 2, DateTime? inicio}) => Tarea(
      uid: uid,
      titulo: ' Montar las mesas ',
      inicio: inicio ?? DateTime(2026, 11, 20, 10),
      lugar: 'Plaza',
      plazas: plazas,
      creadaPorUid: 'quien-sea',
      apuntadosUids: const {'maite'},
    );

void main() {
  test('solo la mesa crea tareas; salen sin nadie apuntado', () {
    expect(() => _pueblo('maite').crearTarea(_nueva()), throwsStateError);
    final ane = _pueblo('ane');
    final acciones = <AccionConcejo>[];
    ane.alHacerAccion = acciones.add;
    ane.crearTarea(_nueva());
    final creada = ane.tarea('nueva');
    expect(creada.titulo, 'Montar las mesas');
    expect(creada.creadaPorUid, 'ane');
    expect(creada.apuntadosUids, isEmpty);
    expect(acciones.single.tipo, TipoAccion.crearTarea);
    expect(() => ane.crearTarea(_nueva()), throwsStateError,
        reason: 'uid repetido');
    expect(
        () => ane.crearTarea(_nueva(uid: 'x', inicio: DateTime(2026, 11, 1))),
        throwsStateError);
  });

  test('cada cual se apunta y se borra; a otra persona solo la apunta la mesa',
      () {
    final maite = _pueblo('maite');
    maite.apuntarseATarea('camino', apuntado: true);
    expect(maite.tarea('camino').apuntadosUids, contains('maite'));
    maite.apuntarseATarea('camino', apuntado: false);
    expect(maite.tarea('camino').apuntadosUids, isNot(contains('maite')));
    expect(
        () =>
            maite.apuntarseATarea('camino', apuntado: true, personaUid: 'pili'),
        throwsStateError);

    final ane = _pueblo('ane');
    ane.apuntarseATarea('camino', apuntado: true, personaUid: 'pili');
    expect(ane.tarea('camino').apuntadosUids, contains('pili'));
    expect(
        () =>
            ane.apuntarseATarea('camino', apuntado: true, personaUid: 'nadie'),
        throwsStateError);
  });

  test('sin plazas libres no entra nadie más', () {
    final maite = _pueblo('maite');
    expect(maite.tarea('local').llena, isTrue);
    expect(
        () => maite.apuntarseATarea('local', apuntado: true), throwsStateError);
  });

  test('la mesa anula con motivo y da por hecha desde el día', () {
    final ane = _pueblo('ane');
    ane.anularTarea('camino', 'Ha nevado');
    expect(ane.tarea('camino').anulada, isTrue);
    expect(() => _pueblo('maite').anularTarea('local', 'x'), throwsStateError);

    final elDia = _pueblo('ane', ahora: DateTime(2026, 11, 14, 8));
    elDia.marcarTareaHecha('local', 'Abierto de 17 a 20');
    expect(elDia.tarea('local').estaHecha, isTrue);
    expect(
        () => _pueblo('ane').marcarTareaHecha('camino', ''), throwsStateError);
  });

  test('las próximas por fecha y las tareas viajan en la instantánea', () {
    final estado = _pueblo('maite');
    expect(estado.tareas.map((t) => t.uid), ['fronton', 'local', 'camino']);
    final copia =
        instantaneaDesdeJson(instantaneaAJson(estado), personaActualUid: 'ane');
    expect(copia.tarea('fronton').notaHecha, estado.tarea('fronton').notaHecha);
    expect(copia.tarea('camino').apuntadosUids,
        estado.tarea('camino').apuntadosUids);
  });
}
