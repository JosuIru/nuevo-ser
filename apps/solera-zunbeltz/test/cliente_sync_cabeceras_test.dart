// Cabeceras que manda el cliente de sincronización. Sin `accept`, el
// ModSecurity del hosting de Zunbeltz responde 406 a los POST de /sync.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/servicios/cliente_sync_zunbeltz.dart';

import 'bd_en_memoria.dart';

void main() {
  test('/yo y /sync llevan accept: application/json y el token', () async {
    final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final cabecerasPorRuta = <String, HttpHeaders>{};
    servidor.listen((peticion) async {
      cabecerasPorRuta[peticion.uri.pathSegments.last] = peticion.headers;
      await peticion.drain<void>();
      // 401: el cliente corta ahí, solo interesa lo que ha mandado.
      peticion.response.statusCode = 401;
      await peticion.response.close();
    });
    addTearDown(() => servidor.close(force: true));
    final cliente = ClienteSyncZunbeltz(
        urlBase: 'http://127.0.0.1:${servidor.port}', token: 'token-de-prueba');

    await expectLater(cliente.obtenerSesion(), throwsA(isA<ErrorSyncZunbeltz>()));
    await expectLater(cliente.sincronizar(await abrirBdEnMemoria()),
        throwsA(isA<ErrorSyncZunbeltz>()));

    for (final ruta in ['yo', 'sync']) {
      final cabeceras = cabecerasPorRuta[ruta];
      expect(cabeceras, isNotNull, reason: 'no llegó la petición a /$ruta');
      expect(cabeceras!.value('accept'), 'application/json', reason: '/$ruta');
      expect(cabeceras.value('x-zunbeltz-token'), 'token-de-prueba', reason: '/$ruta');
    }
  });
}
