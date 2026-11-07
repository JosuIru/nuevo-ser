import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../datos/catalogos_generados/catalogo_plagas.dart';

/// Niveles de confianza que puede devolver el modelo, de más a menos.
const List<String> nivelesConfianza = ['alta', 'media', 'baja'];

/// Id que usa el modelo cuando lo que ve no está en la lista.
const String plagaFueraDelCatalogo = 'otra';

/// Una plaga o enfermedad candidata, ya cruzada con el catálogo.
class CandidatoPlaga {
  const CandidatoPlaga(this.plaga, this.confianza, this.motivo);

  final PlagaCatalogo plaga;

  /// Uno de [nivelesConfianza].
  final String confianza;
  final String motivo;
}

/// Lo que la IA propone a partir de una foto. **Siempre es una propuesta**:
/// la persona decide qué apunta; la app nunca propone un tratamiento.
class IdentificacionPlaga {
  const IdentificacionPlaga({
    required this.legible,
    required this.candidatos,
    required this.fueraDelCatalogo,
    required this.observaciones,
  });

  /// False si la foto no deja ver el síntoma con claridad.
  final bool legible;

  /// Ordenados por confianza, como mucho tres, solo del catálogo.
  final List<CandidatoPlaga> candidatos;

  /// El modelo cree que es algo que no está en la lista.
  final bool fueraDelCatalogo;
  final String observaciones;
}

/// Plagas del catálogo para una especie (las que se ofrecen al modelo).
List<PlagaCatalogo> plagasParaIdentificar(String especieId) => [
      for (final plaga in catalogoPlagas)
        if (plaga.especies.contains(especieId)) plaga
    ];

/// Esquema de salida estructurada, limitado a los ids de la especie.
Map<String, dynamic> esquemaIdentificacion(String especieId) => {
      'type': 'object',
      'additionalProperties': false,
      'required': ['legible', 'candidatos', 'observaciones'],
      'properties': {
        'legible': {'type': 'boolean'},
        'candidatos': {
          'type': 'array',
          'items': {
            'type': 'object',
            'additionalProperties': false,
            'required': ['plaga_id', 'confianza', 'motivo'],
            'properties': {
              'plaga_id': {
                'type': 'string',
                'enum': [
                  for (final plaga in plagasParaIdentificar(especieId))
                    plaga.id,
                  plagaFueraDelCatalogo,
                ],
              },
              'confianza': {'type': 'string', 'enum': nivelesConfianza},
              'motivo': {'type': 'string'},
            },
          },
        },
        'observaciones': {'type': 'string'},
      },
    };

String _sistema(String especieId) {
  final lista = plagasParaIdentificar(especieId)
      .map((plaga) =>
          '- ${plaga.id}: ${plaga.nombre} (${plaga.nombreCientifico}). Síntomas: ${plaga.sintomas}')
      .join('\n');
  return '''
Miras la foto de un árbol de la especie «$especieId» (hoja, fruto, rama, tronco
o trampa) para un cuaderno de campo. Propones qué plaga o enfermedad de esta
lista puede ser, sin inventar:
$lista
- Usa "$plagaFueraDelCatalogo" si parece otra cosa (carencia, helada, granizo,
  otra plaga). Como mucho tres candidatos, del más probable al menos.
- "confianza": alta solo si los síntomas son característicos e inequívocos.
- Si la foto no deja ver el síntoma, "legible": false y di qué foto hace falta.
- Nunca recomiendes productos, sustancias, dosis ni tratamientos: eso lo decide
  la persona con su asesor. Solo describes lo que ves.''';
}

/// Convierte la respuesta en [IdentificacionPlaga]: descarta ids que no son
/// de la especie, repetidos y confianzas desconocidas; ordena y recorta.
IdentificacionPlaga interpretarIdentificacion(
    Map<String, dynamic> json, String especieId) {
  final validas = {
    for (final plaga in plagasParaIdentificar(especieId)) plaga.id: plaga
  };
  final candidatos = <CandidatoPlaga>[];
  var fueraDelCatalogo = false;
  final vistas = <String>{};
  for (final entrada
      in (json['candidatos'] is List ? json['candidatos'] as List : const [])) {
    if (entrada is! Map) continue;
    final id = (entrada['plaga_id'] as String?)?.trim() ?? '';
    final confianza = (entrada['confianza'] as String?)?.trim() ?? '';
    if (id == plagaFueraDelCatalogo) {
      fueraDelCatalogo = true;
      continue;
    }
    final plaga = validas[id];
    if (plaga == null || !nivelesConfianza.contains(confianza)) continue;
    if (!vistas.add(id)) continue;
    candidatos.add(CandidatoPlaga(
        plaga, confianza, (entrada['motivo'] as String?)?.trim() ?? ''));
  }
  candidatos.sort((a, b) => nivelesConfianza
      .indexOf(a.confianza)
      .compareTo(nivelesConfianza.indexOf(b.confianza)));
  return IdentificacionPlaga(
    legible: json['legible'] == true,
    candidatos: candidatos.take(3).toList(),
    fueraDelCatalogo: fueraDelCatalogo,
    observaciones: (json['observaciones'] as String?)?.trim() ?? '',
  );
}

/// Envía la foto al modelo (clave de la persona) y devuelve la propuesta.
Future<IdentificacionPlaga> identificarPlagaConIa({
  required String claveApi,
  required String especieId,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: _sistema(especieId),
    esquemaJson: esquemaIdentificacion(especieId),
    mensajes: [
      MensajeClaude.usuario('¿Qué plaga o enfermedad puede ser?',
          imagenes: [foto]),
    ],
  );
  return interpretarIdentificacion(respuesta, especieId);
}
