import 'package:concejo/dominio/asunto.dart';
import 'package:concejo/dominio/compromiso.dart';
import 'package:concejo/dominio/consentimiento.dart';
import 'package:concejo/dominio/debate.dart';
import 'package:concejo/dominio/reglas_decision.dart';
import 'package:flutter_test/flutter_test.dart';

Asunto _fiestas({
  String efectoEntorno = 'Ninguno',
  TipoDecision tipo = TipoDecision.consultiva,
  String compromiso = '',
}) =>
    Asunto(
      uid: 'fiestas',
      titulo: '¿Cambiamos la fecha de las fiestas?',
      resumen: 'Proponen pasar las fiestas a septiembre.',
      efectoEntorno: efectoEntorno,
      tipoDecision: tipo,
      compromisoPrevio: compromiso,
      reglas: const ReglasDecision(forma: FormaDecision.votacion),
      inicioDebate: DateTime(2026, 11, 1),
      inicioDecision: DateTime(2026, 11, 11),
      finDecision: DateTime(2026, 11, 15),
    );

void main() {
  group('asunto', () {
    test('sin efecto sobre el entorno no se abre (aunque sea «ninguno»)', () {
      expect(_fiestas(efectoEntorno: '').problemasParaAbrir(),
          [ProblemaAsunto.faltaEfectoEntorno]);
      expect(() => _fiestas(efectoEntorno: ' ').abrir(), throwsStateError);
    });

    test('con compromiso previo hay que escribir el compromiso', () {
      expect(
        _fiestas(tipo: TipoDecision.conCompromisoPrevio).problemasParaAbrir(),
        [ProblemaAsunto.faltaCompromisoPrevio],
      );
    });

    test('las reglas se cambian en borrador y quedan fijas al abrir', () {
      final borrador = _fiestas();
      final conQuorum = borrador.conReglas(const ReglasDecision(
          forma: FormaDecision.votacion, quorumPersonas: 20));
      expect(conQuorum.reglas.quorumPersonas, 20);
      final abierto = conQuorum.abrir();
      expect(
        () => abierto
            .conReglas(const ReglasDecision(forma: FormaDecision.votacion)),
        throwsStateError,
      );
    });

    test('las fases siguen el calendario', () {
      final asunto = _fiestas().abrir();
      expect(asunto.faseEn(DateTime(2026, 11, 5)), FaseAsunto.debate);
      expect(asunto.faseEn(DateTime(2026, 11, 12)), FaseAsunto.decision);
      expect(asunto.faseEn(DateTime(2026, 11, 20)), FaseAsunto.seguimiento);
      expect(_fiestas().faseEn(DateTime(2026, 11, 5)), FaseAsunto.borrador);
    });
  });

  group('consentimiento', () {
    const inicio = EstadoConsentimiento(rondaActual: 1, rondasMaximas: 2);

    test('sin objeciones vivas, aprobada', () {
      expect(inicio.cerrarRonda().desenlace, DesenlaceConsentimiento.aprobada);
    });

    test('objeción integrada en la segunda vuelta: aprobada', () {
      var estado = inicio.objetar(
          uid: 'o1',
          autorUid: 'ane',
          motivo: 'El ruido despierta al ganado de noche');
      final cierre = estado.cerrarRonda();
      expect(cierre.desenlace, DesenlaceConsentimiento.enCurso);
      estado = cierre.estado.resolverObjecion(
          'o1', EstadoObjecion.integrada, 'La música acaba a las 2');
      expect(estado.rondaActual, 2);
      expect(estado.cerrarRonda().desenlace, DesenlaceConsentimiento.aprobada);
    });

    test(
        'con objeciones vivas al agotar las vueltas, pasa a votación o asamblea',
        () {
      var estado = inicio.objetar(uid: 'o1', autorUid: 'ane', motivo: 'Daño X');
      estado = estado.cerrarRonda().estado;
      expect(estado.cerrarRonda().desenlace,
          DesenlaceConsentimiento.pasaAVotacionOAsamblea);
    });

    test('una objeción sin motivo no vale, y resolverla exige decir cómo', () {
      expect(() => inicio.objetar(uid: 'o1', autorUid: 'ane', motivo: ' '),
          throwsArgumentError);
      final estado =
          inicio.objetar(uid: 'o1', autorUid: 'ane', motivo: 'Daño X');
      expect(
          () => estado.resolverObjecion('o1', EstadoObjecion.noEsObjecion, ''),
          throwsArgumentError);
      expect(
        estado.resolverObjecion('o1', EstadoObjecion.retirada, '').vivas,
        isEmpty,
      );
    });
  });

  group('debate', () {
    final cuando = DateTime(2026, 11, 2);
    Aportacion aportacion(String uid, TipoAportacion tipo,
            {String? respondeA, bool anonima = false}) =>
        Aportacion(
          uid: uid,
          asuntoUid: 'fiestas',
          autorUid: 'ane',
          tipo: tipo,
          texto: 'Texto $uid',
          creada: cuando,
          respondeAUid: respondeA,
          anonima: anonima,
        );

    test('las aportaciones van a su columna y las respuestas no son columna',
        () {
      final debate = const Debate(asuntoUid: 'fiestas')
          .aportar(aportacion('1', TipoAportacion.aFavor))
          .aportar(aportacion('2', TipoAportacion.enContra))
          .aportar(aportacion('3', TipoAportacion.duda, respondeA: '1'));
      expect(debate.columna(TipoAportacion.aFavor).map((a) => a.uid), ['1']);
      expect(debate.columna(TipoAportacion.duda), isEmpty);
      expect(debate.respuestasA('1').map((a) => a.uid), ['3']);
    });

    test('solo un nivel de respuestas', () {
      final debate = const Debate(asuntoUid: 'fiestas')
          .aportar(aportacion('1', TipoAportacion.aFavor))
          .aportar(aportacion('2', TipoAportacion.duda, respondeA: '1'));
      expect(
          () => debate
              .aportar(aportacion('3', TipoAportacion.duda, respondeA: '2')),
          throwsArgumentError);
    });

    test('las anónimas esperan a la mesa', () {
      final debate = const Debate(asuntoUid: 'fiestas')
          .aportar(aportacion('1', TipoAportacion.enContra, anonima: true));
      expect(debate.columna(TipoAportacion.enContra), isEmpty);
      expect(debate.columna(TipoAportacion.enContra, paraLaMesa: true),
          hasLength(1));
    });
  });

  group('compromisos', () {
    final compromiso = Compromiso(
      uid: 'c1',
      asuntoUid: 'fiestas',
      que: 'Avisar a la charanga del cambio',
      responsable: 'Comisión de fiestas',
      fechaLimite: DateTime(2026, 12, 15),
    );

    test('vence al día siguiente de la fecha límite, no antes', () {
      expect(compromiso.vencidoEn(DateTime(2026, 12, 15, 23, 59)), isFalse);
      expect(compromiso.vencidoEn(DateTime(2026, 12, 16)), isTrue);
      expect(
        compromiso
            .cambiarEstado(EstadoCompromiso.hecho)
            .vencidoEn(DateTime(2027)),
        isFalse,
      );
    });

    test('«no se hará» exige motivo', () {
      expect(() => compromiso.cambiarEstado(EstadoCompromiso.noSeHara),
          throwsArgumentError);
    });

    test('balance para «¿Se ha hecho?»', () {
      final balance = BalanceCompromisos([
        compromiso,
        compromiso.cambiarEstado(EstadoCompromiso.hecho),
        compromiso.cambiarEstado(EstadoCompromiso.noSeHara,
            nota: 'No hay charanga'),
      ], DateTime(2026, 12, 20));
      expect(
          (balance.total, balance.hechos, balance.noSeHaran, balance.vencidos),
          (3, 1, 1, 1));
    });
  });
}
