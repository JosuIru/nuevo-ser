import 'package:flutter_test/flutter_test.dart';
import 'package:solera_zunbeltz/modelos/carga_ganadera.dart';

void main() {
  final ahora = DateTime(2026, 10, 22);
  int nacido(int anio, int mes, int dia) =>
      DateTime(anio, mes, dia).millisecondsSinceEpoch;

  test('meses cumplidos de calendario', () {
    expect(mesesCumplidos(DateTime(2026, 4, 22), ahora), 6);
    expect(mesesCumplidos(DateTime(2026, 4, 23), ahora), 5);
    expect(mesesCumplidos(DateTime(2027, 1, 1), ahora), 0);
  });

  test('vacuno por edad; sin fecha cuenta como adulto', () {
    expect(ugmPorCabeza(especie: 'vacuno', ahora: ahora), 1.0);
    expect(
        ugmPorCabeza(
            especie: 'vacuno',
            fechaNacimientoMs: nacido(2026, 6, 1),
            ahora: ahora),
        0.2);
    expect(
        ugmPorCabeza(
            especie: 'vacuno',
            fechaNacimientoMs: nacido(2025, 6, 1),
            ahora: ahora),
        0.6);
    expect(
        ugmPorCabeza(
            especie: 'vacuno',
            fechaNacimientoMs: nacido(2024, 6, 1),
            ahora: ahora),
        1.0);
  });

  test('ovino y caprino: crías, recría, hembras y machos adultos', () {
    expect(
        ugmPorCabeza(
            especie: 'ovino',
            fechaNacimientoMs: nacido(2026, 8, 1),
            ahora: ahora),
        0.05);
    expect(
        ugmPorCabeza(
            especie: 'caprino',
            fechaNacimientoMs: nacido(2026, 3, 1),
            ahora: ahora),
        0.10);
    expect(ugmPorCabeza(especie: 'ovino', sexo: 'hembra', ahora: ahora), 0.15);
    expect(ugmPorCabeza(especie: 'ovino', sexo: 'macho', ahora: ahora), 0.12);
  });

  test('otras especies y especie sin coeficiente', () {
    expect(ugmPorCabeza(especie: 'equino', ahora: ahora), 1.0);
    expect(ugmPorCabeza(especie: 'porcino', sexo: 'macho', ahora: ahora), 0.30);
    expect(ugmPorCabeza(especie: 'porcino', ahora: ahora), 0.25);
    expect(ugmPorCabeza(especie: 'aves', ahora: ahora), 0.015);
    expect(ugmPorCabeza(especie: 'varias', ahora: ahora), 0);
  });

  test('carga por hectárea', () {
    expect(cargaPorHectarea(3, 2), 1.5);
    expect(cargaPorHectarea(3, null), isNull);
    expect(cargaPorHectarea(3, 0), isNull);
  });
}
