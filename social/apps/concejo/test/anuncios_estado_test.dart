import 'package:concejo/datos/instantanea.dart';
import 'package:concejo/dominio/anuncio.dart';
import 'package:concejo/estado/accion.dart';
import 'package:concejo/estado/datos_ejemplo.dart';
import 'package:concejo/estado/estado_concejo.dart';
import 'package:flutter_test/flutter_test.dart';

final _hoy = DateTime(2026, 11, 10, 12);

EstadoConcejo _pueblo(String personaUid, {DateTime? ahora}) =>
    instantaneaDesdeJson(instantaneaAJson(estadoDeEjemplo(hoy: _hoy)),
        personaActualUid: personaUid, reloj: () => ahora ?? _hoy);

Anuncio _nuevo({String uid = 'nuevo', String titulo = 'Se regalan nueces'}) =>
    Anuncio(
      uid: uid,
      titulo: titulo,
      texto: 'Un saco en la puerta de casa.',
      autorUid: 'quien-sea',
      publicado: DateTime(2000),
      fijado: true,
    );

void main() {
  test('cualquier participante publica; autor y fecha los pone la app', () {
    final maite = _pueblo('maite');
    final acciones = <AccionConcejo>[];
    maite.alHacerAccion = acciones.add;
    maite.publicarAnuncio(_nuevo());

    final publicado = maite.anuncios.firstWhere((a) => a.uid == 'nuevo');
    expect(publicado.autorUid, 'maite');
    expect(publicado.publicado, _hoy);
    expect(publicado.fijado, isFalse, reason: 'fijar es cosa de la mesa');
    expect(acciones.single.tipo, TipoAccion.publicarAnuncio);

    expect(() => maite.publicarAnuncio(_nuevo()), throwsStateError,
        reason: 'uid repetido: no se edita publicando otra vez');
    expect(() => maite.publicarAnuncio(_nuevo(uid: 'otro', titulo: ' ')),
        throwsStateError);
  });

  test('en el tablón, los fijados arriba y luego lo más reciente', () {
    final maite = _pueblo('maite');
    maite.publicarAnuncio(_nuevo());
    final orden = maite.anunciosVigentes.map((a) => a.uid).toList();
    expect(orden.first, 'agua', reason: 'el corte de agua está fijado');
    expect(orden[1], 'nuevo');
    expect(orden, isNot(contains('feria')), reason: 'ya pasó su fecha');
  });

  test('quien lo publicó lo retira; otra persona sin mesa, no', () {
    final maite = _pueblo('maite');
    maite.publicarAnuncio(_nuevo());
    expect(
        () => _pueblo('josean').retirarAnuncio('nueces', ''), throwsStateError);
    maite.retirarAnuncio('nuevo', '');
    expect(maite.anunciosVigentes.map((a) => a.uid), isNot(contains('nuevo')));
    expect(() => maite.retirarAnuncio('nuevo', ''), throwsStateError);
  });

  test('la mesa retira el de otra persona diciendo por qué, y fija', () {
    final ane = _pueblo('ane');
    expect(() => ane.retirarAnuncio('nueces', ' '), throwsStateError);
    ane.retirarAnuncio('nueces', 'Ya no quedan');
    expect(ane.anuncios.firstWhere((a) => a.uid == 'nueces').motivoRetirada,
        'Ya no quedan');

    ane.fijarAnuncio('poda', fijado: true);
    expect(ane.anunciosVigentes.take(2).map((a) => a.uid).toSet(),
        {'agua', 'poda'});
    expect(() => _pueblo('maite').fijarAnuncio('poda', fijado: true),
        throwsStateError);
    expect(() => ane.fijarAnuncio('no-existe', fijado: true), throwsStateError);
  });

  test('los anuncios viajan en la instantánea', () {
    final copia = instantaneaDesdeJson(instantaneaAJson(_pueblo('ane')),
        personaActualUid: 'maite');
    final agua = copia.anuncios.firstWhere((a) => a.uid == 'agua');
    expect(agua.fijado, isTrue);
    expect(agua.hasta, isNotNull);
    expect(copia.anuncios.length, _pueblo('ane').anuncios.length);
  });
}
