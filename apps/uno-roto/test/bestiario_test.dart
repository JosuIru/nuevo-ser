import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:uno_roto/dominio/bestiario.dart';

/// Tests del bestiario de Fragmentos (doc 16, eje C): coherencia del
/// catálogo de fichas contra `skills.json` y lógica pura de
/// encuentros/tramos.
void main() {
  group('CatalogoBestiario — coherencia', () {
    test('ids únicos y sin habilidades repetidas entre fichas', () {
      final ids = CatalogoBestiario.todas.map((f) => f.id).toSet();
      expect(ids.length, CatalogoBestiario.todas.length);
      final habilidadesVistas = <String>{};
      for (final ficha in CatalogoBestiario.todas) {
        for (final idHabilidad in ficha.idsHabilidades) {
          expect(habilidadesVistas.add(idHabilidad), isTrue,
              reason: '$idHabilidad cuenta para dos fichas — los '
                  'encuentros se duplicarían');
        }
      }
    });

    test('toda habilidad de las fichas existe en skills.json', () {
      final catalogoRaw = jsonDecode(
        File('${Directory.current.path}/assets/data/skills.json')
            .readAsStringSync(),
      ) as Map<String, dynamic>;
      final idsCatalogo = (catalogoRaw['skills'] as List<dynamic>)
          .map((s) => (s as Map<String, dynamic>)['id'] as String)
          .toSet();
      for (final ficha in CatalogoBestiario.todas) {
        for (final idHabilidad in ficha.idsHabilidades) {
          expect(idsCatalogo.contains(idHabilidad), isTrue,
              reason: 'La ficha ${ficha.id} referencia $idHabilidad, '
                  'que no existe en el catálogo');
        }
      }
    });

    test('tramos crecientes y el primero se revela al primer encuentro', () {
      for (final ficha in CatalogoBestiario.todas) {
        expect(ficha.tramos, isNotEmpty);
        expect(ficha.tramos.first.umbralEncuentros, 1,
            reason: '${ficha.id}: si el niño ya vio la familia, la '
                'ficha no puede seguir vacía');
        for (var i = 1; i < ficha.tramos.length; i++) {
          expect(
            ficha.tramos[i].umbralEncuentros >
                ficha.tramos[i - 1].umbralEncuentros,
            isTrue,
            reason: '${ficha.id}: tramos desordenados',
          );
        }
      }
    });
  });

  group('FichaBestiario — encuentros y tramos', () {
    EstadoHabilidad estadoCon(String id, int exposiciones) =>
        EstadoHabilidad.inicial(id)
            .copiarCon(totalExposiciones: exposiciones);

    test('encuentros suma las exposiciones de sus habilidades', () {
      final ficha = CatalogoBestiario.todas
          .firstWhere((f) => f.id == 'impropios'); // FR.12 + FR.13
      final estados = {
        'FR.12': estadoCon('FR.12', 3),
        'FR.13': estadoCon('FR.13', 4),
        'FR.01': estadoCon('FR.01', 99), // de otra ficha — no cuenta
      };
      expect(ficha.encuentros(estados), 7);
      expect(ficha.encuentros(const {}), 0);
    });

    test('tramosRevelados respeta los umbrales 1/5/15', () {
      final ficha = CatalogoBestiario.todas.first;
      expect(ficha.tramosRevelados(0), isEmpty);
      expect(ficha.tramosRevelados(1).length, 1);
      expect(ficha.tramosRevelados(5).length, 2);
      expect(ficha.tramosRevelados(14).length, 2);
      expect(ficha.tramosRevelados(15).length, 3);
    });
  });
}
