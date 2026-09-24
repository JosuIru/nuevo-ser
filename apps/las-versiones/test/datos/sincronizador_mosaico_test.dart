import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuevo_ser_companion/nuevo_ser_companion.dart' as companion;
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:las_versiones/datos/repositorio_mosaico.dart';
import 'package:las_versiones/datos/sincronizador_mosaico.dart';
import 'package:las_versiones/dominio/mosaico_arco_1.dart';

GestorPerfiles _gestorDePrueba() => GestorPerfiles(
      namespace: 'nuevoser.lasversiones',
      sufijoNombreVisible: 'nombre_jugador',
      clavesGlobalesNoMigrables: const {
        'nuevoser.lasversiones.idioma_app',
        'nuevoser.lasversiones.token_backend',
        'nuevoser.lasversiones.email_backend',
      },
    );

/// Tests del sincronizador del Mosaico v2 contra el endpoint
/// `POST /companion/mosaicos`.
///
/// El sincronizador es opt-in: se dispara tras pulsar ENTREGAR. Sin
/// token guardado cae en `SyncMosaicoSinToken` sin tocar red; con
/// token y respuesta 201 devuelve `SyncMosaicoExito`; los errores de
/// API/red caen en `SyncMosaicoError`.
void main() {
  late RepositorioCuentaBackend repoCuenta;
  late RepositorioMosaico repoMosaico;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repoCuenta = RepositorioCuentaBackend(
      prefs: SharedPreferences.getInstance,
      claveToken: 'nuevoser.lasversiones.token_backend',
      claveEmail: 'nuevoser.lasversiones.email_backend',
    );
    repoMosaico = RepositorioMosaico(gestor: _gestorDePrueba());
  });

  Future<void> sembrarMarcas() async {
    await repoMosaico.guardar(MosaicoArco1.idArco, const {
      'aralar_dolmen_visita': NivelConfianza.solido,
      'aralar_paisaje_y_toponimo': NivelConfianza.probable,
      'cromlech_banquete': NivelConfianza.probable,
      'cromlech_dialogo_con_sira': NivelConfianza.solido,
      'cueva_grabados_parietales': NivelConfianza.disputado,
      'cueva_covacho_habitacion': NivelConfianza.probable,
    });
  }

  http.Response respuesta201({int id = 42}) {
    return http.Response(
      jsonEncode({
        'id': id,
        'game_id': gameIdLasVersiones,
        'arc_id': MosaicoArco1.idArco,
        'format': formatoMosaicoV2,
        'title': MosaicoArco1.titulo,
        'content_ref': '',
        'completed_at': '2026-04-30 14:00:00',
      }),
      201,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  companion.ClienteCompanion clienteConRespuesta(http.Response respuesta) {
    final mock = MockClient((_) async => respuesta);
    return companion.ClienteCompanion(
      urlBase: 'https://backend.example',
      cliente: mock,
    );
  }

  companion.ClienteCompanion clienteCapturando({
    required void Function(http.Request) sobreLaRequest,
    required http.Response respuesta,
  }) {
    final mock = MockClient((request) async {
      sobreLaRequest(request);
      return respuesta;
    });
    return companion.ClienteCompanion(
      urlBase: 'https://backend.example',
      cliente: mock,
    );
  }

  test('sin token guardado: devuelve SyncMosaicoSinToken sin tocar red',
      () async {
    var llamadas = 0;
    final mock = MockClient((_) async {
      llamadas++;
      return http.Response('', 500);
    });
    final cliente = companion.ClienteCompanion(
      urlBase: 'https://backend.example',
      cliente: mock,
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    final resultado = await sincronizador.sincronizar();

    expect(resultado, isA<SyncMosaicoSinToken>());
    expect(llamadas, 0);
  });

  test('201 con shape válido: devuelve SyncMosaicoExito con el mosaico backend',
      () async {
    await repoCuenta.guardarToken('jwt-cronista');
    await sembrarMarcas();
    final cliente = clienteConRespuesta(respuesta201(id: 7));
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    final resultado = await sincronizador.sincronizar();

    expect(resultado, isA<SyncMosaicoExito>());
    final exito = resultado as SyncMosaicoExito;
    expect(exito.mosaicoBackend.id, 7);
    expect(exito.mosaicoBackend.gameId, gameIdLasVersiones);
    expect(exito.mosaicoBackend.arcId, MosaicoArco1.idArco);
    expect(exito.mosaicoBackend.format, formatoMosaicoV2);
  });

  test('payload contiene game_id, arc_id, format, title y los anchors',
      () async {
    await repoCuenta.guardarToken('jwt-cronista');
    await sembrarMarcas();
    http.Request? capturada;
    final cliente = clienteCapturando(
      sobreLaRequest: (r) => capturada = r,
      respuesta: respuesta201(),
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    await sincronizador.sincronizar();

    expect(capturada, isNotNull);
    expect(capturada!.method, 'POST');
    expect(capturada!.url.path, '/wp-json/nuevo-ser/v1/companion/mosaicos');
    final body = jsonDecode(capturada!.body) as Map<String, dynamic>;
    expect(body['game_id'], gameIdLasVersiones);
    expect(body['arc_id'], MosaicoArco1.idArco);
    expect(body['format'], formatoMosaicoV2);
    expect(body['title'], MosaicoArco1.titulo);
    // requiredAnchors = ids de las 7 viñetas con anclaje obligatorio
    // (todas excepto `cromlech_dialogo_con_sira` que es diálogo con
    // Sira — tiene `idsFuentesAncladas` vacía).
    final required = body['required_anchors'] as List<dynamic>;
    expect(required, hasLength(7));
    expect(required, isNot(contains('cromlech_dialogo_con_sira')));
    expect(required, contains('aralar_dolmen_visita'));
    expect(required, contains('irulegi_la_mano'));
    // fulfilledAnchors = ids de las 6 viñetas marcadas (las que
    // sembramos arriba), ordenadas alfabéticamente.
    final fulfilled = body['fulfilled_anchors'] as List<dynamic>;
    expect(fulfilled, hasLength(6));
    expect(fulfilled, contains('aralar_dolmen_visita'));
    expect(fulfilled, contains('cromlech_dialogo_con_sira'));
    expect(fulfilled, isNot(contains('irulegi_la_mano')));
    // contentMeta = mapa nivel-por-viñeta serializado a strings.
    final meta = body['content_meta'] as Map<String, dynamic>;
    expect(meta['aralar_dolmen_visita'], 'solido');
    expect(meta['cueva_grabados_parietales'], 'disputado');
  });

  test('cabecera Authorization: Bearer <token>', () async {
    await repoCuenta.guardarToken('jwt-cronista-secreto');
    await sembrarMarcas();
    http.Request? capturada;
    final cliente = clienteCapturando(
      sobreLaRequest: (r) => capturada = r,
      respuesta: respuesta201(),
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    await sincronizador.sincronizar();

    expect(capturada!.headers['Authorization'], 'Bearer jwt-cronista-secreto');
  });

  test('500 del backend: devuelve SyncMosaicoError con código y mensaje',
      () async {
    await repoCuenta.guardarToken('jwt-cronista');
    await sembrarMarcas();
    final cliente = clienteConRespuesta(http.Response(
      jsonEncode({'message': 'archivo de mosaicos no disponible'}),
      500,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ));
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    final resultado = await sincronizador.sincronizar();

    expect(resultado, isA<SyncMosaicoError>());
    final error = resultado as SyncMosaicoError;
    expect(error.razon, contains('500'));
    expect(error.razon, contains('archivo de mosaicos'));
  });

  test('TimeoutException: SyncMosaicoError con razón "Tiempo de espera"',
      () async {
    await repoCuenta.guardarToken('jwt-cronista');
    await sembrarMarcas();
    final mock = MockClient((_) async {
      throw TimeoutException('forced');
    });
    final cliente = companion.ClienteCompanion(
      urlBase: 'https://backend.example',
      cliente: mock,
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    final resultado = await sincronizador.sincronizar();

    expect(resultado, isA<SyncMosaicoError>());
    final error = resultado as SyncMosaicoError;
    expect(error.razon, contains('Tiempo de espera'));
  });

  test('SocketException: SyncMosaicoError con razón "Sin conexión"', () async {
    await repoCuenta.guardarToken('jwt-cronista');
    await sembrarMarcas();
    final mock = MockClient((_) async {
      throw const SocketException('no route');
    });
    final cliente = companion.ClienteCompanion(
      urlBase: 'https://backend.example',
      cliente: mock,
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    final resultado = await sincronizador.sincronizar();

    expect(resultado, isA<SyncMosaicoError>());
    final error = resultado as SyncMosaicoError;
    expect(error.razon, contains('Sin conexión'));
  });

  test('ClientException (fallo de red en web): SyncMosaicoError "Sin conexión"',
      () async {
    await repoCuenta.guardarToken('jwt-cronista');
    await sembrarMarcas();
    final mock = MockClient((_) async {
      throw http.ClientException('Failed to fetch');
    });
    final cliente = companion.ClienteCompanion(
      urlBase: 'https://backend.example',
      cliente: mock,
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    final resultado = await sincronizador.sincronizar();

    expect(resultado, isA<SyncMosaicoError>());
    final error = resultado as SyncMosaicoError;
    expect(error.razon, contains('Sin conexión'));
  });

  test('mosaico vacío (cero marcas): payload con anchors vacíos', () async {
    await repoCuenta.guardarToken('jwt-cronista');
    // No sembramos nada — el repo devuelve mapa vacío.
    http.Request? capturada;
    final cliente = clienteCapturando(
      sobreLaRequest: (r) => capturada = r,
      respuesta: respuesta201(),
    );
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: cliente,
    );

    await sincronizador.sincronizar();

    final body = jsonDecode(capturada!.body) as Map<String, dynamic>;
    expect((body['fulfilled_anchors'] as List).isEmpty, isTrue);
    expect((body['content_meta'] as Map).isEmpty, isTrue);
    // requiredAnchors siempre lista las 7 viñetas obligatorias del arco.
    expect((body['required_anchors'] as List), hasLength(7));
  });

  test(
      'construirPayload sin tocar red: ids ordenados y serialización canónica',
      () {
    final sincronizador = SincronizadorMosaicoArco1(
      repoCuenta: repoCuenta,
      repoMosaico: repoMosaico,
      clienteCompanion: companion.ClienteCompanion(
        urlBase: 'https://backend.example',
        cliente: MockClient((_) async => http.Response('', 200)),
      ),
    );

    final payload = sincronizador.construirPayload(marcas: const {
      'irulegi_la_mano': NivelConfianza.probable,
      'aralar_dolmen_visita': NivelConfianza.solido,
    });

    expect(payload.gameId, gameIdLasVersiones);
    expect(payload.arcId, MosaicoArco1.idArco);
    expect(payload.format, formatoMosaicoV2);
    // fulfilledAnchors ordenados alfabéticamente para que el hash que
    // pueda hacer el servidor sea estable entre llamadas con el mismo
    // contenido.
    expect(payload.fulfilledAnchors, ['aralar_dolmen_visita', 'irulegi_la_mano']);
  });
}
