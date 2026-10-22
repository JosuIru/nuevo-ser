import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solera_quesera/datos/base_datos.dart';
import 'package:solera_quesera/estado/clave_anthropic_quesera.dart';
import 'package:solera_quesera/servicios/backup_servicio.dart';
import 'package:solera_quesera/servicios/cliente_anthropic_quesero.dart';

void main() {
  group('configuración de la copia de seguridad', () {
    final configuracion = configuracionCopiaSoleraQuesera();

    test('conserva el identificador, la BD y el nombre de ZIP de siempre', () {
      expect(configuracion.identificadorApp, 'solera_quesera');
      expect(configuracion.nombreFicheroBaseDatos, 'solera_quesera.db');
      expect(configuracion.prefijoNombreCopia, 'solera-quesera-backup');
      expect(configuracion.carpetasExtra, contains('fotos'));
    });

    test('rechaza esquemas más nuevos que el que abre la app', () {
      expect(versionEsquemaSoleraQuesera, 4);
      expect(configuracion.versionEsquemaActual, versionEsquemaSoleraQuesera);
      expect(configuracion.comprobarIntegridad, isNotNull);
    });

    test('la fecha de la última copia se sigue leyendo de la misma preferencia',
        () async {
      final momento = DateTime(2026, 10, 1, 9, 30);
      SharedPreferences.setMockInitialValues({
        'solera_quesera.backup.ultimo_ms': momento.millisecondsSinceEpoch,
      });
      final ultima = await ServicioCopiaSeguridad(configuracion).ultimaCopia();
      expect(ultima, momento);
    });
  });

  group('textoErrorCopia', () {
    test('dice que los datos no se han tocado solo si es verdad', () {
      const rechazada = ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.deOtraApp, 'otra app');
      expect(textoErrorCopia(rechazada), contains('no se han tocado'));

      const rota = ErrorCopiaSeguridad(
          MotivoErrorCopiaSeguridad.reversionFallida, 'a medias');
      expect(textoErrorCopia(rota), isNot(contains('no se han tocado')));
    });

    test('tiene texto para todos los motivos', () {
      for (final motivo in MotivoErrorCopiaSeguridad.values) {
        expect(textoErrorCopia(ErrorCopiaSeguridad(motivo, '')), isNotEmpty);
      }
    });
  });

  test('la clave de Anthropic sigue en la preferencia de siempre', () {
    expect(estadoClaveAnthropicQuesera.claveAlmacenamiento,
        'solera_quesera.anthropic.clave');
  });

  group('cliente de visión quesero', () {
    test('ResultadoAnalisisIA.desdeJson acota la confianza y rellena huecos', () {
      final resultado = ResultadoAnalisisIA.desdeJson({
        'nombre_defecto': 'Hinchazón tardía',
        'tipo': 'hinchazon',
        'severidad': 4,
        'confianza': 1.7,
      });
      expect(resultado.nombreDefecto, 'Hinchazón tardía');
      expect(resultado.severidad, 4);
      expect(resultado.confianza, 1.0);
      expect(resultado.posibleCausa, '');

      final vacio = ResultadoAnalisisIA.desdeJson({});
      expect(vacio.nombreDefecto, 'Sin identificar');
      expect(vacio.tipo, 'otro');
      expect(vacio.confianza, 0);
    });

    test('el prompt incluye las observaciones si las hay', () {
      expect(construirPromptAnalisis('  Idiazabal 3 meses '),
          contains('Observaciones del quesero: Idiazabal 3 meses'));
      expect(construirPromptAnalisis(''), isNot(contains('Observaciones')));
    });

    test('pide a Haiku 5.5 con esfuerzo bajo, sin temperature y con la foto',
        () async {
      final carpeta = await Directory.systemTemp.createTemp('quesera_ia');
      addTearDown(() => carpeta.delete(recursive: true));
      final foto = File('${carpeta.path}/corte.png')
        ..writeAsBytesSync([0x89, 0x50, 0x4e, 0x47]);

      late Map<String, dynamic> cuerpoEnviado;
      final clienteHttp = MockClient((peticion) async {
        cuerpoEnviado = jsonDecode(peticion.body) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode(jsonEncode({
            'content': [
              {
                'type': 'text',
                'text': '{"nombre_defecto": "Grietas en corteza", '
                    '"tipo": "corteza", "severidad": 2, "confianza": 0.8}',
              }
            ],
            'stop_reason': 'end_turn',
            'model': modeloClaudeRapido,
            'usage': {'input_tokens': 10, 'output_tokens': 20},
          })),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final resultado = await ClienteAnthropicQuesero('sk-ant-prueba',
              clienteClaude: ClienteClaude(
                  claveApi: 'sk-ant-prueba', cliente: clienteHttp))
          .analizarFoto(foto: foto);

      expect(resultado.nombreDefecto, 'Grietas en corteza');
      expect(cuerpoEnviado['model'], 'claude-haiku-5-5');
      expect(cuerpoEnviado['max_tokens'], greaterThanOrEqualTo(4096));
      expect(cuerpoEnviado.containsKey('temperature'), isFalse);
      expect(cuerpoEnviado['output_config'], {'effort': 'low'});
      final contenido =
          (cuerpoEnviado['messages'] as List).single['content'] as List;
      expect(contenido.first['type'], 'image');
      expect(contenido.first['source']['media_type'], 'image/png');
    });
  });
}
