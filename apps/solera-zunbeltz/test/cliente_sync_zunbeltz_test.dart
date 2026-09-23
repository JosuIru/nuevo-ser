// Tests puros (sin red) del formato de payload de sincronización de
// tareas: serialización a JSON y reconstrucción, que es lo único de
// `ClienteSyncZunbeltz` que se puede testear sin un servidor real.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/constantes.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

void main() {
  group('tareaAJson / tareaDesdeJson', () {
    test('round-trip conserva los campos sincronizables', () {
      final tarea = TareaMantenimiento(
        uid: 'uid-1',
        fincaId: 7, // local a este dispositivo; no viaja en el JSON.
        titulo: 'Rellenar comederos',
        descripcion: 'Comedero grande del cercado norte',
        responsable: 'Maite',
        responsableUid: 'maite',
        creadoPorUid: 'coord',
        prioridad: 'alta',
        estado: 'pendiente',
        fechaObjetivoMs: 5000,
        costeCentimos: 1200,
        recurrenciaDias: 7,
        fechaCreacionMs: 1000,
        actualizadoMs: 2000,
      );

      final json = ClienteSyncZunbeltz.tareaAJson(tarea, 'Zunbeltz');
      expect(json['finca_nombre'], 'Zunbeltz');
      expect(json.containsKey('finca_id'), isFalse,
          reason: 'el id local no debe viajar, no significa nada en otro dispositivo');

      final reconstruida = ClienteSyncZunbeltz.tareaDesdeJson(json, 99);
      expect(reconstruida.uid, 'uid-1');
      expect(reconstruida.fincaId, 99, reason: 'fincaId lo resuelve el llamador, no el JSON');
      expect(reconstruida.titulo, 'Rellenar comederos');
      expect(reconstruida.descripcion, 'Comedero grande del cercado norte');
      expect(reconstruida.responsable, 'Maite');
      expect(reconstruida.responsableUid, 'maite');
      expect(reconstruida.creadoPorUid, 'coord');
      expect(reconstruida.prioridad, 'alta');
      expect(reconstruida.estado, 'pendiente');
      expect(reconstruida.fechaObjetivoMs, 5000);
      expect(reconstruida.costeCentimos, 1200);
      expect(reconstruida.recurrenciaDias, 7);
      expect(reconstruida.fechaCreacionMs, 1000);
      expect(reconstruida.actualizadoMs, 2000);
      expect(reconstruida.puntoId, isNull,
          reason: 'puntos/zonas no se sincronizan todavía');
      expect(reconstruida.zonaId, isNull);
    });

    test('tareaDesdeJson aplica valores por defecto ante campos ausentes', () {
      final reconstruida = ClienteSyncZunbeltz.tareaDesdeJson(
        {'uid': 'uid-2', 'titulo': 'Mínima'},
        1,
      );
      expect(reconstruida.estado, estadoTareaPorDefecto);
      expect(reconstruida.prioridad, prioridadTareaPorDefecto);
      expect(reconstruida.recurrenciaDias, isNull);
      expect(reconstruida.costeCentimos, isNull);
    });
  });

  group('SesionRemota.desdeJson', () {
    test('lee la persona conectada, sus capacidades y las personas', () {
      final remota = SesionRemota.desdeJson({
        'yo': {
          'uid': 'ane',
          'nombre': 'Ane',
          'rol': 'tester',
          'etiqueta_rol': 'Tester',
          'capacidades': ['crear_tareas'],
        },
        'personas': [
          {'uid': 'ane', 'nombre': 'Ane', 'rol': 'tester'},
          {'uid': 'coord', 'nombre': 'Coordinación', 'rol': 'coordinador'},
        ],
      });
      expect(remota.sesion.persona.uid, 'ane');
      expect(remota.sesion.puede('crear_tareas'), isTrue);
      expect(remota.personas.map((p) => p.uid), ['ane', 'coord']);
    });

    test('sin `yo` es una respuesta inválida', () {
      expect(() => SesionRemota.desdeJson({'tareas': []}),
          throwsA(isA<ErrorSyncZunbeltz>()));
    });
  });
}
