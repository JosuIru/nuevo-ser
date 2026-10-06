// Sincronización de todo el espacio (POST /sync) contra un servidor
// simulado: identidad estable de cada fila, lápidas al borrar, referencias
// por uid en los dos sentidos, permisos del servidor (forzar) y
// sincronización completa que retira lo que ya no se ve.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/modelos/punto_infraestructura.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

/// Servidor falso: guarda lo último que le llegó y responde lo preparado.
class ServidorSimulado {
  Map<String, Object?> ultimaPeticion = {};
  Map<String, Object?> respuesta = {};

  Map<String, Object?> get respuestaCompleta => {
        'entidades': <Object>[],
        'revision': 0,
        'forzar_entidades': <Object>[],
        'rechazos_entidades': <Object>[],
        'tareas': <Object>[],
        'completo': true,
        'forzar': <String>[],
        'rechazos': <Object>[],
        'actividad': <Object>[],
        'yo': {
          'uid': 'coord',
          'nombre': 'Pablo',
          'rol': 'coordinador',
          'etiqueta_rol': 'Coordinación',
          'capacidades': <String>[],
        },
        'personas': <Object>[],
        ...respuesta,
      };

  MockClient get cliente => MockClient((peticion) async {
        ultimaPeticion =
            Map<String, Object?>.from(jsonDecode(peticion.body) as Map);
        return http.Response(jsonEncode(respuestaCompleta), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      });

  List<Map<String, Object?>> get entidadesSubidas => [
        for (final e in (ultimaPeticion['entidades'] as List? ?? const []))
          Map<String, Object?>.from(e as Map),
      ];
}

Map<String, Object?> entidad(String tipo, String uid, Map<String, Object?> datos,
        {int actualizadoMs = 5000,
        bool borrado = false,
        String proyectoUid = '',
        String autorUid = ''}) =>
    {
      'tipo': tipo,
      'uid': uid,
      'actualizado_ms': actualizadoMs,
      'borrado': borrado,
      'proyecto_uid': proyectoUid,
      'autor_uid': autorUid,
      'datos': datos,
      'revision': 1,
    };

void main() {
  late BaseDatosSoleraZunbeltz bd;
  late ServidorSimulado servidor;

  setUp(() async {
    bd = await abrirBdEnMemoria();
    servidor = ServidorSimulado();
  });

  Future<ResultadoSyncZunbeltz> sincronizar({bool completa = false}) =>
      http.runWithClient(
        () => ClienteSyncZunbeltz(urlBase: 'https://zunbeltz.test', token: 't')
            .sincronizar(bd, completa: completa),
        () => servidor.cliente,
      );

  group('identidad y lápidas en local', () {
    test('cada alta lleva uid y marca de tiempo', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      final uid = await bd.uidDeFila('fincas', fincaId);
      expect(uid, isNotNull);
      expect(uid, isNotEmpty);
    });

    test('las fincas sembradas tienen uid fijo, igual en todos los móviles',
        () async {
      await bd.sembrarFincasDemoSiVacia();
      final otra = await abrirBdEnMemoria();
      await otra.sembrarFincasDemoSiVacia();
      final uidsAqui = {
        for (final f in await bd.listarFincas()) await bd.uidDeFila('fincas', f.id!)
      };
      final uidsAlli = {
        for (final f in await otra.listarFincas())
          await otra.uidDeFila('fincas', f.id!)
      };
      expect(uidsAqui, uidsAlli);
    });

    test('borrar una finca deja lápida suya y de lo que cuelga', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      final puntoId = await bd.guardarPunto(
          PuntoInfraestructura(fincaId: fincaId, tipo: 'abrevadero'));
      final tareaId =
          await bd.guardarTarea(TareaMantenimiento(fincaId: fincaId, titulo: 'x'));
      final uidPunto = await bd.uidDeFila('puntos_infraestructura', puntoId);
      final uidTarea = (await bd.obtenerTarea(tareaId))!.uid;
      await bd.borrarFinca(fincaId);
      final lapidas = await bd.listarBorradosPendientes();
      expect(lapidas.map((l) => l.tipo).toSet(), {'finca', 'punto', 'tarea'});
      expect(lapidas.map((l) => l.uid), containsAll([uidPunto, uidTarea]));
    });
  });

  group('subida', () {
    test('las referencias viajan como uid, no como id local', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      final proyectoId = await bd.guardarProyecto(ProyectoTest(nombre: 'Quesería'));
      await bd.guardarApunte(ApunteEconomico(
          fincaId: fincaId, proyectoId: proyectoId, concepto: 'Cencerro'));
      final uidFinca = await bd.uidDeFila('fincas', fincaId);
      final uidProyecto = await bd.uidDeFila('proyectos_test', proyectoId);
      await sincronizar();

      final apunte =
          servidor.entidadesSubidas.firstWhere((e) => e['tipo'] == 'apunte');
      final datos = Map<String, Object?>.from(apunte['datos'] as Map);
      expect(datos['finca_uid'], uidFinca);
      expect(apunte['proyecto_uid'], uidProyecto);
      expect(datos.containsKey('finca_id'), isFalse);
      expect(datos.containsKey('proyecto_id'), isFalse);
      expect(datos.containsKey('id'), isFalse);
    });

    test('las lápidas se suben y, aceptadas, se olvidan', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      await bd.borrarFinca(fincaId);
      await sincronizar();
      expect(servidor.entidadesSubidas.single['borrado'], isTrue);
      expect(await bd.listarBorradosPendientes(), isEmpty);
    });

    test('las tareas suben ancladas por uid y las borradas aparte', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Zufía'));
      final puntoId = await bd.guardarPunto(
          PuntoInfraestructura(fincaId: fincaId, tipo: 'abrevadero'));
      await bd.guardarTarea(
          TareaMantenimiento(fincaId: fincaId, puntoId: puntoId, titulo: 'x'));
      final borrarId =
          await bd.guardarTarea(TareaMantenimiento(fincaId: fincaId, titulo: 'y'));
      final uidBorrada = (await bd.obtenerTarea(borrarId))!.uid;
      final uidPunto = await bd.uidDeFila('puntos_infraestructura', puntoId);
      await bd.borrarTarea(borrarId);
      await sincronizar();

      final tarea = Map<String, Object?>.from(
          (servidor.ultimaPeticion['tareas'] as List).single as Map);
      expect(tarea['punto_uid'], uidPunto);
      expect(servidor.ultimaPeticion['tareas_borradas'], [uidBorrada]);
    });
  });

  test('la primera sincronización es completa (baja desde la revisión 0)',
      () async {
    await bd.guardarEstadoSync('revision', 0);
    await sincronizar();
    expect(servidor.ultimaPeticion['desde_revision'], 0);
    servidor.respuesta = {'revision': 7};
    await sincronizar();
    await sincronizar();
    expect(servidor.ultimaPeticion['desde_revision'], 7);
  });

  group('bajada', () {
    test('crea lo nuevo resolviendo las referencias a ids locales', () async {
      servidor.respuesta = {
        'revision': 9,
        'entidades': [
          entidad('punto', 'pu1', {'nombre': 'Abrevadero', 'tipo': 'abrevadero', 'finca_uid': 'f1'}),
          entidad('finca', 'f1', {'nombre': 'Zufía'}),
        ],
        'tareas': [
          {'uid': 't1', 'finca_uid': 'f1', 'punto_uid': 'pu1', 'titulo': 'Limpiar', 'actualizado_ms': 1},
        ],
      };
      await sincronizar();

      final finca = (await bd.listarFincas()).single;
      final punto = (await bd.listarPuntos()).single;
      expect(finca.nombre, 'Zufía');
      expect(punto.fincaId, finca.id);
      final tarea = (await bd.listarTareas()).single;
      expect(tarea.puntoId, punto.id, reason: 'el anclaje ya no se pierde');
      expect(await bd.leerEstadoSync('revision'), 9);
    });

    test('no pisa una edición local más reciente', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Local'));
      final uid = (await bd.uidDeFila('fincas', fincaId))!;
      servidor.respuesta = {
        'entidades': [entidad('finca', uid, {'nombre': 'Vieja'}, actualizadoMs: 1)],
      };
      await sincronizar();
      expect((await bd.obtenerFinca(fincaId))!.nombre, 'Local');
    });

    test('una lápida del servidor borra en local sin dejar lápida propia',
        () async {
      servidor.respuesta = {'entidades': [entidad('finca', 'f1', {'nombre': 'Zufía'})]};
      await sincronizar();
      servidor.respuesta = {
        'entidades': [entidad('finca', 'f1', {}, actualizadoMs: 9000, borrado: true)],
      };
      await sincronizar();
      expect(await bd.listarFincas(), isEmpty);
      expect(await bd.listarBorradosPendientes(), isEmpty);
    });

    test('lo forzado sin versión en el servidor se borra en local', () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Inventada'));
      final uid = (await bd.uidDeFila('fincas', fincaId))!;
      servidor.respuesta = {
        'forzar_entidades': [
          {'tipo': 'finca', 'uid': uid}
        ],
        'rechazos_entidades': [
          {'tipo': 'finca', 'uid': uid, 'motivo': 'sin_permiso'}
        ],
      };
      final resultado = await sincronizar();
      expect(await bd.listarFincas(), isEmpty);
      expect(resultado.rechazadasPorPermisos, 1);
    });

    test('lo forzado con versión en el servidor sobrescribe aunque sea más vieja',
        () async {
      final fincaId = await bd.guardarFinca(Finca(nombre: 'Cambiada'));
      final uid = (await bd.uidDeFila('fincas', fincaId))!;
      servidor.respuesta = {
        'entidades': [entidad('finca', uid, {'nombre': 'Original'}, actualizadoMs: 1)],
        'forzar_entidades': [
          {'tipo': 'finca', 'uid': uid}
        ],
      };
      await sincronizar();
      expect((await bd.obtenerFinca(fincaId))!.nombre, 'Original');
    });

    test('la sincronización completa retira lo que el servidor ya no manda',
        () async {
      servidor.respuesta = {
        'entidades': [
          entidad('finca', 'f1', {'nombre': 'Zufía'}),
          entidad('proyecto', 'p1', {'nombre': 'Ajeno'}),
        ],
      };
      await sincronizar();
      servidor.respuesta = {'entidades': [entidad('finca', 'f1', {'nombre': 'Zufía'})]};
      await sincronizar(completa: true);
      expect(servidor.ultimaPeticion['desde_revision'], 0);
      expect(await bd.listarProyectos(), isEmpty);
      expect((await bd.listarFincas()).single.nombre, 'Zufía');
    });

    test('la actividad del espacio se guarda en local y avanza su cursor',
        () async {
      servidor.respuesta = {
        'actividad': [
          {
            'id': 41,
            'momento_ms': 1000,
            'persona_uid': 'ane',
            'persona_nombre': 'Ane',
            'accion': 'mover',
            'tipo': 'punto',
            'uid': 'pu1',
            'etiqueta': 'Corral móvil',
            'contexto': 'Zunbeltz',
            'detalle': '',
            'origen': 'app',
          }
        ],
      };
      await sincronizar();
      final actividad = await bd.listarActividadEspacio();
      expect(actividad.single.etiqueta, 'Corral móvil');
      expect(await bd.leerEstadoSync('actividad'), 41);
    });
  });
}
