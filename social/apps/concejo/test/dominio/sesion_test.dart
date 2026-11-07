import 'package:concejo/dominio/sesion.dart';
import 'package:flutter_test/flutter_test.dart';

final _inicio = DateTime(2026, 11, 20, 19);

Sesion _asamblea({List<PuntoOrdenDia>? puntos, String lugar = 'Local'}) =>
    Sesion(
      uid: 's1',
      titulo: 'Asamblea de noviembre',
      inicio: _inicio,
      lugar: lugar,
      puntos: puntos ??
          const [
            PuntoOrdenDia(uid: 'p1', texto: 'Fiestas', asuntoUid: 'fiestas'),
            PuntoOrdenDia(uid: 'p2', texto: 'Ruegos y preguntas'),
          ],
    );

void main() {
  test('para convocar hacen falta título, lugar y algún punto', () {
    expect(_asamblea().problemas(), isEmpty);
    expect(_asamblea(lugar: ' ').problemas(), [ProblemaSesion.faltaLugar]);
    expect(_asamblea(puntos: const []).problemas(), [ProblemaSesion.sinPuntos]);
    expect(
      _asamblea(puntos: const [
        PuntoOrdenDia(uid: 'a', texto: 'Fiestas'),
        PuntoOrdenDia(uid: 'b', texto: 'fiestas '),
      ]).problemas(),
      [ProblemaSesion.puntoRepetido],
    );
  });

  test('se anula con motivo y solo antes de empezar', () {
    final antes = DateTime(2026, 11, 18);
    expect(() => _asamblea().anular(' ', antes), throwsArgumentError);
    final anulada = _asamblea().anular('Coincide con el funeral', antes);
    expect(anulada.anulada, isTrue);
    expect(() => anulada.anular('otra vez', antes), throwsStateError);
    expect(() => _asamblea().anular('tarde', DateTime(2026, 11, 20, 19, 5)),
        throwsStateError);
  });

  test('la asistencia y lo hablado se apuntan desde el día de la asamblea', () {
    final dosDiasAntes = DateTime(2026, 11, 18, 12);
    final eseDia = DateTime(2026, 11, 20, 10);
    expect(
      () =>
          _asamblea().conAsistencia('ane', presente: true, ahora: dosDiasAntes),
      throwsStateError,
    );
    final conGente = _asamblea()
        .conAsistencia('ane', presente: true, ahora: eseDia)
        .conAsistencia('maite', presente: true, ahora: eseDia)
        .conAsistencia('ane', presente: false, ahora: eseDia)
        .conAsistentesSinApp(7, eseDia)
        .conNotas('p2', ' Piden arreglar la fuente. ', eseDia);
    expect(conGente.asistentesUids, {'maite'});
    expect(conGente.asistentes, 8);
    expect(conGente.puntos.last.notas, 'Piden arreglar la fuente.');
    expect(() => conGente.conAsistentesSinApp(-1, eseDia), throwsArgumentError);
    expect(() => conGente.conNotas('p9', 'x', eseDia), throwsStateError);
  });

  test('la convocatoria se cambia hasta que empieza', () {
    final cambiada = Sesion(
      uid: 's1',
      titulo: 'Asamblea de noviembre',
      inicio: _inicio.add(const Duration(days: 1)),
      lugar: 'Frontón',
      puntos: _asamblea().puntos,
    );
    expect(_asamblea().cambiadaPor(cambiada, DateTime(2026, 11, 19)).lugar,
        'Frontón');
    expect(() => _asamblea().cambiadaPor(cambiada, _inicio), throwsStateError);
  });
}
