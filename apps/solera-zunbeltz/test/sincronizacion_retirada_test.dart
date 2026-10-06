// Sincronización contra un servidor simulado: con `completo: true` el
// servidor manda la lista entera de tareas visibles, y el dispositivo
// retira las que ya no le corresponden (p. ej. reasignadas a otra persona).
// Sin esa marca (servidor v0.2) no se borra nada.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/finca.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

void main() {
  late BaseDatosSoleraZunbeltz bd;
  late TareaMantenimiento tareaQueSigue;
  late TareaMantenimiento tareaReasignada;

  setUp(() async {
    bd = await abrirBdEnMemoria();
    final fincaId = await bd.guardarFinca(Finca(nombre: 'Zunbeltz'));
    tareaQueSigue = TareaMantenimiento(
        fincaId: fincaId, titulo: 'Limpiar abrevadero', responsableUid: 'ane');
    tareaReasignada = TareaMantenimiento(
        fincaId: fincaId, titulo: 'Reparar cierre', responsableUid: 'ane');
    await bd.guardarTarea(tareaQueSigue);
    await bd.guardarTarea(tareaReasignada);
    // Ya sincronizado antes: así esta no es la primera (completa).
    await bd.guardarEstadoSync('revision', 1);
  });

  Map<String, Object?> respuestaServidor({required bool completo}) => {
        'entidades': <Object>[],
        'revision': 1,
        'tareas': [ClienteSyncZunbeltz.tareaAJson(tareaQueSigue, 'Zunbeltz')],
        if (completo) 'completo': true,
        'forzar': <String>[],
        'rechazos': <Object>[],
        'yo': {
          'uid': 'ane',
          'nombre': 'Ane',
          'rol': 'tester',
          'etiqueta_rol': 'Tester',
          'capacidades': <String>[],
        },
        'personas': <Object>[],
      };

  Future<ResultadoSyncZunbeltz> sincronizarContra(
          Map<String, Object?> respuesta) =>
      http.runWithClient(
        () => ClienteSyncZunbeltz(urlBase: 'https://zunbeltz.test', token: 't')
            .sincronizar(bd),
        () => MockClient((_) async => http.Response(
              jsonEncode(respuesta),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            )),
      );

  test('con lista completa se retiran las tareas que ya no se ven', () async {
    final resultado = await sincronizarContra(respuestaServidor(completo: true));
    final uidsLocales = {for (final t in await bd.listarTareas()) t.uid};
    expect(uidsLocales, {tareaQueSigue.uid});
    expect(resultado.retiradas, 1);
  });

  test('sin la marca `completo` (servidor v0.2) no se borra nada', () async {
    final resultado =
        await sincronizarContra(respuestaServidor(completo: false));
    expect((await bd.listarTareas()).length, 2);
    expect(resultado.retiradas, 0);
  });
}
