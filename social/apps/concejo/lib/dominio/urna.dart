/// La urna de un asunto: quién ha participado y qué se ha votado, **por
/// separado** (`docs/04-concejo.md` §4.4).
///
/// - Una [Participacion] dice que una persona ha votado, en la app o en
///   persona, y sirve para que nadie vote dos veces y para el quórum.
/// - Una [Papeleta] dice qué se ha votado y **no lleva persona**.
/// - Un [ConteoPresencial] recoge las papeletas en papel que cuenta la mesa,
///   ya sumadas y firmadas por dos personas distintas de la mesa.
///
/// Las dos primeras no comparten ningún identificador. Con voto secreto la
/// papeleta además se guarda con la hora redondeada ([Papeleta.horaRedondeada])
/// y **en una posición al azar** de la lista: si fuera al final, la papeleta
/// n.º 5 sería la de la quinta persona en participar.
///
/// En [FormaDecision.consentimiento] no hay urna: ver `consentimiento.dart`.
library;

import 'dart:math';

enum CanalParticipacion { app, presencial }

class Participacion {
  const Participacion({
    required this.asuntoUid,
    required this.personaUid,
    required this.canal,
    this.anotadaPorUid = '',
  });

  final String asuntoUid;
  final String personaUid;
  final CanalParticipacion canal;

  /// En persona: la persona de la mesa que la apuntó.
  final String anotadaPorUid;
}

/// Lo que dice una papeleta según la forma de decidir:
/// - votación: una sola de `si`, `no`, `abstencion` ([opcionesMarcadas]
///   con un elemento);
/// - elección entre opciones y presupuesto: los ids de todas las opciones
///   que se aceptan o apoyan (puede ir vacía: es un voto en blanco).
class Papeleta {
  const Papeleta({
    required this.asuntoUid,
    required this.opcionesMarcadas,
    this.horaRedondeada,
    this.personaUid,
  });

  final String asuntoUid;
  final Set<String> opcionesMarcadas;

  /// Solo en voto nominal (no secreto). En voto secreto es siempre `null`.
  final String? personaUid;
  final DateTime? horaRedondeada;
}

const String votoSi = 'si';
const String votoNo = 'no';
const String votoAbstencion = 'abstencion';

/// Las papeletas en papel de una mesa, ya contadas: cuántas marcan cada
/// opción y cuántas había en total (una papeleta de aprobación puede
/// marcar varias opciones, así que el total no es la suma).
class ConteoPresencial {
  const ConteoPresencial({
    required this.asuntoUid,
    required this.papeletasTotales,
    required this.marcasPorOpcion,
    required this.firmadoPorUids,
  });

  final String asuntoUid;
  final int papeletasTotales;
  final Map<String, int> marcasPorOpcion;

  /// Dos personas de la mesa, distintas.
  final List<String> firmadoPorUids;

  bool get firmaValida =>
      firmadoPorUids.length >= 2 && firmadoPorUids.toSet().length >= 2;
}

/// Redondea a la hora en punto, en UTC.
DateTime redondearALaHora(DateTime momento) {
  final utc = momento.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day, utc.hour);
}

class VotoDuplicado implements Exception {
  const VotoDuplicado(this.personaUid);
  final String personaUid;
  @override
  String toString() => 'VotoDuplicado($personaUid)';
}

/// Estado de la urna de un asunto. Inmutable: cada voto devuelve una urna
/// nueva.
class Urna {
  const Urna({
    required this.asuntoUid,
    this.participaciones = const [],
    this.papeletas = const [],
    this.conteosPresenciales = const [],
  });

  final String asuntoUid;
  final List<Participacion> participaciones;
  final List<Papeleta> papeletas;
  final List<ConteoPresencial> conteosPresenciales;

  bool haParticipado(String personaUid) =>
      participaciones.any((p) => p.personaUid == personaUid);

  int get personasQueHanParticipado =>
      participaciones.map((p) => p.personaUid).toSet().length;

  int get participacionesPresenciales => participaciones
      .where((p) => p.canal == CanalParticipacion.presencial)
      .length;

  int get papeletasPresencialesContadas =>
      conteosPresenciales.fold(0, (suma, c) => suma + c.papeletasTotales);

  /// Voto desde la app: se apunta la participación y, aparte, la papeleta
  /// sin persona.
  Urna votarEnLaApp({
    required String personaUid,
    required Set<String> opcionesMarcadas,
    required DateTime ahora,
    required bool secreta,
    Random? azar,
  }) {
    if (haParticipado(personaUid)) throw VotoDuplicado(personaUid);
    final papeleta = Papeleta(
      asuntoUid: asuntoUid,
      opcionesMarcadas: Set.unmodifiable(opcionesMarcadas),
      horaRedondeada: secreta ? redondearALaHora(ahora) : ahora.toUtc(),
      personaUid: secreta ? null : personaUid,
    );
    final nuevasPapeletas = [...papeletas];
    if (secreta) {
      final posicion = (azar ?? Random.secure()).nextInt(papeletas.length + 1);
      nuevasPapeletas.insert(posicion, papeleta);
    } else {
      nuevasPapeletas.add(papeleta);
    }
    return Urna(
      asuntoUid: asuntoUid,
      participaciones: [
        ...participaciones,
        Participacion(
          asuntoUid: asuntoUid,
          personaUid: personaUid,
          canal: CanalParticipacion.app,
        ),
      ],
      papeletas: nuevasPapeletas,
      conteosPresenciales: conteosPresenciales,
    );
  }

  /// La mesa apunta que una persona ha votado en papel. Su papeleta entra
  /// después, dentro de un [ConteoPresencial].
  Urna anotarVotoPresencial({
    required String personaUid,
    required String mesaUid,
  }) {
    if (haParticipado(personaUid)) throw VotoDuplicado(personaUid);
    return Urna(
      asuntoUid: asuntoUid,
      participaciones: [
        ...participaciones,
        Participacion(
          asuntoUid: asuntoUid,
          personaUid: personaUid,
          canal: CanalParticipacion.presencial,
          anotadaPorUid: mesaUid,
        ),
      ],
      papeletas: papeletas,
      conteosPresenciales: conteosPresenciales,
    );
  }

  Urna anadirConteoPresencial(ConteoPresencial conteo) {
    if (!conteo.firmaValida) {
      throw ArgumentError(
          'El conteo lo firman dos personas distintas de la mesa');
    }
    return Urna(
      asuntoUid: asuntoUid,
      participaciones: participaciones,
      papeletas: papeletas,
      conteosPresenciales: [...conteosPresenciales, conteo],
    );
  }

  /// Avisos de coherencia que la mesa tiene que ver antes de cerrar. No
  /// impiden el recuento: lo dejan a la vista en el acta.
  List<AvisoUrna> avisos() => [
        if (papeletasPresencialesContadas != participacionesPresenciales)
          AvisoUrna.papeletasPresencialesNoCuadran,
        if (papeletas.length !=
            participaciones
                .where((p) => p.canal == CanalParticipacion.app)
                .length)
          AvisoUrna.papeletasAppNoCuadran,
      ];
}

enum AvisoUrna { papeletasPresencialesNoCuadran, papeletasAppNoCuadran }
