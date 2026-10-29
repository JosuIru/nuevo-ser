import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Prefijo de preferencias de la app: la clave vive en
/// `solera_quesera.anthropic.clave`, la misma de siempre.
const String prefijoPreferenciasSoleraQuesera = 'solera_quesera';

/// Clave de Anthropic de Larrea Quesera (solo en el dispositivo).
final EstadoClaveAnthropic estadoClaveAnthropicQuesera =
    EstadoClaveAnthropic.paraApp(prefijoPreferenciasSoleraQuesera);

/// Prueba la clave con una petición mínima al modelo rápido. Devuelve
/// null si funciona o el mensaje del error si no.
Future<String?> probarClaveAnthropicQuesera(String clave) async {
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

/// Pantalla común de la clave con los textos de la quesería.
Widget pantallaClaveAnthropicQuesera() => PantallaClaveAnthropic(
      estado: estadoClaveAnthropicQuesera,
      nombreApp: 'Larrea Quesera',
      titulo: SoleraL10n.t('identificacion_con_ia'),
      queIdentifica: 'Identifica defectos en el corte y la corteza del queso',
      descripcion: 'Con tu propia clave de Anthropic, Larrea Quesera puede '
          'analizar la foto de un queso (corte o corteza) y señalar posibles '
          'defectos de textura, corteza, color o hinchazón, con su causa '
          'probable y qué revisar. La herramienta está en Lotes → Cava. '
          'No sustituye a una analítica: ante la duda, deriva al laboratorio.',
      probarClave: probarClaveAnthropicQuesera,
    );
