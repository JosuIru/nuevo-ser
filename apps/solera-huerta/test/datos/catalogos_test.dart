// Integridad de los catálogos de content/huerta/ ya compilados.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_cultivos.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_insumos.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_huerta/datos/catalogos_generados/catalogo_rotacion.dart';
import 'package:solera_huerta/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_huerta/dominio/catalogos.dart';
import 'package:solera_huerta/dominio/rotacion.dart';

void main() {
  final familias = {for (final familia in catalogoRotacion) familia.familiaId};

  void sinRepetidos(Iterable<String> ids) =>
      expect(ids.toSet(), hasLength(ids.length), reason: 'ids repetidos');

  /// Solo valen fuente pública o revisión con registro; nunca la firma
  /// humana (asesor:/persona:), que no puede ponerla un agente.
  void revisionValida(String revisadoPor) {
    expect(
        revisadoPor.startsWith('asesor:') || revisadoPor.startsWith('persona:'),
        isFalse,
        reason: 'firma humana fingida: $revisadoPor');
    if (revisadoPor.isNotEmpty) {
      expect(
          revisadoPor.startsWith('fuente_publica:') ||
              revisadoPor.startsWith('revision-ia:'),
          isTrue,
          reason: revisadoPor);
    }
  }

  test('hay datos en los cuatro catálogos', () {
    expect(catalogoCultivos.length, greaterThan(20));
    expect(catalogoRotacion.length, greaterThan(8));
    expect(catalogoCategoriasInsumo.length, greaterThan(20));
    expect(catalogoPlagas.length, greaterThan(15));
  });

  test('ids únicos', () {
    sinRepetidos(catalogoCultivos.map((cultivo) => cultivo.id));
    sinRepetidos(catalogoRotacion.map((familia) => familia.familiaId));
    sinRepetidos(catalogoCategoriasInsumo.map((categoria) => categoria.id));
    sinRepetidos(catalogoPlagas.map((plaga) => plaga.id));
  });

  test('cada cultivo apunta a una familia de la rotación', () {
    for (final cultivo in catalogoCultivos) {
      expect(familias, contains(cultivo.familiaId), reason: cultivo.id);
    }
  });

  test('cada plaga apunta a familias de la rotación', () {
    for (final plaga in catalogoPlagas) {
      for (final familia in plaga.familias) {
        expect(familias, contains(familia), reason: plaga.id);
      }
      expect(['plaga', 'enfermedad', 'carencia'], contains(plaga.tipo),
          reason: plaga.id);
    }
  });

  test('las leguminosas existen con el id que usa la rotación', () {
    expect(familias, contains(familiaLeguminosas));
  });

  test('años mínimos y ciclos con sentido', () {
    for (final familia in catalogoRotacion) {
      expect(familia.aniosMinimos, isNotNull, reason: familia.familiaId);
      expect(familia.aniosMinimos, inInclusiveRange(0, 10));
    }
    for (final cultivo in catalogoCultivos) {
      if (cultivo.cicloDias != null) {
        expect(cultivo.cicloDias, inInclusiveRange(15, 400),
            reason: cultivo.id);
      }
      if (cultivo.semanasCosecha != null) {
        expect(cultivo.semanasCosecha, inInclusiveRange(1, 52),
            reason: cultivo.id);
      }
    }
  });

  test('categorías de insumo del anexo I (fitosanitarios) o II (fertilizantes)',
      () {
    for (final categoria in catalogoCategoriasInsumo) {
      expect((categoria.anexo, categoria.tipo),
          anyOf(equals(('I', 'fitosanitario')), equals(('II', 'fertilizante'))),
          reason: categoria.id);
    }
  });

  test('revisado_por: nunca firma humana fingida', () {
    for (final revisado in [
      ...catalogoCultivos.map((fila) => fila.revisadoPor),
      ...catalogoRotacion.map((fila) => fila.revisadoPor),
      ...catalogoCategoriasInsumo.map((fila) => fila.revisadoPor),
      ...catalogoPlagas.map((fila) => fila.revisadoPor),
    ]) {
      revisionValida(revisado);
    }
    expect(catalogosCompletamenteRevisados, isFalse,
        reason: 'solo la firma humana apaga el banner');
  });

  test('los catálogos no llevan marcas comerciales ni dosis', () {
    final contenido = [
      for (final fichero in Directory('../../content/huerta')
          .listSync()
          .whereType<File>()
          .where((fichero) => fichero.path.endsWith('.csv')))
        fichero.readAsStringSync()
    ].join('\n');
    expect(contenido, isNot(contains('®')));
    expect(contenido, isNot(contains('™')));
    for (final dosis in [RegExp(r'\d\s*(ml|cc|l)/hl'), RegExp(r'\d\s*l/ha')]) {
      expect(dosis.hasMatch(contenido), isFalse, reason: dosis.pattern);
    }
  });

  test('consultas: familia y ciclo desde la especie', () {
    expect(familiaDeEspecie('tomate'), 'solanaceas');
    expect(familiaDeEspecie('inventada'), '');
    expect(nombreEspecie('inventada'), 'inventada');
    expect(aniosMinimosPorFamilia()['solanaceas'], isNotNull);
    expect(
        opcionesPlagas(familiaId: 'solanaceas').first.id,
        isIn(catalogoPlagas
            .where((plaga) => plaga.familias.contains('solanaceas'))
            .map((plaga) => plaga.id)));
    expect(idDesdeTexto('TOMATE', opcionesEspecies()), 'tomate');
    expect(
        idDesdeTexto('Tomatillo raro', opcionesEspecies()), 'Tomatillo raro');
  });

  test('lechuga se reparte por piezas', () {
    expect(seRepartePorUnidades('lechuga'), isTrue);
    expect(seRepartePorUnidades('inventada'), isFalse);
  });
}
