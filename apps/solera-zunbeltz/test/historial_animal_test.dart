// La línea de tiempo de la ficha de un animal: nacimiento, lo hecho a él,
// lo del rebaño mientras vivía (en el espacio) y la baja, de lo más
// reciente a lo más antiguo.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/modelos/historial_animal.dart';

int dia(int mes, int diaDelMes, [int hora = 10]) =>
    DateTime(2026, mes, diaDelMes, hora).millisecondsSinceEpoch;

void main() {
  final morena = Animal(
    id: 1,
    identificacion: 'ES012345678901',
    loteId: 5,
    fechaNacimientoMs: dia(3, 1, 8),
    estado: 'vendido',
    fechaBajaMs: dia(9, 30, 18),
  );

  final movimientos = [
    MovimientoGanado(id: 1, loteId: 5, fechaMs: dia(2, 1)), // antes de nacer
    MovimientoGanado(id: 2, loteId: 5, fechaMs: dia(3, 1, 7)), // el mismo día
    MovimientoGanado(id: 3, loteId: 5, fechaMs: dia(6, 15)),
    MovimientoGanado(id: 4, loteId: 9, fechaMs: dia(6, 16)), // otro rebaño
    MovimientoGanado(id: 5, loteId: 5, fechaMs: dia(10, 5)), // tras la baja
  ];

  final eventos = [
    EventoGanado(id: 10, animalId: 1, loteId: 5, fechaMs: dia(6, 15, 12),
        tipo: tipoEventoPesaje),
    EventoGanado(id: 11, loteId: 5, fechaMs: dia(5, 2)), // al rebaño
    EventoGanado(id: 12, loteId: 5, fechaMs: dia(1, 10)), // al rebaño, antes
    EventoGanado(id: 13, animalId: 2, loteId: 5, fechaMs: dia(5, 3)), // otro
    EventoGanado(id: 14, animalId: 1, fechaMs: dia(9, 30, 9),
        tipo: 'incidencia'),
    EventoGanado(id: 15, loteId: 5, fechaMs: dia(10, 1)), // tras la baja
  ];

  test('todo lo suyo, lo del rebaño mientras estaba y en orden', () {
    final historial = historialDeAnimal(
        animal: morena, movimientos: movimientos, eventos: eventos);
    expect(
      historial
          .map((hito) => (
                hito.tipo,
                hito.evento?.id ?? hito.movimiento?.id,
              ))
          .toList(),
      [
        (TipoHitoAnimal.baja, null),
        (TipoHitoAnimal.evento, 14), // mismo día que la baja, debajo
        (TipoHitoAnimal.evento, 10), // mismo día que el movimiento 3, encima
        (TipoHitoAnimal.movimientoRebano, 3),
        (TipoHitoAnimal.evento, 11),
        (TipoHitoAnimal.movimientoRebano, 2), // mismo día que nació, encima
        (TipoHitoAnimal.nacimiento, null),
      ],
    );
    expect(historial[2].delRebano, isFalse);
    expect(historial[3].delRebano, isTrue);
    expect(historial[4].delRebano, isTrue);
  });

  test('sin nacimiento ni baja: lo del rebaño desde siempre', () {
    final sinFechas = Animal(id: 1, loteId: 5);
    final historial = historialDeAnimal(
        animal: sinFechas, movimientos: movimientos, eventos: eventos);
    expect(historial.first.movimiento?.id, 5);
    expect(historial.last.evento?.id, 12);
    expect(historial.where((hito) => hito.tipo == TipoHitoAnimal.nacimiento),
        isEmpty);
    expect(historial.where((hito) => hito.tipo == TipoHitoAnimal.baja),
        isEmpty);
  });

  test('sin rebaño: solo lo suyo', () {
    final suelto = Animal(id: 1, fechaNacimientoMs: dia(3, 1));
    final historial = historialDeAnimal(
        animal: suelto, movimientos: movimientos, eventos: eventos);
    expect(historial.map((hito) => hito.evento?.id),
        [14, 10, null]); // incidencia, pesaje, nacimiento
  });

  test('un animal en el espacio no tiene baja aunque quede una fecha', () {
    final activo = Animal(id: 1, loteId: 5, fechaBajaMs: dia(4, 1));
    final historial =
        historialDeAnimal(animal: activo, movimientos: movimientos, eventos: []);
    expect(historial.map((hito) => hito.movimiento?.id), [5, 3, 2, 1]);
  });
}
