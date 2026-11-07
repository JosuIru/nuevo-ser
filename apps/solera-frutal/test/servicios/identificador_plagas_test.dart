import 'package:flutter_test/flutter_test.dart';
import 'package:solera_frutal/servicios/identificador_plagas_ia.dart';

void main() {
  test('el esquema solo ofrece las plagas de la especie y «otra»', () {
    final ids =
        ((esquemaIdentificacion('avellano')['properties'] as Map)['candidatos']
            ['items']['properties']['plaga_id'] as Map)['enum'] as List;
    expect(ids, contains('balanino_avellano'));
    expect(ids, contains(plagaFueraDelCatalogo));
    expect(ids, isNot(contains('eurytoma_amygdali')));
  });

  test('intérprete: filtra por especie, quita repetidos y ordena', () {
    final resultado = interpretarIdentificacion({
      'legible': true,
      'candidatos': [
        {'plaga_id': 'monilia', 'confianza': 'baja', 'motivo': 'flores secas'},
        {'plaga_id': 'eurytoma_amygdali', 'confianza': 'alta', 'motivo': 'x'},
        {'plaga_id': 'balanino_avellano', 'confianza': 'alta', 'motivo': 'y'},
        {'plaga_id': 'monilia', 'confianza': 'media', 'motivo': 'repetida'},
        {'plaga_id': 'pulgones', 'confianza': 'segura', 'motivo': 'nivel raro'},
        {'plaga_id': 'otra', 'confianza': 'media', 'motivo': 'carencia'},
        'basura',
      ],
      'observaciones': ' Hoja con melaza ',
    }, 'almendro');
    expect(resultado.legible, isTrue);
    expect(resultado.candidatos.map((c) => c.plaga.id),
        ['eurytoma_amygdali', 'monilia']);
    expect(resultado.candidatos.last.motivo, 'flores secas');
    expect(resultado.fueraDelCatalogo, isTrue);
    expect(resultado.observaciones, 'Hoja con melaza');
  });

  test('intérprete: respuesta vacía o rara no rompe', () {
    final resultado = interpretarIdentificacion({}, 'nogal');
    expect(resultado.legible, isFalse);
    expect(resultado.candidatos, isEmpty);
    expect(
        interpretarIdentificacion({'candidatos': 'no es lista'}, 'nogal')
            .candidatos,
        isEmpty);
  });

  test('como mucho tres candidatos', () {
    final resultado = interpretarIdentificacion({
      'legible': true,
      'candidatos': [
        for (final id in [
          'monilia',
          'cribado',
          'mancha_ocre',
          'lepra_almendro'
        ])
          {'plaga_id': id, 'confianza': 'media', 'motivo': ''}
      ],
    }, 'almendro');
    expect(resultado.candidatos, hasLength(3));
  });

  test('especie sin plagas en el catálogo: solo «otra»', () {
    expect(plagasParaIdentificar('pepita'), isEmpty);
  });
}
