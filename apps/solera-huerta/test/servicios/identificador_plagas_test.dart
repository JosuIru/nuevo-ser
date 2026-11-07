import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/servicios/identificador_plagas_ia.dart';

void main() {
  List<dynamic> idsDelEsquema(String familia) =>
      ((esquemaIdentificacion(familia)['properties'] as Map)['candidatos']
          ['items']['properties']['plaga_id'] as Map)['enum'] as List;

  test('el esquema solo ofrece las plagas de la familia y «otra»', () {
    final ids = idsDelEsquema('solanaceas');
    expect(ids, contains('tuta_absoluta'));
    expect(ids, contains(plagaFueraDelCatalogo));
    expect(ids, isNot(contains('mosca_zanahoria')));
    expect(idsDelEsquema('Apiaceas'), contains('mosca_zanahoria'),
        reason: 'la familia se normaliza');
  });

  test('las instrucciones prohíben proponer tratamientos', () {
    final sistema = sistemaIdentificacion('Tomate', 'solanaceas');
    expect(sistema, contains('Nunca recomiendes productos'));
    expect(sistema, contains('tuta_absoluta'));
  });

  test('intérprete: filtra por familia, quita repetidos y ordena', () {
    final resultado = interpretarIdentificacion({
      'legible': true,
      'candidatos': [
        {
          'plaga_id': 'mildiu_tomate_patata',
          'confianza': 'baja',
          'motivo': 'manchas'
        },
        {
          'plaga_id': 'mosca_zanahoria',
          'confianza': 'alta',
          'motivo': 'otra familia'
        },
        {
          'plaga_id': 'tuta_absoluta',
          'confianza': 'alta',
          'motivo': 'galerías'
        },
        {
          'plaga_id': 'mildiu_tomate_patata',
          'confianza': 'media',
          'motivo': 'repetida'
        },
        {'plaga_id': 'pulgones', 'confianza': 'segura', 'motivo': 'nivel raro'},
        {'plaga_id': 'otra', 'confianza': 'media', 'motivo': 'granizo'},
        'basura',
      ],
      'observaciones': ' Hoja con galerías ',
    }, 'solanaceas');
    expect(resultado.legible, isTrue);
    expect(resultado.candidatos.map((c) => c.plaga.id),
        ['tuta_absoluta', 'mildiu_tomate_patata']);
    expect(resultado.candidatos.last.motivo, 'manchas');
    expect(resultado.fueraDelCatalogo, isTrue);
    expect(resultado.observaciones, 'Hoja con galerías');
  });

  test('intérprete: respuesta vacía o rara no rompe', () {
    final resultado = interpretarIdentificacion({}, 'solanaceas');
    expect(resultado.legible, isFalse);
    expect(resultado.candidatos, isEmpty);
    expect(
        interpretarIdentificacion({'candidatos': 'no es lista'}, 'solanaceas')
            .candidatos,
        isEmpty);
  });

  test('como mucho tres candidatos', () {
    final resultado = interpretarIdentificacion({
      'legible': true,
      'candidatos': [
        for (final id in [
          'tuta_absoluta',
          'mosca_blanca',
          'arana_roja',
          'trips',
        ])
          {'plaga_id': id, 'confianza': 'media', 'motivo': ''}
      ],
    }, 'solanaceas');
    expect(resultado.candidatos, hasLength(3));
  });

  test('familia desconocida: solo las plagas sin familia y «otra»', () {
    final ids = idsDelEsquema('inventada');
    expect(ids.last, plagaFueraDelCatalogo);
    expect(
        plagasParaIdentificar('inventada')
            .every((plaga) => plaga.familias.isEmpty),
        isTrue);
  });
}
