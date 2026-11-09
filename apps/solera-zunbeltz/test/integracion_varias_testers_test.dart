// Integración: un proyecto de test de dos personas (plugin 1.1.3). Lo crea
// coordinación para Ane y Mikel; las dos lo ven y apuntan en él, Jon no lo
// ve ni puede apuntar, y una app anterior (que no conoce la lista) lo edita
// sin quitarle la segunda persona. Se salta sin servidor:
//
//   SZS_URL=http://zunbeltz-app.local SZS_COORDINACION=<token> \
//     SZS_ANE=<token> SZS_UID_ANE=<uid> SZS_MIKEL=<token> SZS_UID_MIKEL=<uid> \
//     SZS_JON=<token> flutter test test/integracion_varias_testers_test.dart
//
// Al acabar borra el proyecto de prueba (queda como lápida en el servidor).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:solera_zunbeltz/datos/base_datos.dart';
import 'package:solera_zunbeltz/modelos/apunte_economico.dart';
import 'package:solera_zunbeltz/modelos/proyecto_test.dart';
import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

void main() {
  final entorno = Platform.environment;
  final url = entorno['SZS_URL'] ?? '';
  final tokenCoordinacion = entorno['SZS_COORDINACION'] ?? '';
  final tokenAne = entorno['SZS_ANE'] ?? '';
  final tokenMikel = entorno['SZS_MIKEL'] ?? '';
  final tokenJon = entorno['SZS_JON'] ?? '';
  final uidAne = entorno['SZS_UID_ANE'] ?? '';
  final uidMikel = entorno['SZS_UID_MIKEL'] ?? '';

  test('un proyecto de dos personas tester, de punta a punta', () async {
    Future<ResultadoSyncZunbeltz> sincronizar(
            BaseDatosSoleraZunbeltz bd, String token) =>
        ClienteSyncZunbeltz(urlBase: url, token: token).sincronizar(bd);
    final coordinacion = await abrirBdEnMemoria();
    final ane = await abrirBdEnMemoria();
    final mikel = await abrirBdEnMemoria();
    final jon = await abrirBdEnMemoria();

    await sincronizar(coordinacion, tokenCoordinacion);
    final finca = (await coordinacion.listarFincas()).first;
    final proyectoId = await coordinacion.guardarProyecto(ProyectoTest(
      nombre: 'Prueba de dos testers (borrar)',
      persona: 'Prueba Ane (e2e), Prueba Mikel (e2e)',
      personaUid: uidAne,
      personasUids: [uidAne, uidMikel],
      fincaId: finca.id,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    final subida = await sincronizar(coordinacion, tokenCoordinacion);
    expect(subida.rechazadasPorPermisos, 0);
    final uidProyecto = (await (await coordinacion.basedatos)
            .query('proyectos_test', where: 'id = ?', whereArgs: [proyectoId]))
        .single['uid'] as String;
    // El proyecto de prueba en cada copia, por su uid (null si no lo tiene).
    Future<ProyectoTest?> enCopia(BaseDatosSoleraZunbeltz bd) async {
      final id = await bd.idDeUid('proyectos_test', uidProyecto);
      return id == null ? null : bd.obtenerProyecto(id);
    }

    try {
      // Las dos lo ven, con las dos personas.
      for (final (bd, token) in [(ane, tokenAne), (mikel, tokenMikel)]) {
        await sincronizar(bd, token);
        final visto = (await enCopia(bd))!;
        expect(visto.uidsTester, [uidAne, uidMikel]);
      }

      // La segunda apunta un gasto y el servidor lo acepta.
      final proyectoEnMikel = (await enCopia(mikel))!;
      await mikel.guardarApunte(ApunteEconomico(
        fincaId: (await mikel.listarFincas())
            .firstWhere((otra) => otra.nombre == finca.nombre)
            .id!,
        proyectoId: proyectoEnMikel.id,
        concepto: 'Pienso de prueba (Mikel)',
        importeCentimos: 1234,
        fechaMs: DateTime.now().millisecondsSinceEpoch,
      ));
      final deMikel = await sincronizar(mikel, tokenMikel);
      expect(deMikel.rechazadasPorPermisos, 0,
          reason: 'la segunda persona apunta en el proyecto');

      // La primera ve el gasto de la segunda.
      await sincronizar(ane, tokenAne);
      final proyectoEnAne = (await enCopia(ane))!;
      expect(
          (await ane.listarApuntes(proyectoId: proyectoEnAne.id))
              .map((apunte) => apunte.concepto),
          contains('Pienso de prueba (Mikel)'));

      // Otra tester no lo ve.
      await sincronizar(jon, tokenJon);
      expect(await enCopia(jon), isNull);

      // Una app anterior a la lista edita el proyecto (sin `personas_uids`)
      // sin cambiar la persona: la segunda no lo pierde.
      final fila = (await (await coordinacion.basedatos).query('proyectos_test',
              where: 'uid = ?', whereArgs: [uidProyecto]))
          .single;
      final datosViejos = Map<String, Object?>.from(fila)
        ..remove('id')
        ..remove('uid')
        ..remove('actualizado_ms')
        ..remove('autor_uid')
        ..remove('personas_uids')
        ..remove('finca_id')
        ..['nombre'] = 'Prueba de dos testers, renombrada (borrar)';
      final respuesta = await http.post(
        Uri.parse('$url/wp-json/solera-zunbeltz/v1/sync'),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'X-Zunbeltz-Token': tokenCoordinacion,
        },
        body: jsonEncode({
          'entidades': [
            {
              'tipo': 'proyecto',
              'uid': uidProyecto,
              'actualizado_ms': DateTime.now().millisecondsSinceEpoch + 1000,
              'borrado': false,
              'proyecto_uid': '',
              'datos': datosViejos,
            }
          ],
          'tareas': const [],
          'tareas_borradas': const [],
          'desde_revision': 0,
          'desde_actividad': 0,
        }),
      );
      expect(respuesta.statusCode, 200, reason: respuesta.body);
      await sincronizar(mikel, tokenMikel);
      final trasAppVieja = (await enCopia(mikel))!;
      expect(trasAppVieja.nombre, 'Prueba de dos testers, renombrada (borrar)');
      expect(trasAppVieja.uidsTester, [uidAne, uidMikel]);
    } finally {
      await sincronizar(coordinacion, tokenCoordinacion);
      final local = (await enCopia(coordinacion))!;
      await coordinacion.borrarProyecto(local.id!);
      await sincronizar(coordinacion, tokenCoordinacion);
    }
  },
      skip: [
        url,
        tokenCoordinacion,
        tokenAne,
        tokenMikel,
        tokenJon,
        uidAne,
        uidMikel
      ].any((valor) => valor.isEmpty)
          ? 'sin servidor ni claves de prueba'
          : false,
      timeout: const Timeout(Duration(minutes: 3)));
}
