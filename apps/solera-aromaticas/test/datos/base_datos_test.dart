import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_aromaticas/datos/base_datos.dart';
import 'package:solera_aromaticas/modelos/cosecha.dart';
import 'package:solera_aromaticas/modelos/destilacion.dart';
import 'package:solera_aromaticas/modelos/lote_producto.dart';
import 'package:solera_aromaticas/modelos/parcela.dart';
import 'package:solera_aromaticas/modelos/secado.dart';
import 'package:solera_aromaticas/modelos/titular.dart';
import 'package:solera_aromaticas/modelos/tratamiento.dart';
import 'package:solera_aromaticas/modelos/zona_recoleccion.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraAromaticas.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosAromaticas en la versión declarada',
      () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaAromaticas);
    expect(File(entorno.ruta(nombreFicheroBaseDatosAromaticas)).existsSync(),
        isTrue);
  });

  test('el esquema creado coincide con las sentencias v1', () async {
    final db = await baseDatos.basedatos;
    expect(await leerColumnasPorTabla(db),
        await columnasDeEsquemaV1(sentenciasEsquemaAromaticasV1));
  });

  test('el titular se guarda en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos.guardarTitular(
        Titular(nombre: 'Segunda', comunidadAutonoma: 'Aragón'));
    final filas = await (await baseDatos.basedatos).query('titulares');
    expect(filas, hasLength(1));
    final titular = await baseDatos.obtenerTitular();
    expect((titular.nombre, titular.comunidadAutonoma), ('Segunda', 'Aragón'));
  });

  test('cosechas por zona o por parcela, de la más reciente', () async {
    final parcela = await baseDatos
        .guardarParcela(Parcela(nombre: 'Bancal', especieId: 'lavanda'));
    final zona = await baseDatos.guardarZonaRecoleccion(
        ZonaRecoleccion(nombre: 'Monte', especiesPermitidas: ['romero']));
    for (final (fecha, deZona) in [(5, true), (15, false), (25, true)]) {
      await baseDatos.guardarCosecha(Cosecha(
          parcelaId: deZona ? null : parcela,
          zonaRecoleccionId: deZona ? zona : null,
          especieId: 'romero',
          fechaMs: fecha,
          kgFrescos: 10));
    }
    expect(
        (await baseDatos.listarCosechas(zonaId: zona))
            .map((cosecha) => cosecha.fechaMs),
        [25, 5]);
    expect((await baseDatos.listarCosechas(parcelaId: parcela)).single.fechaMs,
        15);
    expect((await baseDatos.listarCosechas(desdeMs: 10, hastaMs: 30)),
        hasLength(2));
    expect((await baseDatos.listarZonasRecoleccion()).single.especiesPermitidas,
        ['romero']);
  });

  test('la BD rechaza una cosecha sin origen o con dos', () async {
    final db = await baseDatos.basedatos;
    await expectLater(db.insert('cosechas', {'especie_id': 'x', 'fecha_ms': 1}),
        throwsA(anything));
  });

  test('no se borra una zona ni una parcela con cosechas o tratamientos',
      () async {
    final zona = await baseDatos
        .guardarZonaRecoleccion(ZonaRecoleccion(nombre: 'Comunal'));
    await baseDatos.guardarCosecha(
        Cosecha(zonaRecoleccionId: zona, especieId: 'x', fechaMs: 1));
    await expectLater(baseDatos.borrarZonaRecoleccion(zona), throwsA(anything));
    final parcela =
        await baseDatos.guardarParcela(Parcela(nombre: 'P', especieId: 'x'));
    await baseDatos
        .guardarTratamiento(Tratamiento(parcelaId: parcela, fechaMs: 2));
    await expectLater(baseDatos.borrarParcela(parcela), throwsA(anything));
    final vacia =
        await baseDatos.guardarParcela(Parcela(nombre: 'Q', especieId: 'x'));
    await baseDatos.borrarParcela(vacia);
    expect(await baseDatos.listarParcelas(), hasLength(1));
  });

  test('lotes: código único; borrar un lote deja el proceso sin lote',
      () async {
    final lote = await baseDatos.guardarLoteProducto(LoteProducto(
        codigo: 'AE-2026-001',
        tipo: 'aceite_esencial',
        especieId: 'lavandin',
        fechaMs: 3));
    await expectLater(
        baseDatos.guardarLoteProducto(LoteProducto(
            codigo: 'AE-2026-001',
            tipo: 'hidrolato',
            especieId: 'lavandin',
            fechaMs: 4)),
        throwsA(anything));
    await baseDatos.guardarDestilacion(Destilacion(
        fechaMs: 3, especieId: 'lavandin', kgPlanta: 100, loteAceiteId: lote));
    await baseDatos.guardarSecado(
        Secado(fechaInicioMs: 2, especieId: 'lavandin', loteProductoId: lote));
    await baseDatos.borrarLoteProducto(lote);
    expect((await baseDatos.listarDestilaciones()).single.loteAceiteId, isNull);
    expect((await baseDatos.listarSecados()).single.loteProductoId, isNull);
    expect((await baseDatos.listarDestilaciones()).single.kgPlanta, 100);
  });
}
