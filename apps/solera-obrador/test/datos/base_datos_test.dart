import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/modelos/hornada.dart';
import 'package:solera_obrador/modelos/ingrediente.dart';
import 'package:solera_obrador/modelos/lote_ingrediente.dart';
import 'package:solera_obrador/modelos/receta.dart';
import 'package:solera_obrador/modelos/registro_autocontrol.dart';
import 'package:solera_obrador/modelos/titular.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraObrador.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosObrador en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaObrador);
    expect(
        File(entorno.ruta(nombreFicheroBaseDatosObrador)).existsSync(), isTrue);
  });

  test('el titular se guarda en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos.guardarTitular(Titular(nombre: 'Segunda'));
    final filas = await (await baseDatos.basedatos).query('titulares');
    expect(filas, hasLength(1));
    expect((await baseDatos.obtenerTitular()).nombre, 'Segunda');
  });

  test('trazabilidad: qué hornadas usaron un lote de harina', () async {
    final harina = await baseDatos.guardarIngrediente(
        Ingrediente(nombre: 'Harina', alergenos: {'gluten'}));
    final lote = await baseDatos.guardarLoteIngrediente(LoteIngrediente(
        ingredienteId: harina, codigoLote: 'H-001', fechaRecepcionMs: 1));
    final pan = await baseDatos.guardarReceta(Receta(nombre: 'Pan'));
    await baseDatos.guardarLineasReceta(
        pan, [LineaReceta(recetaId: pan, ingredienteId: harina, gramos: 1000)]);
    final hornada = await baseDatos.guardarHornada(
        Hornada(recetaId: pan, fechaMs: 10, piezas: 4, codigoLote: 'L1'),
        lotesUsados: [lote, lote]);
    expect(await baseDatos.lotesDeHornada(hornada), [lote]);
    expect((await baseDatos.hornadasConLote(lote)).single.codigoLote, 'L1');
    expect((await baseDatos.lineasPorReceta())[pan], hasLength(1));
  });

  test('no se puede borrar un ingrediente que usa una receta', () async {
    final harina =
        await baseDatos.guardarIngrediente(Ingrediente(nombre: 'Harina'));
    final pan = await baseDatos.guardarReceta(Receta(nombre: 'Pan'));
    await baseDatos.guardarLineasReceta(
        pan, [LineaReceta(recetaId: pan, ingredienteId: harina, gramos: 1)]);
    final db = await baseDatos.basedatos;
    await expectLater(
        db.delete('ingredientes', where: 'id = ?', whereArgs: [harina]),
        throwsA(anything));
    // Borrar la receta se lleva sus líneas (cascada).
    await baseDatos.borrarReceta(pan);
    expect(await db.query('lineas_receta'), isEmpty);
  });

  test('autocontrol filtrado por fechas y tipo', () async {
    for (final (fecha, tipo) in [
      (5, 'temperatura'),
      (15, 'limpieza'),
      (25, 'temperatura')
    ]) {
      await baseDatos.guardarRegistroAutocontrol(
          RegistroAutocontrol(tipo: tipo, fechaMs: fecha, elemento: 'Cámara'));
    }
    final delMes =
        await baseDatos.listarRegistrosAutocontrol(desdeMs: 0, hastaMs: 20);
    expect(delMes.map((registro) => registro.fechaMs), [5, 15]);
    final temperaturas = await baseDatos.listarRegistrosAutocontrol(
        desdeMs: 0, hastaMs: 30, tipo: 'temperatura');
    expect(temperaturas, hasLength(2));
  });
}
