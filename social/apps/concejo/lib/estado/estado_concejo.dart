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
    required this.personaActual,
    required List<Persona> personas,
    required List<Asunto> asuntos,
    Map<String, Urna> urnas = const {},
    Map<String, Debate> debates = const {},
    Map<String, EstadoConsentimiento> consentimientos = const {},
    List<Compromiso> compromisos = const [],
    DateTime Function()? reloj,
  })  : _personas = [...personas],
        _asuntos = [...asuntos],
        _urnas = {...urnas},
        _debates = {...debates},
        _consentimientos = {...consentimientos},
        _compromisos = [...compromisos],
        _reloj = reloj ?? DateTime.now;

  final String nombreEspacio;
  final Persona personaActual;
  final List<Persona> _personas;
  final List<Asunto> _asuntos;
  final Map<String, Urna> _urnas;
  final Map<String, Debate> _debates;
  final Map<String, EstadoConsentimiento> _consentimientos;
  final List<Compromiso> _compromisos;
  final DateTime Function() _reloj;
  var _contadorUid = 0;

  DateTime get ahora => _reloj();
  List<Persona> get personas => List.unmodifiable(_personas);
  List<Asunto> get asuntos => List.unmodifiable(_asuntos);
  List<Compromiso> get compromisos => List.unmodifiable(_compromisos);
  bool get soyMesa => personaActual.esMesaEn(ahora);

  Asunto asunto(String uid) => _asuntos.firstWhere((a) => a.uid == uid);
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

  List<Asunto> asuntosEnFase(FaseAsunto fase) =>
      _asuntos.where((a) => a.faseEn(ahora) == fase).toList();

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
    final indice = _compromisos.indexWhere((c) => c.uid == compromisoUid);
    _compromisos[indice] =
        _compromisos[indice].cambiarEstado(nuevo, nota: nota);
    notifyListeners();
  }
}
