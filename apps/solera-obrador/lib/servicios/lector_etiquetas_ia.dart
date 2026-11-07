import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../modelos/alergenos.dart';

/// Lo que la IA ha leído en la foto de una etiqueta o ficha técnica.
/// **Siempre es una propuesta**: la persona la revisa antes de guardar.
class LecturaEtiqueta {
  LecturaEtiqueta({
    required this.nombreProducto,
    required this.ingredientes,
    required this.alergenos,
    required this.trazas,
    required this.legible,
    required this.observaciones,
  });

  final String nombreProducto;
  final List<String> ingredientes;
  final Set<String> alergenos;
  final Set<String> trazas;

  /// False si la foto no deja leer la lista con seguridad.
  final bool legible;
  final String observaciones;
}

/// Esquema de la salida estructurada que se pide al modelo.
const Map<String, dynamic> esquemaLecturaEtiqueta = {
  'type': 'object',
  'additionalProperties': false,
  'required': [
    'nombre_producto',
    'ingredientes',
    'alergenos',
    'trazas',
    'legible',
    'observaciones'
  ],
  'properties': {
    'nombre_producto': {'type': 'string'},
    'ingredientes': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'alergenos': {
      'type': 'array',
      'items': {'type': 'string', 'enum': alergenosObligatorios},
    },
    'trazas': {
      'type': 'array',
      'items': {'type': 'string', 'enum': alergenosObligatorios},
    },
    'legible': {'type': 'boolean'},
    'observaciones': {'type': 'string'},
  },
};

const String _sistema = '''
Lees la foto de la etiqueta o la ficha técnica de un ingrediente para un obrador
artesano (panadería, pastelería, conservas). Transcribes, no deduces.
- "ingredientes": la lista tal como aparece, en orden.
- "alergenos": solo los que la etiqueta declara (suelen ir resaltados), con los
  identificadores del esquema. No añadas alérgenos por intuición.
- "trazas": solo lo que aparece como «puede contener» o «trazas de».
- Si la foto no deja leer la lista con seguridad, "legible": false y explica por qué.
- Nunca digas que un producto es apto, seguro o sin gluten.
Responde en el idioma de la etiqueta en "observaciones" si hace falta.''';

/// Convierte la respuesta JSON en [LecturaEtiqueta], descartando lo que no
/// sea uno de los 14 alérgenos (aunque el esquema ya lo limita).
LecturaEtiqueta interpretarLecturaEtiqueta(Map<String, dynamic> json) {
  List<String> textos(Object? valor) => valor is List
      ? valor.whereType<String>().map((texto) => texto.trim()).toList()
      : const [];
  Set<String> alergenos(Object? valor) =>
      textos(valor).where(alergenosObligatorios.contains).toSet();
  final declarados = alergenos(json['alergenos']);
  return LecturaEtiqueta(
    nombreProducto: (json['nombre_producto'] as String?)?.trim() ?? '',
    ingredientes: textos(json['ingredientes'])
        .where((texto) => texto.isNotEmpty)
        .toList(),
    alergenos: declarados,
    trazas: alergenos(json['trazas']).difference(declarados),
    legible: json['legible'] == true,
    observaciones: (json['observaciones'] as String?)?.trim() ?? '',
  );
}

/// Envía la foto al modelo y devuelve la propuesta.
Future<LecturaEtiqueta> leerEtiquetaConIa({
  required String claveApi,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: _sistema,
    esquemaJson: esquemaLecturaEtiqueta,
    mensajes: [
      MensajeClaude.usuario('Lee esta etiqueta o ficha técnica.',
          imagenes: [foto]),
    ],
  );
  return interpretarLecturaEtiqueta(respuesta);
}
