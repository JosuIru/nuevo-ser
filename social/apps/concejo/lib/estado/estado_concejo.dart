/// Estado de la app en memoria. Es la costura donde entrará la
/// sincronización con el servidor del pueblo (bloque siguiente): las
/// pantallas solo hablan con esta clase.
library;

import 'package:flutter/foundation.dart';

import '../dominio/acta.dart';
import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/compromiso.dart';
import '../dominio/consentimiento.dart';
import '../dominio/debate.dart';
import '../dominio/persona.dart';
import '../dominio/urna.dart';

class EstadoConcejo extends ChangeNotifier {
  EstadoConcejo({
    required this.nombreEspacio,
    required Persona personaActual,
    required List<Persona> personas,
    required List<Asunto> asuntos,
    Map<String, Urna> urnas = const {},
    Map<String, Debate> debates = const {},
    Map<String, EstadoConsentimiento> consentimientos = const {},
    List<Compromiso> compromisos = const [],
    Map<String, Acta> actas = const {},
    DateTime Function()? reloj,
  })  : _personaActual = personaActual,
        _personas = [...personas],
        _asuntos = [...asuntos],
        _urnas = {...urnas},
        _debates = {...debates},
        _consentimientos = {...consentimientos},
        _compromisos = [...compromisos],
        _actas = {...actas},
        _reloj = reloj ?? DateTime.now;

  final String nombreEspacio;
  Persona _personaActual;
  final List<Persona> _personas;
  final List<Asunto> _asuntos;
  final Map<String, Urna> _urnas;
  final Map<String, Debate> _debates;
  final Map<String, EstadoConsentimiento> _consentimientos;
  final List<Compromiso> _compromisos;
  final Map<String, Acta> _actas;
  final DateTime Function() _reloj;
  var _contadorUid = 0;

  DateTime get ahora => _reloj();
  Persona get personaActual => _personaActual;
  List<Persona> get personas => List.unmodifiable(_personas);
  List<Asunto> get asuntos => List.unmodifiable(_asuntos);
  List<Compromiso> get compromisos => List.unmodifiable(_compromisos);
  bool get soyMesa => personaActual.esMesaEn(ahora);

  Asunto asunto(String uid) => _asuntos.firstWhere((a) => a.uid == uid);

  /// `null` si ya no existe (un borrador recién borrado).
  Asunto? buscarAsunto(String uid) {
    for (final a in _asuntos) {
      if (a.uid == uid) return a;
    }
    return null;
  }

  Urna urna(String asuntoUid) =>
      _urnas[asuntoUid] ?? Urna(asuntoUid: asuntoUid);
  Debate debate(String asuntoUid) =>
      _debates[asuntoUid] ?? Debate(asuntoUid: asuntoUid);
  EstadoConsentimiento consentimiento(String asuntoUid) =>
      _consentimientos[asuntoUid] ??
      EstadoConsentimiento(
        rondaActual: 1,
        rondasMaximas: asunto(asuntoUid).reglas.rondasConsentimiento,
      );
  List<Compromiso> compromisosDe(String asuntoUid) =>
      _compromisos.where((c) => c.asuntoUid == asuntoUid).toList();
  String nombreDe(String personaUid) => _personas
      .firstWhere((p) => p.uid == personaUid,
          orElse: () => Persona(uid: personaUid, nombre: personaUid))
      .nombre;

  /// Los borradores solo los ve la mesa.
  List<Asunto> asuntosEnFase(FaseAsunto fase) =>
      fase == FaseAsunto.borrador && !soyMesa
          ? const []
          : _asuntos.where((a) => a.faseEn(ahora) == fase).toList();

  String _nuevoUid(String prefijo) =>
      '$prefijo-${ahora.microsecondsSinceEpoch}-${_contadorUid++}';

  bool heVotado(String asuntoUid) =>
      urna(asuntoUid).haParticipado(personaActual.uid);

  void _soloEnDecision(String asuntoUid) {
    if (asunto(asuntoUid).faseEn(ahora) != FaseAsunto.decision) {
      throw StateError('Fuera del plazo de decisión');
    }
  }

  void votar(String asuntoUid, Set<String> opcionesMarcadas) {
    _soloEnDecision(asuntoUid);
    final reglas = asunto(asuntoUid).reglas;
    _urnas[asuntoUid] = urna(asuntoUid).votarEnLaApp(
      personaUid: personaActual.uid,
      opcionesMarcadas: opcionesMarcadas,
      ahora: ahora,
      secreta: reglas.esSecreta,
    );
    notifyListeners();
  }

  /// [enNombreDeUid]: la mesa recoge lo que alguien dijo en persona o dejó
  /// por escrito (canal en papel).
  void aportar(
    String asuntoUid,
    TipoAportacion tipo,
    String texto, {
    String? respondeAUid,
    bool anonima = false,
    String? enNombreDeUid,
  }) {
    if (enNombreDeUid != null) _soloMesa();
    _debates[asuntoUid] = debate(asuntoUid).aportar(Aportacion(
      uid: _nuevoUid('ap'),
      asuntoUid: asuntoUid,
      autorUid: enNombreDeUid ?? personaActual.uid,
      tipo: tipo,
      texto: texto.trim(),
      creada: ahora,
      respondeAUid: respondeAUid,
      anonima: anonima,
    ));
    notifyListeners();
  }

  void objetar(String asuntoUid, String motivo, {String? enNombreDeUid}) {
    if (enNombreDeUid != null) _soloMesa();
    _consentimientos[asuntoUid] = consentimiento(asuntoUid).objetar(
      uid: _nuevoUid('ob'),
      autorUid: enNombreDeUid ?? personaActual.uid,
      motivo: motivo.trim(),
    );
    notifyListeners();
  }

  void cambiarEstadoCompromiso(
    String compromisoUid,
    EstadoCompromiso nuevo, {
    String nota = '',
  }) {
    _soloMesa();
    final indice = _compromisos.indexWhere((c) => c.uid == compromisoUid);
    _compromisos[indice] =
        _compromisos[indice].cambiarEstado(nuevo, nota: nota);
    notifyListeners();
  }

  // ------------------------------------------------------------- la mesa

  void _soloMesa() {
    if (!soyMesa) throw StateError('Esto lo hace la mesa');
  }

  /// Solo en el pueblo de ejemplo: ver la app como otra persona.
  void verComo(String personaUid) {
    _personaActual = _personas.firstWhere((p) => p.uid == personaUid);
    notifyListeners();
  }

  String nuevoUidAsunto() => _nuevoUid('as');

  /// Crea o reemplaza un borrador. Un asunto abierto ya no se toca.
  void guardarBorrador(Asunto borrador) {
    _soloMesa();
    if (borrador.abierto) {
      throw StateError('Un borrador no puede venir abierto');
    }
    final indice = _asuntos.indexWhere((a) => a.uid == borrador.uid);
    if (indice >= 0 && _asuntos[indice].abierto) {
      throw StateError('Un asunto abierto no se edita');
    }
    final guardado = Asunto(
      uid: borrador.uid,
      titulo: borrador.titulo,
      resumen: borrador.resumen,
      texto: borrador.texto,
      tipoDecision: borrador.tipoDecision,
      compromisoPrevio: borrador.compromisoPrevio,
      costeEuros: borrador.costeEuros,
      efectoEntorno: borrador.efectoEntorno,
      reglas: borrador.reglas,
      inicioDebate: borrador.inicioDebate,
      inicioDecision: borrador.inicioDecision,
      finDecision: borrador.finDecision,
      creadoPorUid:
          indice >= 0 ? _asuntos[indice].creadoPorUid : personaActual.uid,
    );
    if (indice >= 0) {
      _asuntos[indice] = guardado;
    } else {
      _asuntos.add(guardado);
    }
    notifyListeners();
  }

  /// Abre el borrador: desde aquí las reglas quedan fijas.
  void abrirAsunto(String uid) {
    _soloMesa();
    final indice = _asuntos.indexWhere((a) => a.uid == uid);
    _asuntos[indice] = _asuntos[indice].abrir();
    notifyListeners();
  }

  void borrarBorrador(String uid) {
    _soloMesa();
    if (asunto(uid).abierto) throw StateError('Un asunto abierto no se borra');
    _asuntos.removeWhere((a) => a.uid == uid);
    notifyListeners();
  }

  void moderar(String asuntoUid, String aportacionUid, EstadoModeracion nuevo,
      {String motivo = ''}) {
    _soloMesa();
    _debates[asuntoUid] =
        debate(asuntoUid).moderar(aportacionUid, nuevo, motivo: motivo);
    notifyListeners();
  }

  void resumirDebate(String asuntoUid, String resumen) {
    _soloMesa();
    _sinFirmasEnElActa(asuntoUid);
    _debates[asuntoUid] = debate(asuntoUid).conResumen(resumen);
    notifyListeners();
  }

  /// Integrar o declarar que no es objeción lo hace la mesa; retirarla, solo
  /// quien la planteó.
  void resolverObjecion(String asuntoUid, String objecionUid,
      EstadoObjecion nuevo, String respuesta) {
    final objecion = consentimiento(asuntoUid)
        .objeciones
        .firstWhere((o) => o.uid == objecionUid);
    if (nuevo == EstadoObjecion.retirada) {
      if (objecion.autorUid != personaActual.uid) {
        throw StateError('Una objeción solo la retira quien la planteó');
      }
    } else {
      _soloMesa();
    }
    _consentimientos[asuntoUid] = consentimiento(asuntoUid)
        .resolverObjecion(objecionUid, nuevo, respuesta);
    notifyListeners();
  }

  DesenlaceConsentimiento cerrarRondaConsentimiento(String asuntoUid) {
    _soloMesa();
    _sinFirmasEnElActa(asuntoUid);
    final cierre = consentimiento(asuntoUid).cerrarRonda();
    _consentimientos[asuntoUid] = cierre.estado;
    notifyListeners();
    return cierre.desenlace;
  }

  void anadirCompromiso({
    required String asuntoUid,
    required String que,
    required String responsable,
    required DateTime fechaLimite,
  }) {
    _soloMesa();
    if (que.trim().isEmpty || responsable.trim().isEmpty) {
      throw ArgumentError('Un compromiso dice qué y quién');
    }
    _compromisos.add(Compromiso(
      uid: _nuevoUid('co'),
      asuntoUid: asuntoUid,
      que: que.trim(),
      responsable: responsable.trim(),
      fechaLimite: fechaLimite,
    ));
    notifyListeners();
  }

  // --------------------------------------------------- el canal en papel

  /// Personas que aún no han participado en el asunto, por nombre.
  List<Persona> personasSinParticipar(String asuntoUid) {
    final urnaAsunto = urna(asuntoUid);
    return [
      for (final persona in _personas)
        if (!urnaAsunto.haParticipado(persona.uid)) persona,
    ]..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
  }

  /// Personas que pueden firmar un conteo con la persona actual: la otra
  /// gente de la mesa en este momento.
  List<Persona> otrasPersonasDeLaMesa() => [
        for (final persona in _personas)
          if (persona.uid != personaActual.uid && persona.esMesaEn(ahora))
            persona,
      ];

  /// Alta rápida de alguien que vota en persona y no está en la lista (en
  /// el servidor, el alta llevará además su código en papel).
  Persona darDeAlta(String nombre) {
    _soloMesa();
    if (nombre.trim().isEmpty) throw ArgumentError('Falta el nombre');
    final persona = Persona(uid: _nuevoUid('pe'), nombre: nombre.trim());
    _personas.add(persona);
    notifyListeners();
    return persona;
  }

  /// La mesa apunta que alguien ha votado en papel. Su papeleta entra luego
  /// en el conteo de la mesa.
  void anotarVotoPresencial(String asuntoUid, String personaUid) {
    _soloMesa();
    _soloEnDecision(asuntoUid);
    _urnas[asuntoUid] = urna(asuntoUid).anotarVotoPresencial(
      personaUid: personaUid,
      mesaUid: personaActual.uid,
    );
    notifyListeners();
  }

  /// El conteo de las papeletas en papel, firmado por la persona actual y
  /// otra persona de la mesa.
  void registrarConteoPresencial({
    required String asuntoUid,
    required int papeletasTotales,
    required Map<String, int> marcasPorOpcion,
    required String segundaFirmaUid,
  }) {
    _soloMesa();
    // Las papeletas en papel se cuentan al cerrar, así que el conteo vale
    // también cuando ya ha acabado el plazo.
    final fase = asunto(asuntoUid).faseEn(ahora);
    if (fase != FaseAsunto.decision && fase != FaseAsunto.seguimiento) {
      throw StateError('Aún no se puede votar');
    }
    _sinFirmasEnElActa(asuntoUid);
    if (!otrasPersonasDeLaMesa().any((p) => p.uid == segundaFirmaUid)) {
      throw StateError('El conteo lo firma otra persona de la mesa');
    }
    if (papeletasTotales < 0 || marcasPorOpcion.values.any((n) => n < 0)) {
      throw ArgumentError('Las cifras no pueden ser negativas');
    }
    _urnas[asuntoUid] = urna(asuntoUid).anadirConteoPresencial(ConteoPresencial(
      asuntoUid: asuntoUid,
      papeletasTotales: papeletasTotales,
      marcasPorOpcion: Map.unmodifiable(marcasPorOpcion),
      firmadoPorUids: [personaActual.uid, segundaFirmaUid],
    ));
    notifyListeners();
  }

  // ---------------------------------------------------------------- acta

  Acta acta(String asuntoUid) =>
      _actas[asuntoUid] ?? Acta(asuntoUid: asuntoUid);

  /// Se firma cuando el asunto está decidido: acabado el plazo y, en
  /// consentimiento, con la ronda cerrada.
  bool actaLista(String asuntoUid) {
    final asuntoActa = asunto(asuntoUid);
    if (asuntoActa.faseEn(ahora) != FaseAsunto.seguimiento) return false;
    return asuntoActa.reglas.forma != FormaDecision.consentimiento ||
        consentimiento(asuntoUid).decidido;
  }

  /// Los compromisos que recoge el acta: los fijados al firmarla o, si aún
  /// es borrador, los de ahora.
  List<Compromiso> compromisosDelActa(String asuntoUid) {
    final fijados = acta(asuntoUid).compromisosAlFirmarUids;
    final todos = compromisosDe(asuntoUid);
    return fijados == null
        ? todos
        : todos.where((c) => fijados.contains(c.uid)).toList();
  }

  void firmarActa(String asuntoUid) {
    _soloMesa();
    if (!actaLista(asuntoUid)) {
      throw StateError('El acta se firma con el asunto decidido');
    }
    _actas[asuntoUid] = acta(asuntoUid).firmar(
      personaUid: personaActual.uid,
      ahora: ahora,
      compromisosUids: [for (final c in compromisosDe(asuntoUid)) c.uid],
    );
    notifyListeners();
  }

  void retirarFirmaActa(String asuntoUid) {
    _soloMesa();
    _actas[asuntoUid] = acta(asuntoUid).retirarFirma(personaActual.uid);
    notifyListeners();
  }

  /// Lo que recoge el acta no cambia una vez que alguien la ha firmado.
  void _sinFirmasEnElActa(String asuntoUid) {
    if (acta(asuntoUid).tieneFirmas) {
      throw StateError('El acta ya tiene firmas: retírala para corregir');
    }
  }
}
