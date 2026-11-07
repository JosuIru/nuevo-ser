import 'package:flutter_test/flutter_test.dart';
import 'package:solera_vivero/dominio/catalogos.dart';
import 'package:solera_vivero/servicios/identificador_plagas_ia.dart';

void main() {
  final plagasTomate = plagasParaIdentificar(
      especieId: 'tomate', nombreBotanico: 'Solanum lycopersicum');

  test('se ofrecen las comunes del grupo y las reguladas de la planta', () {
    final ids = plagasTomate.map((plaga) => plaga.id);
    expect(ids, contains('tuta_absoluta'));
    expect(ids, contains('clavibacter_michiganensis'));
    expect(ids, isNot(contains('procesionaria')));
    expect(ids, isNot(contains('bursaphelenchus_xylophilus')));
    expect(
        plagasTomate
            .firstWhere((plaga) => plaga.id == 'clavibacter_michiganensis')
            .esRegulada,
        isTrue);
    final olivoEscritoAMano =
        plagasParaIdentificar(nombreBotanico: 'Olea europaea').map((p) => p.id);
    expect(olivoEscritoAMano, contains('xylella_fastidiosa'));
  });

  test('el esquema solo ofrece esa lista y «otra»', () {
    final ids = ((esquemaIdentificacion(plagasTomate)['properties']
            as Map)['candidatos']['items']['properties']['plaga_id']
        as Map)['enum'] as List;
    expect(ids, hasLength(plagasTomate.length + 1));
    expect(ids, contains(plagaFueraDelCatalogo));
  });

  test('el sistema prohíbe tratamientos y dar la planta por sana', () {
    final sistema = sistemaIdentificacion(plagasTomate, 'Tomate');
    expect(sistema, contains('Nunca recomiendes productos'));
    expect(sistema, contains('Nunca digas que la planta está sana'));
    expect(sistema, contains('[REGULADA]'));
  });

  test(
      'intérprete: filtra, quita repetidos, baja la confianza de las reguladas',
      () {
    final resultado = interpretarIdentificacion({
      'legible': true,
      'candidatos': [
        {'plaga_id': 'oidio', 'confianza': 'baja', 'motivo': 'polvo blanco'},
        {'plaga_id': 'procesionaria', 'confianza': 'alta', 'motivo': 'no es'},
        {
          'plaga_id': 'clavibacter_michiganensis',
          'confianza': 'alta',
          'motivo': 'chancro'
        },
        {'plaga_id': 'oidio', 'confianza': 'media', 'motivo': 'repetida'},
        {'plaga_id': 'trips', 'confianza': 'segura', 'motivo': 'nivel raro'},
        {'plaga_id': 'otra', 'confianza': 'media', 'motivo': 'riego'},
        'basura',
      ],
      'observaciones': ' Hojas con manchas ',
    }, plagasTomate);
    expect(resultado.legible, isTrue);
    expect(resultado.candidatos.map((c) => (c.plaga.id, c.confianza)), [
      ('clavibacter_michiganensis', 'media'),
      ('oidio', 'baja'),
    ]);
    expect(resultado.fueraDelCatalogo, isTrue);
    expect(resultado.observaciones, 'Hojas con manchas');
  });

  test('intérprete: respuesta vacía o rara no rompe; como mucho tres', () {
    expect(interpretarIdentificacion({}, plagasTomate).candidatos, isEmpty);
    expect(interpretarIdentificacion({}, plagasTomate).legible, isFalse);
    expect(
        interpretarIdentificacion({'candidatos': 'no'}, plagasTomate)
            .candidatos,
        isEmpty);
    final muchos = interpretarIdentificacion({
      'legible': true,
      'candidatos': [
        for (final id in ['oidio', 'botritis', 'trips', 'pulgones'])
          {'plaga_id': id, 'confianza': 'media', 'motivo': ''}
      ],
    }, plagasTomate);
    expect(muchos.candidatos, hasLength(3));
  });

  test('aviso a la autoridad: no para plagas comunes, sí para el resto', () {
    expect(exigeAvisoAutoridad('pulgones'), isFalse);
    expect(exigeAvisoAutoridad('xylella_fastidiosa'), isTrue);
    expect(exigeAvisoAutoridad('algo escrito a mano'), isTrue);
  });
}
