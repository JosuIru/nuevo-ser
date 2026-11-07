import 'package:concejo/dominio/tarea.dart';
import 'package:flutter_test/flutter_test.dart';

final _inicio = DateTime(2026, 11, 15, 9);
final _antes = DateTime(2026, 11, 10, 12);

Tarea _tarea({String titulo = 'Limpiar el camino', int plazas = 2}) => Tarea(
      uid: 't1',
      titulo: titulo,
      inicio: _inicio,
      lugar: 'Camino del monte',
      plazas: plazas,
    );

void main() {
  test('para crearla hacen falta título, plazas no negativas y fecha futura',
      () {
    expect(_tarea().problemas(_antes), isEmpty);
    expect(_tarea(titulo: ' ').problemas(_antes), [ProblemaTarea.faltaTitulo]);
    expect(
        _tarea(plazas: -1).problemas(_antes), [ProblemaTarea.plazasNegativas]);
    expect(_tarea().problemas(_inicio), [ProblemaTarea.yaHaEmpezado]);
  });

  test('apuntarse hasta llenar las plazas; 0 plazas es sin límite', () {
    final llena = _tarea()
        .conApuntado('ane', apuntado: true, ahora: _antes)
        .conApuntado('maite', apuntado: true, ahora: _antes);
    expect(llena.llena, isTrue);
    expect(llena.plazasLibres, 0);
    expect(() => llena.conApuntado('pili', apuntado: true, ahora: _antes),
        throwsStateError);
    expect(
        llena.conApuntado('ane', apuntado: false, ahora: _antes).apuntadosUids,
        {'maite'});

    var sinLimite = _tarea(plazas: 0);
    for (final uid in ['a', 'b', 'c']) {
      sinLimite = sinLimite.conApuntado(uid, apuntado: true, ahora: _antes);
    }
    expect(sinLimite.llena, isFalse);
    expect(sinLimite.plazasLibres, isNull);
  });

  test('apuntarse dos veces no ocupa dos plazas', () {
    final una = _tarea()
        .conApuntado('ane', apuntado: true, ahora: _antes)
        .conApuntado('ane', apuntado: true, ahora: _antes);
    expect(una.apuntadosUids, {'ane'});
  });

  test('cuando ha empezado ya no se apunta ni se desapunta nadie', () {
    expect(() => _tarea().conApuntado('ane', apuntado: true, ahora: _inicio),
        throwsStateError);
  });

  test('se anula antes de empezar y con motivo', () {
    expect(() => _tarea().anular(' ', _antes), throwsArgumentError);
    final anulada = _tarea().anular('Llueve', _antes);
    expect(anulada.anulada, isTrue);
    expect(() => anulada.conApuntado('ane', apuntado: true, ahora: _antes),
        throwsStateError);
    expect(() => _tarea().anular('Tarde', _inicio), throwsStateError);
  });

  test('desde el día se da por hecha, con una nota', () {
    expect(() => _tarea().hecha('Hecho', _antes), throwsStateError);
    final hecha = _tarea().hecha(' Quedó limpio ', DateTime(2026, 11, 15, 7));
    expect(hecha.estaHecha, isTrue);
    expect(hecha.notaHecha, 'Quedó limpio');
    expect(() => _tarea().anular('x', _antes).hecha('y', _inicio),
        throwsStateError);
  });
}
