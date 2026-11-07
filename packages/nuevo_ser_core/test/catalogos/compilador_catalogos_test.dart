import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/catalogos/compilador_catalogos.dart';

void main() {
  late Directory raiz;

  setUp(() async {
    raiz = await Directory.systemTemp.createTemp('catalogos_');
    await Directory('${raiz.path}/content/prueba').create(recursive: true);
    await Directory('${raiz.path}/apps/solera-prueba').create(recursive: true);
  });
  tearDown(() => raiz.delete(recursive: true));

  Future<CsvCatalogo> leer(String filas) async {
    await File('${raiz.path}/content/prueba/c.csv')
        .writeAsString('# comentario\nid,nombre,revisado_por\n$filas');
    final anterior = Directory.current;
    Directory.current = '${raiz.path}/apps/solera-prueba';
    try {
      return await CompiladorCatalogos(carpetaContent: 'prueba', carpetaApp: 'solera-prueba')
          .leer('c.csv');
    } finally {
      Directory.current = anterior;
    }
  }

  test('solo la firma de una persona cuenta como revisada', () {
    expect(esFirmaDePersona('asesor: Ana Pérez, col. 123'), isTrue);
    expect(esFirmaDePersona('  Persona: titular'), isTrue);
    for (final valor in ['fuente_publica', 'revision-ia: informe', 'MAPA 2026', '']) {
      expect(esFirmaDePersona(valor), isFalse, reason: valor);
    }
  });

  test('fuente pública o IA no apagan el banner', () async {
    final csv = await leer('1,a,fuente_publica\n2,b,revision-ia: x\n3,c,asesor: Ana\n');
    expect(csv.revisadas, 3);
    expect(csv.firmadas, 1);
    expect(csv.todasRevisadas, isFalse);
  });

  test('con todas las filas firmadas por persona, sí', () async {
    final csv = await leer('1,a,asesor: Ana\n2,b,persona: Josu\n');
    expect(csv.todasRevisadas, isTrue);
  });
}
