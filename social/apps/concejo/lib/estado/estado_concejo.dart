/// Estado de la app en memoria. Es la costura donde entrará la
/// sincronización con el servidor del pueblo (bloque siguiente): las
/// pantallas solo hablan con esta clase.
library;

import 'package:flutter/foundation.dart';

import '../dominio/asunto.dart';
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
    DateTime Function()? reloj,
  })  : _personaActual = personaActual,
        _personas = [...personas],
        _asuntos = [...asuntos],
        _urnas = {...urnas},
        _debates = {...debates},
        _consentimientos = {...consentimientos},
        _compromisos = [...compromisos],
        _reloj = reloj ?? DateTime.now;

  final String nombreEspacio;
  Persona _personaActual;
  final List<Persona> _personas;
  final List<Asunto> _asuntos;
  final Map<String, Urna> _urnas;
  final Map<String, Debate> _debates;
  final Map<String, EstadoConsentimiento> _consentimientos;
  final List<Compromiso> _compromisos;
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

  void votar(String asuntoUid, Set<String> opcionesMarcadas) {
    final reglas = asunto(asuntoUid).reglas;
    _urnas[asuntoUid] = urna(asuntoUid).votarEnLaApp(
      personaUid: personaActual.uid,
      opcionesMarcadas: opcionesMarcadas,
      ahora: ahora,
      secreta: reglas.esSecreta,
    );
    notifyListeners();
  }

  void aportar(
    String asuntoUid,
    TipoAportacion tipo,
    String texto, {
    String? respondeAUid,
    bool anonima = false,
  }) {
    _debates[asuntoUid] = debate(asuntoUid).aportar(Aportacion(
      uid: _nuevoUid('ap'),
      asuntoUid: asuntoUid,
      autorUid: personaActual.uid,
      tipo: tipo,
      texto: texto.trim(),
      creada: ahora,
      respondeAUid: respondeAUid,
      anonima: anonima,
    ));
    notifyListeners();
  }

  void objetar(String asuntoUid, String motivo) {
    _consentimientos[asuntoUid] = consentimiento(asuntoUid).objetar(
      uid: _nuevoUid('ob'),
      autorUid: personaActual.uid,
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
}
