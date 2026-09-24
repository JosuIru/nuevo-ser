// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'textos_app.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class TextosAppEs extends TextosApp {
  TextosAppEs([String locale = 'es']) : super(locale);

  @override
  String get tituloApp => 'El Cuaderno';

  @override
  String get subtituloBienvenida =>
      'Una herramienta para anotar lo que ves vivo cerca de ti.';

  @override
  String get saludoSinNombre => 'Hola.';

  @override
  String saludoConNombre(String nombre) {
    return 'Hola, $nombre.';
  }

  @override
  String get navCuaderno => 'cuaderno';

  @override
  String get navMapa => 'mapa';

  @override
  String get navMisterios => 'misterios';

  @override
  String get navTutor => 'tutor';

  @override
  String get seccionSitSpot => 'Tu sit spot';

  @override
  String get seccionMisteriosAbiertos => 'Misterios abiertos';

  @override
  String get seccionUltimaPagina => 'Última página';

  @override
  String get sitSpotInvitacion =>
      'Cuando estés en algún sitio al aire libre que te guste — un parque, un árbol, una esquina — puedes hacerlo tu sit spot. Toca aquí cuando estés.';

  @override
  String sitSpotUltimaVisita(String cuando) {
    return 'Última visita: $cuando';
  }

  @override
  String get ultimaPaginaVacia =>
      'Aún no has anotado nada. Cuando lo hagas, aparecerá aquí.';

  @override
  String get misteriosVacio =>
      'Aún no tienes Misterios abiertos. El sistema te propondrá alguno pronto.';

  @override
  String get misteriosFueraDeContexto =>
      'Hoy no hay Misterios para tu lugar y esta estación. Vuelve a mirar al cambiar el tiempo.';

  @override
  String get navProximamente => 'Próximamente.';

  @override
  String get homeFabAnotar => 'anotar';

  @override
  String get homeFabAnotarTooltip => 'anotar lo que ves';

  @override
  String get homeOrientacionConMisterios =>
      'Estos son los Misterios que tu cuaderno tiene abiertos. Ábrelos para leerlos; cuando veas algo en tu sit spot que tenga que ver, anótalo.';

  @override
  String get seccionTusPreguntas => 'Tus preguntas';

  @override
  String get seccionMisteriosDelCuaderno => 'Misterios del cuaderno';

  @override
  String get tusPreguntasVacio =>
      'Aún no has formulado ninguna pregunta. Cuando se te ocurra una mientras observas tu lugar, anótala aquí.';

  @override
  String get preguntaFabFormular => 'formular pregunta';

  @override
  String get preguntaFormularTitulo => 'Tu pregunta';

  @override
  String get preguntaFormularIntro =>
      'Una pregunta tuya. La que llevas dándole vueltas, la que se te acaba de ocurrir, la que nadie te ha contado. Escríbela como te suene; no hace falta que esté bien hecha — sólo que sea la tuya.';

  @override
  String get preguntaFormularPlaceholder => '¿…?';

  @override
  String get preguntaFormularBotonGuardar => 'Guardar mi pregunta';

  @override
  String get preguntaFormularBotonIdeas => 'necesito ideas';

  @override
  String get preguntaIdeasTitulo => 'Si necesitas un punto de partida';

  @override
  String get preguntaIdeasIntro =>
      'No tienes que usar ninguno. Si te ayuda alguno, púlsalo y empieza desde ahí.';

  @override
  String get preguntaIdea1 => '¿siempre … cuando …?';

  @override
  String get preguntaIdea2 => '¿qué pasa cuando …?';

  @override
  String get preguntaIdea3 => '¿se parece … a …?';

  @override
  String get preguntaIdea4 => '¿cómo cambia … con el tiempo?';

  @override
  String get preguntaIdea5 => '¿qué hace … cuando …?';

  @override
  String get preguntaPaginaTitulo => 'Tu pregunta';

  @override
  String preguntaPaginaFormulada(String fecha) {
    return 'Formulada el $fecha';
  }

  @override
  String get preguntaPaginaEvidenciaVacia =>
      'Todavía no has anotado nada para tu pregunta. Vuelve al lugar y mira; cuando veas algo que tenga que ver, anótalo y ánclalo aquí.';

  @override
  String get preguntaPaginaCabeceraEvidencia => 'Lo que ya has anotado';

  @override
  String get preguntaPaginaBorrar => 'borrar esta pregunta';

  @override
  String get preguntaPaginaConfirmaBorrar =>
      'Vas a borrar esta pregunta tuya. Las observaciones que tuvieras ancladas se conservan en el cuaderno. No se puede deshacer.';

  @override
  String get preguntaPaginaBotonEvidencia =>
      'anotar evidencia para esta pregunta';

  @override
  String get preguntaPaginaBotonCerrar =>
      'ya tengo mi respuesta sobre esta pregunta';

  @override
  String get preguntaCerrarTitulo => 'Tu respuesta';

  @override
  String get preguntaCerrarIntro =>
      'Cuenta con tus palabras lo que has aprendido. No hay respuesta correcta — esto no se corrige ni se nota; sólo se guarda en tu cuaderno.';

  @override
  String get preguntaCerrarPlaceholder => 'tu respuesta';

  @override
  String get preguntaCerrarBoton => 'Guardar mi respuesta';

  @override
  String get preguntaPaginaBloqueRespuesta => 'Tu respuesta';

  @override
  String preguntaPaginaCerradaEl(String fecha) {
    return 'Cerrada el $fecha';
  }

  @override
  String get preguntaPaginaReabrir => 'reabrir esta pregunta';

  @override
  String get preguntaPaginaConfirmaReabrir =>
      'Si la reabres, tu respuesta se borra y la pregunta vuelve a la lista de abiertas. Las anotaciones que ya tenías se conservan.';

  @override
  String get observacionTitulo => 'nueva observación';

  @override
  String observacionCabecera(String hora) {
    return 'Hoy · $hora';
  }

  @override
  String get observacionCajaFoto => 'foto';

  @override
  String get observacionCajaDibujo => 'dibujo';

  @override
  String get observacionCajaPlaceholder =>
      'Si quieres, añade una foto o un dibujo.';

  @override
  String get observacionFotoTomar => 'tomar foto';

  @override
  String get observacionFotoElegir => 'elegir foto';

  @override
  String get observacionFotoQuitar => 'quitar foto';

  @override
  String get observacionDibujoComenzar => 'hacer dibujo';

  @override
  String get observacionDibujoQuitar => 'quitar dibujo';

  @override
  String get observacionEtiquetaQueViste => 'qué viste';

  @override
  String get observacionPlaceholderQueViste =>
      'describe lo que has visto, sin nombrarlo si no estás segura';

  @override
  String get observacionEtiquetaCreesQueEs => 'crees que es';

  @override
  String get observacionPlaceholderCreesQueEs => 'si quieres, propón un nombre';

  @override
  String get confianzaConsenso => 'consenso';

  @override
  String get confianzaHipotesisActiva => 'hipótesis activa';

  @override
  String get confianzaNoSegura => 'no estoy segura';

  @override
  String get confianzaConsensoTooltip =>
      'lo has confirmado con una clave o con el Tutor';

  @override
  String get confianzaNoSeguraTooltip => 'no pasa nada, anótalo así';

  @override
  String get observacionAvisoFalta => 'haz una nota antes de guardar';

  @override
  String get observacionBotonGuardar => 'Guardar en el cuaderno';

  @override
  String get tutorSaludoCanonico =>
      'Soy el Tutor del Cuaderno. Pregúntame lo que necesites.';

  @override
  String get tutorPlaceholderInput => 'escribe tu pregunta';

  @override
  String get tutorBotonEnviar => 'Enviar';

  @override
  String get tutorRespuestaCanned =>
      'El Tutor todavía no está conectado. Vuelve en unas semanas.';

  @override
  String get tutorErrorRed =>
      'Ahora mismo no llego al cuaderno. Espera un momento y vuelve a probar.';

  @override
  String get ajustesTitulo => 'Ajustes';

  @override
  String get atlasTitulo => 'Tu atlas';

  @override
  String get atlasSubtitulo => 'no es un trofeo. es lo que has visto.';

  @override
  String get atlasSeccionPrimerasVeces => 'Tus primeras veces';

  @override
  String get atlasSeccionLoQueHasVisto => 'Lo que has visto';

  @override
  String get atlasConteoSingular => '1 vez';

  @override
  String atlasConteoPlural(int conteo) {
    return '$conteo veces';
  }

  @override
  String get atlasVacioCabecera => 'Tu atlas todavía está vacío.';

  @override
  String get atlasVacioCuerpo =>
      'Cuando vayas anotando lo que crees que ves, esto se irá llenando solo. No hay prisa.';

  @override
  String get atlasEnlaceDesdeCuaderno => 'ver tu atlas';

  @override
  String get seccionEcos => 'Hace un tiempo, por aquí';

  @override
  String get ecoCabeceraUnMes => 'hace un mes, por estas fechas…';

  @override
  String get ecoCabeceraSeisMeses => 'hace seis meses, por estas fechas…';

  @override
  String get ecoCabeceraUnAno => 'hace un año, por estas fechas…';

  @override
  String get paginaSitSpotResumenMesCabecera => 'Este mes aquí';

  @override
  String paginaSitSpotResumenMesVisitas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Has venido $count veces este mes.',
      two: 'Has venido dos veces este mes.',
      one: 'Has venido una vez este mes.',
    );
    return '$_temp0';
  }

  @override
  String paginaSitSpotResumenMesPrimeraUltima(String primera, String ultima) {
    return 'La primera fue el $primera. La última, el $ultima.';
  }

  @override
  String get lecturaTitulo => 'Leer tus páginas';

  @override
  String get lecturaTooltip => 'leer tus páginas';

  @override
  String lecturaPaginaIndicador(int pagina, int total) {
    return '$pagina de $total';
  }

  @override
  String get lecturaVacioCuerpo =>
      'Aún no has anotado nada. Cuando lo hagas, podrás abrir tu cuaderno como un libro.';

  @override
  String get ajustesMapaOnlineEtiqueta => 'Activar el mapa';

  @override
  String get ajustesMapaOnlineCuerpo =>
      'Si lo activas, el dispositivo se conectará a internet para mostrar la zona del mundo donde estés. La pestaña \"mapa\" sólo funciona con esto encendido. Más adelante el mapa podrá descargarse una vez y dejará de salir a internet.';

  @override
  String get detalleCompartirFotoOpcion => 'compartir foto a tu adulto';

  @override
  String get detalleCompartirFotoTextoAdjunto =>
      'Mira lo que he visto en mi cuaderno. ¿Sabes qué es?';

  @override
  String get compararVisitasTitulo => 'Comparar dos visitas';

  @override
  String get compararVisitasEnlace => 'comparar dos visitas';

  @override
  String get compararVisitasIntro => 'elige dos momentos. mira qué cambia.';

  @override
  String get compararVisitasColumnaIzquierda => 'primer momento';

  @override
  String get compararVisitasColumnaDerecha => 'segundo momento';

  @override
  String get compararVisitasInsuficientesCabecera =>
      'Necesitas dos visitas para comparar.';

  @override
  String get compararVisitasInsuficientesCuerpo =>
      'Cuando vuelvas a tu sit spot otro día y anotes algo, podrás comparar lo que viste antes con lo que ves ahora.';

  @override
  String get imprimirPlantillaBloque =>
      'Imprimir páginas en blanco para el campo';

  @override
  String get imprimirPlantillaBloqueDescripcion =>
      'Genera un PDF para llevar el cuaderno en papel a una salida. Sin pantallas, sin pilas.';

  @override
  String get imprimirPlantillaTitulo => 'Páginas para el campo';

  @override
  String get imprimirPlantillaIntro =>
      'A veces el campo se mira mejor sin pantalla. Aquí preparas tu cuaderno en papel para llevarlo en la mochila.';

  @override
  String get imprimirPlantillaContenido =>
      'Cada página tiene espacio para la fecha, dónde estabas, qué viste, lo que crees que es y un recuadro grande para dibujar.';

  @override
  String get imprimirPlantillaSelectorCabecera => 'Cuántas páginas';

  @override
  String imprimirPlantillaOpcionPaginas(int paginas) {
    return '$paginas páginas';
  }

  @override
  String get imprimirPlantillaBoton => 'Imprimir o compartir';

  @override
  String get imprimirPlantillaNotaFinal =>
      'Si no tienes impresora, también puedes guardar el PDF en el móvil y enseñárselo a quien sí la tenga.';

  @override
  String get detalleObservacionPrimeraVez =>
      'primera vez que anotas algo así en el cuaderno.';

  @override
  String get acercaTitulo => 'Cómo se usa este cuaderno';

  @override
  String get acercaBloque => 'Cómo se usa este cuaderno';

  @override
  String get acercaBloqueDescripcion =>
      'Qué es, cómo anotar, cómo acompañar. Para ti, para tu adulto y para tu maestra.';

  @override
  String ajustesIdiomaActual(String idioma) {
    return 'Idioma del cuaderno: $idioma';
  }

  @override
  String get ajustesIdiomaCambiar => 'Cambiar idioma';

  @override
  String get ajustesExportar => 'Exportar mi cuaderno';

  @override
  String get ajustesExportarDescripcion =>
      'Recibe una copia legible de tus observaciones y Misterios. El cuaderno es tuyo.';

  @override
  String get ajustesExportarPdf => 'Exportar como PDF';

  @override
  String get ajustesExportarPdfDescripcion =>
      'Una copia para imprimir o llevar a un papel. El sistema te preguntará dónde guardarla.';

  @override
  String get ajustesExportarDialogoTitulo => 'Tu cuaderno como texto';

  @override
  String get ajustesExportarDialogoCerrar => 'Cerrar';

  @override
  String get ajustesVistaCuidador => 'Vista del cuidador';

  @override
  String get ajustesVistaCuidadorDescripcion =>
      'Una página discreta para una persona adulta que te acompaña.';

  @override
  String get ajustesBorrar => 'Borrar mi cuaderno';

  @override
  String get ajustesBorrarDescripcion =>
      'Borrar todas tus observaciones, Misterios y sit spot. No se puede deshacer.';

  @override
  String get ajustesBorrarDialogoTitulo => '¿Borrar todo?';

  @override
  String ajustesBorrarDialogoCuerpo(
      int observaciones, int misterios, int sitSpots) {
    return 'Si continúas, se borrarán $observaciones observaciones, $misterios Misterios y $sitSpots sit spot. No se puede deshacer.';
  }

  @override
  String get ajustesBorrarDialogoSeguir => 'Seguir';

  @override
  String get ajustesBorrarDialogoCancelar => 'Cancelar';

  @override
  String get ajustesBorrarConfirmacionTitulo => '¿Estás segura?';

  @override
  String get ajustesBorrarConfirmacionCuerpo =>
      'Escribe «borrar» abajo para confirmar.';

  @override
  String get ajustesBorrarConfirmacionPalabra => 'borrar';

  @override
  String get ajustesBorrarConfirmacionPlaceholder => 'escribe la palabra';

  @override
  String get ajustesBorrarConfirmacionBoton => 'Borrar todo';

  @override
  String get ajustesBorradoCompleto => 'Listo. Tu cuaderno está vacío.';

  @override
  String get bienvenidaTitulo => '¿Cómo te llamas?';

  @override
  String get bienvenidaCuerpo =>
      'Tu nombre se queda en este cuaderno. No sale al servidor a menos que tú decidas vincularlo más tarde.';

  @override
  String get bienvenidaPlaceholderNombre => 'tu nombre';

  @override
  String get bienvenidaBotonContinuar => 'Continuar';

  @override
  String get ajustesSyncObsTitulo => 'Sincronizar mis observaciones';

  @override
  String get ajustesSyncObsDescripcion =>
      'Sube las observaciones nuevas a tu cuenta del servidor para no perderlas si cambias de dispositivo.';

  @override
  String get ajustesSyncObsBoton => 'Subir ahora';

  @override
  String get ajustesSyncObsEnVuelo => 'Subiendo…';

  @override
  String get ajustesSyncObsSinToken =>
      'Aún no hay cuenta vinculada con el servidor. Cuando la haya, este botón subirá tus observaciones.';

  @override
  String get ajustesSyncObsNadaPendiente =>
      'No hay observaciones pendientes — todo subido.';

  @override
  String ajustesSyncObsTodasEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se han subido $count observaciones.',
      one: 'Se ha subido una observación.',
    );
    return '$_temp0';
  }

  @override
  String ajustesSyncObsParcial(int enviadas, int pendientes) {
    return 'Subidas $enviadas, quedan $pendientes para el siguiente intento.';
  }

  @override
  String ajustesSyncObsRechazadas(int enviadas, int rechazadas) {
    return 'Subidas $enviadas, el servidor ha rechazado $rechazadas. Vuelve a abrirlas para revisarlas.';
  }

  @override
  String get ajustesCuentaTitulo => 'Cuenta del adulto';

  @override
  String get ajustesCuentaDescripcion =>
      'Si tienes una cuenta de Nuevo Ser, puedes vincularla aquí. Sirve para subir tus observaciones, recibir el resumen escrito del cuidador y conectar el Tutor real.';

  @override
  String get ajustesCuentaPlaceholderEmail => 'correo del adulto';

  @override
  String get ajustesCuentaPlaceholderPassword => 'contraseña';

  @override
  String get ajustesCuentaBotonEntrar => 'Iniciar sesión';

  @override
  String get ajustesCuentaEntrando => 'Entrando…';

  @override
  String ajustesCuentaSesionIniciada(String email) {
    return 'Sesión iniciada como $email.';
  }

  @override
  String get ajustesCuentaSesionIniciadaSinEmail => 'Sesión iniciada.';

  @override
  String get ajustesCuentaCerrarSesion => 'Cerrar sesión';

  @override
  String get ajustesCuentaErrorCredenciales =>
      'El correo o la contraseña no coinciden con ninguna cuenta.';

  @override
  String get ajustesCuentaErrorSinPerfil =>
      'La cuenta del adulto no tiene ningún niño asociado todavía.';

  @override
  String get ajustesCuentaErrorRed =>
      'No se ha podido conectar con el servidor. Inténtalo en un momento.';

  @override
  String get ajustesCuentaErrorVacio =>
      'Escribe el correo y la contraseña antes de continuar.';

  @override
  String get ajustesTutorDebugTitulo => 'Tutor (debug)';

  @override
  String get ajustesTutorDebugDescripcion =>
      'Pega aquí un token del backend para activar el Tutor real. Visible sólo en debug.';

  @override
  String get ajustesTutorDebugPlaceholder => 'JWT del backend';

  @override
  String get ajustesTutorDebugBotonGuardar => 'Guardar token';

  @override
  String get ajustesTutorDebugBotonBorrar => 'Borrar token';

  @override
  String get ajustesTutorDebugGuardado =>
      'Token guardado. Vuelve al Tutor para probarlo.';

  @override
  String get ajustesTutorDebugBorrado =>
      'Token borrado. El Tutor vuelve a la respuesta canónica.';

  @override
  String get cuidadorTitulo => 'Página del cuidador';

  @override
  String get cuidadorAviso =>
      'Esta es la única vista que comparte el juego con quien te acompaña. No verá tus observaciones ni lo que escribes — solo este resumen y una pregunta para hablar.';

  @override
  String cuidadorSemanaActual(String isoWeek) {
    return 'Semana $isoWeek';
  }

  @override
  String get cuidadorPreguntaCabecera => 'Una pregunta para la cena';

  @override
  String get cuidadorMetricasCabecera => 'Esta semana';

  @override
  String cuidadorMetricaObservaciones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observaciones',
      one: 'Una observación',
      zero: 'Sin observaciones',
    );
    return '$_temp0';
  }

  @override
  String cuidadorMetricaMisterios(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Misterios',
      one: 'Un Misterio',
      zero: 'Sin Misterios anclados',
    );
    return '$_temp0';
  }

  @override
  String cuidadorMetricaSitSpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visitas al sit spot',
      one: 'Una visita al sit spot',
      zero: 'Sin visitas al sit spot',
    );
    return '$_temp0';
  }

  @override
  String get cuidadorSincronizarBoton => 'Compartir resumen con el adulto';

  @override
  String get cuidadorSincronizarEnVuelo => 'Pidiéndolo…';

  @override
  String get cuidadorSincronizarSinToken =>
      'Aún no hay cuenta vinculada con el servidor. Cuando la haya, este botón pedirá un resumen escrito.';

  @override
  String get cuidadorSincronizarErrorRed =>
      'Hoy no se ha podido conectar. Puedes volver a intentarlo más tarde.';

  @override
  String get cuidadorSincronizarSinResumen =>
      'El servidor no ha podido generar un resumen esta vez. La pregunta de abajo sigue valiendo.';

  @override
  String get cuidadorResumenCabecera => 'Esta semana, en una frase';

  @override
  String get crearSitSpotPermisoDenegadoPermanente =>
      'No se ha podido pedir permiso. Si quieres anclar la posición, cámbialo en los ajustes del teléfono.';

  @override
  String get crearSitSpotSinPermisoUbicacion =>
      'Sin permiso de ubicación. Puedes seguir sin él.';

  @override
  String get crearSitSpotErrorLocalizar =>
      'No se ha podido localizar la posición. Puedes seguir sin ella.';

  @override
  String get crearSitSpotPrePermisoTitulo => 'Anclar la posición a tu sit spot';

  @override
  String get crearSitSpotPrePermisoMensaje =>
      'La posición se queda en este cuaderno y no sale a internet. No la ve el adulto. Es opcional — el sit spot funciona sin ella.';

  @override
  String get crearSitSpotPrePermisoCancelar => 'cancelar';

  @override
  String get crearSitSpotPrePermisoAnclar => 'anclar';

  @override
  String get sitSpotsJubiladosTitulo => 'Sit spots de antes';

  @override
  String get misterioPaginaTitulo => 'Misterio';

  @override
  String get misterioBotonEvidencia => 'anotar evidencia para este misterio';

  @override
  String get misterioBotonCerrar => 'ya tengo mi respuesta sobre este Misterio';

  @override
  String get misterioCabeceraEvidencia => 'Lo que ya has anotado';

  @override
  String get misterioPaginaEvidenciaVacia =>
      'Todavía no has anotado nada para este misterio. Cuando lo hagas, aparecerá aquí.';

  @override
  String get misterioBloqueRespuesta => 'Tu respuesta';

  @override
  String misterioCerradoEl(String fecha) {
    return 'Cerrado el $fecha';
  }

  @override
  String get misterioReabrir => 'reabrir este Misterio';

  @override
  String get misterioReabrirTitulo => 'Reabrir este Misterio';

  @override
  String get misterioReabrirMensaje =>
      'Si lo reabres, tu respuesta se borra y el Misterio vuelve a la lista de abiertos. Las anotaciones que ya tenías se conservan.';

  @override
  String get misterioReabrirCancelar => 'No';

  @override
  String get misterioReabrirConfirmar => 'Reabrir';

  @override
  String get misterioCerrarTitulo => 'Tu respuesta';

  @override
  String get misterioCerrarCabeceraMisterio => 'El Misterio';

  @override
  String get misterioCerrarIntro =>
      'Cuenta con tus palabras lo que has aprendido sobre este Misterio. No hay respuesta correcta — esto no se corrige ni se nota; sólo se guarda en tu cuaderno.';

  @override
  String get misterioCerrarPlaceholder =>
      'Lo que he aprendido sobre este Misterio...';

  @override
  String get misterioCerrarBotonGuardar => 'guardar mi respuesta';

  @override
  String get misterioCerrarBotonGuardando => 'guardando...';

  @override
  String get misterioCerrarErrorGuardar =>
      'No se ha podido guardar la respuesta. Vuelve a probar.';

  @override
  String get observacionPrePermisoTitulo => 'Anclar la posición a esta página';

  @override
  String get observacionPrePermisoMensaje =>
      'La posición se queda en este cuaderno y no sale a internet. No la ve el adulto. Es opcional — puedes guardar la página sin ella.';

  @override
  String get observacionPrePermisoCancelar => 'cancelar';

  @override
  String get observacionPrePermisoAnclar => 'anclar';

  @override
  String get detalleObservacionTitulo => 'Página del cuaderno';

  @override
  String get detalleObservacionTooltipOpciones => 'opciones de la página';

  @override
  String get detalleObservacionMenuEditar => 'editar este registro';

  @override
  String get detalleObservacionMenuCompartirPdf =>
      'compartir esta página como PDF';

  @override
  String get detalleObservacionMenuBorrar => 'borrar este registro';

  @override
  String get detalleObservacionBorrarTitulo => 'Borrar este registro';

  @override
  String get detalleObservacionBorrarMensaje =>
      'Vas a borrar esta página del cuaderno. La foto y el dibujo, si los tenía, también se borrarán. No se puede deshacer.';

  @override
  String get detalleObservacionBorrarCancelar => 'cancelar';

  @override
  String get detalleObservacionBorrarConfirmar => 'borrar';

  @override
  String get listaObservacionesTitulo => 'Todas tus páginas';

  @override
  String get listaObservacionesPlaceholderBusqueda =>
      'busca por algo que recuerdes';

  @override
  String get listaObservacionesLimpiarBusqueda => 'limpiar búsqueda';

  @override
  String get listaObservacionesBusquedaSinResultados =>
      'Ninguna página guarda eso. Prueba con otra palabra.';

  @override
  String get sitSpotJubilarTitulo => 'Jubilar este sit spot';

  @override
  String sitSpotJubilarMensaje(String nombre) {
    return 'Vas a jubilar \"$nombre\". La página seguirá guardada en el cuaderno. No podrás añadir más observaciones a este sit spot, pero sí crear otro nuevo cuando quieras.';
  }

  @override
  String get sitSpotJubilarCancelar => 'cancelar';

  @override
  String get sitSpotJubilarConfirmar => 'jubilar';

  @override
  String get sitSpotExplicacionCerrar => 'Cerrar';

  @override
  String get preguntaReabrirCancelar => 'No';

  @override
  String get preguntaReabrirConfirmar => 'Reabrir';

  @override
  String get preguntaBorrarCancelar => 'cancelar';

  @override
  String get preguntaBorrarConfirmar => 'borrar';

  @override
  String get loginProfesorTitulo => 'Acceso del profesor';

  @override
  String get loginProfesorIntro =>
      'Esta pantalla es para el adulto que acompaña a la clase. No se enseña al niño. La cuenta de profesor se crea desde la web; aquí solo se vincula.';

  @override
  String get loginProfesorPlaceholderEmail => 'correo del profesor';

  @override
  String get loginProfesorPlaceholderPassword => 'contraseña';

  @override
  String get loginProfesorBotonEntrar => 'Iniciar sesión';

  @override
  String get loginProfesorEntrando => 'Entrando…';

  @override
  String get loginProfesorErrorVacio =>
      'Escribe el correo y la contraseña antes de continuar.';

  @override
  String get loginProfesorErrorCredenciales =>
      'El correo o la contraseña no coinciden con ninguna cuenta de profesor.';

  @override
  String get loginProfesorErrorSinRol =>
      'Esta cuenta no tiene perfil de profesor. Si eres cuidador, busca ese acceso aparte.';

  @override
  String get loginProfesorErrorRolInvalido =>
      'El servidor no aceptó la petición. Avisa al equipo.';

  @override
  String get loginProfesorErrorRed =>
      'No se ha podido conectar con el servidor. Inténtalo en un momento.';

  @override
  String get aulaProfesorTitulo => 'Aula';

  @override
  String get aulaProfesorTooltipCerrarSesion => 'cerrar sesión';

  @override
  String get aulaProfesorCrearTitulo => 'Crea tu primera aula';

  @override
  String get aulaProfesorCrearIntro =>
      'El servidor te dará un código que repartes a la clase. Cada niño se une desde su cuaderno con ese código.';

  @override
  String get aulaProfesorPlaceholderNombre => 'nombre del aula';

  @override
  String get aulaProfesorHintNombre => 'p. ej., 6º A · curso 2026/27';

  @override
  String get aulaProfesorJuegosCabecera => 'Juegos del aula';

  @override
  String get aulaProfesorBotonCrear => 'Crear aula';

  @override
  String get aulaProfesorCreando => 'Creando…';

  @override
  String get aulaProfesorErrorVacio =>
      'Pon un nombre al aula y elige al menos un juego.';

  @override
  String get aulaProfesorErrorSesionCaducadaCrear =>
      'La sesión ha caducado. Vuelve a iniciar sesión.';

  @override
  String get aulaProfesorErrorDatosInvalidos =>
      'Algún dato del aula no es válido. Revisa el nombre y los juegos seleccionados.';

  @override
  String get aulaProfesorErrorCodigoUnico =>
      'No se pudo generar un código único para el aula. Inténtalo en un momento.';

  @override
  String aulaProfesorErrorGenerico(int codigo) {
    return 'No se ha podido crear el aula (HTTP $codigo).';
  }

  @override
  String get aulaProfesorMensajeKMinimo =>
      'El aula necesita al menos cinco niños con datos esta semana para que se vean los agregados. Eso protege la privacidad de la clase. Vuelve cuando haya más actividad.';

  @override
  String get aulaProfesorErrorSesionCaducadaCargar =>
      'La sesión ha caducado. Cierra sesión y vuelve a entrar.';

  @override
  String aulaProfesorErrorCargarAgregados(String error) {
    return 'No se han podido cargar los agregados ($error).';
  }

  @override
  String aulaProfesorCodigoEtiqueta(String code) {
    return 'Código del aula: $code';
  }

  @override
  String aulaProfesorSemanaResumen(String iso, int reporting, int total) {
    return 'Semana $iso · $reporting de $total con datos';
  }

  @override
  String get preguntaCenaCuadernoEnReposo =>
      'Esta semana el cuaderno descansó. ¿Hay algo del lugar que os apetezca volver a mirar despacio?';

  @override
  String get preguntaCenaObservacionesSinAnclajes =>
      '¿Qué cosa pequeña ha aparecido esta semana en el cuaderno que no estaba antes?';

  @override
  String get preguntaCenaRegresoAlSitSpot =>
      'Esta semana ha vuelto al lugar de regreso. ¿Qué le ha sonado distinto allí?';

  @override
  String get preguntaCenaUnaPreguntaActiva =>
      'Esta semana ha quedado dándole vueltas a una pregunta. ¿Cuál cuenta hoy?';

  @override
  String get preguntaCenaVariasPreguntasActivas =>
      'Esta semana ha tenido varias preguntas a la vez. ¿Cuál de todas le tiene más enganchada ahora mismo?';

  @override
  String get configuracionInicialEnlacePolitica =>
      'lee cómo se cuida tu cuaderno';

  @override
  String get configuracionInicialPoliticaTitulo => 'cómo se cuida tu cuaderno';

  @override
  String get crearSitSpotTitulo => 'Tu sit spot';

  @override
  String get crearSitSpotQuitarPosicion => 'quitar posición';

  @override
  String get paginaSitSpotBotonAnotar => 'anotar observación aquí';

  @override
  String get lienzoDibujoBotonGuardar => 'guardar dibujo';

  @override
  String get tarjetaSitSpotQueEs => 'qué es un sit spot';

  @override
  String get tarjetaSitSpotJubilarOpcion => 'jubilar este sit spot';

  @override
  String get editarObservacionTitulo => 'editar página';

  @override
  String get editarObservacionBotonGuardar => 'guardar cambios';

  @override
  String get chipSugerenciaMisterioNo => 'no';

  @override
  String get chipSugerenciaMisterioAnclar => 'anclar';

  @override
  String get homeBotonVerTodasPaginas => 'ver todas tus páginas';

  @override
  String get mapaBotonAbrirAjustes => 'abrir Ajustes';

  @override
  String get mapaBotonEncender => 'encender el mapa';

  @override
  String get mapaConfirmarEncenderEncender => 'encender';

  @override
  String get mapaConfirmarEncenderCancelar => 'cancelar';

  @override
  String get mapaBotonConfigurarSitSpot => 'configurar sit spot';

  @override
  String get observacionQuitarPosicion => 'quitar posición';

  @override
  String get sitSpotsJubiladosVacio =>
      'Aquí aparecerán los sit spots que jubiles. Sus páginas seguirán guardadas con sus observaciones.';

  @override
  String sitSpotJubiladoPeriodoCreado(String desde) {
    return 'Creado el $desde.';
  }

  @override
  String sitSpotJubiladoPeriodoActivo(String desde, String hasta) {
    return 'Estuvo activo del $desde al $hasta.';
  }

  @override
  String get sitSpotJubiladoSinObservaciones => 'Sin observaciones guardadas.';

  @override
  String get sitSpotJubiladoUnaObservacion => '1 observación guardada';

  @override
  String sitSpotJubiladoVariasObservaciones(int cuenta) {
    return '$cuenta observaciones guardadas';
  }

  @override
  String get sitSpotJubiladoPaginaVacia =>
      'No hay observaciones guardadas en esta página.';

  @override
  String get paginaSitSpotLoQueAnotaste => 'Lo que ya has anotado aquí';

  @override
  String get paginaSitSpotVacio =>
      'Todavía no has anotado nada en este sit spot. Cuando lo hagas, aparecerá aquí.';

  @override
  String paginaSitSpotActivoDesde(String desde) {
    return 'Activo desde el $desde.';
  }

  @override
  String get crearSitSpotIntro =>
      'Un sit spot es un lugar al que vuelves. Lo ves cambiar con el tiempo.';

  @override
  String get crearSitSpotEtiquetaNombre => 'cómo se llama tu sit spot';

  @override
  String get crearSitSpotHintNombre =>
      'el roble grande, mi banco, donde fui con la abuela…';

  @override
  String get crearSitSpotEtiquetaDonde =>
      'dónde está, para acordarte (opcional)';

  @override
  String get crearSitSpotHintDonde =>
      'al final del parque, junto al pino más alto';

  @override
  String get crearSitSpotBotonGuardar => 'guardar sit spot';

  @override
  String get crearSitSpotGuardando => 'guardando…';

  @override
  String get crearSitSpotPosicionNoAnclada => 'Posición no anclada';

  @override
  String get crearSitSpotPosicionAnclada => 'Posición anclada al sit spot';

  @override
  String get crearSitSpotPosicionPrivada =>
      'La posición se queda en este cuaderno y no sale a internet.';

  @override
  String get crearSitSpotBotonAnclar => 'anclar mi posición';

  @override
  String get crearSitSpotLocalizando => 'localizando…';

  @override
  String get presentacionSitSpotTitulo => 'Un sitio que conoces';

  @override
  String get presentacionSitSpotParrafo1 =>
      'En este cuaderno hay un sitio especial. Lo eliges tú: un banco del parque, una piedra junto al río, un rincón del jardín, una ventana.';

  @override
  String get presentacionSitSpotParrafo2 =>
      'Lo importante no es que sea bonito. Es que puedas volver. Si vuelves muchas veces, lo verás cambiar — las hojas, los pájaros, la luz, los bichos. El cuaderno se llenará de lo que pase allí.';

  @override
  String get presentacionSitSpotParrafo3 =>
      'Cuando lo encuentres, le pones nombre. No tiene que ser un nombre serio.';

  @override
  String get presentacionSitSpotBotonTengoSitio => 'ya pienso en uno';

  @override
  String get presentacionSitSpotBotonTodaviaNo => 'todavía no';

  @override
  String get acercaCabeceraNombre => 'El Cuaderno';

  @override
  String get acercaCabeceraSubtitulo =>
      'un cuaderno de campo digital — para 9-13 años';

  @override
  String get acercaCierre => 'el monte espera';

  @override
  String get acercaQueEsTitulo => 'qué es esto';

  @override
  String get acercaQueEsCuerpo =>
      'Un cuaderno de campo. Es tuyo. Lo que escribas aquí no se borra solo y nadie lo lee a tus espaldas.\n\nNo es un juego para ganar. No tiene puntos, ni rachas, ni nada que celebre nada. Es un sitio donde dejar lo que ves cuando sales a mirar.';

  @override
  String get acercaPestanasTitulo => 'las cuatro pestañas';

  @override
  String get acercaPestanasCuerpo =>
      '**Cuaderno** — el saludo, el sit spot, los Misterios abiertos y la última página.\n\n**Mapa** — sólo si la persona adulta lo enciende en Ajustes.\n\n**Misterios** — tus preguntas y los Misterios del cuaderno. Aquí formulas las tuyas con el botón *\"formular pregunta\"*.\n\n**Tutor** — alguien con quien hablar cuando no entiendes algo. No es un buscador de internet y no da la respuesta hecha.';

  @override
  String get acercaAnotarTitulo => 'anotar una observación';

  @override
  String get acercaAnotarCuerpo =>
      'Cuando ves algo que merece la pena, lo anotas. Una página tiene tres campos importantes:\n\n**Qué viste** — lo que vieron tus ojos. *\"Una mariposa blanca con manchas marrones\"* es mejor que *\"una pieris\"*. La identificación viene después.\n\n**Crees que es** — si crees que sabes qué era. Si no, lo dejas vacío. Decir *\"no sé\"* es información: significa que volverás a mirar.\n\n**Nivel de confianza** — tres opciones: *consenso* (estás seguro), *hipótesis activa* (crees que sabes pero te haría falta volver a mirar), *no segura* (viste algo, no sabes qué).';

  @override
  String get acercaSitSpotTitulo => 'tu sit spot';

  @override
  String get acercaSitSpotCuerpo =>
      'El lugar al que vuelves muchas veces. No tiene que ser bonito. Tiene que ser tuyo: un banco del parque, una piedra junto al río, una rama gruesa de un árbol del patio.\n\nSi vas siempre a sitios distintos, ves cosas distintas. Si vuelves al mismo sitio, ves **cómo cambia**.\n\nNo tienes prisa por elegirlo. La presentación del cuaderno deja explícito que se puede dejar para después.';

  @override
  String get acercaMisteriosTitulo => 'misterios y preguntas';

  @override
  String get acercaMisteriosCuerpo =>
      'Hay dos tipos de preguntas en la pestaña Misterios:\n\nLos **Misterios del cuaderno** los propone el cuaderno, contextualizados a tu zona y a la estación. No tienes que resolverlos todos.\n\n**Tus preguntas** las formulas tú. Si no se te ocurre cómo empezar, hay un *\"necesito ideas\"* con cinco maneras posibles.\n\nCuando creas que tienes tu respuesta — no la respuesta correcta del libro de ciencias, **tu respuesta** — la guardas. Aquí no hay respuesta correcta: hay tu respuesta.';

  @override
  String get acercaNoHaceTitulo => 'lo que este cuaderno NO hace';

  @override
  String get acercaNoHaceCuerpo =>
      'No tiene puntos, niveles, rachas, premios.\n\nNo envía notificaciones. Cuando te apetezca, abres tú.\n\nNo celebra cuando anotas algo. Tu observación es la celebración.\n\nNo te compara con otros niños. No hay rankings.\n\nNo te dice si algo está bien o mal. Lo que ves está bien por ser visto.';

  @override
  String get acercaPrivacidadTitulo => 'para tu adulto: privacidad';

  @override
  String get acercaPrivacidadCuerpo =>
      'Esto es un hard limit no negociable: el cuaderno es del niño.\n\n**Sólo se queda en el dispositivo, nunca cruza red:**\n· el texto libre de las observaciones\n· las fotos\n· los dibujos del lienzo\n· las coordenadas precisas\n· las preguntas que formula\n· las respuestas al cerrar Misterios\n· el nombre que ha elegido\n\n**Sólo viaja al servidor con sincronización opt-in:**\n· un *hash* de la observación (no el texto)\n· el código de región provincial (no la posición)\n· un agregado semanal con conteos por tipo, sin contenido\n· las preguntas al Tutor IA, si está activado, con cuota diaria + ZDR + lista negra\n\n**Lo que la persona adulta puede ver:**\n· un párrafo cualitativo resumiendo la semana, sin texto literal\n· una pregunta sugerida para la cena\n\n**Lo que la persona adulta no puede ver:** ninguna observación literal, ninguna foto, ningún dibujo, ninguna coordenada, ninguna conversación con el Tutor.';

  @override
  String get acercaAcompanarTitulo => 'para tu adulto: cómo acompañar';

  @override
  String get acercaAcompanarCuerpo =>
      'El sit spot es lo más importante. Si la niña no se lo ha apropiado, no volverá. Que lo elija ella. Si todavía no encuentra ninguno, no tiene prisa.\n\nUna observación a la semana es buen ritmo. Hay semanas con cero observaciones — eso también está bien. La biblia del proyecto: *cierre amable y ritmo respetuoso.*\n\nSi activas el resumen semanal en Ajustes, recibirás una pregunta sugerida para la cena. Está pensada para que sea más fácil empezar conversación, no para auditar.\n\n**Lo que es mejor no hacer:**\n· leer su cuaderno por encima del hombro\n· pedir que demuestre lo que ha aprendido\n· corregir si identifica mal — la próxima vez comparará y se corregirá sola\n· felicitar efusivamente cuando anota — convierte el oficio en performance';

  @override
  String get acercaTutorTitulo => 'para tu adulto: el Tutor';

  @override
  String get acercaTutorCuerpo =>
      'Asistente conversacional limitado por reglas. La biblia del proyecto le pone cinco bumpers:\n\n**ZDR** — el proveedor del modelo no entrena con las conversaciones ni las retiene.\n\n**Sin memoria entre conversaciones.** Cada apertura empieza limpia.\n\n**Lista negra de temas.** Hay temas (sexualidad, violencia, drogas, autolesión, datos personales) que el Tutor no continúa. Redirige amable y al cabo de pocos turnos cierra.\n\n**Cuota de 30 turnos al día.** Cuando se llega, el Tutor responde *\"hablamos mañana\"*. Bumper deliberado contra el efecto adictivo.\n\n**No da respuestas hechas.** Está prompted para devolver la pregunta al lugar.';

  @override
  String get acercaAulaTitulo => 'para el aula: vista del docente';

  @override
  String get acercaAulaCuerpo =>
      'Cuando este cuaderno se usa en clase, la persona docente accede a un panel agregado desde Ajustes → *\"Acceder como profesor\"*. Lo que ve:\n\n· recuento agregado de la actividad de su aula\n· distribución por dominios (presencia, observación, registro, identificación, relaciones, ciclos, hábitats, hipótesis, tejido)\n\n**Nunca el contenido literal de las observaciones de ningún niño.**\n\nUmbral mínimo: **k≥5**. Si en un dominio hay menos de 5 alumnas con datos, ese dato se oculta para que no sea posible deducir el comportamiento de una niña concreta.\n\nEsta parte está pendiente de cerrar la policy escolar definitiva con la regulación europea para menores en aulas.';

  @override
  String get acercaIdiomasTitulo => 'idiomas';

  @override
  String get acercaIdiomasCuerpo =>
      'Castellano, euskera y catalán desde el primer arranque. La traducción de euskera y catalán está pendiente de revisión por hablantes nativas con criterio terminológico naturalista.';

  @override
  String get acercaLicenciaTitulo => 'licencia';

  @override
  String get acercaLicenciaCuerpo =>
      'Código AGPL-3.0. Contenido (textos, ilustraciones, catálogo de Misterios) CC-BY-SA 4.0. Sin tracking, sin anuncios, sin monetización. Privacidad por diseño.';

  @override
  String get tarjetaMisterioContadorVacio => 'todavía no has anotado nada';

  @override
  String get tarjetaMisterioContadorUna => '1 evidencia anotada';

  @override
  String tarjetaMisterioContadorVarias(int n) {
    return '$n evidencias anotadas';
  }

  @override
  String tarjetaMisterioPrefijoCaliente(String base) {
    return 'estos días · $base';
  }

  @override
  String get tarjetaSitSpotOpcionesTooltip => 'opciones del sit spot';

  @override
  String get editarObservacionEtiquetaDonde => 'dónde estabas';

  @override
  String get lienzoTooltipDeshacer => 'deshacer';

  @override
  String get lienzoTooltipBorrar => 'borrar y empezar otra vez';

  @override
  String get lienzoAnchoFino => 'trazo fino';

  @override
  String get lienzoAnchoMedio => 'trazo medio';

  @override
  String get lienzoAnchoGrueso => 'trazo grueso';

  @override
  String get lienzoHerramientaPlumilla => 'plumilla';

  @override
  String get lienzoHerramientaLapicero => 'lapicero';

  @override
  String get lienzoHerramientaCarboncillo => 'carboncillo';

  @override
  String get lienzoHerramientaGoma => 'goma';

  @override
  String get lienzoColorTinta => 'tinta';

  @override
  String get lienzoColorSanguina => 'sanguina';

  @override
  String get lienzoColorSepia => 'sepia';

  @override
  String get lienzoColorOcre => 'ocre';

  @override
  String get lienzoColorVerdeBotanico => 'verde botánico';

  @override
  String get pdfPlantillaTituloCabecera => 'Cuaderno de campo';

  @override
  String pdfPlantillaTituloCabeceraConNombre(String nombre) {
    return 'Cuaderno de campo · $nombre';
  }

  @override
  String get pdfPlantillaAutorAnonimo => 'El Cuaderno';

  @override
  String pdfPlantillaPagina(int numero, int total) {
    return 'pág. $numero de $total';
  }

  @override
  String pdfPlantillaSitSpot(String nombre) {
    return 'Sit spot: $nombre';
  }

  @override
  String get pdfPlantillaDiaHora => 'Día y hora';

  @override
  String get pdfPlantillaDondeEstabas => 'Dónde estabas';

  @override
  String get pdfPlantillaQueViste => 'Qué viste';

  @override
  String get pdfPlantillaCreesQueEs => 'Crees que es';

  @override
  String get pdfPlantillaDibuja => 'Dibuja';

  @override
  String get configuracionInicialPoliticaCuerpo =>
      'Tu cuaderno es tuyo. Lo que escribes, las fotos y los dibujos que añades, viven solo en tu dispositivo. No salen al servidor.\n\nNo hay anuncios. No se vende lo que escribes a nadie. No hay rachas, niveles ni recompensas que te empujen a volver: vuelve si quieres, cuando quieras.\n\nSi una persona adulta quiere ayudarte a usar el Tutor real, o quiere recibir un resumen para hablar contigo, tiene que entrar a Ajustes y darle a un botón cada vez. Nunca pasa solo. Nunca avisa a nadie sin que tú lo sepas.\n\nCuando quieras, en Ajustes puedes exportar todo tu cuaderno como un archivo y borrarlo del todo de este dispositivo.\n\nEsta es una versión provisional escrita por el equipo que está haciendo el cuaderno. Antes de que lo use mucha gente, una persona experta en leyes va a revisarla.';

  @override
  String get observacionMapaSonidosComenzar => 'mapa de sonidos';

  @override
  String get mapaSonidosTitulo => 'Mapa de sonidos';

  @override
  String get mapaSonidosIntroduccion =>
      'Quédate en un sitio un rato. Tú estás en el centro. Cada sonido que oigas, márcalo donde te llega: cerca, a media distancia o lejos.';

  @override
  String get mapaSonidosAyuda =>
      'Toca el mapa para marcar. Toca una marca para quitarla.';

  @override
  String get mapaSonidosCentro => 'tú';

  @override
  String get mapaSonidosDelante => 'delante';

  @override
  String get mapaSonidosGuardar => 'guardar mapa';

  @override
  String get mapaSonidosDeshacer => 'deshacer';

  @override
  String get mapaSonidosTipoPajaro => 'pájaro';

  @override
  String get mapaSonidosTipoInsecto => 'insecto';

  @override
  String get mapaSonidosTipoAgua => 'agua';

  @override
  String get mapaSonidosTipoViento => 'viento';

  @override
  String get mapaSonidosTipoHojas => 'hojas';

  @override
  String get mapaSonidosTipoAnimal => 'otro animal';

  @override
  String get mapaSonidosTipoPersona => 'personas';

  @override
  String get mapaSonidosTipoMaquina => 'máquina';

  @override
  String get mapaSonidosTipoNoSe => 'no sé qué es';

  @override
  String get paletaLugarTitulo => 'Los colores de este sitio';

  @override
  String get paletaLugarExplicacion =>
      'Salen de tus fotos de aquí, estación a estación.';

  @override
  String paletaLugarFotos(int numero) {
    String _temp0 = intl.Intl.pluralLogic(
      numero,
      locale: localeName,
      other: '$numero fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String get estacionPrimavera => 'primavera';

  @override
  String get estacionVerano => 'verano';

  @override
  String get estacionOtono => 'otoño';

  @override
  String get estacionInvierno => 'invierno';
}
