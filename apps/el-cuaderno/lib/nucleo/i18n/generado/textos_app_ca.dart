// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'textos_app.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class TextosAppCa extends TextosApp {
  TextosAppCa([String locale = 'ca']) : super(locale);

  @override
  String get tituloApp => 'El Quadern';

  @override
  String get subtituloBienvenida =>
      'Una eina per anotar el que veus viu prop teu.';

  @override
  String get saludoSinNombre => 'Hola.';

  @override
  String saludoConNombre(String nombre) {
    return 'Hola, $nombre.';
  }

  @override
  String get navCuaderno => 'quadern';

  @override
  String get navMapa => 'mapa';

  @override
  String get navMisterios => 'misteris';

  @override
  String get navTutor => 'tutor';

  @override
  String get seccionSitSpot => 'El teu sit spot';

  @override
  String get seccionMisteriosAbiertos => 'Misteris oberts';

  @override
  String get seccionUltimaPagina => 'Última pàgina';

  @override
  String get sitSpotInvitacion =>
      'Quan siguis en algun lloc a l\'aire lliure que t\'agradi — un parc, un arbre, una cantonada — el pots fer el teu sit spot. Toca aquí quan hi siguis.';

  @override
  String sitSpotUltimaVisita(String cuando) {
    return 'Darrera visita: $cuando';
  }

  @override
  String get ultimaPaginaVacia =>
      'Encara no has anotat res. Quan ho facis, apareixerà aquí.';

  @override
  String get misteriosVacio =>
      'Encara no tens cap Misteri obert. El sistema te\'n proposarà algun aviat.';

  @override
  String get misteriosFueraDeContexto =>
      'Avui no hi ha Misteris per al teu lloc i aquesta estació. Torna a mirar quan canviï el temps.';

  @override
  String get navProximamente => 'Aviat.';

  @override
  String get homeFabAnotar => 'anotar';

  @override
  String get homeFabAnotarTooltip => 'anotar el que veus';

  @override
  String get homeOrientacionConMisterios =>
      'Aquests són els Misteris que el teu quadern té oberts. Obre\'ls per llegir-los; quan vegis alguna cosa al teu sit spot que hi tingui a veure, anota-la.';

  @override
  String get seccionTusPreguntas => 'Les teves preguntes';

  @override
  String get seccionMisteriosDelCuaderno => 'Misteris del quadern';

  @override
  String get tusPreguntasVacio =>
      'Encara no has formulat cap pregunta. Quan se\'t acudeixi alguna mentre observes el teu lloc, anota-la aquí.';

  @override
  String get preguntaFabFormular => 'formular pregunta';

  @override
  String get preguntaFormularTitulo => 'La teva pregunta';

  @override
  String get preguntaFormularIntro =>
      'Una pregunta teva. La que portes donant-li voltes, la que se t\'ha acabat d\'acudir, la que ningú t\'ha explicat. Escriu-la com et soni; no cal que estigui ben feta — només que sigui la teva.';

  @override
  String get preguntaFormularPlaceholder => '…?';

  @override
  String get preguntaFormularBotonGuardar => 'Desar la meva pregunta';

  @override
  String get preguntaFormularBotonIdeas => 'necessito idees';

  @override
  String get preguntaIdeasTitulo => 'Si necessites un punt de partida';

  @override
  String get preguntaIdeasIntro =>
      'No has d\'utilitzar-ne cap. Si te n\'ajuda algun, prem-lo i comença des d\'allà.';

  @override
  String get preguntaIdea1 => 'sempre … quan …?';

  @override
  String get preguntaIdea2 => 'què passa quan …?';

  @override
  String get preguntaIdea3 => 's\'assembla … a …?';

  @override
  String get preguntaIdea4 => 'com canvia … amb el temps?';

  @override
  String get preguntaIdea5 => 'què fa … quan …?';

  @override
  String get preguntaPaginaTitulo => 'La teva pregunta';

  @override
  String preguntaPaginaFormulada(String fecha) {
    return 'Plantejada el $fecha';
  }

  @override
  String get preguntaPaginaEvidenciaVacia =>
      'Encara no has anotat res per a la teva pregunta. Torna al lloc i mira; quan vegis alguna cosa que hi tingui a veure, anota-la i ancora-la aquí.';

  @override
  String get preguntaPaginaCabeceraEvidencia => 'El que ja has anotat';

  @override
  String get preguntaPaginaBorrar => 'esborrar aquesta pregunta';

  @override
  String get preguntaPaginaConfirmaBorrar =>
      'Vas a esborrar aquesta pregunta teva. Les observacions que hi tinguessis ancorades es conserven al quadern. No es pot desfer.';

  @override
  String get preguntaPaginaBotonEvidencia =>
      'anotar evidència per aquesta pregunta';

  @override
  String get preguntaPaginaBotonCerrar =>
      'ja tinc la meva resposta sobre aquesta pregunta';

  @override
  String get preguntaCerrarTitulo => 'La teva resposta';

  @override
  String get preguntaCerrarIntro =>
      'Explica amb les teves paraules el que has après. No hi ha resposta correcta — això no es corregeix ni es puntua; només es desa al teu quadern.';

  @override
  String get preguntaCerrarPlaceholder => 'la teva resposta';

  @override
  String get preguntaCerrarBoton => 'Desar la meva resposta';

  @override
  String get preguntaPaginaBloqueRespuesta => 'La teva resposta';

  @override
  String preguntaPaginaCerradaEl(String fecha) {
    return 'Tancada el $fecha';
  }

  @override
  String get preguntaPaginaReabrir => 'tornar a obrir aquesta pregunta';

  @override
  String get preguntaPaginaConfirmaReabrir =>
      'Si la tornes a obrir, la teva resposta s\'esborra i la pregunta torna a la llista d\'obertes. Les anotacions que ja tenies es conserven.';

  @override
  String get observacionTitulo => 'observació nova';

  @override
  String observacionCabecera(String hora) {
    return 'Avui · $hora';
  }

  @override
  String get observacionCajaFoto => 'foto';

  @override
  String get observacionCajaDibujo => 'dibuix';

  @override
  String get observacionCajaPlaceholder =>
      'Si vols, afegeix una foto o un dibuix.';

  @override
  String get observacionFotoTomar => 'fer foto';

  @override
  String get observacionFotoElegir => 'triar foto';

  @override
  String get observacionFotoQuitar => 'treure foto';

  @override
  String get observacionDibujoComenzar => 'fer dibuix';

  @override
  String get observacionDibujoQuitar => 'treure dibuix';

  @override
  String get observacionEtiquetaQueViste => 'què has vist';

  @override
  String get observacionPlaceholderQueViste =>
      'descriu el que has vist, sense posar-li nom si no n\'estàs segura';

  @override
  String get observacionEtiquetaCreesQueEs => 'creus que és';

  @override
  String get observacionPlaceholderCreesQueEs => 'si vols, proposa un nom';

  @override
  String get confianzaConsenso => 'consens';

  @override
  String get confianzaHipotesisActiva => 'hipòtesi activa';

  @override
  String get confianzaNoSegura => 'no n\'estic segura';

  @override
  String get confianzaConsensoTooltip =>
      'ho has confirmat amb una clau o amb el Tutor';

  @override
  String get confianzaNoSeguraTooltip => 'no passa res, anota-ho així';

  @override
  String get observacionAvisoFalta => 'fes una nota abans de desar';

  @override
  String get observacionBotonGuardar => 'Desar al quadern';

  @override
  String get tutorSaludoCanonico =>
      'Soc el Tutor del Quadern. Pregunta\'m el que necessitis.';

  @override
  String get tutorPlaceholderInput => 'escriu la teva pregunta';

  @override
  String get tutorBotonEnviar => 'Enviar';

  @override
  String get tutorRespuestaCanned =>
      'El Tutor encara no està connectat. Torna en unes setmanes.';

  @override
  String get tutorErrorRed =>
      'Ara mateix no arribo al quadern. Espera un moment i torna-ho a provar.';

  @override
  String get ajustesTitulo => 'Configuració';

  @override
  String get atlasTitulo => 'El teu atles';

  @override
  String get atlasSubtitulo => 'no és un trofeu. és el que has vist.';

  @override
  String get atlasSeccionPrimerasVeces => 'Les teves primeres vegades';

  @override
  String get atlasSeccionLoQueHasVisto => 'El que has vist';

  @override
  String get atlasConteoSingular => '1 vegada';

  @override
  String atlasConteoPlural(int conteo) {
    return '$conteo vegades';
  }

  @override
  String get atlasVacioCabecera => 'El teu atles encara és buit.';

  @override
  String get atlasVacioCuerpo =>
      'Quan vagis anotant el que creus que veus, això s\'anirà omplint sol. No hi ha pressa.';

  @override
  String get atlasEnlaceDesdeCuaderno => 'veure el teu atles';

  @override
  String get seccionEcos => 'Fa un temps, per aquí';

  @override
  String get ecoCabeceraUnMes => 'fa un mes, per aquestes dates…';

  @override
  String get ecoCabeceraSeisMeses => 'fa sis mesos, per aquestes dates…';

  @override
  String get ecoCabeceraUnAno => 'fa un any, per aquestes dates…';

  @override
  String get paginaSitSpotResumenMesCabecera => 'Aquest mes aquí';

  @override
  String paginaSitSpotResumenMesVisitas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Has vingut $count vegades aquest mes.',
      two: 'Has vingut dues vegades aquest mes.',
      one: 'Has vingut una vegada aquest mes.',
    );
    return '$_temp0';
  }

  @override
  String paginaSitSpotResumenMesPrimeraUltima(String primera, String ultima) {
    return 'La primera va ser el $primera. L\'última, el $ultima.';
  }

  @override
  String get lecturaTitulo => 'Llegir les teves pàgines';

  @override
  String get lecturaTooltip => 'llegir les teves pàgines';

  @override
  String lecturaPaginaIndicador(int pagina, int total) {
    return '$pagina de $total';
  }

  @override
  String get lecturaVacioCuerpo =>
      'Encara no has anotat res. Quan ho facis, podràs obrir el teu quadern com un llibre.';

  @override
  String get ajustesMapaOnlineEtiqueta => 'Activar el mapa';

  @override
  String get ajustesMapaOnlineCuerpo =>
      'Si l\'actives, el dispositiu es connectarà a internet per mostrar la zona del món on siguis. La pestanya \"mapa\" només funciona amb això encès. Més endavant el mapa es podrà descarregar una vegada i deixarà d\'anar a internet.';

  @override
  String get detalleCompartirFotoOpcion => 'compartir foto al teu adult';

  @override
  String get detalleCompartirFotoTextoAdjunto =>
      'Mira el que he vist al meu quadern. Saps què és?';

  @override
  String get compararVisitasTitulo => 'Comparar dues visites';

  @override
  String get compararVisitasEnlace => 'comparar dues visites';

  @override
  String get compararVisitasIntro => 'tria dos moments. mira què canvia.';

  @override
  String get compararVisitasColumnaIzquierda => 'primer moment';

  @override
  String get compararVisitasColumnaDerecha => 'segon moment';

  @override
  String get compararVisitasInsuficientesCabecera =>
      'Necessites dues visites per comparar.';

  @override
  String get compararVisitasInsuficientesCuerpo =>
      'Quan tornis al teu sit spot un altre dia i anotis alguna cosa, podràs comparar el que veies abans amb el que veus ara.';

  @override
  String get imprimirPlantillaBloque => 'Imprimir pàgines en blanc per al camp';

  @override
  String get imprimirPlantillaBloqueDescripcion =>
      'Genera un PDF per portar el quadern en paper a una sortida. Sense pantalles, sense piles.';

  @override
  String get imprimirPlantillaTitulo => 'Pàgines per al camp';

  @override
  String get imprimirPlantillaIntro =>
      'De vegades el camp es mira millor sense pantalla. Aquí prepares el teu quadern en paper per portar-lo a la motxilla.';

  @override
  String get imprimirPlantillaContenido =>
      'Cada pàgina té espai per a la data, on eres, què has vist, el que creus que és i un quadre gran per dibuixar.';

  @override
  String get imprimirPlantillaSelectorCabecera => 'Quantes pàgines';

  @override
  String imprimirPlantillaOpcionPaginas(int paginas) {
    return '$paginas pàgines';
  }

  @override
  String get imprimirPlantillaBoton => 'Imprimir o compartir';

  @override
  String get imprimirPlantillaNotaFinal =>
      'Si no tens impressora, també pots desar el PDF al mòbil i ensenyar-lo a qui sí en tingui.';

  @override
  String get detalleObservacionPrimeraVez =>
      'primera vegada que anotes una cosa així al quadern.';

  @override
  String get acercaTitulo => 'Com s\'utilitza aquest quadern';

  @override
  String get acercaBloque => 'Com s\'utilitza aquest quadern';

  @override
  String get acercaBloqueDescripcion =>
      'Què és, com anotar, com acompanyar. Per a tu, per al teu adult i per a la teva mestra.';

  @override
  String ajustesIdiomaActual(String idioma) {
    return 'Idioma del quadern: $idioma';
  }

  @override
  String get ajustesIdiomaCambiar => 'Canviar idioma';

  @override
  String get ajustesExportar => 'Exportar el meu quadern';

  @override
  String get ajustesExportarDescripcion =>
      'Rep una còpia llegible de les teves observacions i Misteris. El quadern és teu.';

  @override
  String get ajustesExportarPdf => 'Exportar com a PDF';

  @override
  String get ajustesExportarPdfDescripcion =>
      'Una còpia per imprimir o portar a un paper. El sistema et preguntarà on desar-la.';

  @override
  String get ajustesExportarDialogoTitulo => 'El teu quadern com a text';

  @override
  String get ajustesExportarDialogoCerrar => 'Tancar';

  @override
  String get ajustesVistaCuidador => 'Vista del cuidador';

  @override
  String get ajustesVistaCuidadorDescripcion =>
      'Una pàgina discreta per a una persona adulta que t\'acompanya.';

  @override
  String get ajustesBorrar => 'Esborrar el meu quadern';

  @override
  String get ajustesBorrarDescripcion =>
      'Esborrar totes les teves observacions, Misteris i sit spot. No es pot desfer.';

  @override
  String get ajustesBorrarDialogoTitulo => 'Esborrar-ho tot?';

  @override
  String ajustesBorrarDialogoCuerpo(
      int observaciones, int misterios, int sitSpots) {
    return 'Si continues, s\'esborraran $observaciones observacions, $misterios Misteris i $sitSpots sit spot. No es pot desfer.';
  }

  @override
  String get ajustesBorrarDialogoSeguir => 'Continuar';

  @override
  String get ajustesBorrarDialogoCancelar => 'Cancel·lar';

  @override
  String get ajustesBorrarConfirmacionTitulo => 'Estàs segura?';

  @override
  String get ajustesBorrarConfirmacionCuerpo =>
      'Escriu «esborrar» a sota per confirmar.';

  @override
  String get ajustesBorrarConfirmacionPalabra => 'esborrar';

  @override
  String get ajustesBorrarConfirmacionPlaceholder => 'escriu la paraula';

  @override
  String get ajustesBorrarConfirmacionBoton => 'Esborrar-ho tot';

  @override
  String get ajustesBorradoCompleto => 'Fet. El teu quadern és buit.';

  @override
  String get bienvenidaTitulo => 'Com et dius?';

  @override
  String get bienvenidaCuerpo =>
      'El teu nom es queda en aquest quadern. No surt al servidor tret que decideixis vincular-lo més endavant.';

  @override
  String get bienvenidaPlaceholderNombre => 'el teu nom';

  @override
  String get bienvenidaBotonContinuar => 'Continuar';

  @override
  String get ajustesSyncObsTitulo => 'Sincronitzar les meves observacions';

  @override
  String get ajustesSyncObsDescripcion =>
      'Puja les observacions noves al teu compte del servidor per no perdre-les si canvies de dispositiu.';

  @override
  String get ajustesSyncObsBoton => 'Pujar ara';

  @override
  String get ajustesSyncObsEnVuelo => 'Pujant…';

  @override
  String get ajustesSyncObsSinToken =>
      'Encara no hi ha compte vinculat amb el servidor. Quan n\'hi hagi, aquest botó pujarà les teves observacions.';

  @override
  String get ajustesSyncObsNadaPendiente =>
      'No hi ha observacions pendents — tot pujat.';

  @override
  String ajustesSyncObsTodasEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S\'han pujat $count observacions.',
      one: 'S\'ha pujat una observació.',
    );
    return '$_temp0';
  }

  @override
  String ajustesSyncObsParcial(int enviadas, int pendientes) {
    return 'Pujades $enviadas, en queden $pendientes per al següent intent.';
  }

  @override
  String ajustesSyncObsRechazadas(int enviadas, int rechazadas) {
    return 'Pujades $enviadas, el servidor n\'ha rebutjat $rechazadas. Torna a obrir-les per revisar-les.';
  }

  @override
  String get ajustesCuentaTitulo => 'Compte de l\'adult';

  @override
  String get ajustesCuentaDescripcion =>
      'Si tens un compte de Nuevo Ser, el pots vincular aquí. Serveix per pujar les teves observacions, rebre el resum escrit del cuidador i connectar el Tutor real.';

  @override
  String get ajustesCuentaPlaceholderEmail => 'correu de l\'adult';

  @override
  String get ajustesCuentaPlaceholderPassword => 'contrasenya';

  @override
  String get ajustesCuentaBotonEntrar => 'Iniciar sessió';

  @override
  String get ajustesCuentaEntrando => 'Entrant…';

  @override
  String ajustesCuentaSesionIniciada(String email) {
    return 'Sessió iniciada com a $email.';
  }

  @override
  String get ajustesCuentaSesionIniciadaSinEmail => 'Sessió iniciada.';

  @override
  String get ajustesCuentaCerrarSesion => 'Tancar sessió';

  @override
  String get ajustesCuentaErrorCredenciales =>
      'El correu o la contrasenya no coincideixen amb cap compte.';

  @override
  String get ajustesCuentaErrorSinPerfil =>
      'El compte de l\'adult encara no té cap nen associat.';

  @override
  String get ajustesCuentaErrorRed =>
      'No s\'ha pogut connectar amb el servidor. Torna-ho a provar en un moment.';

  @override
  String get ajustesCuentaErrorVacio =>
      'Escriu el correu i la contrasenya abans de continuar.';

  @override
  String get ajustesTutorDebugTitulo => 'Tutor (debug)';

  @override
  String get ajustesTutorDebugDescripcion =>
      'Enganxa aquí un token del backend per activar el Tutor real. Només visible en debug.';

  @override
  String get ajustesTutorDebugPlaceholder => 'JWT del backend';

  @override
  String get ajustesTutorDebugBotonGuardar => 'Desar el token';

  @override
  String get ajustesTutorDebugBotonBorrar => 'Esborrar el token';

  @override
  String get ajustesTutorDebugGuardado =>
      'Token desat. Torna al Tutor per provar-lo.';

  @override
  String get ajustesTutorDebugBorrado =>
      'Token esborrat. El Tutor torna a la resposta canònica.';

  @override
  String get cuidadorTitulo => 'Pàgina del cuidador';

  @override
  String get cuidadorAviso =>
      'Aquesta és l\'única vista que el joc comparteix amb qui t\'acompanya. No veurà les teves observacions ni el que escrius — només aquest resum i una pregunta per parlar.';

  @override
  String cuidadorSemanaActual(String isoWeek) {
    return 'Setmana $isoWeek';
  }

  @override
  String get cuidadorPreguntaCabecera => 'Una pregunta per al sopar';

  @override
  String get cuidadorMetricasCabecera => 'Aquesta setmana';

  @override
  String cuidadorMetricaObservaciones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count observacions',
      one: 'Una observació',
      zero: 'Sense observacions',
    );
    return '$_temp0';
  }

  @override
  String cuidadorMetricaMisterios(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Misteris',
      one: 'Un Misteri',
      zero: 'Sense Misteris ancorats',
    );
    return '$_temp0';
  }

  @override
  String cuidadorMetricaSitSpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visites al sit spot',
      one: 'Una visita al sit spot',
      zero: 'Sense visites al sit spot',
    );
    return '$_temp0';
  }

  @override
  String get cuidadorSincronizarBoton => 'Compartir resum amb l\'adult';

  @override
  String get cuidadorSincronizarEnVuelo => 'Demanant-ho…';

  @override
  String get cuidadorSincronizarSinToken =>
      'Encara no hi ha compte vinculat amb el servidor. Quan n\'hi hagi, aquest botó demanarà un resum escrit.';

  @override
  String get cuidadorSincronizarErrorRed =>
      'Avui no s\'ha pogut connectar. Pots tornar-ho a provar més tard.';

  @override
  String get cuidadorSincronizarSinResumen =>
      'El servidor no ha pogut generar un resum aquesta vegada. La pregunta de sota continua valent.';

  @override
  String get cuidadorResumenCabecera => 'Aquesta setmana, en una frase';

  @override
  String get crearSitSpotPermisoDenegadoPermanente =>
      'No s\'ha pogut demanar permís. Si vols ancorar la posició, canvia-ho als ajustos del telèfon.';

  @override
  String get crearSitSpotSinPermisoUbicacion =>
      'Sense permís d\'ubicació. Pots continuar sense ell.';

  @override
  String get crearSitSpotErrorLocalizar =>
      'No s\'ha pogut localitzar la posició. Pots continuar sense ella.';

  @override
  String get crearSitSpotPrePermisoTitulo =>
      'Ancorar la posició al teu sit spot';

  @override
  String get crearSitSpotPrePermisoMensaje =>
      'La posició es queda en aquest quadern i no surt a internet. L\'adult no la veu. És opcional — el sit spot funciona sense ella.';

  @override
  String get crearSitSpotPrePermisoCancelar => 'cancel·lar';

  @override
  String get crearSitSpotPrePermisoAnclar => 'ancorar';

  @override
  String get sitSpotsJubiladosTitulo => 'Sit spots d\'abans';

  @override
  String get misterioPaginaTitulo => 'Misteri';

  @override
  String get misterioBotonEvidencia => 'anotar evidència per a aquest misteri';

  @override
  String get misterioBotonCerrar =>
      'ja tinc la meva resposta sobre aquest Misteri';

  @override
  String get misterioCabeceraEvidencia => 'El que ja has anotat';

  @override
  String get misterioPaginaEvidenciaVacia =>
      'Encara no has anotat res per a aquest misteri. Quan ho facis, apareixerà aquí.';

  @override
  String get misterioBloqueRespuesta => 'La teva resposta';

  @override
  String misterioCerradoEl(String fecha) {
    return 'Tancat el $fecha';
  }

  @override
  String get misterioReabrir => 'tornar a obrir aquest Misteri';

  @override
  String get misterioReabrirTitulo => 'Tornar a obrir aquest Misteri';

  @override
  String get misterioReabrirMensaje =>
      'Si el tornes a obrir, la teva resposta s\'esborra i el Misteri torna a la llista d\'oberts. Les anotacions que ja tenies es conserven.';

  @override
  String get misterioReabrirCancelar => 'No';

  @override
  String get misterioReabrirConfirmar => 'Tornar a obrir';

  @override
  String get misterioCerrarTitulo => 'La teva resposta';

  @override
  String get misterioCerrarCabeceraMisterio => 'El Misteri';

  @override
  String get misterioCerrarIntro =>
      'Explica amb les teves paraules el que has après sobre aquest Misteri. No hi ha resposta correcta — això no es corregeix ni es puntua; només es desa al teu quadern.';

  @override
  String get misterioCerrarPlaceholder =>
      'El que he après sobre aquest Misteri...';

  @override
  String get misterioCerrarBotonGuardar => 'desar la meva resposta';

  @override
  String get misterioCerrarBotonGuardando => 'desant...';

  @override
  String get misterioCerrarErrorGuardar =>
      'No s\'ha pogut desar la resposta. Torna-ho a provar.';

  @override
  String get observacionPrePermisoTitulo =>
      'Ancorar la posició a aquesta pàgina';

  @override
  String get observacionPrePermisoMensaje =>
      'La posició es queda en aquest quadern i no surt a internet. L\'adult no la veu. És opcional — pots desar la pàgina sense ella.';

  @override
  String get observacionPrePermisoCancelar => 'cancel·lar';

  @override
  String get observacionPrePermisoAnclar => 'ancorar';

  @override
  String get detalleObservacionTitulo => 'Pàgina del quadern';

  @override
  String get detalleObservacionTooltipOpciones => 'opcions de la pàgina';

  @override
  String get detalleObservacionMenuEditar => 'editar aquest registre';

  @override
  String get detalleObservacionMenuCompartirPdf =>
      'compartir aquesta pàgina com a PDF';

  @override
  String get detalleObservacionMenuBorrar => 'esborrar aquest registre';

  @override
  String get detalleObservacionBorrarTitulo => 'Esborrar aquest registre';

  @override
  String get detalleObservacionBorrarMensaje =>
      'Vas a esborrar aquesta pàgina del quadern. La foto i el dibuix, si en tenia, també s\'esborraran. No es pot desfer.';

  @override
  String get detalleObservacionBorrarCancelar => 'cancel·lar';

  @override
  String get detalleObservacionBorrarConfirmar => 'esborrar';

  @override
  String get listaObservacionesTitulo => 'Totes les teves pàgines';

  @override
  String get listaObservacionesPlaceholderBusqueda =>
      'cerca per alguna cosa que recordis';

  @override
  String get listaObservacionesLimpiarBusqueda => 'netejar cerca';

  @override
  String get listaObservacionesBusquedaSinResultados =>
      'Cap pàgina recull això. Prova amb una altra paraula.';

  @override
  String get sitSpotJubilarTitulo => 'Jubilar aquest sit spot';

  @override
  String sitSpotJubilarMensaje(String nombre) {
    return 'Vas a jubilar \"$nombre\". La pàgina continuarà desada al quadern. No podràs afegir més observacions a aquest sit spot, però sí crear-ne un de nou quan vulguis.';
  }

  @override
  String get sitSpotJubilarCancelar => 'cancel·lar';

  @override
  String get sitSpotJubilarConfirmar => 'retirar';

  @override
  String get sitSpotExplicacionCerrar => 'Tancar';

  @override
  String get preguntaReabrirCancelar => 'No';

  @override
  String get preguntaReabrirConfirmar => 'Tornar a obrir';

  @override
  String get preguntaBorrarCancelar => 'cancel·lar';

  @override
  String get preguntaBorrarConfirmar => 'esborrar';

  @override
  String get loginProfesorTitulo => 'Accés del professor';

  @override
  String get loginProfesorIntro =>
      'Aquesta pantalla és per a l\'adult que acompanya la classe. No es mostra al nen. El compte de professor es crea des del web; aquí només s\'hi vincula.';

  @override
  String get loginProfesorPlaceholderEmail => 'correu del professor';

  @override
  String get loginProfesorPlaceholderPassword => 'contrasenya';

  @override
  String get loginProfesorBotonEntrar => 'Iniciar sessió';

  @override
  String get loginProfesorEntrando => 'Entrant…';

  @override
  String get loginProfesorErrorVacio =>
      'Escriu el correu i la contrasenya abans de continuar.';

  @override
  String get loginProfesorErrorCredenciales =>
      'El correu o la contrasenya no coincideixen amb cap compte de professor.';

  @override
  String get loginProfesorErrorSinRol =>
      'Aquest compte no té perfil de professor. Si ets cuidador, busca aquest accés a part.';

  @override
  String get loginProfesorErrorRolInvalido =>
      'El servidor no ha acceptat la petició. Avisa l\'equip.';

  @override
  String get loginProfesorErrorRed =>
      'No s\'ha pogut connectar amb el servidor. Torna-ho a provar d\'aquí a una estona.';

  @override
  String get aulaProfesorTitulo => 'Aula';

  @override
  String get aulaProfesorTooltipCerrarSesion => 'tancar sessió';

  @override
  String get aulaProfesorCrearTitulo => 'Crea la teva primera aula';

  @override
  String get aulaProfesorCrearIntro =>
      'El servidor et donarà un codi que repartiràs a la classe. Cada nen s\'hi uneix des del seu quadern amb aquest codi.';

  @override
  String get aulaProfesorPlaceholderNombre => 'nom de l\'aula';

  @override
  String get aulaProfesorHintNombre => 'p. ex., 6è A · curs 2026/27';

  @override
  String get aulaProfesorJuegosCabecera => 'Jocs de l\'aula';

  @override
  String get aulaProfesorBotonCrear => 'Crear aula';

  @override
  String get aulaProfesorCreando => 'Creant…';

  @override
  String get aulaProfesorErrorVacio =>
      'Posa un nom a l\'aula i tria almenys un joc.';

  @override
  String get aulaProfesorErrorSesionCaducadaCrear =>
      'La sessió ha caducat. Torna a iniciar la sessió.';

  @override
  String get aulaProfesorErrorDatosInvalidos =>
      'Alguna dada de l\'aula no és vàlida. Revisa el nom i els jocs seleccionats.';

  @override
  String get aulaProfesorErrorCodigoUnico =>
      'No s\'ha pogut generar un codi únic per a l\'aula. Torna-ho a provar d\'aquí a una estona.';

  @override
  String aulaProfesorErrorGenerico(int codigo) {
    return 'No s\'ha pogut crear l\'aula (HTTP $codigo).';
  }

  @override
  String get aulaProfesorMensajeKMinimo =>
      'L\'aula necessita almenys cinc nens amb dades aquesta setmana perquè es vegin els agregats. Això protegeix la privacitat de la classe. Torna quan hi hagi més activitat.';

  @override
  String get aulaProfesorErrorSesionCaducadaCargar =>
      'La sessió ha caducat. Tanca sessió i torna a entrar.';

  @override
  String aulaProfesorErrorCargarAgregados(String error) {
    return 'No s\'han pogut carregar els agregats ($error).';
  }

  @override
  String aulaProfesorCodigoEtiqueta(String code) {
    return 'Codi de l\'aula: $code';
  }

  @override
  String aulaProfesorSemanaResumen(String iso, int reporting, int total) {
    return 'Setmana $iso · $reporting de $total amb dades';
  }

  @override
  String get preguntaCenaCuadernoEnReposo =>
      'Aquesta setmana el quadern ha descansat. Hi ha alguna cosa del lloc que us vingui de gust tornar a mirar a poc a poc?';

  @override
  String get preguntaCenaObservacionesSinAnclajes =>
      'Quina cosa petita ha aparegut aquesta setmana al quadern que abans no hi era?';

  @override
  String get preguntaCenaRegresoAlSitSpot =>
      'Aquesta setmana ha tornat al lloc de retorn. Què li ha sonat diferent allà?';

  @override
  String get preguntaCenaUnaPreguntaActiva =>
      'Aquesta setmana s\'ha quedat donant voltes a una pregunta. Quina compta avui?';

  @override
  String get preguntaCenaVariasPreguntasActivas =>
      'Aquesta setmana ha tingut diverses preguntes alhora. Quina de totes el té més enganxat ara mateix?';

  @override
  String get configuracionInicialEnlacePolitica =>
      'llegeix com es cuida el teu quadern';

  @override
  String get configuracionInicialPoliticaTitulo =>
      'com es cuida el teu quadern';

  @override
  String get crearSitSpotTitulo => 'El teu sit spot';

  @override
  String get crearSitSpotQuitarPosicion => 'treure la posició';

  @override
  String get paginaSitSpotBotonAnotar => 'anotar observació aquí';

  @override
  String get lienzoDibujoBotonGuardar => 'desar el dibuix';

  @override
  String get tarjetaSitSpotQueEs => 'què és un sit spot';

  @override
  String get tarjetaSitSpotJubilarOpcion => 'retirar aquest sit spot';

  @override
  String get editarObservacionTitulo => 'editar la pàgina';

  @override
  String get editarObservacionBotonGuardar => 'desar els canvis';

  @override
  String get chipSugerenciaMisterioNo => 'no';

  @override
  String get chipSugerenciaMisterioAnclar => 'vincular';

  @override
  String get homeBotonVerTodasPaginas => 'veure totes les teves pàgines';

  @override
  String get mapaBotonAbrirAjustes => 'obrir Configuració';

  @override
  String get mapaBotonEncender => 'encén el mapa';

  @override
  String get mapaConfirmarEncenderEncender => 'encén';

  @override
  String get mapaConfirmarEncenderCancelar => 'cancel·la';

  @override
  String get mapaBotonConfigurarSitSpot => 'configurar el sit spot';

  @override
  String get observacionQuitarPosicion => 'treure la posició';

  @override
  String get sitSpotsJubiladosVacio =>
      'Aquí apareixeran els sit spots que retiris. Les seves pàgines continuaran desades amb les seves observacions.';

  @override
  String sitSpotJubiladoPeriodoCreado(String desde) {
    return 'Creat el $desde.';
  }

  @override
  String sitSpotJubiladoPeriodoActivo(String desde, String hasta) {
    return 'Va ser actiu del $desde al $hasta.';
  }

  @override
  String get sitSpotJubiladoSinObservaciones => 'Sense observacions desades.';

  @override
  String get sitSpotJubiladoUnaObservacion => '1 observació desada';

  @override
  String sitSpotJubiladoVariasObservaciones(int cuenta) {
    return '$cuenta observacions desades';
  }

  @override
  String get sitSpotJubiladoPaginaVacia =>
      'No hi ha observacions desades en aquesta pàgina.';

  @override
  String get paginaSitSpotLoQueAnotaste => 'El que ja has anotat aquí';

  @override
  String get paginaSitSpotVacio =>
      'Encara no has anotat res en aquest sit spot. Quan ho facis, apareixerà aquí.';

  @override
  String paginaSitSpotActivoDesde(String desde) {
    return 'Actiu des del $desde.';
  }

  @override
  String get crearSitSpotIntro =>
      'Un sit spot és un lloc on tornes. El veus canviar amb el temps.';

  @override
  String get crearSitSpotEtiquetaNombre => 'com es diu el teu sit spot';

  @override
  String get crearSitSpotHintNombre =>
      'el roure gran, el meu banc, on vaig anar amb l\'àvia…';

  @override
  String get crearSitSpotEtiquetaDonde => 'on és, per recordar-ho (opcional)';

  @override
  String get crearSitSpotHintDonde =>
      'al final del parc, al costat del pi més alt';

  @override
  String get crearSitSpotBotonGuardar => 'desar el sit spot';

  @override
  String get crearSitSpotGuardando => 'desant…';

  @override
  String get crearSitSpotPosicionNoAnclada => 'Posició no vinculada';

  @override
  String get crearSitSpotPosicionAnclada => 'Posició vinculada al sit spot';

  @override
  String get crearSitSpotPosicionPrivada =>
      'La posició es queda en aquest quadern i no surt a internet.';

  @override
  String get crearSitSpotBotonAnclar => 'vincular la meva posició';

  @override
  String get crearSitSpotLocalizando => 'localitzant…';

  @override
  String get presentacionSitSpotTitulo => 'Un lloc que coneixes';

  @override
  String get presentacionSitSpotParrafo1 =>
      'En aquest quadern hi ha un lloc especial. El tries tu: un banc del parc, una pedra al costat del riu, un racó del jardí, una finestra.';

  @override
  String get presentacionSitSpotParrafo2 =>
      'L\'important no és que sigui bonic. És que hi puguis tornar. Si hi tornes moltes vegades, el veuràs canviar — les fulles, els ocells, la llum, els insectes. El quadern s\'omplirà del que hi passi.';

  @override
  String get presentacionSitSpotParrafo3 =>
      'Quan el trobis, li poses un nom. No cal que sigui un nom seriós.';

  @override
  String get presentacionSitSpotBotonTengoSitio => 'ja en penso un';

  @override
  String get presentacionSitSpotBotonTodaviaNo => 'encara no';

  @override
  String get acercaCabeceraNombre => 'El Quadern';

  @override
  String get acercaCabeceraSubtitulo =>
      'un quadern de camp digital — per a 9-13 anys';

  @override
  String get acercaCierre => 'la muntanya espera';

  @override
  String get acercaQueEsTitulo => 'què és això';

  @override
  String get acercaQueEsCuerpo =>
      'Un quadern de camp. És teu. El que escriguis aquí no s\'esborra sol i ningú no ho llegeix a la teva esquena.\n\nNo és un joc per guanyar. No té punts, ni ratxes, ni res que celebri res. És un lloc on deixar el que veus quan surts a mirar.';

  @override
  String get acercaPestanasTitulo => 'les quatre pestanyes';

  @override
  String get acercaPestanasCuerpo =>
      '**Quadern** — la salutació, el sit spot, els Misteris oberts i la darrera pàgina.\n\n**Mapa** — només si la persona adulta l\'encén a Configuració.\n\n**Misteris** — les teves preguntes i els Misteris del quadern. Aquí formules les teves amb el botó *\"formular pregunta\"*.\n\n**Tutor** — algú amb qui parlar quan no entens alguna cosa. No és un cercador d\'internet i no dona la resposta feta.';

  @override
  String get acercaAnotarTitulo => 'anotar una observació';

  @override
  String get acercaAnotarCuerpo =>
      'Quan veus alguna cosa que val la pena, l\'anotes. Una pàgina té tres camps importants:\n\n**Què has vist** — el que han vist els teus ulls. *\"Una papallona blanca amb taques marrons\"* és millor que *\"una pieris\"*. La identificació ve després.\n\n**Creus que és** — si creus que saps què era. Si no, ho deixes buit. Dir *\"no ho sé\"* és informació: significa que tornaràs a mirar.\n\n**Nivell de confiança** — tres opcions: *consens* (n\'estàs segur), *hipòtesi activa* (creus que ho saps però hauries de tornar a mirar), *no segura* (has vist alguna cosa, no saps què).';

  @override
  String get acercaSitSpotTitulo => 'el teu sit spot';

  @override
  String get acercaSitSpotCuerpo =>
      'El lloc on tornes moltes vegades. No cal que sigui bonic. Ha de ser teu: un banc del parc, una pedra al costat del riu, una branca gruixuda d\'un arbre del pati.\n\nSi sempre vas a llocs diferents, veus coses diferents. Si tornes al mateix lloc, veus **com canvia**.\n\nNo tens pressa per triar-lo. La presentació del quadern deixa explícit que es pot deixar per després.';

  @override
  String get acercaMisteriosTitulo => 'misteris i preguntes';

  @override
  String get acercaMisteriosCuerpo =>
      'Hi ha dos tipus de preguntes a la pestanya Misteris:\n\nEls **Misteris del quadern** els proposa el quadern, contextualitzats a la teva zona i a l\'estació. No has de resoldre\'ls tots.\n\n**Les teves preguntes** les formules tu. Si no se t\'acut com començar, hi ha un *\"necessito idees\"* amb cinc maneres possibles.\n\nQuan creguis que tens la teva resposta — no la resposta correcta del llibre de ciències, **la teva resposta** — la guardes. Aquí no hi ha resposta correcta: hi ha la teva resposta.';

  @override
  String get acercaNoHaceTitulo => 'el que aquest quadern NO fa';

  @override
  String get acercaNoHaceCuerpo =>
      'No té punts, nivells, ratxes, premis.\n\nNo envia notificacions. Quan et vingui de gust, l\'obres tu.\n\nNo celebra quan anotes alguna cosa. La teva observació és la celebració.\n\nNo et compara amb altres nens. No hi ha rànquings.\n\nNo et diu si alguna cosa està bé o malament. El que veus està bé per haver estat vist.';

  @override
  String get acercaPrivacidadTitulo => 'per al teu adult: privacitat';

  @override
  String get acercaPrivacidadCuerpo =>
      'Això és un hard limit no negociable: el quadern és del nen.\n\n**Només es queda al dispositiu, mai no creua xarxa:**\n· el text lliure de les observacions\n· les fotos\n· els dibuixos del llenç\n· les coordenades precises\n· les preguntes que formula\n· les respostes en tancar Misteris\n· el nom que ha triat\n\n**Només viatja al servidor amb sincronització opt-in:**\n· un *hash* de l\'observació (no el text)\n· el codi de regió provincial (no la posició)\n· un agregat setmanal amb recomptes per tipus, sense contingut\n· les preguntes al Tutor IA, si està activat, amb quota diària + ZDR + llista negra\n\n**El que la persona adulta pot veure:**\n· un paràgraf qualitatiu resumint la setmana, sense text literal\n· una pregunta suggerida per al sopar\n\n**El que la persona adulta no pot veure:** cap observació literal, cap foto, cap dibuix, cap coordenada, cap conversa amb el Tutor.';

  @override
  String get acercaAcompanarTitulo => 'per al teu adult: com acompanyar';

  @override
  String get acercaAcompanarCuerpo =>
      'El sit spot és el més important. Si la nena no se l\'ha apropiat, no tornarà. Que el triï ella. Si encara no en troba cap, no té pressa.\n\nUna observació a la setmana és bon ritme. Hi ha setmanes amb zero observacions — això també està bé. La bíblia del projecte: *tancament amable i ritme respectuós.*\n\nSi actives el resum setmanal a Configuració, rebràs una pregunta suggerida per al sopar. Està pensada perquè sigui més fàcil començar conversa, no per auditar.\n\n**El que és millor no fer:**\n· llegir el seu quadern per sobre l\'espatlla\n· demanar que demostri el que ha après\n· corregir si identifica malament — la propera vegada compararà i es corregirà sola\n· felicitar efusivament quan anota — converteix l\'ofici en performance';

  @override
  String get acercaTutorTitulo => 'per al teu adult: el Tutor';

  @override
  String get acercaTutorCuerpo =>
      'Assistent conversacional limitat per regles. La bíblia del projecte li posa cinc bumpers:\n\n**ZDR** — el proveïdor del model no entrena amb les converses ni les reté.\n\n**Sense memòria entre converses.** Cada obertura comença neta.\n\n**Llista negra de temes.** Hi ha temes (sexualitat, violència, drogues, autolesió, dades personals) que el Tutor no continua. Redirigeix amable i al cap de pocs torns tanca.\n\n**Quota de 30 torns al dia.** Quan s\'arriba, el Tutor respon *\"parlem demà\"*. Bumper deliberat contra l\'efecte addictiu.\n\n**No dona respostes fetes.** Està preparat per tornar la pregunta al lloc.';

  @override
  String get acercaAulaTitulo => 'per a l\'aula: vista del docent';

  @override
  String get acercaAulaCuerpo =>
      'Quan aquest quadern s\'utilitza a classe, la persona docent accedeix a un panell agregat des de Configuració → *\"Accedir com a professor\"*. El que veu:\n\n· recompte agregat de l\'activitat de la seva aula\n· distribució per dominis (presència, observació, registre, identificació, relacions, cicles, hàbitats, hipòtesis, teixit)\n\n**Mai el contingut literal de les observacions de cap nen.**\n\nLlindar mínim: **k≥5**. Si en un domini hi ha menys de 5 alumnes amb dades, aquesta dada s\'oculta perquè no sigui possible deduir el comportament d\'una nena concreta.\n\nAquesta part està pendent de tancar la policy escolar definitiva amb la regulació europea per a menors a les aules.';

  @override
  String get acercaIdiomasTitulo => 'idiomes';

  @override
  String get acercaIdiomasCuerpo =>
      'Castellà, èuscar i català des del primer arrencament. La traducció d\'èuscar i català està pendent de revisió per parlants natives amb criteri terminològic naturalista.';

  @override
  String get acercaLicenciaTitulo => 'llicència';

  @override
  String get acercaLicenciaCuerpo =>
      'Codi AGPL-3.0. Contingut (textos, il·lustracions, catàleg de Misteris) CC-BY-SA 4.0. Sense tracking, sense anuncis, sense monetització. Privacitat per disseny.';

  @override
  String get tarjetaMisterioContadorVacio => 'encara no has anotat res';

  @override
  String get tarjetaMisterioContadorUna => '1 evidència anotada';

  @override
  String tarjetaMisterioContadorVarias(int n) {
    return '$n evidències anotades';
  }

  @override
  String tarjetaMisterioPrefijoCaliente(String base) {
    return 'aquests dies · $base';
  }

  @override
  String get tarjetaSitSpotOpcionesTooltip => 'opcions del sit spot';

  @override
  String get editarObservacionEtiquetaDonde => 'on eres';

  @override
  String get lienzoTooltipDeshacer => 'desfer';

  @override
  String get lienzoTooltipBorrar => 'esborrar i començar de nou';

  @override
  String get lienzoAnchoFino => 'traç fi';

  @override
  String get lienzoAnchoMedio => 'traç mitjà';

  @override
  String get lienzoAnchoGrueso => 'traç gruixut';

  @override
  String get lienzoHerramientaPlumilla => 'ploma';

  @override
  String get lienzoHerramientaLapicero => 'llapis';

  @override
  String get lienzoHerramientaCarboncillo => 'carbonet';

  @override
  String get lienzoHerramientaGoma => 'goma';

  @override
  String get lienzoColorTinta => 'tinta';

  @override
  String get lienzoColorSanguina => 'sangina';

  @override
  String get lienzoColorSepia => 'sèpia';

  @override
  String get lienzoColorOcre => 'ocre';

  @override
  String get lienzoColorVerdeBotanico => 'verd botànic';

  @override
  String get pdfPlantillaTituloCabecera => 'Quadern de camp';

  @override
  String pdfPlantillaTituloCabeceraConNombre(String nombre) {
    return 'Quadern de camp · $nombre';
  }

  @override
  String get pdfPlantillaAutorAnonimo => 'El Quadern';

  @override
  String pdfPlantillaPagina(int numero, int total) {
    return 'pàg. $numero de $total';
  }

  @override
  String pdfPlantillaSitSpot(String nombre) {
    return 'Sit spot: $nombre';
  }

  @override
  String get pdfPlantillaDiaHora => 'Dia i hora';

  @override
  String get pdfPlantillaDondeEstabas => 'On eres';

  @override
  String get pdfPlantillaQueViste => 'Què has vist';

  @override
  String get pdfPlantillaCreesQueEs => 'Creus que és';

  @override
  String get pdfPlantillaDibuja => 'Dibuixa';

  @override
  String get configuracionInicialPoliticaCuerpo =>
      'El teu quadern és teu. El que escrius, les fotos i els dibuixos que hi afegeixes, viuen només al teu dispositiu. No surten al servidor.\n\nNo hi ha anuncis. No es ven el que escrius a ningú. No hi ha ratxes, nivells ni recompenses que t\'empenyin a tornar: torna si vols, quan vulguis.\n\nSi una persona adulta vol ajudar-te a fer servir el Tutor real, o vol rebre un resum per parlar amb tu, ha d\'entrar a Configuració i prémer un botó cada vegada. Mai no passa sol. Mai no avisa ningú sense que tu ho sàpigues.\n\nQuan vulguis, a Configuració pots exportar tot el teu quadern com un arxiu i esborrar-lo del tot d\'aquest dispositiu.\n\nAquesta és una versió provisional escrita per l\'equip que està fent el quadern. Abans que la facin servir moltes persones, una persona experta en lleis la revisarà.';

  @override
  String get observacionMapaSonidosComenzar => 'mapa de sons';

  @override
  String get mapaSonidosTitulo => 'Mapa de sons';

  @override
  String get mapaSonidosIntroduccion =>
      'Queda\'t en un lloc una estona. Tu ets al centre. Cada so que sentis, marca\'l on et arriba: a prop, a mitja distància o lluny.';

  @override
  String get mapaSonidosAyuda =>
      'Toca el mapa per marcar. Toca una marca per treure-la.';

  @override
  String get mapaSonidosCentro => 'tu';

  @override
  String get mapaSonidosDelante => 'davant';

  @override
  String get mapaSonidosGuardar => 'desar mapa';

  @override
  String get mapaSonidosDeshacer => 'desfer';

  @override
  String get mapaSonidosTipoPajaro => 'ocell';

  @override
  String get mapaSonidosTipoInsecto => 'insecte';

  @override
  String get mapaSonidosTipoAgua => 'aigua';

  @override
  String get mapaSonidosTipoViento => 'vent';

  @override
  String get mapaSonidosTipoHojas => 'fulles';

  @override
  String get mapaSonidosTipoAnimal => 'un altre animal';

  @override
  String get mapaSonidosTipoPersona => 'persones';

  @override
  String get mapaSonidosTipoMaquina => 'màquina';

  @override
  String get mapaSonidosTipoNoSe => 'no sé què és';

  @override
  String get paletaLugarTitulo => 'Els colors d\'aquest lloc';

  @override
  String get paletaLugarExplicacion =>
      'Surten de les teves fotos d\'aquí, estació a estació.';

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
  String get estacionVerano => 'estiu';

  @override
  String get estacionOtono => 'tardor';

  @override
  String get estacionInvierno => 'hivern';
}
