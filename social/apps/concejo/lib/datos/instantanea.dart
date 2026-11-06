/// Todo el estado de un espacio en un JSON: lo que manda el servidor en
/// `GET /estado` y lo que la app guarda en su caché para abrir sin red.
library;

import '../estado/estado_concejo.dart';
import 'json_dominio.dart';

Json instantaneaAJson(EstadoConcejo estado, {int revision = 0}) => {
      'nombre_espacio': estado.nombreEspacio,
      'revision': revision,
      'personas': [for (final p in estado.personas) personaAJson(p)],
      'asuntos': [for (final a in estado.asuntos) asuntoAJson(a)],
      'urnas': [for (final u in estado.urnas.values) urnaAJson(u)],
      'debates': [for (final d in estado.debates.values) debateAJson(d)],
      'consentimientos': {
        for (final MapEntry(:key, :value) in estado.consentimientos.entries)
          key: consentimientoAJson(value),
      },
      'compromisos': [for (final c in estado.compromisos) compromisoAJson(c)],
      'actas': [for (final a in estado.actas.values) actaAJson(a)],
    };

/// [personaActualUid]: quien usa la app (la del token). Tiene que estar en
/// la lista de personas.
EstadoConcejo instantaneaDesdeJson(
  Json json, {
  required String personaActualUid,
  DateTime Function()? reloj,
}) {
  final personas = [
    for (final persona in json['personas'] as List)
      personaDesdeJson(persona as Json),
  ];
  return EstadoConcejo(
    nombreEspacio: json['nombre_espacio'] as String,
    personaActual: personas.firstWhere((p) => p.uid == personaActualUid),
    personas: personas,
    asuntos: [
      for (final asunto in json['asuntos'] as List)
        asuntoDesdeJson(asunto as Json),
    ],
    urnas: {
      for (final urna in json['urnas'] as List? ?? const [])
        (urna as Json)['asunto_uid'] as String: urnaDesdeJson(urna),
    },
    debates: {
      for (final debate in json['debates'] as List? ?? const [])
        (debate as Json)['asunto_uid'] as String: debateDesdeJson(debate),
    },
    consentimientos: {
      for (final MapEntry(:key, :value)
          in (json['consentimientos'] as Map? ?? const {}).entries)
        key as String: consentimientoDesdeJson(value as Json),
    },
    compromisos: [
      for (final compromiso in json['compromisos'] as List? ?? const [])
        compromisoDesdeJson(compromiso as Json),
    ],
    actas: {
      for (final acta in json['actas'] as List? ?? const [])
        (acta as Json)['asunto_uid'] as String: actaDesdeJson(acta),
    },
    reloj: reloj,
  );
}
