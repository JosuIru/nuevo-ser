import 'dart:math';

import 'package:concejo/dominio/recuento.dart';
import 'package:concejo/dominio/reglas_decision.dart';
import 'package:concejo/dominio/urna.dart';
import 'package:flutter_test/flutter_test.dart';

final _ahora = DateTime.utc(2026, 11, 10, 18, 42, 13);

Urna _urnaConVotos(List<Set<String>> votos, {bool secreta = true}) {
  var urna = const Urna(asuntoUid: 'a1');
  for (final (indice, voto) in votos.indexed) {
    urna = urna.votarEnLaApp(
      personaUid: 'p$indice',
      opcionesMarcadas: voto,
      ahora: _ahora,
      secreta: secreta,
      azar: Random(indice),
    );
  }
  return urna;
}

void main() {
  group('votación', () {
    const simple = ReglasDecision(forma: FormaDecision.votacion);

    test('mayoría simple: más síes que noes, sin contar abstenciones', () {
      final urna = _urnaConVotos([
        {votoSi},
        {votoSi},
        {votoNo},
        {votoAbstencion},
        {votoAbstencion},
      ]);
      final resultado = contarVotacion(simple, urna);
      expect(resultado.desenlace, DesenlaceVotacion.aprobada);
      expect((resultado.si, resultado.no, resultado.abstenciones), (2, 1, 2));
    });

    test('empate en mayoría simple = rechazada', () {
      final urna = _urnaConVotos([
        {votoSi},
        {votoNo}
      ]);
      expect(
          contarVotacion(simple, urna).desenlace, DesenlaceVotacion.rechazada);
    });

    test('mayoría absoluta cuenta las abstenciones en el total', () {
      const absoluta = ReglasDecision(
          forma: FormaDecision.votacion, mayoria: Mayoria.absoluta);
      final urna = _urnaConVotos([
        {votoSi},
        {votoSi},
        {votoNo},
        {votoAbstencion},
        {votoAbstencion},
      ]);
      // 2 de 5 no es más de la mitad.
      expect(contarVotacion(absoluta, urna).desenlace,
          DesenlaceVotacion.rechazada);
    });

    test('dos tercios: 2 de 3 llega, 3 de 5 no', () {
      const dosTercios = ReglasDecision(
          forma: FormaDecision.votacion, mayoria: Mayoria.dosTercios);
      expect(
        contarVotacion(
            dosTercios,
            _urnaConVotos([
              {votoSi},
              {votoSi},
              {votoNo}
            ])).desenlace,
        DesenlaceVotacion.aprobada,
      );
      expect(
        contarVotacion(
          dosTercios,
          _urnaConVotos([
            {votoSi},
            {votoSi},
            {votoSi},
            {votoNo},
            {votoNo}
          ]),
        ).desenlace,
        DesenlaceVotacion.rechazada,
      );
    });

    test('sin quórum, aunque gane el sí', () {
      const conQuorum =
          ReglasDecision(forma: FormaDecision.votacion, quorumPersonas: 4);
      final urna = _urnaConVotos([
        {votoSi},
        {votoSi},
        {votoSi}
      ]);
      expect(contarVotacion(conQuorum, urna).desenlace,
          DesenlaceVotacion.sinQuorum);
    });

    test('las papeletas en papel se suman y cuentan para el quórum', () {
      const conQuorum =
          ReglasDecision(forma: FormaDecision.votacion, quorumPersonas: 4);
      var urna = _urnaConVotos([
        {votoNo},
        {votoNo}
      ]);
      urna = urna
          .anotarVotoPresencial(personaUid: 'abuela', mesaUid: 'm1')
          .anotarVotoPresencial(personaUid: 'vecino', mesaUid: 'm1')
          .anotarVotoPresencial(personaUid: 'pastora', mesaUid: 'm2')
          .anadirConteoPresencial(const ConteoPresencial(
            asuntoUid: 'a1',
            papeletasTotales: 3,
            marcasPorOpcion: {votoSi: 3},
            firmadoPorUids: ['m1', 'm2'],
          ));
      final resultado = contarVotacion(conQuorum, urna);
      expect(resultado.participantes, 5);
      expect((resultado.si, resultado.no), (3, 2));
      expect(resultado.desenlace, DesenlaceVotacion.aprobada);
      expect(urna.avisos(), isEmpty);
    });
  });

  group('elección entre opciones (aprobación)', () {
    const reglas = ReglasDecision(
      forma: FormaDecision.eleccionEntreOpciones,
      opciones: [
        OpcionDecision(id: 'agosto', texto: 'Segundo fin de semana de agosto'),
        OpcionDecision(
            id: 'septiembre', texto: 'Primer fin de semana de septiembre'),
        OpcionDecision(id: 'julio', texto: 'Último fin de semana de julio'),
      ],
    );

    test(
        'gana la opción que más gente acepta, aunque no sea la favorita de nadie',
        () {
      final urna = _urnaConVotos([
        {'agosto', 'septiembre'},
        {'julio', 'septiembre'},
        {'agosto', 'septiembre'},
        {'julio'},
      ]);
      final resultado = contarEleccion(reglas, urna);
      expect(resultado.ganadoras, ['septiembre']);
      expect(resultado.aceptacionesPorOpcion,
          {'agosto': 2, 'septiembre': 3, 'julio': 2});
    });

    test('un empate se enseña, no se sortea', () {
      final urna = _urnaConVotos([
        {'agosto'},
        {'julio'}
      ]);
      final resultado = contarEleccion(reglas, urna);
      expect(resultado.empate, isTrue);
      expect(resultado.ganadoras, ['agosto', 'julio']);
    });

    test('papeletas en blanco cuentan como papeletas pero no aceptan nada', () {
      final urna = _urnaConVotos([{}, {}]);
      final resultado = contarEleccion(reglas, urna);
      expect(resultado.ganadoras, isEmpty);
      expect(resultado.papeletas, 2);
    });
  });

  group('presupuesto', () {
    const reglas = ReglasDecision(
      forma: FormaDecision.presupuesto,
      bolsaEuros: 10000,
      opciones: [
        OpcionDecision(
            id: 'bancos', texto: 'Bancos en la plaza', costeEuros: 3000),
        OpcionDecision(
            id: 'frontón', texto: 'Arreglar el frontón', costeEuros: 8000),
        OpcionDecision(
            id: 'fuente', texto: 'Limpiar la fuente vieja', costeEuros: 1500),
        OpcionDecision(id: 'columpios', texto: 'Columpios', costeEuros: 5000),
      ],
    );

    test('entran por apoyos mientras quepan; la que no cabe se salta', () {
      final urna = _urnaConVotos([
        {'frontón', 'fuente'},
        {'frontón', 'bancos'},
        {'frontón', 'columpios', 'fuente'},
        {'bancos', 'fuente'},
        {'columpios'},
      ]);
      // Apoyos: frontón 3, fuente 3, bancos 2, columpios 2.
      // A igualdad, la más barata: fuente (1500) antes que frontón (8000).
      final resultado = contarPresupuesto(reglas, urna);
      expect(resultado.lineas.map((l) => l.opcion.id),
          ['fuente', 'frontón', 'bancos', 'columpios']);
      expect(resultado.seleccionadas.map((o) => o.id), ['fuente', 'frontón']);
      expect(resultado.lineas[2].motivo, MotivoPresupuesto.noCabe);
      expect(resultado.gastadoEuros, 9500);
      expect(resultado.sobranteEuros, 500);
    });

    test('sin apoyos no entra aunque sobre dinero', () {
      final urna = _urnaConVotos([
        {'fuente'}
      ]);
      final resultado = contarPresupuesto(reglas, urna);
      expect(resultado.seleccionadas.map((o) => o.id), ['fuente']);
      expect(
        resultado.lineas.where((l) => l.motivo == MotivoPresupuesto.sinApoyos),
        hasLength(3),
      );
    });
  });

  group('reglas', () {
    test(
        'un presupuesto sin bolsa o con propuestas sin coste no se puede abrir',
        () {
      const reglas = ReglasDecision(
        forma: FormaDecision.presupuesto,
        opciones: [OpcionDecision(id: 'x', texto: 'X')],
      );
      expect(reglas.problemas(), hasLength(2));
    });

    test('una elección necesita al menos dos opciones distintas', () {
      const reglas = ReglasDecision(
        forma: FormaDecision.eleccionEntreOpciones,
        opciones: [
          OpcionDecision(id: 'a', texto: 'A'),
          OpcionDecision(id: 'a', texto: 'A otra vez'),
        ],
      );
      expect(reglas.problemas(), isNotEmpty);
    });

    test('el consentimiento nunca es secreto', () {
      const reglas = ReglasDecision(forma: FormaDecision.consentimiento);
      expect(reglas.esSecreta, isFalse);
    });
  });
}
