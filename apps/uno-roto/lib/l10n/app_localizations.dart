import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('es'),
    Locale('eu')
  ];

  /// No description provided for @botonSaltar.
  ///
  /// In es, this message translates to:
  /// **'saltar'**
  String get botonSaltar;

  /// No description provided for @tocaParaContinuar.
  ///
  /// In es, this message translates to:
  /// **'toca para continuar'**
  String get tocaParaContinuar;

  /// No description provided for @comunCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get comunCancelar;

  /// No description provided for @tutorCabecera.
  ///
  /// In es, this message translates to:
  /// **'pista — {habilidad}'**
  String tutorCabecera(String habilidad);

  /// No description provided for @tutorInputPista.
  ///
  /// In es, this message translates to:
  /// **'pregunta'**
  String get tutorInputPista;

  /// No description provided for @tutorBotonPreguntar.
  ///
  /// In es, this message translates to:
  /// **'preguntar'**
  String get tutorBotonPreguntar;

  /// No description provided for @tutorEstadoVacio.
  ///
  /// In es, this message translates to:
  /// **'Cuéntame qué te ha trabado.\nCon tus palabras.'**
  String get tutorEstadoVacio;

  /// No description provided for @tutorOfertaTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres una pista?'**
  String get tutorOfertaTitulo;

  /// No description provided for @tutorOfertaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Sobre {habilidad}. Una pista, no la solución.'**
  String tutorOfertaCuerpo(String habilidad);

  /// No description provided for @tutorOfertaSigoSolo.
  ///
  /// In es, this message translates to:
  /// **'sigo solo'**
  String get tutorOfertaSigoSolo;

  /// No description provided for @tutorOfertaSi.
  ///
  /// In es, this message translates to:
  /// **'sí'**
  String get tutorOfertaSi;

  /// No description provided for @habTitulo.
  ///
  /// In es, this message translates to:
  /// **'habilidades'**
  String get habTitulo;

  /// No description provided for @habTooltipPerfiles.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de perfil'**
  String get habTooltipPerfiles;

  /// No description provided for @habTooltipSonido.
  ///
  /// In es, this message translates to:
  /// **'Ajustes de sonido'**
  String get habTooltipSonido;

  /// No description provided for @habTooltipRitmo.
  ///
  /// In es, this message translates to:
  /// **'Cambiar ritmo del juego'**
  String get habTooltipRitmo;

  /// No description provided for @habTooltipCuenta.
  ///
  /// In es, this message translates to:
  /// **'Cuenta (vincular / sesión)'**
  String get habTooltipCuenta;

  /// No description provided for @habTooltipSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar progreso'**
  String get habTooltipSync;

  /// No description provided for @habTooltipDebugTutor.
  ///
  /// In es, this message translates to:
  /// **'Probar tutor IA (debug)'**
  String get habTooltipDebugTutor;

  /// No description provided for @habTooltipReiniciar.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar progreso (debug)'**
  String get habTooltipReiniciar;

  /// No description provided for @habTooltipIdioma.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get habTooltipIdioma;

  /// No description provided for @habIdiomaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Idioma de la app'**
  String get habIdiomaTitulo;

  /// No description provided for @habIdiomaSnack.
  ///
  /// In es, this message translates to:
  /// **'Idioma cambiado.'**
  String get habIdiomaSnack;

  /// No description provided for @mapaBotonEntrenar.
  ///
  /// In es, this message translates to:
  /// **'Entrenar'**
  String get mapaBotonEntrenar;

  /// No description provided for @mapaBotonInstrucciones.
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get mapaBotonInstrucciones;

  /// No description provided for @tituloInstrucciones.
  ///
  /// In es, this message translates to:
  /// **'CÓMO SE JUEGA'**
  String get tituloInstrucciones;

  /// No description provided for @demoPuzzleTocaResultado.
  ///
  /// In es, this message translates to:
  /// **'Cuando sepas la respuesta,\ntoca la opción correcta.'**
  String get demoPuzzleTocaResultado;

  /// No description provided for @demoPuzzleTocaSiNo.
  ///
  /// In es, this message translates to:
  /// **'Decide y toca SÍ o NO.'**
  String get demoPuzzleTocaSiNo;

  /// No description provided for @cazaBotonMapa.
  ///
  /// In es, this message translates to:
  /// **'‹ mapa'**
  String get cazaBotonMapa;

  /// No description provided for @cazaBadgeEntrenando.
  ///
  /// In es, this message translates to:
  /// **'ENTRENANDO · '**
  String get cazaBadgeEntrenando;

  /// No description provided for @entrenamientoTitulo.
  ///
  /// In es, this message translates to:
  /// **'ENTRENAMIENTO'**
  String get entrenamientoTitulo;

  /// No description provided for @entrenamientoPregunta.
  ///
  /// In es, this message translates to:
  /// **'¿En qué quieres centrarte hoy?'**
  String get entrenamientoPregunta;

  /// No description provided for @sonidoPaqueteTitulo.
  ///
  /// In es, this message translates to:
  /// **'PAQUETE SONORO'**
  String get sonidoPaqueteTitulo;

  /// No description provided for @sonidoPaqueteNoInstalado.
  ///
  /// In es, this message translates to:
  /// **'No instalado. Solo suenan los efectos cortos.'**
  String get sonidoPaqueteNoInstalado;

  /// No description provided for @sonidoPaqueteVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} · {tamano}'**
  String sonidoPaqueteVersion(int version, String tamano);

  /// No description provided for @sonidoPaqueteExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Ambient, música y narrativos se descargan del servidor para no inflar el tamaño de la app.'**
  String get sonidoPaqueteExplicacion;

  /// No description provided for @sonidoPaqueteBotonDescargar.
  ///
  /// In es, this message translates to:
  /// **'Descargar paquete'**
  String get sonidoPaqueteBotonDescargar;

  /// No description provided for @sonidoPaqueteBotonComprobar.
  ///
  /// In es, this message translates to:
  /// **'Comprobar actualizaciones'**
  String get sonidoPaqueteBotonComprobar;

  /// No description provided for @sonidoPaqueteBotonBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar paquete'**
  String get sonidoPaqueteBotonBorrar;

  /// No description provided for @sonidoPaqueteConfirmTitulo.
  ///
  /// In es, this message translates to:
  /// **'Borrar paquete sonoro'**
  String get sonidoPaqueteConfirmTitulo;

  /// No description provided for @sonidoPaqueteConfirmTexto.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán {tamano} del dispositivo. Podrás volver a descargarlo cuando quieras.'**
  String sonidoPaqueteConfirmTexto(String tamano);

  /// No description provided for @sonidoPaqueteConfirmBotonBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get sonidoPaqueteConfirmBotonBorrar;

  /// No description provided for @sonidoBotonCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get sonidoBotonCancelar;

  /// No description provided for @sonidoMensajeInstalado.
  ///
  /// In es, this message translates to:
  /// **'Paquete sonoro instalado.'**
  String get sonidoMensajeInstalado;

  /// No description provided for @sonidoMensajeBorrado.
  ///
  /// In es, this message translates to:
  /// **'Paquete sonoro borrado.'**
  String get sonidoMensajeBorrado;

  /// No description provided for @sonidoMensajeFallido.
  ///
  /// In es, this message translates to:
  /// **'Descarga fallida: {mensaje}'**
  String sonidoMensajeFallido(String mensaje);

  /// No description provided for @cierreBotonSeguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir practicando'**
  String get cierreBotonSeguir;

  /// No description provided for @cierreBotonBuenasNoches.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get cierreBotonBuenasNoches;

  /// No description provided for @combateBotonDeshacer.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get combateBotonDeshacer;

  /// No description provided for @combateBotonDeNuevo.
  ///
  /// In es, this message translates to:
  /// **'De nuevo'**
  String get combateBotonDeNuevo;

  /// No description provided for @combateBotonCortar.
  ///
  /// In es, this message translates to:
  /// **'Cortar'**
  String get combateBotonCortar;

  /// No description provided for @cinematicaAccionDividir.
  ///
  /// In es, this message translates to:
  /// **'desliza para dividir'**
  String get cinematicaAccionDividir;

  /// No description provided for @cinematicaAccionDesfragmentar.
  ///
  /// In es, this message translates to:
  /// **'toca cada mitad'**
  String get cinematicaAccionDesfragmentar;

  /// No description provided for @comparacionMismoTamano.
  ///
  /// In es, this message translates to:
  /// **'mismo tamaño de trozo'**
  String get comparacionMismoTamano;

  /// No description provided for @comparacionMismoNumero.
  ///
  /// In es, this message translates to:
  /// **'el mismo número de trozos'**
  String get comparacionMismoNumero;

  /// No description provided for @simetriaPreguntaVertical.
  ///
  /// In es, this message translates to:
  /// **'¿es simétrica respecto al eje vertical?'**
  String get simetriaPreguntaVertical;

  /// No description provided for @simetriaPreguntaHorizontal.
  ///
  /// In es, this message translates to:
  /// **'¿es simétrica respecto al eje horizontal?'**
  String get simetriaPreguntaHorizontal;

  /// No description provided for @barrasPreguntaValor.
  ///
  /// In es, this message translates to:
  /// **'¿cuántos en \"{etiqueta}\"?'**
  String barrasPreguntaValor(String etiqueta);

  /// No description provided for @barrasPreguntaTotal.
  ///
  /// In es, this message translates to:
  /// **'¿cuál es el total?'**
  String get barrasPreguntaTotal;

  /// No description provided for @aumentoVerbo.
  ///
  /// In es, this message translates to:
  /// **'aumenta un {porcentaje}% sobre'**
  String aumentoVerbo(int porcentaje);

  /// No description provided for @descuentoVerbo.
  ///
  /// In es, this message translates to:
  /// **'descuenta un {porcentaje}% sobre'**
  String descuentoVerbo(int porcentaje);

  /// No description provided for @respuestaSi.
  ///
  /// In es, this message translates to:
  /// **'sí'**
  String get respuestaSi;

  /// No description provided for @respuestaNo.
  ///
  /// In es, this message translates to:
  /// **'no'**
  String get respuestaNo;

  /// No description provided for @habRitmoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ritmo del juego'**
  String get habRitmoTitulo;

  /// No description provided for @habRitmoSnack.
  ///
  /// In es, this message translates to:
  /// **'Ritmo \"{ritmo}\". Se aplicará en la próxima escena.'**
  String habRitmoSnack(String ritmo);

  /// No description provided for @habSyncFaltaToken.
  ///
  /// In es, this message translates to:
  /// **'Vincula primero una cuenta desde el icono de perfil.'**
  String get habSyncFaltaToken;

  /// No description provided for @habSyncEnProgreso.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando…'**
  String get habSyncEnProgreso;

  /// No description provided for @habSyncResumen.
  ///
  /// In es, this message translates to:
  /// **'Sync OK. Esquirlas {esquirlas} · {flags} flags · {habilidades} habilidades.'**
  String habSyncResumen(int esquirlas, int flags, int habilidades);

  /// No description provided for @habSyncSesionCaduco.
  ///
  /// In es, this message translates to:
  /// **'La sesión caducó. Ábrela desde \"Cuenta\" e inicia sesión otra vez.'**
  String get habSyncSesionCaduco;

  /// No description provided for @habApiError.
  ///
  /// In es, this message translates to:
  /// **'API {codigo}: {mensaje}'**
  String habApiError(int codigo, String mensaje);

  /// No description provided for @habRedError.
  ///
  /// In es, this message translates to:
  /// **'Red: {error}'**
  String habRedError(String error);

  /// No description provided for @habReiniciarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar progreso'**
  String get habReiniciarTitulo;

  /// No description provided for @habReiniciarCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Borra escenas vistas, habilidades, esquirlas y rango. La próxima vez que abras la app, empezarás desde la apertura.'**
  String get habReiniciarCuerpo;

  /// No description provided for @habReiniciarBoton.
  ///
  /// In es, this message translates to:
  /// **'reiniciar'**
  String get habReiniciarBoton;

  /// No description provided for @habReiniciarHecho.
  ///
  /// In es, this message translates to:
  /// **'Progreso reiniciado. Cierra la app y vuélvela a abrir.'**
  String get habReiniciarHecho;

  /// No description provided for @habEsquirlasResumen.
  ///
  /// In es, this message translates to:
  /// **'{n} esquirlas'**
  String habEsquirlasResumen(int n);

  /// No description provided for @habNivelInexplorada.
  ///
  /// In es, this message translates to:
  /// **'sin tocar'**
  String get habNivelInexplorada;

  /// No description provided for @habNivelIntroducida.
  ///
  /// In es, this message translates to:
  /// **'introducida'**
  String get habNivelIntroducida;

  /// No description provided for @habNivelEnDesarrollo.
  ///
  /// In es, this message translates to:
  /// **'en desarrollo'**
  String get habNivelEnDesarrollo;

  /// No description provided for @habNivelCompetente.
  ///
  /// In es, this message translates to:
  /// **'competente'**
  String get habNivelCompetente;

  /// No description provided for @habNivelMaestria.
  ///
  /// In es, this message translates to:
  /// **'maestría'**
  String get habNivelMaestria;

  /// No description provided for @habChipNivel.
  ///
  /// In es, this message translates to:
  /// **'{n} {etiqueta}'**
  String habChipNivel(int n, String etiqueta);

  /// No description provided for @habFilaResumen.
  ///
  /// In es, this message translates to:
  /// **'{nivel} · precisión {precision}% · {intentos} intentos'**
  String habFilaResumen(String nivel, int precision, int intentos);

  /// No description provided for @cuentaTitulo.
  ///
  /// In es, this message translates to:
  /// **'cuenta'**
  String get cuentaTitulo;

  /// No description provided for @cuentaCrearTitulo.
  ///
  /// In es, this message translates to:
  /// **'crear cuenta'**
  String get cuentaCrearTitulo;

  /// No description provided for @cuentaIniciarTitulo.
  ///
  /// In es, this message translates to:
  /// **'iniciar sesión'**
  String get cuentaIniciarTitulo;

  /// No description provided for @cuentaCerrarSesionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get cuentaCerrarSesionTitulo;

  /// No description provided for @cuentaCerrarSesionCuerpo.
  ///
  /// In es, this message translates to:
  /// **'El progreso local sigue intacto, solo se desconecta del servidor.'**
  String get cuentaCerrarSesionCuerpo;

  /// No description provided for @cuentaBotonCerrar.
  ///
  /// In es, this message translates to:
  /// **'cerrar'**
  String get cuentaBotonCerrar;

  /// No description provided for @cuentaSinCuentaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin cuenta vinculada'**
  String get cuentaSinCuentaTitulo;

  /// No description provided for @cuentaSinCuentaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Puedes seguir jugando offline. Si vinculas una cuenta, el progreso se guarda en el servidor y se desbloquea el tutor para cuando te atasques.'**
  String get cuentaSinCuentaCuerpo;

  /// No description provided for @cuentaBotonCrear.
  ///
  /// In es, this message translates to:
  /// **'crear cuenta'**
  String get cuentaBotonCrear;

  /// No description provided for @cuentaBotonIniciar.
  ///
  /// In es, this message translates to:
  /// **'iniciar sesión'**
  String get cuentaBotonIniciar;

  /// No description provided for @cuentaVinculadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cuenta vinculada'**
  String get cuentaVinculadaTitulo;

  /// No description provided for @cuentaVinculadaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'El progreso se sincroniza con el servidor y el tutor está disponible cuando te atascas.'**
  String get cuentaVinculadaCuerpo;

  /// No description provided for @cuentaBotonCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'cerrar sesión'**
  String get cuentaBotonCerrarSesion;

  /// No description provided for @cuentaCaducadaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sesión caducada'**
  String get cuentaCaducadaTitulo;

  /// No description provided for @cuentaCaducadaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a iniciar sesión para sincronizar y usar el tutor:\n{email}'**
  String cuentaCaducadaCuerpo(String email);

  /// No description provided for @cuentaCampoEmail.
  ///
  /// In es, this message translates to:
  /// **'email del tutor'**
  String get cuentaCampoEmail;

  /// No description provided for @cuentaCampoPassword.
  ///
  /// In es, this message translates to:
  /// **'contraseña'**
  String get cuentaCampoPassword;

  /// No description provided for @cuentaCampoPasswordMin.
  ///
  /// In es, this message translates to:
  /// **'contraseña (mínimo 8)'**
  String get cuentaCampoPasswordMin;

  /// No description provided for @cuentaCampoNombreTutor.
  ///
  /// In es, this message translates to:
  /// **'nombre del tutor (opcional)'**
  String get cuentaCampoNombreTutor;

  /// No description provided for @cuentaCampoNombreNino.
  ///
  /// In es, this message translates to:
  /// **'nombre del niño'**
  String get cuentaCampoNombreNino;

  /// No description provided for @cuentaErrorCamposRegistro.
  ///
  /// In es, this message translates to:
  /// **'Pon email, contraseña (mínimo 8 caracteres) y nombre del niño.'**
  String get cuentaErrorCamposRegistro;

  /// No description provided for @cuentaErrorCamposLogin.
  ///
  /// In es, this message translates to:
  /// **'Pon el email y la contraseña.'**
  String get cuentaErrorCamposLogin;

  /// No description provided for @cuentaErrorRed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar.'**
  String get cuentaErrorRed;

  /// No description provided for @cuentaBotonCreando.
  ///
  /// In es, this message translates to:
  /// **'creando…'**
  String get cuentaBotonCreando;

  /// No description provided for @cuentaBotonEntrando.
  ///
  /// In es, this message translates to:
  /// **'entrando…'**
  String get cuentaBotonEntrando;

  /// No description provided for @cuentaResetTitulo.
  ///
  /// In es, this message translates to:
  /// **'OLVIDÉ MI CONTRASEÑA'**
  String get cuentaResetTitulo;

  /// No description provided for @cuentaResetEmailInvalido.
  ///
  /// In es, this message translates to:
  /// **'Escribe un email válido.'**
  String get cuentaResetEmailInvalido;

  /// No description provided for @cuentaResetErrorRed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar. Inténtalo más tarde.'**
  String get cuentaResetErrorRed;

  /// No description provided for @cuentaResetTagline.
  ///
  /// In es, this message translates to:
  /// **'No pasa nada.'**
  String get cuentaResetTagline;

  /// No description provided for @cuentaResetIntro.
  ///
  /// In es, this message translates to:
  /// **'Pon tu email y te mandamos un enlace para crear una contraseña nueva. Caduca en 30 minutos.'**
  String get cuentaResetIntro;

  /// No description provided for @cuentaResetCampoEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get cuentaResetCampoEmail;

  /// No description provided for @cuentaResetBoton.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR ENLACE'**
  String get cuentaResetBoton;

  /// No description provided for @cuentaResetEnviadoCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Si esa dirección está registrada,\nte llegará un enlace en unos minutos.'**
  String get cuentaResetEnviadoCuerpo;

  /// No description provided for @cuentaResetEnviadoSpam.
  ///
  /// In es, this message translates to:
  /// **'Revisa también la carpeta de spam.'**
  String get cuentaResetEnviadoSpam;

  /// No description provided for @cuentaResetBotonVolver.
  ///
  /// In es, this message translates to:
  /// **'VOLVER'**
  String get cuentaResetBotonVolver;

  /// No description provided for @panelTutorTitulo.
  ///
  /// In es, this message translates to:
  /// **'MODO TUTOR'**
  String get panelTutorTitulo;

  /// No description provided for @panelTutorTooltipSalir.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get panelTutorTooltipSalir;

  /// No description provided for @panelTutorErrorAuth.
  ///
  /// In es, this message translates to:
  /// **'Email o contraseña incorrectos.'**
  String get panelTutorErrorAuth;

  /// No description provided for @panelTutorErrorServidor.
  ///
  /// In es, this message translates to:
  /// **'Error del servidor ({codigo}).'**
  String panelTutorErrorServidor(int codigo);

  /// No description provided for @panelTutorErrorRed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar al servidor.'**
  String get panelTutorErrorRed;

  /// No description provided for @panelTutorErrorProgreso.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el progreso (token caducado).'**
  String get panelTutorErrorProgreso;

  /// No description provided for @panelTutorTagline.
  ///
  /// In es, this message translates to:
  /// **'Para ti, no para el peque.'**
  String get panelTutorTagline;

  /// No description provided for @panelTutorIntro.
  ///
  /// In es, this message translates to:
  /// **'Entra con tu email y contraseña para ver el progreso real.'**
  String get panelTutorIntro;

  /// No description provided for @panelTutorCampoEmail.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get panelTutorCampoEmail;

  /// No description provided for @panelTutorCampoPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get panelTutorCampoPassword;

  /// No description provided for @panelTutorBotonEntrar.
  ///
  /// In es, this message translates to:
  /// **'ENTRAR'**
  String get panelTutorBotonEntrar;

  /// No description provided for @panelTutorSinNinos.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta aún no tiene ningún niño.'**
  String get panelTutorSinNinos;

  /// No description provided for @panelTutorElegirNino.
  ///
  /// In es, this message translates to:
  /// **'Elige un niño para ver su progreso.'**
  String get panelTutorElegirNino;

  /// No description provided for @panelTutorSaludoConNombre.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}.'**
  String panelTutorSaludoConNombre(String nombre);

  /// No description provided for @panelTutorSubtituloSaludo.
  ///
  /// In es, this message translates to:
  /// **'Aquí tienes el progreso real, sin adornos.'**
  String get panelTutorSubtituloSaludo;

  /// No description provided for @sonidoTitulo.
  ///
  /// In es, this message translates to:
  /// **'sonido'**
  String get sonidoTitulo;

  /// No description provided for @sonidoSeccionVolumen.
  ///
  /// In es, this message translates to:
  /// **'VOLUMEN POR CAPA'**
  String get sonidoSeccionVolumen;

  /// No description provided for @sonidoModoSilencioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Modo sin sonido'**
  String get sonidoModoSilencioTitulo;

  /// No description provided for @sonidoModoSilencioSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'el juego es completamente jugable en silencio'**
  String get sonidoModoSilencioSubtitulo;

  /// No description provided for @ajustesSeccionMaquinas.
  ///
  /// In es, this message translates to:
  /// **'MÁQUINAS'**
  String get ajustesSeccionMaquinas;

  /// No description provided for @sinPrisasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sin prisas'**
  String get sinPrisasTitulo;

  /// No description provided for @sinPrisasSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'En las máquinas de acción nada corre solo: la pieza de Encaje espera, las sombras se paran si tú te paras, las barcas no llegan a la compuerta y Salto va más despacio.'**
  String get sinPrisasSubtitulo;

  /// No description provided for @sonidoCapaAmbient.
  ///
  /// In es, this message translates to:
  /// **'viento, agua, ruido rosa del mundo'**
  String get sonidoCapaAmbient;

  /// No description provided for @sonidoCapaMusica.
  ///
  /// In es, this message translates to:
  /// **'loops de distrito y de combate'**
  String get sonidoCapaMusica;

  /// No description provided for @sonidoCapaEfectos.
  ///
  /// In es, this message translates to:
  /// **'taps, aciertos, errores'**
  String get sonidoCapaEfectos;

  /// No description provided for @sonidoCapaNarrativos.
  ///
  /// In es, this message translates to:
  /// **'motivos y efectos únicos'**
  String get sonidoCapaNarrativos;

  /// No description provided for @sonidoNotaAccesibilidad.
  ///
  /// In es, this message translates to:
  /// **'Los ajustes se guardan por perfil. Cada niño que juegue con su perfil tendrá su propia configuración de volúmenes.'**
  String get sonidoNotaAccesibilidad;

  /// No description provided for @perfHeaderQuienEres.
  ///
  /// In es, this message translates to:
  /// **'¿QUIÉN ERES?'**
  String get perfHeaderQuienEres;

  /// No description provided for @perfHeaderSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'elige un perfil o crea uno nuevo'**
  String get perfHeaderSubtitulo;

  /// No description provided for @perfBadgeActual.
  ///
  /// In es, this message translates to:
  /// **'perfil actual'**
  String get perfBadgeActual;

  /// No description provided for @perfTooltipBorrar.
  ///
  /// In es, this message translates to:
  /// **'borrar perfil'**
  String get perfTooltipBorrar;

  /// No description provided for @perfBotonNuevo.
  ///
  /// In es, this message translates to:
  /// **'nuevo perfil'**
  String get perfBotonNuevo;

  /// No description provided for @perfDialogNuevoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo perfil'**
  String get perfDialogNuevoTitulo;

  /// No description provided for @perfDialogNuevoHint.
  ///
  /// In es, this message translates to:
  /// **'nombre del jugador'**
  String get perfDialogNuevoHint;

  /// No description provided for @perfBotonCrear.
  ///
  /// In es, this message translates to:
  /// **'crear'**
  String get perfBotonCrear;

  /// No description provided for @perfDialogBorrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Borrar perfil'**
  String get perfDialogBorrarTitulo;

  /// No description provided for @perfDialogBorrarCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Se borrará todo el progreso de {nombre}. Esta acción no se puede deshacer.'**
  String perfDialogBorrarCuerpo(String nombre);

  /// No description provided for @perfBotonBorrar.
  ///
  /// In es, this message translates to:
  /// **'borrar'**
  String get perfBotonBorrar;

  /// No description provided for @nombreTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamas?'**
  String get nombreTitulo;

  /// No description provided for @nombreSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'sora te va a preguntar en un momento'**
  String get nombreSubtitulo;

  /// No description provided for @nombreBotonContinuar.
  ///
  /// In es, this message translates to:
  /// **'continuar'**
  String get nombreBotonContinuar;

  /// No description provided for @cuadernoTitulo.
  ///
  /// In es, this message translates to:
  /// **'cuaderno'**
  String get cuadernoTitulo;

  /// No description provided for @cuadernoVacio.
  ///
  /// In es, this message translates to:
  /// **'Aún no has desbloqueado entradas.\nSigue jugando — cada persona o lugar que conozcas abre una página.'**
  String get cuadernoVacio;

  /// No description provided for @cuadernoResumen.
  ///
  /// In es, this message translates to:
  /// **'{leidas} leídas · {desbloqueadas} de {total} desbloqueadas'**
  String cuadernoResumen(int leidas, int desbloqueadas, int total);

  /// No description provided for @mapaArcoResumen.
  ///
  /// In es, this message translates to:
  /// **'Arco {romano} · {vistas}/{total}'**
  String mapaArcoResumen(String romano, int vistas, int total);

  /// No description provided for @mapaMontanaTitulo.
  ///
  /// In es, this message translates to:
  /// **'LA MONTAÑA'**
  String get mapaMontanaTitulo;

  /// No description provided for @mapaMontanaSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'el horizonte espera'**
  String get mapaMontanaSubtitulo;

  /// No description provided for @mapaDistritoBloqueado.
  ///
  /// In es, this message translates to:
  /// **'se abre a las {n} esquirlas'**
  String mapaDistritoBloqueado(int n);

  /// No description provided for @puzzleBotonHuir.
  ///
  /// In es, this message translates to:
  /// **'huir'**
  String get puzzleBotonHuir;

  /// No description provided for @rangoAprendiz1.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz I'**
  String get rangoAprendiz1;

  /// No description provided for @rangoAprendiz2.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz II'**
  String get rangoAprendiz2;

  /// No description provided for @rangoAprendiz3.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz III'**
  String get rangoAprendiz3;

  /// No description provided for @rangoIniciado.
  ///
  /// In es, this message translates to:
  /// **'Iniciado'**
  String get rangoIniciado;

  /// No description provided for @ritmoTranquilo.
  ///
  /// In es, this message translates to:
  /// **'Tranquilo'**
  String get ritmoTranquilo;

  /// No description provided for @ritmoEstandar.
  ///
  /// In es, this message translates to:
  /// **'Estándar'**
  String get ritmoEstandar;

  /// No description provided for @ritmoExigente.
  ///
  /// In es, this message translates to:
  /// **'Exigente'**
  String get ritmoExigente;

  /// No description provided for @ritmoTranquiloDesc.
  ///
  /// In es, this message translates to:
  /// **'Las palabras aparecen más despacio. Los combates dan más tiempo.'**
  String get ritmoTranquiloDesc;

  /// No description provided for @ritmoEstandarDesc.
  ///
  /// In es, this message translates to:
  /// **'La velocidad base del juego.'**
  String get ritmoEstandarDesc;

  /// No description provided for @ritmoExigenteDesc.
  ///
  /// In es, this message translates to:
  /// **'Todo va más rápido. Los combates piden más agilidad.'**
  String get ritmoExigenteDesc;

  /// No description provided for @capaAmbient.
  ///
  /// In es, this message translates to:
  /// **'Ambiente'**
  String get capaAmbient;

  /// No description provided for @capaMusica.
  ///
  /// In es, this message translates to:
  /// **'Música'**
  String get capaMusica;

  /// No description provided for @capaEfectos.
  ///
  /// In es, this message translates to:
  /// **'Efectos'**
  String get capaEfectos;

  /// No description provided for @capaNarrativos.
  ///
  /// In es, this message translates to:
  /// **'Narrativos'**
  String get capaNarrativos;

  /// No description provided for @catCuadernoBitacora.
  ///
  /// In es, this message translates to:
  /// **'Bitácora'**
  String get catCuadernoBitacora;

  /// No description provided for @catCuadernoPersonajes.
  ///
  /// In es, this message translates to:
  /// **'Personajes'**
  String get catCuadernoPersonajes;

  /// No description provided for @catCuadernoFragmentos.
  ///
  /// In es, this message translates to:
  /// **'Fragmentos'**
  String get catCuadernoFragmentos;

  /// No description provided for @catCuadernoLugares.
  ///
  /// In es, this message translates to:
  /// **'Lugares'**
  String get catCuadernoLugares;

  /// No description provided for @catCuadernoHistoria.
  ///
  /// In es, this message translates to:
  /// **'Historia'**
  String get catCuadernoHistoria;

  /// No description provided for @catCuadernoNaturaleza.
  ///
  /// In es, this message translates to:
  /// **'Naturaleza'**
  String get catCuadernoNaturaleza;

  /// No description provided for @catCuadernoMitos.
  ///
  /// In es, this message translates to:
  /// **'Mitos'**
  String get catCuadernoMitos;

  /// No description provided for @puzzleHeaderAmplificar.
  ///
  /// In es, this message translates to:
  /// **'AMPLIFICAR'**
  String get puzzleHeaderAmplificar;

  /// No description provided for @puzzleInstrAmplificar.
  ///
  /// In es, this message translates to:
  /// **'completa: toca el número que falta'**
  String get puzzleInstrAmplificar;

  /// No description provided for @puzzleHeaderSumaBasica.
  ///
  /// In es, this message translates to:
  /// **'SUMAR'**
  String get puzzleHeaderSumaBasica;

  /// No description provided for @puzzleInstrSumaBasica.
  ///
  /// In es, this message translates to:
  /// **'¿cuánto suman?'**
  String get puzzleInstrSumaBasica;

  /// No description provided for @puzzleHeaderEcuacionLineal.
  ///
  /// In es, this message translates to:
  /// **'DESPEJA X'**
  String get puzzleHeaderEcuacionLineal;

  /// No description provided for @puzzleInstrEcuacionLineal.
  ///
  /// In es, this message translates to:
  /// **'¿qué valor de x hace cierta la ecuación?'**
  String get puzzleInstrEcuacionLineal;

  /// No description provided for @puzzleHeaderAngulo.
  ///
  /// In es, this message translates to:
  /// **'ÁNGULO'**
  String get puzzleHeaderAngulo;

  /// No description provided for @puzzleInstrAngulo.
  ///
  /// In es, this message translates to:
  /// **'toca el nombre del ángulo dibujado'**
  String get puzzleInstrAngulo;

  /// No description provided for @puzzleInstrAreaRectangulo.
  ///
  /// In es, this message translates to:
  /// **'área = base × altura. Toca el resultado'**
  String get puzzleInstrAreaRectangulo;

  /// No description provided for @puzzleHeaderTriangulo.
  ///
  /// In es, this message translates to:
  /// **'TRIÁNGULO'**
  String get puzzleHeaderTriangulo;

  /// No description provided for @puzzleInstrAreaTriangulo.
  ///
  /// In es, this message translates to:
  /// **'área = base × altura ÷ 2. Toca el resultado'**
  String get puzzleInstrAreaTriangulo;

  /// No description provided for @puzzleInstrCirculoPi.
  ///
  /// In es, this message translates to:
  /// **'usa la fórmula (π ≈ 3,14) y toca el resultado'**
  String get puzzleInstrCirculoPi;

  /// No description provided for @puzzleHeaderComparar.
  ///
  /// In es, this message translates to:
  /// **'COMPARAR'**
  String get puzzleHeaderComparar;

  /// No description provided for @puzzleInstrCualEsMayor.
  ///
  /// In es, this message translates to:
  /// **'toca la fracción mayor'**
  String get puzzleInstrCualEsMayor;

  /// No description provided for @puzzleInstrLeerCifras.
  ///
  /// In es, this message translates to:
  /// **'toca el decimal mayor (más cifras no es más)'**
  String get puzzleInstrLeerCifras;

  /// No description provided for @puzzleInstrMiraValor.
  ///
  /// In es, this message translates to:
  /// **'toca el decimal mayor (más cifras no es más)'**
  String get puzzleInstrMiraValor;

  /// No description provided for @puzzleHeaderContraMitad.
  ///
  /// In es, this message translates to:
  /// **'CONTRA 1/2'**
  String get puzzleHeaderContraMitad;

  /// No description provided for @puzzleInstrContraMitad.
  ///
  /// In es, this message translates to:
  /// **'toca <, =, > comparándola con 1/2'**
  String get puzzleInstrContraMitad;

  /// No description provided for @puzzleHeaderContraUno.
  ///
  /// In es, this message translates to:
  /// **'CONTRA 1'**
  String get puzzleHeaderContraUno;

  /// No description provided for @puzzleInstrContraUno.
  ///
  /// In es, this message translates to:
  /// **'toca <, =, > comparándola con 1'**
  String get puzzleInstrContraUno;

  /// No description provided for @puzzleHeaderDecimal.
  ///
  /// In es, this message translates to:
  /// **'DECIMAL'**
  String get puzzleHeaderDecimal;

  /// No description provided for @puzzleInstrQueDecimal.
  ///
  /// In es, this message translates to:
  /// **'toca el decimal que vale lo mismo'**
  String get puzzleInstrQueDecimal;

  /// No description provided for @puzzleHeaderDivisores.
  ///
  /// In es, this message translates to:
  /// **'DIVISORES'**
  String get puzzleHeaderDivisores;

  /// No description provided for @puzzleInstrCualNoDivisor.
  ///
  /// In es, this message translates to:
  /// **'tres son divisores. Toca el que NO'**
  String get puzzleInstrCualNoDivisor;

  /// No description provided for @puzzleHeaderDual.
  ///
  /// In es, this message translates to:
  /// **'DUAL'**
  String get puzzleHeaderDual;

  /// No description provided for @puzzleInstrDual.
  ///
  /// In es, this message translates to:
  /// **'calcula la operación y toca el resultado'**
  String get puzzleInstrDual;

  /// No description provided for @puzzleHeaderEscala.
  ///
  /// In es, this message translates to:
  /// **'ESCALA'**
  String get puzzleHeaderEscala;

  /// No description provided for @puzzleInstrEscalaMapa.
  ///
  /// In es, this message translates to:
  /// **'mapa 1:{denominador}'**
  String puzzleInstrEscalaMapa(int denominador);

  /// No description provided for @puzzleInstrEnPlano.
  ///
  /// In es, this message translates to:
  /// **'en plano'**
  String get puzzleInstrEnPlano;

  /// No description provided for @puzzleHeaderEspejo.
  ///
  /// In es, this message translates to:
  /// **'ESPEJO'**
  String get puzzleHeaderEspejo;

  /// No description provided for @puzzleInstrEspejo.
  ///
  /// In es, this message translates to:
  /// **'toca la fracción equivalente'**
  String get puzzleInstrEspejo;

  /// No description provided for @puzzleHeaderParte.
  ///
  /// In es, this message translates to:
  /// **'PARTE'**
  String get puzzleHeaderParte;

  /// No description provided for @puzzleInstrCalcula.
  ///
  /// In es, this message translates to:
  /// **'calcula y toca el resultado'**
  String get puzzleInstrCalcula;

  /// No description provided for @puzzleHeaderGrafico.
  ///
  /// In es, this message translates to:
  /// **'GRÁFICO'**
  String get puzzleHeaderGrafico;

  /// No description provided for @puzzleHeaderCircular.
  ///
  /// In es, this message translates to:
  /// **'CIRCULAR'**
  String get puzzleHeaderCircular;

  /// No description provided for @puzzleHeaderImpropio.
  ///
  /// In es, this message translates to:
  /// **'IMPROPIO'**
  String get puzzleHeaderImpropio;

  /// No description provided for @puzzleInstrImpropio.
  ///
  /// In es, this message translates to:
  /// **'toca el número mixto que vale igual'**
  String get puzzleInstrImpropio;

  /// No description provided for @puzzleHeaderJerarquia.
  ///
  /// In es, this message translates to:
  /// **'JERARQUÍA'**
  String get puzzleHeaderJerarquia;

  /// No description provided for @puzzleInstrJerarquiaPrimero.
  ///
  /// In es, this message translates to:
  /// **'primero × y ÷, después + y −. Toca el resultado'**
  String get puzzleInstrJerarquiaPrimero;

  /// No description provided for @puzzleInstrJerarquiaRecuerda.
  ///
  /// In es, this message translates to:
  /// **'× y ÷ antes que + y −. Toca el resultado'**
  String get puzzleInstrJerarquiaRecuerda;

  /// No description provided for @puzzleHeaderLeer.
  ///
  /// In es, this message translates to:
  /// **'LEER'**
  String get puzzleHeaderLeer;

  /// No description provided for @puzzleInstrQueNumero.
  ///
  /// In es, this message translates to:
  /// **'lee el texto y toca el número correcto'**
  String get puzzleInstrQueNumero;

  /// No description provided for @puzzleInstrQueFraccion.
  ///
  /// In es, this message translates to:
  /// **'lee el texto y toca la fracción correcta'**
  String get puzzleInstrQueFraccion;

  /// No description provided for @puzzleHeaderLongitud.
  ///
  /// In es, this message translates to:
  /// **'LONGITUD'**
  String get puzzleHeaderLongitud;

  /// No description provided for @puzzleInstrConvierteMedida.
  ///
  /// In es, this message translates to:
  /// **'convierte y toca el resultado'**
  String get puzzleInstrConvierteMedida;

  /// No description provided for @puzzleHeaderMedia.
  ///
  /// In es, this message translates to:
  /// **'MEDIA'**
  String get puzzleHeaderMedia;

  /// No description provided for @puzzleInstrCalculaMedia.
  ///
  /// In es, this message translates to:
  /// **'suma y divide. Toca la media'**
  String get puzzleInstrCalculaMedia;

  /// No description provided for @puzzleHeaderConvertir.
  ///
  /// In es, this message translates to:
  /// **'CONVERTIR'**
  String get puzzleHeaderConvertir;

  /// No description provided for @puzzleInstrConvertirImpropia.
  ///
  /// In es, this message translates to:
  /// **'toca la fracción impropia equivalente'**
  String get puzzleInstrConvertirImpropia;

  /// No description provided for @puzzleInstrCualEsModa.
  ///
  /// In es, this message translates to:
  /// **'toca el valor de la {modo}'**
  String puzzleInstrCualEsModa(String modo);

  /// No description provided for @puzzleHeaderOpDecimal.
  ///
  /// In es, this message translates to:
  /// **'OP. DECIMAL'**
  String get puzzleHeaderOpDecimal;

  /// No description provided for @puzzleInstrCuantoValeOp.
  ///
  /// In es, this message translates to:
  /// **'calcula y toca el resultado'**
  String get puzzleInstrCuantoValeOp;

  /// No description provided for @puzzleHeaderDecimalFraccion.
  ///
  /// In es, this message translates to:
  /// **'DECIMAL Y FRACCIÓN'**
  String get puzzleHeaderDecimalFraccion;

  /// No description provided for @puzzleInstrFraccionDecimal.
  ///
  /// In es, this message translates to:
  /// **'calcula la operación mixta y toca el resultado'**
  String get puzzleInstrFraccionDecimal;

  /// No description provided for @puzzleHeaderOrdenar.
  ///
  /// In es, this message translates to:
  /// **'ORDENAR'**
  String get puzzleHeaderOrdenar;

  /// No description provided for @puzzleInstrOrdenar.
  ///
  /// In es, this message translates to:
  /// **'toca la fila ordenada de menor a mayor'**
  String get puzzleInstrOrdenar;

  /// No description provided for @puzzleHeaderPerimetro.
  ///
  /// In es, this message translates to:
  /// **'PERÍMETRO'**
  String get puzzleHeaderPerimetro;

  /// No description provided for @puzzleInstrPerimetro.
  ///
  /// In es, this message translates to:
  /// **'suma los lados y toca el perímetro'**
  String get puzzleInstrPerimetro;

  /// No description provided for @puzzleHeaderPoligono.
  ///
  /// In es, this message translates to:
  /// **'POLÍGONO'**
  String get puzzleHeaderPoligono;

  /// No description provided for @puzzleInstrPoligono.
  ///
  /// In es, this message translates to:
  /// **'toca el nombre del polígono dibujado'**
  String get puzzleInstrPoligono;

  /// No description provided for @puzzleHeaderPorcentaje.
  ///
  /// In es, this message translates to:
  /// **'PORCENTAJE'**
  String get puzzleHeaderPorcentaje;

  /// No description provided for @puzzleInstrPorcentajeFraccion.
  ///
  /// In es, this message translates to:
  /// **'toca la fracción equivalente al porcentaje'**
  String get puzzleInstrPorcentajeFraccion;

  /// No description provided for @puzzleInstrPorcentajeDe.
  ///
  /// In es, this message translates to:
  /// **'el {porcentaje} % de {cantidad}'**
  String puzzleInstrPorcentajeDe(int porcentaje, int cantidad);

  /// No description provided for @puzzleHeaderQuePorcentaje.
  ///
  /// In es, this message translates to:
  /// **'¿QUÉ %?'**
  String get puzzleHeaderQuePorcentaje;

  /// No description provided for @puzzleInstrQuePorcentaje.
  ///
  /// In es, this message translates to:
  /// **'toca el porcentaje correcto'**
  String get puzzleInstrQuePorcentaje;

  /// No description provided for @puzzleHeaderPrimos.
  ///
  /// In es, this message translates to:
  /// **'PRIMOS'**
  String get puzzleHeaderPrimos;

  /// No description provided for @puzzleInstrEsPrimo.
  ///
  /// In es, this message translates to:
  /// **'toca SÍ si es primo, NO si no lo es'**
  String get puzzleInstrEsPrimo;

  /// No description provided for @puzzleHeaderProbabilidad.
  ///
  /// In es, this message translates to:
  /// **'PROBABILIDAD'**
  String get puzzleHeaderProbabilidad;

  /// No description provided for @puzzleInstrProbabilidadSaco.
  ///
  /// In es, this message translates to:
  /// **'saco con {favorables} rojas y {otros} azules'**
  String puzzleInstrProbabilidadSaco(int favorables, int otros);

  /// No description provided for @puzzleInstrProbabilidadFormula.
  ///
  /// In es, this message translates to:
  /// **'toca la fracción que da la probabilidad'**
  String get puzzleInstrProbabilidadFormula;

  /// No description provided for @puzzleHeaderPProb.
  ///
  /// In es, this message translates to:
  /// **'P → %'**
  String get puzzleHeaderPProb;

  /// No description provided for @puzzleInstrPEquals.
  ///
  /// In es, this message translates to:
  /// **'P = {numerador}/{denominador}'**
  String puzzleInstrPEquals(int numerador, int denominador);

  /// No description provided for @puzzleInstrComoPorcentaje.
  ///
  /// In es, this message translates to:
  /// **'toca el porcentaje equivalente a la fracción'**
  String get puzzleInstrComoPorcentaje;

  /// No description provided for @puzzleHeaderProporcion.
  ///
  /// In es, this message translates to:
  /// **'PROPORCIÓN'**
  String get puzzleHeaderProporcion;

  /// No description provided for @puzzleInstrCompletaProporcion.
  ///
  /// In es, this message translates to:
  /// **'completa: toca el número que falta'**
  String get puzzleInstrCompletaProporcion;

  /// No description provided for @puzzleInstrSiEsto.
  ///
  /// In es, this message translates to:
  /// **'si esto, entonces…'**
  String get puzzleInstrSiEsto;

  /// No description provided for @puzzleHeaderRazon.
  ///
  /// In es, this message translates to:
  /// **'RAZÓN'**
  String get puzzleHeaderRazon;

  /// No description provided for @puzzleInstrRazon.
  ///
  /// In es, this message translates to:
  /// **'toca la razón ya reducida'**
  String get puzzleInstrRazon;

  /// No description provided for @puzzleHeaderRedondear.
  ///
  /// In es, this message translates to:
  /// **'REDONDEAR'**
  String get puzzleHeaderRedondear;

  /// No description provided for @puzzleInstrRedondear.
  ///
  /// In es, this message translates to:
  /// **'toca el redondeo a la décima'**
  String get puzzleInstrRedondear;

  /// No description provided for @puzzleHeaderSimetria.
  ///
  /// In es, this message translates to:
  /// **'SIMETRÍA'**
  String get puzzleHeaderSimetria;

  /// No description provided for @puzzleHeaderSimplificar.
  ///
  /// In es, this message translates to:
  /// **'SIMPLIFICAR'**
  String get puzzleHeaderSimplificar;

  /// No description provided for @puzzleInstrSimplificar.
  ///
  /// In es, this message translates to:
  /// **'toca la fracción reducida al máximo'**
  String get puzzleInstrSimplificar;

  /// No description provided for @puzzleHeaderSuperficie.
  ///
  /// In es, this message translates to:
  /// **'SUPERFICIE'**
  String get puzzleHeaderSuperficie;

  /// No description provided for @puzzleInstrSuperficie.
  ///
  /// In es, this message translates to:
  /// **'convierte la superficie. Toca el resultado'**
  String get puzzleInstrSuperficie;

  /// No description provided for @puzzleHeaderTiempo.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO'**
  String get puzzleHeaderTiempo;

  /// No description provided for @puzzleInstrTiempo.
  ///
  /// In es, this message translates to:
  /// **'convierte y toca el resultado'**
  String get puzzleInstrTiempo;

  /// No description provided for @puzzleHeaderVolumen.
  ///
  /// In es, this message translates to:
  /// **'VOLUMEN'**
  String get puzzleHeaderVolumen;

  /// No description provided for @puzzleInstrVolumenFormula.
  ///
  /// In es, this message translates to:
  /// **'V = largo × ancho × alto. Toca el volumen'**
  String get puzzleInstrVolumenFormula;

  /// No description provided for @estadisticoModa.
  ///
  /// In es, this message translates to:
  /// **'moda'**
  String get estadisticoModa;

  /// No description provided for @estadisticoMediana.
  ///
  /// In es, this message translates to:
  /// **'mediana'**
  String get estadisticoMediana;

  /// No description provided for @sonidoDescargaConectando.
  ///
  /// In es, this message translates to:
  /// **'Conectando con el servidor…'**
  String get sonidoDescargaConectando;

  /// No description provided for @sonidoDescargaBajandoConTotal.
  ///
  /// In es, this message translates to:
  /// **'Bajando {mb} / {total} MB'**
  String sonidoDescargaBajandoConTotal(String mb, String total);

  /// No description provided for @sonidoDescargaBajandoSinTotal.
  ///
  /// In es, this message translates to:
  /// **'Bajando {mb} MB'**
  String sonidoDescargaBajandoSinTotal(String mb);

  /// No description provided for @sonidoDescargaVerificando.
  ///
  /// In es, this message translates to:
  /// **'Verificando integridad…'**
  String get sonidoDescargaVerificando;

  /// No description provided for @sonidoDescargaInstalando.
  ///
  /// In es, this message translates to:
  /// **'Instalando {actual} / {total}'**
  String sonidoDescargaInstalando(int actual, int total);

  /// No description provided for @cuentaErrorCamposAnadirNino.
  ///
  /// In es, this message translates to:
  /// **'Pon el email, la contraseña y el nombre del niño.'**
  String get cuentaErrorCamposAnadirNino;

  /// No description provided for @cuentaAnadirNinoTitulo.
  ///
  /// In es, this message translates to:
  /// **'AÑADIR NIÑO'**
  String get cuentaAnadirNinoTitulo;

  /// No description provided for @cuentaAnadirNinoTagline.
  ///
  /// In es, this message translates to:
  /// **'Mete el email y la contraseña del tutor que ya tiene cuenta. Añadiremos a este niño bajo esa misma cuenta.'**
  String get cuentaAnadirNinoTagline;

  /// No description provided for @cuentaAnadirNinoBoton.
  ///
  /// In es, this message translates to:
  /// **'AÑADIR NIÑO'**
  String get cuentaAnadirNinoBoton;

  /// No description provided for @cuentaAnadirNinoBotonEnviando.
  ///
  /// In es, this message translates to:
  /// **'AÑADIENDO…'**
  String get cuentaAnadirNinoBotonEnviando;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'es', 'eu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
