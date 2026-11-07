import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../datos/catalogos_generados/catalogo_plagas.dart';
import '../datos/catalogos_generados/catalogo_plagas_reguladas.dart';
import '../dominio/catalogos.dart';

/// Niveles de confianza que puede devolver el modelo, de más a menos.
const List<String> nivelesConfianza = ['alta', 'media', 'baja'];

/// Id que usa el modelo cuando lo que ve no está en la lista.
const String plagaFueraDelCatalogo = 'otra';

/// Una plaga candidata que se ofrece al modelo: común o regulada.
class PlagaCandidataIa {
  const PlagaCandidataIa({
    required this.id,
    required this.nombre,
    required this.nombreCientifico,
    required this.sintomas,
    required this.esRegulada,
  });

  final String id;
  final String nombre;
  final String nombreCientifico;
  final String sintomas;

  /// Cuarentenaria prioritaria o RNQP: si sale, la app abre una inspección
  /// con «sospecha» y recuerda el aviso a la autoridad.
  final bool esRegulada;
}

/// Un candidato de la respuesta, ya cruzado con el catálogo.
class CandidatoPlaga {
  const CandidatoPlaga(this.plaga, this.confianza, this.motivo);

  final PlagaCandidataIa plaga;

  /// Uno de [nivelesConfianza].
  final String confianza;
  final String motivo;
}

/// Lo que la IA propone a partir de una foto. **Siempre es una propuesta**:
/// la persona decide qué apunta; la app nunca propone un tratamiento ni da
/// una planta por sana.
class IdentificacionPlaga {
  const IdentificacionPlaga({
    required this.legible,
    required this.candidatos,
    required this.fueraDelCatalogo,
    required this.observaciones,
  });

  final bool legible;

  /// Ordenados por confianza, como mucho tres, solo de la lista ofrecida.
  final List<CandidatoPlaga> candidatos;
  final bool fueraDelCatalogo;
  final String observaciones;
}

/// Plagas que se ofrecen al modelo para una planta: las comunes de su grupo
/// de cultivo y las reguladas que la afectan por su nombre botánico o por la
/// ficha de la especie.
List<PlagaCandidataIa> plagasParaIdentificar(
    {String? especieId, String nombreBotanico = ''}) {
  final comunes = opcionesPlagas(especieId).map((opcion) => opcion.id).toSet();
  final deEspecie = especieId == null
      ? const <String>[]
      : especiePorId(especieId)?.plagasReguladas ?? const <String>[];
  return [
    for (final plaga in catalogoPlagas)
      if (comunes.contains(plaga.id))
        PlagaCandidataIa(
            id: plaga.id,
            nombre: plaga.nombre,
            nombreCientifico: plaga.nombreCientifico,
            sintomas: plaga.sintomas,
            esRegulada: false),
    for (final plaga in catalogoPlagasReguladas)
      if (deEspecie.contains(plaga.id) ||
          plagaReguladaAfecta(plaga, nombreBotanico))
        PlagaCandidataIa(
            id: plaga.id,
            nombre: plaga.nombre,
            nombreCientifico: plaga.nombreCientifico,
            sintomas: plaga.sintomas,
            esRegulada: true),
  ];
}

/// Esquema de salida estructurada, limitado a los ids ofrecidos.
Map<String, dynamic> esquemaIdentificacion(List<PlagaCandidataIa> plagas) => {
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
                  for (final plaga in plagas) plaga.id,
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

String sistemaIdentificacion(
    List<PlagaCandidataIa> plagas, String descripcionPlanta) {
  final lista = plagas
      .map((plaga) =>
          '- ${plaga.id}: ${plaga.nombre} (${plaga.nombreCientifico})'
          '${plaga.esRegulada ? ' [REGULADA]' : ''}. Síntomas: ${plaga.sintomas}')
      .join('\n');
  return '''
Miras la foto de una planta joven de vivero ($descripcionPlanta): plántula,
esqueje, hoja, tallo, raíz o sustrato. Propones qué plaga o enfermedad de esta
lista puede ser, sin inventar:
$lista
- Usa "$plagaFueraDelCatalogo" si parece otra cosa (riego, carencia, quemadura,
  frío, fitotoxicidad u otra plaga). Como mucho tres candidatos, del más
  probable al menos.
- "confianza": alta solo si los síntomas son característicos e inequívocos.
  Las marcadas [REGULADA] solo se confirman en laboratorio: nunca pongas
  "alta" en ellas.
- Si la foto no deja ver el síntoma, "legible": false y di qué foto hace falta.
- Nunca digas que la planta está sana ni libre de plagas: no se puede saber
  por una foto.
- Nunca recomiendes productos, sustancias, dosis ni tratamientos. Solo
  describes lo que ves.''';
}

/// Convierte la respuesta en [IdentificacionPlaga]: descarta ids que no se
/// ofrecieron, repetidos y confianzas desconocidas; una regulada nunca queda
/// con confianza «alta»; ordena y recorta.
IdentificacionPlaga interpretarIdentificacion(
    Map<String, dynamic> json, List<PlagaCandidataIa> plagas) {
  final validas = {for (final plaga in plagas) plaga.id: plaga};
  final candidatos = <CandidatoPlaga>[];
  var fueraDelCatalogo = false;
  final vistas = <String>{};
  for (final entrada
      in (json['candidatos'] is List ? json['candidatos'] as List : const [])) {
    if (entrada is! Map) continue;
    final id = (entrada['plaga_id'] as String?)?.trim() ?? '';
    var confianza = (entrada['confianza'] as String?)?.trim() ?? '';
    if (id == plagaFueraDelCatalogo) {
      fueraDelCatalogo = true;
      continue;
    }
    final plaga = validas[id];
    if (plaga == null || !nivelesConfianza.contains(confianza)) continue;
    if (!vistas.add(id)) continue;
    if (plaga.esRegulada && confianza == 'alta') confianza = 'media';
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
  required List<PlagaCandidataIa> plagas,
  required String descripcionPlanta,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: sistemaIdentificacion(plagas, descripcionPlanta),
    esquemaJson: esquemaIdentificacion(plagas),
    mensajes: [
      MensajeClaude.usuario('¿Qué plaga o enfermedad puede ser?',
          imagenes: [foto]),
    ],
  );
  return interpretarIdentificacion(respuesta, plagas);
}
