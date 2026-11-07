import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_vivero/datos/base_datos.dart';
import 'package:solera_vivero/modelos/bandeja.dart';
import 'package:solera_vivero/modelos/inspeccion_plagas.dart';
import 'package:solera_vivero/modelos/lote_material.dart';
import 'package:solera_vivero/modelos/partida_planta.dart';
import 'package:solera_vivero/modelos/pasaporte_emitido.dart';
import 'package:solera_vivero/modelos/salida.dart';
import 'package:solera_vivero/modelos/siembra.dart';
import 'package:solera_vivero/modelos/tratamiento.dart';
import 'package:solera_vivero/modelos/vivero.dart';
import 'package:solera_vivero/modelos/zona_cultivo.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraVivero.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  /// Lote → bandeja → siembra → partida. Devuelve los ids.
  Future<(int, int, int, int)> sembrar() async {
    final lote = await baseDatos.guardarLoteMaterial(
        LoteMaterial(codigo: 'SEM-1', especieId: 'tomate', fechaEntradaMs: 1));
    final bandeja =
        await baseDatos.guardarBandeja(Bandeja(codigoQr: 'VIV-B-0001'));
    final siembra = await baseDatos.guardarSiembra(
        Siembra(loteMaterialId: lote, bandejaId: bandeja, fechaMs: 2));
    final partida = await baseDatos.guardarPartida(PartidaPlanta(
        codigo: 'P26-0001',
        especieId: 'tomate',
        cantidadInicial: 100,
        siembraId: siembra,
        bandejaId: bandeja,
        fechaAltaMs: 3));
    return (lote, bandeja, siembra, partida);
  }

  test('crea $nombreFicheroBaseDatosVivero en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaVivero);
    expect(
        File(entorno.ruta(nombreFicheroBaseDatosVivero)).existsSync(), isTrue);
  });

  test('el esquema creado coincide con las sentencias v1', () async {
    final db = await baseDatos.basedatos;
    expect(await leerColumnasPorTabla(db),
        await columnasDeEsquemaV1(sentenciasEsquemaViveroV1));
  });

  test('el vivero se guarda en una sola fila', () async {
    await baseDatos.guardarVivero(Vivero(nombre: 'Primero'));
    await baseDatos
        .guardarVivero(Vivero(nombre: 'Segundo', codigoRopveg: 'ES-15200001'));
    final filas = await (await baseDatos.basedatos).query('viveros');
    expect(filas, hasLength(1));
    final vivero = await baseDatos.obtenerVivero();
    expect((vivero.nombre, vivero.codigoRopveg), ('Segundo', 'ES-15200001'));
  });

  test('bandeja por QR y códigos únicos', () async {
    await baseDatos.guardarBandeja(Bandeja(codigoQr: 'VIV-B-0001'));
    expect((await baseDatos.obtenerBandejaPorQr(' VIV-B-0001 '))?.codigoQr,
        'VIV-B-0001');
    expect(await baseDatos.obtenerBandejaPorQr('VIV-B-0404'), isNull);
    expect(await baseDatos.obtenerBandejaPorQr(''), isNull);
    await expectLater(baseDatos.guardarBandeja(Bandeja(codigoQr: 'VIV-B-0001')),
        throwsA(anything));
  });

  test('la trazabilidad no se puede borrar (RESTRICT)', () async {
    final (lote, bandeja, siembra, partida) = await sembrar();
    await expectLater(baseDatos.borrarLoteMaterial(lote), throwsA(anything));
    await expectLater(baseDatos.borrarBandeja(bandeja), throwsA(anything));
    await expectLater(baseDatos.borrarSiembra(siembra), throwsA(anything));
    final salida = await baseDatos
        .guardarSalida(Salida(partidaId: partida, fechaMs: 4, cantidad: 10));
    await expectLater(baseDatos.borrarPartida(partida), throwsA(anything));
    await baseDatos.guardarPasaporte(PasaporteEmitido(
        salidaId: salida,
        fechaMs: 4,
        nombreBotanico: 'Solanum lycopersicum',
        codigoOperador: 'ES-15200001',
        codigoTrazabilidad: 'P26-0001',
        paisOrigen: 'ES'));
    await expectLater(baseDatos.borrarSalida(salida), throwsA(anything));
  });

  test('repicar crea la partida nueva y el eslabón en una transacción',
      () async {
    final (_, _, _, partida) = await sembrar();
    final destino = await baseDatos.repicar(
        partidaDestino: PartidaPlanta(
            codigo: 'P26-0002',
            especieId: 'tomate',
            formato: 'maceta',
            cantidadInicial: 40,
            fechaAltaMs: 5),
        partidaOrigenId: partida,
        fechaMs: 5,
        cantidad: 40);
    final nueva = await baseDatos.obtenerPartida(destino);
    expect((nueva?.partidaOrigenId, nueva?.formato), (partida, 'maceta'));
    final repicados = await baseDatos.listarRepicados();
    expect((repicados.single.partidaOrigenId, repicados.single.cantidad),
        (partida, 40));
    // Si el código ya existe, no queda nada a medias.
    await expectLater(
        baseDatos.repicar(
            partidaDestino: PartidaPlanta(
                codigo: 'P26-0002',
                especieId: 'tomate',
                cantidadInicial: 1,
                fechaAltaMs: 6),
            partidaOrigenId: partida,
            fechaMs: 6,
            cantidad: 1),
        throwsA(anything));
    expect(await baseDatos.listarRepicados(), hasLength(1));
  });

  test('pasaportes: se anulan, no se borran; filtro por fechas', () async {
    final (_, _, _, partida) = await sembrar();
    final salida = await baseDatos
        .guardarSalida(Salida(partidaId: partida, fechaMs: 10, cantidad: 5));
    for (final fecha in [10, 20]) {
      await baseDatos.guardarPasaporte(PasaporteEmitido(
          salidaId: salida,
          fechaMs: fecha,
          nombreBotanico: 'Solanum lycopersicum',
          codigoOperador: 'ES-15200001',
          codigoTrazabilidad: 'P26-0001',
          paisOrigen: 'ES'));
    }
    final pasaportes = await baseDatos.listarPasaportes();
    expect(pasaportes.map((p) => p.fechaMs), [20, 10]);
    await baseDatos.anularPasaporte(pasaportes.first);
    final despues = await baseDatos.listarPasaportes(desdeMs: 15);
    expect((despues.single.anulado, despues.single.fechaMs), (true, 20));
    expect(await baseDatos.listarPasaportes(salidaId: salida), hasLength(2));
  });

  test(
      'tratamientos e inspecciones por partida; zona con registros no se borra',
      () async {
    final (_, _, _, partida) = await sembrar();
    final zona = await baseDatos.guardarZona(ZonaCultivo(nombre: 'Nave 1'));
    await baseDatos.guardarTratamiento(Tratamiento(
        fechaMs: 1, partidaId: partida, sustanciaActivaId: 'azufre'));
    await baseDatos.guardarTratamiento(Tratamiento(fechaMs: 2, zonaId: zona));
    await baseDatos.guardarInspeccion(InspeccionPlagas(
        fechaMs: 3, zonaId: zona, plagaId: 'xylella_fastidiosa'));
    expect(
        await baseDatos.listarTratamientos(partidaId: partida), hasLength(1));
    expect(await baseDatos.listarTratamientos(), hasLength(2));
    expect(await baseDatos.listarInspecciones(), hasLength(1));
    await expectLater(baseDatos.borrarZona(zona), throwsA(anything));
  });

  test('una bandeja retirada sigue en la lista completa', () async {
    await baseDatos.guardarBandeja(Bandeja(codigoQr: 'VIV-B-0001'));
    await baseDatos
        .guardarBandeja(Bandeja(codigoQr: 'VIV-B-0002', activa: false));
    expect(await baseDatos.listarBandejas(soloActivas: true), hasLength(1));
    expect(await baseDatos.listarBandejas(), hasLength(2));
  });
}
