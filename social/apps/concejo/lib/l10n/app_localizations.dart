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
  /// **'{cantidad, plural, =1{Hace falta que participe al menos 1 persona} other{Hace falta que participen al menos {cantidad} personas}}'**
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
  /// **'{cantidad, plural, =1{Ha participado 1 persona} other{Han participado {cantidad} personas}}'**
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
  /// **'{cantidad, plural, =1{1 apoyo} other{{cantidad} apoyos}}'**
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

  /// No description provided for @nuevoAsunto.
  ///
  /// In es, this message translates to:
  /// **'Nuevo asunto'**
  String get nuevoAsunto;

  /// No description provided for @editarAsunto.
  ///
  /// In es, this message translates to:
  /// **'Editar asunto'**
  String get editarAsunto;

  /// No description provided for @campoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get campoTitulo;

  /// No description provided for @campoResumen.
  ///
  /// In es, this message translates to:
  /// **'Resumen en tres líneas'**
  String get campoResumen;

  /// No description provided for @ayudaResumen.
  ///
  /// In es, this message translates to:
  /// **'Lo primero que se lee. Frases cortas, sin jerga.'**
  String get ayudaResumen;

  /// No description provided for @campoTexto.
  ///
  /// In es, this message translates to:
  /// **'Texto completo (opcional)'**
  String get campoTexto;

  /// No description provided for @campoTipoDecision.
  ///
  /// In es, this message translates to:
  /// **'¿Qué valor tiene lo que salga?'**
  String get campoTipoDecision;

  /// No description provided for @campoCompromiso.
  ///
  /// In es, this message translates to:
  /// **'Compromiso previo'**
  String get campoCompromiso;

  /// No description provided for @campoCoste.
  ///
  /// In es, this message translates to:
  /// **'Coste (€, opcional)'**
  String get campoCoste;

  /// No description provided for @campoEntorno.
  ///
  /// In es, this message translates to:
  /// **'Efecto sobre el entorno'**
  String get campoEntorno;

  /// No description provided for @campoInicioDebate.
  ///
  /// In es, this message translates to:
  /// **'Empieza el debate'**
  String get campoInicioDebate;

  /// No description provided for @campoInicioDecision.
  ///
  /// In es, this message translates to:
  /// **'Empieza la decisión'**
  String get campoInicioDecision;

  /// No description provided for @campoFinDecision.
  ///
  /// In es, this message translates to:
  /// **'Acaba la decisión'**
  String get campoFinDecision;

  /// No description provided for @campoForma.
  ///
  /// In es, this message translates to:
  /// **'Cómo se decide'**
  String get campoForma;

  /// No description provided for @nombreVotacion.
  ///
  /// In es, this message translates to:
  /// **'Votación'**
  String get nombreVotacion;

  /// No description provided for @nombreEleccion.
  ///
  /// In es, this message translates to:
  /// **'Elegir entre opciones'**
  String get nombreEleccion;

  /// No description provided for @nombreConsentimiento.
  ///
  /// In es, this message translates to:
  /// **'Consentimiento'**
  String get nombreConsentimiento;

  /// No description provided for @nombrePresupuesto.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get nombrePresupuesto;

  /// No description provided for @campoMayoria.
  ///
  /// In es, this message translates to:
  /// **'Mayoría'**
  String get campoMayoria;

  /// No description provided for @campoQuorum.
  ///
  /// In es, this message translates to:
  /// **'Mínimo de participación'**
  String get campoQuorum;

  /// No description provided for @campoSecreto.
  ///
  /// In es, this message translates to:
  /// **'Voto secreto'**
  String get campoSecreto;

  /// No description provided for @campoBolsa.
  ///
  /// In es, this message translates to:
  /// **'Dinero disponible (€)'**
  String get campoBolsa;

  /// No description provided for @campoRondas.
  ///
  /// In es, this message translates to:
  /// **'Vueltas antes de llevarlo a votación o a la asamblea'**
  String get campoRondas;

  /// No description provided for @opciones.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get opciones;

  /// No description provided for @propuestas.
  ///
  /// In es, this message translates to:
  /// **'Propuestas'**
  String get propuestas;

  /// No description provided for @anadirOpcion.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get anadirOpcion;

  /// No description provided for @textoOpcion.
  ///
  /// In es, this message translates to:
  /// **'Texto'**
  String get textoOpcion;

  /// No description provided for @costeOpcion.
  ///
  /// In es, this message translates to:
  /// **'Coste €'**
  String get costeOpcion;

  /// No description provided for @guardarBorrador.
  ///
  /// In es, this message translates to:
  /// **'Guardar borrador'**
  String get guardarBorrador;

  /// No description provided for @abrirAsunto.
  ///
  /// In es, this message translates to:
  /// **'Abrir el asunto'**
  String get abrirAsunto;

  /// No description provided for @confirmarAbrir.
  ///
  /// In es, this message translates to:
  /// **'Al abrirlo, todo el mundo lo verá y las reglas de decisión ya no se podrán cambiar. ¿Lo abres?'**
  String get confirmarAbrir;

  /// No description provided for @abrir.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get abrir;

  /// No description provided for @borrarBorrador.
  ///
  /// In es, this message translates to:
  /// **'Borrar borrador'**
  String get borrarBorrador;

  /// No description provided for @confirmarBorrar.
  ///
  /// In es, this message translates to:
  /// **'¿Borras este borrador?'**
  String get confirmarBorrar;

  /// No description provided for @borrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get borrar;

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @faltaParaAbrir.
  ///
  /// In es, this message translates to:
  /// **'Falta para poder abrirlo:'**
  String get faltaParaAbrir;

  /// No description provided for @problemaTitulo.
  ///
  /// In es, this message translates to:
  /// **'el título'**
  String get problemaTitulo;

  /// No description provided for @problemaResumen.
  ///
  /// In es, this message translates to:
  /// **'el resumen'**
  String get problemaResumen;

  /// No description provided for @problemaEntorno.
  ///
  /// In es, this message translates to:
  /// **'el efecto sobre el entorno'**
  String get problemaEntorno;

  /// No description provided for @problemaCompromiso.
  ///
  /// In es, this message translates to:
  /// **'el texto del compromiso previo'**
  String get problemaCompromiso;

  /// No description provided for @problemaFechas.
  ///
  /// In es, this message translates to:
  /// **'que las fechas vayan en orden (debate, decisión, fin)'**
  String get problemaFechas;

  /// No description provided for @problemaOpciones.
  ///
  /// In es, this message translates to:
  /// **'al menos dos opciones (o una propuesta)'**
  String get problemaOpciones;

  /// No description provided for @problemaRepetidas.
  ///
  /// In es, this message translates to:
  /// **'que no haya opciones repetidas'**
  String get problemaRepetidas;

  /// No description provided for @problemaBolsa.
  ///
  /// In es, this message translates to:
  /// **'el dinero disponible'**
  String get problemaBolsa;

  /// No description provided for @problemaSinCoste.
  ///
  /// In es, this message translates to:
  /// **'el coste de cada propuesta'**
  String get problemaSinCoste;

  /// No description provided for @problemaQuorum.
  ///
  /// In es, this message translates to:
  /// **'un mínimo de participación que no sea negativo'**
  String get problemaQuorum;

  /// No description provided for @verComo.
  ///
  /// In es, this message translates to:
  /// **'Ver como…'**
  String get verComo;

  /// No description provided for @rolMesa.
  ///
  /// In es, this message translates to:
  /// **'mesa'**
  String get rolMesa;

  /// No description provided for @rolVecina.
  ///
  /// In es, this message translates to:
  /// **'vecina'**
  String get rolVecina;

  /// No description provided for @pendienteModeracion.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre · espera a la mesa'**
  String get pendienteModeracion;

  /// No description provided for @publicarAportacion.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get publicarAportacion;

  /// No description provided for @retirarAportacion.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get retirarAportacion;

  /// No description provided for @motivoRetirada.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué se retira? Quedará a la vista.'**
  String get motivoRetirada;

  /// No description provided for @retiradaPorMesa.
  ///
  /// In es, this message translates to:
  /// **'Retirada por la mesa: {motivo}'**
  String retiradaPorMesa(String motivo);

  /// No description provided for @escribirResumen.
  ///
  /// In es, this message translates to:
  /// **'Escribir el resumen del debate'**
  String get escribirResumen;

  /// No description provided for @resumenDebate.
  ///
  /// In es, this message translates to:
  /// **'Resumen del debate (mesa)'**
  String get resumenDebate;

  /// No description provided for @integrarObjecion.
  ///
  /// In es, this message translates to:
  /// **'Integrar'**
  String get integrarObjecion;

  /// No description provided for @noEsObjecion.
  ///
  /// In es, this message translates to:
  /// **'No es objeción'**
  String get noEsObjecion;

  /// No description provided for @comoSeIntegra.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo se cambia la propuesta para resolverla?'**
  String get comoSeIntegra;

  /// No description provided for @porQueNoEsObjecion.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué no razona un daño? Quedará en el acta.'**
  String get porQueNoEsObjecion;

  /// No description provided for @retirarMiObjecion.
  ///
  /// In es, this message translates to:
  /// **'Retirar mi objeción'**
  String get retirarMiObjecion;

  /// No description provided for @cerrarVuelta.
  ///
  /// In es, this message translates to:
  /// **'Cerrar la vuelta {ronda}'**
  String cerrarVuelta(int ronda);

  /// No description provided for @confirmarCerrarVuelta.
  ///
  /// In es, this message translates to:
  /// **'Si no quedan objeciones vivas, la propuesta queda aprobada. Si quedan, empieza otra vuelta o pasa a votación o asamblea. ¿Cierras la vuelta?'**
  String get confirmarCerrarVuelta;

  /// No description provided for @cerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get cerrar;

  /// No description provided for @consentimientoAprobado.
  ///
  /// In es, this message translates to:
  /// **'Aprobada por consentimiento: nadie mantiene una objeción.'**
  String get consentimientoAprobado;

  /// No description provided for @consentimientoPasa.
  ///
  /// In es, this message translates to:
  /// **'Quedan objeciones sin resolver: pasa a votación o a la asamblea en persona.'**
  String get consentimientoPasa;

  /// No description provided for @objecionesResueltas.
  ///
  /// In es, this message translates to:
  /// **'Objeciones resueltas'**
  String get objecionesResueltas;

  /// No description provided for @estadoIntegrada.
  ///
  /// In es, this message translates to:
  /// **'Integrada'**
  String get estadoIntegrada;

  /// No description provided for @estadoRetirada.
  ///
  /// In es, this message translates to:
  /// **'Retirada'**
  String get estadoRetirada;

  /// No description provided for @estadoNoEsObjecion.
  ///
  /// In es, this message translates to:
  /// **'No era objeción'**
  String get estadoNoEsObjecion;

  /// No description provided for @apuntarCompromiso.
  ///
  /// In es, this message translates to:
  /// **'Apuntar compromiso'**
  String get apuntarCompromiso;

  /// No description provided for @campoQue.
  ///
  /// In es, this message translates to:
  /// **'Qué se hará'**
  String get campoQue;

  /// No description provided for @campoResponsable.
  ///
  /// In es, this message translates to:
  /// **'Quién'**
  String get campoResponsable;

  /// No description provided for @campoFechaLimite.
  ///
  /// In es, this message translates to:
  /// **'Para cuándo'**
  String get campoFechaLimite;

  /// No description provided for @marcarNoSeHara.
  ///
  /// In es, this message translates to:
  /// **'No se hará…'**
  String get marcarNoSeHara;

  /// No description provided for @porQueNoSeHara.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué no se hará? También es información para el pueblo.'**
  String get porQueNoSeHara;

  /// No description provided for @ayudaEntorno.
  ///
  /// In es, this message translates to:
  /// **'Agua, monte, ruido, paisaje, animales… Si no tiene, escribe «ninguno».'**
  String get ayudaEntorno;

  /// No description provided for @ayudaQuorum.
  ///
  /// In es, this message translates to:
  /// **'Personas que tienen que participar para que valga (0 = sin mínimo)'**
  String get ayudaQuorum;

  /// No description provided for @ayudaCompromiso.
  ///
  /// In es, this message translates to:
  /// **'Quién se compromete a qué y en qué condiciones'**
  String get ayudaCompromiso;

  /// No description provided for @ayudaResponsable.
  ///
  /// In es, this message translates to:
  /// **'Persona, comisión, «la junta»…'**
  String get ayudaResponsable;

  /// No description provided for @pdfHojaAsunto.
  ///
  /// In es, this message translates to:
  /// **'Hoja del asunto'**
  String get pdfHojaAsunto;

  /// No description provided for @pdfPapeletas.
  ///
  /// In es, this message translates to:
  /// **'Papeletas'**
  String get pdfPapeletas;

  /// No description provided for @pdfHojaRecuento.
  ///
  /// In es, this message translates to:
  /// **'Hoja de recuento'**
  String get pdfHojaRecuento;

  /// No description provided for @pdfComoParticipar.
  ///
  /// In es, this message translates to:
  /// **'Cómo participar'**
  String get pdfComoParticipar;

  /// No description provided for @pdfParticiparTexto.
  ///
  /// In es, this message translates to:
  /// **'En la app o en papel: pide la papeleta a la mesa y entrégala dentro del plazo. Cada persona vota una sola vez.'**
  String get pdfParticiparTexto;

  /// No description provided for @pdfMarcaUna.
  ///
  /// In es, this message translates to:
  /// **'Marca una sola casilla.'**
  String get pdfMarcaUna;

  /// No description provided for @pdfMarcaVarias.
  ///
  /// In es, this message translates to:
  /// **'Marca todas las opciones que aceptes.'**
  String get pdfMarcaVarias;

  /// No description provided for @pdfMarcaPropuestas.
  ///
  /// In es, this message translates to:
  /// **'Marca las propuestas que apoyas. Hay {bolsa}: entran por apoyos mientras quepan.'**
  String pdfMarcaPropuestas(String bolsa);

  /// No description provided for @pdfPapeletaSecreta.
  ///
  /// In es, this message translates to:
  /// **'Voto secreto: no escribas tu nombre. Dobla la papeleta.'**
  String get pdfPapeletaSecreta;

  /// No description provided for @pdfPapeletaNominal.
  ///
  /// In es, this message translates to:
  /// **'Voto a la vista: escribe tu nombre.'**
  String get pdfPapeletaNominal;

  /// No description provided for @pdfNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get pdfNombre;

  /// No description provided for @pdfHojaObjeciones.
  ///
  /// In es, this message translates to:
  /// **'Objeciones'**
  String get pdfHojaObjeciones;

  /// No description provided for @pdfObjecionesTexto.
  ///
  /// In es, this message translates to:
  /// **'Si la propuesta causaría algún daño, explícalo aquí. Objetar no es estar en contra: di qué daño y, si puedes, cómo evitarlo.'**
  String get pdfObjecionesTexto;

  /// No description provided for @pdfDanoYComoEvitarlo.
  ///
  /// In es, this message translates to:
  /// **'Qué daño causaría y cómo evitarlo'**
  String get pdfDanoYComoEvitarlo;

  /// No description provided for @pdfRecuentoTexto.
  ///
  /// In es, this message translates to:
  /// **'Para la mesa: cuenta las papeletas en papel entre dos personas y pasa las cifras a la app.'**
  String get pdfRecuentoTexto;

  /// No description provided for @pdfOpcion.
  ///
  /// In es, this message translates to:
  /// **'Opción'**
  String get pdfOpcion;

  /// No description provided for @pdfMarcas.
  ///
  /// In es, this message translates to:
  /// **'Marcas'**
  String get pdfMarcas;

  /// No description provided for @pdfPapeletasTotales.
  ///
  /// In es, this message translates to:
  /// **'Papeletas en total'**
  String get pdfPapeletasTotales;

  /// No description provided for @pdfEnBlanco.
  ///
  /// In es, this message translates to:
  /// **'De ellas, en blanco'**
  String get pdfEnBlanco;

  /// No description provided for @pdfPersonasAnotadas.
  ///
  /// In es, this message translates to:
  /// **'Personas anotadas como votantes en persona'**
  String get pdfPersonasAnotadas;

  /// No description provided for @pdfFirma.
  ///
  /// In es, this message translates to:
  /// **'Firma'**
  String get pdfFirma;

  /// No description provided for @pdfFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get pdfFecha;

  /// No description provided for @pdfRecorta.
  ///
  /// In es, this message translates to:
  /// **'Recorta por la línea'**
  String get pdfRecorta;

  /// No description provided for @imprimir.
  ///
  /// In es, this message translates to:
  /// **'Imprimir o compartir'**
  String get imprimir;

  /// No description provided for @votosEnPersona.
  ///
  /// In es, this message translates to:
  /// **'Votos en persona'**
  String get votosEnPersona;

  /// No description provided for @votosEnPersonaTexto.
  ///
  /// In es, this message translates to:
  /// **'Apunta a cada persona cuando te entregue su papeleta: así nadie vota dos veces ni en papel ni en la app. Al cerrar, contad las papeletas entre dos y pasad las cifras.'**
  String get votosEnPersonaTexto;

  /// No description provided for @buscarPersona.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre'**
  String get buscarPersona;

  /// No description provided for @haVotadoEnPersona.
  ///
  /// In es, this message translates to:
  /// **'Ha votado en persona'**
  String get haVotadoEnPersona;

  /// No description provided for @anotar.
  ///
  /// In es, this message translates to:
  /// **'Anotar'**
  String get anotar;

  /// No description provided for @darDeAlta.
  ///
  /// In es, this message translates to:
  /// **'No está en la lista: darla de alta'**
  String get darDeAlta;

  /// No description provided for @nombreNuevaPersona.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la persona'**
  String get nombreNuevaPersona;

  /// No description provided for @anotadasEnPersona.
  ///
  /// In es, this message translates to:
  /// **'{cantidad, plural, =1{1 persona anotada en persona} other{{cantidad} personas anotadas en persona}}'**
  String anotadasEnPersona(int cantidad);

  /// No description provided for @pasarConteo.
  ///
  /// In es, this message translates to:
  /// **'Pasar el conteo de las papeletas'**
  String get pasarConteo;

  /// No description provided for @conteosRegistrados.
  ///
  /// In es, this message translates to:
  /// **'{papeletas, plural, =1{Conteos registrados: 1 papeleta} other{Conteos registrados: {papeletas} papeletas}}'**
  String conteosRegistrados(int papeletas);

  /// No description provided for @segundaFirma.
  ///
  /// In es, this message translates to:
  /// **'Segunda firma (otra persona de la mesa)'**
  String get segundaFirma;

  /// No description provided for @registrarConteo.
  ///
  /// In es, this message translates to:
  /// **'Registrar el conteo'**
  String get registrarConteo;

  /// No description provided for @avisoPapeletasNoCuadran.
  ///
  /// In es, this message translates to:
  /// **'Las papeletas contadas en papel no cuadran con las personas anotadas. Revisadlo antes del acta.'**
  String get avisoPapeletasNoCuadran;

  /// No description provided for @sinOtraMesa.
  ///
  /// In es, this message translates to:
  /// **'Hace falta otra persona de la mesa para firmar el conteo.'**
  String get sinOtraMesa;

  /// No description provided for @aportarEnNombreDe.
  ///
  /// In es, this message translates to:
  /// **'Recoger lo que dijo alguien en persona'**
  String get aportarEnNombreDe;

  /// No description provided for @objetarEnNombreDe.
  ///
  /// In es, this message translates to:
  /// **'Recoger una objeción hecha en persona'**
  String get objetarEnNombreDe;

  /// No description provided for @quienLoDijo.
  ///
  /// In es, this message translates to:
  /// **'¿Quién lo dijo?'**
  String get quienLoDijo;

  /// No description provided for @pdfActa.
  ///
  /// In es, this message translates to:
  /// **'Acta'**
  String get pdfActa;

  /// No description provided for @pdfMarcaBorrador.
  ///
  /// In es, this message translates to:
  /// **'BORRADOR'**
  String get pdfMarcaBorrador;

  /// No description provided for @pdfActaBorradorAviso.
  ///
  /// In es, this message translates to:
  /// **'Borrador: aún no vale como acta. Falta que la firmen dos personas de la mesa.'**
  String get pdfActaBorradorAviso;

  /// No description provided for @pdfParticipacion.
  ///
  /// In es, this message translates to:
  /// **'Participación'**
  String get pdfParticipacion;

  /// No description provided for @pdfParticipacionDetalle.
  ///
  /// In es, this message translates to:
  /// **'{total, plural, =1{Ha participado 1 persona} other{Han participado {total} personas}}: {app} en la app y {papel} en persona.'**
  String pdfParticipacionDetalle(int total, int app, int papel);

  /// No description provided for @pdfQuorumAlcanzado.
  ///
  /// In es, this message translates to:
  /// **'Se ha llegado al quórum.'**
  String get pdfQuorumAlcanzado;

  /// No description provided for @pdfQuorumNoAlcanzado.
  ///
  /// In es, this message translates to:
  /// **'No se ha llegado al quórum.'**
  String get pdfQuorumNoAlcanzado;

  /// No description provided for @pdfResultado.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get pdfResultado;

  /// No description provided for @pdfEnLaApp.
  ///
  /// In es, this message translates to:
  /// **'En la app'**
  String get pdfEnLaApp;

  /// No description provided for @pdfEnPapel.
  ///
  /// In es, this message translates to:
  /// **'En papel'**
  String get pdfEnPapel;

  /// No description provided for @pdfTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get pdfTotal;

  /// No description provided for @pdfConteoFirmado.
  ///
  /// In es, this message translates to:
  /// **'{papeletas, plural, =1{Conteo en papel de 1 papeleta, firmado por {firmas}.} other{Conteo en papel de {papeletas} papeletas, firmado por {firmas}.}}'**
  String pdfConteoFirmado(int papeletas, String firmas);

  /// No description provided for @pdfObjeciones.
  ///
  /// In es, this message translates to:
  /// **'Objeciones'**
  String get pdfObjeciones;

  /// No description provided for @pdfRespuestaMesa.
  ///
  /// In es, this message translates to:
  /// **'Respuesta: {respuesta}'**
  String pdfRespuestaMesa(String respuesta);

  /// No description provided for @estadoViva.
  ///
  /// In es, this message translates to:
  /// **'Sin resolver'**
  String get estadoViva;

  /// No description provided for @pdfDebate.
  ///
  /// In es, this message translates to:
  /// **'Debate'**
  String get pdfDebate;

  /// No description provided for @pdfSinResumen.
  ///
  /// In es, this message translates to:
  /// **'La mesa no ha escrito un resumen del debate.'**
  String get pdfSinResumen;

  /// No description provided for @pdfFirmas.
  ///
  /// In es, this message translates to:
  /// **'Firmas de la mesa'**
  String get pdfFirmas;

  /// No description provided for @pdfFirmadaPor.
  ///
  /// In es, this message translates to:
  /// **'{nombre}, el {fecha}'**
  String pdfFirmadaPor(String nombre, String fecha);

  /// No description provided for @pdfFaltaFirma.
  ///
  /// In es, this message translates to:
  /// **'Falta esta firma'**
  String get pdfFaltaFirma;

  /// No description provided for @pdfGenerada.
  ///
  /// In es, this message translates to:
  /// **'Generada el {fecha} con Concejo.'**
  String pdfGenerada(String fecha);

  /// No description provided for @pdfCompromisoLinea.
  ///
  /// In es, this message translates to:
  /// **'{responsable}, para el {fecha}'**
  String pdfCompromisoLinea(String responsable, String fecha);

  /// No description provided for @seccionActa.
  ///
  /// In es, this message translates to:
  /// **'Acta'**
  String get seccionActa;

  /// No description provided for @actaNoLista.
  ///
  /// In es, this message translates to:
  /// **'El acta se firma cuando el asunto está decidido.'**
  String get actaNoLista;

  /// No description provided for @actaBorrador.
  ///
  /// In es, this message translates to:
  /// **'{firmadas, plural, =0{Borrador: sin firmas de la mesa} =1{Borrador: tiene 1 de las 2 firmas de la mesa} other{Borrador: tiene {firmadas} de las 2 firmas de la mesa}}'**
  String actaBorrador(int firmadas);

  /// No description provided for @actaDefinitiva.
  ///
  /// In es, this message translates to:
  /// **'Acta firmada por {primera} y {segunda}.'**
  String actaDefinitiva(String primera, String segunda);

  /// No description provided for @actaConFirmasAviso.
  ///
  /// In es, this message translates to:
  /// **'El acta ya tiene una firma: para corregir el resultado, retírala primero.'**
  String get actaConFirmasAviso;

  /// No description provided for @firmarActa.
  ///
  /// In es, this message translates to:
  /// **'Firmar el acta'**
  String get firmarActa;

  /// No description provided for @confirmarFirmarActa.
  ///
  /// In es, this message translates to:
  /// **'Al firmar, el resultado, los conteos y el resumen del debate quedan fijos. ¿Lo has revisado en el PDF?'**
  String get confirmarFirmarActa;

  /// No description provided for @firmar.
  ///
  /// In es, this message translates to:
  /// **'Firmar'**
  String get firmar;

  /// No description provided for @retirarFirma.
  ///
  /// In es, this message translates to:
  /// **'Retirar mi firma'**
  String get retirarFirma;

  /// No description provided for @descargarActa.
  ///
  /// In es, this message translates to:
  /// **'Descargar el acta'**
  String get descargarActa;
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
