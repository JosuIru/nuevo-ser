import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../datos/catalogos_generados/catalogo_plagas_manzano.dart';
import '../dominio/catalogos.dart';

/// Valores de `plaga_id` además de los del catálogo.
const String sinPlagaVisible = 'ninguna';
const String plagaNoIdentificada = 'no_identificada';

const List<String> confianzasDiagnostico = ['alta', 'media', 'baja'];

/// Lo que la IA cree ver en la foto. **Siempre es una propuesta**: la
/// persona la revisa y decide; nunca trae un producto ni una dosis.
class DiagnosticoPlaga {
  DiagnosticoPlaga({
    required this.plagaId,
    required this.confianza,
    required this.otrasPosibles,
    required this.sintomasObservados,
    required this.fotoValida,
    required this.observaciones,
  });

  /// Id del catálogo `plagas_manzano`, [sinPlagaVisible] o
  /// [plagaNoIdentificada].
  final String plagaId;

  /// `alta`, `media` o `baja`.
  final String confianza;

  /// Otras plagas del catálogo que podrían ser (sin la principal).
  final List<String> otrasPosibles;
  final String sintomasObservados;

  /// False si la foto no es de un manzano o no deja ver nada.
  final bool fotoValida;
  final String observaciones;

  /// La plaga del catálogo, si la propuesta es una de ellas.
  PlagaManzano? get plaga => plagaPorId(plagaId);

  /// Se puede ofrecer «apuntar tratamiento» con esta plaga.
  bool get esPlagaDelCatalogo => fotoValida && plaga != null;
}

/// Esquema de la salida estructurada: la plaga solo puede ser una del
/// catálogo (o «ninguna» / «no identificada»).
Map<String, dynamic> esquemaDiagnosticoPlaga() {
  final ids = catalogoPlagasManzano.map((plaga) => plaga.id).toList();
  return {
    'type': 'object',
    'additionalProperties': false,
    'required': [
      'plaga_id',
      'confianza',
      'otras_posibles',
      'sintomas_observados',
      'foto_valida',
      'observaciones',
    ],
    'properties': {
      'plaga_id': {
        'type': 'string',
        'enum': [...ids, sinPlagaVisible, plagaNoIdentificada],
      },
      'confianza': {'type': 'string', 'enum': confianzasDiagnostico},
      'otras_posibles': {
        'type': 'array',
        'items': {'type': 'string', 'enum': ids},
      },
      'sintomas_observados': {'type': 'string'},
      'foto_valida': {'type': 'boolean'},
      'observaciones': {'type': 'string'},
    },
  };
}

String _sistema() {
  final lista = catalogoPlagasManzano
      .map((plaga) =>
          '- ${plaga.id}: ${plaga.nombre} (${plaga.nombreCientifico})')
      .join('\n');
  return '''
Miras la foto de un manzano de sidra (hoja, fruto, rama, flor o cuello) que ha
hecho quien lleva la pomarada. Propones qué plaga o enfermedad de esta lista se
ve, o "ninguna" si la planta parece sana, o "no_identificada" si hay un daño que
no encaja:
$lista
- Describe en "sintomas_observados" solo lo que se ve en la foto.
- "confianza": baja si la foto es borrosa, lejana o los síntomas son comunes a
  varias; "otras_posibles" con las alternativas razonables.
- Si la foto no es de un manzano o no deja ver nada, "foto_valida": false.
- No recomiendes productos, marcas, dosis ni tratamientos: eso no es tu papel.
- No afirmes con seguridad: es una propuesta que revisa una persona.
Escribe "sintomas_observados" y "observaciones" en castellano, breves.''';
}

/// Convierte la respuesta JSON en [DiagnosticoPlaga], descartando lo que no
/// sea del catálogo (aunque el esquema ya lo limita).
DiagnosticoPlaga interpretarDiagnosticoPlaga(Map<String, dynamic> json) {
  final idsCatalogo = catalogoPlagasManzano.map((plaga) => plaga.id).toSet();
  final propuesta = json['plaga_id'];
  final plagaId = propuesta is String &&
          (idsCatalogo.contains(propuesta) ||
              propuesta == sinPlagaVisible ||
              propuesta == plagaNoIdentificada)
      ? propuesta
      : plagaNoIdentificada;
  final confianza = json['confianza'];
  final otras = json['otras_posibles'];
  return DiagnosticoPlaga(
    plagaId: plagaId,
    confianza: confianzasDiagnostico.contains(confianza)
        ? confianza as String
        : 'baja',
    otrasPosibles: otras is List
        ? otras
            .whereType<String>()
            .where((id) => idsCatalogo.contains(id) && id != plagaId)
            .toSet()
            .toList()
        : const [],
    sintomasObservados: (json['sintomas_observados'] as String?)?.trim() ?? '',
    fotoValida: json['foto_valida'] == true,
    observaciones: (json['observaciones'] as String?)?.trim() ?? '',
  );
}

/// Envía la foto al modelo y devuelve la propuesta.
Future<DiagnosticoPlaga> diagnosticarPlagaConIa({
  required String claveApi,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: _sistema(),
    esquemaJson: esquemaDiagnosticoPlaga(),
    mensajes: [
      MensajeClaude.usuario('¿Qué se ve en este manzano?', imagenes: [foto]),
    ],
  );
  return interpretarDiagnosticoPlaga(respuesta);
}
