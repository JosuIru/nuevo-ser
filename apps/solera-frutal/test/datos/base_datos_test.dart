import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_frutal/datos/base_datos.dart';
import 'package:solera_frutal/modelos/titular.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSoleraFrutal.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea $nombreFicheroBaseDatosFrutal en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaFrutal);
    expect(File(entorno.ruta(nombreFicheroBaseDatosFrutal)).existsSync(), isTrue);
  });

  test('el titular se guarda en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos.guardarTitular(Titular(nombre: 'Segunda'));
    final filas = await (await baseDatos.basedatos).query('titulares');
    expect(filas, hasLength(1));
    expect((await baseDatos.obtenerTitular()).nombre, 'Segunda');
  });
}
