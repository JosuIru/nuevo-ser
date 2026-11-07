// Adaptado de apps/solera-zunbeltz/test/ganado_test.dart (commit 92ade2b):
// los cálculos puros, sin la parte de sincronización entre móviles.

import 'package:flutter_test/flutter_test.dart';
import 'package:solera_ganadera/modelos/ganado.dart';

int dia(int anio, int mes, int diaDelMes) =>
    DateTime(anio, mes, diaDelMes, 10).millisecondsSinceEpoch;

void main() {
  test('el rebaño está en el destino de su último movimiento', () {
    final movimientos = [
      MovimientoGanado(
          id: 1, loteId: 1, fechaMs: dia(2026, 10, 1), piezaDestinoId: 10),
      MovimientoGanado(
          id: 3, loteId: 1, fechaMs: dia(2026, 10, 9), piezaDestinoId: 30),
      MovimientoGanado(
          id: 2, loteId: 1, fechaMs: dia(2026, 10, 5), piezaDestinoId: 20),
    ];
    expect(piezaActualDeLote(movimientos), 30);
    expect(piezaActualDeLote(const []), isNull);
  });

  test('a igual fecha manda el último apuntado', () {
    final movimientos = [
      MovimientoGanado(
          id: 5, loteId: 1, fechaMs: dia(2026, 10, 9), piezaDestinoId: 50),
      MovimientoGanado(
          id: 4, loteId: 1, fechaMs: dia(2026, 10, 9), piezaDestinoId: 40),
    ];
    expect(piezaActualDeLote(movimientos), 50);
  });

  test('tras una salida el rebaño no está en ninguna pieza', () {
    final movimientos = [
      MovimientoGanado(
          id: 1, loteId: 1, fechaMs: dia(2026, 6, 1), piezaDestinoId: 10),
      MovimientoGanado(
          id: 2,
          loteId: 1,
          fechaMs: dia(2026, 6, 15),
          tipo: tipoMovimientoSalida,
          titularExterno: 'Puerto de Urbasa'),
    ];
    expect(piezaActualDeLote(movimientos), isNull);
    expect(ultimoMovimiento(movimientos)!.titularExterno, 'Puerto de Urbasa');
  });

  test('una baja parcial no mueve el rebaño', () {
    final movimientos = [
      MovimientoGanado(
          id: 1, loteId: 1, fechaMs: dia(2026, 6, 1), piezaDestinoId: 10),
      MovimientoGanado(
          id: 2,
          loteId: 1,
          fechaMs: dia(2026, 6, 15),
          tipo: tipoMovimientoBajaParcial,
          cabezas: 12,
          explotacionExterna: 'ES310000000001'),
    ];
    expect(piezaActualDeLote(movimientos), 10);
    expect(movimientos.last.esSalidaDeExplotacion, isTrue);
    expect(movimientos.last.cambiaUbicacion, isFalse);
  });

  test('cabezas: animales activos más las sin identificar', () {
    final lote = LoteGanado(id: 1, cabezasSinIdentificar: 12);
    final animales = [
      Animal(loteId: 1),
      Animal(loteId: 1),
      Animal(loteId: 1, estado: 'vendido'),
    ];
    expect(cabezasDeLote(lote, animales), 14);
  });

  test('supresión: el final más tardío que aún no ha llegado', () {
    final ahora = DateTime(2026, 10, 16, 12);
    final eventos = [
      EventoGanado(
          fechaMs: dia(2026, 10, 10),
          plazoSupresionCarneDias: 10,
          plazoSupresionLecheDias: 3),
      EventoGanado(fechaMs: dia(2026, 10, 15), plazoSupresionCarneDias: 10),
      EventoGanado(fechaMs: dia(2026, 10, 1), plazoSupresionLecheDias: 10),
    ];
    final supresion = supresionVigente(eventos, ahora);
    expect(supresion.carneHasta, DateTime(2026, 10, 25));
    expect(supresion.lecheHasta, isNull);
    expect(supresion.hayAlguna, isTrue);
  });

  test('supresión: el día en que termina ya no cuenta', () {
    final supresion = supresionVigente(
        [EventoGanado(fechaMs: dia(2026, 10, 6), plazoSupresionCarneDias: 10)],
        DateTime(2026, 10, 16, 8));
    expect(supresion.hayAlguna, isFalse);
  });

  test('supresión: días de calendario aunque cambie la hora', () {
    expect(finDePlazo(DateTime(2026, 10, 24, 23, 30).millisecondsSinceEpoch, 2),
        DateTime(2026, 10, 26));
  });

  test('round-trip de los cuatro modelos, con los campos del RD 787/2023', () {
    final lote = LoteGanado(
        id: 1,
        nombre: 'Latxas',
        especie: 'ovino',
        cabezasSinIdentificar: 4,
        ecologico: true,
        cicloCorto: true);
    final copiaLote = LoteGanado.fromMap(lote.toMap());
    expect(copiaLote.ecologico, isTrue);
    expect(copiaLote.cicloCorto, isTrue);
    expect(copiaLote.cabezasSinIdentificar, 4);

    final animal = Animal(
        id: 2,
        identificacion: 'ES031101234567',
        dispositivo: 'bolo_ruminal',
        sexo: 'hembra',
        fechaNacimientoMs: 5,
        loteId: 1);
    final copiaAnimal = Animal.fromMap(animal.toMap());
    expect(copiaAnimal.dispositivo, 'bolo_ruminal');
    expect(copiaAnimal.fechaNacimientoMs, 5);
    expect(copiaAnimal.rotulo, 'ES031101234567');

    final movimiento = MovimientoGanado(
        loteId: 1,
        fechaMs: 9,
        tipo: tipoMovimientoSalida,
        codigoRemo: 'REMO-1',
        autorizacionTransportista: 'AT-9',
        fechaCertificadoMs: 8);
    final copiaMovimiento = MovimientoGanado.fromMap(movimiento.toMap());
    expect(copiaMovimiento.codigoRemo, 'REMO-1');
    expect(copiaMovimiento.autorizacionTransportista, 'AT-9');
    expect(copiaMovimiento.fechaCertificadoMs, 8);
    expect(copiaMovimiento.esSalida, isTrue);

    final evento = EventoGanado(
        loteId: 1,
        fechaMs: 3,
        medicamento: 'El de la receta',
        sustanciaActiva: 'Ivermectina',
        duracionDias: 3,
        plazoSupresionCarneDias: 28,
        proveedor: 'Cooperativa',
        pruebaCompra: 'F-12',
        pesoKg: 41.5);
    final copiaEvento = EventoGanado.fromMap(evento.toMap());
    expect(copiaEvento.medicamento, 'El de la receta');
    expect(copiaEvento.pruebaCompra, 'F-12');
    expect(copiaEvento.duracionDias, 3);
    expect(copiaEvento.pesoKg, 41.5);
    expect(copiaEvento.llevaMedicamento, isTrue);
  });

  test('un mapa vacío no rompe ningún modelo', () {
    expect(LoteGanado.fromMap(const {}).activo, isTrue);
    expect(Animal.fromMap(const {}).activo, isTrue);
    expect(MovimientoGanado.fromMap(const {}).tipo, tipoMovimientoTraslado);
    expect(EventoGanado.fromMap(const {}).tipo, tipoEventoTratamiento);
  });
}
