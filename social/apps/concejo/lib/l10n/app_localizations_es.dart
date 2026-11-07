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
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Hace falta que participen al menos $cantidad personas',
      one: 'Hace falta que participe al menos 1 persona',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Han participado $cantidad personas',
      one: 'Ha participado 1 persona',
    );
    return '$_temp0';
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
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad apoyos',
      one: '1 apoyo',
    );
    return '$_temp0';
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

  @override
  String get nuevoAsunto => 'Nuevo asunto';

  @override
  String get editarAsunto => 'Editar asunto';

  @override
  String get campoTitulo => 'Título';

  @override
  String get campoResumen => 'Resumen en tres líneas';

  @override
  String get ayudaResumen => 'Lo primero que se lee. Frases cortas, sin jerga.';

  @override
  String get campoTexto => 'Texto completo (opcional)';

  @override
  String get campoTipoDecision => '¿Qué valor tiene lo que salga?';

  @override
  String get campoCompromiso => 'Compromiso previo';

  @override
  String get campoCoste => 'Coste (€, opcional)';

  @override
  String get campoEntorno => 'Efecto sobre el entorno';

  @override
  String get campoInicioDebate => 'Empieza el debate';

  @override
  String get campoInicioDecision => 'Empieza la decisión';

  @override
  String get campoFinDecision => 'Acaba la decisión';

  @override
  String get campoForma => 'Cómo se decide';

  @override
  String get nombreVotacion => 'Votación';

  @override
  String get nombreEleccion => 'Elegir entre opciones';

  @override
  String get nombreConsentimiento => 'Consentimiento';

  @override
  String get nombrePresupuesto => 'Presupuesto';

  @override
  String get campoMayoria => 'Mayoría';

  @override
  String get campoQuorum => 'Mínimo de participación';

  @override
  String get campoSecreto => 'Voto secreto';

  @override
  String get campoBolsa => 'Dinero disponible (€)';

  @override
  String get campoRondas =>
      'Vueltas antes de llevarlo a votación o a la asamblea';

  @override
  String get opciones => 'Opciones';

  @override
  String get propuestas => 'Propuestas';

  @override
  String get anadirOpcion => 'Añadir';

  @override
  String get textoOpcion => 'Texto';

  @override
  String get costeOpcion => 'Coste €';

  @override
  String get guardarBorrador => 'Guardar borrador';

  @override
  String get abrirAsunto => 'Abrir el asunto';

  @override
  String get confirmarAbrir =>
      'Al abrirlo, todo el mundo lo verá y las reglas de decisión ya no se podrán cambiar. ¿Lo abres?';

  @override
  String get abrir => 'Abrir';

  @override
  String get borrarBorrador => 'Borrar borrador';

  @override
  String get confirmarBorrar => '¿Borras este borrador?';

  @override
  String get borrar => 'Borrar';

  @override
  String get editar => 'Editar';

  @override
  String get guardar => 'Guardar';

  @override
  String get faltaParaAbrir => 'Falta para poder abrirlo:';

  @override
  String get problemaTitulo => 'el título';

  @override
  String get problemaResumen => 'el resumen';

  @override
  String get problemaEntorno => 'el efecto sobre el entorno';

  @override
  String get problemaCompromiso => 'el texto del compromiso previo';

  @override
  String get problemaFechas =>
      'que las fechas vayan en orden (debate, decisión, fin)';

  @override
  String get problemaOpciones => 'al menos dos opciones (o una propuesta)';

  @override
  String get problemaRepetidas => 'que no haya opciones repetidas';

  @override
  String get problemaBolsa => 'el dinero disponible';

  @override
  String get problemaSinCoste => 'el coste de cada propuesta';

  @override
  String get problemaQuorum => 'un mínimo de participación que no sea negativo';

  @override
  String get verComo => 'Ver como…';

  @override
  String get rolMesa => 'mesa';

  @override
  String get rolVecina => 'vecina';

  @override
  String get pendienteModeracion => 'Sin nombre · espera a la mesa';

  @override
  String get publicarAportacion => 'Publicar';

  @override
  String get retirarAportacion => 'Retirar';

  @override
  String get motivoRetirada => '¿Por qué se retira? Quedará a la vista.';

  @override
  String retiradaPorMesa(String motivo) {
    return 'Retirada por la mesa: $motivo';
  }

  @override
  String get escribirResumen => 'Escribir el resumen del debate';

  @override
  String get resumenDebate => 'Resumen del debate (mesa)';

  @override
  String get integrarObjecion => 'Integrar';

  @override
  String get noEsObjecion => 'No es objeción';

  @override
  String get comoSeIntegra => '¿Cómo se cambia la propuesta para resolverla?';

  @override
  String get porQueNoEsObjecion =>
      '¿Por qué no razona un daño? Quedará en el acta.';

  @override
  String get retirarMiObjecion => 'Retirar mi objeción';

  @override
  String cerrarVuelta(int ronda) {
    return 'Cerrar la vuelta $ronda';
  }

  @override
  String get confirmarCerrarVuelta =>
      'Si no quedan objeciones vivas, la propuesta queda aprobada. Si quedan, empieza otra vuelta o pasa a votación o asamblea. ¿Cierras la vuelta?';

  @override
  String get cerrar => 'Cerrar';

  @override
  String get consentimientoAprobado =>
      'Aprobada por consentimiento: nadie mantiene una objeción.';

  @override
  String get consentimientoPasa =>
      'Quedan objeciones sin resolver: pasa a votación o a la asamblea en persona.';

  @override
  String get objecionesResueltas => 'Objeciones resueltas';

  @override
  String get estadoIntegrada => 'Integrada';

  @override
  String get estadoRetirada => 'Retirada';

  @override
  String get estadoNoEsObjecion => 'No era objeción';

  @override
  String get apuntarCompromiso => 'Apuntar compromiso';

  @override
  String get campoQue => 'Qué se hará';

  @override
  String get campoResponsable => 'Quién';

  @override
  String get campoFechaLimite => 'Para cuándo';

  @override
  String get marcarNoSeHara => 'No se hará…';

  @override
  String get porQueNoSeHara =>
      '¿Por qué no se hará? También es información para el pueblo.';

  @override
  String get ayudaEntorno =>
      'Agua, monte, ruido, paisaje, animales… Si no tiene, escribe «ninguno».';

  @override
  String get ayudaQuorum =>
      'Personas que tienen que participar para que valga (0 = sin mínimo)';

  @override
  String get ayudaCompromiso =>
      'Quién se compromete a qué y en qué condiciones';

  @override
  String get ayudaResponsable => 'Persona, comisión, «la junta»…';

  @override
  String get pdfHojaAsunto => 'Hoja del asunto';

  @override
  String get pdfPapeletas => 'Papeletas';

  @override
  String get pdfHojaRecuento => 'Hoja de recuento';

  @override
  String get pdfComoParticipar => 'Cómo participar';

  @override
  String get pdfParticiparTexto =>
      'En la app o en papel: pide la papeleta a la mesa y entrégala dentro del plazo. Cada persona vota una sola vez.';

  @override
  String get pdfMarcaUna => 'Marca una sola casilla.';

  @override
  String get pdfMarcaVarias => 'Marca todas las opciones que aceptes.';

  @override
  String pdfMarcaPropuestas(String bolsa) {
    return 'Marca las propuestas que apoyas. Hay $bolsa: entran por apoyos mientras quepan.';
  }

  @override
  String get pdfPapeletaSecreta =>
      'Voto secreto: no escribas tu nombre. Dobla la papeleta.';

  @override
  String get pdfPapeletaNominal => 'Voto a la vista: escribe tu nombre.';

  @override
  String get pdfNombre => 'Nombre';

  @override
  String get pdfHojaObjeciones => 'Objeciones';

  @override
  String get pdfObjecionesTexto =>
      'Si la propuesta causaría algún daño, explícalo aquí. Objetar no es estar en contra: di qué daño y, si puedes, cómo evitarlo.';

  @override
  String get pdfDanoYComoEvitarlo => 'Qué daño causaría y cómo evitarlo';

  @override
  String get pdfRecuentoTexto =>
      'Para la mesa: cuenta las papeletas en papel entre dos personas y pasa las cifras a la app.';

  @override
  String get pdfOpcion => 'Opción';

  @override
  String get pdfMarcas => 'Marcas';

  @override
  String get pdfPapeletasTotales => 'Papeletas en total';

  @override
  String get pdfEnBlanco => 'De ellas, en blanco';

  @override
  String get pdfPersonasAnotadas =>
      'Personas anotadas como votantes en persona';

  @override
  String get pdfFirma => 'Firma';

  @override
  String get pdfFecha => 'Fecha';

  @override
  String get pdfRecorta => 'Recorta por la línea';

  @override
  String get imprimir => 'Imprimir o compartir';

  @override
  String get votosEnPersona => 'Votos en persona';

  @override
  String get votosEnPersonaTexto =>
      'Apunta a cada persona cuando te entregue su papeleta: así nadie vota dos veces ni en papel ni en la app. Al cerrar, contad las papeletas entre dos y pasad las cifras.';

  @override
  String get buscarPersona => 'Buscar por nombre';

  @override
  String get haVotadoEnPersona => 'Ha votado en persona';

  @override
  String get anotar => 'Anotar';

  @override
  String get darDeAlta => 'No está en la lista: darla de alta';

  @override
  String get nombreNuevaPersona => 'Nombre de la persona';

  @override
  String anotadasEnPersona(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad personas anotadas en persona',
      one: '1 persona anotada en persona',
    );
    return '$_temp0';
  }

  @override
  String get pasarConteo => 'Pasar el conteo de las papeletas';

  @override
  String conteosRegistrados(int papeletas) {
    String _temp0 = intl.Intl.pluralLogic(
      papeletas,
      locale: localeName,
      other: 'Conteos registrados: $papeletas papeletas',
      one: 'Conteos registrados: 1 papeleta',
    );
    return '$_temp0';
  }

  @override
  String get segundaFirma => 'Segunda firma (otra persona de la mesa)';

  @override
  String get registrarConteo => 'Registrar el conteo';

  @override
  String get avisoPapeletasNoCuadran =>
      'Las papeletas contadas en papel no cuadran con las personas anotadas. Revisadlo antes del acta.';

  @override
  String get sinOtraMesa =>
      'Hace falta otra persona de la mesa para firmar el conteo.';

  @override
  String get aportarEnNombreDe => 'Recoger lo que dijo alguien en persona';

  @override
  String get objetarEnNombreDe => 'Recoger una objeción hecha en persona';

  @override
  String get quienLoDijo => '¿Quién lo dijo?';

  @override
  String get pdfActa => 'Acta';

  @override
  String get pdfMarcaBorrador => 'BORRADOR';

  @override
  String get pdfActaBorradorAviso =>
      'Borrador: aún no vale como acta. Falta que la firmen dos personas de la mesa.';

  @override
  String get pdfParticipacion => 'Participación';

  @override
  String pdfParticipacionDetalle(int total, int app, int papel) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Han participado $total personas',
      one: 'Ha participado 1 persona',
    );
    return '$_temp0: $app en la app y $papel en persona.';
  }

  @override
  String get pdfQuorumAlcanzado => 'Se ha llegado al quórum.';

  @override
  String get pdfQuorumNoAlcanzado => 'No se ha llegado al quórum.';

  @override
  String get pdfResultado => 'Resultado';

  @override
  String get pdfEnLaApp => 'En la app';

  @override
  String get pdfEnPapel => 'En papel';

  @override
  String get pdfTotal => 'Total';

  @override
  String pdfConteoFirmado(int papeletas, String firmas) {
    String _temp0 = intl.Intl.pluralLogic(
      papeletas,
      locale: localeName,
      other: 'Conteo en papel de $papeletas papeletas, firmado por $firmas.',
      one: 'Conteo en papel de 1 papeleta, firmado por $firmas.',
    );
    return '$_temp0';
  }

  @override
  String get pdfObjeciones => 'Objeciones';

  @override
  String pdfRespuestaMesa(String respuesta) {
    return 'Respuesta: $respuesta';
  }

  @override
  String get estadoViva => 'Sin resolver';

  @override
  String get pdfDebate => 'Debate';

  @override
  String get pdfSinResumen => 'La mesa no ha escrito un resumen del debate.';

  @override
  String get pdfFirmas => 'Firmas de la mesa';

  @override
  String pdfFirmadaPor(String nombre, String fecha) {
    return '$nombre, el $fecha';
  }

  @override
  String get pdfFaltaFirma => 'Falta esta firma';

  @override
  String pdfGenerada(String fecha) {
    return 'Generada el $fecha con Concejo.';
  }

  @override
  String pdfCompromisoLinea(String responsable, String fecha) {
    return '$responsable, para el $fecha';
  }

  @override
  String get seccionActa => 'Acta';

  @override
  String get actaNoLista => 'El acta se firma cuando el asunto está decidido.';

  @override
  String actaBorrador(int firmadas) {
    String _temp0 = intl.Intl.pluralLogic(
      firmadas,
      locale: localeName,
      other: 'Borrador: tiene $firmadas de las 2 firmas de la mesa',
      one: 'Borrador: tiene 1 de las 2 firmas de la mesa',
      zero: 'Borrador: sin firmas de la mesa',
    );
    return '$_temp0';
  }

  @override
  String actaDefinitiva(String primera, String segunda) {
    return 'Acta firmada por $primera y $segunda.';
  }

  @override
  String get actaConFirmasAviso =>
      'El acta ya tiene una firma: para corregir el resultado, retírala primero.';

  @override
  String get firmarActa => 'Firmar el acta';

  @override
  String get confirmarFirmarActa =>
      'Al firmar, el resultado, los conteos y el resumen del debate quedan fijos. ¿Lo has revisado en el PDF?';

  @override
  String get firmar => 'Firmar';

  @override
  String get retirarFirma => 'Retirar mi firma';

  @override
  String get descargarActa => 'Descargar el acta';

  @override
  String get entrarTitulo => 'Entra en tu concejo';

  @override
  String get entrarTexto =>
      'La mesa te ha dado en papel la dirección de tu pueblo y tu código personal.';

  @override
  String get campoDireccion => 'Dirección del pueblo';

  @override
  String get campoCodigo => 'Tu código';

  @override
  String get entrar => 'Entrar';

  @override
  String get verEjemplo => 'Ver el pueblo de ejemplo';

  @override
  String get errorCodigo =>
      'Ese código no vale. Revísalo o pide otro a la mesa.';

  @override
  String get errorConexion =>
      'No se llega al servidor. Revisa la dirección y la conexión.';

  @override
  String get sinConexionAviso =>
      'Sin conexión: lo que hagas se guarda y se enviará después.';

  @override
  String pendientesAviso(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad cambios por enviar',
      one: '1 cambio por enviar',
    );
    return '$_temp0';
  }

  @override
  String get codigoCaducadoAviso =>
      'Tu código ya no vale: pide otro a la mesa.';

  @override
  String rechazadasAviso(int cantidad, String motivo) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad cambios no se han podido guardar. El último: $motivo',
      one: 'Un cambio no se ha podido guardar: $motivo',
    );
    return '$_temp0';
  }

  @override
  String get entendido => 'Entendido';

  @override
  String get sincronizarAhora => 'Actualizar';

  @override
  String get salir => 'Salir';

  @override
  String get confirmarSalir =>
      'Al salir se borra lo guardado en este teléfono, también lo que aún no se haya enviado. ¿Salir?';

  @override
  String get pdfHojaCodigo => 'Tu código para Concejo';

  @override
  String pdfHolaPersona(String nombre) {
    return 'Hola, $nombre:';
  }

  @override
  String get pdfCodigoTexto =>
      'Con la app Concejo puedes seguir los asuntos del pueblo, opinar y votar desde casa. Para entrar, escribe estos dos datos:';

  @override
  String get pdfCodigoGuardalo =>
      'Este código es solo tuyo: no lo compartas. Si lo pierdes, pide otro a la mesa y este dejará de valer. Si prefieres el papel, puedes seguir participando como siempre.';

  @override
  String get personas => 'Personas';

  @override
  String get sacarCodigo => 'Sacar código';

  @override
  String confirmarSacarCodigo(String nombre) {
    return 'Se hará un código nuevo para $nombre. Si tenía otro, deja de valer. ¿Seguir?';
  }

  @override
  String codigoDe(String nombre) {
    return 'Código de $nombre';
  }

  @override
  String get codigoUnaVez =>
      'Imprímelo o apúntalo ahora: no se vuelve a enseñar.';

  @override
  String get imprimirHoja => 'Imprimir la hoja';

  @override
  String get soloConServidor =>
      'Los códigos los da el servidor del pueblo: en el ejemplo no hay.';

  @override
  String get darDeAltaPersona => 'Dar de alta a alguien';

  @override
  String get paraTi => 'Para ti';

  @override
  String get quitarAviso => 'Quitar aviso';

  @override
  String avisoAsuntoNuevo(String titulo, String fecha) {
    return 'Asunto nuevo: «$titulo». Se debate hasta el $fecha.';
  }

  @override
  String avisoUltimosDias(String titulo, String fecha) {
    return 'Quedan pocos días para decidir «$titulo»: cierra el $fecha.';
  }

  @override
  String avisoResultado(String titulo) {
    return 'Ya hay resultado: «$titulo».';
  }

  @override
  String avisoCompromisoVence(String que, String fecha) {
    return 'Compromiso para el $fecha: $que.';
  }

  @override
  String avisoCompromisoVencido(String que, String fecha) {
    return 'Compromiso que venció el $fecha: $que.';
  }

  @override
  String avisoMandatoAcaba(String fecha) {
    return 'Tu cargo en la mesa acaba el $fecha. Toca hablar de quién sigue.';
  }

  @override
  String get etiquetaNuevo => 'Nuevo';

  @override
  String get etiquetaResultado => 'Hay resultado';
}
