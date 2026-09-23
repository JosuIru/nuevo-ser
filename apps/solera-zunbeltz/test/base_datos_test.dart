// Tests de la base de datos (FZ-2) con sqflite_common_ffi en memoria.
// Cubren el contrato CRUD y, sobre todo, las cascadas de borrado: borrar
// una finca arrastra sus puntos y tareas; borrar un punto deja sus tareas
// huérfanas (punto_id = NULL) sin perderlas.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/modelos/punto_infraestructura.dart';
import 'package:solera_zunbeltz/modelos/registro_actividad.dart';
import 'package:solera_zunbeltz/modelos/registro_comercializacion.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/modelos/validacion_producto.dart';
import 'package:solera_zunbeltz/modelos/zona_finca.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  Future<BaseDatosSoleraZunbeltz> abrirBdEnMemoria() async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 8,
        // BD nueva por test: sin esto, todas las llamadas comparten la
        // misma BD en memoria y el estado se filtra entre tests.
        singleInstance: false,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV6(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV7(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV8(d);
        },
      ),
    );
    return BaseDatosSoleraZunbeltz.paraTests(db);
  }

  test('alta finca → punto → tarea y lectura', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final puntoId = await bd.guardarPunto(
        PuntoInfraestructura(fincaId: fincaId, tipo: 'abrevadero'));
    final tareaId = await bd.guardarTarea(TareaMantenimiento(
      fincaId: fincaId,
      puntoId: puntoId,
      titulo: 'Revisar fuga',
      estado: 'pendiente',
    ));

    expect((await bd.listarFincas()).single.nombre, 'Zunbeltz');
    expect((await bd.listarPuntos(fincaId: fincaId)).single.id, puntoId);
    expect((await bd.obtenerTarea(tareaId))!.titulo, 'Revisar fuga');
    expect(await bd.contarTareasAbiertas(), 1);
  });

  test('filtros de listarTareas (estado y responsable)', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'La Planilla'));
    await bd.guardarTarea(TareaMantenimiento(
        fincaId: fincaId, titulo: 'A', estado: 'pendiente', responsable: 'Maite'));
    await bd.guardarTarea(TareaMantenimiento(
        fincaId: fincaId, titulo: 'B', estado: 'hecha', responsable: 'Iñaki'));

    expect((await bd.listarTareas(estado: 'pendiente')).single.titulo, 'A');
    expect((await bd.listarTareas(responsable: 'Iñaki')).single.titulo, 'B');
    expect((await bd.listarTareas()).length, 2);
    expect(await bd.contarTareasAbiertas(), 1);
  });

  test('borrar finca arrastra sus puntos y tareas (CASCADE)', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final puntoId =
        await bd.guardarPunto(PuntoInfraestructura(fincaId: fincaId));
    await bd.guardarTarea(
        TareaMantenimiento(fincaId: fincaId, puntoId: puntoId, titulo: 'T'));

    await bd.borrarFinca(fincaId);

    expect(await bd.listarFincas(), isEmpty);
    expect(await bd.listarPuntos(fincaId: fincaId), isEmpty);
    expect(await bd.listarTareas(fincaId: fincaId), isEmpty);
  });

  test('borrar punto deja sus tareas huérfanas, no las borra (SET NULL)',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final puntoId =
        await bd.guardarPunto(PuntoInfraestructura(fincaId: fincaId));
    final tareaId = await bd.guardarTarea(
        TareaMantenimiento(fincaId: fincaId, puntoId: puntoId, titulo: 'T'));

    await bd.borrarPunto(puntoId);

    final tarea = await bd.obtenerTarea(tareaId);
    expect(tarea, isNotNull);
    expect(tarea!.puntoId, isNull, reason: 'la tarea sobrevive sin punto');
    expect(tarea.fincaId, fincaId);
  });

  test('sembrarFincasDemoSiVacia siembra solo una vez', () async {
    final bd = await abrirBdEnMemoria();
    expect(await bd.sembrarFincasDemoSiVacia(), isTrue);
    expect((await bd.listarFincas()).length, 2);
    // Segunda llamada no duplica.
    expect(await bd.sembrarFincasDemoSiVacia(), isFalse);
    expect((await bd.listarFincas()).length, 2);
  });

  test('seguimiento: registros y agregados de actividad', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    await bd.guardarRegistro(RegistroActividad(
        fincaId: fincaId, tipo: 'alimentacion', cantidad: 100, fechaMs: 10));
    await bd.guardarRegistro(RegistroActividad(
        fincaId: fincaId, tipo: 'alimentacion', cantidad: 50, fechaMs: 20));
    await bd.guardarRegistro(RegistroActividad(
        fincaId: fincaId, tipo: 'paricion', cantidad: 3, fechaMs: 30));

    expect(await bd.sumarCantidadActividad('alimentacion', fincaId: fincaId), 150);
    expect(await bd.sumarCantidadActividad('paricion', fincaId: fincaId), 3);
    expect(await bd.sumarCantidadActividad('producto', fincaId: fincaId), 0);
    expect((await bd.listarRegistros(fincaId: fincaId)).length, 3);
    // Filtro por rango de fechas.
    expect(
        await bd.sumarCantidadActividad('alimentacion',
            fincaId: fincaId, desdeMs: 15),
        50);
  });

  test('seguimiento: apuntes económicos y balance', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId, tipo: 'ingreso', importeCentimos: 50000, fechaMs: 1));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId, tipo: 'gasto', importeCentimos: 18000, fechaMs: 2));

    expect(await bd.sumarImporteEconomico('ingreso', fincaId: fincaId), 50000);
    expect(await bd.sumarImporteEconomico('gasto', fincaId: fincaId), 18000);
    expect((await bd.listarApuntes(fincaId: fincaId)).length, 2);
  });

  test('migración v1 → v3 (cadena completa) conserva datos y habilita seguimiento',
      () async {
    final dir = await Directory.systemTemp.createTemp('zunbeltz_mig');
    final ruta = '${dir.path}/migracion.db';
    // Abrimos en v1 (solo gestión de fincas) y metemos una finca.
    final v1 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) => BaseDatosSoleraZunbeltz.crearEsquemaV1(d),
      ),
    );
    await v1.insert('fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
    await v1.close();

    // Reabrimos en v3: las migraciones v2 y v3 deben correr en cadena y
    // conservar la finca.
    final v3 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 3,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (d, anterior, actual) async {
          if (anterior < 2) await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          if (anterior < 3) await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
        },
      ),
    );
    final bd = BaseDatosSoleraZunbeltz.paraTests(v3);
    expect((await bd.listarFincas()).single.nombre, 'Zunbeltz');
    // El seguimiento existe y funciona (incluida la columna proyecto_id de v3).
    final fincaId = (await bd.listarFincas()).single.id!;
    await bd.guardarRegistro(RegistroActividad(
        fincaId: fincaId, tipo: 'alimentacion', cantidad: 10));
    expect(await bd.sumarCantidadActividad('alimentacion'), 10);
    await v3.close();
    await dir.delete(recursive: true);
  });

  test('proceso de test: proyecto + comercialización + validación', () async {
    final bd = await abrirBdEnMemoria();
    final proyectoId = await bd.guardarProyecto(
        ProyectoTest(nombre: 'Quesería test', persona: 'Maite'));
    await bd.guardarComercializacion(RegistroComercializacion(
        proyectoId: proyectoId,
        producto: 'Queso',
        canal: 'directa',
        cantidad: 10,
        precioUnitarioCentimos: 1200,
        ingresoCentimos: 12000));
    await bd.guardarValidacion(ValidacionProducto(
        proyectoId: proyectoId,
        descripcion: 'Curación 60 días',
        resultado: 'validado',
        valoracion: 4));

    expect((await bd.listarProyectos()).single.persona, 'Maite');
    expect((await bd.listarComercializacion(proyectoId: proyectoId)).single.producto, 'Queso');
    expect(await bd.sumarIngresoComercializacion(proyectoId: proyectoId), 12000);
    expect((await bd.listarValidaciones(proyectoId: proyectoId)).single.resultado, 'validado');
  });

  test('rentabilidad por proyecto = ingresos (comercial+apuntes) − gastos',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final proyectoId = await bd.guardarProyecto(
        ProyectoTest(nombre: 'P', persona: 'Iñaki', fincaId: fincaId));
    await bd.guardarComercializacion(RegistroComercializacion(
        proyectoId: proyectoId, ingresoCentimos: 30000));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: 'ingreso',
        importeCentimos: 5000));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: 'gasto',
        importeCentimos: 12000));

    final r = await bd.rentabilidadProyecto(proyectoId);
    expect(r.ingresosComercializacionCentimos, 30000);
    expect(r.ingresosApuntesCentimos, 5000);
    expect(r.gastosCentimos, 12000);
    expect(r.balanceCentimos, 23000); // 35000 - 12000
    expect(r.balanceAnualExtrapoladoCentimos(73), 115000); // 23000 * 365/73
  });

  test('borrar proyecto arrastra su comercialización y validaciones (CASCADE)',
      () async {
    final bd = await abrirBdEnMemoria();
    final proyectoId =
        await bd.guardarProyecto(ProyectoTest(nombre: 'P', persona: 'A'));
    await bd.guardarComercializacion(
        RegistroComercializacion(proyectoId: proyectoId, ingresoCentimos: 100));
    await bd.guardarValidacion(ValidacionProducto(proyectoId: proyectoId));

    await bd.borrarProyecto(proyectoId);

    expect(await bd.listarProyectos(), isEmpty);
    expect(await bd.listarComercializacion(proyectoId: proyectoId), isEmpty);
    expect(await bd.listarValidaciones(proyectoId: proyectoId), isEmpty);
  });

  test('migración v2 → v3 conserva datos y habilita proceso de test', () async {
    final dir = await Directory.systemTemp.createTemp('zunbeltz_mig3');
    final ruta = '${dir.path}/m3.db';
    final v2 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 2,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
        },
      ),
    );
    await v2.insert('fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
    await v2.close();

    final v3 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 4,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (d, anterior, actual) async {
          if (anterior < 3) await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
          if (anterior < 4) await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
        },
      ),
    );
    final bd = BaseDatosSoleraZunbeltz.paraTests(v3);
    expect((await bd.listarFincas()).single.nombre, 'Zunbeltz');
    // La tabla nueva funciona y el seguimiento ya admite proyecto_id.
    final proyectoId =
        await bd.guardarProyecto(ProyectoTest(nombre: 'P', persona: 'A'));
    final fincaId = (await bd.listarFincas()).single.id!;
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: 'gasto',
        importeCentimos: 999));
    expect(await bd.sumarImporteEconomico('gasto', proyectoId: proyectoId), 999);
    await v3.close();
    await dir.delete(recursive: true);
  });

  test('desglose por categoría y persistencia de IVA', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final proyectoId =
        await bd.guardarProyecto(ProyectoTest(nombre: 'P', persona: 'A'));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: 'gasto',
        categoria: 'alimentacion',
        importeCentimos: 10000,
        ivaPorcentaje: 10));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: 'gasto',
        categoria: 'sanidad',
        importeCentimos: 4000));
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        proyectoId: proyectoId,
        tipo: 'gasto',
        categoria: 'alimentacion',
        importeCentimos: 6000));

    final desglose =
        await bd.desglosePorCategoria('gasto', proyectoId: proyectoId);
    expect(desglose['alimentacion'], 16000);
    expect(desglose['sanidad'], 4000);
    // El IVA se persiste.
    final apunte = (await bd.listarApuntes(proyectoId: proyectoId))
        .firstWhere((a) => a.categoria == 'alimentacion' && a.ivaPorcentaje == 10);
    expect(apunte.ivaPorcentaje, 10);
  });

  test('migración v3 → v4 conserva datos y añade categoría/IVA', () async {
    final dir = await Directory.systemTemp.createTemp('zunbeltz_mig4');
    final ruta = '${dir.path}/m4.db';
    final v3 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 3,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
        },
      ),
    );
    final fincaId =
        await v3.insert('fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
    await v3.close();

    final v4 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 4,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (d, anterior, actual) async {
          if (anterior < 4) await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
        },
      ),
    );
    final bd = BaseDatosSoleraZunbeltz.paraTests(v4);
    expect((await bd.listarFincas()).single.nombre, 'Zunbeltz');
    // La columna categoría existe y funciona el desglose.
    await bd.guardarApunte(ApunteEconomico(
        fincaId: fincaId,
        tipo: 'gasto',
        categoria: 'insumos',
        importeCentimos: 500));
    final desglose = await bd.desglosePorCategoria('gasto');
    expect(desglose['insumos'], 500);
    await v4.close();
    await dir.delete(recursive: true);
  });

  // ─── Zonas dibujadas (FZ-3b) ──────────────────────────────

  test('alta de zona: guarda trazado, superficie y tarea anclada', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final zonaId = await bd.guardarZona(ZonaFinca.desdeTrazado(
      fincaId: fincaId,
      nombre: 'Larre handia',
      tipo: 'parcela_pasto',
      vertices: [
        LatLng(42.700, -2.050),
        LatLng(42.700, -2.049),
        LatLng(42.701, -2.049),
        LatLng(42.701, -2.050),
      ],
    ));

    final zona = await bd.obtenerZona(zonaId);
    expect(zona!.nombre, 'Larre handia');
    expect(zona.vertices.length, 4);
    expect(zona.superficieHaCalculada, greaterThan(0));

    await bd.guardarTarea(TareaMantenimiento(
        fincaId: fincaId, zonaId: zonaId, titulo: 'Desbrozar'));
    final tareasDeLaZona = await bd.listarTareas(zonaId: zonaId);
    expect(tareasDeLaZona.single.titulo, 'Desbrozar');
  });

  test('borrar zona desancla sus tareas, no las borra', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'La Planilla'));
    final zonaId = await bd.guardarZona(ZonaFinca.desdeTrazado(
      fincaId: fincaId,
      vertices: [
        LatLng(42.70, -2.05),
        LatLng(42.70, -2.04),
        LatLng(42.71, -2.04),
      ],
    ));
    await bd.guardarTarea(TareaMantenimiento(
        fincaId: fincaId, zonaId: zonaId, titulo: 'Cerrar paso'));

    await bd.borrarZona(zonaId);

    expect(await bd.obtenerZona(zonaId), isNull);
    final tareas = await bd.listarTareas(fincaId: fincaId);
    expect(tareas.single.titulo, 'Cerrar paso');
    expect(tareas.single.zonaId, isNull);
  });

  test('borrar finca arrastra sus zonas (CASCADE)', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    await bd.guardarZona(ZonaFinca.desdeTrazado(
      fincaId: fincaId,
      vertices: [
        LatLng(42.70, -2.05),
        LatLng(42.70, -2.04),
        LatLng(42.71, -2.04),
      ],
    ));
    expect((await bd.listarZonas()).length, 1);

    await bd.borrarFinca(fincaId);
    expect(await bd.listarZonas(), isEmpty);
  });

  test('actualizarTrazadoZona recalcula la superficie', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final zonaId = await bd.guardarZona(ZonaFinca.desdeTrazado(
      fincaId: fincaId,
      vertices: [
        LatLng(42.700, -2.050),
        LatLng(42.700, -2.049),
        LatLng(42.701, -2.049),
        LatLng(42.701, -2.050),
      ],
    ));
    final superficieInicial =
        (await bd.obtenerZona(zonaId))!.superficieHaCalculada;

    await bd.actualizarTrazadoZona(zonaId, [
      LatLng(42.700, -2.050),
      LatLng(42.700, -2.046),
      LatLng(42.702, -2.046),
      LatLng(42.702, -2.050),
    ]);

    final ampliada = (await bd.obtenerZona(zonaId))!;
    expect(ampliada.vertices.length, 4);
    expect(ampliada.superficieHaCalculada, greaterThan(superficieInicial * 3));
  });

  test('superficie total de zonas usa la oficial cuando existe', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final triangulo = [
      LatLng(42.70, -2.05),
      LatLng(42.70, -2.04),
      LatLng(42.71, -2.04),
    ];
    await bd.guardarZona(ZonaFinca.desdeTrazado(
        fincaId: fincaId, vertices: triangulo, superficieHaOficial: 2.5));
    await bd.guardarZona(ZonaFinca.desdeTrazado(
        fincaId: fincaId, vertices: triangulo, superficieHaOficial: 1.5));

    expect(await bd.superficieTotalZonasHa(fincaId: fincaId), closeTo(4.0, 1e-9));
  });

  test('listarZonas filtra por finca', () async {
    final bd = await abrirBdEnMemoria();
    final zunbeltz = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final planilla = await bd.guardarFinca(Finca(nombre: 'La Planilla'));
    final triangulo = [
      LatLng(42.70, -2.05),
      LatLng(42.70, -2.04),
      LatLng(42.71, -2.04),
    ];
    await bd.guardarZona(
        ZonaFinca.desdeTrazado(fincaId: zunbeltz, vertices: triangulo));
    await bd.guardarZona(
        ZonaFinca.desdeTrazado(fincaId: planilla, vertices: triangulo));

    expect((await bd.listarZonas(fincaId: zunbeltz)).length, 1);
    expect((await bd.listarZonas()).length, 2);
  });

  test('migración v4 → v5 conserva datos y habilita zonas', () async {
    final dir = await Directory.systemTemp.createTemp('zunbeltz_mig5');
    final ruta = '${dir.path}/m5.db';
    final v4 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 4,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
        },
      ),
    );
    final fincaId = await v4.insert(
        'fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
    // Fila escrita con el esquema v4: sin zona_id, como la tendría una app
    // ya instalada en el móvil de alguien.
    await v4.insert(
        'tareas_mantenimiento',
        TareaMantenimiento(fincaId: fincaId, titulo: 'Revisar abrevadero')
            .toMap()
          ..remove('id')
          ..remove('zona_id')
          ..remove('recurrencia_dias')
          ..remove('uid')
          ..remove('actualizado_ms')
          ..remove('responsable_uid')
          ..remove('creado_por_uid'));
    await v4.close();

    final v5 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 5,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (d, anterior, actual) async {
          if (anterior < 5) await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
        },
      ),
    );
    final bd = BaseDatosSoleraZunbeltz.paraTests(v5);

    // La tarea anterior sigue ahí y ahora no está anclada a ninguna zona.
    final tareas = await bd.listarTareas();
    expect(tareas.single.titulo, 'Revisar abrevadero');
    expect(tareas.single.zonaId, isNull);

    // Y ya se pueden dibujar zonas sobre la finca que ya existía.
    final zonaId = await bd.guardarZona(ZonaFinca.desdeTrazado(
      fincaId: fincaId,
      nombre: 'Cercado nuevo',
      vertices: [
        LatLng(42.70, -2.05),
        LatLng(42.70, -2.04),
        LatLng(42.71, -2.04),
      ],
    ));
    expect((await bd.obtenerZona(zonaId))!.nombre, 'Cercado nuevo');

    await v5.close();
    await dir.delete(recursive: true);
  });

  test('migración v5 → v6 conserva datos y habilita recurrencia', () async {
    final dir = await Directory.systemTemp.createTemp('zunbeltz_mig6');
    final ruta = '${dir.path}/m6.db';
    final v5 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 5,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
        },
      ),
    );
    final fincaId = await v5.insert(
        'fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
    // Fila escrita con el esquema v5: sin recurrencia_dias, como la tendría
    // una app ya instalada en el móvil de alguien.
    await v5.insert(
        'tareas_mantenimiento',
        TareaMantenimiento(fincaId: fincaId, titulo: 'Rellenar comederos')
            .toMap()
          ..remove('id')
          ..remove('recurrencia_dias')
          ..remove('uid')
          ..remove('actualizado_ms')
          ..remove('responsable_uid')
          ..remove('creado_por_uid'));
    await v5.close();

    final v6 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 6,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (d, anterior, actual) async {
          if (anterior < 6) await BaseDatosSoleraZunbeltz.aplicarMigracionV6(d);
        },
      ),
    );
    final bd = BaseDatosSoleraZunbeltz.paraTests(v6);

    final tareas = await bd.listarTareas();
    expect(tareas.single.titulo, 'Rellenar comederos');
    expect(tareas.single.recurrenciaDias, isNull);
    expect(tareas.single.esRecurrente, isFalse);

    await v6.close();
    await dir.delete(recursive: true);
  });

  test('marcarTareaHecha sobre tarea puntual no genera siguiente', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final tareaId = await bd.guardarTarea(
        TareaMantenimiento(fincaId: fincaId, titulo: 'Reparar cierre'));

    final siguienteId = await bd.marcarTareaHecha(tareaId);

    expect(siguienteId, isNull);
    expect((await bd.obtenerTarea(tareaId))!.estado, 'hecha');
    expect(await bd.contarTareasAbiertas(), 0);
  });

  test('marcarTareaHecha sobre tarea recurrente genera la siguiente pendiente',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final puntoId = await bd.guardarPunto(
        PuntoInfraestructura(fincaId: fincaId, tipo: 'comedero'));
    final tareaId = await bd.guardarTarea(TareaMantenimiento(
      fincaId: fincaId,
      puntoId: puntoId,
      titulo: 'Rellenar comederos',
      responsable: 'Maite',
      prioridad: 'alta',
      recurrenciaDias: 7,
    ));

    final siguienteId = await bd.marcarTareaHecha(tareaId);

    expect(siguienteId, isNotNull);
    final original = await bd.obtenerTarea(tareaId);
    expect(original!.estado, 'hecha');

    final siguiente = await bd.obtenerTarea(siguienteId!);
    expect(siguiente, isNotNull);
    expect(siguiente!.titulo, 'Rellenar comederos');
    expect(siguiente.estado, 'pendiente');
    expect(siguiente.puntoId, puntoId);
    expect(siguiente.responsable, 'Maite');
    expect(siguiente.recurrenciaDias, 7);
    // Sin fecha objetivo previa: se cuenta desde hoy, así que la nueva fecha
    // cae aproximadamente 7 días por delante (con margen por el tiempo del test).
    final dentroDeSieteDias =
        DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;
    expect(
        (siguiente.fechaObjetivoMs! - dentroDeSieteDias).abs() < 60000, isTrue);
    expect(await bd.contarTareasAbiertas(), 1);
  });

  test(
      'marcarTareaHecha con fecha objetivo futura calcula la siguiente desde esa fecha',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final fechaObjetivo =
        DateTime.now().add(const Duration(days: 3)).millisecondsSinceEpoch;
    final tareaId = await bd.guardarTarea(TareaMantenimiento(
      fincaId: fincaId,
      titulo: 'Revisar vallado',
      fechaObjetivoMs: fechaObjetivo,
      recurrenciaDias: 30,
    ));

    final siguienteId = await bd.marcarTareaHecha(tareaId);
    final siguiente = await bd.obtenerTarea(siguienteId!);

    final esperado = fechaObjetivo + Duration(days: 30).inMilliseconds;
    expect((siguiente!.fechaObjetivoMs! - esperado).abs() < 1000, isTrue);
  });

  test('migración v6 → v7 rellena uid y actualizado_ms en filas existentes',
      () async {
    final dir = await Directory.systemTemp.createTemp('zunbeltz_mig7');
    final ruta = '${dir.path}/m7.db';
    final v6 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 6,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV6(d);
        },
      ),
    );
    final fincaId = await v6.insert(
        'fincas', Finca(nombre: 'Zunbeltz').toMap()..remove('id'));
    // Fila escrita con el esquema v6: sin uid ni actualizado_ms, como la
    // tendría una app ya instalada en el móvil de alguien.
    await v6.insert(
        'tareas_mantenimiento',
        TareaMantenimiento(
                fincaId: fincaId,
                titulo: 'Rellenar comederos',
                fechaCreacionMs: 12345)
            .toMap()
          ..remove('id')
          ..remove('uid')
          ..remove('actualizado_ms')
          ..remove('responsable_uid')
          ..remove('creado_por_uid'));
    await v6.close();

    final v7 = await databaseFactoryFfi.openDatabase(
      ruta,
      options: OpenDatabaseOptions(
        version: 7,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (d, anterior, actual) async {
          if (anterior < 7) await BaseDatosSoleraZunbeltz.aplicarMigracionV7(d);
        },
      ),
    );
    final bd = BaseDatosSoleraZunbeltz.paraTests(v7);

    final tareas = await bd.listarTareas();
    final tarea = tareas.single;
    expect(tarea.titulo, 'Rellenar comederos');
    expect(tarea.uid, isNotEmpty);
    expect(tarea.actualizadoMs, 12345);

    // Y el uid queda como clave única: no se puede duplicar.
    expect(
      () => v7.insert('tareas_mantenimiento',
          {'finca_id': fincaId, 'uid': tarea.uid, 'titulo': 'Duplicada'}),
      throwsA(isA<DatabaseException>()),
    );

    await v7.close();
    await dir.delete(recursive: true);
  });

  test('upsertTareaRemota inserta una tarea nueva por uid', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final remota = TareaMantenimiento(
      uid: 'abc123',
      fincaId: fincaId,
      titulo: 'Tarea del servidor',
      estado: 'en_curso',
      actualizadoMs: 5000,
    );

    await bd.upsertTareaRemota(remota);

    final local = await bd.obtenerTareaPorUid('abc123');
    expect(local, isNotNull);
    expect(local!.titulo, 'Tarea del servidor');
    expect(local.estado, 'en_curso');
    expect(local.actualizadoMs, 5000);
  });

  test('upsertTareaRemota no pisa una edición local más reciente', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final id = await bd.guardarTarea(TareaMantenimiento(
      uid: 'xyz789',
      fincaId: fincaId,
      titulo: 'Editada en local',
      actualizadoMs: 9000,
    ));

    final remotaVieja = TareaMantenimiento(
      uid: 'xyz789',
      fincaId: fincaId,
      titulo: 'Versión antigua del servidor',
      actualizadoMs: 1000,
    );
    await bd.upsertTareaRemota(remotaVieja);

    final local = await bd.obtenerTarea(id);
    expect(local!.titulo, 'Editada en local');
  });

  test('upsertTareaRemota sí aplica una versión remota más reciente',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    await bd.guardarTarea(TareaMantenimiento(
      uid: 'def456',
      fincaId: fincaId,
      titulo: 'Versión vieja',
      actualizadoMs: 1000,
    ));

    final remotaNueva = TareaMantenimiento(
      uid: 'def456',
      fincaId: fincaId,
      titulo: 'Versión nueva del servidor',
      estado: 'hecha',
      actualizadoMs: 9000,
    );
    await bd.upsertTareaRemota(remotaNueva);

    final local = await bd.obtenerTareaPorUid('def456');
    expect(local!.titulo, 'Versión nueva del servidor');
    expect(local.estado, 'hecha');
  });

  test('migración v8: las tareas previas quedan sin responsable_uid ni creador',
      () async {
    final v7 = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 7,
        singleInstance: false,
        onCreate: (d, v) async {
          await BaseDatosSoleraZunbeltz.crearEsquemaV1(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV2(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV3(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV4(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV5(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV6(d);
          await BaseDatosSoleraZunbeltz.aplicarMigracionV7(d);
        },
      ),
    );
    final fincaId = await v7.insert('fincas', {'nombre': 'Zunbeltz'});
    await v7.insert('tareas_mantenimiento', {
      'finca_id': fincaId,
      'uid': 'previa',
      'titulo': 'Tarea de antes de los roles',
      'responsable': 'Maite',
    });

    await BaseDatosSoleraZunbeltz.aplicarMigracionV8(v7);
    final bd = BaseDatosSoleraZunbeltz.paraTests(v7);

    final tarea = (await bd.obtenerTareaPorUid('previa'))!;
    expect(tarea.responsable, 'Maite',
        reason: 'el responsable en texto libre se conserva');
    expect(tarea.responsableUid, '');
    expect(tarea.creadoPorUid, '');
    await v7.close();
  });

  test('responsable_uid y creado_por_uid se guardan y filtran', () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    await bd.guardarTarea(TareaMantenimiento(
      fincaId: fincaId,
      titulo: 'De Ane',
      responsable: 'Ane',
      responsableUid: 'ane',
      creadoPorUid: 'coord',
    ));
    await bd.guardarTarea(TareaMantenimiento(fincaId: fincaId, titulo: 'Libre'));

    final deAne = await bd.listarTareas(responsableUid: 'ane');
    expect(deAne.single.titulo, 'De Ane');
    expect(deAne.single.creadoPorUid, 'coord');
  });

  test('la siguiente instancia de una tarea periódica conserva responsable y creador',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final id = await bd.guardarTarea(TareaMantenimiento(
      fincaId: fincaId,
      titulo: 'Rellenar comederos',
      responsable: 'Ane',
      responsableUid: 'ane',
      creadoPorUid: 'coord',
      recurrenciaDias: 7,
    ));

    final siguienteId = await bd.marcarTareaHecha(id);
    final siguiente = (await bd.obtenerTarea(siguienteId!))!;
    expect(siguiente.responsableUid, 'ane');
    expect(siguiente.creadoPorUid, 'coord');
  });

  test('upsertTareaRemota con forzar pisa una edición local más reciente',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final id = await bd.guardarTarea(TareaMantenimiento(
      uid: 'rechazada',
      fincaId: fincaId,
      titulo: 'Reparar cierre',
      estado: 'hecha', // cambio local que el servidor no permite
      actualizadoMs: 9000,
    ));

    await bd.upsertTareaRemota(
      TareaMantenimiento(
        uid: 'rechazada',
        fincaId: fincaId,
        titulo: 'Reparar cierre',
        estado: 'pendiente',
        actualizadoMs: 1000,
      ),
      forzar: true,
    );

    expect((await bd.obtenerTarea(id))!.estado, 'pendiente');
  });

  test('upsertTareaRemota conserva el anclaje local y las fotos al actualizar',
      () async {
    final bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    final puntoId = await bd.guardarPunto(
        PuntoInfraestructura(fincaId: fincaId, tipo: 'abrevadero'));
    final id = await bd.guardarTarea(TareaMantenimiento(
      uid: 'anclada',
      fincaId: fincaId,
      puntoId: puntoId,
      titulo: 'Limpiar abrevadero',
      rutasFotosAntesJson: '["antes.jpg"]',
      actualizadoMs: 1000,
    ));

    await bd.upsertTareaRemota(TareaMantenimiento(
      uid: 'anclada',
      fincaId: fincaId,
      titulo: 'Limpiar abrevadero',
      estado: 'hecha',
      actualizadoMs: 9000,
    ));

    final local = (await bd.obtenerTarea(id))!;
    expect(local.estado, 'hecha');
    expect(local.puntoId, puntoId);
    expect(local.rutasFotosAntesJson, '["antes.jpg"]');
  });
}
