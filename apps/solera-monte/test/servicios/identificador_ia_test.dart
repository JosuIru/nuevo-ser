import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:solera_monte/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_monte/pantallas/identificar_con_ia.dart';
import 'package:solera_monte/servicios/identificador_ia.dart';

List<Object?> _idsDelEsquema(Map<String, dynamic> esquema) =>
    ((esquema['properties'] as Map)['candidatos']['items']['properties']['id']
        as Map)['enum'] as List;

void main() {
  test('el esquema de una especie solo ofrece sus plagas y «otra»', () {
    final delHaya = _idsDelEsquema(esquemaPlaga('fagus_sylvatica'));
    expect(delHaya, containsAll(['lagarta_peluda', fueraDelCatalogo]));
    expect(delHaya, isNot(contains('procesionaria_pino')));
    final delPino = _idsDelEsquema(esquemaPlaga('pinus_nigra'));
    expect(delPino, containsAll(['procesionaria_pino', 'tomicus_minor']));
    expect(delPino, isNot(contains('chancro_castano')));
  });

  test('sin especie, se ofrece todo el catálogo', () {
    expect(_idsDelEsquema(esquemaPlaga(null)),
        hasLength(catalogoPlagas.length + 1));
    expect(plagasParaIdentificar(''), hasLength(catalogoPlagas.length));
  });

  test('intérprete: filtra, quita repetidos, ordena y recorta a tres', () {
    final propuesta = interpretarPlaga({
      'legible': true,
      'candidatos': [
        {'id': 'tomicus_minor', 'confianza': 'baja', 'motivo': 'ramillos'},
        {'id': 'procesionaria_pino', 'confianza': 'alta', 'motivo': 'bolsón'},
        {'id': 'procesionaria_pino', 'confianza': 'media', 'motivo': 'otra'},
        {'id': 'chancro_castano', 'confianza': 'alta', 'motivo': 'no es pino'},
        {'id': 'ips_acuminatus', 'confianza': 'segura', 'motivo': 'raro'},
        {'id': 'ips_sexdentatus', 'confianza': 'media', 'motivo': 'galerías'},
        {'id': 'banda_marron', 'confianza': 'baja', 'motivo': ''},
        {'id': 'otra', 'confianza': 'media', 'motivo': ''},
        'basura',
      ],
      'observaciones': ' Copa seca ',
      'que_comprobar': ' Mira bajo la corteza ',
    }, 'pinus_sylvestris');
    expect(propuesta.candidatos.map((c) => c.plaga.id),
        ['procesionaria_pino', 'ips_sexdentatus', 'tomicus_minor']);
    expect(propuesta.fueraDelCatalogo, isTrue);
    expect(propuesta.hayUrticante, isTrue);
    expect(propuesta.hayPrioritaria, isFalse);
    expect(propuesta.observaciones, 'Copa seca');
    expect(propuesta.queComprobar, 'Mira bajo la corteza');
    final vacia = interpretarPlaga({}, 'pinus_sylvestris');
    expect(vacia.legible, isFalse);
    expect(vacia.candidatos, isEmpty);
    expect(interpretarPlaga({'candidatos': 'no es lista'}, null).candidatos,
        isEmpty);
  });

  test('el nematodo del pino activa el aviso de plaga prioritaria', () {
    final propuesta = interpretarPlaga({
      'legible': true,
      'candidatos': [
        {'id': 'nematodo_pino', 'confianza': 'baja', 'motivo': 'seca súbita'}
      ],
    }, 'pinus_pinaster');
    expect(propuesta.hayPrioritaria, isTrue);
  });

  test('el prompt prohíbe recomendar tratamientos', () {
    for (final especie in [null, 'pinus_sylvestris', 'castanea_sativa']) {
      final prompt = sistemaPlaga(especie);
      expect(prompt, contains('Nunca recomiendes productos'));
      expect(prompt.toLowerCase(), isNot(contains('dosis recomendada')));
    }
    expect(sistemaPlaga('castanea_sativa'), contains('Castaño'));
  });

  testWidgets('el diálogo enseña el aviso de plaga prioritaria',
      (tester) async {
    final propuesta = interpretarPlaga({
      'legible': true,
      'candidatos': [
        {'id': 'nematodo_pino', 'confianza': 'media', 'motivo': 'x'}
      ],
    }, 'pinus_pinaster');
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => mostrarPropuestaPlaga(context, propuesta),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(
        find.text(SoleraL10n.t('mont.ia_aviso_prioritaria')), findsOneWidget);
    expect(find.text(SoleraL10n.t('mont.ia_revisa_plaga')), findsOneWidget);
  });
}
