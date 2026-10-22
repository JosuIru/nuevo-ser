// Cliente común de la API de Claude (Messages API por HTTP).
//
// Subido al core el 2026-10-22 para que las apps dejen de tener cada una
// el suyo. Pensado para Claude Haiku 5.5 y familia 5.5, donde:
// - el razonamiento está activo por defecto y la respuesta puede empezar con
//   bloques `thinking`: el texto se lee juntando los bloques `type == "text"`;
// - el razonamiento cuenta en `max_tokens`: márgenes holgados;
// - `temperature`, `top_p` y `top_k` dan 400: nunca se mandan;
// - el prefill (último mensaje del asistente) da 400: el último mensaje debe
//   ser de la persona usuaria.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Modelo rápido y barato: identificar por foto, chat, resúmenes.
const String modeloClaudeRapido = 'claude-haiku-5-5';

/// Modelo equilibrado.
const String modeloClaudeEquilibrado = 'claude-sonnet-5-5';

/// Modelo más capaz (y caro).
const String modeloClaudePotente = 'claude-opus-5-5';

/// Traduce un ID de modelo guardado (p. ej. en preferencias) al actual de su
/// familia: `claude-haiku-4-5` → [modeloClaudeRapido],
/// `claude-sonnet-4-6` → [modeloClaudeEquilibrado],
/// `claude-opus-4-7` → [modeloClaudePotente]. Lo desconocido o vacío →
/// [modeloClaudeRapido].
String modeloClaudeActual(String guardado) {
  final idNormalizado = guardado.trim().toLowerCase();
  if (idNormalizado == modeloClaudeRapido ||
      idNormalizado == modeloClaudeEquilibrado ||
      idNormalizado == modeloClaudePotente) {
    return idNormalizado;
  }
  if (idNormalizado.contains('opus')) return modeloClaudePotente;
  if (idNormalizado.contains('sonnet')) return modeloClaudeEquilibrado;
  return modeloClaudeRapido;
}

/// Cuánto razona el modelo antes de contestar (`output_config.effort`).
/// Haiku 5.5 usa `medio` si no se indica.
enum EsfuerzoClaude {
  bajo('low'),
  medio('medium'),
  alto('high');

  const EsfuerzoClaude(this.valorApi);

  /// Valor que espera la API.
  final String valorApi;
}

/// Por qué falló una llamada a Claude.
enum MotivoErrorClaude {
  /// No hay clave de Anthropic configurada.
  sinClave,

  /// La clave no es válida (401/403).
  claveNoValida,

  /// Límite de uso o saldo agotado (429).
  limite,

  /// Servicio sobrecargado o caído (529/5xx).
  sobrecarga,

  /// El modelo declinó contestar (`stop_reason: refusal`).
  rechazado,

  /// Respuesta cortada por `max_tokens` sin texto útil.
  cortado,

  /// La API rechazó la petición (400 y otros 4xx).
  peticionNoValida,

  /// Sin conexión o tiempo de espera agotado.
  red,

  /// La respuesta no tiene la forma esperada (o el JSON no se entiende).
  respuestaRara,
}

/// Error de una llamada a Claude, con un mensaje claro para enseñar a la
/// persona.
class ErrorClaude implements Exception {
  ErrorClaude(this.motivo, this.mensaje, {this.codigoHttp});

  final MotivoErrorClaude motivo;
  final String mensaje;
  final int? codigoHttp;

  @override
  String toString() => mensaje;
}

/// Imagen adjunta a un mensaje.
class ImagenClaude {
  ImagenClaude(this.bytes, this.tipoMedia);

  final Uint8List bytes;

  /// `image/jpeg`, `image/png`, `image/webp` o `image/gif`.
  final String tipoMedia;

  /// Lee una imagen del disco; el tipo se deduce de la extensión
  /// (jpg/jpeg/png/webp/gif; lo demás se trata como JPEG). No vale en web.
  static Future<ImagenClaude> desdeFichero(String ruta) async {
    final bytes = await File(ruta).readAsBytes();
    return ImagenClaude(bytes, tipoMediaPorExtension(ruta));
  }

  /// Tipo de medio según la extensión de [ruta].
  static String tipoMediaPorExtension(String ruta) {
    final extension = ruta.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  Map<String, dynamic> aJsonApi() => {
        'type': 'image',
        'source': {
          'type': 'base64',
          'media_type': tipoMedia,
          'data': base64Encode(bytes),
        },
      };
}

/// Quién habla en un mensaje.
enum RolClaude {
  usuario('user'),
  asistente('assistant');

  const RolClaude(this.valorApi);
  final String valorApi;
}

/// Un mensaje de la conversación: texto y/o imágenes.
class MensajeClaude {
  MensajeClaude({
    required this.rol,
    this.texto,
    this.imagenes = const [],
  });

  /// Mensaje de la persona usuaria.
  MensajeClaude.usuario(String texto, {List<ImagenClaude> imagenes = const []})
      : this(rol: RolClaude.usuario, texto: texto, imagenes: imagenes);

  /// Mensaje anterior del asistente (historial).
  MensajeClaude.asistente(String texto)
      : this(rol: RolClaude.asistente, texto: texto);

  final RolClaude rol;
  final String? texto;
  final List<ImagenClaude> imagenes;

  bool get _tieneTexto => texto != null && texto!.isNotEmpty;

  Map<String, dynamic> aJsonApi() {
    if (imagenes.isEmpty) {
      return {'role': rol.valorApi, 'content': texto ?? ''};
    }
    // Las imágenes van antes del texto.
    return {
      'role': rol.valorApi,
      'content': [
        for (final imagen in imagenes) imagen.aJsonApi(),
        if (_tieneTexto) {'type': 'text', 'text': texto},
      ],
    };
  }
}

/// Respuesta de Claude ya leída.
class RespuestaClaude {
  RespuestaClaude({
    required this.texto,
    required this.stopReason,
    required this.modelo,
    required this.tokensEntrada,
    required this.tokensSalida,
  });

  /// Bloques `text` concatenados (sin el razonamiento).
  final String texto;
  final String? stopReason;
  final String? modelo;
  final int tokensEntrada;
  final int tokensSalida;
}

/// Cliente de la Messages API de Anthropic.
class ClienteClaude {
  ClienteClaude({
    required String claveApi,
    http.Client? cliente,
    Duration timeout = const Duration(seconds: 60),
  })  : _claveApi = claveApi,
        _clienteHttp = cliente,
        _timeout = timeout;

  static final Uri urlMensajes =
      Uri.parse('https://api.anthropic.com/v1/messages');
  static const String versionApi = '2023-06-01';

  final String _claveApi;
  final http.Client? _clienteHttp;
  final Duration _timeout;

  /// Envía la conversación y devuelve la respuesta leída. Lanza
  /// [ErrorClaude] si algo falla y [ArgumentError] si la conversación está
  /// vacía o el último mensaje no es de la persona usuaria.
  Future<RespuestaClaude> enviar({
    required String modelo,
    required List<MensajeClaude> mensajes,
    String? sistema,
    int maxTokens = 4096,
    EsfuerzoClaude? esfuerzo,
    Map<String, dynamic>? esquemaJson,
  }) async {
    if (mensajes.isEmpty) {
      throw ArgumentError.value(mensajes, 'mensajes', 'no puede estar vacío');
    }
    if (mensajes.last.rol != RolClaude.usuario) {
      throw ArgumentError.value(mensajes, 'mensajes',
          'el último mensaje debe ser del usuario (la API no admite prefill)');
    }
    if (_claveApi.trim().isEmpty) {
      throw ErrorClaude(MotivoErrorClaude.sinClave,
          'Falta la clave de Anthropic. Añádela en Ajustes.');
    }

    final configuracionSalida = <String, dynamic>{
      if (esfuerzo != null) 'effort': esfuerzo.valorApi,
      if (esquemaJson != null)
        'format': {'type': 'json_schema', 'schema': esquemaJson},
    };
    final cuerpo = <String, dynamic>{
      'model': modelo,
      'max_tokens': maxTokens,
      if (sistema != null && sistema.isNotEmpty) 'system': sistema,
      'messages': [for (final mensaje in mensajes) mensaje.aJsonApi()],
      if (configuracionSalida.isNotEmpty) 'output_config': configuracionSalida,
    };

    final http.Response respuestaHttp;
    try {
      final peticion = _clienteHttp != null
          ? _clienteHttp.post(urlMensajes,
              headers: _cabeceras(), body: jsonEncode(cuerpo))
          : http.post(urlMensajes,
              headers: _cabeceras(), body: jsonEncode(cuerpo));
      respuestaHttp = await peticion.timeout(_timeout);
    } on TimeoutException {
      throw ErrorClaude(MotivoErrorClaude.red,
          'Claude ha tardado demasiado en contestar. Inténtalo de nuevo.');
    } on http.ClientException catch (error) {
      throw ErrorClaude(MotivoErrorClaude.red,
          'No se ha podido conectar con Claude. Revisa la conexión. (${error.message})');
    } on SocketException {
      throw ErrorClaude(MotivoErrorClaude.red,
          'No se ha podido conectar con Claude. Revisa la conexión.');
    }

    if (respuestaHttp.statusCode != 200) {
      throw _errorPorEstado(respuestaHttp);
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(respuestaHttp.bodyBytes))
          as Map<String, dynamic>;
    } catch (_) {
      throw ErrorClaude(MotivoErrorClaude.respuestaRara,
          'Claude ha devuelto una respuesta que no se entiende.',
          codigoHttp: 200);
    }
    return _leerRespuesta(json);
  }

  /// Envía y devuelve solo el texto.
  Future<String> pedirTexto({
    required String modelo,
    required List<MensajeClaude> mensajes,
    String? sistema,
    int maxTokens = 4096,
    EsfuerzoClaude? esfuerzo,
  }) async {
    final respuesta = await enviar(
      modelo: modelo,
      mensajes: mensajes,
      sistema: sistema,
      maxTokens: maxTokens,
      esfuerzo: esfuerzo,
    );
    return respuesta.texto;
  }

  /// Envía y devuelve un objeto JSON. Con [esquemaJson] pide salida
  /// estructurada; sin él, extrae el primer objeto JSON del texto (tolera
  /// vallas ```json ... ```).
  Future<Map<String, dynamic>> pedirJson({
    required String modelo,
    required List<MensajeClaude> mensajes,
    String? sistema,
    int maxTokens = 4096,
    EsfuerzoClaude? esfuerzo,
    Map<String, dynamic>? esquemaJson,
  }) async {
    final respuesta = await enviar(
      modelo: modelo,
      mensajes: mensajes,
      sistema: sistema,
      maxTokens: maxTokens,
      esfuerzo: esfuerzo,
      esquemaJson: esquemaJson,
    );
    final objeto = extraerObjetoJson(respuesta.texto);
    if (objeto == null) {
      throw ErrorClaude(MotivoErrorClaude.respuestaRara,
          'Claude no ha devuelto los datos en el formato esperado. Inténtalo de nuevo.');
    }
    return objeto;
  }

  /// Primer objeto JSON de [texto] (con o sin vallas de código), o null.
  static Map<String, dynamic>? extraerObjetoJson(String texto) {
    var candidato = texto.trim();
    final valla = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(candidato);
    if (valla != null) candidato = valla.group(1)!.trim();
    final directo = _decodificarObjeto(candidato);
    if (directo != null) return directo;

    // Buscar el primer `{` y su `}` de cierre, respetando cadenas.
    final inicio = candidato.indexOf('{');
    if (inicio < 0) return null;
    var profundidad = 0;
    var dentroDeCadena = false;
    var escapado = false;
    for (var posicion = inicio; posicion < candidato.length; posicion++) {
      final caracter = candidato[posicion];
      if (dentroDeCadena) {
        if (escapado) {
          escapado = false;
        } else if (caracter == r'\') {
          escapado = true;
        } else if (caracter == '"') {
          dentroDeCadena = false;
        }
        continue;
      }
      if (caracter == '"') {
        dentroDeCadena = true;
      } else if (caracter == '{') {
        profundidad++;
      } else if (caracter == '}') {
        profundidad--;
        if (profundidad == 0) {
          return _decodificarObjeto(candidato.substring(inicio, posicion + 1));
        }
      }
    }
    return null;
  }

  static Map<String, dynamic>? _decodificarObjeto(String texto) {
    try {
      final valor = jsonDecode(texto);
      return valor is Map<String, dynamic> ? valor : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _cabeceras() => {
        'x-api-key': _claveApi,
        'anthropic-version': versionApi,
        'content-type': 'application/json',
        'anthropic-dangerous-direct-browser-access': 'true',
      };

  RespuestaClaude _leerRespuesta(Map<String, dynamic> json) {
    final bloques = json['content'];
    final stopReason = json['stop_reason'] as String?;
    final textos = <String>[];
    if (bloques is List) {
      for (final bloque in bloques) {
        if (bloque is Map && bloque['type'] == 'text' && bloque['text'] is String) {
          textos.add(bloque['text'] as String);
        }
      }
    }
    final texto = textos.join();

    if (stopReason == 'refusal') {
      final categoria = (json['stop_details'] is Map)
          ? (json['stop_details'] as Map)['category'] as String?
          : null;
      throw ErrorClaude(
        MotivoErrorClaude.rechazado,
        'Claude ha preferido no responder a esta petición'
        '${categoria != null ? ' ($categoria)' : ''}. Prueba a reformularla.',
        codigoHttp: 200,
      );
    }
    if (texto.trim().isEmpty) {
      if (stopReason == 'max_tokens') {
        throw ErrorClaude(MotivoErrorClaude.cortado,
            'La respuesta de Claude se ha cortado antes de terminar. Inténtalo de nuevo.',
            codigoHttp: 200);
      }
      if (bloques is! List) {
        throw ErrorClaude(MotivoErrorClaude.respuestaRara,
            'Claude ha devuelto una respuesta que no se entiende.',
            codigoHttp: 200);
      }
    }

    final uso = json['usage'] is Map ? json['usage'] as Map : const {};
    return RespuestaClaude(
      texto: texto,
      stopReason: stopReason,
      modelo: json['model'] as String?,
      tokensEntrada: (uso['input_tokens'] as num?)?.toInt() ?? 0,
      tokensSalida: (uso['output_tokens'] as num?)?.toInt() ?? 0,
    );
  }

  ErrorClaude _errorPorEstado(http.Response respuestaHttp) {
    final codigo = respuestaHttp.statusCode;
    String? mensajeApi;
    try {
      final json = jsonDecode(utf8.decode(respuestaHttp.bodyBytes));
      if (json is Map && json['error'] is Map) {
        mensajeApi = (json['error'] as Map)['message'] as String?;
      }
    } catch (_) {}

    if (codigo == 401 || codigo == 403) {
      return ErrorClaude(MotivoErrorClaude.claveNoValida,
          'La clave de Anthropic no es válida. Revísala en Ajustes.',
          codigoHttp: codigo);
    }
    if (codigo == 429) {
      return ErrorClaude(MotivoErrorClaude.limite,
          'Se ha alcanzado el límite de uso de Claude o no queda saldo. Espera un poco o revisa tu cuenta de Anthropic.',
          codigoHttp: codigo);
    }
    if (codigo == 529 || codigo >= 500) {
      return ErrorClaude(MotivoErrorClaude.sobrecarga,
          'Claude está saturado en este momento. Inténtalo de nuevo en unos minutos.',
          codigoHttp: codigo);
    }
    return ErrorClaude(
      MotivoErrorClaude.peticionNoValida,
      'Claude ha rechazado la petición'
      '${mensajeApi != null ? ': $mensajeApi' : ' (error $codigo)'}.',
      codigoHttp: codigo,
    );
  }
}
