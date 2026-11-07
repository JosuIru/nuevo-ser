/// Los **avisos mínimos** (`docs/04-concejo.md` §4.7): solo lo que necesita
/// a esa persona. Asunto nuevo, últimos días para decidir, asamblea
/// próxima o anulada, resultado,
/// compromiso que vence (a quien lo tiene) y fin de mandato en la mesa.
/// Nada de «vuelve a la app»: lo demás va al correo semanal.
///
/// Se calculan del estado cada vez; lo único que se guarda es qué avisos ha
/// quitado ya cada persona ([AvisosVistos]).
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../servidor/almacen_local.dart';
import 'estado_concejo.dart';

enum TipoAviso {
  ultimosDias,
  asamblea,
  asambleaAnulada,
  tarea,
  tareaAnulada,
  compromisoVence,
  compromisoVencido,
  mandatoAcaba,
  asuntoNuevo,
  resultado,
}

class Aviso {
  const Aviso({
    required this.tipo,
    required this.clave,
    required this.fecha,
    this.asuntoUid,
    this.compromisoUid,
    this.sesionUid,
    this.tareaUid,
  });

  final TipoAviso tipo;

  /// Única y estable: con ella se recuerda que la persona lo quitó. Lleva
  /// la fecha cuando la fecha puede cambiar (un plazo nuevo vuelve a avisar).
  final String clave;

  /// La fecha que importa: fin del debate, cierre, plazo o fin de mandato.
  final DateTime fecha;
  final String? asuntoUid;
  final String? compromisoUid;
  final String? sesionUid;
  final String? tareaUid;
}

/// Un asunto es «nuevo» durante sus primeras dos semanas de debate.
const diasDeAsuntoNuevo = 14;

/// Se avisa en los dos últimos días para decidir.
const diasDeUltimoAviso = 2;

/// Un resultado se avisa durante dos semanas.
const diasDeResultado = 14;

/// Una asamblea se avisa en los tres días anteriores (también si se anula).
const diasAntesDeLaAsamblea = 3;

/// A quien se ha apuntado a una tarea se le recuerda en los dos días
/// anteriores (y si se anula).
const diasAntesDeLaTarea = 2;

/// Un compromiso se avisa tres días antes de su fecha.
const diasAntesDelCompromiso = 3;

/// El fin de mandato se avisa dos semanas antes, para que dé tiempo a rotar.
const diasAntesDelFinDeMandato = 14;

/// El responsable de un compromiso es texto libre («Mikel», «la junta»): se
/// reconoce a la persona por su nombre, sin mayúsculas ni espacios de más.
String _normalizar(String texto) =>
    texto.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _dia(DateTime fecha) =>
    '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}';

/// Los avisos de la persona actual, lo más urgente primero.
List<Aviso> avisosPara(EstadoConcejo estado) {
  final ahora = estado.ahora;
  final persona = estado.personaActual;
  final avisos = <Aviso>[];

  for (final asunto in estado.asuntos) {
    final fase = asunto.faseEn(ahora);
    final esConsentimiento =
        asunto.reglas.forma == FormaDecision.consentimiento;
    switch (fase) {
      case FaseAsunto.borrador:
        break;
      case FaseAsunto.debate:
        if (ahora.difference(asunto.inicioDebate).inDays < diasDeAsuntoNuevo) {
          avisos.add(Aviso(
            tipo: TipoAviso.asuntoNuevo,
            clave: 'nuevo:${asunto.uid}',
            fecha: asunto.inicioDecision,
            asuntoUid: asunto.uid,
          ));
        }
      case FaseAsunto.decision:
        final quedaPoco = asunto.finDecision.difference(ahora) <=
            const Duration(days: diasDeUltimoAviso);
        // Quien ya ha votado no necesita el aviso. En consentimiento no se
        // vota: callar es consentir, así que se avisa a todo el mundo.
        final pendiente = esConsentimiento
            ? !estado.consentimiento(asunto.uid).decidido
            : !estado.heVotado(asunto.uid);
        if (quedaPoco && pendiente) {
          avisos.add(Aviso(
            tipo: TipoAviso.ultimosDias,
            clave: 'ultimos:${asunto.uid}:${_dia(asunto.finDecision)}',
            fecha: asunto.finDecision,
            asuntoUid: asunto.uid,
          ));
        }
      case FaseAsunto.seguimiento:
        final decidido =
            !esConsentimiento || estado.consentimiento(asunto.uid).decidido;
        if (decidido &&
            ahora.difference(asunto.finDecision).inDays < diasDeResultado) {
          avisos.add(Aviso(
            tipo: TipoAviso.resultado,
            clave: 'resultado:${asunto.uid}',
            fecha: asunto.finDecision,
            asuntoUid: asunto.uid,
          ));
        }
    }
  }

  for (final sesion in estado.sesiones) {
    if (sesion.empezadaEn(ahora)) continue;
    if (sesion.inicio.difference(ahora) >
        const Duration(days: diasAntesDeLaAsamblea)) {
      continue;
    }
    avisos.add(Aviso(
      tipo: sesion.anulada ? TipoAviso.asambleaAnulada : TipoAviso.asamblea,
      clave: '${sesion.anulada ? 'anulada' : 'asamblea'}:${sesion.uid}:'
          '${sesion.inicio.toIso8601String()}',
      fecha: sesion.inicio,
      sesionUid: sesion.uid,
    ));
  }

  for (final tarea in estado.tareas) {
    if (!tarea.apuntadosUids.contains(persona.uid)) continue;
    if (tarea.estaHecha || tarea.empezadaEn(ahora)) continue;
    if (tarea.inicio.difference(ahora) >
        const Duration(days: diasAntesDeLaTarea)) {
      continue;
    }
    avisos.add(Aviso(
      tipo: tarea.anulada ? TipoAviso.tareaAnulada : TipoAviso.tarea,
      clave: '${tarea.anulada ? 'tarea-anulada' : 'tarea'}:${tarea.uid}',
      fecha: tarea.inicio,
      tareaUid: tarea.uid,
    ));
  }

  final miNombre = _normalizar(persona.nombre);
  for (final compromiso in estado.compromisos) {
    if (compromiso.cerrado) continue;
    // A quien lo tiene, y a la mesa, que es quien sigue los acuerdos.
    final esMio = _normalizar(compromiso.responsable) == miNombre;
    if (!esMio && !estado.soyMesa) continue;
    final vencido = compromiso.vencidoEn(ahora);
    final faltaPoco = compromiso.fechaLimite.difference(ahora) <=
        const Duration(days: diasAntesDelCompromiso);
    if (!vencido && !faltaPoco) continue;
    avisos.add(Aviso(
      tipo: vencido ? TipoAviso.compromisoVencido : TipoAviso.compromisoVence,
      clave: '${vencido ? 'vencido' : 'vence'}:${compromiso.uid}:'
          '${_dia(compromiso.fechaLimite)}',
      fecha: compromiso.fechaLimite,
      asuntoUid: compromiso.asuntoUid,
      compromisoUid: compromiso.uid,
    ));
  }

  final diasDeMandato = persona.diasDeMandatoEn(ahora);
  if (diasDeMandato != null &&
      diasDeMandato <= diasAntesDelFinDeMandato &&
      persona.esMesaEn(ahora)) {
    avisos.add(Aviso(
      tipo: TipoAviso.mandatoAcaba,
      clave: 'mandato:${persona.uid}:${_dia(persona.mandatoHasta!)}',
      fecha: persona.mandatoHasta!,
    ));
  }

  avisos.sort((a, b) {
    final porTipo = a.tipo.index.compareTo(b.tipo.index);
    return porTipo != 0 ? porTipo : a.fecha.compareTo(b.fecha);
  });
  return avisos;
}

/// Qué avisos ha quitado cada persona. Se guarda en el teléfono: no es
/// algo que el pueblo tenga que saber.
class AvisosVistos extends ChangeNotifier {
  AvisosVistos({AlmacenLocal? almacen}) : _almacen = almacen {
    final guardado = _almacen?.leer(clave);
    if (guardado != null) {
      _vistos.addAll((jsonDecode(guardado) as List).cast<String>());
    }
  }

  static const clave = 'concejo.avisos_vistos';

  final AlmacenLocal? _almacen;
  final _vistos = <String>{};

  String _de(String personaUid, Aviso aviso) => '$personaUid|${aviso.clave}';

  /// Los avisos que la persona aún no ha quitado.
  List<Aviso> pendientes(String personaUid, List<Aviso> avisos) => [
        for (final aviso in avisos)
          if (!_vistos.contains(_de(personaUid, aviso))) aviso,
      ];

  /// Quita los [avisos]. De paso olvida los que ya no salen ([vigentes]),
  /// para que la lista no crezca sin fin.
  Future<void> quitar(
      String personaUid, Iterable<Aviso> avisos, List<Aviso> vigentes) async {
    final siguenSaliendo = {for (final otro in vigentes) _de(personaUid, otro)};
    _vistos
      ..removeWhere((vista) =>
          vista.startsWith('$personaUid|') && !siguenSaliendo.contains(vista))
      ..addAll([for (final aviso in avisos) _de(personaUid, aviso)]);
    notifyListeners();
    await _almacen?.escribir(clave, jsonEncode(_vistos.toList()));
  }
}
