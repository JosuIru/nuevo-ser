import 'package:flutter_test/flutter_test.dart';
import 'package:solera_huerta/provisional_core/venta_directa/reparto_cestas.dart';
import 'package:solera_huerta/provisional_core/venta_directa/semanas.dart';

void main() {
  const tres = [
    CestaEnReparto(suscripcionId: 1, partes: 2),
    CestaEnReparto(suscripcionId: 2, partes: 3),
    CestaEnReparto(suscripcionId: 3, partes: 4),
  ];

  double kilosDe(PropuestaReparto propuesta, int suscripcion, int cultivo) =>
      propuesta.lineas[suscripcion]!
          .where((linea) => linea.cultivoId == cultivo)
          .fold(0.0, (suma, linea) => suma + linea.kg);

  test('kilos en proporción a las partes, en pasos de 50 g', () {
    final propuesta = repartirCosecha(
        existencias: const [ExistenciaReparto(cultivoId: 7, kg: 9)],
        cestas: tres);
    expect(kilosDe(propuesta, 1, 7), closeTo(2, 1e-9));
    expect(kilosDe(propuesta, 2, 7), closeTo(3, 1e-9));
    expect(kilosDe(propuesta, 3, 7), closeTo(4, 1e-9));
    expect(propuesta.sobrante, isEmpty);
  });

  test('nunca reparte más de lo que hay; el resto queda como sobrante', () {
    final propuesta = repartirCosecha(
        existencias: const [ExistenciaReparto(cultivoId: 7, kg: 1.03)],
        cestas: tres);
    final total = totalesRepartidos(propuesta)[7]!.kg;
    expect(total, closeTo(1.0, 1e-9));
    expect(propuesta.sobrante[7]!.kg, closeTo(0.03, 1e-9));
    for (final lineas in propuesta.lineas.values) {
      for (final linea in lineas) {
        final pasos = linea.kg / 0.05;
        expect((pasos - pasos.round()).abs(), lessThan(1e-6));
      }
    }
  });

  test('piezas enteras por mayor resto', () {
    final propuesta = repartirCosecha(
        existencias: const [ExistenciaReparto(cultivoId: 8, unidades: 10)],
        cestas: tres);
    // Cuotas 2,22 / 3,33 / 4,44 → 2 / 3 / 4 y la que sobra a la de mayor resto.
    expect(propuesta.lineas[3]!.single.unidades, 5);
    expect(propuesta.lineas[1]!.single.unidades, 2);
    expect(totalesRepartidos(propuesta)[8]!.unidades, 10);
    expect(propuesta.sobrante, isEmpty);
  });

  test('a igualdad de resto, el turno rota con la semilla', () {
    const iguales = [
      CestaEnReparto(suscripcionId: 1, partes: 3),
      CestaEnReparto(suscripcionId: 2, partes: 3),
      CestaEnReparto(suscripcionId: 3, partes: 3),
    ];
    Set<int> conLechuga(int semilla) {
      final propuesta = repartirCosecha(
          existencias: const [ExistenciaReparto(cultivoId: 1, unidades: 2)],
          cestas: iguales,
          semilla: semilla);
      return {
        for (final entrada in propuesta.lineas.entries)
          if (entrada.value.isNotEmpty) entrada.key
      };
    }

    expect(conLechuga(0), {1, 2});
    expect(conLechuga(1), {2, 3});
    expect(conLechuga(2), {3, 1});
  });

  test('sin cestas, todo es sobrante; sin existencias, cestas vacías', () {
    final sinCestas = repartirCosecha(
        existencias: const [ExistenciaReparto(cultivoId: 1, kg: 2)],
        cestas: const []);
    expect(sinCestas.sobrante[1]!.kg, 2);
    final sinNada = repartirCosecha(existencias: const [], cestas: tres);
    expect(sinNada.lineas.values.every((lineas) => lineas.isEmpty), isTrue);
  });

  test('una cesta con 0 partes no recibe', () {
    final propuesta = repartirCosecha(existencias: const [
      ExistenciaReparto(cultivoId: 1, kg: 1)
    ], cestas: const [
      CestaEnReparto(suscripcionId: 1, partes: 0),
      CestaEnReparto(suscripcionId: 2, partes: 1),
    ]);
    expect(propuesta.lineas[1], isEmpty);
    expect(kilosDe(propuesta, 2, 1), closeTo(1, 1e-9));
  });

  test('cantidades negativas no reparten nada', () {
    final propuesta = repartirCosecha(
        existencias: const [ExistenciaReparto(cultivoId: 1, kg: -1)],
        cestas: tres);
    expect(propuesta.lineas.values.every((lineas) => lineas.isEmpty), isTrue);
  });

  group('semanas', () {
    test('lunes de la semana', () {
      expect(lunesDeSemana(DateTime(2026, 11, 8, 18)), DateTime(2026, 11, 2));
      expect(lunesDeSemana(DateTime(2026, 11, 2)), DateTime(2026, 11, 2));
    });
    test('semanas entre fechas, a través del cambio de hora', () {
      expect(semanasEntre(DateTime(2026, 3, 23), DateTime(2026, 4, 1)), 1);
      expect(semanasEntre(DateTime(2026, 10, 19), DateTime(2026, 10, 26)), 1);
    });
    test('número de semana ISO', () {
      expect(numeroSemanaIso(DateTime(2026, 1, 1)), 1);
      expect(numeroSemanaIso(DateTime(2027, 1, 1)), 53);
      expect(numeroSemanaIso(DateTime(2026, 11, 7)), 45);
    });
    test('intervalo de la semana', () {
      final (inicio, fin) = intervaloSemana(DateTime(2026, 11, 4));
      expect(inicio, DateTime(2026, 11, 2).millisecondsSinceEpoch);
      expect(fin, DateTime(2026, 11, 9).millisecondsSinceEpoch - 1);
    });
  });
}
