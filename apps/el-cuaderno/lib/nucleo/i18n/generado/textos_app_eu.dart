// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'textos_app.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class TextosAppEu extends TextosApp {
  TextosAppEu([String locale = 'eu']) : super(locale);

  @override
  String get tituloApp => 'Koadernoa';

  @override
  String get subtituloBienvenida =>
      'Zure inguruan ikusten duzun bizia idazteko tresna.';

  @override
  String get saludoSinNombre => 'Kaixo.';

  @override
  String saludoConNombre(String nombre) {
    return 'Kaixo, $nombre.';
  }

  @override
  String get navCuaderno => 'koadernoa';

  @override
  String get navMapa => 'mapa';

  @override
  String get navMisterios => 'misterioak';

  @override
  String get navTutor => 'tutorea';

  @override
  String get seccionSitSpot => 'Zure sit spot-a';

  @override
  String get seccionMisteriosAbiertos => 'Misterio irekiak';

  @override
  String get seccionUltimaPagina => 'Azken orria';

  @override
  String get sitSpotInvitacion =>
      'Aire zabalean atsegin zaizun toki batean zaudenean — parke bat, zuhaitz bat, kale-kantoi bat — zure sit spot bihurtu dezakezu. Sakatu hemen han zaudenean.';

  @override
  String sitSpotUltimaVisita(String cuando) {
    return 'Azken bisita: $cuando';
  }

  @override
  String get ultimaPaginaVacia =>
      'Oraindik ez duzu ezer idatzi. Egiten duzunean, hemen agertuko da.';

  @override
  String get misteriosVacio =>
      'Oraindik ez daukazu misteriorik irekita. Sistemak laster proposatuko dizu bat.';

  @override
  String get misteriosFueraDeContexto =>
      'Gaur ez dago misteriorik zure lekurako eta urtaro honetarako. Eguraldia aldatzean berriro begiratu.';

  @override
  String get navProximamente => 'Laster etorriko da.';

  @override
  String get homeFabAnotar => 'idatzi';

  @override
  String get homeFabAnotarTooltip => 'ikusten duzuna idatzi';

  @override
  String get homeOrientacionConMisterios =>
      'Hauek dira zure koadernoak irekita dauzkan misterioak. Ireki itzazu irakurtzeko; zure sit spot-ean haiekin zerikusia duen zerbait ikusten duzunean, idatzi.';

  @override
  String get seccionTusPreguntas => 'Zure galderak';

  @override
  String get seccionMisteriosDelCuaderno => 'Koadernoaren misterioak';

  @override
  String get tusPreguntasVacio =>
      'Oraindik ez duzu galderarik egin. Zure tokia behatzen ari zarela bururatzen zaizunean, hemen idatzi.';

  @override
  String get preguntaFabFormular => 'galdera egin';

  @override
  String get preguntaFormularTitulo => 'Zure galdera';

  @override
  String get preguntaFormularIntro =>
      'Zure galdera bat. Buruan dabilkizuna, oraintxe bururatu zaizuna, inork esan ez dizuna. Idatzi datorkizun bezala; ez du ondo eginda egon beharrik — zurea izan behar du, besterik ez.';

  @override
  String get preguntaFormularPlaceholder => '…?';

  @override
  String get preguntaFormularBotonGuardar => 'Nire galdera gorde';

  @override
  String get preguntaFormularBotonIdeas => 'ideiak behar ditut';

  @override
  String get preguntaIdeasTitulo => 'Abiapuntu bat behar baduzu';

  @override
  String get preguntaIdeasIntro =>
      'Ez duzu inola ere erabili behar. Baten batek laguntzen badizu, sakatu eta hortik abiatu.';

  @override
  String get preguntaIdea1 => '¿beti … noiz …?';

  @override
  String get preguntaIdea2 => '¿zer gertatzen da … denean?';

  @override
  String get preguntaIdea3 => '¿…ren antza al du …?';

  @override
  String get preguntaIdea4 => '¿nola aldatzen da … denborarekin?';

  @override
  String get preguntaIdea5 => '¿zer egiten du …k … denean?';

  @override
  String get preguntaPaginaTitulo => 'Zure galdera';

  @override
  String preguntaPaginaFormulada(String fecha) {
    return 'Egindako data: $fecha';
  }

  @override
  String get preguntaPaginaEvidenciaVacia =>
      'Oraindik ez duzu ezer idatzi zure galderari buruz. Itzuli tokira eta begiratu; zerikusia duen zerbait ikusten duzunean, idatzi eta hona ekarri.';

  @override
  String get preguntaPaginaCabeceraEvidencia => 'Dagoeneko idatzi duzuna';

  @override
  String get preguntaPaginaBorrar => 'galdera hau ezabatu';

  @override
  String get preguntaPaginaConfirmaBorrar =>
      'Zure galdera hau ezabatu egingo duzu. Lotuta zenituen behaketak koadernoan gordeko dira. Ezin da desegin.';

  @override
  String get preguntaPaginaBotonEvidencia => 'galdera honentzako froga idatzi';

  @override
  String get preguntaPaginaBotonCerrar =>
      'galdera honi buruzko erantzuna badaukat';

  @override
  String get preguntaCerrarTitulo => 'Zure erantzuna';

  @override
  String get preguntaCerrarIntro =>
      'Zure hitzekin kontatu zer ikasi duzun. Ez dago erantzun zuzenik — hau ez da zuzentzen ezta ebaluatzen ere; zure koadernoan gordetzen da, besterik ez.';

  @override
  String get preguntaCerrarPlaceholder => 'zure erantzuna';

  @override
  String get preguntaCerrarBoton => 'Nire erantzuna gorde';

  @override
  String get preguntaPaginaBloqueRespuesta => 'Zure erantzuna';

  @override
  String preguntaPaginaCerradaEl(String fecha) {
    return 'Itxitako data: $fecha';
  }

  @override
  String get preguntaPaginaReabrir => 'galdera hau berriro ireki';

  @override
  String get preguntaPaginaConfirmaReabrir =>
      'Berriro irekitzen baduzu, zure erantzuna ezabatu egingo da eta galdera irekien zerrendara itzuliko da. Lehendik zenituen oharrak gordeko dira.';

  @override
  String get observacionTitulo => 'behaketa berria';

  @override
  String observacionCabecera(String hora) {
    return 'Gaur · $hora';
  }

  @override
  String get observacionCajaFoto => 'argazkia';

  @override
  String get observacionCajaDibujo => 'marrazkia';

  @override
  String get observacionCajaPlaceholder =>
      'Nahi baduzu, gehitu argazki bat edo marrazki bat.';

  @override
  String get observacionFotoTomar => 'argazkia atera';

  @override
  String get observacionFotoElegir => 'argazkia aukeratu';

  @override
  String get observacionFotoQuitar => 'argazkia kendu';

  @override
  String get observacionDibujoComenzar => 'marrazkia egin';

  @override
  String get observacionDibujoQuitar => 'marrazkia kendu';

  @override
  String get observacionEtiquetaQueViste => 'zer ikusi duzu';

  @override
  String get observacionPlaceholderQueViste =>
      'deskribatu ikusi duzuna, izenik gabe ziur ez bazaude';

  @override
  String get observacionEtiquetaCreesQueEs => 'zer dela uste duzu';

  @override
  String get observacionPlaceholderCreesQueEs =>
      'nahi baduzu, izen bat proposatu';

  @override
  String get confianzaConsenso => 'adostasuna';

  @override
  String get confianzaHipotesisActiva => 'hipotesi aktiboa';

  @override
  String get confianzaNoSegura => 'ez nago ziur';

  @override
  String get confianzaConsensoTooltip =>
      'gida batekin edo Tutorearekin egiaztatu duzu';

  @override
  String get confianzaNoSeguraTooltip =>
      'ez da ezer gertatzen, idatz ezazu horrela';

  @override
  String get observacionAvisoFalta => 'egin ohar bat gorde aurretik';

  @override
  String get observacionBotonGuardar => 'Koadernoan gorde';

  @override
  String get tutorSaludoCanonico =>
      'Koadernoaren Tutorea naiz. Galdetu behar duzuna.';

  @override
  String get tutorPlaceholderInput => 'idatzi zure galdera';

  @override
  String get tutorBotonEnviar => 'Bidali';

  @override
  String get tutorRespuestaCanned =>
      'Tutorea oraindik ez dago konektatuta. Itzuli aste batzuetan.';

  @override
  String get tutorErrorRed =>
      'Une honetan ezin dut koadernora iritsi. Itxaron une bat eta saiatu berriro.';

  @override
  String get ajustesTitulo => 'Ezarpenak';

  @override
  String get atlasTitulo => 'Zure atlasa';

  @override
  String get atlasSubtitulo => 'ez da garaikurra. ikusi duzuna da.';

  @override
  String get atlasSeccionPrimerasVeces => 'Zure lehen aldiak';

  @override
  String get atlasSeccionLoQueHasVisto => 'Ikusi duzuna';

  @override
  String get atlasConteoSingular => 'behin';

  @override
  String atlasConteoPlural(int conteo) {
    return '$conteo aldiz';
  }

  @override
  String get atlasVacioCabecera => 'Zure atlasa hutsik dago oraindik.';

  @override
  String get atlasVacioCuerpo =>
      'Ikusten duzula uste duzuna idazten joan ahala, hau berez beteko da. Ez da presarik.';

  @override
  String get atlasEnlaceDesdeCuaderno => 'zure atlasa ikusi';

  @override
  String get seccionEcos => 'Aspaldi, hemen';

  @override
  String get ecoCabeceraUnMes => 'duela hilabete, garai honetan…';

  @override
  String get ecoCabeceraSeisMeses => 'duela sei hilabete, garai honetan…';

  @override
  String get ecoCabeceraUnAno => 'duela urtebete, garai honetan…';

  @override
  String get paginaSitSpotResumenMesCabecera => 'Hilabete honetan hemen';

  @override
  String paginaSitSpotResumenMesVisitas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aldiz etorri zara hilabete honetan.',
      two: 'Bi aldiz etorri zara hilabete honetan.',
      one: 'Behin etorri zara hilabete honetan.',
    );
    return '$_temp0';
  }

  @override
  String paginaSitSpotResumenMesPrimeraUltima(String primera, String ultima) {
    return 'Lehena: $primera. Azkena: $ultima.';
  }

  @override
  String get lecturaTitulo => 'Zure orriak irakurri';

  @override
  String get lecturaTooltip => 'zure orriak irakurri';

  @override
  String lecturaPaginaIndicador(int pagina, int total) {
    return '$pagina / $total';
  }

  @override
  String get lecturaVacioCuerpo =>
      'Oraindik ez duzu ezer idatzi. Egiten duzunean, zure koadernoa liburu baten moduan irekitzeko aukera izango duzu.';

  @override
  String get ajustesMapaOnlineEtiqueta => 'Mapa aktibatu';

  @override
  String get ajustesMapaOnlineCuerpo =>
      'Aktibatzen baduzu, gailua interneten konektatuko da zauden munduko zatia erakusteko. \"Mapa\" fitxak hori piztuta egonez gero bakarrik funtzionatzen du. Aurrerago mapa behin deskargatu ahalko da eta ez da gehiago internetera joango.';

  @override
  String get detalleCompartirFotoOpcion => 'argazkia helduarekin partekatu';

  @override
  String get detalleCompartirFotoTextoAdjunto =>
      'Begira zer ikusi dudan nire koadernoan. Badakizu zer den?';

  @override
  String get compararVisitasTitulo => 'Bi bisita konparatu';

  @override
  String get compararVisitasEnlace => 'bi bisita konparatu';

  @override
  String get compararVisitasIntro => 'aukeratu bi une. ikusi zer aldatu den.';

  @override
  String get compararVisitasColumnaIzquierda => 'lehen unea';

  @override
  String get compararVisitasColumnaDerecha => 'bigarren unea';

  @override
  String get compararVisitasInsuficientesCabecera =>
      'Bi bisita behar dituzu konparatzeko.';

  @override
  String get compararVisitasInsuficientesCuerpo =>
      'Beste egun batean zure sit spot-era itzultzen zarenean eta zerbait idazten duzunean, lehen ikusten zenuena oraingoarekin konparatu ahal izango duzu.';

  @override
  String get imprimirPlantillaBloque => 'Landa lanerako orri zuriak inprimatu';

  @override
  String get imprimirPlantillaBloqueDescripcion =>
      'PDF bat sortzen du paperezko koadernoa irteera batean eramateko. Pantailarik gabe, bateriarik gabe.';

  @override
  String get imprimirPlantillaTitulo => 'Landa lanerako orriak';

  @override
  String get imprimirPlantillaIntro =>
      'Batzuetan landa lana hobeto begiratzen da pantailarik gabe. Hemen prestatzen duzu paperezko koadernoa motxilan eramateko.';

  @override
  String get imprimirPlantillaContenido =>
      'Orri bakoitzak du data, non zinen, zer ikusi duzun, zer dela uste duzun eta marrazkirako lauki handi bat idazteko lekua.';

  @override
  String get imprimirPlantillaSelectorCabecera => 'Zenbat orri';

  @override
  String imprimirPlantillaOpcionPaginas(int paginas) {
    return '$paginas orri';
  }

  @override
  String get imprimirPlantillaBoton => 'Inprimatu edo partekatu';

  @override
  String get imprimirPlantillaNotaFinal =>
      'Inprimagailurik ez baduzu, PDFa mugikorrean gorde eta inprimagailua daukan norbaiti erakutsi diezaiokezu.';

  @override
  String get detalleObservacionPrimeraVez =>
      'lehen aldia idazten duzu honelako zerbait koadernoan.';

  @override
  String get acercaTitulo => 'Koaderno hau nola erabili';

  @override
  String get acercaBloque => 'Koaderno hau nola erabili';

  @override
  String get acercaBloqueDescripcion =>
      'Zer den, nola idatzi, nola lagundu. Zuretzat, zure helduarentzat eta zure irakaslearentzat.';

  @override
  String ajustesIdiomaActual(String idioma) {
    return 'Koadernoaren hizkuntza: $idioma';
  }

  @override
  String get ajustesIdiomaCambiar => 'Hizkuntza aldatu';

  @override
  String get ajustesExportar => 'Nire koadernoa esportatu';

  @override
  String get ajustesExportarDescripcion =>
      'Jaso zure behaketen eta Misterioen kopia irakurgarri bat. Koadernoa zurea da.';

  @override
  String get ajustesExportarPdf => 'PDF gisa esportatu';

  @override
  String get ajustesExportarPdfDescripcion =>
      'Inprimatzeko edo paperera eramateko kopia bat. Sistemak galdetuko dizu non gorde.';

  @override
  String get ajustesExportarDialogoTitulo => 'Zure koadernoa testu gisa';

  @override
  String get ajustesExportarDialogoCerrar => 'Itxi';

  @override
  String get ajustesVistaCuidador => 'Zaintzailearen ikuspegia';

  @override
  String get ajustesVistaCuidadorDescripcion =>
      'Lagun egiten dizun heldu batentzako orri diskretu bat.';

  @override
  String get ajustesBorrar => 'Nire koadernoa ezabatu';

  @override
  String get ajustesBorrarDescripcion =>
      'Zure behaketa, Misterio eta sit spot guztiak ezabatu. Ezin da desegin.';

  @override
  String get ajustesBorrarDialogoTitulo => 'Dena ezabatu?';

  @override
  String ajustesBorrarDialogoCuerpo(
      int observaciones, int misterios, int sitSpots) {
    return 'Jarraitzen baduzu, $observaciones behaketa, $misterios Misterio eta $sitSpots sit spot ezabatuko dira. Ezin da desegin.';
  }

  @override
  String get ajustesBorrarDialogoSeguir => 'Jarraitu';

  @override
  String get ajustesBorrarDialogoCancelar => 'Bertan behera utzi';

  @override
  String get ajustesBorrarConfirmacionTitulo => 'Ziur zaude?';

  @override
  String get ajustesBorrarConfirmacionCuerpo =>
      'Idatzi «ezabatu» behean berresteko.';

  @override
  String get ajustesBorrarConfirmacionPalabra => 'ezabatu';

  @override
  String get ajustesBorrarConfirmacionPlaceholder => 'idatzi hitza';

  @override
  String get ajustesBorrarConfirmacionBoton => 'Dena ezabatu';

  @override
  String get ajustesBorradoCompleto => 'Eginda. Zure koadernoa hutsik dago.';

  @override
  String get bienvenidaTitulo => 'Nola duzu izena?';

  @override
  String get bienvenidaCuerpo =>
      'Zure izena koaderno honetan geratzen da. Ez da zerbitzarira joaten zuk gero lotzea erabakitzen ez baduzu.';

  @override
  String get bienvenidaPlaceholderNombre => 'zure izena';

  @override
  String get bienvenidaBotonContinuar => 'Jarraitu';

  @override
  String get ajustesSyncObsTitulo => 'Nire behaketak sinkronizatu';

  @override
  String get ajustesSyncObsDescripcion =>
      'Igo behaketa berriak zerbitzariko zure kontura, gailuz aldatzen baduzu galdu ez daitezen.';

  @override
  String get ajustesSyncObsBoton => 'Orain igo';

  @override
  String get ajustesSyncObsEnVuelo => 'Igotzen…';

  @override
  String get ajustesSyncObsSinToken =>
      'Oraindik ez dago konturik zerbitzariarekin lotuta. Lotzen denean, botoi honek zure behaketak igoko ditu.';

  @override
  String get ajustesSyncObsNadaPendiente =>
      'Ez dago behaketa zain — dena igota.';

  @override
  String ajustesSyncObsTodasEnviadas(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count behaketa igo dira.',
      one: 'Behaketa bat igo da.',
    );
    return '$_temp0';
  }

  @override
  String ajustesSyncObsParcial(int enviadas, int pendientes) {
    return 'Igota: $enviadas. Hurrengo saiakeran: $pendientes.';
  }

  @override
  String ajustesSyncObsRechazadas(int enviadas, int rechazadas) {
    return 'Igota: $enviadas. Zerbitzariak $rechazadas ezetsi ditu. Berriz ireki itzazu berrikusteko.';
  }

  @override
  String get ajustesCuentaTitulo => 'Helduaren kontua';

  @override
  String get ajustesCuentaDescripcion =>
      'Nuevo Ser-eko konturen bat baduzu, hemen lotu dezakezu. Zure behaketak igotzeko, zaintzailearen idatzizko laburpena jasotzeko eta benetako Tutorea konektatzeko balio du.';

  @override
  String get ajustesCuentaPlaceholderEmail => 'helduaren posta';

  @override
  String get ajustesCuentaPlaceholderPassword => 'pasahitza';

  @override
  String get ajustesCuentaBotonEntrar => 'Saioa hasi';

  @override
  String get ajustesCuentaEntrando => 'Sartzen…';

  @override
  String ajustesCuentaSesionIniciada(String email) {
    return 'Saioa hasita: $email.';
  }

  @override
  String get ajustesCuentaSesionIniciadaSinEmail => 'Saioa hasita.';

  @override
  String get ajustesCuentaCerrarSesion => 'Saioa itxi';

  @override
  String get ajustesCuentaErrorCredenciales =>
      'Postak edo pasahitzak ez datoz bat inolako konturekin.';

  @override
  String get ajustesCuentaErrorSinPerfil =>
      'Helduaren kontuak ez du oraindik haurrik lotuta.';

  @override
  String get ajustesCuentaErrorRed =>
      'Ezin izan da zerbitzariarekin konektatu. Une batean saiatu berriro.';

  @override
  String get ajustesCuentaErrorVacio =>
      'Idatzi posta eta pasahitza jarraitu aurretik.';

  @override
  String get ajustesTutorDebugTitulo => 'Tutorea (debug)';

  @override
  String get ajustesTutorDebugDescripcion =>
      'Itsatsi hemen backend-eko tokena benetako Tutorea aktibatzeko. Debug moduan bakarrik agertzen da.';

  @override
  String get ajustesTutorDebugPlaceholder => 'Backend-eko JWTa';

  @override
  String get ajustesTutorDebugBotonGuardar => 'Tokena gorde';

  @override
  String get ajustesTutorDebugBotonBorrar => 'Tokena ezabatu';

  @override
  String get ajustesTutorDebugGuardado =>
      'Tokena gorde da. Itzuli Tutorera probatzeko.';

  @override
  String get ajustesTutorDebugBorrado =>
      'Tokena ezabatu da. Tutoreak erantzun kanonikora itzuliko da.';

  @override
  String get cuidadorTitulo => 'Zaintzailearen orria';

  @override
  String get cuidadorAviso =>
      'Hau da jokoak laguntzen zaituenarekin partekatzen duen ikuspegi bakarra. Ez ditu zure behaketak ikusiko, ezta idazten duzuna ere — laburpen hau eta hitz egiteko galdera bat baino ez.';

  @override
  String cuidadorSemanaActual(String isoWeek) {
    return '$isoWeek astea';
  }

  @override
  String get cuidadorPreguntaCabecera => 'Afarirako galdera bat';

  @override
  String get cuidadorMetricasCabecera => 'Aste honetan';

  @override
  String cuidadorMetricaObservaciones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count behaketa',
      one: 'Behaketa bat',
      zero: 'Behaketarik ez',
    );
    return '$_temp0';
  }

  @override
  String cuidadorMetricaMisterios(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Misterio',
      one: 'Misterio bat',
      zero: 'Misteriorik gabe lotuta',
    );
    return '$_temp0';
  }

  @override
  String cuidadorMetricaSitSpot(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bisita sit spot-era',
      one: 'Bisita bat sit spot-era',
      zero: 'Sit spot-erako bisitarik ez',
    );
    return '$_temp0';
  }

  @override
  String get cuidadorSincronizarBoton => 'Laburpena helduarekin partekatu';

  @override
  String get cuidadorSincronizarEnVuelo => 'Eskatzen…';

  @override
  String get cuidadorSincronizarSinToken =>
      'Oraindik ez dago konturik zerbitzariarekin lotuta. Lotzen denean, botoi honek idatzizko laburpena eskatuko du.';

  @override
  String get cuidadorSincronizarErrorRed =>
      'Gaur ezin izan da konektatu. Geroago saiatu zaitezke berriro.';

  @override
  String get cuidadorSincronizarSinResumen =>
      'Zerbitzariak ezin izan du laburpenik sortu oraingoan. Beheko galderak balio du oraindik.';

  @override
  String get cuidadorResumenCabecera => 'Aste hau, esaldi batean';

  @override
  String get crearSitSpotPermisoDenegadoPermanente =>
      'Ezin izan da baimena eskatu. Posizioa lotu nahi baduzu, telefonoaren ezarpenetan aldatu.';

  @override
  String get crearSitSpotSinPermisoUbicacion =>
      'Kokapenerako baimenik gabe. Hala ere jarraitu dezakezu.';

  @override
  String get crearSitSpotErrorLocalizar =>
      'Ezin izan da posizioa kokatu. Hala ere jarraitu dezakezu.';

  @override
  String get crearSitSpotPrePermisoTitulo => 'Posizioa zure sit spot-era lotu';

  @override
  String get crearSitSpotPrePermisoMensaje =>
      'Posizioa koaderno honetan geratzen da eta ez da internetera ateratzen. Helduak ez du ikusten. Aukerakoa da — sit spot-ak posizioarik gabe ere funtzionatzen du.';

  @override
  String get crearSitSpotPrePermisoCancelar => 'bertan behera utzi';

  @override
  String get crearSitSpotPrePermisoAnclar => 'lotu';

  @override
  String get sitSpotsJubiladosTitulo => 'Lehengo sit spot-ak';

  @override
  String get misterioPaginaTitulo => 'Misterioa';

  @override
  String get misterioBotonEvidencia => 'misterio honentzako froga idatzi';

  @override
  String get misterioBotonCerrar => 'Misterio honi buruzko erantzuna badaukat';

  @override
  String get misterioCabeceraEvidencia => 'Dagoeneko idatzi duzuna';

  @override
  String get misterioPaginaEvidenciaVacia =>
      'Oraindik ez duzu ezer idatzi misterio honentzat. Egiten duzunean, hemen agertuko da.';

  @override
  String get misterioBloqueRespuesta => 'Zure erantzuna';

  @override
  String misterioCerradoEl(String fecha) {
    return 'Itxitako data: $fecha';
  }

  @override
  String get misterioReabrir => 'Misterio hau berriro ireki';

  @override
  String get misterioReabrirTitulo => 'Misterio hau berriro ireki';

  @override
  String get misterioReabrirMensaje =>
      'Berriro irekitzen baduzu, zure erantzuna ezabatu egingo da eta Misterioa berriz egongo da irekita. Lehendik zenituen oharrak gordeko dira.';

  @override
  String get misterioReabrirCancelar => 'Ez';

  @override
  String get misterioReabrirConfirmar => 'Berriro ireki';

  @override
  String get misterioCerrarTitulo => 'Zure erantzuna';

  @override
  String get misterioCerrarCabeceraMisterio => 'Misterioa';

  @override
  String get misterioCerrarIntro =>
      'Zure hitzekin kontatu zer ikasi duzun Misterio honi buruz. Ez dago erantzun zuzenik — hau ez da zuzentzen ezta ebaluatzen ere; zure koadernoan gordetzen da, besterik ez.';

  @override
  String get misterioCerrarPlaceholder => 'Misterio honi buruz ikasi dudana...';

  @override
  String get misterioCerrarBotonGuardar => 'nire erantzuna gorde';

  @override
  String get misterioCerrarBotonGuardando => 'gordetzen...';

  @override
  String get misterioCerrarErrorGuardar =>
      'Ezin izan da erantzuna gorde. Saiatu berriro.';

  @override
  String get observacionPrePermisoTitulo => 'Posizioa orri honi lotu';

  @override
  String get observacionPrePermisoMensaje =>
      'Posizioa koaderno honetan geratzen da eta ez da internetera ateratzen. Helduak ez du ikusten. Aukerakoa da — orria gorde dezakezu posizioarik gabe.';

  @override
  String get observacionPrePermisoCancelar => 'bertan behera utzi';

  @override
  String get observacionPrePermisoAnclar => 'lotu';

  @override
  String get detalleObservacionTitulo => 'Koadernoaren orria';

  @override
  String get detalleObservacionTooltipOpciones => 'orriaren aukerak';

  @override
  String get detalleObservacionMenuEditar => 'erregistro hau editatu';

  @override
  String get detalleObservacionMenuCompartirPdf =>
      'orri hau PDF gisa partekatu';

  @override
  String get detalleObservacionMenuBorrar => 'erregistro hau ezabatu';

  @override
  String get detalleObservacionBorrarTitulo => 'Erregistro hau ezabatu';

  @override
  String get detalleObservacionBorrarMensaje =>
      'Koadernoaren orri hau ezabatu egingo duzu. Argazkia eta marrazkia, izan baditu, ere ezabatu egingo dira. Ezin da desegin.';

  @override
  String get detalleObservacionBorrarCancelar => 'bertan behera utzi';

  @override
  String get detalleObservacionBorrarConfirmar => 'ezabatu';

  @override
  String get listaObservacionesTitulo => 'Zure orri guztiak';

  @override
  String get listaObservacionesPlaceholderBusqueda =>
      'gogoratzen duzun zerbait bilatu';

  @override
  String get listaObservacionesLimpiarBusqueda => 'bilaketa garbitu';

  @override
  String get listaObservacionesBusquedaSinResultados =>
      'Inolako orrik ez du hori jasotzen. Saiatu beste hitz batekin.';

  @override
  String get sitSpotJubilarTitulo => 'Sit spot hau erretiratu';

  @override
  String sitSpotJubilarMensaje(String nombre) {
    return '\"$nombre\" erretiratuko duzu. Orria koadernoan gordeko da. Ezin izango duzu sit spot honetara behaketa gehiago gehitu, baina beste berri bat sortu dezakezu nahi duzunean.';
  }

  @override
  String get sitSpotJubilarCancelar => 'bertan behera utzi';

  @override
  String get sitSpotJubilarConfirmar => 'erretiratu';

  @override
  String get sitSpotExplicacionCerrar => 'Itxi';

  @override
  String get preguntaReabrirCancelar => 'Ez';

  @override
  String get preguntaReabrirConfirmar => 'Berriro ireki';

  @override
  String get preguntaBorrarCancelar => 'bertan behera utzi';

  @override
  String get preguntaBorrarConfirmar => 'ezabatu';

  @override
  String get loginProfesorTitulo => 'Irakaslearen sarbidea';

  @override
  String get loginProfesorIntro =>
      'Pantaila hau gelarekin doan helduarentzat da. Ez zaio haurrari erakusten. Irakasle-kontua webgunean sortzen da; hemen lotzeko bakarrik balio du.';

  @override
  String get loginProfesorPlaceholderEmail =>
      'irakaslearen helbide elektronikoa';

  @override
  String get loginProfesorPlaceholderPassword => 'pasahitza';

  @override
  String get loginProfesorBotonEntrar => 'Saioa hasi';

  @override
  String get loginProfesorEntrando => 'Sartzen…';

  @override
  String get loginProfesorErrorVacio =>
      'Idatzi helbide elektronikoa eta pasahitza jarraitu aurretik.';

  @override
  String get loginProfesorErrorCredenciales =>
      'Helbide elektronikoa edo pasahitza ez datoz bat ezein irakasle-konturekin.';

  @override
  String get loginProfesorErrorSinRol =>
      'Kontu honek ez du irakasle-profilik. Zaintzailea bazara, bilatu sarbide hori beste leku batean.';

  @override
  String get loginProfesorErrorRolInvalido =>
      'Zerbitzariak ez du eskaera onartu. Esan taldeari.';

  @override
  String get loginProfesorErrorRed =>
      'Ezin izan da zerbitzariarekin konektatu. Saiatu une batean.';

  @override
  String get aulaProfesorTitulo => 'Gela';

  @override
  String get aulaProfesorTooltipCerrarSesion => 'saioa amaitu';

  @override
  String get aulaProfesorCrearTitulo => 'Sortu zure lehen gela';

  @override
  String get aulaProfesorCrearIntro =>
      'Zerbitzariak kode bat emango dizu, gelari banatzeko. Haur bakoitzak bere koadernotik kode horrekin sartzen da.';

  @override
  String get aulaProfesorPlaceholderNombre => 'gelaren izena';

  @override
  String get aulaProfesorHintNombre => 'adib., 6. A · 2026/27 ikasturtea';

  @override
  String get aulaProfesorJuegosCabecera => 'Gelaren jokoak';

  @override
  String get aulaProfesorBotonCrear => 'Gela sortu';

  @override
  String get aulaProfesorCreando => 'Sortzen…';

  @override
  String get aulaProfesorErrorVacio =>
      'Jarri izen bat gelari eta aukeratu joko bat gutxienez.';

  @override
  String get aulaProfesorErrorSesionCaducadaCrear =>
      'Saioa iraungi da. Berriz hasi saioa.';

  @override
  String get aulaProfesorErrorDatosInvalidos =>
      'Gelaren datu bat ez da baliozkoa. Berrikusi izena eta hautatutako jokoak.';

  @override
  String get aulaProfesorErrorCodigoUnico =>
      'Ezin izan da gelarako kode esklusibo bat sortu. Saiatu une batean.';

  @override
  String aulaProfesorErrorGenerico(int codigo) {
    return 'Ezin izan da gela sortu (HTTP $codigo).';
  }

  @override
  String get aulaProfesorMensajeKMinimo =>
      'Gelak gutxienez bost haur behar ditu astean datuekin agregatuak ikusteko. Horrek gelaren pribatutasuna babesten du. Etorri jarduera gehiago dagoenean.';

  @override
  String get aulaProfesorErrorSesionCaducadaCargar =>
      'Saioa iraungi da. Itxi saioa eta berriz sartu.';

  @override
  String aulaProfesorErrorCargarAgregados(String error) {
    return 'Ezin izan dira agregatuak kargatu ($error).';
  }

  @override
  String aulaProfesorCodigoEtiqueta(String code) {
    return 'Gelaren kodea: $code';
  }

  @override
  String aulaProfesorSemanaResumen(String iso, int reporting, int total) {
    return '$iso. astea · $reporting datuekin ${total}etik';
  }

  @override
  String get preguntaCenaCuadernoEnReposo =>
      'Aste honetan koadernoak atseden hartu du. Bada lekuko zerbait poliki begiratzera itzuli nahi duzuena?';

  @override
  String get preguntaCenaObservacionesSinAnclajes =>
      'Aste honetan koadernoan agertu den gauza txiki hura zer da, lehen ez zegoena?';

  @override
  String get preguntaCenaRegresoAlSitSpot =>
      'Aste honetan itzulera-lekura itzuli da. Zer entzun du han ezberdina?';

  @override
  String get preguntaCenaUnaPreguntaActiva =>
      'Aste honetan galdera bati buelta eta buelta eman dio. Zein da gaur garrantzitsuena?';

  @override
  String get preguntaCenaVariasPreguntasActivas =>
      'Aste honetan galdera batzuk izan ditu aldi berean. Zein du bereziki engantxatuta orain?';

  @override
  String get configuracionInicialEnlacePolitica =>
      'irakurri zure koaderno nola zaintzen den';

  @override
  String get configuracionInicialPoliticaTitulo =>
      'zure koaderno nola zaintzen den';

  @override
  String get crearSitSpotTitulo => 'Zure sit spota';

  @override
  String get crearSitSpotQuitarPosicion => 'kokapena kendu';

  @override
  String get paginaSitSpotBotonAnotar => 'hemen behaketa idatzi';

  @override
  String get lienzoDibujoBotonGuardar => 'marrazkia gorde';

  @override
  String get tarjetaSitSpotQueEs => 'zer da sit spota';

  @override
  String get tarjetaSitSpotJubilarOpcion => 'sit spot hau erretiratu';

  @override
  String get editarObservacionTitulo => 'orria editatu';

  @override
  String get editarObservacionBotonGuardar => 'aldaketak gorde';

  @override
  String get chipSugerenciaMisterioNo => 'ez';

  @override
  String get chipSugerenciaMisterioAnclar => 'lotu';

  @override
  String get homeBotonVerTodasPaginas => 'zure orri guztiak ikusi';

  @override
  String get mapaBotonAbrirAjustes => 'Ezarpenak ireki';

  @override
  String get mapaBotonEncender => 'mapa piztu';

  @override
  String get mapaConfirmarEncenderEncender => 'piztu';

  @override
  String get mapaConfirmarEncenderCancelar => 'utzi';

  @override
  String get mapaBotonConfigurarSitSpot => 'sit spota konfiguratu';

  @override
  String get observacionQuitarPosicion => 'kokapena kendu';

  @override
  String get sitSpotsJubiladosVacio =>
      'Hemen agertuko dira erretiratzen dituzun sit spotak. Beren orriak gordeta jarraituko dute beren behaketekin.';

  @override
  String sitSpotJubiladoPeriodoCreado(String desde) {
    return 'Sortua: $desde.';
  }

  @override
  String sitSpotJubiladoPeriodoActivo(String desde, String hasta) {
    return 'Aktibo egon zen ${desde}etik ${hasta}era.';
  }

  @override
  String get sitSpotJubiladoSinObservaciones => 'Behaketarik gabe.';

  @override
  String get sitSpotJubiladoUnaObservacion => 'Behaketa 1 gordeta';

  @override
  String sitSpotJubiladoVariasObservaciones(int cuenta) {
    return '$cuenta behaketa gordeta';
  }

  @override
  String get sitSpotJubiladoPaginaVacia =>
      'Orri honetan ez dago behaketarik gordeta.';

  @override
  String get paginaSitSpotLoQueAnotaste => 'Hemen idatzi duzuna';

  @override
  String get paginaSitSpotVacio =>
      'Sit spot honetan oraindik ez duzu ezer idatzi. Idazten duzunean, hemen agertuko da.';

  @override
  String paginaSitSpotActivoDesde(String desde) {
    return '${desde}etik aktibo.';
  }

  @override
  String get crearSitSpotIntro =>
      'Sit spot bat itzultzen zaren leku bat da. Denboran zehar aldatzen ikusten duzu.';

  @override
  String get crearSitSpotEtiquetaNombre => 'nola du izena zure sit spotak';

  @override
  String get crearSitSpotHintNombre =>
      'haritz handia, nire bankua, amonarekin joan nintzen lekua…';

  @override
  String get crearSitSpotEtiquetaDonde => 'non dagoen, gogoratzeko (aukerakoa)';

  @override
  String get crearSitSpotHintDonde => 'parke amaieran, pinu altuenaren ondoan';

  @override
  String get crearSitSpotBotonGuardar => 'sit spota gorde';

  @override
  String get crearSitSpotGuardando => 'gordetzen…';

  @override
  String get crearSitSpotPosicionNoAnclada => 'Kokapena lotu gabe';

  @override
  String get crearSitSpotPosicionAnclada => 'Kokapena sit spotari lotuta';

  @override
  String get crearSitSpotPosicionPrivada =>
      'Kokapena koaderno honetan geratzen da eta ez da internetera ateratzen.';

  @override
  String get crearSitSpotBotonAnclar => 'nire kokapena lotu';

  @override
  String get crearSitSpotLocalizando => 'kokatzen…';

  @override
  String get presentacionSitSpotTitulo => 'Ezagutzen duzun lekua';

  @override
  String get presentacionSitSpotParrafo1 =>
      'Koaderno honetan leku berezi bat dago. Zuk aukeratzen duzu: parkeko banku bat, ibaiaren ondoko harri bat, lorategiko txoko bat, leiho bat.';

  @override
  String get presentacionSitSpotParrafo2 =>
      'Garrantzitsuena ez da polita izatea. Garrantzitsuena itzuli ahal izatea da. Askotan itzultzen bazara, aldatzen ikusiko duzu — hostoak, txoriak, argia, zomorroak. Koadernoa bete egingo da han gertatzen denarekin.';

  @override
  String get presentacionSitSpotParrafo3 =>
      'Aurkitzen duzunean, izena jartzen diozu. Ez du zertan izen serioa izan.';

  @override
  String get presentacionSitSpotBotonTengoSitio => 'bat pentsatzen ari naiz';

  @override
  String get presentacionSitSpotBotonTodaviaNo => 'oraindik ez';

  @override
  String get acercaCabeceraNombre => 'Koadernoa';

  @override
  String get acercaCabeceraSubtitulo =>
      'landa-koaderno digitala — 9-13 urteko haurrentzat';

  @override
  String get acercaCierre => 'mendia zain dago';

  @override
  String get acercaQueEsTitulo => 'zer da hau';

  @override
  String get acercaQueEsCuerpo =>
      'Landa-koaderno bat. Zurea da. Hemen idazten duzuna ez da bere kabuz ezabatzen eta inork ez du irakurtzen zure atzean.\n\nEz da irabazteko jokoa. Ez du punturik, ez segidarik, ez ezer ospatzen duenik. Begiratzera ateratzen zarenean ikusten duzuna uzteko leku bat da.';

  @override
  String get acercaPestanasTitulo => 'lau fitxak';

  @override
  String get acercaPestanasCuerpo =>
      '**Koadernoa** — agurra, sit spota, irekita dauden Misterioak eta azken orria.\n\n**Mapa** — heldu pertsonak Ezarpenetan piztuz gero bakarrik.\n\n**Misterioak** — zure galderak eta koadernoaren Misterioak. Hemen formulatzen dituzu zureak *\"galdera formulatu\"* botoiarekin.\n\n**Tutorea** — zerbait ulertzen ez duzunean hitz egiteko norbait. Ez da interneteko bilatzaile bat eta ez du erantzun egina ematen.';

  @override
  String get acercaAnotarTitulo => 'behaketa bat idaztea';

  @override
  String get acercaAnotarCuerpo =>
      'Merezi duen zerbait ikusten duzunean, idatzi egiten duzu. Orri batek hiru eremu garrantzitsu ditu:\n\n**Zer ikusi duzu** — zure begiek ikusi dutena. *\"Tximeleta zuri bat orban marroiekin\"* hobea da *\"pieris bat\"* baino. Identifikazioa geroago etortzen da.\n\n**Zer dela uste duzun** — zer zen badakizula uste baduzu. Bestela, hutsik uzten duzu. *\"Ez dakit\"* esatea informazioa da: berriz begiratuko duzula esan nahi du.\n\n**Konfiantza-maila** — hiru aukera: *adostasuna* (ziur zaude), *hipotesi aktiboa* (badakizula uste duzu baina berriz begiratu beharko zenuke), *ez ziur* (zerbait ikusi duzu, ez dakizu zer).';

  @override
  String get acercaSitSpotTitulo => 'zure sit spota';

  @override
  String get acercaSitSpotCuerpo =>
      'Askotan itzultzen zaren lekua. Ez du polita izan behar. Zurea izan behar du: parkeko banku bat, ibaiaren ondoko harri bat, patioko zuhaitz baten adar lodi bat.\n\nBeti leku ezberdinetara joaten bazara, gauza ezberdinak ikusten dituzu. Leku berera itzultzen bazara, ikusten duzu **nola aldatzen den**.\n\nEz duzu presarik aukeratzeko. Koadernoaren aurkezpenak argi uzten du geroago utzi daitekeela.';

  @override
  String get acercaMisteriosTitulo => 'misterioak eta galderak';

  @override
  String get acercaMisteriosCuerpo =>
      'Bi galdera mota daude Misterioak fitxan:\n\n**Koadernoaren Misterioak** koadernoak proposatzen ditu, zure eremura eta urtaroaren testuingurura egokituta. Ez dituzu denak ebatzi behar.\n\n**Zure galderak** zuk formulatzen dituzu. Nola hasi okurritzen ez bazaizu, *\"ideiak behar ditut\"* batek bost modu posible eskaintzen ditu.\n\nZure erantzuna duzula uste duzunean — ez zientzia-liburuko erantzun zuzena, **zure erantzuna** — gorde egiten duzu. Hemen ez dago erantzun zuzenik: zure erantzuna dago.';

  @override
  String get acercaNoHaceTitulo => 'koaderno honek EZ duena egiten';

  @override
  String get acercaNoHaceCuerpo =>
      'Ez du punturik, mailarik, segidarik, saririk.\n\nEz du jakinarazpenik bidaltzen. Gogoa duzunean, zuk irekitzen duzu.\n\nEz du ezer ospatzen idazten duzunean. Zure behaketa da ospakizuna.\n\nEz zaitu beste haurrekin alderatzen. Ez dago sailkapenik.\n\nEz dizu esaten ondo edo gaizki dagoen. Ikusten duzuna ondo dago ikusi delako.';

  @override
  String get acercaPrivacidadTitulo => 'zure helduarentzat: pribatutasuna';

  @override
  String get acercaPrivacidadCuerpo =>
      'Hau muga negoziatu ezina da: koadernoa haurrarena da.\n\n**Gailuan bakarrik geratzen da, ez da inoiz sarera ateratzen:**\n· behaketen testu librea\n· argazkiak\n· oihalaren marrazkiak\n· kokapen zehatzak\n· formulatzen dituen galderak\n· Misterioak ixtean ematen dituen erantzunak\n· aukeratu duen izena\n\n**Sinkronizazio aukerakoarekin bakarrik bidaltzen da zerbitzarira:**\n· behaketaren *hash* bat (ez testua)\n· probintziaren eskualde-kodea (ez kokapena)\n· asteko agregatua, mota arabera kontatuz, edukirik gabe\n· Tutor IAri egindako galderak, aktibatuta badago, eguneko kuotarekin + ZDR + zerrenda beltzarekin\n\n**Heldu pertsonak ikus dezakeena:**\n· asteko paragrafo bat, testu literalik gabe\n· afarirako iradokitako galdera bat\n\n**Heldu pertsonak ezin du ikusi:** behaketa literalik, argazkirik, marrazkirik, koordenatik, Tutorearekin izandako elkarrizketarik.';

  @override
  String get acercaAcompanarTitulo => 'zure helduarentzat: nola lagundu';

  @override
  String get acercaAcompanarCuerpo =>
      'Sit spota da garrantzitsuena. Haurrak bere egin ez badu, ez da itzuliko. Berak aukeratu dezala. Oraindik bat aurkitu ez badu, ez du presarik.\n\nAsteko behaketa bat erritmo ona da. Astebete batzuetan zero behaketa egongo dira — hori ere ondo dago. Proiektuaren biblia: *itxiera atsegina eta erritmo errespetagarria.*\n\nEzarpenetan asteko laburpena aktibatzen baduzu, afarirako galdera iradoki bat jasoko duzu. Solasaldia errazago hasteko pentsatuta dago, ez auditatzeko.\n\n**Hobe ez egitea:**\n· bere koadernoa sorbalda gainetik irakurri\n· ikasi duena erakustea eskatu\n· gaizki identifikatzen badu zuzendu — hurrengoan alderatu eta bere kabuz zuzenduko da\n· berotsuki zoriondu idazten duenean — ofizioa ikuskizun bihurtzen du';

  @override
  String get acercaTutorTitulo => 'zure helduarentzat: Tutorea';

  @override
  String get acercaTutorCuerpo =>
      'Arauen bidez mugatutako solasaldi-laguntzailea. Proiektuaren bibliak bost mugatzaile jartzen dizkio:\n\n**ZDR** — eredu hornitzaileak ez du elkarrizketekin entrenatzen ezta gordetzen ere.\n\n**Elkarrizketen artean memoriarik gabe.** Irekiera bakoitza garbi hasten da.\n\n**Gaien zerrenda beltza.** Tutoreak ez ditu jarraitzen gai batzuk (sexualitatea, indarkeria, drogak, autoertsuntzia, datu pertsonalak). Lagunkoiki bideratzen du eta txanda gutxi batzuetan ixten du.\n\n**Eguneko 30 txandako kuota.** Iristen denean, Tutoreak *\"bihar hitz egingo dugu\"* erantzuten du. Mendekotasun-eraginaren aurkako mugatzaile berariazkoa.\n\n**Ez du erantzun eginik ematen.** Galdera lekura itzultzeko prompt egina dago.';

  @override
  String get acercaAulaTitulo => 'gelarentzat: irakaslearen ikuspegia';

  @override
  String get acercaAulaCuerpo =>
      'Koaderno hau eskolan erabiltzen denean, irakasleak panel agregatu batera sartzen du Ezarpenak → *\"Irakasle gisa sartu\"*. Ikusten duena:\n\n· bere gelaren jardueraren agregatu zenbaketa\n· dominioka banaketa (presentzia, behaketa, erregistroa, identifikazioa, harremanak, zikloak, habitatak, hipotesiak, ehuna)\n\n**Inoiz ez ezein haurraren behaketen eduki literala.**\n\nGutxieneko atalasea: **k≥5**. Domeinu batean 5 ikasle baino gutxiago badaude datuekin, datu hori ezkutatzen da haur jakin baten portaera ondorioztatu ez dadin.\n\nZati hau itxi gabe dago, eskola-arautegi behin betikoa adingabeentzako Europako araudiarekin itxi behar baita.';

  @override
  String get acercaIdiomasTitulo => 'hizkuntzak';

  @override
  String get acercaIdiomasCuerpo =>
      'Gaztelania, euskara eta katalana lehen abioti. Euskararen eta katalanaren itzulpena natur-arloko terminologia irizpidea duten hiztun jatorrek berrikusi behar dute.';

  @override
  String get acercaLicenciaTitulo => 'lizentzia';

  @override
  String get acercaLicenciaCuerpo =>
      'Kodea AGPL-3.0. Edukia (testuak, ilustrazioak, Misterioen katalogoa) CC-BY-SA 4.0. Trackerrik gabe, iragarkirik gabe, monetizaziorik gabe. Diseinu bidez babestutako pribatutasuna.';

  @override
  String get tarjetaMisterioContadorVacio => 'oraindik ez duzu ezer idatzi';

  @override
  String get tarjetaMisterioContadorUna => '1 ebidentzia idatzita';

  @override
  String tarjetaMisterioContadorVarias(int n) {
    return '$n ebidentzia idatzita';
  }

  @override
  String tarjetaMisterioPrefijoCaliente(String base) {
    return 'egun hauetan · $base';
  }

  @override
  String get tarjetaSitSpotOpcionesTooltip => 'sit spot-aren aukerak';

  @override
  String get editarObservacionEtiquetaDonde => 'non zeunden';

  @override
  String get lienzoTooltipDeshacer => 'desegin';

  @override
  String get lienzoTooltipBorrar => 'ezabatu eta berriz hasi';

  @override
  String get lienzoAnchoFino => 'marra mehe';

  @override
  String get lienzoAnchoMedio => 'marra ertaina';

  @override
  String get lienzoAnchoGrueso => 'marra lodi';

  @override
  String get lienzoHerramientaPlumilla => 'lumatxoa';

  @override
  String get lienzoHerramientaLapicero => 'arkatza';

  @override
  String get lienzoHerramientaCarboncillo => 'ikatza';

  @override
  String get lienzoHerramientaGoma => 'borragoma';

  @override
  String get lienzoColorTinta => 'tinta';

  @override
  String get lienzoColorSanguina => 'odol-kolorea';

  @override
  String get lienzoColorSepia => 'sepia';

  @override
  String get lienzoColorOcre => 'okre';

  @override
  String get lienzoColorVerdeBotanico => 'berde botanikoa';

  @override
  String get pdfPlantillaTituloCabecera => 'Landa-koadernoa';

  @override
  String pdfPlantillaTituloCabeceraConNombre(String nombre) {
    return 'Landa-koadernoa · $nombre';
  }

  @override
  String get pdfPlantillaAutorAnonimo => 'Koadernoa';

  @override
  String pdfPlantillaPagina(int numero, int total) {
    return '$numero. or. / $total';
  }

  @override
  String pdfPlantillaSitSpot(String nombre) {
    return 'Sit spota: $nombre';
  }

  @override
  String get pdfPlantillaDiaHora => 'Eguna eta ordua';

  @override
  String get pdfPlantillaDondeEstabas => 'Non zeunden';

  @override
  String get pdfPlantillaQueViste => 'Zer ikusi duzun';

  @override
  String get pdfPlantillaCreesQueEs => 'Zer dela uste duzun';

  @override
  String get pdfPlantillaDibuja => 'Marraztu';

  @override
  String get configuracionInicialPoliticaCuerpo =>
      'Zure koadernoa zurea da. Idazten duzuna, gehitzen dituzun argazki eta marrazkiak, zure gailuan baino ez dira bizi. Ez dira zerbitzarira ateratzen.\n\nEz dago iragarkirik. Idazten duzuna ez zaio inori saltzen. Ez dago segidarik, mailarik, ez itzulera bultzatzen duen saririk: itzul zaitez nahi duzunean, nahi duzunean.\n\nHelduren batek benetako Tutorea erabiltzen lagundu nahi badizu, edo zurekin hitz egiteko laburpen bat jaso nahi badu, Ezarpenetan sartu eta botoi bati eman behar dio aldi bakoitzean. Ez da bere kabuz gertatzen. Ez du inori abisatzen zuk jakin gabe.\n\nNahi duzunean, Ezarpenetan zure koaderno osoa fitxategi gisa esportatu eta gailu honetatik erabat ezabatu dezakezu.\n\nHau koadernoa egiten ari den taldeak idatzitako behin-behineko bertsioa da. Jende askok erabili aurretik, lege-aditu batek berrikusiko du.';

  @override
  String get observacionMapaSonidosComenzar => 'soinuen mapa';

  @override
  String get mapaSonidosTitulo => 'Soinuen mapa';

  @override
  String get mapaSonidosIntroduccion =>
      'Geratu toki batean pixka batean. Zu erdian zaude. Entzuten duzun soinu bakoitza, markatu iristen zaizun lekuan: gertu, erdibidean edo urrun.';

  @override
  String get mapaSonidosAyuda =>
      'Ukitu mapa markatzeko. Ukitu marka bat kentzeko.';

  @override
  String get mapaSonidosCentro => 'zu';

  @override
  String get mapaSonidosDelante => 'aurrean';

  @override
  String get mapaSonidosGuardar => 'gorde mapa';

  @override
  String get mapaSonidosDeshacer => 'desegin';

  @override
  String get mapaSonidosTipoPajaro => 'txoria';

  @override
  String get mapaSonidosTipoInsecto => 'intsektua';

  @override
  String get mapaSonidosTipoAgua => 'ura';

  @override
  String get mapaSonidosTipoViento => 'haizea';

  @override
  String get mapaSonidosTipoHojas => 'hostoak';

  @override
  String get mapaSonidosTipoAnimal => 'beste animalia bat';

  @override
  String get mapaSonidosTipoPersona => 'pertsonak';

  @override
  String get mapaSonidosTipoMaquina => 'makina';

  @override
  String get mapaSonidosTipoNoSe => 'ez dakit zer den';

  @override
  String get paletaLugarTitulo => 'Leku honetako koloreak';

  @override
  String get paletaLugarExplicacion =>
      'Hemengo zure argazkietatik ateratzen dira, urtaroz urtaro.';

  @override
  String paletaLugarFotos(int numero) {
    String _temp0 = intl.Intl.pluralLogic(
      numero,
      locale: localeName,
      other: '$numero argazki',
      one: 'argazki 1',
    );
    return '$_temp0';
  }

  @override
  String get estacionPrimavera => 'udaberria';

  @override
  String get estacionVerano => 'uda';

  @override
  String get estacionOtono => 'udazkena';

  @override
  String get estacionInvierno => 'negua';
}
