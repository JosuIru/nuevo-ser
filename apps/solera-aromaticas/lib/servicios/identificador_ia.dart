// Identificación por foto con la IA (clave de la persona): especie de una
// planta y plaga en cultivo. **Siempre es una propuesta**, nunca una
// afirmación: la identificación de una especie por IA **nunca habilita el
// consumo** (hard limit) y la de una plaga nunca lleva a un tratamiento.
//
// Los prompts no hablan de usos ni de propiedades de salud de las plantas
// (hard limit; lo vigila test/hard_limits_test.dart).

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show ClienteClaude, ImagenClaude, MensajeClaude, modeloClaudeEquilibrado;

import '../datos/catalogos_generados/catalogo_especies.dart';
import '../datos/catalogos_generados/catalogo_plagas.dart';

/// Niveles de confianza que puede devolver el modelo, de más a menos.
const List<String> nivelesConfianza = ['alta', 'media', 'baja'];

/// Id que usa el modelo cuando lo que ve no está en la lista.
const String fueraDelCatalogo = 'otra';

/// Un candidato ya cruzado con el catálogo ([T] es la fila del catálogo).
class Candidato<T> {
  const Candidato(this.fila, this.confianza, this.motivo);

  final T fila;

  /// Uno de [nivelesConfianza].
  final String confianza;
  final String motivo;
}

/// Lo que la IA propone a partir de una foto.
class PropuestaIa<T> {
  const PropuestaIa({
    required this.legible,
    required this.candidatos,
    required this.fueraDelCatalogo,
    required this.observaciones,
    this.rasgosAComprobar = '',
  });

  /// False si la foto no deja ver lo necesario.
  final bool legible;

  /// Ordenados por confianza, como mucho tres, solo del catálogo.
  final List<Candidato<T>> candidatos;

  /// El modelo cree que es algo que no está en la lista.
  final bool fueraDelCatalogo;
  final String observaciones;

  /// Solo en especies: qué mirar en la planta para confirmarla.
  final String rasgosAComprobar;
}

Map<String, dynamic> _esquema(List<String> ids, {required bool conRasgos}) => {
      'type': 'object',
      'additionalProperties': false,
      'required': [
        'legible',
        'candidatos',
        'observaciones',
        if (conRasgos) 'rasgos_a_comprobar',
      ],
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
                'enum': [...ids, fueraDelCatalogo],
              },
              'confianza': {'type': 'string', 'enum': nivelesConfianza},
              'motivo': {'type': 'string'},
            },
          },
        },
        'observaciones': {'type': 'string'},
        if (conRasgos) 'rasgos_a_comprobar': {'type': 'string'},
      },
    };

/// Esquema de salida para identificar la especie (todas las del catálogo).
Map<String, dynamic> esquemaEspecie() =>
    _esquema([for (final especie in catalogoEspecies) especie.id],
        conRasgos: true);

/// Plagas del catálogo para una especie (las que se ofrecen al modelo).
List<PlagaCatalogo> plagasParaIdentificar(String especieId) => [
      for (final plaga in catalogoPlagas)
        if (plaga.especies.contains(especieId)) plaga
    ];

/// Esquema de salida para la plaga, limitado a las de la especie.
Map<String, dynamic> esquemaPlaga(String especieId) =>
    _esquema([for (final plaga in plagasParaIdentificar(especieId)) plaga.id],
        conRasgos: false);

/// Instrucciones para la especie. Públicas para el test del hard limit.
String sistemaEspecie() {
  final lista = catalogoEspecies
      .map((especie) =>
          '- ${especie.id}: ${especie.nombre} (${especie.nombreCientifico}), ${especie.familia}')
      .join('\n');
  return '''
Miras la foto de una planta para el cuaderno de campo de un productor de
plantas aromáticas. Propones qué especie de esta lista puede ser, sin inventar:
$lista
- Usa "$fueraDelCatalogo" si parece otra especie. Como mucho tres candidatos,
  del más probable al menos.
- "confianza": alta solo si los rasgos que se ven son característicos e
  inequívocos; muchas especies se parecen entre sí (tomillos, lavandas,
  salvias, compuestas de flor blanca, umbelíferas), y en la duda, media o baja.
- En "rasgos_a_comprobar" di qué hay que mirar en la planta para confirmarla
  (hoja, flor, tallo, olor, porte) y con qué especies parecidas se confunde.
- Si la foto no deja ver lo necesario, "legible": false y di qué foto hace falta.
- Es solo una propuesta para que la persona la compruebe con una clave
  botánica o con alguien que la conozca. No digas nunca si la planta se puede
  comer, beber, oler, tocar o usar, ni hables de usos de salud ni de
  propiedades de la planta. Solo describes lo que ves.''';
}

/// Instrucciones para la plaga. Públicas para el test del hard limit.
String sistemaPlaga(String especieId, String nombreEspecie) {
  final lista = plagasParaIdentificar(especieId)
      .map((plaga) =>
          '- ${plaga.id}: ${plaga.nombre}${plaga.nombreCientifico.isEmpty ? '' : ' (${plaga.nombreCientifico})'}. Síntomas: ${plaga.sintomas}')
      .join('\n');
  return '''
Miras la foto de una planta cultivada de «$nombreEspecie» (hoja, flor, tallo,
raíz o trampa) para un cuaderno de campo. Propones qué plaga, enfermedad o
problema de esta lista puede ser, sin inventar:
$lista
- Usa "$fueraDelCatalogo" si parece otra cosa (sequía, helada, carencia, otra
  plaga). Como mucho tres candidatos, del más probable al menos.
- "confianza": alta solo si los síntomas son característicos e inequívocos.
- Si la foto no deja ver el síntoma, "legible": false y di qué foto hace falta.
- Nunca recomiendes productos, sustancias, dosis ni tratamientos: eso lo decide
  la persona con su asesor. Solo describes lo que ves.''';
}

/// Convierte la respuesta en una propuesta: descarta ids que no están en
/// [validas], repetidos y confianzas desconocidas; ordena y recorta a tres.
PropuestaIa<T> interpretarPropuesta<T>(
    Map<String, dynamic> json, Map<String, T> validas) {
  final candidatos = <Candidato<T>>[];
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
    final fila = validas[id];
    if (fila == null || !nivelesConfianza.contains(confianza)) continue;
    if (!vistas.add(id)) continue;
    candidatos.add(Candidato(
        fila, confianza, (entrada['motivo'] as String?)?.trim() ?? ''));
  }
  candidatos.sort((a, b) => nivelesConfianza
      .indexOf(a.confianza)
      .compareTo(nivelesConfianza.indexOf(b.confianza)));
  return PropuestaIa(
    legible: json['legible'] == true,
    candidatos: candidatos.take(3).toList(),
    fueraDelCatalogo: otra,
    observaciones: (json['observaciones'] as String?)?.trim() ?? '',
    rasgosAComprobar: (json['rasgos_a_comprobar'] as String?)?.trim() ?? '',
  );
}

PropuestaIa<EspecieCatalogo> interpretarEspecie(Map<String, dynamic> json) =>
    interpretarPropuesta(
        json, {for (final especie in catalogoEspecies) especie.id: especie});

PropuestaIa<PlagaCatalogo> interpretarPlaga(
        Map<String, dynamic> json, String especieId) =>
    interpretarPropuesta(json, {
      for (final plaga in plagasParaIdentificar(especieId)) plaga.id: plaga
    });

/// Envía la foto al modelo y devuelve la propuesta de especie.
Future<PropuestaIa<EspecieCatalogo>> identificarEspecieConIa({
  required String claveApi,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: sistemaEspecie(),
    esquemaJson: esquemaEspecie(),
    mensajes: [
      MensajeClaude.usuario('¿Qué especie de la lista puede ser?',
          imagenes: [foto]),
    ],
  );
  return interpretarEspecie(respuesta);
}

/// Envía la foto al modelo y devuelve la propuesta de plaga.
Future<PropuestaIa<PlagaCatalogo>> identificarPlagaConIa({
  required String claveApi,
  required String especieId,
  required String nombreEspecie,
  required ImagenClaude foto,
}) async {
  final respuesta = await ClienteClaude(claveApi: claveApi).pedirJson(
    modelo: modeloClaudeEquilibrado,
    sistema: sistemaPlaga(especieId, nombreEspecie),
    esquemaJson: esquemaPlaga(especieId),
    mensajes: [
      MensajeClaude.usuario('¿Qué plaga o problema puede ser?',
          imagenes: [foto]),
    ],
  );
  return interpretarPlaga(respuesta, especieId);
}
