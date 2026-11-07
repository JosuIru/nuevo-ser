import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_ganadera/datos/base_datos.dart';
import 'package:solera_ganadera/modelos/apunte_economico.dart';
import 'package:solera_ganadera/modelos/explotacion.dart';
import 'package:solera_ganadera/modelos/ganado.dart';
import 'package:solera_ganadera/modelos/pieza_pasto.dart';
import 'package:solera_ganadera/modelos/tarea_sanitaria.dart';
import 'package:solera_ganadera/modelos/titular.dart';
import 'package:solera_ganadera/modelos/visita.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraGanadera.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosGanadera en la versión declarada',
      () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaGanadera);
    expect(File(entorno.ruta(nombreFicheroBaseDatosGanadera)).existsSync(),
        isTrue);
    expect((await leerColumnasPorTabla(db)).keys, containsAll(tablasGanadera));
  });

  test('titular y explotación se guardan en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos.guardarTitular(Titular(nombre: 'Segunda', nif: '1'));
    await baseDatos.guardarExplotacion(
        Explotacion(codigoRega: 'ES310000000001', especies: {'ovino'}));
    await baseDatos.guardarExplotacion(Explotacion(
        codigoRega: 'ES310000000002', especies: {'ovino', 'vacuno'}));
    final db = await baseDatos.basedatos;
    expect(await db.query('titulares'), hasLength(1));
    expect(await db.query('explotaciones'), hasLength(1));
    expect((await baseDatos.obtenerTitular()).nombre, 'Segunda');
    final explotacion = await baseDatos.obtenerExplotacion();
    expect(explotacion.codigoRega, 'ES310000000002');
    expect(explotacion.especies, {'ovino', 'vacuno'});
  });

  test('un rebaño se mueve entre piezas y se sabe dónde está', () async {
    final alta = await baseDatos.guardarPieza(PiezaPasto(
        nombre: 'Larre altua',
        superficieHa: 12.5,
        tipoPasto: pastoHumedo,
        titularidad: 'comunal',
        contorno: [(43.0, -1.5), (43.1, -1.5), (43.1, -1.4)]));
    final baja = await baseDatos.guardarPieza(PiezaPasto(nombre: 'Soto'));
    final lote = await baseDatos
        .guardarLote(LoteGanado(nombre: 'Latxas', especie: 'ovino'));
    await baseDatos.guardarAnimal(Animal(identificacion: 'ES01', loteId: lote));
    await baseDatos.guardarMovimiento(MovimientoGanado(
        loteId: lote,
        fechaMs: 1,
        tipo: tipoMovimientoEntrada,
        piezaDestinoId: baja));
    await baseDatos.guardarMovimiento(MovimientoGanado(
        loteId: lote, fechaMs: 2, piezaOrigenId: baja, piezaDestinoId: alta));
    final movimientos = await baseDatos.listarMovimientos(loteId: lote);
    expect(piezaActualDeLote(movimientos), alta);
    expect(await baseDatos.listarMovimientos(desdeMs: 2), hasLength(1));
    final pieza =
        (await baseDatos.listarPiezas()).firstWhere((p) => p.id == alta);
    expect(pieza.contorno, hasLength(3));
    expect(pieza.titularidad, 'comunal');
    expect(await baseDatos.listarAnimales(loteId: lote), hasLength(1));
  });

  test('lo que pide el libro no se borra en cascada', () async {
    final pieza = await baseDatos.guardarPieza(PiezaPasto(nombre: 'Soto'));
    final lote = await baseDatos.guardarLote(LoteGanado(nombre: 'Vacas'));
    await baseDatos.guardarMovimiento(
        MovimientoGanado(loteId: lote, fechaMs: 1, piezaDestinoId: pieza));
    expect(() => baseDatos.borrarPieza(pieza), throwsA(anything));
    final db = await baseDatos.basedatos;
    expect(() => db.delete('lotes_ganado', where: 'id = ?', whereArgs: [lote]),
        throwsA(anything));
  });

  test('los eventos del animal incluyen los de su rebaño', () async {
    final lote = await baseDatos.guardarLote(LoteGanado(nombre: 'Vacas'));
    final otro = await baseDatos.guardarLote(LoteGanado(nombre: 'Otras'));
    final animal = await baseDatos
        .guardarAnimal(Animal(identificacion: 'ES09', loteId: lote));
    await baseDatos.guardarEvento(EventoGanado(
        animalId: animal, fechaMs: 2, tipo: tipoEventoPesaje, pesoKg: 412));
    await baseDatos.guardarEvento(
        EventoGanado(loteId: lote, fechaMs: 3, sustanciaActiva: 'Ivermectina'));
    await baseDatos.guardarEvento(
        EventoGanado(loteId: otro, fechaMs: 4, sustanciaActiva: 'Otra'));
    final eventos =
        await baseDatos.listarEventos(animalId: animal, loteId: lote);
    expect(eventos.map((evento) => evento.tipo),
        [tipoEventoTratamiento, tipoEventoPesaje]);
    expect(await baseDatos.listarEventos(), hasLength(3));
  });

  test('visitas, calendario, apuntes y volcado completo', () async {
    await baseDatos.guardarVisita(
        Visita(fechaMs: 1, persona: 'Veterinaria', esVeterinaria: true));
    final tarea = await baseDatos.guardarTareaSanitaria(
        TareaSanitaria(titulo: 'Saneamiento', fechaPrevistaMs: 10));
    final tareaGuardada = (await baseDatos.listarTareasSanitarias()).single;
    await baseDatos.guardarTareaSanitaria(tareaGuardada.marcarHecha(11));
    expect(
        (await baseDatos.listarTareasSanitarias()).single.pendiente, isFalse);
    await baseDatos.guardarApunteEconomico(ApunteEconomico(
        esIngreso: true,
        fechaMs: 5,
        concepto: 'Corderos',
        categoria: 'venta_animales',
        baseCentimos: 100000,
        regimen: regimenReagp,
        porcentaje: 10.5));
    final apunte =
        (await baseDatos.listarApuntesEconomicos(desdeMs: 0, hastaMs: 10))
            .single;
    expect(apunte.cuotaCentimos, 10500);
    expect(apunte.esReagp, isTrue);
    final volcado = await baseDatos.volcarTodo();
    expect(volcado.keys, tablasGanadera);
    expect(volcado['visitas'], hasLength(1));
    expect(volcado['tareas_sanitarias']!.single['id'], tarea);
  });
}
