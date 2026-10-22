import 'dart:io';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

class ResultadoAnalisisIA {
  final String nombreDefecto;
  final String tipo; // textura / corteza / color / sabor / hinchazon / otro
  final int? severidad;
  final double confianza;
  final String descripcion;
  final String posibleCausa;
  final String accionRecomendada;
  final String advertencia;

  ResultadoAnalisisIA({
    required this.nombreDefecto,
    required this.tipo,
    this.severidad,
    required this.confianza,
    this.descripcion = '',
    this.posibleCausa = '',
    this.accionRecomendada = '',
    this.advertencia = '',
  });

  /// Lee el JSON que devuelve el modelo (claves del prompt de sistema).
  factory ResultadoAnalisisIA.desdeJson(Map<String, dynamic> json) =>
      ResultadoAnalisisIA(
        nombreDefecto: (json['nombre_defecto'] as String?) ?? 'Sin identificar',
        tipo: (json['tipo'] as String?) ?? 'otro',
        severidad: (json['severidad'] as num?)?.toInt(),
        confianza:
            ((json['confianza'] as num?)?.toDouble() ?? 0).clamp(0, 1).toDouble(),
        descripcion: (json['descripcion'] as String?) ?? '',
        posibleCausa: (json['posible_causa'] as String?) ?? '',
        accionRecomendada: (json['accion_recomendada'] as String?) ?? '',
        advertencia: (json['advertencia'] as String?) ?? '',
      );
}

/// Tamaño máximo de foto que se envía (la API admite 5 MB por imagen).
const int tamanoMaximoFotoBytes = 5 * 1024 * 1024;

/// Identificación de defectos en queso artesanal por foto (corte y
/// corteza). El transporte (petición, imagen, errores) es el
/// [ClienteClaude] del core con el modelo rápido (Haiku 5.5); aquí solo
/// vive el prompt quesero y la lectura del resultado. Los errores que
/// llegan a la pantalla son [ErrorClaude], con su mensaje en castellano
/// (también la negativa por los filtros de seguridad).
class ClienteAnthropicQuesero {
  ClienteAnthropicQuesero(String claveApi, {ClienteClaude? clienteClaude})
      : _clienteClaude = clienteClaude ?? ClienteClaude(claveApi: claveApi);

  final ClienteClaude _clienteClaude;

  Future<ResultadoAnalisisIA> analizarFoto({
    required File foto,
    String observaciones = '',
  }) async {
    final imagen = await ImagenClaude.desdeFichero(foto.path);
    if (imagen.bytes.length > tamanoMaximoFotoBytes) {
      throw ErrorClaude(MotivoErrorClaude.peticionNoValida,
          'La foto pesa más de 5 MB. Reduce el tamaño antes de enviarla.');
    }
    final json = await _clienteClaude.pedirJson(
      modelo: modeloClaudeRapido,
      sistema: _promptSistema,
      mensajes: [
        MensajeClaude.usuario(construirPromptAnalisis(observaciones),
            imagenes: [imagen]),
      ],
      maxTokens: 4096,
      esfuerzo: EsfuerzoClaude.bajo,
    );
    return ResultadoAnalisisIA.desdeJson(json);
  }
}

const String _promptSistema = '''
Eres un maestro quesero con formación en tecnología de alimentos y análisis sensorial. Te paso la foto de un queso artesanal (corte o corteza) y debes identificar posibles defectos o alteraciones.

CATÁLOGO DE DEFECTOS COMUNES EN QUESO ARTESANAL (no exhaustivo):
- Textura: ojos excesivos (mecánica o fermentación contaminante), falta de ojos, ojos irregulares, hendiduras internas, textura harinosa, gomosa, pegajosa, cristales de tirosina.
- Corteza: grietas, moho superficial no deseado, ácaros, separación corteza-pasta, corteza excesivamente seca o húmeda, manchas anormales.
- Color: color anormal de la pasta, manchas grises, distribución irregular del color, vetas de color no deseadas.
- Sabor/olor (si se describe en observaciones): amargor, acidez excesiva, picante anómalo, rancidez, sabores a moho, sabores metálicos.
- Hinchazón: hinchazón precoz (primeros días), hinchazón tardía (semanas/meses, posible contaminación por clostridios butíricos).
- Otros: exudado excesivo, costra anormal, deformación, ataque de insectos, roedores.

REGLAS ESTRICTAS:
1. Responde SOLO con JSON, sin texto antes ni después.
2. Estructura del JSON:
{
  "nombre_defecto": "nombre del defecto en español",
  "tipo": "textura" | "corteza" | "color" | "sabor" | "hinchazon" | "otro",
  "severidad": número entero 1-5 (1=sutil, 5=masivo/impropio para consumo),
  "confianza": número decimal 0.0-1.0,
  "descripcion": "descripción breve de lo que observas en la foto",
  "posible_causa": "qué pudo causarlo (en 1-2 frases)",
  "accion_recomendada": "acción correctiva o de manejo (limpieza cava, ajuste HR, revisar pH, derivar a analítica...)",
  "advertencia": "si la foto es borrosa, hay poca luz, o el diagnóstico incierto, dilo aquí. Vacío si confianza alta."
}
3. NO emitas juicios sobre seguridad alimentaria. Si hay duda, recomienda derivar a analítica.
4. NO recomiendes productos comerciales. Solo acciones de manejo.
5. Si no ves ningún defecto, devuelve tipo="otro", confianza=0, y explica que el queso parece visualmente correcto.
6. Sé conservador con severidad: 5 solo para alteraciones graves (moho generalizado, hinchazón severa, claramente no apto).
''';

/// Texto del mensaje que acompaña a la foto.
String construirPromptAnalisis(String observaciones) {
  if (observaciones.trim().isNotEmpty) {
    return 'Observaciones del quesero: ${observaciones.trim()}\n\nAnaliza el queso de la foto e identifica defectos.';
  }
  return 'Analiza el queso de la foto e identifica posibles defectos visibles.';
}
