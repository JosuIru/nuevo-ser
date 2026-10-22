// Subido al core el 2026-10-22: era idéntico en solera-apicola,
// solera-viticultura, fósiles y naturaleza.
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../ia/cliente_claude.dart';

enum ProveedorChat { claude, deepseek }

class MensajeChat {
  final String texto;
  final bool esUsuario;
  final DateTime timestamp;
  final ProveedorChat? proveedor;
  final String? rutaImagen;

  MensajeChat({
    required this.texto,
    required this.esUsuario,
    this.proveedor,
    DateTime? timestamp,
    this.rutaImagen,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get tieneImagen => rutaImagen != null;

  Map<String, dynamic> toJson() => {
        't': texto,
        'u': esUsuario,
        'p': proveedor?.name,
        'ts': timestamp.millisecondsSinceEpoch,
        if (rutaImagen != null) 'img': rutaImagen,
      };

  factory MensajeChat.fromJson(Map<String, dynamic> json) => MensajeChat(
        texto: json['t'] as String,
        esUsuario: json['u'] as bool,
        proveedor: json['p'] != null
            ? ProveedorChat.values.firstWhere((p) => p.name == json['p'])
            : null,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int),
        rutaImagen: json['img'] as String?,
      );
}

class ServicioChat {
  final String apiKeyClaude;
  final String apiKeyDeepseek;
  final String modeloClaude;
  final String modeloDeepseek;

  /// Cliente HTTP para la parte de Claude (tests); null = el de por defecto.
  final http.Client? clienteHttpClaude;

  ServicioChat({
    required this.apiKeyClaude,
    required this.apiKeyDeepseek,
    this.modeloClaude = modeloClaudeRapido,
    this.modeloDeepseek = 'deepseek-chat',
    this.clienteHttpClaude,
  });

  Future<String> enviarMensaje(
    String mensaje, {
    required ProveedorChat proveedor,
    List<MensajeChat>? historial,
    String? sistemaPrompt,
    String? rutaImagen,
  }) async {
    if (rutaImagen != null && proveedor == ProveedorChat.deepseek) {
      return 'DeepSeek no puede analizar imágenes. Cambia a Claude para identificar fósiles con foto.';
    }
    switch (proveedor) {
      case ProveedorChat.claude:
        return _enviarAClaude(mensaje, historial: historial, sistemaPrompt: sistemaPrompt, rutaImagen: rutaImagen);
      case ProveedorChat.deepseek:
        return _enviarADeepseek(mensaje, historial: historial, sistemaPrompt: sistemaPrompt);
    }
  }

  Future<String> _enviarAClaude(
    String mensaje, {
    List<MensajeChat>? historial,
    String? sistemaPrompt,
    String? rutaImagen,
  }) async {
    final mensajes = <MensajeClaude>[
      for (final mensajeAnterior in (historial ?? const <MensajeChat>[]))
        mensajeAnterior.esUsuario
            ? MensajeClaude.usuario(mensajeAnterior.texto)
            : MensajeClaude.asistente(mensajeAnterior.texto),
      MensajeClaude.usuario(
        mensaje,
        imagenes: rutaImagen != null
            ? [await ImagenClaude.desdeFichero(rutaImagen)]
            : const [],
      ),
    ];

    final clienteClaude = ClienteClaude(
      claveApi: apiKeyClaude,
      cliente: clienteHttpClaude,
      timeout: const Duration(seconds: 60),
    );
    try {
      // El razonamiento cuenta en max_tokens: margen holgado y esfuerzo bajo.
      return await clienteClaude.pedirTexto(
        modelo: modeloClaudeActual(modeloClaude),
        mensajes: mensajes,
        sistema: sistemaPrompt ?? _sistemaPromptFosiles,
        maxTokens: 2048,
        esfuerzo: EsfuerzoClaude.bajo,
      );
    } on ErrorClaude catch (errorClaude) {
      // Mismo contrato que antes: Exception con el mensaje.
      throw Exception(errorClaude.mensaje);
    }
  }

  Future<String> _enviarADeepseek(
    String mensaje, {
    List<MensajeChat>? historial,
    String? sistemaPrompt,
  }) async {
    final mensajesApi = <Map<String, dynamic>>[];
    mensajesApi.add({
      'role': 'system',
      'content': sistemaPrompt ?? _sistemaPromptFosiles,
    });
    for (final m in (historial ?? const [])) {
      mensajesApi.add({
        'role': m.esUsuario ? 'user' : 'assistant',
        'content': m.texto,
      });
    }
    mensajesApi.add({'role': 'user', 'content': mensaje});

    final respuesta = await http.post(
      Uri.parse('https://api.deepseek.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKeyDeepseek',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': modeloDeepseek,
        'messages': mensajesApi,
        'max_tokens': 1024,
        'temperature': 0.7,
      }),
    ).timeout(const Duration(seconds: 45));

    if (respuesta.statusCode != 200) {
      final err = jsonDecode(respuesta.body);
      throw Exception(err['error']?['message'] ?? 'Error ${respuesta.statusCode}');
    }

    final json = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final choices = json['choices'] as List;
    final message = (choices.first as Map)['message'] as Map;
    return message['content'] as String;
  }

  static const _sistemaPromptFosiles =
      'Eres un asistente especializado en paleontología y geología para aficionados. '
      'Ayudas a identificar fósiles, interpretar formaciones geológicas, entender la '
      'cronoestratigrafía y dar consejos prácticos de campo. '
      'Hablas con precisión científica pero en tono accesible y entusiasta. '
      'Cuando no estés seguro de algo, lo dices claramente y sugieres consultar '
      'a un geólogo profesional o a un museo. '
      'Respondes en castellano. Sé conciso (máximo 3 párrafos salvo que te pidan detalle).';
}
