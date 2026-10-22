import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Prefijo de las preferencias de Solera Viticultura. La clave de
/// Anthropic vive en `solera_viticultura.anthropic.clave` desde la v0.1:
/// no cambiarlo o se perdería la clave ya guardada.
const String prefijoPreferenciasViticultura = 'solera_viticultura';

/// Clave de Anthropic de la persona (modelo «trae tu clave»), guardada
/// solo en el dispositivo. Instancia única para toda la app.
final EstadoClaveAnthropic estadoClaveAnthropicViticultura =
    EstadoClaveAnthropic.paraApp(prefijoPreferenciasViticultura);

/// Prueba [clave] con una petición mínima a Claude. Devuelve null si
/// funciona o el mensaje de error para enseñar a la persona.
Future<String?> probarClaveAnthropicViticultura(String clave) async {
  try {
    await ClienteClaude(claveApi: clave).pedirTexto(
      modelo: modeloClaudeRapido,
      mensajes: [MensajeClaude.usuario('Responde solo: ok')],
      maxTokens: 1024,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return null;
  } on ErrorClaude catch (errorClaude) {
    return errorClaude.mensaje;
  }
}
