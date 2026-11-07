import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../datos/catalogos_generados/catalogo_sustancias_activas.dart';
import '../dominio/busqueda_catalogos.dart';

/// Lo que la IA ha **transcrito** de la foto de una receta veterinaria.
/// Siempre es una propuesta: la persona la compara con la receta antes de
/// guardar. La IA no propone medicamentos, dosis ni plazos: si la receta no
/// los pone o no se leen, quedan vacíos.
class LecturaReceta {
  LecturaReceta({
    required this.medicamento,
    required this.sustanciasLeidas,
    required this.sustanciaCatalogo,
    required this.dosis,
    required this.duracionDias,
    required this.esperaCarneDias,
    required this.esperaLecheDias,
    required this.veterinario,
    required this.numeroReceta,
    required this.fecha,
    required this.legible,
    required this.observaciones,
  });

  final String medicamento;

  /// Tal como vienen en la receta.
  final List<String> sustanciasLeidas;

  /// La primera leída que está en el catálogo (null si ninguna).
  final SustanciaActivaCatalogo? sustanciaCatalogo;
  final String dosis;
  final int? duracionDias;
  final int? esperaCarneDias;
  final int? esperaLecheDias;
  final String veterinario;
  final String numeroReceta;
  final DateTime? fecha;

  /// False si la foto no deja leer la receta con seguridad.
  final bool legible;
  final String observaciones;

  /// Lo que se propone guardar como sustancia activa: el nombre del
  /// catálogo si coincide; si no, lo leído.
  String get sustanciaPropuesta =>
      sustanciaCatalogo?.nombre ?? sustanciasLeidas.join(' + ');
}

/// Esquema de la salida estructurada que se pide al modelo.
const Map<String, dynamic> esquemaLecturaReceta = {
  'type': 'object',
  'additionalProperties': false,
  'required': [
    'medicamento',
    'sustancias_activas',
    'cantidad',
    'duracion_dias',
    'espera_carne_dias',
    'espera_leche_dias',
    'veterinario',
    'numero_receta',
    'fecha',
    'legible',
    'observaciones',
  ],
  'properties': {
    'medicamento': {'type': 'string'},
    'sustancias_activas': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'cantidad': {'type': 'string'},
    'duracion_dias': {
      'type': 'integer',
      'description': '-1 si no aparece en la receta',
    },
    'espera_carne_dias': {
      'type': 'integer',
      'description': '-1 si no aparece en la receta',
    },
    'espera_leche_dias': {
      'type': 'integer',
      'description': '-1 si no aparece en la receta',
    },
    'veterinario': {'type': 'string'},
    'numero_receta': {'type': 'string'},
    'fecha': {'type': 'string', 'description': 'AAAA-MM-DD o vacío'},
    'legible': {'type': 'boolean'},
    'observaciones': {'type': 'string'},
  },
};

const String _sistema = '''
Transcribes la foto de una receta veterinaria para el registro de tratamientos
de una explotación ganadera. Transcribes, no deduces ni recomiendas.
- Copia el medicamento, las sustancias activas, la cantidad o posología, la
  duración, los tiempos de espera de carne y de leche, el veterinario, el número
  de receta y la fecha TAL COMO APARECEN.
- Si un dato no aparece o no se lee con seguridad, déjalo vacío (o -1 en los
  números de días). Nunca
  pongas un tiempo de espera que no esté escrito en la receta, ni lo calcules.
- No propongas medicamentos, dosis ni diagnósticos, ni opines sobre el tratamiento.
- Si la foto no deja leer la receta con seguridad, "legible": false y explica por
  qué en "observaciones".''';

int? _enteroNoNegativo(Object? valor) {
  if (valor is num && valor >= 0) return valor.toInt();
  if (valor is String) {
    final numero = int.tryParse(valor.trim());
    if (numero != null && numero >= 0) return numero;
  }
  return null;
}

/// Convierte la respuesta JSON en [LecturaReceta] y busca la sustancia en el
/// catálogo. Lo que no tiene forma válida se descarta.
LecturaReceta interpretarLecturaReceta(Map<String, dynamic> json) {
  String texto(Object? valor) => valor is String ? valor.trim() : '';
  final sustancias = (json['sustancias_activas'] is List
          ? json['sustancias_activas'] as List
          : const [])
      .whereType<String>()
      .map((sustancia) => sustancia.trim())
      .where((sustancia) => sustancia.isNotEmpty)
      .toList();
  final fechaLeida = DateTime.tryParse(texto(json['fecha']));
  return LecturaReceta(
    medicamento: texto(json['medicamento']),
    sustanciasLeidas: sustancias,
    sustanciaCatalogo: sustancias
        .map(buscarSustanciaActiva)
        .whereType<SustanciaActivaCatalogo>()
        .firstOrNull,
    dosis: texto(json['cantidad']),
    duracionDias: _enteroNoNegativo(json['duracion_dias']),
    esperaCarneDias: _enteroNoNegativo(json['espera_carne_dias']),
    esperaLecheDias: _enteroNoNegativo(json['espera_leche_dias']),
    veterinario: texto(json['veterinario']),
    numeroReceta: texto(json['numero_receta']),
    fecha: fechaLeida == null
        ? null
        : DateTime(fechaLeida.year, fechaLeida.month, fechaLeida.day),
    legible: json['legible'] == true,
    observaciones: texto(json['observaciones']),
  );
}

/// Envía la foto al modelo y devuelve la propuesta. La foto no se guarda.
Future<LecturaReceta> leerRecetaConIa({
  required String claveApi,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: _sistema,
    esquemaJson: esquemaLecturaReceta,
    mensajes: [
      MensajeClaude.usuario('Transcribe esta receta veterinaria.',
          imagenes: [foto]),
    ],
  );
  return interpretarLecturaReceta(respuesta);
}
