/// Estado de la app en memoria. Es la costura con la sincronización: las
/// pantallas solo hablan con esta clase, y cada cambio sale como una
/// [AccionConcejo] por [alHacerAccion] para la cola de envío.
library;

import 'package:flutter/foundation.dart';

import '../datos/json_dominio.dart';

import '../dominio/acta.dart';
import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/compromiso.dart';
import '../dominio/consentimiento.dart';
import '../dominio/debate.dart';
import '../dominio/persona.dart';
import '../dominio/urna.dart';
import 'accion.dart';

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
  Map<String, Urna> get urnas => Map.unmodifiable(_urnas);
  Map<String, Debate> get debates => Map.unmodifiable(_debates);
  Map<String, EstadoConsentimiento> get consentimientos =>
      Map.unmodifiable(_consentimientos);
  Map<String, Acta> get actas => Map.unmodifiable(_actas);
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

  Null _votar(String asuntoUid, Set<String> opcionesMarcadas) {
    _soloEnDecision(asuntoUid);
    final reglas = asunto(asuntoUid).reglas;
    _urnas[asuntoUid] = urna(asuntoUid).votarEnLaApp(
      personaUid: personaActual.uid,
      opcionesMarcadas: opcionesMarcadas,
      ahora: ahora,
      secreta: reglas.esSecreta,
    );
  }

  /// [enNombreDeUid]: la mesa recoge lo que alguien dijo en persona o dejó
  /// por escrito (canal en papel).
  Null _aportar(
    String uid,
    String asuntoUid,
    TipoAportacion tipo,
    String texto, {
    String? respondeAUid,
    bool anonima = false,
    String? enNombreDeUid,
  }) {
    if (enNombreDeUid != null) _soloMesa();
    _debates[asuntoUid] = debate(asuntoUid).aportar(Aportacion(
      uid: uid,
      asuntoUid: asuntoUid,
      autorUid: enNombreDeUid ?? personaActual.uid,
      tipo: tipo,
      texto: texto.trim(),
      creada: ahora,
      respondeAUid: respondeAUid,
      anonima: anonima,
    ));
  }

  Null _objetar(String uid, String asuntoUid, String motivo,
      {String? enNombreDeUid}) {
    if (enNombreDeUid != null) _soloMesa();
    _consentimientos[asuntoUid] = consentimiento(asuntoUid).objetar(
      uid: uid,
      autorUid: enNombreDeUid ?? personaActual.uid,
      motivo: motivo.trim(),
    );
  }

  Null _cambiarEstadoCompromiso(
    String compromisoUid,
    EstadoCompromiso nuevo, {
    String nota = '',
  }) {
    _soloMesa();
    final indice = _compromisos.indexWhere((c) => c.uid == compromisoUid);
    _compromisos[indice] =
        _compromisos[indice].cambiarEstado(nuevo, nota: nota);
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
  Null _guardarBorrador(Asunto borrador) {
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
  }

  /// Abre el borrador: desde aquí las reglas quedan fijas.
  Null _abrirAsunto(String uid) {
    _soloMesa();
    final indice = _asuntos.indexWhere((a) => a.uid == uid);
    _asuntos[indice] = _asuntos[indice].abrir();
  }

  Null _borrarBorrador(String uid) {
    _soloMesa();
    if (asunto(uid).abierto) throw StateError('Un asunto abierto no se borra');
    _asuntos.removeWhere((a) => a.uid == uid);
  }

  Null _moderar(String asuntoUid, String aportacionUid, EstadoModeracion nuevo,
      {String motivo = ''}) {
    _soloMesa();
    _debates[asuntoUid] =
        debate(asuntoUid).moderar(aportacionUid, nuevo, motivo: motivo);
  }

  Null _resumirDebate(String asuntoUid, String resumen) {
    _soloMesa();
    _sinFirmasEnElActa(asuntoUid);
    _debates[asuntoUid] = debate(asuntoUid).conResumen(resumen);
  }

  /// Integrar o declarar que no es objeción lo hace la mesa; retirarla, solo
  /// quien la planteó.
  Null _resolverObjecion(String asuntoUid, String objecionUid,
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
  }

  DesenlaceConsentimiento _cerrarRondaConsentimiento(String asuntoUid) {
    _soloMesa();
    _sinFirmasEnElActa(asuntoUid);
    final cierre = consentimiento(asuntoUid).cerrarRonda();
    _consentimientos[asuntoUid] = cierre.estado;
    return cierre.desenlace;
  }

  Null _anadirCompromiso({
    required String uid,
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
      uid: uid,
      asuntoUid: asuntoUid,
      que: que.trim(),
      responsable: responsable.trim(),
      fechaLimite: fechaLimite,
    ));
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
  Persona _darDeAlta(String uid, String nombre) {
    _soloMesa();
    if (nombre.trim().isEmpty) throw ArgumentError('Falta el nombre');
    final persona = Persona(uid: uid, nombre: nombre.trim());
    _personas.add(persona);
    return persona;
  }

  /// La mesa apunta que alguien ha votado en papel. Su papeleta entra luego
  /// en el conteo de la mesa.
  Null _anotarVotoPresencial(String asuntoUid, String personaUid) {
    _soloMesa();
    _soloEnDecision(asuntoUid);
    _urnas[asuntoUid] = urna(asuntoUid).anotarVotoPresencial(
      personaUid: personaUid,
      mesaUid: personaActual.uid,
    );
  }

  /// El conteo de las papeletas en papel, firmado por la persona actual y
  /// otra persona de la mesa.
  Null _registrarConteoPresencial({
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

  Null _firmarActa(String asuntoUid) {
    _soloMesa();
    if (!actaLista(asuntoUid)) {
      throw StateError('El acta se firma con el asunto decidido');
    }
    _actas[asuntoUid] = acta(asuntoUid).firmar(
      personaUid: personaActual.uid,
      ahora: ahora,
      compromisosUids: [for (final c in compromisosDe(asuntoUid)) c.uid],
    );
  }

  Null _retirarFirmaActa(String asuntoUid) {
    _soloMesa();
    _actas[asuntoUid] = acta(asuntoUid).retirarFirma(personaActual.uid);
  }

  /// Lo que recoge el acta no cambia una vez que alguien la ha firmado.
  void _sinFirmasEnElActa(String asuntoUid) {
    if (acta(asuntoUid).tieneFirmas) {
      throw StateError('El acta ya tiene firmas: retírala para corregir');
    }
  }

  // ------------------------------------------------------------ acciones

  /// Quien escucha las acciones que hace la persona actual (la cola de
  /// envío al servidor). Solo salen las que se han aplicado bien.
  void Function(AccionConcejo accion)? alHacerAccion;

  Object? _hacer(TipoAccion tipo, Json datos) {
    final accion = AccionConcejo(
      uid: _nuevoUid('ac'),
      tipo: tipo,
      autorUid: personaActual.uid,
      momento: ahora,
      datos: datos,
    );
    final resultado = _aplicar(accion);
    notifyListeners();
    alHacerAccion?.call(accion);
    return resultado;
  }

  /// Vuelve a aplicar una acción propia que aún no ha confirmado el
  /// servidor, sobre el estado recién bajado. Lanza si ya no vale (se ha
  /// cerrado el plazo, otra persona firmó…), y entonces se descarta.
  void rehacer(AccionConcejo accion) {
    if (accion.autorUid != personaActual.uid) {
      throw StateError('Solo se rehacen las acciones propias');
    }
    _aplicar(accion);
    notifyListeners();
  }

  /// Las mutaciones privadas devuelven `Null` (y no `void`) para caber en
  /// este switch; `cerrarRonda` y `darDeAlta` devuelven su resultado.
  Object? _aplicar(AccionConcejo accion) {
    final datos = accion.datos;
    String texto(String clave) => datos[clave] as String;
    String? opcional(String clave) => datos[clave] as String?;
    return switch (accion.tipo) {
      TipoAccion.votar => _votar(texto('asunto_uid'),
          {for (final opcion in datos['opciones'] as List) opcion as String}),
      TipoAccion.aportar => _aportar(
          texto('uid'),
          texto('asunto_uid'),
          TipoAportacion.values.byName(texto('tipo')),
          texto('texto'),
          respondeAUid: opcional('responde_a_uid'),
          anonima: datos['anonima'] as bool? ?? false,
          enNombreDeUid: opcional('en_nombre_de_uid'),
        ),
      TipoAccion.objetar => _objetar(
          texto('uid'), texto('asunto_uid'), texto('motivo'),
          enNombreDeUid: opcional('en_nombre_de_uid')),
      TipoAccion.cambiarEstadoCompromiso => _cambiarEstadoCompromiso(
          texto('compromiso_uid'),
          EstadoCompromiso.values.byName(texto('estado')),
          nota: opcional('nota') ?? ''),
      TipoAccion.guardarBorrador =>
        _guardarBorrador(asuntoDesdeJson(datos['asunto'] as Json)),
      TipoAccion.abrirAsunto => _abrirAsunto(texto('asunto_uid')),
      TipoAccion.borrarBorrador => _borrarBorrador(texto('asunto_uid')),
      TipoAccion.moderar => _moderar(
          texto('asunto_uid'),
          texto('aportacion_uid'),
          EstadoModeracion.values.byName(texto('estado')),
          motivo: opcional('motivo') ?? ''),
      TipoAccion.resumirDebate =>
        _resumirDebate(texto('asunto_uid'), texto('resumen')),
      TipoAccion.resolverObjecion => _resolverObjecion(
          texto('asunto_uid'),
          texto('objecion_uid'),
          EstadoObjecion.values.byName(texto('estado')),
          texto('respuesta')),
      TipoAccion.cerrarRondaConsentimiento =>
        _cerrarRondaConsentimiento(texto('asunto_uid')),
      TipoAccion.anadirCompromiso => _anadirCompromiso(
          uid: texto('uid'),
          asuntoUid: texto('asunto_uid'),
          que: texto('que'),
          responsable: texto('responsable'),
          fechaLimite: DateTime.parse(texto('fecha_limite'))),
      TipoAccion.darDeAlta => _darDeAlta(texto('uid'), texto('nombre')),
      TipoAccion.anotarVotoPresencial =>
        _anotarVotoPresencial(texto('asunto_uid'), texto('persona_uid')),
      TipoAccion.registrarConteoPresencial => _registrarConteoPresencial(
          asuntoUid: texto('asunto_uid'),
          papeletasTotales: (datos['papeletas_totales'] as num).toInt(),
          marcasPorOpcion: {
            for (final MapEntry(:key, :value)
                in (datos['marcas'] as Map).entries)
              key as String: (value as num).toInt(),
          },
          segundaFirmaUid: texto('segunda_firma_uid')),
      TipoAccion.firmarActa => _firmarActa(texto('asunto_uid')),
      TipoAccion.retirarFirmaActa => _retirarFirmaActa(texto('asunto_uid')),
    };
  }

  // Lo que llaman las pantallas: cada método es una acción.

  void votar(String asuntoUid, Set<String> opcionesMarcadas) => _hacer(
      TipoAccion.votar,
      {'asunto_uid': asuntoUid, 'opciones': opcionesMarcadas.toList()});

  /// [enNombreDeUid]: la mesa recoge lo que alguien dijo en persona o dejó
  /// por escrito (canal en papel).
  void aportar(
    String asuntoUid,
    TipoAportacion tipo,
    String texto, {
    String? respondeAUid,
    bool anonima = false,
    String? enNombreDeUid,
  }) =>
      _hacer(TipoAccion.aportar, {
        'uid': _nuevoUid('ap'),
        'asunto_uid': asuntoUid,
        'tipo': tipo.name,
        'texto': texto,
        'responde_a_uid': respondeAUid,
        'anonima': anonima,
        'en_nombre_de_uid': enNombreDeUid,
      });

  void objetar(String asuntoUid, String motivo, {String? enNombreDeUid}) =>
      _hacer(TipoAccion.objetar, {
        'uid': _nuevoUid('ob'),
        'asunto_uid': asuntoUid,
        'motivo': motivo,
        'en_nombre_de_uid': enNombreDeUid,
      });

  void cambiarEstadoCompromiso(
    String compromisoUid,
    EstadoCompromiso nuevo, {
    String nota = '',
  }) =>
      _hacer(TipoAccion.cambiarEstadoCompromiso, {
        'compromiso_uid': compromisoUid,
        'estado': nuevo.name,
        'nota': nota,
      });

  /// Crea o reemplaza un borrador. Un asunto abierto ya no se toca.
  void guardarBorrador(Asunto borrador) =>
      _hacer(TipoAccion.guardarBorrador, {'asunto': asuntoAJson(borrador)});

  /// Abre el borrador: desde aquí las reglas quedan fijas.
  void abrirAsunto(String uid) =>
      _hacer(TipoAccion.abrirAsunto, {'asunto_uid': uid});

  void borrarBorrador(String uid) =>
      _hacer(TipoAccion.borrarBorrador, {'asunto_uid': uid});

  void moderar(String asuntoUid, String aportacionUid, EstadoModeracion nuevo,
          {String motivo = ''}) =>
      _hacer(TipoAccion.moderar, {
        'asunto_uid': asuntoUid,
        'aportacion_uid': aportacionUid,
        'estado': nuevo.name,
        'motivo': motivo,
      });

  void resumirDebate(String asuntoUid, String resumen) => _hacer(
      TipoAccion.resumirDebate, {'asunto_uid': asuntoUid, 'resumen': resumen});

  /// Integrar o declarar que no es objeción lo hace la mesa; retirarla, solo
  /// quien la planteó.
  void resolverObjecion(String asuntoUid, String objecionUid,
          EstadoObjecion nuevo, String respuesta) =>
      _hacer(TipoAccion.resolverObjecion, {
        'asunto_uid': asuntoUid,
        'objecion_uid': objecionUid,
        'estado': nuevo.name,
        'respuesta': respuesta,
      });

  DesenlaceConsentimiento cerrarRondaConsentimiento(String asuntoUid) =>
      _hacer(TipoAccion.cerrarRondaConsentimiento, {'asunto_uid': asuntoUid})
          as DesenlaceConsentimiento;

  void anadirCompromiso({
    required String asuntoUid,
    required String que,
    required String responsable,
    required DateTime fechaLimite,
  }) =>
      _hacer(TipoAccion.anadirCompromiso, {
        'uid': _nuevoUid('co'),
        'asunto_uid': asuntoUid,
        'que': que,
        'responsable': responsable,
        'fecha_limite': fechaLimite.toIso8601String(),
      });

  /// Alta rápida de alguien que vota en persona y no está en la lista (el
  /// servidor le genera además su código en papel).
  Persona darDeAlta(String nombre) =>
      _hacer(TipoAccion.darDeAlta, {'uid': _nuevoUid('pe'), 'nombre': nombre})
          as Persona;

  /// La mesa apunta que alguien ha votado en papel. Su papeleta entra luego
  /// en el conteo de la mesa.
  void anotarVotoPresencial(String asuntoUid, String personaUid) => _hacer(
      TipoAccion.anotarVotoPresencial,
      {'asunto_uid': asuntoUid, 'persona_uid': personaUid});

  /// El conteo de las papeletas en papel, firmado por la persona actual y
  /// otra persona de la mesa.
  void registrarConteoPresencial({
    required String asuntoUid,
    required int papeletasTotales,
    required Map<String, int> marcasPorOpcion,
    required String segundaFirmaUid,
  }) =>
      _hacer(TipoAccion.registrarConteoPresencial, {
        'asunto_uid': asuntoUid,
        'papeletas_totales': papeletasTotales,
        'marcas': marcasPorOpcion,
        'segunda_firma_uid': segundaFirmaUid,
      });

  void firmarActa(String asuntoUid) =>
      _hacer(TipoAccion.firmarActa, {'asunto_uid': asuntoUid});

  void retirarFirmaActa(String asuntoUid) =>
      _hacer(TipoAccion.retirarFirmaActa, {'asunto_uid': asuntoUid});
}
