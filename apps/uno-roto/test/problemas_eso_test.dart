import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uno_roto/dominio/eso/problema_eso.dart';
import 'package:uno_roto/dominio/fragmento_en_tejado.dart';
import 'package:uno_roto/dominio/generador_caza.dart';
import 'package:uno_roto/dominio/mapeo_habilidades_puzzle.dart';
import 'package:uno_roto/l10n/app_localizations.dart';
import 'package:uno_roto/l10n/narrativa_ca.dart';
import 'package:uno_roto/l10n/narrativa_eu.dart';
import 'package:uno_roto/vista/pantalla_problema_eso.dart';

/// Las fichas de las habilidades de 1.º y 2.º de ESO (Fase B de la
/// ampliación a 14 años): cada generador da problemas bien formados,
/// deterministas por semilla, para cualquier dificultad, y todo lo que
/// se lee está traducido.
void main() {
  const semillasPorDificultad = 40;

  Iterable<ProblemaEso> muestras(FichaProblemaEso ficha) sync* {
    for (var dificultad = 0; dificultad <= 7; dificultad++) {
      for (var semilla = 0; semilla < semillasPorDificultad; semilla++) {
        yield ficha.generar(math.Random(semilla * 31 + dificultad), dificultad);
      }
    }
  }

  test('todas las habilidades de ESO tienen ficha', () {
    expect(fichasProblemasEso.keys.toSet(), habilidadesEso);
  });

  test('las fichas son de habilidades de ESO del catálogo', () {
    final catalogo =
        jsonDecode(File('assets/data/skills.json').readAsStringSync())
            as Map<String, dynamic>;
    final cursos = {
      for (final habilidad in catalogo['skills'] as List)
        habilidad['id'] as String: habilidad['course'] as String?,
    };
    for (final id in habilidadesEso) {
      expect(cursos[id], anyOf('1E', '2E'),
          reason: '$id debe estar en skills.json con curso de ESO');
    }
    for (final id in fichasProblemasEso.keys) {
      expect(habilidadesEso, contains(id),
          reason: 'ficha $id sin habilidad de ESO');
      expect(fichasProblemasEso[id]!.idHabilidad, id);
    }
  });

  for (final ficha in fichasProblemasEso.values) {
    group(ficha.idHabilidad, () {
      test('problemas bien formados en todas las dificultades', () {
        for (final problema in muestras(ficha)) {
          final contexto =
              '${ficha.idHabilidad}: ${problema.enunciadoRelleno} ${problema.opciones}';
          expect(problema.idHabilidad, ficha.idHabilidad, reason: contexto);
          expect(problema.opciones, hasLength(4), reason: contexto);
          expect(problema.opciones.toSet(), hasLength(4),
              reason: 'opciones repetidas en $contexto');
          expect(problema.opciones.every((opcion) => opcion.trim().isNotEmpty),
              isTrue,
              reason: contexto);
          expect(problema.indiceCorrecto, inInclusiveRange(0, 3),
              reason: contexto);
          expect(problema.enunciadoRelleno, isNot(contains('{')),
              reason: 'dato sin rellenar en $contexto');
          expect(
              problema.opciones.any((opcion) =>
                  opcion.contains('NaN') || opcion.contains('Infinity')),
              isFalse,
              reason: contexto);
        }
      });

      test('la misma semilla da el mismo problema', () {
        for (var dificultad = 0; dificultad <= 7; dificultad++) {
          final primero = ficha.generar(math.Random(1234), dificultad);
          final segundo = ficha.generar(math.Random(1234), dificultad);
          expect(segundo.enunciadoRelleno, primero.enunciadoRelleno);
          expect(segundo.opciones, primero.opciones);
          expect(segundo.indiceCorrecto, primero.indiceCorrecto);
        }
      });

      test('la respuesta buena no siempre está en el mismo sitio', () {
        final posiciones = {
          for (final problema in muestras(ficha)) problema.indiceCorrecto
        };
        expect(posiciones.length, greaterThan(1));
      });

      test('ficha completa', () {
        expect(ficha.etiquetaTejado.trim(), isNotEmpty);
        expect(ficha.etiquetaTejado.length, lessThanOrEqualTo(8),
            reason: 'la etiqueta del tejado es corta');
        expect(ficha.tituloAyuda, ficha.tituloAyuda.toUpperCase());
        expect(ficha.transferencia, startsWith('En la vida:'));
        expect(ficha.preguntaTutor.trim(), isNotEmpty);
        expect(ficha.errorTipico.trim(), isNotEmpty);
        expect(ficha.dificultadEstimada, inInclusiveRange(0.5, 2.0));
      });

      test('todo lo que se lee está traducido (eu y ca)', () {
        final textos = <String>{
          ficha.tituloAyuda,
          ficha.textoAyuda,
          ficha.transferencia
        };
        for (final problema in muestras(ficha)) {
          textos.add(problema.enunciado);
          textos.addAll(problema.opciones.where(_tienePalabras));
          textos
              .addAll(_textosDelDibujo(problema.visual).where(_tienePalabras));
        }
        for (final texto in textos) {
          final euskera = narrativaEu[texto] ?? traduccionesEso[texto]?[0];
          final catalan = narrativaCa[texto] ?? traduccionesEso[texto]?[1];
          expect(euskera, isNotNull, reason: 'falta en euskera: «$texto»');
          expect(catalan, isNotNull, reason: 'falta en catalán: «$texto»');
          for (final marcador
              in RegExp(r'\{\w+\}').allMatches(texto).map((m) => m.group(0)!)) {
            expect(euskera, contains(marcador),
                reason: 'eu pierde $marcador en «$texto»');
            expect(catalan, contains(marcador),
                reason: 'ca pierde $marcador en «$texto»');
          }
        }
      });
    });
  }

  test('las traducciones son pares [euskera, catalán]', () {
    traduccionesEso.forEach((castellano, traducciones) {
      expect(traducciones, hasLength(2), reason: castellano);
      expect(traducciones.every((texto) => texto.trim().isNotEmpty), isTrue,
          reason: castellano);
    });
  });

  test('el Fragmento de ESO se reconstruye desde su semilla', () {
    final idHabilidad = fichasProblemasEso.keys.first;
    final fragmento = GeneradorCaza(semilla: 7).siguienteParaSkill(
      idHabilidad: idHabilidad,
      esquirlasAcumuladas: 200,
      ahora: DateTime(2026, 9, 25),
    );
    expect(fragmento.tipo, TipoFragmentoEnTejado.problemaEso);
    expect(fragmento.idHabilidadEso, idHabilidad);
    expect(fragmento.etiquetaDecimal,
        fichasProblemasEso[idHabilidad]!.etiquetaTejado);
    final primero = generarProblemaEso(idHabilidad,
        semilla: fragmento.semillaProblema!,
        dificultad: fragmento.dificultadSugerida!);
    final segundo = generarProblemaEso(idHabilidad,
        semilla: fragmento.semillaProblema!,
        dificultad: fragmento.dificultadSugerida!);
    expect(segundo.opciones, primero.opciones);
    expect(tipoParaSkillId(idHabilidad), TipoFragmentoEnTejado.problemaEso);
    expect(puzzleDisponible(idHabilidad), isTrue);
  });

  group('pantalla', () {
    setUp(() => SharedPreferences.setMockInitialValues({
          'uroto.demos_puzzles_vistos': <String>['eso']
        }));

    Future<bool?> montarYElegir(
        WidgetTester tester, ProblemaEso problema, int indice) async {
      bool? resultado;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Builder(
          builder: (contexto) => TextButton(
            onPressed: () async {
              resultado = await Navigator.of(contexto).push<bool>(
                  MaterialPageRoute(
                      builder: (_) => PantallaProblemaEso(problema: problema)));
            },
            child: const Text('abrir'),
          ),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('eso-enunciado')), findsOneWidget);
      await tester.tap(find.byKey(ValueKey('eso-opcion-$indice')));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      return resultado;
    }

    testWidgets('acertar cierra el puzzle con true', (tester) async {
      final problema = generarProblemaEso(fichasProblemasEso.keys.first,
          semilla: 3, dificultad: 2);
      expect(await montarYElegir(tester, problema, problema.indiceCorrecto),
          isTrue);
    });

    testWidgets('fallar no lo cierra', (tester) async {
      final problema = generarProblemaEso(fichasProblemasEso.keys.first,
          semilla: 3, dificultad: 2);
      expect(
          await montarYElegir(
              tester, problema, (problema.indiceCorrecto + 1) % 4),
          isNull);
      expect(find.byType(PantallaProblemaEso), findsOneWidget);
    });

    // Cada tipo de dibujo se pinta sin romper.
    final dibujos = <VisualEso>[
      const VisualPlano(
          puntos: [(x: 2, y: -3, etiqueta: 'A')],
          rectas: [(pendiente: 2, ordenada: -1)]),
      const VisualGrafica(
          puntos: [(x: 0, y: 0), (x: 2, y: 10), (x: 4, y: 10)],
          etiquetaX: 'horas',
          etiquetaY: 'km'),
      const VisualTriangulos(
          ladosPequeno: ['3', '4', '5'], ladosGrande: ['6', '?', '10']),
      for (final forma in FormaCuerpo.values)
        VisualCuerpo(forma: forma, medidas: const {
          'radio': '3 cm',
          'alto': '?',
          'lado': '4',
          'largo': '5',
          'ancho': '2',
          'generatriz': '5'
        }),
      for (final forma in FormaPlana.values)
        VisualFigura(forma: forma, medidas: const {
          'baseMayor': '8',
          'baseMenor': '5',
          'alto': '4',
          'lado': '6',
          'apotema': '?'
        }),
      const VisualTabla(cabecera: [
        'Dato',
        'Frecuencia'
      ], filas: [
        ['1', '3'],
        ['2', '5']
      ]),
      const VisualArbol(primeras: [
        'C 1/2',
        'X 1/2'
      ], segundas: [
        ['C 1/2', 'X 1/2'],
        ['C 1/2', 'X 1/2']
      ]),
    ];
    for (final dibujo in dibujos) {
      testWidgets('pinta ${dibujo.runtimeType} ${_forma(dibujo)}',
          (tester) async {
        final problema = ProblemaEso(
          idHabilidad: fichasProblemasEso.keys.first,
          enunciado: '¿Cuánto es {e}?',
          datos: const {'e': '2 + 2'},
          opciones: const ['4', '5', '6', '7'],
          indiceCorrecto: 0,
          visual: dibujo,
        );
        await tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PantallaProblemaEso(problema: problema),
        ));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(
          find.byKey(
              ValueKey(dibujo is VisualTabla ? 'eso-tabla' : 'eso-dibujo')),
          findsOneWidget,
        );
      });
    }
  });
}

String _forma(VisualEso dibujo) => switch (dibujo) {
      VisualCuerpo(:final forma) => forma.name,
      VisualFigura(:final forma) => forma.name,
      _ => '',
    };

/// Si un texto lleva palabras que haya que traducir (no sólo números,
/// signos, unidades o letras sueltas de álgebra).
bool _tienePalabras(String texto) =>
    RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñÜü]{4,}').hasMatch(texto);

Iterable<String> _textosDelDibujo(VisualEso? dibujo) => switch (dibujo) {
      null => const [],
      VisualPlano(:final puntos) => puntos.map((punto) => punto.etiqueta),
      VisualGrafica(:final etiquetaX, :final etiquetaY) => [
          etiquetaX,
          etiquetaY
        ],
      VisualTriangulos(:final ladosPequeno, :final ladosGrande) => [
          ...ladosPequeno,
          ...ladosGrande
        ],
      VisualCuerpo(:final medidas) => medidas.values,
      VisualFigura(:final medidas) => medidas.values,
      VisualTabla(:final cabecera, :final filas) => [
          ...cabecera,
          for (final fila in filas) ...fila
        ],
      VisualArbol(:final primeras, :final segundas) => [
          ...primeras,
          for (final ramas in segundas) ...ramas
        ],
    };
