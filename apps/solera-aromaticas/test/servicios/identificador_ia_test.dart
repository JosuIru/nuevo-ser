import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aromaticas/servicios/identificador_ia.dart';

import '../hard_limits_test.dart' show vocabularioProhibido;

List<Object?> _idsDelEsquema(Map<String, dynamic> esquema) =>
    ((esquema['properties'] as Map)['candidatos']['items']['properties']['id']
        as Map)['enum'] as List;

void main() {
  test('el esquema de especie ofrece todo el catálogo y «otra»', () {
    final ids = _idsDelEsquema(esquemaEspecie());
    expect(ids, containsAll(['lavanda', 'genciana', fueraDelCatalogo]));
    expect(
        (esquemaEspecie()['required'] as List), contains('rasgos_a_comprobar'));
  });

  test('el esquema de plaga solo ofrece las de la especie', () {
    final ids = _idsDelEsquema(esquemaPlaga('tomillo_comun'));
    expect(ids, ['arima_marginata', fueraDelCatalogo]);
    expect(plagasParaIdentificar('romero'), isEmpty);
  });

  test('intérprete de especie: filtra, quita repetidos, ordena y recorta', () {
    final propuesta = interpretarEspecie({
      'legible': true,
      'candidatos': [
        {'id': 'tomillo_salsero', 'confianza': 'baja', 'motivo': 'hoja'},
        {'id': 'tomillo_comun', 'confianza': 'media', 'motivo': 'porte'},
        {'id': 'tomillo_comun', 'confianza': 'alta', 'motivo': 'repetida'},
        {'id': 'inventada', 'confianza': 'alta', 'motivo': 'no existe'},
        {'id': 'romero', 'confianza': 'segura', 'motivo': 'nivel raro'},
        {'id': 'cantueso', 'confianza': 'baja', 'motivo': ''},
        {'id': 'lavanda', 'confianza': 'baja', 'motivo': ''},
        {'id': 'otra', 'confianza': 'media', 'motivo': ''},
        'basura',
      ],
      'observaciones': ' Flor pequeña ',
      'rasgos_a_comprobar': ' Mira el envés de la hoja ',
    });
    expect(propuesta.candidatos.map((c) => c.fila.id),
        ['tomillo_comun', 'tomillo_salsero', 'cantueso']);
    expect(propuesta.fueraDelCatalogo, isTrue);
    expect(propuesta.observaciones, 'Flor pequeña');
    expect(propuesta.rasgosAComprobar, 'Mira el envés de la hoja');
  });

  test('intérprete de plaga: solo ids de la especie; vacío no rompe', () {
    final propuesta = interpretarPlaga({
      'legible': true,
      'candidatos': [
        {'id': 'cecidomia_lavandin', 'confianza': 'alta', 'motivo': 'x'},
        {'id': 'arima_marginata', 'confianza': 'media', 'motivo': 'y'},
      ],
    }, 'tomillo_comun');
    expect(propuesta.candidatos.single.fila.id, 'arima_marginata');
    final vacia = interpretarPlaga({}, 'lavanda');
    expect(vacia.legible, isFalse);
    expect(vacia.candidatos, isEmpty);
    expect(
        interpretarEspecie({'candidatos': 'no es lista'}).candidatos, isEmpty);
  });

  test('los prompts no hablan de propiedades de salud y lo prohíben', () {
    for (final prompt in [
      sistemaEspecie(),
      sistemaPlaga('lavandin', 'Lavandín'),
    ]) {
      for (final palabra in vocabularioProhibido) {
        expect(prompt.toLowerCase(), isNot(contains(palabra)), reason: palabra);
      }
    }
    expect(sistemaEspecie(), contains('No digas nunca si la planta se puede'));
    expect(sistemaPlaga('lavandin', 'Lavandín'),
        contains('Nunca recomiendes productos'));
  });
}
