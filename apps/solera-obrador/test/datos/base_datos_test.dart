import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:solera_obrador/datos/base_datos.dart';
import 'package:solera_obrador/dominio/etiqueta_venta.dart';
import 'package:solera_obrador/dominio/planificador_hornada.dart';
import 'package:solera_obrador/dominio/tiempos_guia.dart';
import 'package:solera_obrador/modelos/plan_hornada.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show databaseFactoryFfi;
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

  test('migra de la v1 a la v2 sin perder filas', () async {
    final ruta = entorno.ruta(nombreFicheroBaseDatosObrador);
    final v1 = await databaseFactoryFfi.openDatabase(ruta,
        options: OpenDatabaseOptions(
            version: 1,
            singleInstance: false,
            onCreate: (db, _) async {
              for (final sentencia in sentenciasEsquemaV1Obrador) {
                await db.execute(sentencia);
              }
            }));
    await v1.insert('masas_madre',
        {'nombre': 'Centeno', 'harina_base': 'Centeno', 'creada_ms': 5});
    await v1.insert('recetas', {'nombre': 'Hogaza'});
    await v1.close();

    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquemaObrador);
    final masa = (await baseDatos.listarMasasMadre()).single;
    expect(masa.nombre, 'Centeno');
    expect(masa.recordatorioHoras, isNull);
    await baseDatos.guardarMasaMadre(masa.conRecordatorio(24));
    expect((await baseDatos.listarMasasMadre()).single.recordatorioHoras, 24);
    expect((await baseDatos.listarRecetas()).single.nombre, 'Hogaza');
  });

  test('tiempos de una receta propia y planes en curso', () async {
    final pan = await baseDatos.guardarReceta(Receta(nombre: 'Pan'));
    expect(await baseDatos.obtenerTiemposReceta(pan), isNull);
    await baseDatos.guardarTiemposReceta(pan, plantillaRecetaPropiaPorDefecto);
    await baseDatos.guardarTiemposReceta(pan, tiemposRecetasGuia['baguette']!);
    final leida = (await baseDatos.obtenerTiemposReceta(pan))!;
    expect(leida.admiteNevera, isTrue);

    final fases = planificarHaciaAtras(
        plantilla: leida,
        listoA: DateTime(2026, 11, 12, 8),
        temperaturaCocinaC: 20);
    final planId = await baseDatos.guardarPlanHornada(PlanHornada(
        nombre: 'Pan',
        recetaId: pan,
        listoMs: DateTime(2026, 11, 12, 8).millisecondsSinceEpoch,
        temperaturaCocinaC: 20,
        fases: fases,
        creadoMs: 1));
    final plan = (await baseDatos.listarPlanesEnCurso()).single;
    expect(plan.fases.length, fases.length);
    await baseDatos.guardarPlanHornada(plan.copiar(terminado: true));
    expect(await baseDatos.listarPlanesEnCurso(), isEmpty);
    // Borrar la receta deja el plan (sin receta) y se lleva sus tiempos.
    await baseDatos.borrarReceta(pan);
    expect((await baseDatos.obtenerPlanHornada(planId))!.recetaId, isNull);
    expect(await baseDatos.obtenerTiemposReceta(pan), isNull);
  });

  test('migra de la v2 a la v3: dirección del titular y datos de etiqueta',
      () async {
    final ruta = entorno.ruta(nombreFicheroBaseDatosObrador);
    final v2 = await databaseFactoryFfi.openDatabase(ruta,
        options: OpenDatabaseOptions(
            version: 2,
            singleInstance: false,
            onCreate: (db, _) async {
              for (final sentencia in [
                ...sentenciasEsquemaV1Obrador,
                ...sentenciasEsquemaV2Obrador
              ]) {
                await db.execute(sentencia);
              }
            }));
    await v2.insert('titulares', {'nombre': 'Obrador'});
    final recetaId = await v2.insert('recetas', {'nombre': 'Hogaza'});
    await v2.close();

    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), 3);
    final titular = await baseDatos.obtenerTitular();
    expect(titular.nombre, 'Obrador');
    expect(titular.direccion, '');
    await baseDatos.guardarTitular(
        Titular(nombre: 'Obrador', direccion: 'Calle Mayor 1'));
    expect((await baseDatos.obtenerTitular()).direccion, 'Calle Mayor 1');

    expect(await baseDatos.obtenerDatosEtiqueta(recetaId), isNull);
    await baseDatos.guardarDatosEtiqueta(
        recetaId, const DatosEtiquetaReceta(diasDuracion: 3));
    await baseDatos.guardarDatosEtiqueta(recetaId,
        const DatosEtiquetaReceta(diasDuracion: 5, trazasIndicadas: {'soja'}));
    final datos = (await baseDatos.obtenerDatosEtiqueta(recetaId))!;
    expect(datos.diasDuracion, 5);
    expect(datos.trazasIndicadas, {'soja'});
    // Borrar la receta se lleva sus datos de etiqueta.
    await baseDatos.borrarReceta(recetaId);
    expect(await baseDatos.obtenerDatosEtiqueta(recetaId), isNull);
  });
}
