import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/utiles/periodo.dart';

void main() {
  final hoy = DateTime(2026, 10, 8, 10);
  int ms(DateTime fecha) => fecha.millisecondsSinceEpoch;

  test('trimestre en curso: los días que han pasado, no los 92', () {
    final dias = diasParaExtrapolar(
        rango: rangoDePeriodo(TipoPeriodo.trimestre, hoy), ahoraMs: ms(hoy));
    expect(dias, 8);
  });

  test('año en curso con proyecto empezado en junio: desde junio', () {
    final dias = diasParaExtrapolar(
        rango: rangoDePeriodo(TipoPeriodo.anio, hoy),
        inicioProyectoMs: ms(DateTime(2026, 6, 1)),
        ahoraMs: ms(hoy));
    expect(dias, 130);
  });

  test('trimestre anterior completo: sus 92 días', () {
    final dias = diasParaExtrapolar(
        rango: rangoDePeriodo(TipoPeriodo.trimestreAnterior, hoy),
        ahoraMs: ms(hoy));
    expect(dias, 92);
  });

  test('todo el proyecto con fin previsto futuro: hasta hoy', () {
    final dias = diasParaExtrapolar(
        rango: rangoDePeriodo(TipoPeriodo.todo, hoy),
        inicioProyectoMs: ms(DateTime(2026, 9, 8, 10)),
        finProyectoMs: ms(DateTime(2027, 9, 8)),
        ahoraMs: ms(hoy));
    expect(dias, 30);
  });

  test('sin saber desde cuándo, o empezando en el futuro: null', () {
    expect(
        diasParaExtrapolar(
            rango: rangoDePeriodo(TipoPeriodo.todo, hoy), ahoraMs: ms(hoy)),
        isNull);
    expect(
        diasParaExtrapolar(
            rango: rangoDePeriodo(TipoPeriodo.todo, hoy),
            inicioProyectoMs: ms(DateTime(2026, 11, 1)),
            ahoraMs: ms(hoy)),
        isNull);
  });
}
