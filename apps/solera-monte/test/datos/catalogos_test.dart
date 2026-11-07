import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_monte/datos/catalogos_generados/catalogo_especies.dart';
import 'package:solera_monte/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_monte/datos/catalogos_generados/catalogo_unidades.dart';
import 'package:solera_monte/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_monte/dominio/catalogos.dart';
import 'package:solera_monte/modelos/aprovechamiento.dart';

void main() {
  final idsEspecies = {for (final especie in catalogoEspecies) especie.id};
  final generosEspecies = {for (final id in idsEspecies) generoDe(id)};

  test('ids únicos en los tres catálogos, y códigos IFN únicos', () {
    expect(idsEspecies, hasLength(catalogoEspecies.length));
    expect({for (final e in catalogoEspecies) e.codigoIfn},
        hasLength(catalogoEspecies.length));
    expect({for (final p in catalogoPlagas) p.id},
        hasLength(catalogoPlagas.length));
    expect({for (final u in catalogoUnidades) u.id},
        hasLength(catalogoUnidades.length));
  });

  test('el id de cada especie es su nombre científico en minúsculas', () {
    for (final especie in catalogoEspecies) {
      final esperado =
          especie.nombreCientifico.toLowerCase().split(' ').take(2).join('_');
      expect(especie.id, esperado, reason: especie.nombreCientifico);
      expect(['conifera', 'frondosa'], contains(especie.grupo));
      expect(especie.codigoIfn, matches(RegExp(r'^\d{3}$')));
    }
  });

  test('integridad referencial: cada plaga llega a alguna especie', () {
    for (final plaga in catalogoPlagas) {
      for (final especie in plaga.especies) {
        expect(idsEspecies, contains(especie), reason: plaga.id);
      }
      expect(
          plaga.especies.isNotEmpty ||
              plaga.generos.any(generosEspecies.contains),
          isTrue,
          reason: plaga.id);
      for (final genero in plaga.generos) {
        expect(genero, matches(RegExp(r'^[a-z]+$')), reason: plaga.id);
      }
      expect([
        'defoliador',
        'perforador',
        'gallicola',
        'carpofago',
        'hongo',
        'oomiceto',
        'nematodo'
      ], contains(plaga.grupo), reason: plaga.id);
      expect(['', 'urticante', 'prioritaria_ue'], contains(plaga.aviso));
      expect(plaga.revisadoPor, isNotEmpty, reason: plaga.id);
    }
  });

  test('las unidades del catálogo son las del aprovechamiento', () {
    for (final unidad in catalogoUnidades) {
      expect(unidadesAprovechamiento, contains(unidad.id));
    }
    expect(m3PorEstereo, 0.65);
    expect(aMetrosCubicos(10, 'estereos'), closeTo(6.5, 1e-9));
    expect(aMetrosCubicos(10, 'm3'), 10);
    expect(aMetrosCubicos(10, 'toneladas'), isNull);
  });

  test('consultas: nombres, género, plagas de una especie', () {
    expect(nombreEspecie('fagus_sylvatica'), 'Haya');
    expect(nombreEspecie('texto libre'), 'texto libre');
    expect(generoDe('pinus_sylvestris'), 'pinus');
    final delPino = plagasDeEspecies(['pinus_sylvestris']).map((p) => p.id);
    expect(delPino, containsAll(['procesionaria_pino', 'ips_acuminatus']));
    expect(delPino.first, 'nematodo_pino',
        reason: 'la plaga prioritaria de la UE va primero');
    expect(delPino, isNot(contains('chancro_castano')));
    expect(plagasDeEspecies(['castanea_sativa']).map((p) => p.id),
        contains('avispilla_castano'));
    expect(opcionesEspecies(), hasLength(catalogoEspecies.length));
  });

  test('sin sustancias activas ni marcas en el catálogo de plagas', () {
    final texto =
        File('../../content/monte/plagas_forestales.csv').readAsStringSync();
    final cabecera =
        texto.split('\n').firstWhere((linea) => linea.startsWith('id,'));
    expect(cabecera, isNot(contains('sustancia')));
    expect(cabecera, isNot(contains('dosis')));
  });

  test('ninguna fila lleva una firma humana falsa', () {
    final firmas = [
      ...catalogoEspecies.map((e) => e.revisadoPor),
      ...catalogoPlagas.map((p) => p.revisadoPor),
      ...catalogoUnidades.map((u) => u.revisadoPor),
    ];
    for (final firma in firmas) {
      expect(
          firma.startsWith('asesor:') || firma.startsWith('persona:'), isFalse);
    }
    expect(catalogosCompletamenteRevisados, isFalse);
  });
}
