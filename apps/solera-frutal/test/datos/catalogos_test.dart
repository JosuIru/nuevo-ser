import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_frutal/datos/catalogos_generados/catalogo_especies.dart';
import 'package:solera_frutal/datos/catalogos_generados/catalogo_fenologia.dart';
import 'package:solera_frutal/datos/catalogos_generados/catalogo_fitosanitarios.dart';
import 'package:solera_frutal/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_frutal/datos/catalogos_generados/catalogo_variedades.dart';
import 'package:solera_frutal/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_frutal/dominio/avisos_helada.dart';
import 'package:solera_frutal/dominio/catalogos.dart';
import 'package:solera_frutal/dominio/polinizacion.dart';
import 'package:solera_frutal/modelos/parcela.dart';

void main() {
  void idsUnicos(Iterable<String> ids, String catalogo) {
    final vistos = <String>{};
    for (final id in ids) {
      expect(vistos.add(id), isTrue, reason: '$catalogo: $id repetido');
    }
  }

  test('ids únicos en los cinco catálogos', () {
    idsUnicos(catalogoEspecies.map((fila) => fila.id), 'especies');
    idsUnicos(catalogoVariedades.map((fila) => fila.id), 'variedades');
    idsUnicos(catalogoPlagas.map((fila) => fila.id), 'plagas');
    idsUnicos(catalogoSustanciasActivas.map((fila) => fila.id), 'sustancias');
    idsUnicos(catalogoFenologia.map((fila) => fila.id), 'fenología');
  });

  test('las especies del catálogo son las del código', () {
    expect(
        catalogoEspecies.map((especie) => especie.id).toList(), especiesFrutal);
  });

  test('integridad referencial: especies, plagas y polinizadoras', () {
    final especies = especiesFrutal.toSet();
    final plagas = {for (final plaga in catalogoPlagas) plaga.id: plaga};
    final variedades = catalogoVariedades.map((v) => v.id).toSet();
    for (final variedad in catalogoVariedades) {
      expect(especies, contains(variedad.especieId), reason: variedad.id);
      expect(
          variedad.floracion.isEmpty ||
              epocasFloracion.contains(variedad.floracion),
          isTrue,
          reason: variedad.id);
      expect(variedades.containsAll(variedad.polinizadorasHabituales), isTrue,
          reason: variedad.id);
    }
    for (final plaga in catalogoPlagas) {
      expect(especies.containsAll(plaga.especies), isTrue, reason: plaga.id);
    }
    for (final sustancia in catalogoSustanciasActivas) {
      expect(sustancia.usos, isNotEmpty, reason: sustancia.id);
      for (final uso in sustancia.usos) {
        final [especie, plaga] = uso.split(':');
        expect(especies, contains(especie), reason: '${sustancia.id} $uso');
        expect(plagas[plaga]?.especies, contains(especie),
            reason: '${sustancia.id} $uso');
      }
    }
    for (final estado in catalogoFenologia) {
      expect(especies, contains(estado.especieId), reason: estado.id);
      expect(estado.mesInicio, inInclusiveRange(1, 12), reason: estado.id);
      expect(estado.mesFin, inInclusiveRange(1, 12), reason: estado.id);
    }
  });

  test('fitosanitarios: sin marcas, sin retiradas conocidas y con plazos', () {
    // Retiradas en la UE (EU Pesticides DB, 07/11/2026) que no pueden aparecer.
    const retiradas = [
      'mancozeb',
      'dimetomorf',
      'miclobutanil',
      'clorpirifos',
      'dimetoato',
      'tiacloprid',
      'imidacloprid',
      'fosmet',
      'zeta_cipermetrin',
      'indoxacarb',
      'ciproconazol',
      'tiofanato',
      'clorotalonil',
      'iprodiona',
      'tiram',
      'metiram',
      'propineb',
      'espirotetramat',
      'metoxifenozida',
    ];
    for (final sustancia in catalogoSustanciasActivas) {
      for (final retirada in retiradas) {
        expect(sustancia.id, isNot(contains(retirada)));
      }
      expect(sustancia.estadoUe, startsWith('aprobada'), reason: sustancia.id);
      expect(sustancia.plazoSeguridadRegistro, isNotEmpty,
          reason: sustancia.id);
      expect(sustancia.plazoSeguridadMaximoDias ?? 1, greaterThan(0),
          reason: 'un plazo de 0 días no sale del registro: ${sustancia.id}');
    }
    // Lo que la ficha nombra: gusano cabezudo solo con acetamiprid.
    expect(
        opcionesSustancias('almendro', plagaId: 'capnodis_tenebrionis')
            .first
            .id,
        'acetamiprid');
  });

  test('las revisiones son documentales o de IA, nunca firmas falsas', () {
    final contenido = Directory('../../content/frutal')
        .listSync()
        .whereType<File>()
        .where((fichero) => fichero.path.endsWith('.csv'))
        .map((fichero) => fichero.readAsStringSync())
        .join('\n');
    expect(contenido, isNot(contains(',asesor:')));
    expect(contenido, isNot(contains(',persona:')));
    expect(contenido, isNot(contains('"asesor:')));
    expect(contenido, isNot(contains('"persona:')));
    expect(catalogosCompletamenteRevisados, isFalse);
  });

  test('consultas: nombres, ids desde texto y usos', () {
    expect(nombrePlaga('balanino_avellano'), 'Balanino o diablo del avellano');
    expect(nombrePlaga('malas hierbas'), 'malas hierbas');
    expect(idDesdeTexto('guara', opcionesVariedades('almendro')), 'guara');
    expect(idDesdeTexto(' GUARA ', opcionesVariedades('almendro')), 'guara');
    expect(idDesdeTexto('Mi variedad', opcionesVariedades('almendro')),
        'Mi variedad');
    expect(usoRegistrado('acetamiprid', 'almendro', 'capnodis_tenebrionis'),
        isTrue);
    expect(
        usoRegistrado('acetamiprid', 'avellano', 'balanino_avellano'), isFalse);
    expect(usoRegistrado('inventada', 'almendro', 'monilia'), isNull);
    expect(opcionesPlagas('avellano').map((opcion) => opcion.id),
        contains('eriofido_avellano'));
  });

  test('polinización con el catálogo: sin grupos, nunca «cubierta»', () {
    final resultados = evaluarPolinizacion(
        variedadesEnParcela: ['ferragnes', 'ferraduel', 'guara'],
        catalogo: datosPolinizacionCatalogo());
    final porVariedad = {
      for (final resultado in resultados) resultado.variedadId: resultado.estado
    };
    expect(porVariedad['guara'], EstadoPolinizacion.autocompatible);
    expect(porVariedad['ferragnes'], EstadoPolinizacion.porConfirmar);
  });

  test('fenología: meses que cruzan el año y avisos de helada', () {
    expect(mesEnIntervalo(12, 11, 1), isTrue);
    expect(mesEnIntervalo(6, 11, 1), isFalse);
    expect(mesEnIntervalo(3, 2, 4), isTrue);
    final almendro = Parcela(id: 1, nombre: 'Loma', especieId: 'almendro');
    final castano = Parcela(id: 2, nombre: 'Souto', especieId: 'castano');
    final avisos = calcularAvisosHelada(parcelas: [
      almendro,
      castano
    ], prevision: [
      (fecha: DateTime(2027, 3, 1), minimaC: -1.5),
      (fecha: DateTime(2027, 3, 2), minimaC: 6),
      (fecha: DateTime(2027, 3, 3), minimaC: null),
      (fecha: DateTime(2027, 8, 1), minimaC: -3),
    ]);
    expect(avisos, hasLength(1));
    expect(avisos.single.parcela.nombre, 'Loma');
    expect(avisos.single.estados, isNotEmpty);
  });
}
