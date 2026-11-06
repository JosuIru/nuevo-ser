import 'package:concejo/dominio/debate.dart';
import 'package:concejo/dominio/recuento.dart';
import 'package:concejo/dominio/urna.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

void main() {
  test('la mesa anota votos en persona y registra el conteo firmado por dos',
      () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    final abuela = estado.darDeAlta('Maritxu');
    estado
      ..anotarVotoPresencial('fiestas', abuela.uid)
      ..anotarVotoPresencial('fiestas', 'pili')
      ..registrarConteoPresencial(
        asuntoUid: 'fiestas',
        papeletasTotales: 2,
        marcasPorOpcion: {votoSi: 1, votoNo: 1},
        segundaFirmaUid: 'mikel',
      );
    final urna = estado.urna('fiestas');
    expect(urna.participacionesPresenciales, 2);
    expect(urna.avisos(), isEmpty);
    expect(urna.conteosPresenciales.single.firmadoPorUids, ['ane', 'mikel']);
    final resultado = contarVotacion(estado.asunto('fiestas').reglas, urna);
    expect((resultado.si, resultado.no), (1, 1));
  });

  test('quien ha votado en persona ya no puede votar en la app', () {
    final estado = estadoDeEjemplo(hoy: _hoy)
      ..anotarVotoPresencial('fiestas', 'pili');
    estado.verComo('pili');
    expect(
        () => estado.votar('fiestas', {votoSi}), throwsA(isA<VotoDuplicado>()));
    expect(estado.personasSinParticipar('fiestas').map((p) => p.uid),
        isNot(contains('pili')));
  });

  test('el conteo no lo puede firmar dos veces la misma persona ni una vecina',
      () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    for (final segunda in ['ane', 'maite']) {
      expect(
        () => estado.registrarConteoPresencial(
          asuntoUid: 'fiestas',
          papeletasTotales: 0,
          marcasPorOpcion: const {},
          segundaFirmaUid: segunda,
        ),
        throwsStateError,
      );
    }
  });

  test('fuera de plazo no se vota, ni en la app ni en persona', () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    // El presupuesto aún está en debate.
    expect(() => estado.votar('presupuesto', {'fuente'}), throwsStateError);
    expect(() => estado.anotarVotoPresencial('presupuesto', 'pili'),
        throwsStateError);
  });

  test('la mesa recoge una aportación o una objeción dicha en persona', () {
    final estado = estadoDeEjemplo(hoy: _hoy)
      ..aportar('fiestas', TipoAportacion.aFavor, 'Lo dijo en el bar',
          enNombreDeUid: 'josean')
      ..objetar('comunal', 'Lo dejó por escrito en el concejo',
          enNombreDeUid: 'pili');
    expect(estado.debate('fiestas').aportaciones.last.autorUid, 'josean');
    expect(estado.consentimiento('comunal').objeciones.last.autorUid, 'pili');

    estado.verComo('maite');
    expect(
      () => estado.aportar('fiestas', TipoAportacion.aFavor, 'x',
          enNombreDeUid: 'josean'),
      throwsStateError,
    );
  });

  test('una papeleta con opciones que no son del asunto no vale', () {
    final estado = estadoDeEjemplo(hoy: _hoy)..verComo('maite');
    expect(
        () => estado.votar('fiestas', {votoSi, votoNo}), throwsArgumentError);
    expect(() => estado.votar('fiestas', {'quizas'}), throwsArgumentError);
    expect(estado.heVotado('fiestas'), isFalse);
  });

  test('con el asunto cerrado ya no se aporta ni se objeta', () {
    final estado = estadoDeEjemplo(hoy: _hoy);
    expect(() => estado.aportar('txoko', TipoAportacion.aFavor, 'Tarde'),
        throwsStateError);
  });
}
