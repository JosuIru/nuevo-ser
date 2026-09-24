// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get botonSaltar => 'saltatu';

  @override
  String get tocaParaContinuar => 'ukitu jarraitzeko';

  @override
  String get comunCancelar => 'utzi';

  @override
  String tutorCabecera(String habilidad) {
    return 'iradokizuna — $habilidad';
  }

  @override
  String get tutorInputPista => 'galdera';

  @override
  String get tutorBotonPreguntar => 'galdetu';

  @override
  String get tutorEstadoVacio =>
      'Esadazu zerk traba egin dizun.\nZeure hitzekin.';

  @override
  String get tutorOfertaTitulo => 'Iradokizuna nahi duzu?';

  @override
  String tutorOfertaCuerpo(String habilidad) {
    return 'Honi buruz: $habilidad. Iradokizun bat, ez konponbidea.';
  }

  @override
  String get tutorOfertaSigoSolo => 'bakarrik jarraitzen dut';

  @override
  String get tutorOfertaSi => 'bai';

  @override
  String get habTitulo => 'trebetasunak';

  @override
  String get habTooltipPerfiles => 'Profila aldatu';

  @override
  String get habTooltipSonido => 'Soinu doiketak';

  @override
  String get habTooltipRitmo => 'Jokoaren erritmoa aldatu';

  @override
  String get habTooltipCuenta => 'Kontua (lotu / saioa)';

  @override
  String get habTooltipSync => 'Aurrerapena sinkronizatu';

  @override
  String get habTooltipDebugTutor => 'AA tutorea probatu (debug)';

  @override
  String get habTooltipReiniciar => 'Aurrerapena berrabiarazi (debug)';

  @override
  String get habTooltipIdioma => 'Hizkuntza aldatu';

  @override
  String get habIdiomaTitulo => 'Aplikazioaren hizkuntza';

  @override
  String get habIdiomaSnack => 'Hizkuntza aldatu da.';

  @override
  String get mapaBotonEntrenar => 'Entrenatu';

  @override
  String get mapaBotonInstrucciones => 'Nola jokatu';

  @override
  String get tituloInstrucciones => 'NOLA JOKATU';

  @override
  String get demoPuzzleTocaResultado =>
      'Erantzuna jakitean,\nukitu aukera egokia.';

  @override
  String get demoPuzzleTocaSiNo => 'Erabaki eta ukitu BAI edo EZ.';

  @override
  String get cazaBotonMapa => '‹ mapa';

  @override
  String get cazaBadgeEntrenando => 'ENTRENATZEN · ';

  @override
  String get entrenamientoTitulo => 'ENTRENAMENDUA';

  @override
  String get entrenamientoPregunta => 'Zertan zentratu nahi duzu gaur?';

  @override
  String get sonidoPaqueteTitulo => 'SOINU PAKETEA';

  @override
  String get sonidoPaqueteNoInstalado =>
      'Instalatu gabe. Efektu laburrak baino ez dira entzuten.';

  @override
  String sonidoPaqueteVersion(int version, String tamano) {
    return 'Bertsioa $version · $tamano';
  }

  @override
  String get sonidoPaqueteExplicacion =>
      'Giro-soinua, musika eta narratiboak zerbitzaritik deskargatzen dira aplikazioaren tamaina ez puzteko.';

  @override
  String get sonidoPaqueteBotonDescargar => 'Paketea deskargatu';

  @override
  String get sonidoPaqueteBotonComprobar => 'Eguneraketak begiratu';

  @override
  String get sonidoPaqueteBotonBorrar => 'Paketea ezabatu';

  @override
  String get sonidoPaqueteConfirmTitulo => 'Soinu paketea ezabatu';

  @override
  String sonidoPaqueteConfirmTexto(String tamano) {
    return 'Gailutik $tamano kenduko dira. Nahi duzunean berriro deskarga dezakezu.';
  }

  @override
  String get sonidoPaqueteConfirmBotonBorrar => 'Ezabatu';

  @override
  String get sonidoBotonCancelar => 'Utzi';

  @override
  String get sonidoMensajeInstalado => 'Soinu paketea instalatu da.';

  @override
  String get sonidoMensajeBorrado => 'Soinu paketea ezabatu da.';

  @override
  String sonidoMensajeFallido(String mensaje) {
    return 'Deskargak huts egin du: $mensaje';
  }

  @override
  String get cierreBotonSeguir => 'Praktikatzen jarraitu';

  @override
  String get cierreBotonBuenasNoches => 'Gabon';

  @override
  String get combateBotonDeshacer => 'Desegin';

  @override
  String get combateBotonDeNuevo => 'Berriro';

  @override
  String get combateBotonCortar => 'Moztu';

  @override
  String get cinematicaAccionDividir => 'irristatu zatitzeko';

  @override
  String get cinematicaAccionDesfragmentar => 'ukitu zati bakoitza';

  @override
  String get comparacionMismoTamano => 'zati tamaina bera';

  @override
  String get comparacionMismoNumero => 'zati kopuru bera';

  @override
  String get simetriaPreguntaVertical =>
      'ardatz bertikalarekiko simetrikoa al da?';

  @override
  String get simetriaPreguntaHorizontal =>
      'ardatz horizontalarekiko simetrikoa al da?';

  @override
  String barrasPreguntaValor(String etiqueta) {
    return 'zenbat \"$etiqueta\" daude?';
  }

  @override
  String get barrasPreguntaTotal => 'zein da guztira?';

  @override
  String aumentoVerbo(int porcentaje) {
    return '%$porcentaje igo honi:';
  }

  @override
  String descuentoVerbo(int porcentaje) {
    return '%$porcentaje jaitsi honi:';
  }

  @override
  String get respuestaSi => 'bai';

  @override
  String get respuestaNo => 'ez';

  @override
  String get habRitmoTitulo => 'Jokoaren erritmoa';

  @override
  String habRitmoSnack(String ritmo) {
    return '«$ritmo» erritmoa. Hurrengo eszenan aplikatuko da.';
  }

  @override
  String get habSyncFaltaToken => 'Lotu lehenik kontu bat profilaren ikonotik.';

  @override
  String get habSyncEnProgreso => 'Sinkronizatzen…';

  @override
  String habSyncResumen(int esquirlas, int flags, int habilidades) {
    return 'Sinkronizazioa OK. $esquirlas ezpal · $flags flag · $habilidades trebetasun.';
  }

  @override
  String get habSyncSesionCaduco =>
      'Saioak iraungi du. Ireki «Kontua»-tik eta hasi saioa berriro.';

  @override
  String habApiError(int codigo, String mensaje) {
    return 'API $codigo: $mensaje';
  }

  @override
  String habRedError(String error) {
    return 'Sarea: $error';
  }

  @override
  String get habReiniciarTitulo => 'Aurrerapena berrabiarazi';

  @override
  String get habReiniciarCuerpo =>
      'Ikusitako eszenak, trebetasunak, ezpalak eta maila ezabatuko ditu. Aplikazioa berriz irekitzean, hasieratik abiatuko zara.';

  @override
  String get habReiniciarBoton => 'berrabiarazi';

  @override
  String get habReiniciarHecho =>
      'Aurrerapena berrabiarazi da. Itxi aplikazioa eta ireki berriro.';

  @override
  String habEsquirlasResumen(int n) {
    return '$n ezpal';
  }

  @override
  String get habNivelInexplorada => 'ukitu gabe';

  @override
  String get habNivelIntroducida => 'aurkeztua';

  @override
  String get habNivelEnDesarrollo => 'garapenean';

  @override
  String get habNivelCompetente => 'gai';

  @override
  String get habNivelMaestria => 'maisutza';

  @override
  String habChipNivel(int n, String etiqueta) {
    return '$n $etiqueta';
  }

  @override
  String habFilaResumen(String nivel, int precision, int intentos) {
    return '$nivel · zehaztasuna %$precision · $intentos saiakera';
  }

  @override
  String get cuentaTitulo => 'kontua';

  @override
  String get cuentaCrearTitulo => 'kontua sortu';

  @override
  String get cuentaIniciarTitulo => 'saioa hasi';

  @override
  String get cuentaCerrarSesionTitulo => 'Saioa itxi';

  @override
  String get cuentaCerrarSesionCuerpo =>
      'Tokiko aurrerapena oso-osorik mantentzen da, zerbitzaritik soilik deskonektatzen da.';

  @override
  String get cuentaBotonCerrar => 'itxi';

  @override
  String get cuentaSinCuentaTitulo => 'Konturik gabe';

  @override
  String get cuentaSinCuentaCuerpo =>
      'Lineaz kanpo jolasten jarraitu dezakezu. Kontu bat lotzen baduzu, aurrerapena zerbitzarian gordeko da eta tutorea desblokeatuko da trabatzen zarenerako.';

  @override
  String get cuentaBotonCrear => 'kontua sortu';

  @override
  String get cuentaBotonIniciar => 'saioa hasi';

  @override
  String get cuentaVinculadaTitulo => 'Kontua lotuta';

  @override
  String get cuentaVinculadaCuerpo =>
      'Aurrerapena zerbitzariarekin sinkronizatzen da eta tutorea eskuragarri dago trabatzen zarenean.';

  @override
  String get cuentaBotonCerrarSesion => 'saioa itxi';

  @override
  String get cuentaCaducadaTitulo => 'Saioa iraungita';

  @override
  String cuentaCaducadaCuerpo(String email) {
    return 'Hasi saioa berriro sinkronizatzeko eta tutorea erabiltzeko:\n$email';
  }

  @override
  String get cuentaCampoEmail => 'tutorearen e-posta';

  @override
  String get cuentaCampoPassword => 'pasahitza';

  @override
  String get cuentaCampoPasswordMin => 'pasahitza (gutxienez 8)';

  @override
  String get cuentaCampoNombreTutor => 'tutorearen izena (aukerakoa)';

  @override
  String get cuentaCampoNombreNino => 'umearen izena';

  @override
  String get cuentaErrorCamposRegistro =>
      'Idatzi e-posta, pasahitza (gutxienez 8 karaktere) eta umearen izena.';

  @override
  String get cuentaErrorCamposLogin => 'Idatzi e-posta eta pasahitza.';

  @override
  String get cuentaErrorRed => 'Ezin izan da konektatu.';

  @override
  String get cuentaBotonCreando => 'sortzen…';

  @override
  String get cuentaBotonEntrando => 'sartzen…';

  @override
  String get cuentaResetTitulo => 'PASAHITZA AHAZTU DUT';

  @override
  String get cuentaResetEmailInvalido => 'Idatzi baliozko email bat.';

  @override
  String get cuentaResetErrorRed =>
      'Ezin izan da konektatu. Saiatu beranduago.';

  @override
  String get cuentaResetTagline => 'Ez da ezer gertatzen.';

  @override
  String get cuentaResetIntro =>
      'Jarri zure emaila eta esteka bat bidaliko dizugu pasahitz berri bat sortzeko. 30 minutuan iraungitzen da.';

  @override
  String get cuentaResetCampoEmail => 'Emaila';

  @override
  String get cuentaResetBoton => 'BIDALI ESTEKA';

  @override
  String get cuentaResetEnviadoCuerpo =>
      'Helbide hori erregistratuta badago,\nesteka bat iritsiko zaizu minutu batzuetan.';

  @override
  String get cuentaResetEnviadoSpam => 'Begiratu spam karpeta ere.';

  @override
  String get cuentaResetBotonVolver => 'ITZULI';

  @override
  String get panelTutorTitulo => 'TUTORE MODUA';

  @override
  String get panelTutorTooltipSalir => 'Saioa amaitu';

  @override
  String get panelTutorErrorAuth => 'Emaila edo pasahitza okerrak dira.';

  @override
  String panelTutorErrorServidor(int codigo) {
    return 'Zerbitzariaren errorea ($codigo).';
  }

  @override
  String get panelTutorErrorRed => 'Ezin izan da zerbitzarira konektatu.';

  @override
  String get panelTutorErrorProgreso =>
      'Ezin izan da aurrerapena kargatu (tokena iraungita).';

  @override
  String get panelTutorTagline => 'Zuretzat, ez txikiarentzat.';

  @override
  String get panelTutorIntro =>
      'Sartu zure emaila eta pasahitza benetako aurrerapena ikusteko.';

  @override
  String get panelTutorCampoEmail => 'Emaila';

  @override
  String get panelTutorCampoPassword => 'Pasahitza';

  @override
  String get panelTutorBotonEntrar => 'SARTU';

  @override
  String get panelTutorSinNinos => 'Kontu honek oraindik ez du haurrik.';

  @override
  String get panelTutorElegirNino =>
      'Aukeratu haur bat haren aurrerapena ikusteko.';

  @override
  String panelTutorSaludoConNombre(String nombre) {
    return 'Kaixo, $nombre.';
  }

  @override
  String get panelTutorSubtituloSaludo =>
      'Hemen duzu benetako aurrerapena, apaingarririk gabe.';

  @override
  String get sonidoTitulo => 'soinua';

  @override
  String get sonidoSeccionVolumen => 'BOLUMENA GERUZAKA';

  @override
  String get sonidoModoSilencioTitulo => 'Soinurik gabeko modua';

  @override
  String get sonidoModoSilencioSubtitulo =>
      'jokoa erabat jolastu daiteke isiltasunean';

  @override
  String get ajustesSeccionMaquinas => 'MAKINAK';

  @override
  String get sinPrisasTitulo => 'Presarik gabe';

  @override
  String get sinPrisasSubtitulo =>
      'Ekintza-makinetan ezer ez doa bere kabuz: Encajeko pieza zain geratzen da, itzalak gelditzen dira zu gelditzen bazara, txalupak ez dira atera iristen eta Salto polikiago doa.';

  @override
  String get sonidoCapaAmbient => 'haizea, ura, munduko zarata';

  @override
  String get sonidoCapaMusica => 'auzoetako eta borrokako loopak';

  @override
  String get sonidoCapaEfectos => 'ukituak, asmatzeak, hutsegiteak';

  @override
  String get sonidoCapaNarrativos => 'motibo eta efektu bereziak';

  @override
  String get sonidoNotaAccesibilidad =>
      'Doiketak profilean gordetzen dira. Bere profilarekin jolasten den ume bakoitzak bere bolumen-konfigurazioa izango du.';

  @override
  String get perfHeaderQuienEres => 'NOR ZARA?';

  @override
  String get perfHeaderSubtitulo => 'aukeratu profil bat edo sortu berri bat';

  @override
  String get perfBadgeActual => 'uneko profila';

  @override
  String get perfTooltipBorrar => 'profila ezabatu';

  @override
  String get perfBotonNuevo => 'profil berria';

  @override
  String get perfDialogNuevoTitulo => 'Profil berria';

  @override
  String get perfDialogNuevoHint => 'jokalariaren izena';

  @override
  String get perfBotonCrear => 'sortu';

  @override
  String get perfDialogBorrarTitulo => 'Profila ezabatu';

  @override
  String perfDialogBorrarCuerpo(String nombre) {
    return '$nombre-(r)en aurrerapen guztia ezabatuko da. Ekintza hau ezin da desegin.';
  }

  @override
  String get perfBotonBorrar => 'ezabatu';

  @override
  String get nombreTitulo => 'Nola duzu izena?';

  @override
  String get nombreSubtitulo => 'sorak galdetuko dizu une batean';

  @override
  String get nombreBotonContinuar => 'jarraitu';

  @override
  String get cuadernoTitulo => 'koadernoa';

  @override
  String get cuadernoVacio =>
      'Oraindik ez duzu sarrerarik desblokeatu.\nJolasten jarraitu — ezagutzen duzun pertsona edo leku bakoitzak orri bat irekitzen du.';

  @override
  String cuadernoResumen(int leidas, int desbloqueadas, int total) {
    return '$leidas irakurrita · $desbloqueadas/$total desblokeatuta';
  }

  @override
  String mapaArcoResumen(String romano, int vistas, int total) {
    return '$romano. arkua · $vistas/$total';
  }

  @override
  String get mapaMontanaTitulo => 'MENDIA';

  @override
  String get mapaMontanaSubtitulo => 'ortzimuga zain dago';

  @override
  String mapaDistritoBloqueado(int n) {
    return '$n ezpalekin irekitzen da';
  }

  @override
  String get puzzleBotonHuir => 'ihes';

  @override
  String get rangoAprendiz1 => 'Ikasle I';

  @override
  String get rangoAprendiz2 => 'Ikasle II';

  @override
  String get rangoAprendiz3 => 'Ikasle III';

  @override
  String get rangoIniciado => 'Hasiberria';

  @override
  String get ritmoTranquilo => 'Lasaia';

  @override
  String get ritmoEstandar => 'Estandarra';

  @override
  String get ritmoExigente => 'Eskakizun handikoa';

  @override
  String get ritmoTranquiloDesc =>
      'Hitzak mantsoago agertzen dira. Borrokek denbora gehiago ematen dute.';

  @override
  String get ritmoEstandarDesc => 'Jokoaren oinarrizko abiadura.';

  @override
  String get ritmoExigenteDesc =>
      'Dena bizkorrago doa. Borrokek bizkortasun handiagoa eskatzen dute.';

  @override
  String get capaAmbient => 'Giroa';

  @override
  String get capaMusica => 'Musika';

  @override
  String get capaEfectos => 'Efektuak';

  @override
  String get capaNarrativos => 'Narratiboak';

  @override
  String get catCuadernoBitacora => 'Egunkaria';

  @override
  String get catCuadernoPersonajes => 'Pertsonaiak';

  @override
  String get catCuadernoFragmentos => 'Zatiak';

  @override
  String get catCuadernoLugares => 'Tokiak';

  @override
  String get catCuadernoHistoria => 'Historia';

  @override
  String get catCuadernoNaturaleza => 'Natura';

  @override
  String get catCuadernoMitos => 'Mitoak';

  @override
  String get puzzleHeaderAmplificar => 'ANPLIFIKATU';

  @override
  String get puzzleInstrAmplificar => 'osatu: ukitu falta den zenbakia';

  @override
  String get puzzleHeaderSumaBasica => 'BATU';

  @override
  String get puzzleInstrSumaBasica => 'zenbat batzen dute?';

  @override
  String get puzzleHeaderEcuacionLineal => 'X-A ASKATU';

  @override
  String get puzzleInstrEcuacionLineal =>
      'zer x-balioarekin betetzen da ekuazioa?';

  @override
  String get puzzleHeaderAngulo => 'ANGELUA';

  @override
  String get puzzleInstrAngulo => 'ukitu marraztutako angeluaren izena';

  @override
  String get puzzleInstrAreaRectangulo =>
      'azalera = oinarria × altuera. Ukitu emaitza';

  @override
  String get puzzleHeaderTriangulo => 'TRIANGELUA';

  @override
  String get puzzleInstrAreaTriangulo =>
      'azalera = oinarria × altuera ÷ 2. Ukitu emaitza';

  @override
  String get puzzleInstrCirculoPi =>
      'erabili formula (π ≈ 3,14) eta ukitu emaitza';

  @override
  String get puzzleHeaderComparar => 'ALDERATU';

  @override
  String get puzzleInstrCualEsMayor => 'ukitu frakzio handiena';

  @override
  String get puzzleInstrLeerCifras =>
      'ukitu hamartar handiena (zifra gehiago ez da gehiago)';

  @override
  String get puzzleInstrMiraValor =>
      'ukitu hamartar handiena (zifra gehiago ez da gehiago)';

  @override
  String get puzzleHeaderContraMitad => '1/2-AREN AURKA';

  @override
  String get puzzleInstrContraMitad => 'ukitu <, =, > 1/2-rekin alderatuta';

  @override
  String get puzzleHeaderContraUno => '1-AREN AURKA';

  @override
  String get puzzleInstrContraUno => 'ukitu <, =, > 1ekin alderatuta';

  @override
  String get puzzleHeaderDecimal => 'HAMARTARRA';

  @override
  String get puzzleInstrQueDecimal => 'ukitu balio bera duen hamartarra';

  @override
  String get puzzleHeaderDivisores => 'ZATITZAILEAK';

  @override
  String get puzzleInstrCualNoDivisor => 'hiru zatitzaile dira. Ukitu ez dena';

  @override
  String get puzzleHeaderDual => 'BIKOITZA';

  @override
  String get puzzleInstrDual => 'kalkulatu eragiketa eta ukitu emaitza';

  @override
  String get puzzleHeaderEscala => 'ESKALA';

  @override
  String puzzleInstrEscalaMapa(int denominador) {
    return '1:$denominador mapa';
  }

  @override
  String get puzzleInstrEnPlano => 'planoan';

  @override
  String get puzzleHeaderEspejo => 'ISPILUA';

  @override
  String get puzzleInstrEspejo => 'bilatu baliokidea';

  @override
  String get puzzleHeaderParte => 'ZATIA';

  @override
  String get puzzleInstrCalcula => 'kalkulatu eta ukitu emaitza';

  @override
  String get puzzleHeaderGrafico => 'GRAFIKOA';

  @override
  String get puzzleHeaderCircular => 'ZIRKULARRA';

  @override
  String get puzzleHeaderImpropio => 'INPROPIOA';

  @override
  String get puzzleInstrImpropio => 'ukitu balio bera duen zenbaki mistoa';

  @override
  String get puzzleHeaderJerarquia => 'HIERARKIA';

  @override
  String get puzzleInstrJerarquiaPrimero =>
      'lehenik × eta ÷, gero + eta −. Ukitu emaitza';

  @override
  String get puzzleInstrJerarquiaRecuerda =>
      '× eta ÷ + eta − baino lehen. Ukitu emaitza';

  @override
  String get puzzleHeaderLeer => 'IRAKURRI';

  @override
  String get puzzleInstrQueNumero => 'irakurri testua eta ukitu zenbaki egokia';

  @override
  String get puzzleInstrQueFraccion =>
      'irakurri testua eta ukitu frakzio egokia';

  @override
  String get puzzleHeaderLongitud => 'LUZERA';

  @override
  String get puzzleInstrConvierteMedida => 'bihurtu eta ukitu emaitza';

  @override
  String get puzzleHeaderMedia => 'BATEZBESTEKOA';

  @override
  String get puzzleInstrCalculaMedia => 'batu eta zatitu. Ukitu batezbestekoa';

  @override
  String get puzzleHeaderConvertir => 'BIHURTU';

  @override
  String get puzzleInstrConvertirImpropia =>
      'ukitu frakzio inpropio baliokidea';

  @override
  String puzzleInstrCualEsModa(String modo) {
    return 'ukitu $modo-ren balioa';
  }

  @override
  String get puzzleHeaderOpDecimal => 'ERAG. HAMARTARRA';

  @override
  String get puzzleInstrCuantoValeOp => 'kalkulatu eta ukitu emaitza';

  @override
  String get puzzleHeaderDecimalFraccion => 'HAMARTARRA ETA ZATIKIA';

  @override
  String get puzzleInstrFraccionDecimal =>
      'kalkulatu eragiketa mistoa eta ukitu emaitza';

  @override
  String get puzzleHeaderOrdenar => 'ORDENATU';

  @override
  String get puzzleInstrOrdenar =>
      'ukitu txikienetik handienera ordenatutako lerroa';

  @override
  String get puzzleHeaderPerimetro => 'PERIMETROA';

  @override
  String get puzzleInstrPerimetro => 'batu aldeak eta ukitu perimetroa';

  @override
  String get puzzleHeaderPoligono => 'POLIGONOA';

  @override
  String get puzzleInstrPoligono => 'ukitu marraztutako poligonoaren izena';

  @override
  String get puzzleHeaderPorcentaje => 'EHUNEKOA';

  @override
  String get puzzleInstrPorcentajeFraccion =>
      'ukitu ehunekoaren frakzio baliokidea';

  @override
  String puzzleInstrPorcentajeDe(int porcentaje, int cantidad) {
    return '$cantidad-ren %$porcentaje';
  }

  @override
  String get puzzleHeaderQuePorcentaje => 'ZE %?';

  @override
  String get puzzleInstrQuePorcentaje => 'ukitu ehuneko egokia';

  @override
  String get puzzleHeaderPrimos => 'LEHENAK';

  @override
  String get puzzleInstrEsPrimo => 'ukitu BAI lehena bada, EZ ez bada';

  @override
  String get puzzleHeaderProbabilidad => 'PROBABILITATEA';

  @override
  String puzzleInstrProbabilidadSaco(int favorables, int otros) {
    return '$favorables gorri eta $otros urdin dituen poltsa';
  }

  @override
  String get puzzleInstrProbabilidadFormula =>
      'ukitu probabilitatea ematen duen frakzioa';

  @override
  String get puzzleHeaderPProb => 'P → %';

  @override
  String puzzleInstrPEquals(int numerador, int denominador) {
    return 'P = $numerador/$denominador';
  }

  @override
  String get puzzleInstrComoPorcentaje =>
      'ukitu frakzioaren ehuneko baliokidea';

  @override
  String get puzzleHeaderProporcion => 'PROPORTZIOA';

  @override
  String get puzzleInstrCompletaProporcion => 'osatu: ukitu falta den zenbakia';

  @override
  String get puzzleInstrSiEsto => 'hau izanda, orduan…';

  @override
  String get puzzleHeaderRazon => 'ARRAZOIA';

  @override
  String get puzzleInstrRazon => 'ukitu arrazoi murriztua';

  @override
  String get puzzleHeaderRedondear => 'BIRIBILDU';

  @override
  String get puzzleInstrRedondear => 'ukitu hamarrenerako biribilketa';

  @override
  String get puzzleHeaderSimetria => 'SIMETRIA';

  @override
  String get puzzleHeaderSimplificar => 'SOILDU';

  @override
  String get puzzleInstrSimplificar => 'ukitu ahal beste murriztutako frakzioa';

  @override
  String get puzzleHeaderSuperficie => 'AZALERA';

  @override
  String get puzzleInstrSuperficie => 'bihurtu azalera. Ukitu emaitza';

  @override
  String get puzzleHeaderTiempo => 'DENBORA';

  @override
  String get puzzleInstrTiempo => 'bihurtu eta ukitu emaitza';

  @override
  String get puzzleHeaderVolumen => 'BOLUMENA';

  @override
  String get puzzleInstrVolumenFormula =>
      'B = luzera × zabalera × altuera. Ukitu bolumena';

  @override
  String get estadisticoModa => 'moda';

  @override
  String get estadisticoMediana => 'mediana';

  @override
  String get sonidoDescargaConectando => 'Zerbitzariarekin konektatzen…';

  @override
  String sonidoDescargaBajandoConTotal(String mb, String total) {
    return 'Jaisten $mb / $total MB';
  }

  @override
  String sonidoDescargaBajandoSinTotal(String mb) {
    return 'Jaisten $mb MB';
  }

  @override
  String get sonidoDescargaVerificando => 'Osotasuna egiaztatzen…';

  @override
  String sonidoDescargaInstalando(int actual, int total) {
    return 'Instalatzen $actual / $total';
  }

  @override
  String get cuentaErrorCamposAnadirNino =>
      'Idatzi e-posta, pasahitza eta umearen izena.';

  @override
  String get cuentaAnadirNinoTitulo => 'HAURRA GEHITU';

  @override
  String get cuentaAnadirNinoTagline =>
      'Jadanik kontua duen tutorearen e-posta eta pasahitza jarri. Haur hau kontu berean gehituko dugu.';

  @override
  String get cuentaAnadirNinoBoton => 'HAURRA GEHITU';

  @override
  String get cuentaAnadirNinoBotonEnviando => 'GEHITZEN…';
}
