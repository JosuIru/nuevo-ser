// Siembra del espacio real desde content/espacio/*.csv (compilado en
// espacio_generado.dart): fincas, puntos, zonas y las tareas de partida
// ancladas a su zona o punto, con uid fijo y marca mínima.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/datos/espacio_generado.dart';
import 'package:solera_zunbeltz/datos/esquema_sincronizable.dart';

import 'bd_en_memoria.dart';

void main() {
  late BaseDatosSoleraZunbeltz bd;

  setUp(() async => bd = await abrirBdEnMemoria());

  test('siembra fincas, puntos, zonas y tareas ancladas', () async {
    expect(await bd.sembrarEspacioRealSiVacia(), isTrue);

    final zunbeltz =
        (await bd.listarFincas()).singleWhere((f) => f.nombre == 'Zunbeltz');
    expect(zunbeltz.latitud, closeTo(42.82, 0.01));
    expect(zunbeltz.longitud, closeTo(-2.03, 0.01));

    final zonas = await bd.listarZonas(fincaId: zunbeltz.id);
    expect(zonas,
        hasLength(zonasEspacio.where((z) => z.finca == 'Zunbeltz').length));
    final planilla =
        (await bd.listarFincas()).singleWhere((f) => f.nombre == 'La Planilla');
    expect(planilla.latitud, closeTo(42.77, 0.01));
    expect((await bd.listarZonas(fincaId: planilla.id)).map((z) => z.nombre),
        contains('Prado de La Planilla'));
    final ventaVieja =
        zonas.singleWhere((z) => z.nombre == 'Pieza de la Venta Vieja');
    expect(ventaVieja.recintoSigpac, 'Pol. 24 parc. 2 subp. O');
    expect(ventaVieja.vertices.length, greaterThan(3));
    expect(ventaVieja.superficieHaCalculada, greaterThan(0.5));
    expect(ventaVieja.superficieHaCalculada, lessThan(10));

    final puntos = await bd.listarPuntos(fincaId: zunbeltz.id);
    final aprisco = puntos.singleWhere((p) => p.nombre == 'Aprisco');

    final tareas = await bd.listarTareas();
    expect(tareas, hasLength(tareasEspacio.length));
    final actuacion13 = tareas
        .singleWhere((t) => t.uid == uidSembrado('tarea', 'actuacion-13'));
    expect(actuacion13.zonaId, ventaVieja.id);
    expect(actuacion13.fincaId, zunbeltz.id);
    expect(actuacion13.estado, 'pendiente');
    final actuacion10 = tareas
        .singleWhere((t) => t.uid == uidSembrado('tarea', 'actuacion-10'));
    expect(actuacion10.puntoId, aprisco.id);
  });

  test('todo lo sembrado lleva la marca mínima (sube, pero no pisa)', () async {
    await bd.sembrarEspacioRealSiVacia();
    final db = await bd.basedatos;
    for (final tabla in [
      'fincas',
      'puntos_infraestructura',
      'zonas_finca',
      'tareas_mantenimiento',
    ]) {
      final marcas = await db.query(tabla, columns: ['actualizado_ms']);
      expect(marcas, isNotEmpty, reason: tabla);
      expect(marcas.map((fila) => fila['actualizado_ms']).toSet(),
          {BaseDatosSoleraZunbeltz.marcaSembrado},
          reason: tabla);
    }
  });

  test('los uid son fijos: dos móviles siembran lo mismo', () async {
    await bd.sembrarEspacioRealSiVacia();
    final otro = await abrirBdEnMemoria();
    await otro.sembrarEspacioRealSiVacia();
    Future<Set<Object?>> uids(BaseDatosSoleraZunbeltz base) async {
      final db = await base.basedatos;
      return {
        for (final tabla in ['zonas_finca', 'tareas_mantenimiento'])
          for (final fila in await db.query(tabla, columns: ['uid']))
            fila['uid'],
      };
    }

    expect(
        await uids(bd), hasLength(zonasEspacio.length + tareasEspacio.length));
    expect(await uids(otro), await uids(bd));
  });

  test('con fincas ya en la BD no siembra nada', () async {
    await bd.sembrarFincasDemoSiVacia();
    expect(await bd.sembrarEspacioRealSiVacia(), isFalse);
    expect(await bd.listarZonas(), isEmpty);
    expect(await bd.listarTareas(), isEmpty);
  });
}
