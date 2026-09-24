import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/bestiario.dart';
import 'package:uno_roto/dominio/minijuegos/ayudas_maquinas.dart';
import 'package:uno_roto/dominio/minijuegos/catalogo_minijuegos.dart';
import 'package:uno_roto/dominio/minijuegos/ejemplos_resueltos.dart';
import 'package:uno_roto/dominio/minijuegos/reto_semanal.dart';
import 'package:uno_roto/l10n/narrativa_ca.dart';
import 'package:uno_roto/l10n/narrativa_eu.dart';

/// Los textos de las máquinas tienen que estar en euskera y en catalán:
/// si una clave en castellano no coincide letra a letra, la pantalla
/// sale en castellano sin avisar.
void main() {
  List<String> sinTraducir(Iterable<String> textos) => [
        for (final texto in textos)
          if (!narrativaEu.containsKey(texto) || !narrativaCa.containsKey(texto)) texto,
      ];

  test('fichas de las máquinas', () {
    final textos = [
      for (final definicion in CatalogoMinijuegos.todos) ...[
        definicion.nombre,
        definicion.descripcion,
        definicion.lineaRexan,
        definicion.comoSeJuega,
      ],
    ];
    expect(sinTraducir(textos), isEmpty);
  });

  test('trucos', () {
    expect(sinTraducir(trucosPorHabilidad.values), isEmpty);
  });

  test('pasos de los ejemplos parecidos', () {
    final plantillas = <String>{};
    for (final habilidad in habilidadesConEjemplo) {
      for (var semilla = 0; semilla < 40; semilla++) {
        for (var dificultad = 1; dificultad <= 3; dificultad++) {
          final ejemplo = ejemploParecido(habilidad,
              dificultad: dificultad, azar: math.Random(semilla));
          if (ejemplo == null) continue;
          plantillas.addAll(ejemplo.pasos.map((paso) => paso.plantilla));
        }
      }
    }
    expect(sinTraducir(plantillas), isEmpty);
  });

  test('fichas del bestiario', () {
    final textos = [
      for (final ficha in CatalogoBestiario.todas) ...[
        ficha.nombre,
        ficha.habitat,
        for (final tramo in ficha.tramos) tramo.texto,
      ],
      'Común',
      'Inusual',
    ];
    expect(sinTraducir(textos), isEmpty);
  });

  test('retos de la semana', () {
    final textos = [
      'El reto de la semana',
      for (final especial in especialesSemanales) ...[especial.nombre, especial.descripcion],
    ];
    expect(sinTraducir(textos), isEmpty);
  });
}
