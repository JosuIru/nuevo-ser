import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/dominio/rotacion.dart';

void main() {
  const reglas = {'solanaceas': 4, 'liliaceas': 3, 'leguminosas': 0};
  final historial = [
    PasoPorBancal(
        bancalId: 1,
        familiaId: 'solanaceas',
        fecha: DateTime(2024, 4, 15),
        siembraId: 10),
    PasoPorBancal(
        bancalId: 1,
        familiaId: 'Leguminosas',
        fecha: DateTime(2025, 3, 1),
        siembraId: 11),
    PasoPorBancal(
        bancalId: 2,
        familiaId: 'solanaceas',
        fecha: DateTime(2020, 4, 15),
        siembraId: 12),
  ];

  AvisoRotacion? comprobar(int bancal, String familia, DateTime fecha,
          {int? excluir}) =>
      comprobarRotacion(
          bancalId: bancal,
          familiaId: familia,
          fecha: fecha,
          historial: historial,
          aniosMinimosPorFamilia: reglas,
          excluirSiembraId: excluir);

  test('avisa si la familia vuelve antes de los años mínimos', () {
    final aviso = comprobar(1, 'solanaceas', DateTime(2026, 4, 1))!;
    expect(aviso.aniosMinimos, 4);
    expect(aviso.fechaAnterior, DateTime(2024, 4, 15));
    expect(aviso.fechaLibre, DateTime(2028, 4, 15));
    expect(aviso.siembraAnteriorId, 10);
  });

  test('sin aviso justo al cumplir los años', () {
    expect(comprobar(1, 'solanaceas', DateTime(2028, 4, 15)), isNull);
    expect(comprobar(1, 'solanaceas', DateTime(2028, 4, 14)), isNotNull);
  });

  test('cada bancal lleva su historial', () {
    expect(comprobar(2, 'solanaceas', DateTime(2026, 4, 1)), isNull);
  });

  test('una siembra planificada más adelante también choca', () {
    final aviso = comprobar(1, 'solanaceas', DateTime(2022, 1, 1))!;
    expect(aviso.fechaAnterior, DateTime(2024, 4, 15));
  });

  test('sin regla, regla 0 o familia vacía: no se avisa', () {
    expect(comprobar(1, 'cucurbitaceas', DateTime(2024, 5, 1)), isNull);
    expect(comprobar(1, 'leguminosas', DateTime(2025, 6, 1)), isNull);
    expect(comprobar(1, '', DateTime(2025, 6, 1)), isNull);
  });

  test('al editar, la propia siembra no cuenta', () {
    expect(
        comprobar(1, 'solanaceas', DateTime(2024, 5, 1), excluir: 10), isNull);
  });

  test('compara la familia sin mayúsculas ni espacios', () {
    expect(comprobar(1, ' Solanaceas ', DateTime(2025, 1, 1)), isNotNull);
  });

  test('elige el choque más cercano', () {
    final conDos = [
      ...historial,
      PasoPorBancal(
          bancalId: 1,
          familiaId: 'solanaceas',
          fecha: DateTime(2025, 4, 1),
          siembraId: 13),
    ];
    final aviso = comprobarRotacion(
        bancalId: 1,
        familiaId: 'solanaceas',
        fecha: DateTime(2026, 4, 1),
        historial: conDos,
        aniosMinimosPorFamilia: reglas)!;
    expect(aviso.siembraAnteriorId, 13);
  });

  test('29 de febrero más un año cae en 1 de marzo', () {
    expect(sumarAnios(DateTime(2024, 2, 29), 1), DateTime(2025, 3, 1));
  });

  test('familias bloqueadas del bancal, de la que antes se libera', () {
    final mas = [
      ...historial,
      PasoPorBancal(
          bancalId: 1, familiaId: 'liliaceas', fecha: DateTime(2025, 10, 1)),
      PasoPorBancal(
          bancalId: 1, familiaId: 'liliaceas', fecha: DateTime(2030, 1, 1)),
    ];
    final bloqueadas = familiasBloqueadas(
        bancalId: 1,
        fecha: DateTime(2026, 6, 1),
        historial: mas,
        aniosMinimosPorFamilia: reglas);
    expect(bloqueadas.map((b) => b.familiaId), ['solanaceas', 'liliaceas']);
    expect(bloqueadas.last.fechaLibre, DateTime(2028, 10, 1));
  });

  test('familias sin regla en el catálogo', () {
    expect(
        familiasSinRegla(historial: [
          ...historial,
          PasoPorBancal(bancalId: 1, familiaId: 'Rara', fecha: DateTime(2020)),
          PasoPorBancal(bancalId: 1, familiaId: '', fecha: DateTime(2020)),
        ], aniosMinimosPorFamilia: reglas),
        {'rara'});
  });
}
