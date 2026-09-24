// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get botonSaltar => 'saltar';

  @override
  String get tocaParaContinuar => 'toca per continuar';

  @override
  String get comunCancelar => 'cancel·lar';

  @override
  String tutorCabecera(String habilidad) {
    return 'pista — $habilidad';
  }

  @override
  String get tutorInputPista => 'pregunta';

  @override
  String get tutorBotonPreguntar => 'preguntar';

  @override
  String get tutorEstadoVacio =>
      'Explica\'m què t\'ha encallat.\nAmb les teves paraules.';

  @override
  String get tutorOfertaTitulo => 'Vols una pista?';

  @override
  String tutorOfertaCuerpo(String habilidad) {
    return 'Sobre $habilidad. Una pista, no la solució.';
  }

  @override
  String get tutorOfertaSigoSolo => 'segueixo sol';

  @override
  String get tutorOfertaSi => 'sí';

  @override
  String get habTitulo => 'habilitats';

  @override
  String get habTooltipPerfiles => 'Canviar de perfil';

  @override
  String get habTooltipSonido => 'Ajustos de so';

  @override
  String get habTooltipRitmo => 'Canviar el ritme del joc';

  @override
  String get habTooltipCuenta => 'Compte (vincular / sessió)';

  @override
  String get habTooltipSync => 'Sincronitzar progrés';

  @override
  String get habTooltipDebugTutor => 'Provar tutor IA (debug)';

  @override
  String get habTooltipReiniciar => 'Reiniciar progrés (debug)';

  @override
  String get habTooltipIdioma => 'Canviar idioma';

  @override
  String get habIdiomaTitulo => 'Idioma de l\'app';

  @override
  String get habIdiomaSnack => 'Idioma canviat.';

  @override
  String get mapaBotonEntrenar => 'Entrenar';

  @override
  String get mapaBotonInstrucciones => 'Com s\'hi juga';

  @override
  String get tituloInstrucciones => 'COM S\'HI JUGA';

  @override
  String get demoPuzzleTocaResultado =>
      'Quan sàpigues la resposta,\ntoca l\'opció correcta.';

  @override
  String get demoPuzzleTocaSiNo => 'Decideix i toca SÍ o NO.';

  @override
  String get cazaBotonMapa => '‹ mapa';

  @override
  String get cazaBadgeEntrenando => 'ENTRENANT · ';

  @override
  String get entrenamientoTitulo => 'ENTRENAMENT';

  @override
  String get entrenamientoPregunta => 'En què vols centrar-te avui?';

  @override
  String get sonidoPaqueteTitulo => 'PAQUET DE SO';

  @override
  String get sonidoPaqueteNoInstalado =>
      'No instal·lat. Només sonen els efectes curts.';

  @override
  String sonidoPaqueteVersion(int version, String tamano) {
    return 'Versió $version · $tamano';
  }

  @override
  String get sonidoPaqueteExplicacion =>
      'L\'ambient, la música i els narratius es descarreguen del servidor per no inflar la mida de l\'app.';

  @override
  String get sonidoPaqueteBotonDescargar => 'Descarregar paquet';

  @override
  String get sonidoPaqueteBotonComprobar => 'Comprovar actualitzacions';

  @override
  String get sonidoPaqueteBotonBorrar => 'Esborrar paquet';

  @override
  String get sonidoPaqueteConfirmTitulo => 'Esborrar paquet de so';

  @override
  String sonidoPaqueteConfirmTexto(String tamano) {
    return 'S\'eliminaran $tamano del dispositiu. Podràs tornar a descarregar-lo quan vulguis.';
  }

  @override
  String get sonidoPaqueteConfirmBotonBorrar => 'Esborrar';

  @override
  String get sonidoBotonCancelar => 'Cancel·lar';

  @override
  String get sonidoMensajeInstalado => 'Paquet de so instal·lat.';

  @override
  String get sonidoMensajeBorrado => 'Paquet de so esborrat.';

  @override
  String sonidoMensajeFallido(String mensaje) {
    return 'Descàrrega fallida: $mensaje';
  }

  @override
  String get cierreBotonSeguir => 'Seguir practicant';

  @override
  String get cierreBotonBuenasNoches => 'Bona nit';

  @override
  String get combateBotonDeshacer => 'Desfer';

  @override
  String get combateBotonDeNuevo => 'De nou';

  @override
  String get combateBotonCortar => 'Tallar';

  @override
  String get cinematicaAccionDividir => 'llisca per dividir';

  @override
  String get cinematicaAccionDesfragmentar => 'toca cada meitat';

  @override
  String get comparacionMismoTamano => 'mateixa mida de tros';

  @override
  String get comparacionMismoNumero => 'el mateix nombre de trossos';

  @override
  String get simetriaPreguntaVertical =>
      'és simètrica respecte a l\'eix vertical?';

  @override
  String get simetriaPreguntaHorizontal =>
      'és simètrica respecte a l\'eix horitzontal?';

  @override
  String barrasPreguntaValor(String etiqueta) {
    return 'quants a \"$etiqueta\"?';
  }

  @override
  String get barrasPreguntaTotal => 'quin és el total?';

  @override
  String aumentoVerbo(int porcentaje) {
    return 'augmenta un $porcentaje% sobre';
  }

  @override
  String descuentoVerbo(int porcentaje) {
    return 'descompta un $porcentaje% sobre';
  }

  @override
  String get respuestaSi => 'sí';

  @override
  String get respuestaNo => 'no';

  @override
  String get habRitmoTitulo => 'Ritme del joc';

  @override
  String habRitmoSnack(String ritmo) {
    return 'Ritme \"$ritmo\". S\'aplicarà a la propera escena.';
  }

  @override
  String get habSyncFaltaToken =>
      'Vincula primer un compte des de la icona de perfil.';

  @override
  String get habSyncEnProgreso => 'Sincronitzant…';

  @override
  String habSyncResumen(int esquirlas, int flags, int habilidades) {
    return 'Sync OK. $esquirlas esquerdes · $flags flags · $habilidades habilitats.';
  }

  @override
  String get habSyncSesionCaduco =>
      'La sessió ha caducat. Obre-la des de \"Compte\" i inicia sessió de nou.';

  @override
  String habApiError(int codigo, String mensaje) {
    return 'API $codigo: $mensaje';
  }

  @override
  String habRedError(String error) {
    return 'Xarxa: $error';
  }

  @override
  String get habReiniciarTitulo => 'Reiniciar progrés';

  @override
  String get habReiniciarCuerpo =>
      'Esborra escenes vistes, habilitats, esquerdes i rang. La pròxima vegada que obris l\'app, començaràs des de l\'obertura.';

  @override
  String get habReiniciarBoton => 'reiniciar';

  @override
  String get habReiniciarHecho =>
      'Progrés reiniciat. Tanca l\'app i torna a obrir-la.';

  @override
  String habEsquirlasResumen(int n) {
    return '$n esquerdes';
  }

  @override
  String get habNivelInexplorada => 'sense tocar';

  @override
  String get habNivelIntroducida => 'introduïda';

  @override
  String get habNivelEnDesarrollo => 'en desenvolupament';

  @override
  String get habNivelCompetente => 'competent';

  @override
  String get habNivelMaestria => 'mestratge';

  @override
  String habChipNivel(int n, String etiqueta) {
    return '$n $etiqueta';
  }

  @override
  String habFilaResumen(String nivel, int precision, int intentos) {
    return '$nivel · precisió $precision% · $intentos intents';
  }

  @override
  String get cuentaTitulo => 'compte';

  @override
  String get cuentaCrearTitulo => 'crear compte';

  @override
  String get cuentaIniciarTitulo => 'iniciar sessió';

  @override
  String get cuentaCerrarSesionTitulo => 'Tancar sessió';

  @override
  String get cuentaCerrarSesionCuerpo =>
      'El progrés local es manté intacte, només es desconnecta del servidor.';

  @override
  String get cuentaBotonCerrar => 'tancar';

  @override
  String get cuentaSinCuentaTitulo => 'Sense compte vinculat';

  @override
  String get cuentaSinCuentaCuerpo =>
      'Pots continuar jugant fora de línia. Si vincules un compte, el progrés es desa al servidor i es desbloqueja el tutor per quan t\'encallis.';

  @override
  String get cuentaBotonCrear => 'crear compte';

  @override
  String get cuentaBotonIniciar => 'iniciar sessió';

  @override
  String get cuentaVinculadaTitulo => 'Compte vinculat';

  @override
  String get cuentaVinculadaCuerpo =>
      'El progrés es sincronitza amb el servidor i el tutor està disponible quan t\'encalles.';

  @override
  String get cuentaBotonCerrarSesion => 'tancar sessió';

  @override
  String get cuentaCaducadaTitulo => 'Sessió caducada';

  @override
  String cuentaCaducadaCuerpo(String email) {
    return 'Torna a iniciar sessió per sincronitzar i usar el tutor:\n$email';
  }

  @override
  String get cuentaCampoEmail => 'correu del tutor';

  @override
  String get cuentaCampoPassword => 'contrasenya';

  @override
  String get cuentaCampoPasswordMin => 'contrasenya (mínim 8)';

  @override
  String get cuentaCampoNombreTutor => 'nom del tutor (opcional)';

  @override
  String get cuentaCampoNombreNino => 'nom de l\'infant';

  @override
  String get cuentaErrorCamposRegistro =>
      'Posa correu, contrasenya (mínim 8 caràcters) i nom de l\'infant.';

  @override
  String get cuentaErrorCamposLogin => 'Posa el correu i la contrasenya.';

  @override
  String get cuentaErrorRed => 'No s\'ha pogut connectar.';

  @override
  String get cuentaBotonCreando => 'creant…';

  @override
  String get cuentaBotonEntrando => 'entrant…';

  @override
  String get cuentaResetTitulo => 'HE OBLIDAT LA CONTRASENYA';

  @override
  String get cuentaResetEmailInvalido => 'Escriu un correu vàlid.';

  @override
  String get cuentaResetErrorRed =>
      'No s\'ha pogut connectar. Torna-ho a provar més tard.';

  @override
  String get cuentaResetTagline => 'No passa res.';

  @override
  String get cuentaResetIntro =>
      'Posa el teu correu i t\'enviem un enllaç per crear una contrasenya nova. Caduca en 30 minuts.';

  @override
  String get cuentaResetCampoEmail => 'Correu';

  @override
  String get cuentaResetBoton => 'ENVIAR ENLLAÇ';

  @override
  String get cuentaResetEnviadoCuerpo =>
      'Si aquesta adreça està registrada,\nrebràs un enllaç en uns minuts.';

  @override
  String get cuentaResetEnviadoSpam =>
      'Revisa també la carpeta de correu brossa.';

  @override
  String get cuentaResetBotonVolver => 'TORNAR';

  @override
  String get panelTutorTitulo => 'MODE TUTOR';

  @override
  String get panelTutorTooltipSalir => 'Tancar sessió';

  @override
  String get panelTutorErrorAuth => 'Correu o contrasenya incorrectes.';

  @override
  String panelTutorErrorServidor(int codigo) {
    return 'Error del servidor ($codigo).';
  }

  @override
  String get panelTutorErrorRed => 'No s\'ha pogut connectar al servidor.';

  @override
  String get panelTutorErrorProgreso =>
      'No s\'ha pogut carregar el progrés (token caducat).';

  @override
  String get panelTutorTagline => 'Per a tu, no per al petit.';

  @override
  String get panelTutorIntro =>
      'Entra amb el teu correu i contrasenya per veure el progrés real.';

  @override
  String get panelTutorCampoEmail => 'Correu';

  @override
  String get panelTutorCampoPassword => 'Contrasenya';

  @override
  String get panelTutorBotonEntrar => 'ENTRAR';

  @override
  String get panelTutorSinNinos => 'Aquest compte encara no té cap nen.';

  @override
  String get panelTutorElegirNino => 'Tria un nen per veure el seu progrés.';

  @override
  String panelTutorSaludoConNombre(String nombre) {
    return 'Hola, $nombre.';
  }

  @override
  String get panelTutorSubtituloSaludo =>
      'Aquí tens el progrés real, sense ornaments.';

  @override
  String get sonidoTitulo => 'so';

  @override
  String get sonidoSeccionVolumen => 'VOLUM PER CAPA';

  @override
  String get sonidoModoSilencioTitulo => 'Mode sense so';

  @override
  String get sonidoModoSilencioSubtitulo =>
      'el joc és completament jugable en silenci';

  @override
  String get ajustesSeccionMaquinas => 'MÀQUINES';

  @override
  String get sinPrisasTitulo => 'Sense presses';

  @override
  String get sinPrisasSubtitulo =>
      'A les màquines d\'acció res no corre sol: la peça d\'Encaje espera, les ombres s\'aturen si t\'aturis, les barques no arriben a la comporta i Salto va més a poc a poc.';

  @override
  String get sonidoCapaAmbient => 'vent, aigua, soroll rosa del món';

  @override
  String get sonidoCapaMusica => 'loops de districte i de combat';

  @override
  String get sonidoCapaEfectos => 'tocs, encerts, errors';

  @override
  String get sonidoCapaNarrativos => 'motius i efectes únics';

  @override
  String get sonidoNotaAccesibilidad =>
      'Els ajustos es guarden per perfil. Cada infant que jugui amb el seu perfil tindrà la seva pròpia configuració de volums.';

  @override
  String get perfHeaderQuienEres => 'QUI ETS?';

  @override
  String get perfHeaderSubtitulo => 'tria un perfil o crea\'n un de nou';

  @override
  String get perfBadgeActual => 'perfil actual';

  @override
  String get perfTooltipBorrar => 'esborrar perfil';

  @override
  String get perfBotonNuevo => 'perfil nou';

  @override
  String get perfDialogNuevoTitulo => 'Perfil nou';

  @override
  String get perfDialogNuevoHint => 'nom del jugador';

  @override
  String get perfBotonCrear => 'crear';

  @override
  String get perfDialogBorrarTitulo => 'Esborrar perfil';

  @override
  String perfDialogBorrarCuerpo(String nombre) {
    return 'S\'esborrarà tot el progrés de $nombre. Aquesta acció no es pot desfer.';
  }

  @override
  String get perfBotonBorrar => 'esborrar';

  @override
  String get nombreTitulo => 'Com et dius?';

  @override
  String get nombreSubtitulo => 'la sora et preguntarà d\'aquí a un moment';

  @override
  String get nombreBotonContinuar => 'continuar';

  @override
  String get cuadernoTitulo => 'quadern';

  @override
  String get cuadernoVacio =>
      'Encara no has desbloquejat entrades.\nSegueix jugant — cada persona o lloc que coneguis obre una pàgina.';

  @override
  String cuadernoResumen(int leidas, int desbloqueadas, int total) {
    return '$leidas llegides · $desbloqueadas de $total desbloquejades';
  }

  @override
  String mapaArcoResumen(String romano, int vistas, int total) {
    return 'Arc $romano · $vistas/$total';
  }

  @override
  String get mapaMontanaTitulo => 'LA MUNTANYA';

  @override
  String get mapaMontanaSubtitulo => 'l\'horitzó espera';

  @override
  String mapaDistritoBloqueado(int n) {
    return 's\'obre amb $n esquerdes';
  }

  @override
  String get puzzleBotonHuir => 'fugir';

  @override
  String get rangoAprendiz1 => 'Aprenent I';

  @override
  String get rangoAprendiz2 => 'Aprenent II';

  @override
  String get rangoAprendiz3 => 'Aprenent III';

  @override
  String get rangoIniciado => 'Iniciat';

  @override
  String get ritmoTranquilo => 'Tranquil';

  @override
  String get ritmoEstandar => 'Estàndard';

  @override
  String get ritmoExigente => 'Exigent';

  @override
  String get ritmoTranquiloDesc =>
      'Les paraules apareixen més a poc a poc. Els combats donen més temps.';

  @override
  String get ritmoEstandarDesc => 'La velocitat base del joc.';

  @override
  String get ritmoExigenteDesc =>
      'Tot va més ràpid. Els combats demanen més agilitat.';

  @override
  String get capaAmbient => 'Ambient';

  @override
  String get capaMusica => 'Música';

  @override
  String get capaEfectos => 'Efectes';

  @override
  String get capaNarrativos => 'Narratius';

  @override
  String get catCuadernoBitacora => 'Bitàcola';

  @override
  String get catCuadernoPersonajes => 'Personatges';

  @override
  String get catCuadernoFragmentos => 'Fragments';

  @override
  String get catCuadernoLugares => 'Llocs';

  @override
  String get catCuadernoHistoria => 'Història';

  @override
  String get catCuadernoNaturaleza => 'Natura';

  @override
  String get catCuadernoMitos => 'Mites';

  @override
  String get puzzleHeaderAmplificar => 'AMPLIFICAR';

  @override
  String get puzzleInstrAmplificar => 'completa: toca el número que falta';

  @override
  String get puzzleHeaderSumaBasica => 'SUMAR';

  @override
  String get puzzleInstrSumaBasica => 'quant sumen?';

  @override
  String get puzzleHeaderEcuacionLineal => 'AÏLLA LA X';

  @override
  String get puzzleInstrEcuacionLineal =>
      'quin valor de x fa certa l\'equació?';

  @override
  String get puzzleHeaderAngulo => 'ANGLE';

  @override
  String get puzzleInstrAngulo => 'toca el nom de l\'angle dibuixat';

  @override
  String get puzzleInstrAreaRectangulo =>
      'àrea = base × altura. Toca el resultat';

  @override
  String get puzzleHeaderTriangulo => 'TRIANGLE';

  @override
  String get puzzleInstrAreaTriangulo =>
      'àrea = base × altura ÷ 2. Toca el resultat';

  @override
  String get puzzleInstrCirculoPi =>
      'fes servir la fórmula (π ≈ 3,14) i toca el resultat';

  @override
  String get puzzleHeaderComparar => 'COMPARAR';

  @override
  String get puzzleInstrCualEsMayor => 'toca la fracció més gran';

  @override
  String get puzzleInstrLeerCifras =>
      'toca el decimal més gran (més xifres no és més)';

  @override
  String get puzzleInstrMiraValor =>
      'toca el decimal més gran (més xifres no és més)';

  @override
  String get puzzleHeaderContraMitad => 'CONTRA 1/2';

  @override
  String get puzzleInstrContraMitad => 'toca <, =, > comparant-la amb 1/2';

  @override
  String get puzzleHeaderContraUno => 'CONTRA 1';

  @override
  String get puzzleInstrContraUno => 'toca <, =, > comparant-la amb 1';

  @override
  String get puzzleHeaderDecimal => 'DECIMAL';

  @override
  String get puzzleInstrQueDecimal => 'toca el decimal que val el mateix';

  @override
  String get puzzleHeaderDivisores => 'DIVISORS';

  @override
  String get puzzleInstrCualNoDivisor =>
      'tres són divisors. Toca el que NO ho és';

  @override
  String get puzzleHeaderDual => 'DUAL';

  @override
  String get puzzleInstrDual => 'calcula l\'operació i toca el resultat';

  @override
  String get puzzleHeaderEscala => 'ESCALA';

  @override
  String puzzleInstrEscalaMapa(int denominador) {
    return 'mapa 1:$denominador';
  }

  @override
  String get puzzleInstrEnPlano => 'al plànol';

  @override
  String get puzzleHeaderEspejo => 'MIRALL';

  @override
  String get puzzleInstrEspejo => 'toca la fracció equivalent';

  @override
  String get puzzleHeaderParte => 'PART';

  @override
  String get puzzleInstrCalcula => 'calcula i toca el resultat';

  @override
  String get puzzleHeaderGrafico => 'GRÀFIC';

  @override
  String get puzzleHeaderCircular => 'CIRCULAR';

  @override
  String get puzzleHeaderImpropio => 'IMPROPI';

  @override
  String get puzzleInstrImpropio => 'toca el nombre mixt que val igual';

  @override
  String get puzzleHeaderJerarquia => 'JERARQUIA';

  @override
  String get puzzleInstrJerarquiaPrimero =>
      'primer × i ÷, després + i −. Toca el resultat';

  @override
  String get puzzleInstrJerarquiaRecuerda =>
      '× i ÷ abans que + i −. Toca el resultat';

  @override
  String get puzzleHeaderLeer => 'LLEGIR';

  @override
  String get puzzleInstrQueNumero =>
      'llegeix el text i toca el número correcte';

  @override
  String get puzzleInstrQueFraccion =>
      'llegeix el text i toca la fracció correcta';

  @override
  String get puzzleHeaderLongitud => 'LONGITUD';

  @override
  String get puzzleInstrConvierteMedida => 'converteix i toca el resultat';

  @override
  String get puzzleHeaderMedia => 'MITJANA';

  @override
  String get puzzleInstrCalculaMedia => 'suma i divideix. Toca la mitjana';

  @override
  String get puzzleHeaderConvertir => 'CONVERTIR';

  @override
  String get puzzleInstrConvertirImpropia =>
      'toca la fracció impròpia equivalent';

  @override
  String puzzleInstrCualEsModa(String modo) {
    return 'toca el valor de la $modo';
  }

  @override
  String get puzzleHeaderOpDecimal => 'OP. DECIMAL';

  @override
  String get puzzleInstrCuantoValeOp => 'calcula i toca el resultat';

  @override
  String get puzzleHeaderDecimalFraccion => 'DECIMAL I FRACCIÓ';

  @override
  String get puzzleInstrFraccionDecimal =>
      'calcula l\'operació mixta i toca el resultat';

  @override
  String get puzzleHeaderOrdenar => 'ORDENAR';

  @override
  String get puzzleInstrOrdenar => 'toca la fila ordenada de menor a major';

  @override
  String get puzzleHeaderPerimetro => 'PERÍMETRE';

  @override
  String get puzzleInstrPerimetro => 'suma els costats i toca el perímetre';

  @override
  String get puzzleHeaderPoligono => 'POLÍGON';

  @override
  String get puzzleInstrPoligono => 'toca el nom del polígon dibuixat';

  @override
  String get puzzleHeaderPorcentaje => 'PERCENTATGE';

  @override
  String get puzzleInstrPorcentajeFraccion =>
      'toca la fracció equivalent al percentatge';

  @override
  String puzzleInstrPorcentajeDe(int porcentaje, int cantidad) {
    return 'el $porcentaje % de $cantidad';
  }

  @override
  String get puzzleHeaderQuePorcentaje => 'QUIN %?';

  @override
  String get puzzleInstrQuePorcentaje => 'toca el percentatge correcte';

  @override
  String get puzzleHeaderPrimos => 'PRIMERS';

  @override
  String get puzzleInstrEsPrimo => 'toca SÍ si és primer, NO si no ho és';

  @override
  String get puzzleHeaderProbabilidad => 'PROBABILITAT';

  @override
  String puzzleInstrProbabilidadSaco(int favorables, int otros) {
    return 'sac amb $favorables vermelles i $otros blaves';
  }

  @override
  String get puzzleInstrProbabilidadFormula =>
      'toca la fracció que dóna la probabilitat';

  @override
  String get puzzleHeaderPProb => 'P → %';

  @override
  String puzzleInstrPEquals(int numerador, int denominador) {
    return 'P = $numerador/$denominador';
  }

  @override
  String get puzzleInstrComoPorcentaje =>
      'toca el percentatge equivalent a la fracció';

  @override
  String get puzzleHeaderProporcion => 'PROPORCIÓ';

  @override
  String get puzzleInstrCompletaProporcion =>
      'completa: toca el número que falta';

  @override
  String get puzzleInstrSiEsto => 'si això, llavors…';

  @override
  String get puzzleHeaderRazon => 'RAÓ';

  @override
  String get puzzleInstrRazon => 'toca la raó ja reduïda';

  @override
  String get puzzleHeaderRedondear => 'ARRODONIR';

  @override
  String get puzzleInstrRedondear => 'toca l\'arrodoniment a la dècima';

  @override
  String get puzzleHeaderSimetria => 'SIMETRIA';

  @override
  String get puzzleHeaderSimplificar => 'SIMPLIFICAR';

  @override
  String get puzzleInstrSimplificar => 'redueix-la al màxim';

  @override
  String get puzzleHeaderSuperficie => 'SUPERFÍCIE';

  @override
  String get puzzleInstrSuperficie =>
      'converteix la superfície. Toca el resultat';

  @override
  String get puzzleHeaderTiempo => 'TEMPS';

  @override
  String get puzzleInstrTiempo => 'converteix i toca el resultat';

  @override
  String get puzzleHeaderVolumen => 'VOLUM';

  @override
  String get puzzleInstrVolumenFormula =>
      'V = llarg × ample × alt. Toca el volum';

  @override
  String get estadisticoModa => 'moda';

  @override
  String get estadisticoMediana => 'mediana';

  @override
  String get sonidoDescargaConectando => 'Connectant amb el servidor…';

  @override
  String sonidoDescargaBajandoConTotal(String mb, String total) {
    return 'Baixant $mb / $total MB';
  }

  @override
  String sonidoDescargaBajandoSinTotal(String mb) {
    return 'Baixant $mb MB';
  }

  @override
  String get sonidoDescargaVerificando => 'Verificant integritat…';

  @override
  String sonidoDescargaInstalando(int actual, int total) {
    return 'Instal·lant $actual / $total';
  }

  @override
  String get cuentaErrorCamposAnadirNino =>
      'Posa el correu, la contrasenya i el nom de l\'infant.';

  @override
  String get cuentaAnadirNinoTitulo => 'AFEGIR INFANT';

  @override
  String get cuentaAnadirNinoTagline =>
      'Posa el correu i la contrasenya del tutor que ja té compte. Afegirem aquest infant sota el mateix compte.';

  @override
  String get cuentaAnadirNinoBoton => 'AFEGIR INFANT';

  @override
  String get cuentaAnadirNinoBotonEnviando => 'AFEGINT…';
}
