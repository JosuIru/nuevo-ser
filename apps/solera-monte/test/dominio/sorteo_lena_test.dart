import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solera_monte/dominio/sorteo_lena.dart';

void main() {
  const casas = [
    'Casa Juana',
    'Casa Pello',
    'Casa Miren',
    'Casa Txomin',
    'Casa Arantza',
  ];

  test('la clave es SHA-256 de «semilla|participante», comprobable a mano', () {
    // echo -n "2026-11-07|Casa Juana" | sha256sum
    expect(claveSorteo('2026-11-07', '  Casa   Juana '),
        sha256.convert(utf8.encode('2026-11-07|Casa Juana')).toString());
    expect(claveSorteo('a', 'b'), hasLength(64));
    // Vector conocido de SHA-256 («abc»), para que nadie dude del algoritmo.
    expect(sha256.convert(utf8.encode('abc')).toString(),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });

  test(
      'misma semilla y misma lista: mismo resultado, en cualquier orden de '
      'entrada', () {
    final primero = sortear(
        semilla: 'Loteria 22-12-2026: 04211',
        participantes: casas,
        numerosLote: [1, 2, 3, 4, 5]);
    final segundo = sortear(
        semilla: 'Loteria 22-12-2026: 04211',
        participantes: casas.reversed.toList(),
        numerosLote: [5, 4, 3, 2, 1]);
    expect(segundo.adjudicacionPorLote, primero.adjudicacionPorLote);
    expect(primero.adjudicados, hasLength(5));
    expect(primero.adjudicacionPorLote.values.toSet(), casas.toSet());
  });

  test('otra semilla cambia el orden', () {
    final conUna = sortear(
        semilla: 'una', participantes: casas, numerosLote: [1, 2, 3, 4, 5]);
    final conOtra = sortear(
        semilla: 'otra', participantes: casas, numerosLote: [1, 2, 3, 4, 5]);
    expect(conOtra.adjudicacionPorLote, isNot(conUna.adjudicacionPorLote));
  });

  test('el orden es el de las claves de menor a mayor', () {
    final resultado = sortear(
        semilla: 'S', participantes: casas, numerosLote: [1, 2, 3, 4, 5]);
    final claves = resultado.orden.map((puesto) => puesto.clave).toList();
    expect(claves, [...claves]..sort());
    expect(resultado.orden.first.numeroLote, 1);
    expect(resultado.orden.map((p) => p.posicion), [1, 2, 3, 4, 5]);
  });

  test('más participantes que lotes: lista de espera en orden', () {
    final resultado =
        sortear(semilla: 'S', participantes: casas, numerosLote: [7, 3]);
    expect(resultado.adjudicados.map((p) => p.numeroLote), [3, 7]);
    expect(resultado.listaEspera, hasLength(3));
    expect(resultado.listaEspera.first.posicion, 3);
    expect(resultado.lotesSinAdjudicar, isEmpty);
  });

  test('más lotes que participantes: los últimos quedan sin adjudicar', () {
    final resultado = sortear(
        semilla: 'S',
        participantes: casas.take(2).toList(),
        numerosLote: [1, 2, 3, 4]);
    expect(resultado.lotesSinAdjudicar, [3, 4]);
    expect(resultado.listaEspera, isEmpty);
  });

  test('sin semilla, sin lista, sin lotes o con repetidos no se sortea', () {
    Matcher error(ErrorSorteo tipo) =>
        throwsA(isA<SorteoNoValido>().having((e) => e.error, 'error', tipo));
    expect(() => sortear(semilla: ' ', participantes: casas, numerosLote: [1]),
        error(ErrorSorteo.sinSemilla));
    expect(() => sortear(semilla: 'S', participantes: [' '], numerosLote: [1]),
        error(ErrorSorteo.sinParticipantes));
    expect(() => sortear(semilla: 'S', participantes: casas, numerosLote: []),
        error(ErrorSorteo.sinLotes));
    expect(
        () => sortear(
            semilla: 'S',
            participantes: ['Casa Juana', 'casa  juana'],
            numerosLote: [1, 2]),
        error(ErrorSorteo.participanteRepetido));
  });

  test('huella de la lista: cambia si se toca la lista o su orden', () {
    final huella = huellaLista(casas);
    expect(huellaLista([...casas]), huella);
    expect(huellaLista(casas.map((c) => ' $c ').toList()), huella,
        reason: 'los espacios sobrantes no cuentan');
    expect(huellaLista([...casas, 'Casa Nueva']), isNot(huella));
    expect(huellaLista(casas.reversed.toList()), isNot(huella));
    expect(sortear(semilla: 'S', participantes: casas, numerosLote: [1]).huella,
        huella);
  });

  test('verificar: acepta el resultado publicado y rechaza uno cambiado', () {
    final resultado =
        sortear(semilla: 'S', participantes: casas, numerosLote: [1, 2, 3]);
    final publicado = resultado.adjudicacionPorLote;
    expect(
        verificarSorteo(
            semilla: 'S',
            participantes: casas,
            numerosLote: [1, 2, 3],
            adjudicacionPublicada: publicado),
        isTrue);
    final amanyado = Map<int, String>.of(publicado)
      ..[1] = publicado[2]!
      ..[2] = publicado[1]!;
    expect(
        verificarSorteo(
            semilla: 'S',
            participantes: casas,
            numerosLote: [1, 2, 3],
            adjudicacionPublicada: amanyado),
        isFalse);
  });

  test('reparto: con muchas semillas, cada casa saca el lote 1 parecido', () {
    final vecesPrimero = {for (final casa in casas) casa: 0};
    for (var indice = 0; indice < 2000; indice++) {
      final resultado = sortear(
          semilla: 'semilla-$indice', participantes: casas, numerosLote: [1]);
      vecesPrimero.update(
          resultado.adjudicacionPorLote[1]!, (veces) => veces + 1);
    }
    for (final veces in vecesPrimero.values) {
      expect(veces, inInclusiveRange(320, 480),
          reason: 'esperado ~400 de 2000 con 5 casas');
    }
  });

  test('la lista pegada se lee línea a línea', () {
    expect(leerListaParticipantes(' Casa Juana \n\n  Casa  Pello\n'),
        ['Casa Juana', 'Casa Pello']);
  });
}
