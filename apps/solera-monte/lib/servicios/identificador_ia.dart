// Identificación de plagas y daños forestales por foto con la IA (clave de
// la persona). **Siempre es una propuesta**: nunca lleva a un tratamiento ni
// recomienda productos, y ante una plaga prioritaria de la UE la app avisa
// de que hay que llamar al servicio de sanidad forestal de la comunidad.

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../dominio/catalogos.dart';

/// Niveles de confianza que puede devolver el modelo, de más a menos.
const List<String> nivelesConfianza = ['alta', 'media', 'baja'];

/// Id que usa el modelo cuando lo que ve no está en la lista.
const String fueraDelCatalogo = 'otra';

/// Un candidato ya cruzado con el catálogo.
class CandidatoPlaga {
  const CandidatoPlaga(this.plaga, this.confianza, this.motivo);

  final PlagaForestal plaga;

  /// Uno de [nivelesConfianza].
  final String confianza;
  final String motivo;
}

/// Lo que la IA propone a partir de una foto.
class PropuestaPlaga {
  const PropuestaPlaga({
    required this.legible,
    required this.candidatos,
    required this.fueraDelCatalogo,
    required this.observaciones,
    required this.queComprobar,
  });

  /// False si la foto no deja ver lo necesario.
  final bool legible;

  /// Ordenados por confianza, como mucho tres, solo del catálogo.
  final List<CandidatoPlaga> candidatos;

  /// El modelo cree que es otra cosa (sequía, fuego, otra plaga…).
  final bool fueraDelCatalogo;
  final String observaciones;

  /// Qué mirar en el árbol para confirmarlo.
  final String queComprobar;

  /// Alguno de los candidatos es plaga prioritaria de la Unión.
  bool get hayPrioritaria =>
      candidatos.any((candidato) => candidato.plaga.aviso == 'prioritaria_ue');

  /// Alguno de los candidatos es urticante (procesionaria).
  bool get hayUrticante =>
      candidatos.any((candidato) => candidato.plaga.aviso == 'urticante');
}

/// Plagas que se ofrecen al modelo: las que afectan a la especie (por
/// especie o por género) o, sin especie, todo el catálogo.
List<PlagaForestal> plagasParaIdentificar(String? especieId) =>
    especieId == null || especieId.isEmpty
        ? [...catalogoPlagas]
        : plagasDeEspecies([especieId]);

/// Esquema de salida (ids de las plagas ofrecidas y «otra»).
Map<String, dynamic> esquemaPlaga(String? especieId) => {
      'type': 'object',
      'additionalProperties': false,
      'required': ['legible', 'candidatos', 'observaciones', 'que_comprobar'],
      'properties': {
        'legible': {'type': 'boolean'},
        'candidatos': {
          'type': 'array',
          'items': {
            'type': 'object',
            'additionalProperties': false,
            'required': ['id', 'confianza', 'motivo'],
            'properties': {
              'id': {
                'type': 'string',
                'enum': [
                  for (final plaga in plagasParaIdentificar(especieId))
                    plaga.id,
                  fueraDelCatalogo,
                ],
              },
              'confianza': {'type': 'string', 'enum': nivelesConfianza},
              'motivo': {'type': 'string'},
            },
          },
        },
        'observaciones': {'type': 'string'},
        'que_comprobar': {'type': 'string'},
      },
    };

/// Instrucciones. Públicas para el test de los hard limits.
String sistemaPlaga(String? especieId) {
  final lista = plagasParaIdentificar(especieId)
      .map((plaga) =>
          '- ${plaga.id}: ${plaga.nombre} (${plaga.nombreCientifico}). '
          'Daña: ${plaga.organos}. Síntomas: ${plaga.sintomas}')
      .join('\n');
  final arbol = especieId == null || especieId.isEmpty
      ? 'un árbol del monte'
      : 'un árbol de ${nombreEspecie(especieId)} (${nombreCientificoEspecie(especieId)})';
  return '''
Miras la foto de $arbol (copa, hojas o acículas, tronco, corteza, frutos o
una trampa) para el cuaderno de un monte. Propones qué plaga, enfermedad o
daño de esta lista puede ser, sin inventar:
$lista
- Usa "$fueraDelCatalogo" si parece otra cosa (sequía, fuego, nieve o viento,
  ramoneo de ganado o fauna, otra plaga). Como mucho tres candidatos, del más
  probable al menos.
- "confianza": alta solo si los síntomas son característicos e inequívocos;
  muchos daños se parecen (perforadores entre sí, sequía y hongos de acícula),
  y en la duda, media o baja.
- En "que_comprobar" di qué hay que mirar en el árbol para confirmarlo
  (galerías bajo la corteza, orificios, serrín, bolsones, puestas).
- Si la foto no deja ver el síntoma, "legible": false y di qué foto hace falta.
- Nunca recomiendes productos, sustancias, dosis ni tratamientos: eso lo decide
  el técnico forestal o el servicio de sanidad forestal. Solo describes lo que
  ves.''';
}

/// Convierte la respuesta en una propuesta: descarta ids que no se
/// ofrecieron, repetidos y confianzas desconocidas; ordena y recorta a tres.
PropuestaPlaga interpretarPlaga(Map<String, dynamic> json, String? especieId) {
  final validas = {
    for (final plaga in plagasParaIdentificar(especieId)) plaga.id: plaga
  };
  final candidatos = <CandidatoPlaga>[];
  var otra = false;
  final vistas = <String>{};
  for (final entrada
      in (json['candidatos'] is List ? json['candidatos'] as List : const [])) {
    if (entrada is! Map) continue;
    final id = (entrada['id'] as String?)?.trim() ?? '';
    final confianza = (entrada['confianza'] as String?)?.trim() ?? '';
    if (id == fueraDelCatalogo) {
      otra = true;
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
  return PropuestaPlaga(
    legible: json['legible'] == true,
    candidatos: candidatos.take(3).toList(),
    fueraDelCatalogo: otra,
    observaciones: (json['observaciones'] as String?)?.trim() ?? '',
    queComprobar: (json['que_comprobar'] as String?)?.trim() ?? '',
  );
}

/// Envía la foto al modelo y devuelve la propuesta.
Future<PropuestaPlaga> identificarPlagaConIa({
  required String claveApi,
  required String? especieId,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: sistemaPlaga(especieId),
    esquemaJson: esquemaPlaga(especieId),
    mensajes: [
      MensajeClaude.usuario('¿Qué plaga, enfermedad o daño puede ser?',
          imagenes: [foto]),
    ],
  );
  return interpretarPlaga(respuesta, especieId);
}
