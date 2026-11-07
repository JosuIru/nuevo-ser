/// El dominio en JSON, para la caché local y para hablar con el servidor
/// del pueblo (`social/wp-plugin/concejo/`). Las claves están en castellano
/// y en snake_case, igual que en el plugin.
///
/// Fechas: `toIso8601String()`. Las del calendario de un asunto son de
/// calendario (sin zona, hora local del pueblo); los momentos (una firma,
/// una aportación) van en UTC con `Z`.
library;

import '../dominio/acta.dart';
import '../dominio/asunto.dart';
import '../dominio/compromiso.dart';
import '../dominio/consentimiento.dart';
import '../dominio/debate.dart';
import '../dominio/persona.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/urna.dart';
import '../dominio/sesion.dart';

typedef Json = Map<String, dynamic>;

T _enumPorNombre<T extends Enum>(
    List<T> valores, Object? nombre, T porDefecto) {
  for (final valor in valores) {
    if (valor.name == nombre) return valor;
  }
  return porDefecto;
}

String? _fechaOpcional(DateTime? fecha) => fecha?.toIso8601String();
DateTime? _leerFechaOpcional(Object? texto) =>
    texto is String && texto.isNotEmpty ? DateTime.parse(texto) : null;
DateTime _leerFecha(Object? texto) => DateTime.parse(texto as String);
double? _leerNumero(Object? valor) => valor is num ? valor.toDouble() : null;
List<Json> _lista(Object? valor) =>
    [for (final elemento in (valor as List? ?? const [])) elemento as Json];

// ---------------------------------------------------------------- persona

Json personaAJson(Persona persona) => {
      'uid': persona.uid,
      'nombre': persona.nombre,
      'rol': persona.rol.name,
      'mandato_hasta': _fechaOpcional(persona.mandatoHasta),
    };

Persona personaDesdeJson(Json json) => Persona(
      uid: json['uid'] as String,
      nombre: json['nombre'] as String,
      rol: _enumPorNombre(Rol.values, json['rol'], Rol.vecina),
      mandatoHasta: _leerFechaOpcional(json['mandato_hasta']),
    );

// ---------------------------------------------------------------- asunto

Json reglasAJson(ReglasDecision reglas) => {
      'forma': reglas.forma.name,
      'mayoria': reglas.mayoria.name,
      'quorum_personas': reglas.quorumPersonas,
      'secreta': reglas.secreta,
      'opciones': [
        for (final opcion in reglas.opciones)
          {
            'id': opcion.id,
            'texto': opcion.texto,
            'coste_euros': opcion.costeEuros,
          },
      ],
      'bolsa_euros': reglas.bolsaEuros,
      'rondas_consentimiento': reglas.rondasConsentimiento,
    };

ReglasDecision reglasDesdeJson(Json json) => ReglasDecision(
      forma: _enumPorNombre(
          FormaDecision.values, json['forma'], FormaDecision.votacion),
      mayoria: _enumPorNombre(Mayoria.values, json['mayoria'], Mayoria.simple),
      quorumPersonas: (json['quorum_personas'] as num?)?.toInt() ?? 0,
      secreta: json['secreta'] as bool? ?? true,
      opciones: [
        for (final opcion in _lista(json['opciones']))
          OpcionDecision(
            id: opcion['id'] as String,
            texto: opcion['texto'] as String,
            costeEuros: _leerNumero(opcion['coste_euros']),
          ),
      ],
      bolsaEuros: _leerNumero(json['bolsa_euros']),
      rondasConsentimiento:
          (json['rondas_consentimiento'] as num?)?.toInt() ?? 2,
    );

Json asuntoAJson(Asunto asunto) => {
      'uid': asunto.uid,
      'titulo': asunto.titulo,
      'resumen': asunto.resumen,
      'texto': asunto.texto,
      'tipo_decision': asunto.tipoDecision.name,
      'compromiso_previo': asunto.compromisoPrevio,
      'coste_euros': asunto.costeEuros,
      'efecto_entorno': asunto.efectoEntorno,
      'reglas': reglasAJson(asunto.reglas),
      'inicio_debate': asunto.inicioDebate.toIso8601String(),
      'inicio_decision': asunto.inicioDecision.toIso8601String(),
      'fin_decision': asunto.finDecision.toIso8601String(),
      'creado_por_uid': asunto.creadoPorUid,
      'abierto': asunto.abierto,
    };

Asunto asuntoDesdeJson(Json json) => Asunto(
      uid: json['uid'] as String,
      titulo: json['titulo'] as String? ?? '',
      resumen: json['resumen'] as String? ?? '',
      texto: json['texto'] as String? ?? '',
      tipoDecision: _enumPorNombre(
          TipoDecision.values, json['tipo_decision'], TipoDecision.consultiva),
      compromisoPrevio: json['compromiso_previo'] as String? ?? '',
      costeEuros: _leerNumero(json['coste_euros']),
      efectoEntorno: json['efecto_entorno'] as String? ?? '',
      reglas: reglasDesdeJson(json['reglas'] as Json),
      inicioDebate: _leerFecha(json['inicio_debate']),
      inicioDecision: _leerFecha(json['inicio_decision']),
      finDecision: _leerFecha(json['fin_decision']),
      creadoPorUid: json['creado_por_uid'] as String? ?? '',
      abierto: json['abierto'] as bool? ?? false,
    );

// ---------------------------------------------------------------- urna

/// La urna tal como la manda el servidor: las participaciones (quién ha
/// participado) y, por separado y sin orden de llegada, las papeletas.
Json urnaAJson(Urna urna) => {
      'asunto_uid': urna.asuntoUid,
      'participaciones': [
        for (final participacion in urna.participaciones)
          {
            'persona_uid': participacion.personaUid,
            'canal': participacion.canal.name,
            'anotada_por_uid': participacion.anotadaPorUid,
          },
      ],
      'papeletas': [
        for (final papeleta in urna.papeletas)
          {
            'opciones': papeleta.opcionesMarcadas.toList(),
            'hora': _fechaOpcional(papeleta.horaRedondeada),
            'persona_uid': papeleta.personaUid,
          },
      ],
      'conteos': [
        for (final conteo in urna.conteosPresenciales)
          {
            'papeletas_totales': conteo.papeletasTotales,
            'marcas': conteo.marcasPorOpcion,
            'firmado_por_uids': conteo.firmadoPorUids,
          },
      ],
    };

Urna urnaDesdeJson(Json json) {
  final asuntoUid = json['asunto_uid'] as String;
  return Urna(
    asuntoUid: asuntoUid,
    participaciones: [
      for (final participacion in _lista(json['participaciones']))
        Participacion(
          asuntoUid: asuntoUid,
          personaUid: participacion['persona_uid'] as String,
          canal: _enumPorNombre(CanalParticipacion.values,
              participacion['canal'], CanalParticipacion.app),
          anotadaPorUid: participacion['anotada_por_uid'] as String? ?? '',
        ),
    ],
    papeletas: [
      for (final papeleta in _lista(json['papeletas']))
        Papeleta(
          asuntoUid: asuntoUid,
          opcionesMarcadas: {
            for (final opcion in papeleta['opciones'] as List) opcion as String
          },
          horaRedondeada: _leerFechaOpcional(papeleta['hora']),
          personaUid: papeleta['persona_uid'] as String?,
        ),
    ],
    conteosPresenciales: [
      for (final conteo in _lista(json['conteos']))
        ConteoPresencial(
          asuntoUid: asuntoUid,
          papeletasTotales: (conteo['papeletas_totales'] as num).toInt(),
          marcasPorOpcion: {
            for (final MapEntry(:key, :value)
                in (conteo['marcas'] as Map).entries)
              key as String: (value as num).toInt(),
          },
          firmadoPorUids: [
            for (final uid in conteo['firmado_por_uids'] as List) uid as String
          ],
        ),
    ],
  );
}

// ---------------------------------------------------------------- debate

Json aportacionAJson(Aportacion aportacion) => {
      'uid': aportacion.uid,
      'asunto_uid': aportacion.asuntoUid,
      'autor_uid': aportacion.autorUid,
      'tipo': aportacion.tipo.name,
      'texto': aportacion.texto,
      'creada': aportacion.creada.toIso8601String(),
      'responde_a_uid': aportacion.respondeAUid,
      'anonima': aportacion.anonima,
      'estado': aportacion.estado.name,
      'motivo_retirada': aportacion.motivoRetirada,
    };

Aportacion aportacionDesdeJson(Json json) => Aportacion(
      uid: json['uid'] as String,
      asuntoUid: json['asunto_uid'] as String,
      autorUid: json['autor_uid'] as String? ?? '',
      tipo: _enumPorNombre(
          TipoAportacion.values, json['tipo'], TipoAportacion.duda),
      texto: json['texto'] as String? ?? '',
      creada: _leerFecha(json['creada']),
      respondeAUid: json['responde_a_uid'] as String?,
      anonima: json['anonima'] as bool? ?? false,
      estado: _enumPorNombre(
          EstadoModeracion.values, json['estado'], EstadoModeracion.visible),
      motivoRetirada: json['motivo_retirada'] as String? ?? '',
    );

Json debateAJson(Debate debate) => {
      'asunto_uid': debate.asuntoUid,
      'aportaciones': [for (final a in debate.aportaciones) aportacionAJson(a)],
      'resumen_mesa': debate.resumenMesa,
    };

Debate debateDesdeJson(Json json) => Debate(
      asuntoUid: json['asunto_uid'] as String,
      aportaciones: [
        for (final aportacion in _lista(json['aportaciones']))
          aportacionDesdeJson(aportacion),
      ],
      resumenMesa: json['resumen_mesa'] as String? ?? '',
    );

// --------------------------------------------------------- consentimiento

Json consentimientoAJson(EstadoConsentimiento consentimiento) => {
      'ronda_actual': consentimiento.rondaActual,
      'rondas_maximas': consentimiento.rondasMaximas,
      'desenlace': consentimiento.desenlace.name,
      'objeciones': [
        for (final objecion in consentimiento.objeciones)
          {
            'uid': objecion.uid,
            'autor_uid': objecion.autorUid,
            'ronda': objecion.ronda,
            'motivo': objecion.motivo,
            'estado': objecion.estado.name,
            'respuesta': objecion.respuesta,
          },
      ],
    };

EstadoConsentimiento consentimientoDesdeJson(Json json) => EstadoConsentimiento(
      rondaActual: (json['ronda_actual'] as num).toInt(),
      rondasMaximas: (json['rondas_maximas'] as num).toInt(),
      desenlace: _enumPorNombre(DesenlaceConsentimiento.values,
          json['desenlace'], DesenlaceConsentimiento.enCurso),
      objeciones: [
        for (final objecion in _lista(json['objeciones']))
          Objecion(
            uid: objecion['uid'] as String,
            autorUid: objecion['autor_uid'] as String,
            ronda: (objecion['ronda'] as num).toInt(),
            motivo: objecion['motivo'] as String,
            estado: _enumPorNombre(
                EstadoObjecion.values, objecion['estado'], EstadoObjecion.viva),
            respuesta: objecion['respuesta'] as String? ?? '',
          ),
      ],
    );

// ------------------------------------------------------------- compromiso

Json compromisoAJson(Compromiso compromiso) => {
      'uid': compromiso.uid,
      'asunto_uid': compromiso.asuntoUid,
      'que': compromiso.que,
      'responsable': compromiso.responsable,
      'fecha_limite': compromiso.fechaLimite.toIso8601String(),
      'estado': compromiso.estado.name,
      'nota': compromiso.nota,
    };

Compromiso compromisoDesdeJson(Json json) => Compromiso(
      uid: json['uid'] as String,
      asuntoUid: json['asunto_uid'] as String,
      que: json['que'] as String,
      responsable: json['responsable'] as String,
      fechaLimite: _leerFecha(json['fecha_limite']),
      estado: _enumPorNombre(
          EstadoCompromiso.values, json['estado'], EstadoCompromiso.pendiente),
      nota: json['nota'] as String? ?? '',
    );

// ------------------------------------------------------------------ acta

Json actaAJson(Acta acta) => {
      'asunto_uid': acta.asuntoUid,
      'firmas': [
        for (final firma in acta.firmas)
          {
            'persona_uid': firma.personaUid,
            'firmada': firma.firmada.toIso8601String(),
          },
      ],
      'compromisos_al_firmar_uids': acta.compromisosAlFirmarUids,
    };

Acta actaDesdeJson(Json json) => Acta(
      asuntoUid: json['asunto_uid'] as String,
      firmas: [
        for (final firma in _lista(json['firmas']))
          FirmaActa(
            personaUid: firma['persona_uid'] as String,
            firmada: _leerFecha(firma['firmada']),
          ),
      ],
      compromisosAlFirmarUids: (json['compromisos_al_firmar_uids'] as List?)
          ?.map((uid) => uid as String)
          .toList(),
    );

// ---------------------------------------------------------------- sesion

Json puntoAJson(PuntoOrdenDia punto) => {
      'uid': punto.uid,
      'texto': punto.texto,
      'asunto_uid': punto.asuntoUid,
      'notas': punto.notas,
    };

PuntoOrdenDia puntoDesdeJson(Json json) => PuntoOrdenDia(
      uid: json['uid'] as String,
      texto: json['texto'] as String,
      asuntoUid: json['asunto_uid'] as String?,
      notas: json['notas'] as String? ?? '',
    );

Json sesionAJson(Sesion sesion) => {
      'uid': sesion.uid,
      'titulo': sesion.titulo,
      'inicio': sesion.inicio.toIso8601String(),
      'lugar': sesion.lugar,
      'puntos': [for (final punto in sesion.puntos) puntoAJson(punto)],
      'convocada_por_uid': sesion.convocadaPorUid,
      'asistentes_uids': sesion.asistentesUids.toList()..sort(),
      'asistentes_sin_app': sesion.asistentesSinApp,
      'anulada': sesion.anulada,
      'motivo_anulacion': sesion.motivoAnulacion,
    };

Sesion sesionDesdeJson(Json json) => Sesion(
      uid: json['uid'] as String,
      titulo: json['titulo'] as String,
      inicio: _leerFecha(json['inicio']),
      lugar: json['lugar'] as String,
      puntos: [
        for (final punto in json['puntos'] as List)
          puntoDesdeJson(punto as Json),
      ],
      convocadaPorUid: json['convocada_por_uid'] as String? ?? '',
      asistentesUids: {
        for (final uid in json['asistentes_uids'] as List? ?? const [])
          uid as String,
      },
      asistentesSinApp: (json['asistentes_sin_app'] as num?)?.toInt() ?? 0,
      anulada: json['anulada'] as bool? ?? false,
      motivoAnulacion: json['motivo_anulacion'] as String? ?? '',
    );
