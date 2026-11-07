import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_vivero/datos/catalogos_generados/catalogo_especies.dart';
import 'package:solera_vivero/datos/catalogos_generados/catalogo_fitosanitarios.dart';
import 'package:solera_vivero/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_vivero/datos/catalogos_generados/catalogo_plagas_reguladas.dart';
import 'package:solera_vivero/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_vivero/dominio/catalogos.dart';

void main() {
  void idsUnicos(Iterable<String> ids, String catalogo) {
    final vistos = <String>{};
    for (final id in ids) {
      expect(vistos.add(id), isTrue, reason: '$catalogo: $id repetido');
    }
  }

  const gruposFitosanitarios = {
    'ornamental_herbacea',
    'ornamental_lenosa',
    'pino',
    'tomate',
    'pimiento',
    'lechuga',
  };

  test('ids únicos y que no se pisan entre plagas comunes y reguladas', () {
    idsUnicos(catalogoEspecies.map((fila) => fila.id), 'especies');
    idsUnicos(catalogoSustanciasActivas.map((fila) => fila.id), 'sustancias');
    idsUnicos([
      ...catalogoPlagas.map((p) => p.id),
      ...catalogoPlagasReguladas.map((p) => p.id)
    ], 'plagas');
  });

  test('especies: nombre botánico, pasaporte de planta y referencias', () {
    final reguladas = catalogoPlagasReguladas.map((p) => p.id).toSet();
    for (final especie in catalogoEspecies) {
      expect(especie.nombreBotanico, isNotEmpty, reason: especie.id);
      // Anexo XIII, punto 1: todo vegetal para plantación salvo semillas.
      expect(especie.plantaPasaporte, isTrue, reason: especie.id);
      expect(especie.semillaPasaporte, isNotNull, reason: especie.id);
      expect([
        'horticola',
        'forestal',
        'frutal',
        'ornamental'
      ], contains(especie.grupo), reason: especie.id);
      expect(
          especie.grupoFitosanitario.isEmpty ||
              gruposFitosanitarios.contains(especie.grupoFitosanitario),
          isTrue,
          reason: especie.id);
      expect(reguladas.containsAll(especie.plagasReguladas), isTrue,
          reason: especie.id);
    }
    // Anexo XIV: Quercus salvo Q. suber.
    expect(especiePorId('encina')?.anexoXivZonaProtegida, isTrue);
    expect(especiePorId('alcornoque')?.anexoXivZonaProtegida, isNull);
    expect(especiePorId('tomate')?.semillaPasaporte, isTrue);
    expect(especiePorId('lechuga')?.semillaPasaporte, isFalse);
  });

  test('plagas reguladas: categoría válida y con huéspedes', () {
    for (final plaga in catalogoPlagasReguladas) {
      expect(['prioritaria', 'rnqp'], contains(plaga.categoria),
          reason: plaga.id);
      expect(plaga.generos, isNotEmpty, reason: plaga.id);
    }
  });

  test('fitosanitarios: usos con grupo y plaga existentes', () {
    final plagas = catalogoPlagas.map((p) => p.id).toSet();
    for (final sustancia in catalogoSustanciasActivas) {
      expect(sustancia.usos, isNotEmpty, reason: sustancia.id);
      for (final uso in sustancia.usos) {
        final [grupo, plaga] = uso.split(':');
        expect(gruposFitosanitarios, contains(grupo),
            reason: '${sustancia.id} $uso');
        expect(plagas, contains(plaga), reason: '${sustancia.id} $uso');
      }
    }
  });

  test('fitosanitarios: sin retiradas conocidas, sin plazos 0 y aprobadas', () {
    // Retiradas en la UE (EU Pesticides DB, 07/11/2026): no pueden aparecer.
    const retiradas = [
      'mancozeb',
      'dimetomorf',
      'miclobutanil',
      'clorpirifos',
      'dimetoato',
      'tiacloprid',
      'imidacloprid',
      'tiametoxam',
      'clotianidina',
      'metiocarb',
      'clorotalonil',
      'iprodiona',
      'tiram',
      'metiram',
    ];
    for (final sustancia in catalogoSustanciasActivas) {
      for (final retirada in retiradas) {
        expect(sustancia.id.contains(retirada), isFalse,
            reason: '${sustancia.id} contiene $retirada');
      }
      expect(sustancia.plazoSeguridadMaximoDias, isNot(0),
          reason: sustancia.id);
      expect(sustancia.estadoUe, startsWith('aprobada'), reason: sustancia.id);
    }
  });

  test('ninguna fila finge una firma humana y el banner sigue', () {
    for (final fichero in Directory('../../content/vivero')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.csv'))) {
      for (final linea in fichero.readAsLinesSync()) {
        if (linea.startsWith('#')) continue;
        expect(RegExp(r',"?\s*(asesor|persona):').hasMatch(linea), isFalse,
            reason: '${fichero.path}: $linea');
      }
    }
    expect(catalogosCompletamenteRevisados, isFalse);
  });

  test('consultas: plagas y sustancias por grupo de la especie', () {
    final plagasPino = opcionesPlagas('pino_resinero').map((o) => o.id);
    expect(plagasPino, contains('procesionaria'));
    expect(plagasPino, isNot(contains('tuta_absoluta')));
    expect(opcionesPlagas(null), hasLength(catalogoPlagas.length));
    final sustanciasTomate =
        opcionesSustancias('tomate', plagaId: 'tuta_absoluta');
    final primera = sustanciaPorId(sustanciasTomate.first.id)!;
    expect(primera.usos, contains('tomate:tuta_absoluta'));
    expect(
        usoAutorizado(
            especieId: 'tomate',
            sustanciaId: primera.id,
            plagaId: 'tuta_absoluta'),
        isTrue);
    expect(
        usoAutorizado(
            especieId: 'castano', sustanciaId: primera.id, plagaId: 'pulgones'),
        isNull,
        reason: 'el castaño no tiene grupo cruzado');
  });

  test('plagas reguladas por nombre botánico', () {
    final xylella = plagaReguladaPorId('xylella_fastidiosa')!;
    expect(plagaReguladaAfecta(xylella, 'Olea europaea'), isTrue);
    expect(plagaReguladaAfecta(xylella, 'Oleaster'), isFalse);
    expect(plagaReguladaAfecta(xylella, ''), isFalse);
    final opciones = opcionesPlagasReguladas(nombreBotanico: 'Castanea sativa')
        .map((o) => o.id);
    expect(opciones.first, 'cryphonectria_parasitica');
    expect(nombrePlaga('cryphonectria_parasitica'), contains('Cryphonectria'));
    expect(nombrePlaga('texto libre'), 'texto libre');
  });

  test('texto → id del catálogo o texto libre', () {
    expect(idDesdeTexto(' castaño ', opcionesEspecies()), 'castano');
    expect(idDesdeTexto('Planta rara', opcionesEspecies()), 'Planta rara');
    expect(nombreEspecie('castano'), 'Castaño');
  });
}
