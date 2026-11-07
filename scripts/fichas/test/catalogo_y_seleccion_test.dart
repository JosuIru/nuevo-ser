import 'dart:io';

import 'package:fichas_imprimibles/fichas_imprimibles.dart';
import 'package:test/test.dart';

const _jsonMinimo = '''
{
  "domains": {"FR": "Fracciones", "DEC": "Decimales"},
  "skills": [
    {"id": "FR.10", "name": "Simplificar fracción", "domain": "FR", "course": "5P"},
    {"id": "FR.11", "name": "Amplificar fracción", "domain": "FR", "course": "5P"},
    {"id": "DEC.02", "name": "Comparar decimales", "domain": "DEC", "course": "4P"},
    {"id": "FR.99", "name": "Habilidad sin plantilla", "domain": "FR"}
  ]
}
''';

void main() {
  group('lectura de skills.json', () {
    test('lee habilidades, dominios y curso', () {
      final catalogo = CatalogoHabilidades.desdeJson(_jsonMinimo);
      expect(catalogo.habilidades, hasLength(4));
      expect(catalogo.porId('fr.10')!.nombre, 'Simplificar fracción');
      expect(catalogo.porId('DEC.02')!.curso, '4P');
      expect(catalogo.nombreDominio('DEC'), 'Decimales');
      expect(catalogo.porId('XX.01'), isNull);
    });

    test('el skills.json real de Uno Roto se lee entero', () {
      final raiz = localizarRaizPaquete()!;
      final catalogo = cargarCatalogo(rutaSkillsPorDefecto(raiz));
      expect(catalogo.habilidades.length, greaterThanOrEqualTo(100));
      expect(catalogo.porId('FR.01'), isNotNull);
      expect(catalogo.nombresDominio.keys, containsAll(['FR', 'DEC', 'PROP']));
    });

    test('toda plantilla corresponde a una habilidad real', () {
      final catalogo = cargarCatalogo(rutaSkillsPorDefecto(localizarRaizPaquete()!));
      for (final id in plantillasPorHabilidad.keys) {
        expect(catalogo.porId(id), isNotNull, reason: 'plantilla huérfana $id');
      }
      for (final id in motivosSinPlantilla.keys) {
        expect(catalogo.porId(id), isNotNull, reason: 'motivo huérfano $id');
        expect(plantillasPorHabilidad.containsKey(id), isFalse, reason: '$id: plantilla y motivo a la vez');
      }
    });
  });

  group('selección por id y dominio', () {
    final catalogo = CatalogoHabilidades.desdeJson(_jsonMinimo);

    test('por id, en el orden pedido y sin repetir', () {
      final resultado =
          seleccionarHabilidades(catalogo, ids: ['FR.11', 'fr.10', 'FR.11']);
      expect(resultado.conFicha.map((h) => h.id), ['FR.11', 'FR.10']);
      expect(resultado.saltadas, isEmpty);
    });

    test('por dominio salta las que no tienen plantilla', () {
      final resultado = seleccionarHabilidades(catalogo, dominios: ['fr']);
      expect(resultado.conFicha.map((h) => h.id), ['FR.10', 'FR.11']);
      expect(resultado.saltadas.map((s) => s.id), ['FR.99']);
    });

    test('ids y dominios desconocidos van a saltadas', () {
      final resultado =
          seleccionarHabilidades(catalogo, ids: ['ZZ.01'], dominios: ['NADA']);
      expect(resultado.conFicha, isEmpty);
      expect(resultado.saltadas.map((s) => s.id), containsAll(['ZZ.01', 'NADA']));
    });

    test('ids y dominio combinados', () {
      final resultado =
          seleccionarHabilidades(catalogo, ids: ['DEC.02'], dominios: ['FR']);
      expect(resultado.conFicha.map((h) => h.id), ['DEC.02', 'FR.10', 'FR.11']);
    });
  });

  test('localiza el paquete desde la raíz del monorepo', () {
    final raiz = localizarRaizPaquete()!;
    final desdeMonorepo = localizarRaizPaquete(Directory('${raiz.path}/../..'));
    expect(desdeMonorepo, isNotNull);
    expect(File('${desdeMonorepo!.path}/fuentes/Roboto-Regular.ttf').existsSync(), isTrue);
  });
}
