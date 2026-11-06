import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
    Locale('es'),
    Locale('eu')
  ];

  /// Nombre de la app (provisional).
  ///
  /// In es, this message translates to:
  /// **'Concejo'**
  String get nombreApp;

  /// No description provided for @pestanaAsuntos.
  ///
  /// In es, this message translates to:
  /// **'Asuntos'**
  String get pestanaAsuntos;

  /// No description provided for @pestanaSeHaHecho.
  ///
  /// In es, this message translates to:
  /// **'¿Se ha hecho?'**
  String get pestanaSeHaHecho;

  /// No description provided for @faseBorrador.
  ///
  /// In es, this message translates to:
  /// **'En preparación'**
  String get faseBorrador;

  /// No description provided for @faseDebate.
  ///
  /// In es, this message translates to:
  /// **'En debate'**
  String get faseDebate;

  /// No description provided for @faseDecision.
  ///
  /// In es, this message translates to:
  /// **'Se decide ahora'**
  String get faseDecision;

  /// No description provided for @faseSeguimiento.
  ///
  /// In es, this message translates to:
  /// **'Decidido'**
  String get faseSeguimiento;

  /// No description provided for @sinAsuntos.
  ///
  /// In es, this message translates to:
  /// **'No hay asuntos en esta fase.'**
  String get sinAsuntos;

  /// No description provided for @tipoVinculante.
  ///
  /// In es, this message translates to:
  /// **'Decide el grupo'**
  String get tipoVinculante;

  /// No description provided for @tipoConCompromiso.
  ///
  /// In es, this message translates to:
  /// **'Con compromiso previo'**
  String get tipoConCompromiso;

  /// No description provided for @tipoConsultiva.
  ///
  /// In es, this message translates to:
  /// **'Consultiva'**
  String get tipoConsultiva;

  /// No description provided for @explicaVinculante.
  ///
  /// In es, this message translates to:
  /// **'Lo que salga lo decide el propio grupo, según sus normas.'**
  String get explicaVinculante;

  /// No description provided for @explicaConCompromiso.
  ///
  /// In es, this message translates to:
  /// **'El órgano formal se ha comprometido antes a ejecutar lo que salga:'**
  String get explicaConCompromiso;

  /// No description provided for @explicaConsultiva.
  ///
  /// In es, this message translates to:
  /// **'Sirve para saber qué piensa la gente. Decide el órgano formal.'**
  String get explicaConsultiva;

  /// No description provided for @seccionCalendario.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get seccionCalendario;

  /// No description provided for @calendarioDebate.
  ///
  /// In es, this message translates to:
  /// **'Debate: desde el {fecha}'**
  String calendarioDebate(String fecha);

  /// No description provided for @calendarioDecision.
  ///
  /// In es, this message translates to:
  /// **'Decisión: del {desde} al {hasta}'**
  String calendarioDecision(String desde, String hasta);

  /// No description provided for @seccionComoSeDecide.
  ///
  /// In es, this message translates to:
  /// **'Cómo se decide'**
  String get seccionComoSeDecide;

  /// No description provided for @formaVotacion.
  ///
  /// In es, this message translates to:
  /// **'Votación: sí, no o abstención'**
  String get formaVotacion;

  /// No description provided for @formaEleccion.
  ///
  /// In es, this message translates to:
  /// **'Elegir entre opciones: marca todas las que aceptas'**
  String get formaEleccion;

  /// No description provided for @formaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento: se aprueba si nadie plantea una objeción razonada'**
  String get formaConsentimiento;

  /// No description provided for @formaPresupuesto.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto: apoya las propuestas que quieras; entran por apoyos mientras haya dinero'**
  String get formaPresupuesto;

  /// No description provided for @mayoriaSimple.
  ///
  /// In es, this message translates to:
  /// **'Mayoría simple (más síes que noes)'**
  String get mayoriaSimple;

  /// No description provided for @mayoriaAbsoluta.
  ///
  /// In es, this message translates to:
  /// **'Mayoría absoluta (más de la mitad de los votos)'**
  String get mayoriaAbsoluta;

  /// No description provided for @mayoriaDosTercios.
  ///
  /// In es, this message translates to:
  /// **'Dos tercios de los síes y noes'**
  String get mayoriaDosTercios;

  /// No description provided for @quorum.
  ///
  /// In es, this message translates to:
  /// **'Hace falta que participen al menos {cantidad} personas'**
  String quorum(int cantidad);

  /// No description provided for @sinQuorumRegla.
  ///
  /// In es, this message translates to:
  /// **'Sin mínimo de participación'**
  String get sinQuorumRegla;

  /// No description provided for @votoSecreto.
  ///
  /// In es, this message translates to:
  /// **'Voto secreto'**
  String get votoSecreto;

  /// No description provided for @votoNominal.
  ///
  /// In es, this message translates to:
  /// **'Voto a la vista (se sabe quién vota qué)'**
  String get votoNominal;

  /// No description provided for @reglasFijas.
  ///
  /// In es, this message translates to:
  /// **'Estas reglas se fijaron antes de abrir y no se pueden cambiar.'**
  String get reglasFijas;

  /// No description provided for @seccionEntorno.
  ///
  /// In es, this message translates to:
  /// **'Efecto sobre el entorno'**
  String get seccionEntorno;

  /// No description provided for @seccionCoste.
  ///
  /// In es, this message translates to:
  /// **'Coste'**
  String get seccionCoste;

  /// No description provided for @verTextoCompleto.
  ///
  /// In es, this message translates to:
  /// **'Texto completo'**
  String get verTextoCompleto;

  /// No description provided for @pestanaInformacion.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get pestanaInformacion;

  /// No description provided for @pestanaDebate.
  ///
  /// In es, this message translates to:
  /// **'Debate'**
  String get pestanaDebate;

  /// No description provided for @pestanaDecidir.
  ///
  /// In es, this message translates to:
  /// **'Decidir'**
  String get pestanaDecidir;

  /// No description provided for @pestanaResultado.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get pestanaResultado;

  /// No description provided for @columnaAFavor.
  ///
  /// In es, this message translates to:
  /// **'A favor'**
  String get columnaAFavor;

  /// No description provided for @columnaEnContra.
  ///
  /// In es, this message translates to:
  /// **'En contra'**
  String get columnaEnContra;

  /// No description provided for @columnaDudas.
  ///
  /// In es, this message translates to:
  /// **'Dudas'**
  String get columnaDudas;

  /// No description provided for @columnaCambios.
  ///
  /// In es, this message translates to:
  /// **'Propuestas de cambio'**
  String get columnaCambios;

  /// No description provided for @columnaVacia.
  ///
  /// In es, this message translates to:
  /// **'Nadie ha escrito aquí todavía.'**
  String get columnaVacia;

  /// No description provided for @vecinaAnonima.
  ///
  /// In es, this message translates to:
  /// **'Vecina del pueblo'**
  String get vecinaAnonima;

  /// No description provided for @aportar.
  ///
  /// In es, this message translates to:
  /// **'Aportar'**
  String get aportar;

  /// No description provided for @responder.
  ///
  /// In es, this message translates to:
  /// **'Responder'**
  String get responder;

  /// No description provided for @tuAportacion.
  ///
  /// In es, this message translates to:
  /// **'Lo que quieres decir'**
  String get tuAportacion;

  /// No description provided for @tipoDeAportacion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es?'**
  String get tipoDeAportacion;

  /// No description provided for @aportarAnonima.
  ///
  /// In es, this message translates to:
  /// **'Sin mi nombre (lo verá la mesa antes de publicarlo)'**
  String get aportarAnonima;

  /// No description provided for @publicar.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publicar;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @debateCerrado.
  ///
  /// In es, this message translates to:
  /// **'El debate está cerrado.'**
  String get debateCerrado;

  /// No description provided for @pendienteMesa.
  ///
  /// In es, this message translates to:
  /// **'Tu aportación sin nombre espera a que la vea la mesa.'**
  String get pendienteMesa;

  /// No description provided for @decisionAunNo.
  ///
  /// In es, this message translates to:
  /// **'La decisión se abre el {fecha}. Mientras, puedes participar en el debate.'**
  String decisionAunNo(String fecha);

  /// No description provided for @yaHasVotado.
  ///
  /// In es, this message translates to:
  /// **'Ya has participado. Gracias.'**
  String get yaHasVotado;

  /// No description provided for @votoSi.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get votoSi;

  /// No description provided for @votoNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get votoNo;

  /// No description provided for @votoAbstencion.
  ///
  /// In es, this message translates to:
  /// **'Abstención'**
  String get votoAbstencion;

  /// No description provided for @enviarVoto.
  ///
  /// In es, this message translates to:
  /// **'Enviar mi voto'**
  String get enviarVoto;

  /// No description provided for @confirmarVoto.
  ///
  /// In es, this message translates to:
  /// **'¿Envías tu voto? Después no se puede cambiar.'**
  String get confirmarVoto;

  /// No description provided for @enviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get enviar;

  /// No description provided for @bolsaRestante.
  ///
  /// In es, this message translates to:
  /// **'Has elegido {gastado} de {bolsa}. Lo que no quepa no entrará.'**
  String bolsaRestante(String gastado, String bolsa);

  /// No description provided for @votoEnBlanco.
  ///
  /// In es, this message translates to:
  /// **'Si no marcas nada, cuenta como voto en blanco.'**
  String get votoEnBlanco;

  /// No description provided for @rondaConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Vuelta {ronda} de {maximo}'**
  String rondaConsentimiento(int ronda, int maximo);

  /// No description provided for @sinObjeciones.
  ///
  /// In es, this message translates to:
  /// **'Por ahora nadie ha planteado objeciones.'**
  String get sinObjeciones;

  /// No description provided for @objecionesVivas.
  ///
  /// In es, this message translates to:
  /// **'Objeciones por resolver'**
  String get objecionesVivas;

  /// No description provided for @objetar.
  ///
  /// In es, this message translates to:
  /// **'Plantear una objeción'**
  String get objetar;

  /// No description provided for @queDanoCausa.
  ///
  /// In es, this message translates to:
  /// **'¿Qué daño causaría la propuesta?'**
  String get queDanoCausa;

  /// No description provided for @objetarNoEsContra.
  ///
  /// In es, this message translates to:
  /// **'Objetar no es estar en contra: explica qué daño causaría y, si puedes, cómo evitarlo.'**
  String get objetarNoEsContra;

  /// No description provided for @resultadoAprobada.
  ///
  /// In es, this message translates to:
  /// **'Aprobada'**
  String get resultadoAprobada;

  /// No description provided for @resultadoRechazada.
  ///
  /// In es, this message translates to:
  /// **'Rechazada'**
  String get resultadoRechazada;

  /// No description provided for @resultadoSinQuorum.
  ///
  /// In es, this message translates to:
  /// **'No vale: no se llegó al mínimo de participación'**
  String get resultadoSinQuorum;

  /// No description provided for @resultadoParticipacion.
  ///
  /// In es, this message translates to:
  /// **'Han participado {cantidad} personas'**
  String resultadoParticipacion(int cantidad);

  /// No description provided for @resultadoEmpate.
  ///
  /// In es, this message translates to:
  /// **'Empate: lo resolverá la mesa o una segunda vuelta'**
  String get resultadoEmpate;

  /// No description provided for @resultadoGanadora.
  ///
  /// In es, this message translates to:
  /// **'Más aceptada'**
  String get resultadoGanadora;

  /// No description provided for @presupuestoEntra.
  ///
  /// In es, this message translates to:
  /// **'Entra'**
  String get presupuestoEntra;

  /// No description provided for @presupuestoNoCabe.
  ///
  /// In es, this message translates to:
  /// **'No cabe'**
  String get presupuestoNoCabe;

  /// No description provided for @presupuestoSinApoyos.
  ///
  /// In es, this message translates to:
  /// **'Sin apoyos'**
  String get presupuestoSinApoyos;

  /// No description provided for @apoyos.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} apoyos'**
  String apoyos(int cantidad);

  /// No description provided for @sobrante.
  ///
  /// In es, this message translates to:
  /// **'Sobran {cantidad}'**
  String sobrante(String cantidad);

  /// No description provided for @recuentoEnCurso.
  ///
  /// In es, this message translates to:
  /// **'El recuento se verá al cerrar la decisión.'**
  String get recuentoEnCurso;

  /// No description provided for @seccionCompromisos.
  ///
  /// In es, this message translates to:
  /// **'Compromisos'**
  String get seccionCompromisos;

  /// No description provided for @sinCompromisos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay compromisos apuntados.'**
  String get sinCompromisos;

  /// No description provided for @compromisoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get compromisoPendiente;

  /// No description provided for @compromisoEnMarcha.
  ///
  /// In es, this message translates to:
  /// **'En marcha'**
  String get compromisoEnMarcha;

  /// No description provided for @compromisoHecho.
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get compromisoHecho;

  /// No description provided for @compromisoNoSeHara.
  ///
  /// In es, this message translates to:
  /// **'No se hará'**
  String get compromisoNoSeHara;

  /// No description provided for @compromisoVencido.
  ///
  /// In es, this message translates to:
  /// **'Fuera de plazo'**
  String get compromisoVencido;

  /// No description provided for @compromisoPara.
  ///
  /// In es, this message translates to:
  /// **'{responsable} · para el {fecha}'**
  String compromisoPara(String responsable, String fecha);

  /// No description provided for @balanceCompromisos.
  ///
  /// In es, this message translates to:
  /// **'{hechos} hechos de {total} · {vencidos} fuera de plazo'**
  String balanceCompromisos(int hechos, int total, int vencidos);

  /// No description provided for @marcarHecho.
  ///
  /// In es, this message translates to:
  /// **'Marcar como hecho'**
  String get marcarHecho;

  /// No description provided for @marcarEnMarcha.
  ///
  /// In es, this message translates to:
  /// **'Marcar en marcha'**
  String get marcarEnMarcha;

  /// No description provided for @deAsunto.
  ///
  /// In es, this message translates to:
  /// **'De: {titulo}'**
  String deAsunto(String titulo);

  /// No description provided for @ejemploAviso.
  ///
  /// In es, this message translates to:
  /// **'Pueblo de ejemplo: los datos solo están en este dispositivo.'**
  String get ejemploAviso;

  /// No description provided for @eresMesa.
  ///
  /// In es, this message translates to:
  /// **'Estás en la mesa hasta el {fecha}'**
  String eresMesa(String fecha);
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
      <String>['es', 'eu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
