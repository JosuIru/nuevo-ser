import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:uno_roto/dominio/bestiario.dart';
import 'package:uno_roto/dominio/catalogo_distritos.dart';
import 'package:uno_roto/dominio/personajes_taller.dart';
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

  test('el taller de dibujo', () {
    final textos = [
      for (final personaje in personajesDelTaller) personaje.papel,
      for (final distrito in CatalogoDistritos.todos) distrito.nombre,
      'Así lo ves tú. Dibújalo en papel, hazle una foto y aparecerá así en el juego.',
      'Personajes',
      'Distritos',
      'Máquinas',
      'Su paisaje de noche',
      'La planta de arriba',
      'Las máquinas de Rexán',
      'Todavía no os conocéis.',
      'Dibuja cómo ves a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerá así en sus escenas.',
      'Dibuja cómo ves {n} de noche, con sus edificios y sus luces. Luego hazle una foto con buena luz: será su paisaje.',
      'Dibuja cómo te imaginas la máquina {n}. Luego hazle una foto con buena luz: así estará en la sala de Rexán.',
      'Dibuja cómo te imaginas a {n} en un papel, con los colores que quieras. Luego hazle una foto con buena luz: aparecerán así aquí y en su máquina.',
      'Hacer una foto a mi dibujo',
      'Elegir de la galería',
      'Dibujarlo',
      'Cambiar el dibujo',
      'Volver al original',
      'La pared de Rexán',
      'Lo que dibujas, colgado en los recreativos.',
      'Aquí cuelgo lo que me traes. De momento está vacía: los monstruos se dibujan en el bestiario, y el resto en Mi cuaderno, en el taller.',
      'Aquí cuelgo lo que me traes. Es la mejor pared de los recreativos.',
      'No he encontrado el dibujo en esa foto. Prueba con más luz y con el papel entero.',
      'No se ha podido abrir la cámara ni la galería.',
    ];
    expect(sinTraducir(textos), isEmpty);
  });
}
