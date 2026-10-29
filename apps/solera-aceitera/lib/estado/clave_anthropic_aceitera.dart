import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Prefijo de las preferencias de Larrea Aceitera. La clave de Anthropic
/// vive en `solera_aceitera.anthropic.clave` desde la primera versión:
/// no cambiarlo o la gente perdería la clave guardada.
const String prefijoPreferenciasAceitera = 'solera_aceitera';

/// Clave de Anthropic de la persona (solo en el dispositivo). Instancia
/// única para que `hayClave` sea el mismo en toda la app.
final EstadoClaveAnthropic estadoClaveAnthropicAceitera =
    EstadoClaveAnthropic.paraApp(prefijoPreferenciasAceitera);

/// Prueba una clave con una petición mínima a Claude. Devuelve null si
/// funciona o el mensaje del error para enseñar.
Future<String?> probarClaveAnthropicAceitera(String clave) async {
  try {
    await ClienteClaude(claveApi: clave).pedirTexto(
      modelo: modeloClaudeRapido,
      mensajes: [MensajeClaude.usuario('Responde solo: ok')],
      maxTokens: 1024,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return null;
  } on ErrorClaude catch (error) {
    return error.mensaje;
  }
}

/// Pantalla común de la clave con los textos del olivar.
Widget construirPantallaClaveAnthropicAceitera() => PantallaClaveAnthropic(
      estado: estadoClaveAnthropicAceitera,
      nombreApp: 'Larrea Aceitera',
      titulo: 'Identificación con IA',
      queIdentifica: 'Identifica plagas y variedades del olivar por foto',
      descripcion:
          'La identificación visual de plagas, enfermedades y variedades '
          'del olivar usa Claude, de Anthropic. Pega aquí tu clave '
          'personal: se guarda sólo en este dispositivo y nunca pasa por '
          'un servidor de Larrea; las fotos van directas a Anthropic.\n\n'
          'Las consultas se cobran en tu cuenta de Anthropic (unas décimas '
          'de céntimo cada una con Claude Haiku). El resultado es una '
          'ayuda: contrástalo con tu técnico.',
      probarClave: probarClaveAnthropicAceitera,
    );
