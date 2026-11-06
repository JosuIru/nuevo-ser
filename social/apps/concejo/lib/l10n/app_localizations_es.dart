// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get nombreApp => 'Concejo';

  @override
  String get pestanaAsuntos => 'Asuntos';

  @override
  String get pestanaSeHaHecho => '¿Se ha hecho?';

  @override
  String get faseBorrador => 'En preparación';

  @override
  String get faseDebate => 'En debate';

  @override
  String get faseDecision => 'Se decide ahora';

  @override
  String get faseSeguimiento => 'Decidido';

  @override
  String get sinAsuntos => 'No hay asuntos en esta fase.';

  @override
  String get tipoVinculante => 'Decide el grupo';

  @override
  String get tipoConCompromiso => 'Con compromiso previo';

  @override
  String get tipoConsultiva => 'Consultiva';

  @override
  String get explicaVinculante =>
      'Lo que salga lo decide el propio grupo, según sus normas.';

  @override
  String get explicaConCompromiso =>
      'El órgano formal se ha comprometido antes a ejecutar lo que salga:';

  @override
  String get explicaConsultiva =>
      'Sirve para saber qué piensa la gente. Decide el órgano formal.';

  @override
  String get seccionCalendario => 'Calendario';

  @override
  String calendarioDebate(String fecha) {
    return 'Debate: desde el $fecha';
  }

  @override
  String calendarioDecision(String desde, String hasta) {
    return 'Decisión: del $desde al $hasta';
  }

  @override
  String get seccionComoSeDecide => 'Cómo se decide';

  @override
  String get formaVotacion => 'Votación: sí, no o abstención';

  @override
  String get formaEleccion =>
      'Elegir entre opciones: marca todas las que aceptas';

  @override
  String get formaConsentimiento =>
      'Consentimiento: se aprueba si nadie plantea una objeción razonada';

  @override
  String get formaPresupuesto =>
      'Presupuesto: apoya las propuestas que quieras; entran por apoyos mientras haya dinero';

  @override
  String get mayoriaSimple => 'Mayoría simple (más síes que noes)';

  @override
  String get mayoriaAbsoluta =>
      'Mayoría absoluta (más de la mitad de los votos)';

  @override
  String get mayoriaDosTercios => 'Dos tercios de los síes y noes';

  @override
  String quorum(int cantidad) {
    return 'Hace falta que participen al menos $cantidad personas';
  }

  @override
  String get sinQuorumRegla => 'Sin mínimo de participación';

  @override
  String get votoSecreto => 'Voto secreto';

  @override
  String get votoNominal => 'Voto a la vista (se sabe quién vota qué)';

  @override
  String get reglasFijas =>
      'Estas reglas se fijaron antes de abrir y no se pueden cambiar.';

  @override
  String get seccionEntorno => 'Efecto sobre el entorno';

  @override
  String get seccionCoste => 'Coste';

  @override
  String get verTextoCompleto => 'Texto completo';

  @override
  String get pestanaInformacion => 'Información';

  @override
  String get pestanaDebate => 'Debate';

  @override
  String get pestanaDecidir => 'Decidir';

  @override
  String get pestanaResultado => 'Resultado';

  @override
  String get columnaAFavor => 'A favor';

  @override
  String get columnaEnContra => 'En contra';

  @override
  String get columnaDudas => 'Dudas';

  @override
  String get columnaCambios => 'Propuestas de cambio';

  @override
  String get columnaVacia => 'Nadie ha escrito aquí todavía.';

  @override
  String get vecinaAnonima => 'Vecina del pueblo';

  @override
  String get aportar => 'Aportar';

  @override
  String get responder => 'Responder';

  @override
  String get tuAportacion => 'Lo que quieres decir';

  @override
  String get tipoDeAportacion => '¿Qué es?';

  @override
  String get aportarAnonima =>
      'Sin mi nombre (lo verá la mesa antes de publicarlo)';

  @override
  String get publicar => 'Publicar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get debateCerrado => 'El debate está cerrado.';

  @override
  String get pendienteMesa =>
      'Tu aportación sin nombre espera a que la vea la mesa.';

  @override
  String decisionAunNo(String fecha) {
    return 'La decisión se abre el $fecha. Mientras, puedes participar en el debate.';
  }

  @override
  String get yaHasVotado => 'Ya has participado. Gracias.';

  @override
  String get votoSi => 'Sí';

  @override
  String get votoNo => 'No';

  @override
  String get votoAbstencion => 'Abstención';

  @override
  String get enviarVoto => 'Enviar mi voto';

  @override
  String get confirmarVoto => '¿Envías tu voto? Después no se puede cambiar.';

  @override
  String get enviar => 'Enviar';

  @override
  String bolsaRestante(String gastado, String bolsa) {
    return 'Has elegido $gastado de $bolsa. Lo que no quepa no entrará.';
  }

  @override
  String get votoEnBlanco => 'Si no marcas nada, cuenta como voto en blanco.';

  @override
  String rondaConsentimiento(int ronda, int maximo) {
    return 'Vuelta $ronda de $maximo';
  }

  @override
  String get sinObjeciones => 'Por ahora nadie ha planteado objeciones.';

  @override
  String get objecionesVivas => 'Objeciones por resolver';

  @override
  String get objetar => 'Plantear una objeción';

  @override
  String get queDanoCausa => '¿Qué daño causaría la propuesta?';

  @override
  String get objetarNoEsContra =>
      'Objetar no es estar en contra: explica qué daño causaría y, si puedes, cómo evitarlo.';

  @override
  String get resultadoAprobada => 'Aprobada';

  @override
  String get resultadoRechazada => 'Rechazada';

  @override
  String get resultadoSinQuorum =>
      'No vale: no se llegó al mínimo de participación';

  @override
  String resultadoParticipacion(int cantidad) {
    return 'Han participado $cantidad personas';
  }

  @override
  String get resultadoEmpate =>
      'Empate: lo resolverá la mesa o una segunda vuelta';

  @override
  String get resultadoGanadora => 'Más aceptada';

  @override
  String get presupuestoEntra => 'Entra';

  @override
  String get presupuestoNoCabe => 'No cabe';

  @override
  String get presupuestoSinApoyos => 'Sin apoyos';

  @override
  String apoyos(int cantidad) {
    return '$cantidad apoyos';
  }

  @override
  String sobrante(String cantidad) {
    return 'Sobran $cantidad';
  }

  @override
  String get recuentoEnCurso => 'El recuento se verá al cerrar la decisión.';

  @override
  String get seccionCompromisos => 'Compromisos';

  @override
  String get sinCompromisos => 'Todavía no hay compromisos apuntados.';

  @override
  String get compromisoPendiente => 'Pendiente';

  @override
  String get compromisoEnMarcha => 'En marcha';

  @override
  String get compromisoHecho => 'Hecho';

  @override
  String get compromisoNoSeHara => 'No se hará';

  @override
  String get compromisoVencido => 'Fuera de plazo';

  @override
  String compromisoPara(String responsable, String fecha) {
    return '$responsable · para el $fecha';
  }

  @override
  String balanceCompromisos(int hechos, int total, int vencidos) {
    return '$hechos hechos de $total · $vencidos fuera de plazo';
  }

  @override
  String get marcarHecho => 'Marcar como hecho';

  @override
  String get marcarEnMarcha => 'Marcar en marcha';

  @override
  String deAsunto(String titulo) {
    return 'De: $titulo';
  }

  @override
  String get ejemploAviso =>
      'Pueblo de ejemplo: los datos solo están en este dispositivo.';

  @override
  String eresMesa(String fecha) {
    return 'Estás en la mesa hasta el $fecha';
  }
}
