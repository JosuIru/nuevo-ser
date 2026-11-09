import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aromaticas/datos/catalogos_generados/catalogo_especies.dart';
import 'package:solera_aromaticas/datos/catalogos_generados/catalogo_guia.dart';
import 'package:solera_aromaticas/dominio/catalogos.dart';
import 'package:solera_aromaticas/dominio/guia.dart';
import 'package:solera_aromaticas/servicios/fotos_wikipedia.dart';

void main() {
  test('cada especie del catálogo tiene su ficha en la guía, y al revés', () {
    final idsEspecies = {for (final especie in catalogoEspecies) especie.id};
    final idsGuia = {for (final ficha in catalogoGuia) ficha.id};
    expect(idsGuia, hasLength(catalogoGuia.length), reason: 'ids repetidos');
    expect(idsGuia, idsEspecies);
  });

  test('cada ficha trae rasgos, hábitat y artículo de Wikipedia', () {
    for (final ficha in catalogoGuia) {
      expect(ficha.rasgos.length, greaterThanOrEqualTo(2), reason: ficha.id);
      expect(ficha.habitat, isNotEmpty, reason: ficha.id);
      expect(ficha.tituloWikipedia, isNotEmpty, reason: ficha.id);
    }
  });

  test('la guía no se da por revisada: ninguna fila firmada', () {
    for (final ficha in catalogoGuia) {
      expect(ficha.revisadoPor.startsWith('asesor:'), isFalse);
      expect(ficha.revisadoPor.startsWith('persona:'), isFalse);
    }
  });

  test('las confundibles de seguridad se explican en los rasgos', () {
    // Genciana/vedegambre e hinojo/cicuta: el aviso de seguridad tiene que
    // estar también en «cómo reconocerla».
    expect(fichaGuiaDe('genciana')!.rasgos.join(' '), contains('Veratrum'));
    expect(fichaGuiaDe('hinojo')!.rasgos.join(' '), contains('cicuta'));
  });

  test('agrupa por familia y busca sin acentos ni mayúsculas', () {
    final todo = guiaPorFamilia();
    expect(todo.fold<int>(0, (suma, grupo) => suma + grupo.entradas.length),
        catalogoEspecies.length);
    expect(todo.map((grupo) => grupo.familia),
        orderedEquals([...todo.map((grupo) => grupo.familia)]..sort()));

    final porNombre = guiaPorFamilia(consulta: 'LAVANDIN');
    expect(porNombre.single.entradas.single.especie.id, 'lavandin');

    final porCientifico = guiaPorFamilia(consulta: 'thymus');
    expect(porCientifico.single.entradas.map((e) => e.especie.id),
        containsAll(['tomillo_comun', 'tomillo_salsero', 'tomillo_blanco']));

    final porRasgo = guiaPorFamilia(consulta: 'olor a limon');
    expect(porRasgo.expand((grupo) => grupo.entradas).map((e) => e.especie.id),
        containsAll(['melisa', 'hierba_luisa']));

    expect(guiaPorFamilia(consulta: 'zzz'), isEmpty);
  });

  test('título de Wikipedia: el de la ficha o el nombre científico limpio', () {
    expect(tituloWikipediaDe(especiePorId('romero')!), 'Salvia rosmarinus');
  });

  test('las fotos descartan mapas, logos y vectoriales', () {
    expect(esFotoUtil('https://upload.wikimedia.org/a/b/Lavanda.jpg'), isTrue);
    expect(esFotoUtil('https://upload.wikimedia.org/a/b/Commons-logo.svg'),
        isFalse);
    expect(
        esFotoUtil('https://upload.wikimedia.org/a/b/Thymus_distribution.png'),
        isFalse);
  });
}
