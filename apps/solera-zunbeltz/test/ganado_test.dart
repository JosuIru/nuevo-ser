// El ganado (BD v15): dónde está cada lote (el destino de su último
// movimiento), cuántas cabezas tiene, plazos de supresión de los
// tratamientos, y que todo viaja entre móviles con sus referencias por uid.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/ganado.dart';
import 'package:solera_zunbeltz/modelos/zona_finca.dart';

import 'bd_en_memoria.dart';

int dia(int anio, int mes, int diaDelMes) =>
    DateTime(anio, mes, diaDelMes, 10).millisecondsSinceEpoch;

void main() {
  group('cálculos', () {
    test('el lote está en el destino de su último movimiento', () {
      final movimientos = [
        MovimientoGanado(
            id: 1, loteId: 1, fechaMs: dia(2026, 10, 1), zonaDestinoId: 10),
        MovimientoGanado(
            id: 3, loteId: 1, fechaMs: dia(2026, 10, 9), zonaDestinoId: 30),
        MovimientoGanado(
            id: 2, loteId: 1, fechaMs: dia(2026, 10, 5), zonaDestinoId: 20),
      ];
      expect(zonaActualDeLote(movimientos), 30);
      expect(zonaActualDeLote(const []), isNull);
    });

    test('a igual fecha manda el último apuntado', () {
      final movimientos = [
        MovimientoGanado(
            id: 5, loteId: 1, fechaMs: dia(2026, 10, 9), zonaDestinoId: 50),
        MovimientoGanado(
            id: 4, loteId: 1, fechaMs: dia(2026, 10, 9), zonaDestinoId: 40),
      ];
      expect(zonaActualDeLote(movimientos), 50);
    });

    test('tras una salida el lote no está en ninguna pieza', () {
      final movimientos = [
        MovimientoGanado(
            id: 1, loteId: 1, fechaMs: dia(2026, 6, 1), zonaDestinoId: 10),
        MovimientoGanado(
            id: 2,
            loteId: 1,
            fechaMs: dia(2026, 6, 15),
            tipo: tipoMovimientoSalida,
            destinoExterno: 'Sierra de Urbasa'),
      ];
      expect(zonaActualDeLote(movimientos), isNull);
      expect(ultimoMovimiento(movimientos)!.destinoExterno, 'Sierra de Urbasa');
    });

    test('cabezas: animales en el espacio más las sin identificar', () {
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
        // Termina el 20-oct: vigente.
        EventoGanado(
            fechaMs: dia(2026, 10, 10),
            plazoSupresionCarneDias: 10,
            plazoSupresionLecheDias: 3),
        // Termina el 25-oct: el más tardío.
        EventoGanado(fechaMs: dia(2026, 10, 15), plazoSupresionCarneDias: 10),
        // Terminó el 11-oct.
        EventoGanado(fechaMs: dia(2026, 10, 1), plazoSupresionLecheDias: 10),
      ];
      final supresion = supresionVigente(eventos, ahora);
      expect(supresion.carneHasta, DateTime(2026, 10, 25));
      expect(supresion.lecheHasta, isNull);
      expect(supresion.hayAlguna, isTrue);
    });

    test('supresión: el día en que termina ya no cuenta', () {
      final supresion = supresionVigente([
        EventoGanado(fechaMs: dia(2026, 10, 6), plazoSupresionCarneDias: 10)
      ], DateTime(2026, 10, 16, 8));
      expect(supresion.hayAlguna, isFalse);
    });

    test('supresión: días de calendario aunque cambie la hora', () {
      // El 25-oct-2026 cambia la hora en España.
      expect(
          finDePlazo(DateTime(2026, 10, 24, 23, 30).millisecondsSinceEpoch, 2),
          DateTime(2026, 10, 26));
    });
  });

  group('base de datos', () {
    late BaseDatosSoleraZunbeltz bd;
    late int fincaId;
    late int pasillo;
    late int avellanos;

    setUp(() async {
      bd = await abrirBdEnMemoria();
      fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
      pasillo =
          await bd.guardarZona(ZonaFinca(fincaId: fincaId, nombre: 'Pasillo'));
      avellanos = await bd
          .guardarZona(ZonaFinca(fincaId: fincaId, nombre: 'Los Avellanos'));
    });

    test('mover un lote apunta de dónde viene y cuántas cabezas lleva',
        () async {
      final lote = await bd.guardarLote(LoteGanado(
          nombre: 'Ovejas latxas', especie: 'ovino', cabezasSinIdentificar: 3));
      await bd.guardarAnimal(Animal(identificacion: 'ES01', loteId: lote));
      await bd.guardarAnimal(Animal(identificacion: 'ES02', loteId: lote));

      await bd.moverLote(
          loteId: lote,
          fechaMs: dia(2026, 10, 1),
          tipo: tipoMovimientoEntrada,
          zonaDestinoId: pasillo);
      await bd.moverLote(
          loteId: lote,
          fechaMs: dia(2026, 10, 10),
          tipo: tipoMovimientoTraslado,
          zonaDestinoId: avellanos,
          guia: 'G-123');

      final movimientos = await bd.listarMovimientos(loteId: lote);
      expect(movimientos.first.zonaOrigenId, pasillo);
      expect(movimientos.first.zonaDestinoId, avellanos);
      expect(movimientos.first.cabezas, 5);
      expect(movimientos.first.guia, 'G-123');

      final porZona = await bd.lotesPorZona();
      expect(porZona.keys, [avellanos]);
      expect(porZona[avellanos]!.single.cabezas, 5);
    });

    test('un lote cerrado no sale en las piezas', () async {
      final lote = await bd.guardarLote(LoteGanado(nombre: 'Cerdos'));
      await bd.moverLote(
          loteId: lote,
          fechaMs: dia(2026, 10, 1),
          tipo: tipoMovimientoEntrada,
          zonaDestinoId: pasillo);
      await bd.actualizarLote(lote, {'estado': estadoLoteCerrado});
      expect(await bd.lotesPorZona(), isEmpty);
    });

    test('los eventos del animal incluyen los de su lote', () async {
      final lote = await bd.guardarLote(LoteGanado(nombre: 'Vacas'));
      final otro = await bd.guardarLote(LoteGanado(nombre: 'Otras'));
      final animal =
          await bd.guardarAnimal(Animal(identificacion: 'ES09', loteId: lote));
      await bd.guardarEventoGanado(EventoGanado(
          animalId: animal,
          fechaMs: dia(2026, 10, 2),
          tipo: tipoEventoPesaje,
          pesoKg: 412));
      await bd.guardarEventoGanado(EventoGanado(
          loteId: lote,
          fechaMs: dia(2026, 10, 3),
          sustanciaActiva: 'ivermectina'));
      await bd.guardarEventoGanado(EventoGanado(
          loteId: otro, fechaMs: dia(2026, 10, 4), sustanciaActiva: 'otra'));

      final eventos =
          await bd.listarEventosGanado(animalId: animal, loteId: lote);
      expect(eventos.map((evento) => evento.tipo),
          [tipoEventoTratamiento, tipoEventoPesaje]);
      expect(eventos.last.pesoKg, 412);
    });

    test(
        'borrar un lote se lleva sus movimientos y deja a los animales sin lote',
        () async {
      final lote = await bd.guardarLote(LoteGanado(nombre: 'Vacas'));
      final animal =
          await bd.guardarAnimal(Animal(identificacion: 'ES09', loteId: lote));
      await bd.moverLote(
          loteId: lote,
          fechaMs: dia(2026, 10, 1),
          tipo: tipoMovimientoEntrada,
          zonaDestinoId: pasillo);
      await bd.borrarLote(lote);
      expect(await bd.listarMovimientos(), isEmpty);
      expect((await bd.obtenerAnimal(animal))!.loteId, isNull);
      final lapidas = await bd.listarBorradosPendientes();
      expect(lapidas.map((lapida) => lapida.tipo).toSet(),
          {'lote_ganado', 'movimiento_ganado'});
    });

    test('viaja a otro móvil con sus referencias por uid', () async {
      final lote = await bd.guardarLote(
          LoteGanado(nombre: 'Ovejas', especie: 'ovino', autorUid: 'ane'));
      final animal = await bd.guardarAnimal(
          Animal(identificacion: 'ES01', loteId: lote, sexo: 'hembra'));
      await bd.moverLote(
          loteId: lote,
          fechaMs: dia(2026, 10, 1),
          tipo: tipoMovimientoEntrada,
          zonaDestinoId: pasillo);
      await bd.moverLote(
          loteId: lote,
          fechaMs: dia(2026, 10, 2),
          tipo: tipoMovimientoTraslado,
          zonaDestinoId: avellanos);
      await bd.guardarEventoGanado(EventoGanado(
          animalId: animal,
          fechaMs: dia(2026, 10, 3),
          sustanciaActiva: 'oxitetraciclina',
          plazoSupresionCarneDias: 28));

      final subidas = await bd.entidadesPendientesDeSubir(0);
      final movimiento = subidas.lastWhere(
          (entidad) => entidad['tipo'] == 'movimiento_ganado')['datos'] as Map;
      expect(movimiento['lote_uid'], isNotEmpty);
      expect(movimiento['zona_origen_uid'], isNotEmpty);
      expect(movimiento['zona_destino_uid'], isNotEmpty);
      expect(
          subidas.firstWhere(
              (entidad) => entidad['tipo'] == 'lote_ganado')['autor_uid'],
          'ane');

      final otroMovil = await abrirBdEnMemoria();
      for (final entidad in subidas) {
        await otroMovil.aplicarEntidadRemota(entidad);
      }
      final zonasOtro = {
        for (final zona in await otroMovil.listarZonas()) zona.id: zona.nombre
      };
      final porZona = await otroMovil.lotesPorZona();
      expect(porZona.keys.map((id) => zonasOtro[id]), ['Los Avellanos']);
      expect(porZona.values.single.single.cabezas, 1);
      final animalOtro = (await otroMovil.listarAnimales()).single;
      final eventos = await otroMovil.listarEventosGanado(
          animalId: animalOtro.id, loteId: animalOtro.loteId);
      expect(eventos.single.sustanciaActiva, 'oxitetraciclina');
      expect(eventos.single.plazoSupresionCarneDias, 28);
    });
  });
}
