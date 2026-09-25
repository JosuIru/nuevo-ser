import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show
        NivelMaestria,
        PlanoAmbiente,
        PlanoCierreAmable,
        PlanoDialogo,
        PlanoEleccion;
import 'package:uno_roto/dominio/catalogo_escenas.dart';
import 'package:uno_roto/dominio/desafio_kurz.dart';
import 'package:uno_roto/dominio/escena_cinematica.dart';
import 'package:uno_roto/dominio/escenas_arco_cinco.dart';
import 'package:uno_roto/dominio/motor_maestria.dart';
import 'package:uno_roto/dominio/orquestador_escenas.dart';
import 'package:uno_roto/dominio/personajes_taller.dart';
import 'package:uno_roto/dominio/eso/problema_eso.dart';
import 'package:uno_roto/dominio/voz_personaje.dart';
import 'package:uno_roto/l10n/narrativa_arco_cinco.dart';
import 'package:uno_roto/l10n/narrativa_ca.dart';
import 'package:uno_roto/l10n/narrativa_eu.dart';
import 'package:uno_roto/vista/personajes/retratos.dart';

/// El Arco V (La Montaña, Era 3): se engancha tras el 4.14, avanza con
/// las habilidades de ESO, el combate con Velo sigue gane o pierda, y
/// todo lo que se lee está traducido.
void main() {
  final orquestador = OrquestadorEscenas();

  DecisionOrquestador decidir(Set<String> flags) => orquestador.decidir(
        flagsActivos: flags,
        variantesArco1Usadas: const {},
        variantesArco2Usadas: const {},
        variantesArco3Usadas: const {},
        variantesEraDosUsadas: const {},
        varianteYaDisparadaEnEstaTransicion: true,
      );

  /// Todos los flags de salida del catálogo hasta el 4.14 (lo jugado).
  Set<String> hastaElArcoCuatro() {
    final flags = <String>{};
    for (final escena in CatalogoEscenas.todas) {
      if (EscenasArcoCinco.todas.contains(escena)) break;
      flags
        ..add(escena.flagDeSalida)
        ..addAll(escena.flagsRequeridos);
    }
    for (final id in [
      'kurz_1',
      'kurz_2',
      'kurz_3',
      'zafran',
      'duel_kai',
      'vorax'
    ]) {
      flags.add('combate_${id}_completado');
    }
    return flags;
  }

  test('las escenas del Arco V están en el catálogo con ids únicos', () {
    for (final escena in EscenasArcoCinco.todas) {
      expect(CatalogoEscenas.porId(escena.id), same(escena));
    }
    final ids = CatalogoEscenas.todas.map((escena) => escena.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('sin empezar el lenguaje algebraico, la Montaña espera', () {
    final flags = hastaElArcoCuatro();
    expect(decidir(flags), isA<IrAlMapa>());
    flags
        .add(MotorMaestria.flagDeMaestria('ALG.04', NivelMaestria.introducida));
    final decision = decidir(flags);
    expect(decision, isA<CinematicaPendiente>());
    expect((decision as CinematicaPendiente).escena.id, '5.1');
  });

  test('las habilidades que abren el arco son de ESO y tienen ficha', () {
    final flagsDeHabilidad = {
      for (final escena in EscenasArcoCinco.todas)
        ...escena.flagsRequeridos
            .where((flag) => flag.endsWith('_introducida')),
    };
    expect(flagsDeHabilidad, isNotEmpty);
    for (final flag in flagsDeHabilidad) {
      final idHabilidad = flag
          .replaceAll('_introducida', '')
          .toUpperCase()
          .replaceFirst('_', '.');
      expect(fichasProblemasEso, contains(idHabilidad),
          reason: '$flag necesita la ficha de $idHabilidad');
    }
  });

  for (final gana in [true, false]) {
    test(
        'el arco se recorre entero ${gana ? 'ganando' : 'perdiendo'} contra Velo',
        () {
      final flags = hastaElArcoCuatro();
      // Se van empezando las habilidades de ESO a medida que las piden.
      for (final escena in EscenasArcoCinco.todas) {
        flags.addAll(escena.flagsRequeridos
            .where((flag) => flag.endsWith('_introducida')));
      }
      final vistas = <String>[];
      for (var paso = 0; paso < 40; paso++) {
        final decision = decidir(flags);
        if (decision is IrAlMapa) break;
        if (decision is CombateKurzPendiente) {
          expect(decision.desafio, same(DesafioKurz.velo));
          flags
            ..add('combate_velo_completado')
            ..add(gana ? 'victoria_velo' : 'derrota_velo');
          vistas.add('velo');
          continue;
        }
        final escena = (decision as CinematicaPendiente).escena;
        vistas.add(escena.id);
        flags.add(escena.flagDeSalida);
      }
      expect(vistas, [
        '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', 'velo', //
        gana ? '5.8victoria' : '5.8derrota',
        '5.9', '5.10', '5.11', '5.12', '5.13', '5.14',
      ]);
    });
  }

  test('el 4.14 ya no dice «fin del MVP» y el 5.14 cierra con HASTA ENTONCES',
      () {
    final montana = CatalogoEscenas.porId('4.14')!;
    expect(
      montana.planos
          .whereType<PlanoAmbiente>()
          .map((plano) => plano.textoLectura),
      isNot(contains('FIN DEL MVP.')),
    );
    final cierre = EscenasArcoCinco.laCartaDeIrune;
    expect(cierre.esCierreAmable, isTrue);
    expect(
        (cierre.planos.last as PlanoCierreAmable).textoBoton, 'HASTA ENTONCES');
  });

  test('Velo: cada respuesta buena es la de verdad', () {
    const desafio = DesafioKurz.velo;
    expect(desafio.vozQueHabla, VozPersonaje.fragmentoVelo);
    expect(desafio.secuenciaValores.length, desafio.preguntas.length + 1);
    final respuestas = [
      for (final pregunta in desafio.preguntas)
        pregunta.opciones[pregunta.indiceCorrecto]
    ];
    // 3·7 − 5 = 16; 2·7 + 4 = 18; 2·(5 + 4) = 18; 12/2 + 12/3 = 10; x = (14 + 4)/2.
    expect(respuestas, ['7', '7', '5', '12', '9']);
    for (final pregunta in desafio.preguntas) {
      expect(pregunta.opciones.toSet(), hasLength(pregunta.opciones.length));
    }
  });

  test('Ulden y Aldara tienen retrato y se pueden dibujar en el taller', () {
    for (final voz in [VozPersonaje.ulden, VozPersonaje.aldara]) {
      expect(rasgosPorVoz, contains(voz));
      expect(idDeRetrato(voz), isNotNull);
      expect(personajeDeVoz(voz), isNotNull);
    }
  });

  test(
      'todo lo que se lee en el Arco V y en el combate está en euskera y en catalán',
      () {
    final textos = <String>{
      for (final escena in EscenasArcoCinco.todas) ...[
        escena.titulo,
        ..._textosDe(escena)
      ],
      for (final pregunta in DesafioKurz.velo.preguntas) ...[
        pregunta.enunciado,
        pregunta.fraseFalloKurz
      ],
      DesafioKurz.velo.fraseAcierto,
      DesafioKurz.velo.fraseDerrota,
      DesafioKurz.velo.fraseVictoria,
      for (final personaje in personajesDelTaller) personaje.papel,
    };
    final faltan = <String>[];
    for (final texto in textos) {
      final euskera = narrativaEu[texto] ?? narrativaArcoCinco[texto]?[0];
      final catalan = narrativaCa[texto] ?? narrativaArcoCinco[texto]?[1];
      if (euskera == null || catalan == null) {
        faltan.add(texto);
        continue;
      }
      for (final marcador
          in RegExp(r'\{\w+\}').allMatches(texto).map((m) => m.group(0)!)) {
        expect(euskera, contains(marcador),
            reason: 'eu pierde $marcador en «$texto»');
        expect(catalan, contains(marcador),
            reason: 'ca pierde $marcador en «$texto»');
      }
    }
    expect(faltan, isEmpty);
  });
}

Iterable<String> _textosDe(EscenaCinematica escena) sync* {
  for (final plano in escena.planos) {
    switch (plano) {
      case PlanoAmbiente(:final textoLectura?):
        yield textoLectura;
      case PlanoDialogo(:final texto):
        yield texto;
      case PlanoEleccion(:final textoPrompt, :final opciones):
        if (textoPrompt != null) yield textoPrompt;
        for (final opcion in opciones) {
          yield opcion.textoJugador;
          if (opcion.textoRespuesta != null) yield opcion.textoRespuesta!;
        }
      case PlanoCierreAmable(:final textoBoton):
        yield textoBoton;
      default:
        break;
    }
  }
}
