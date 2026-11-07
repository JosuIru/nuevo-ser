import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_huerta/datos/base_datos.dart';
import 'package:solera_huerta/modelos/bancal.dart';
import 'package:solera_huerta/modelos/cosecha.dart';
import 'package:solera_huerta/modelos/cultivo.dart';
import 'package:solera_huerta/modelos/insumo.dart';
import 'package:solera_huerta/modelos/lote_semilla.dart';
import 'package:solera_huerta/modelos/parcela.dart';
import 'package:solera_huerta/modelos/siembra.dart';
import 'package:solera_huerta/modelos/titular.dart';
import 'package:solera_huerta/modelos/tratamiento.dart';
import 'package:solera_huerta/provisional_core/venta_directa/cesta.dart';
import 'package:solera_huerta/provisional_core/venta_directa/entrega.dart';
import 'package:solera_huerta/provisional_core/venta_directa/socio.dart';
import 'package:solera_huerta/provisional_core/venta_directa/suscripcion.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraHuerta.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  Future<({int parcela, int bancal, int cultivo})> sembrado() async {
    final parcela = await baseDatos.guardarParcela(Parcela(nombre: 'La Vega'));
    final bancal =
        await baseDatos.guardarBancal(Bancal(parcelaId: parcela, nombre: 'B1'));
    final cultivo = await baseDatos
        .guardarCultivo(Cultivo(especieId: 'tomate', familiaId: 'solanaceas'));
    return (parcela: parcela, bancal: bancal, cultivo: cultivo);
  }

  test('crea $nombreFicheroBaseDatosHuerta en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaHuerta);
    expect(
        File(entorno.ruta(nombreFicheroBaseDatosHuerta)).existsSync(), isTrue);
  });

  test('el esquema creado coincide con las sentencias v1', () async {
    final db = await baseDatos.basedatos;
    expect(await leerColumnasPorTabla(db),
        await columnasDeEsquemaV1(sentenciasEsquemaHuertaV1));
  });

  test('el titular se guarda en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos
        .guardarTitular(Titular(nombre: 'Segunda', organismoControl: 'CPAEN'));
    final filas = await (await baseDatos.basedatos).query('titulares');
    expect(filas, hasLength(1));
    final titular = await baseDatos.obtenerTitular();
    expect(titular.nombre, 'Segunda');
    expect(titular.organismoControl, 'CPAEN');
  });

  test('una parcela vacía se borra con sus bancales', () async {
    final parcela = await baseDatos.guardarParcela(Parcela(nombre: 'P'));
    await baseDatos.guardarBancal(Bancal(parcelaId: parcela, nombre: 'B1'));
    await baseDatos.borrarParcela(parcela);
    expect(await baseDatos.listarBancales(), isEmpty);
  });

  test('no se borra un bancal ni un cultivo con siembras', () async {
    final ids = await sembrado();
    await baseDatos.guardarSiembra(Siembra(
        bancalId: ids.bancal, cultivoId: ids.cultivo, fechaPrevistaMs: 5));
    await expectLater(baseDatos.borrarBancal(ids.bancal), throwsA(anything));
    await expectLater(baseDatos.borrarCultivo(ids.cultivo), throwsA(anything));
    await expectLater(baseDatos.borrarParcela(ids.parcela), throwsA(anything));
    expect(await baseDatos.listarBancales(), hasLength(1));
  });

  test('no se borra un insumo aplicado', () async {
    final ids = await sembrado();
    final insumo = await baseDatos
        .guardarInsumo(Insumo(nombre: 'Compost', permitidoEcologico: true));
    await baseDatos.guardarTratamiento(
        Tratamiento(parcelaId: ids.parcela, insumoId: insumo, fechaMs: 10));
    await expectLater(baseDatos.borrarInsumo(insumo), throwsA(anything));
  });

  test('bancales activos de una parcela', () async {
    final parcela = await baseDatos.guardarParcela(Parcela(nombre: 'P'));
    await baseDatos.guardarBancal(Bancal(parcelaId: parcela, nombre: 'B2'));
    await baseDatos
        .guardarBancal(Bancal(parcelaId: parcela, nombre: 'B1', activo: false));
    expect(
        (await baseDatos.listarBancales(parcelaId: parcela))
            .map((b) => b.nombre),
        ['B1', 'B2']);
    expect(
        (await baseDatos.listarBancales(soloActivos: true))
            .map((b) => b.nombre),
        ['B2']);
  });

  test('serie escalonada en una transacción y filtro por fechas', () async {
    final ids = await sembrado();
    final guardadas = await baseDatos.guardarSiembras([
      for (final fecha in [10, 20, 30])
        Siembra(
            bancalId: ids.bancal,
            cultivoId: ids.cultivo,
            fechaPrevistaMs: fecha,
            serieEscalonada: 'S1'),
    ]);
    expect(guardadas, hasLength(3));
    expect(
        (await baseDatos.listarSiembras(desdeMs: 15, hastaMs: 30))
            .map((siembra) => siembra.fechaPrevistaMs),
        [30, 20]);
  });

  test('cosecha con su siembra y lote de semilla propio', () async {
    final ids = await sembrado();
    final siembra = await baseDatos.guardarSiembra(Siembra(
        bancalId: ids.bancal, cultivoId: ids.cultivo, fechaPrevistaMs: 1));
    final cosecha = await baseDatos.guardarCosecha(Cosecha(
        bancalId: ids.bancal,
        cultivoId: ids.cultivo,
        siembraId: siembra,
        fechaMs: 100,
        kg: 12.5,
        destino: 'semilla'));
    await baseDatos.guardarLoteSemilla(LoteSemilla(
        codigo: 'TOM-2026',
        especieId: 'tomate',
        origen: 'propia',
        cosechaOrigenId: cosecha));
    expect(
        (await baseDatos.listarLotesSemilla()).single.cosechaOrigenId, cosecha);
    await baseDatos.borrarSiembra(siembra);
    expect((await baseDatos.listarCosechas()).single.siembraId, isNull);
  });

  test('cesta con líneas: guardar de nuevo sustituye las líneas', () async {
    final ids = await sembrado();
    final socio = await baseDatos.guardarSocio(Socio(nombre: 'Amaia'));
    final suscripcion = await baseDatos
        .guardarSuscripcion(Suscripcion(socioId: socio, fechaInicioMs: 0));
    final cesta = Cesta(suscripcionId: suscripcion, semanaLunesMs: 1000);
    final primera = await baseDatos.guardarCestaConLineas(cesta, [
      LineaCesta(cestaId: 0, cultivoId: ids.cultivo, kg: 1),
      LineaCesta(cestaId: 0, cultivoId: ids.cultivo, unidades: 2),
    ]);
    final segunda = await baseDatos.guardarCestaConLineas(
        cesta, [LineaCesta(cestaId: 0, cultivoId: ids.cultivo, kg: 2)]);
    expect(segunda, primera);
    final lineas = await baseDatos.listarLineasCesta(cestaIds: [primera]);
    expect(lineas.single.kg, 2);
    await baseDatos.guardarEntrega(Entrega(cestaId: primera, fechaMs: 1200));
    expect(await baseDatos.listarEntregas(cestaIds: [primera]), hasLength(1));
    await expectLater(
        baseDatos.borrarSuscripcion(suscripcion), throwsA(anything));
    await baseDatos.borrarCesta(primera);
    expect(await baseDatos.listarLineasCesta(), isEmpty);
    expect(await baseDatos.listarEntregas(), isEmpty);
  });

  test('cestas por semana', () async {
    final socio = await baseDatos.guardarSocio(Socio(nombre: 'Jon'));
    final suscripcion = await baseDatos
        .guardarSuscripcion(Suscripcion(socioId: socio, fechaInicioMs: 0));
    for (final semana in [100, 200]) {
      await baseDatos.guardarCesta(
          Cesta(suscripcionId: suscripcion, semanaLunesMs: semana));
    }
    expect(await baseDatos.listarCestas(semanaLunesMs: 200), hasLength(1));
    expect(await baseDatos.listarLineasCesta(cestaIds: []), isEmpty);
  });
}
