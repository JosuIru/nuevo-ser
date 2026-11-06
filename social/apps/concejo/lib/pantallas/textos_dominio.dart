/// Textos de los valores del dominio en el idioma de la app.
library;

import 'package:intl/intl.dart';

import '../dominio/asunto.dart';
import '../dominio/compromiso.dart';
import '../dominio/debate.dart';
import '../dominio/reglas_decision.dart';
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

  /// «5 de noviembre».
  String fecha(DateTime momento) =>
      DateFormat.MMMMd(localeName).format(momento);

  String euros(double cantidad) => NumberFormat.currency(
        locale: localeName,
        symbol: '€',
        decimalDigits: cantidad == cantidad.roundToDouble() ? 0 : 2,
      ).format(cantidad);
}
