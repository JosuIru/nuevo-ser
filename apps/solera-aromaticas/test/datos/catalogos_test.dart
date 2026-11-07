import 'package:flutter_test/flutter_test.dart';
import 'package:solera_aromaticas/datos/catalogos_generados/catalogo_especies.dart';
import 'package:solera_aromaticas/datos/catalogos_generados/catalogo_plagas.dart';
import 'package:solera_aromaticas/datos/catalogos_generados/catalogo_rendimientos.dart';
import 'package:solera_aromaticas/datos/catalogos_generados/flag_revision.dart';
import 'package:solera_aromaticas/dominio/catalogos.dart';

void main() {
  final idsEspecies = {for (final especie in catalogoEspecies) especie.id};

  test('ids únicos en los tres catálogos', () {
    expect(idsEspecies, hasLength(catalogoEspecies.length));
    expect({for (final plaga in catalogoPlagas) plaga.id},
        hasLength(catalogoPlagas.length));
    expect({for (final fila in catalogoRendimientos) fila.id},
        hasLength(catalogoRendimientos.length));
  });

  test('integridad referencial: plagas, rendimientos y confundibles', () {
    for (final plaga in catalogoPlagas) {
      expect(plaga.especies, isNotEmpty, reason: plaga.id);
      for (final especie in plaga.especies) {
        expect(idsEspecies, contains(especie), reason: plaga.id);
      }
    }
    for (final rendimiento in catalogoRendimientos) {
      expect(idsEspecies, contains(rendimiento.especieId),
          reason: rendimiento.id);
    }
    for (final especie in catalogoEspecies) {
      for (final confundible in especie.confundibles) {
        // Un id corto en minúsculas tiene que existir; si no, es una
        // descripción libre (lleva espacios o mayúsculas).
        if (RegExp(r'^[a-z_]+$').hasMatch(confundible)) {
          expect(idsEspecies, contains(confundible), reason: especie.id);
        }
      }
    }
  });

  test('valores cerrados y rangos coherentes', () {
    for (final especie in catalogoEspecies) {
      expect(['cultivo', 'silvestre', 'ambos'], contains(especie.origen),
          reason: especie.id);
      expect(['', 'anexo_vi_ley_42_2007'], contains(especie.proteccion),
          reason: especie.id);
      for (final mes in [especie.mesInicio, especie.mesFin]) {
        if (mes != null) expect(mes, inInclusiveRange(1, 12));
      }
    }
    for (final rendimiento in catalogoRendimientos) {
      expect(
          ['aceite_esencial', 'planta_seca'], contains(rendimiento.producto));
      expect(['fresca', 'seca'], contains(rendimiento.estadoPlanta));
      expect(rendimiento.minimo, isNotNull);
      expect(rendimiento.minimo!, lessThanOrEqualTo(rendimiento.maximo!),
          reason: rendimiento.id);
      expect(rendimiento.fuente, isNotEmpty, reason: rendimiento.id);
    }
    for (final plaga in catalogoPlagas) {
      expect(['plaga', 'enfermedad', 'fisiopatia', 'vector'],
          contains(plaga.tipo));
    }
  });

  test('las protegidas no tienen época: la app no anima a recolectarlas', () {
    final protegidas = [
      for (final especie in catalogoEspecies)
        if (especie.proteccion.isNotEmpty) especie
    ];
    expect(protegidas.map((especie) => especie.id),
        containsAll(['genciana', 'arnica']));
    for (final especie in protegidas) {
      expect((especie.mesInicio, especie.mesFin), (null, null));
      expect(especie.notaProteccion, isNotEmpty);
      expect(especieConProteccion(especie.id), isTrue);
    }
    expect(especieConProteccion('romero'), isFalse);
    expect(opcionesEspecies(soloSilvestres: true).last.id,
        anyOf('genciana', 'arnica'),
        reason: 'las protegidas van al final de la lista');
  });

  test('ningún revisado_por finge una firma humana; el flag sigue en false',
      () {
    final revisiones = [
      for (final especie in catalogoEspecies) especie.revisadoPor,
      for (final plaga in catalogoPlagas) plaga.revisadoPor,
      for (final fila in catalogoRendimientos) fila.revisadoPor,
    ];
    for (final revision in revisiones) {
      expect(revision.toLowerCase(),
          isNot(anyOf(startsWith('asesor:'), startsWith('persona:'))));
    }
    expect(catalogosCompletamenteRevisados, isFalse);
  });

  test('consultas: nombres, rendimiento orientativo, época y texto libre', () {
    expect(nombreEspecie('lavandin'), 'Lavandín');
    expect(nombreEspecie('algo raro'), 'algo raro');
    expect(
        rendimientoOrientativo('romero', producto: 'aceite_esencial')!.maximo,
        6);
    expect(
        rendimientoOrientativo('oregano',
                producto: 'aceite_esencial', estadoPlanta: 'seca')!
            .minimo,
        2);
    expect(
        rendimientoOrientativo('lavanda', producto: 'aceite_esencial'), isNull);
    expect(opcionesPlagas('lavandin').map((plaga) => plaga.id),
        contains('decaimiento_stolbur'));
    expect(
        especiesEnEpoca(['lavanda', 'romero', 'genciana'], 7)
            .map((especie) => especie.id),
        ['lavanda']);
    expect(mesEnIntervalo(1, 11, 2), isTrue);
    expect(idDesdeTexto('lavandín', opcionesEspecies()), 'lavandin');
    expect(idDesdeTexto('Poleo', opcionesEspecies()), 'Poleo');
    expect(nombreConfundible('lavanda'), 'Lavanda');
  });
}
