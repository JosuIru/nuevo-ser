// Adaptado de apps/solera-zunbeltz/test/carga_ganadera_test.dart (commit
// 92ade2b): los coeficientes de Andalucía ahora son una tabla más del
// catálogo, y la PAC tiene la suya (RD 1048/2022, anexo V).

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_ganadera/datos/catalogos_generados/catalogo_tabla_ugm.dart';
import 'package:solera_ganadera/modelos/carga_ganadera.dart';
import 'package:solera_ganadera/modelos/ganado.dart';

void main() {
  final ahora = DateTime(2026, 10, 22);
  int nacido(int anio, int mes, int dia) =>
      DateTime(anio, mes, dia).millisecondsSinceEpoch;
  final andalucia = tablaDeTramite(catalogoCoeficientesUgm, tramiteAndalucia);
  final pac = tablaDeTramite(catalogoCoeficientesUgm, tramitePac);

  double ugm(List<CoeficienteUgm> tabla, String especie,
          {String sexo = '', int? nacimiento}) =>
      ugmPorCabeza(
          tabla: tabla,
          especie: especie,
          sexo: sexo,
          fechaNacimientoMs: nacimiento,
          ahora: ahora);

  test('meses cumplidos de calendario', () {
    expect(mesesCumplidos(DateTime(2026, 4, 22), ahora), 6);
    expect(mesesCumplidos(DateTime(2026, 4, 23), ahora), 5);
    expect(mesesCumplidos(DateTime(2027, 1, 1), ahora), 0);
  });

  test('Andalucía (la tabla de Zunbeltz): vacuno por edad', () {
    expect(ugm(andalucia, 'vacuno'), 1.0);
    expect(ugm(andalucia, 'vacuno', nacimiento: nacido(2026, 6, 1)), 0.2);
    expect(ugm(andalucia, 'vacuno', nacimiento: nacido(2025, 6, 1)), 0.6);
    expect(ugm(andalucia, 'vacuno', nacimiento: nacido(2024, 6, 1)), 1.0);
  });

  test('Andalucía: ovino y caprino, crías, recría, hembras y machos', () {
    expect(ugm(andalucia, 'ovino', nacimiento: nacido(2026, 8, 1)), 0.05);
    expect(ugm(andalucia, 'caprino', nacimiento: nacido(2026, 3, 1)), 0.10);
    expect(ugm(andalucia, 'ovino', sexo: 'hembra'), 0.15);
    expect(ugm(andalucia, 'ovino', sexo: 'macho'), 0.12);
    expect(ugm(andalucia, 'porcino', sexo: 'macho'), 0.30);
    expect(ugm(andalucia, 'porcino'), 0.25);
  });

  test('PAC (RD 1048/2022 anexo V): la misma cabeza cuenta distinto', () {
    expect(ugm(pac, 'ovino', sexo: 'hembra'), 0.1);
    expect(ugm(pac, 'caprino', nacimiento: nacido(2026, 8, 1)), 0.1);
    expect(ugm(pac, 'vacuno', nacimiento: nacido(2026, 6, 1)), 0.4);
    expect(ugm(pac, 'vacuno', nacimiento: nacido(2025, 6, 1)), 0.7);
    expect(ugm(pac, 'vacuno', sexo: 'macho'), 1.0);
    expect(ugm(pac, 'vacuno', sexo: 'castrado'), 1.0);
    expect(ugm(pac, 'vacuno', sexo: 'hembra'), 0.8);
    expect(ugm(pac, 'equino'), 0.8);
    expect(ugm(pac, 'porcino', sexo: 'hembra'), 0.5);
    expect(ugm(pac, 'porcino', sexo: 'macho'), 0.3);
  });

  test('una especie sin fila en el trámite cuenta 0', () {
    expect(ugm(pac, 'aves'), 0);
    expect(ugm(const [], 'ovino'), 0);
  });

  test('UGM de un rebaño: animales activos y cabezas sin crotal', () {
    final lote = LoteGanado(id: 1, especie: 'ovino', cabezasSinIdentificar: 10);
    final animales = [
      Animal(loteId: 1, sexo: 'macho'),
      Animal(loteId: 1, estado: 'vendido'),
    ];
    expect(ugmDeLote(lote, animales, ahora, pac), closeTo(1.1, 1e-9));
    expect(ugmDeLote(lote, animales, ahora, andalucia), closeTo(1.62, 1e-9));
  });

  test('carga por hectárea', () {
    expect(cargaPorHectarea(3, 2), 1.5);
    expect(cargaPorHectarea(3, null), isNull);
    expect(cargaPorHectarea(3, 0), isNull);
  });
}
