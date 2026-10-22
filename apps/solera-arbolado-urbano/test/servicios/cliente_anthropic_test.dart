import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:solera_arbolado_urbano/servicios/cliente_anthropic.dart';

http.Response _respuestaTexto(String texto, {String stopReason = 'end_turn'}) =>
    http.Response.bytes(
      utf8.encode(jsonEncode({
        'content': [
          {'type': 'thinking', 'thinking': '...'},
          {'type': 'text', 'text': texto},
        ],
        'stop_reason': stopReason,
        'model': modeloClaudeRapido,
        'usage': {'input_tokens': 10, 'output_tokens': 5},
      })),
      200,
    );

void main() {
  late Directory carpetaTemporal;
  late File foto;

  setUp(() async {
    carpetaTemporal = await Directory.systemTemp.createTemp('arbolado_ia');
    foto = File('${carpetaTemporal.path}/hoja.jpg')
      ..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);
  });

  tearDown(() => carpetaTemporal.delete(recursive: true));

  test('la clave vive en la preferencia de siempre', () {
    expect(estadoClaveAnthropic.claveAlmacenamiento,
        'solera_arbolado_urbano.anthropic.clave');
  });

  test('diagnóstico de plaga: Haiku 5.5, esfuerzo bajo, sin temperature', () async {
    late Map<String, dynamic> cuerpoEnviado;
    final clienteHttp = MockClient((peticion) async {
      cuerpoEnviado = jsonDecode(peticion.body) as Map<String, dynamic>;
      return _respuestaTexto(jsonEncode({
        'tipo_analisis': 'plaga',
        'plaga_nombre_comun': 'Procesionaria del pino',
        'plaga_nombre_cientifico': 'Thaumetopoea pityocampa',
        'tipo_plaga': 'plaga_insecto',
        'severidad': 3,
        'confianza': 0.9,
        'manejo_cultural': 'Retirar bolsones.',
        'declaracion_oficial_sugerida': false,
        'riesgo_sanitario_publico_sugerido': true,
        'advertencia': '',
      }));
    });
    final cliente = ClienteAnthropic('sk-ant-prueba-0123456789',
        clienteClaude: ClienteClaude(
            claveApi: 'sk-ant-prueba-0123456789', cliente: clienteHttp));

    final resultado = await cliente.analizarFoto(
        foto: foto, modo: ModoAnalisisIA.diagnosticarPlaga);

    expect(cuerpoEnviado['model'], 'claude-haiku-5-5');
    expect(cuerpoEnviado['max_tokens'], greaterThanOrEqualTo(4096));
    expect(cuerpoEnviado['output_config'], {'effort': 'low'});
    expect(cuerpoEnviado.containsKey('temperature'), isFalse);
    expect(cuerpoEnviado['system'], contains('sanidad de arbolado urbano'));
    final contenido = (cuerpoEnviado['messages'] as List).single['content'] as List;
    expect(contenido.first['type'], 'image');
    expect(contenido.first['source']['media_type'], 'image/jpeg');

    expect(resultado.tipoAnalisis, 'plaga');
    expect(resultado.plagaNombreCientifico, 'Thaumetopoea pityocampa');
    expect(resultado.severidad, 3);
    expect(resultado.riesgoSanitarioPublicoSugerido, isTrue);
    expect(resultado.confianza, 0.9);
  });

  test('la negativa de Claude llega como ErrorClaude con su mensaje', () async {
    final clienteHttp = MockClient((_) async => http.Response(
        jsonEncode({
          'content': [],
          'stop_reason': 'refusal',
        }),
        200));
    final cliente = ClienteAnthropic('sk-ant-prueba-0123456789',
        clienteClaude: ClienteClaude(
            claveApi: 'sk-ant-prueba-0123456789', cliente: clienteHttp));
    await expectLater(
      cliente.analizarFoto(foto: foto, modo: ModoAnalisisIA.diagnosticarPlaga),
      throwsA(isA<ErrorClaude>()
          .having((e) => e.motivo, 'motivo', MotivoErrorClaude.rechazado)),
    );
  });

  test('resultadoDesdeJson tolera campos ausentes', () {
    final resultado =
        resultadoDesdeJson({'confianza': 3}, ModoAnalisisIA.diagnosticarPlaga);
    expect(resultado.tipoPlaga, 'indeterminado');
    expect(resultado.confianza, 1.0);
    expect(resultado.severidad, isNull);
    final especie = resultadoDesdeJson(
        {'especie_nombre_comun': 'Tilo', 'confianza': 0.5},
        ModoAnalisisIA.identificarEspecie);
    expect(especie.especieNombreComun, 'Tilo');
  });

  test('probarClaveAnthropic: null si va bien, mensaje si no', () async {
    late Map<String, dynamic> cuerpoEnviado;
    final bien = MockClient((peticion) async {
      cuerpoEnviado = jsonDecode(peticion.body) as Map<String, dynamic>;
      return _respuestaTexto('ok');
    });
    expect(
        await probarClaveAnthropic('clave',
            clienteClaude: ClienteClaude(claveApi: 'clave', cliente: bien)),
        isNull);
    expect(cuerpoEnviado['model'], modeloClaudeRapido);
    expect(cuerpoEnviado['max_tokens'], 1024);

    final mal = MockClient((_) async => http.Response('{}', 401));
    final mensaje = await probarClaveAnthropic('clave',
        clienteClaude: ClienteClaude(claveApi: 'clave', cliente: mal));
    expect(mensaje, contains('no es válida'));
  });
}
