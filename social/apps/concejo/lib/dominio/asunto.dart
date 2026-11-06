/// Un **asunto** es lo que el pueblo tiene que decidir: «¿Cambiamos la fecha
/// de las fiestas?», «Ordenanza del uso del comunal», «Presupuesto 2027».
///
/// Pasa por tres fases visibles desde el principio (`docs/04-concejo.md` §4.2):
/// **debate** → **decisión** → **seguimiento**. Las reglas de decisión se
/// fijan al crearlo y **no se pueden cambiar una vez abierto** (§4.4): así
/// nadie ajusta el quórum o la mayoría a la vista de cómo va la cosa.
library;

import 'reglas_decision.dart';

/// Qué valor tiene lo que salga (§3). Se enseña en la cabecera del asunto.
enum TipoDecision {
  /// El grupo decide sobre lo suyo según sus estatutos o normas.
  vinculante,

  /// El órgano formal se compromete por escrito, antes, a ejecutar lo que
  /// salga si se cumplen unas condiciones ([Asunto.compromisoPrevio]).
  conCompromisoPrevio,

  /// Sirve para que el órgano formal sepa qué piensa la gente; decide él.
  consultiva,
}

enum FaseAsunto {
  /// Creado por la mesa pero aún no abierto: es el único momento en que se
  /// pueden cambiar las reglas.
  borrador,
  debate,
  decision,

  /// Decidido: ya solo queda seguir los compromisos.
  seguimiento,
}

class Asunto {
  const Asunto({
    required this.uid,
    required this.titulo,
    required this.resumen,
    required this.reglas,
    required this.inicioDebate,
    required this.inicioDecision,
    required this.finDecision,
    this.texto = '',
    this.tipoDecision = TipoDecision.consultiva,
    this.compromisoPrevio = '',
    this.costeEuros,
    this.efectoEntorno = '',
    this.creadoPorUid = '',
    this.abierto = false,
  });

  final String uid;
  final String titulo;

  /// Tres líneas en lectura fácil: es lo primero que se ve.
  final String resumen;

  /// El texto completo, debajo del resumen.
  final String texto;
  final TipoDecision tipoDecision;

  /// Obligatorio si [tipoDecision] es [TipoDecision.conCompromisoPrevio]:
  /// quién se compromete a qué y en qué condiciones.
  final String compromisoPrevio;
  final double? costeEuros;

  /// Efecto sobre el agua, el monte, el ruido, el paisaje, los animales…
  /// Obligatorio aunque sea «ninguno»: es la forma práctica de dar voz a la
  /// naturaleza en las decisiones (`docs/02-fuentes-coleccion.md` §2).
  final String efectoEntorno;
  final ReglasDecision reglas;
  final DateTime inicioDebate;
  final DateTime inicioDecision;
  final DateTime finDecision;
  final String creadoPorUid;

  /// La mesa lo ha abierto: desde ese momento las reglas quedan fijas.
  final bool abierto;

  FaseAsunto faseEn(DateTime ahora) {
    if (!abierto) return FaseAsunto.borrador;
    if (ahora.isBefore(inicioDecision)) return FaseAsunto.debate;
    if (ahora.isBefore(finDecision)) return FaseAsunto.decision;
    return FaseAsunto.seguimiento;
  }

  bool get puedeCambiarReglas => !abierto;

  /// Lo que falta para poder abrirlo, en el orden en que se rellena.
  /// Vacío = se puede abrir.
  List<ProblemaAsunto> problemasParaAbrir() => [
        if (titulo.trim().isEmpty) ProblemaAsunto.faltaTitulo,
        if (resumen.trim().isEmpty) ProblemaAsunto.faltaResumen,
        if (efectoEntorno.trim().isEmpty) ProblemaAsunto.faltaEfectoEntorno,
        if (tipoDecision == TipoDecision.conCompromisoPrevio &&
            compromisoPrevio.trim().isEmpty)
          ProblemaAsunto.faltaCompromisoPrevio,
        if (!inicioDebate.isBefore(inicioDecision) ||
            !inicioDecision.isBefore(finDecision))
          ProblemaAsunto.fechasDesordenadas,
        ...reglas.problemas(),
      ];

  /// Lo abre si no le falta nada. Devuelve el asunto abierto (las reglas
  /// quedan fijas) o lanza [StateError] con lo que falta.
  Asunto abrir() {
    if (abierto) throw StateError('El asunto ya está abierto');
    final problemas = problemasParaAbrir();
    if (problemas.isNotEmpty) {
      throw StateError('No se puede abrir: ${problemas.join(', ')}');
    }
    return copiarCon(abierto: true);
  }

  /// Cambiar las reglas solo vale en borrador.
  Asunto conReglas(ReglasDecision nuevas) {
    if (!puedeCambiarReglas) {
      throw StateError('Las reglas de un asunto abierto no se cambian');
    }
    return copiarCon(reglas: nuevas);
  }

  Asunto copiarCon({ReglasDecision? reglas, bool? abierto}) => Asunto(
        uid: uid,
        titulo: titulo,
        resumen: resumen,
        texto: texto,
        tipoDecision: tipoDecision,
        compromisoPrevio: compromisoPrevio,
        costeEuros: costeEuros,
        efectoEntorno: efectoEntorno,
        reglas: reglas ?? this.reglas,
        inicioDebate: inicioDebate,
        inicioDecision: inicioDecision,
        finDecision: finDecision,
        creadoPorUid: creadoPorUid,
        abierto: abierto ?? this.abierto,
      );
}

enum ProblemaAsunto {
  faltaTitulo,
  faltaResumen,
  faltaEfectoEntorno,
  faltaCompromisoPrevio,
  fechasDesordenadas,
  faltanOpciones,
  opcionesRepetidas,
  faltaBolsa,
  propuestaSinCoste,
  quorumNegativo,
}
