/// Textos de los valores del dominio en el idioma de la app.
library;

import 'package:intl/intl.dart';

import '../dominio/anuncio.dart';
import '../dominio/asunto.dart';
import '../dominio/compromiso.dart';
import '../dominio/consentimiento.dart';
import '../dominio/debate.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/sesion.dart';
import '../dominio/tarea.dart';
import '../l10n/app_localizations.dart';

extension TextosDominio on AppLocalizations {
  String fase(FaseAsunto fase) => switch (fase) {
        FaseAsunto.borrador => faseBorrador,
        FaseAsunto.debate => faseDebate,
        FaseAsunto.decision => faseDecision,
        FaseAsunto.seguimiento => faseSeguimiento,
      };

  String tipoDecision(TipoDecision tipo) => switch (tipo) {
        TipoDecision.vinculante => tipoVinculante,
        TipoDecision.conCompromisoPrevio => tipoConCompromiso,
        TipoDecision.consultiva => tipoConsultiva,
      };

  String explicaTipoDecision(TipoDecision tipo) => switch (tipo) {
        TipoDecision.vinculante => explicaVinculante,
        TipoDecision.conCompromisoPrevio => explicaConCompromiso,
        TipoDecision.consultiva => explicaConsultiva,
      };

  String forma(FormaDecision forma) => switch (forma) {
        FormaDecision.votacion => formaVotacion,
        FormaDecision.eleccionEntreOpciones => formaEleccion,
        FormaDecision.consentimiento => formaConsentimiento,
        FormaDecision.presupuesto => formaPresupuesto,
      };

  String mayoria(Mayoria mayoria) => switch (mayoria) {
        Mayoria.simple => mayoriaSimple,
        Mayoria.absoluta => mayoriaAbsoluta,
        Mayoria.dosTercios => mayoriaDosTercios,
      };

  String columna(TipoAportacion tipo) => switch (tipo) {
        TipoAportacion.aFavor => columnaAFavor,
        TipoAportacion.enContra => columnaEnContra,
        TipoAportacion.duda => columnaDudas,
        TipoAportacion.propuestaDeCambio => columnaCambios,
      };

  String estadoCompromiso(EstadoCompromiso estado) => switch (estado) {
        EstadoCompromiso.pendiente => compromisoPendiente,
        EstadoCompromiso.enMarcha => compromisoEnMarcha,
        EstadoCompromiso.hecho => compromisoHecho,
        EstadoCompromiso.noSeHara => compromisoNoSeHara,
      };

  String nombreForma(FormaDecision forma) => switch (forma) {
        FormaDecision.votacion => nombreVotacion,
        FormaDecision.eleccionEntreOpciones => nombreEleccion,
        FormaDecision.consentimiento => nombreConsentimiento,
        FormaDecision.presupuesto => nombrePresupuesto,
      };

  String problema(ProblemaAsunto problema) => switch (problema) {
        ProblemaAsunto.faltaTitulo => problemaTitulo,
        ProblemaAsunto.faltaResumen => problemaResumen,
        ProblemaAsunto.faltaEfectoEntorno => problemaEntorno,
        ProblemaAsunto.faltaCompromisoPrevio => problemaCompromiso,
        ProblemaAsunto.fechasDesordenadas => problemaFechas,
        ProblemaAsunto.faltanOpciones => problemaOpciones,
        ProblemaAsunto.opcionesRepetidas => problemaRepetidas,
        ProblemaAsunto.faltaBolsa => problemaBolsa,
        ProblemaAsunto.propuestaSinCoste => problemaSinCoste,
        ProblemaAsunto.quorumNegativo => problemaQuorum,
      };

  String estadoObjecion(EstadoObjecion estado) => switch (estado) {
        EstadoObjecion.viva => objecionesVivas,
        EstadoObjecion.integrada => estadoIntegrada,
        EstadoObjecion.retirada => estadoRetirada,
        EstadoObjecion.noEsObjecion => estadoNoEsObjecion,
      };

  /// «5 de noviembre».
  String fecha(DateTime momento) =>
      DateFormat.MMMMd(localeName).format(momento);

  /// «jueves, 14 de noviembre, 19:00»: día y hora de una asamblea.
  String fechaYHora(DateTime momento) =>
      '${DateFormat.MMMMEEEEd(localeName).format(momento)}, '
      '${DateFormat.Hm(localeName).format(momento)}';

  /// «19:00».
  String hora(DateTime momento) => DateFormat.Hm(localeName).format(momento);

  String problemaSesion(ProblemaSesion problema) => switch (problema) {
        ProblemaSesion.faltaTitulo => sesionFaltaTitulo,
        ProblemaSesion.faltaLugar => sesionFaltaLugar,
        ProblemaSesion.sinPuntos => sesionSinPuntos,
        ProblemaSesion.puntoVacio => sesionPuntoVacio,
        ProblemaSesion.puntoRepetido => sesionPuntoRepetido,
      };

  String problemaAnuncio(ProblemaAnuncio problema) => switch (problema) {
        ProblemaAnuncio.faltaTitulo => anuncioFaltaTitulo,
        ProblemaAnuncio.tituloLargo =>
          anuncioTituloLargo(Anuncio.largoMaximoTitulo),
        ProblemaAnuncio.textoLargo =>
          anuncioTextoLargo(Anuncio.largoMaximoTexto),
        ProblemaAnuncio.hastaPasado => anuncioHastaPasado,
      };

  String problemaTarea(ProblemaTarea problema) => switch (problema) {
        ProblemaTarea.faltaTitulo => tareaFaltaTitulo,
        ProblemaTarea.plazasNegativas => tareaPlazasNegativas,
        ProblemaTarea.yaHaEmpezado => tareaYaHaEmpezado,
      };

  /// «Van 3 de 8: faltan 5», «Van 1 de 1: completa», «Van 4».
  String cuentaTarea(Tarea tarea) {
    final apuntadas = tarea.apuntadosUids.length;
    final libres = tarea.plazasLibres;
    if (libres == null) return tareaCuentaSinLimite(apuntadas);
    return '${tareaCuenta(apuntadas, tarea.plazas)}: '
        '${libres == 0 ? tareaCompleta : faltanManos(libres)}';
  }

  /// «5 de noviembre de 2026»: para el acta, que se lee años después.
  String fechaConAnio(DateTime momento) =>
      DateFormat.yMMMMd(localeName).format(momento);

  String euros(double cantidad) => NumberFormat.currency(
        locale: localeName,
        symbol: '€',
        decimalDigits: cantidad == cantidad.roundToDouble() ? 0 : 2,
      ).format(cantidad);
}
