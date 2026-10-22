import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuevo_ser_core/src/ia/cliente_claude.dart';
import 'package:nuevo_ser_core/src/servicios/servicio_chat.dart';

http.Response respuestaJson(Map<String, dynamic> cuerpo, [int estado = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(cuerpo)), estado,
        headers: {'content-type': 'application/json'});

Map<String, dynamic> respuestaConBloques(List<Map<String, dynamic>> bloques,
        {String stopReason = 'end_turn'}) =>
    {
      'id': 'msg_1',
      'type': 'message',
      'role': 'assistant',
      'model': 'claude-haiku-5-5',
      'content': bloques,
      'stop_reason': stopReason,
      'usage': {'input_tokens': 12, 'output_tokens': 34},
    };

const bloquePensamiento = {
  'type': 'thinking',
  'thinking': 'Voy a pensar...',
  'signature': 'abc',
};

ClienteClaude clienteCon(http.Response Function(http.Request) responder,
        {List<http.Request>? peticiones}) =>
    ClienteClaude(
      claveApi: 'clave-de-prueba',
      cliente: MockClient((peticion) async {
        peticiones?.add(peticion);
        return responder(peticion);
      }),
    );

Future<ErrorClaude> errorDe(Future<Object?> llamada) async {
  try {
    await llamada;
  } on ErrorClaude catch (error) {
    return error;
  }
  fail('Se esperaba ErrorClaude');
}

void main() {
  final mensajesSimples = [MensajeClaude.usuario('Hola')];

  group('lectura de la respuesta', () {
    test('ignora el bloque thinking que va delante del texto', () async {
      final cliente = clienteCon((_) => respuestaJson(respuestaConBloques([
            bloquePensamiento,
            {'type': 'text', 'text': 'Buenos días'},
          ])));
      final respuesta = await cliente.enviar(
          modelo: modeloClaudeRapido, mensajes: mensajesSimples);
      expect(respuesta.texto, 'Buenos días');
      expect(respuesta.stopReason, 'end_turn');
      expect(respuesta.modelo, 'claude-haiku-5-5');
      expect(respuesta.tokensEntrada, 12);
      expect(respuesta.tokensSalida, 34);
    });

    test('concatena varios bloques text', () async {
      final cliente = clienteCon((_) => respuestaJson(respuestaConBloques([
            {'type': 'text', 'text': 'Uno, '},
            bloquePensamiento,
            {'type': 'text', 'text': 'dos.'},
          ])));
      expect(
          await cliente.pedirTexto(
              modelo: modeloClaudeRapido, mensajes: mensajesSimples),
          'Uno, dos.');
    });

    test('refusal es ErrorClaude rechazado', () async {
      final cliente = clienteCon((_) => respuestaJson({
            ...respuestaConBloques([], stopReason: 'refusal'),
            'stop_details': {'category': 'cyber'},
          }));
      final error = await errorDe(cliente.enviar(
          modelo: modeloClaudeRapido, mensajes: mensajesSimples));
      expect(error.motivo, MotivoErrorClaude.rechazado);
      expect(error.toString(), contains('cyber'));
    });

    test('max_tokens sin texto es ErrorClaude cortado', () async {
      final cliente = clienteCon((_) => respuestaJson(respuestaConBloques(
          [bloquePensamiento],
          stopReason: 'max_tokens')));
      final error = await errorDe(cliente.enviar(
          modelo: modeloClaudeRapido, mensajes: mensajesSimples));
      expect(error.motivo, MotivoErrorClaude.cortado);
    });
  });

  group('errores HTTP', () {
    Future<ErrorClaude> errorConEstado(int estado) {
      final cliente = clienteCon((_) => respuestaJson({
            'type': 'error',
            'error': {'type': 'x', 'message': 'detalle de la API'},
          }, estado));
      return errorDe(cliente.enviar(
          modelo: modeloClaudeRapido, mensajes: mensajesSimples));
    }

    test('401 → claveNoValida', () async {
      final error = await errorConEstado(401);
      expect(error.motivo, MotivoErrorClaude.claveNoValida);
      expect(error.codigoHttp, 401);
      expect(error.toString(),
          'La clave de Anthropic no es válida. Revísala en Ajustes.');
    });

    test('429 → limite', () async {
      expect((await errorConEstado(429)).motivo, MotivoErrorClaude.limite);
    });

    test('529 → sobrecarga', () async {
      expect((await errorConEstado(529)).motivo, MotivoErrorClaude.sobrecarga);
    });

    test('400 → peticionNoValida con el mensaje de la API', () async {
      final error = await errorConEstado(400);
      expect(error.motivo, MotivoErrorClaude.peticionNoValida);
      expect(error.toString(), contains('detalle de la API'));
    });

    test('sin clave → sinClave, sin llamar a la red', () async {
      var llamadas = 0;
      final cliente = ClienteClaude(
          claveApi: '  ',
          cliente: MockClient((_) async {
            llamadas++;
            return respuestaJson({});
          }));
      final error = await errorDe(cliente.enviar(
          modelo: modeloClaudeRapido, mensajes: mensajesSimples));
      expect(error.motivo, MotivoErrorClaude.sinClave);
      expect(llamadas, 0);
    });

    test('fallo de red → red', () async {
      final cliente = ClienteClaude(
          claveApi: 'k',
          cliente: MockClient((_) async => throw http.ClientException('caído')));
      final error = await errorDe(cliente.enviar(
          modelo: modeloClaudeRapido, mensajes: mensajesSimples));
      expect(error.motivo, MotivoErrorClaude.red);
    });
  });

  group('cuerpo de la petición', () {
    test('cabeceras, sin temperature, con effort y format, imagen antes del texto',
        () async {
      final peticiones = <http.Request>[];
      final cliente = clienteCon(
          (_) => respuestaJson(respuestaConBloques([
                {'type': 'text', 'text': '{"especie":"x"}'},
              ])),
          peticiones: peticiones);
      final esquema = {
        'type': 'object',
        'properties': {
          'especie': {'type': 'string'},
        },
      };
      await cliente.pedirJson(
        modelo: modeloClaudeRapido,
        sistema: 'Eres botánico.',
        mensajes: [
          MensajeClaude.usuario('Antes'),
          MensajeClaude.asistente('Vale'),
          MensajeClaude.usuario('¿Qué es?', imagenes: [
            ImagenClaude(Uint8List.fromList([1, 2, 3]), 'image/png'),
          ]),
        ],
        esfuerzo: EsfuerzoClaude.bajo,
        esquemaJson: esquema,
      );

      final peticion = peticiones.single;
      expect(peticion.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(peticion.headers['x-api-key'], 'clave-de-prueba');
      expect(peticion.headers['anthropic-version'], '2023-06-01');
      expect(peticion.headers['content-type'], startsWith('application/json'));
      expect(peticion.headers['anthropic-dangerous-direct-browser-access'],
          'true');

      final cuerpo = jsonDecode(peticion.body) as Map<String, dynamic>;
      expect(cuerpo.containsKey('temperature'), isFalse);
      expect(cuerpo.containsKey('top_p'), isFalse);
      expect(cuerpo.containsKey('top_k'), isFalse);
      expect(cuerpo['model'], 'claude-haiku-5-5');
      expect(cuerpo['max_tokens'], 4096);
      expect(cuerpo['system'], 'Eres botánico.');
      expect(cuerpo['output_config'], {
        'effort': 'low',
        'format': {'type': 'json_schema', 'schema': esquema},
      });
      final mensajes = cuerpo['messages'] as List;
      expect(mensajes.map((m) => m['role']), ['user', 'assistant', 'user']);
      expect(mensajes.first['content'], 'Antes');
      final contenido = mensajes.last['content'] as List;
      expect(contenido[0], {
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': 'image/png',
          'data': base64Encode([1, 2, 3]),
        },
      });
      expect(contenido[1], {'type': 'text', 'text': '¿Qué es?'});
    });

    test('sin esfuerzo ni esquema no se manda output_config', () async {
      final peticiones = <http.Request>[];
      final cliente = clienteCon(
          (_) => respuestaJson(respuestaConBloques([
                {'type': 'text', 'text': 'ok'},
              ])),
          peticiones: peticiones);
      await cliente.enviar(modelo: modeloClaudeRapido, mensajes: mensajesSimples);
      final cuerpo = jsonDecode(peticiones.single.body) as Map<String, dynamic>;
      expect(cuerpo.containsKey('output_config'), isFalse);
      expect(cuerpo.containsKey('system'), isFalse);
    });

    test('último mensaje del asistente → ArgumentError', () async {
      final cliente = clienteCon((_) => respuestaJson({}));
      expect(
        () => cliente.enviar(modelo: modeloClaudeRapido, mensajes: [
          MensajeClaude.usuario('Hola'),
          MensajeClaude.asistente('Prefill'),
        ]),
        throwsArgumentError,
      );
      expect(() => cliente.enviar(modelo: modeloClaudeRapido, mensajes: []),
          throwsArgumentError);
    });
  });

  group('modeloClaudeActual', () {
    test('traduce IDs antiguos a su familia actual', () {
      expect(modeloClaudeActual('claude-haiku-4-5'), modeloClaudeRapido);
      expect(modeloClaudeActual('claude-3-5-haiku-20241022'), modeloClaudeRapido);
      expect(modeloClaudeActual('claude-sonnet-4-6'), modeloClaudeEquilibrado);
      expect(modeloClaudeActual('claude-sonnet-4-20250514'),
          modeloClaudeEquilibrado);
      expect(modeloClaudeActual('claude-opus-4-7'), modeloClaudePotente);
      expect(modeloClaudeActual('claude-opus-4-1'), modeloClaudePotente);
    });

    test('los actuales se quedan y lo desconocido va al rápido', () {
      expect(modeloClaudeActual('claude-haiku-5-5'), 'claude-haiku-5-5');
      expect(modeloClaudeActual('claude-sonnet-5-5'), 'claude-sonnet-5-5');
      expect(modeloClaudeActual('claude-opus-5-5'), 'claude-opus-5-5');
      expect(modeloClaudeActual(''), modeloClaudeRapido);
      expect(modeloClaudeActual('gpt-4'), modeloClaudeRapido);
    });
  });

  group('pedirJson', () {
    Future<Map<String, dynamic>> jsonDeTexto(String texto) =>
        clienteCon((_) => respuestaJson(respuestaConBloques([
              bloquePensamiento,
              {'type': 'text', 'text': texto},
            ]))).pedirJson(modelo: modeloClaudeRapido, mensajes: mensajesSimples);

    test('JSON limpio', () async {
      expect(await jsonDeTexto('{"a": 1}'), {'a': 1});
    });

    test('con vallas ```json', () async {
      expect(
          await jsonDeTexto('Aquí tienes:\n```json\n{"a": {"b": "}"}}\n```\nFin.'),
          {
            'a': {'b': '}'},
          });
    });

    test('con texto alrededor y sin vallas', () async {
      expect(await jsonDeTexto('Resultado: {"especie": "Quercus"} y ya.'),
          {'especie': 'Quercus'});
    });

    test('sin JSON → respuestaRara', () async {
      final error = await errorDe(jsonDeTexto('No sé.'));
      expect(error.motivo, MotivoErrorClaude.respuestaRara);
    });
  });

  group('ImagenClaude', () {
    test('tipo por extensión', () {
      expect(ImagenClaude.tipoMediaPorExtension('a.JPG'), 'image/jpeg');
      expect(ImagenClaude.tipoMediaPorExtension('a.jpeg'), 'image/jpeg');
      expect(ImagenClaude.tipoMediaPorExtension('a.png'), 'image/png');
      expect(ImagenClaude.tipoMediaPorExtension('a.webp'), 'image/webp');
      expect(ImagenClaude.tipoMediaPorExtension('a.gif'), 'image/gif');
    });
  });

  group('ServicioChat con Claude', () {
    test('lee el texto aunque venga un bloque thinking delante', () async {
      final peticiones = <http.Request>[];
      final servicio = ServicioChat(
        apiKeyClaude: 'k',
        apiKeyDeepseek: '',
        clienteHttpClaude: MockClient((peticion) async {
          peticiones.add(peticion);
          return respuestaJson(respuestaConBloques([
            bloquePensamiento,
            {'type': 'text', 'text': 'Es un ammonites.'},
          ]));
        }),
      );
      final texto = await servicio.enviarMensaje(
        '¿Qué es?',
        proveedor: ProveedorChat.claude,
        historial: [
          MensajeChat(texto: 'Hola', esUsuario: true),
          MensajeChat(texto: 'Hola, dime', esUsuario: false),
        ],
      );
      expect(texto, 'Es un ammonites.');
      final cuerpo = jsonDecode(peticiones.single.body) as Map<String, dynamic>;
      expect(cuerpo['model'], 'claude-haiku-5-5');
      expect(cuerpo.containsKey('temperature'), isFalse);
      expect(cuerpo['max_tokens'], greaterThanOrEqualTo(2048));
      expect(cuerpo['output_config'], {'effort': 'low'});
      expect((cuerpo['messages'] as List).length, 3);
    });

    test('un modelo antiguo guardado se traduce y los errores son Exception',
        () async {
      final peticiones = <http.Request>[];
      final servicio = ServicioChat(
        apiKeyClaude: 'k',
        apiKeyDeepseek: '',
        modeloClaude: 'claude-haiku-4-5',
        clienteHttpClaude: MockClient((peticion) async {
          peticiones.add(peticion);
          return respuestaJson({
            'error': {'message': 'x'},
          }, 401);
        }),
      );
      await expectLater(
        servicio.enviarMensaje('Hola', proveedor: ProveedorChat.claude),
        throwsA(isA<Exception>().having((e) => e.toString(), 'mensaje',
            contains('La clave de Anthropic no es válida'))),
      );
      final cuerpo = jsonDecode(peticiones.single.body) as Map<String, dynamic>;
      expect(cuerpo['model'], 'claude-haiku-5-5');
    });
  });
}
