import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'textos_app_ca.dart';
import 'textos_app_es.dart';
import 'textos_app_eu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of TextosApp
/// returned by `TextosApp.of(context)`.
///
/// Applications need to include `TextosApp.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generado/textos_app.dart';
///
/// return MaterialApp(
///   localizationsDelegates: TextosApp.localizationsDelegates,
///   supportedLocales: TextosApp.supportedLocales,
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
/// be consistent with the languages listed in the TextosApp.supportedLocales
/// property.
abstract class TextosApp {
  TextosApp(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static TextosApp of(BuildContext context) {
    return Localizations.of<TextosApp>(context, TextosApp)!;
  }

  static const LocalizationsDelegate<TextosApp> delegate = _TextosAppDelegate();

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

  /// Nombre del juego (provisional, biblia §10.1).
  ///
  /// In es, this message translates to:
  /// **'El Cuaderno'**
  String get tituloApp;

  /// Bajada de la pantalla de bienvenida (doc 13 §1.1). En S1 no se muestra todavía — se introducirá en el flujo de onboarding del Sprint 2.
  ///
  /// In es, this message translates to:
  /// **'Una herramienta para anotar lo que ves vivo cerca de ti.'**
  String get subtituloBienvenida;

  /// Saludo del cuaderno cuando el niño aún no ha puesto nombre.
  ///
  /// In es, this message translates to:
  /// **'Hola.'**
  String get saludoSinNombre;

  /// Saludo del cuaderno con el nombre del niño.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}.'**
  String saludoConNombre(String nombre);

  /// Pestaña 1 del bottom nav (sentence case sin mayúscula inicial — el botón es del oficio, no un título).
  ///
  /// In es, this message translates to:
  /// **'cuaderno'**
  String get navCuaderno;

  /// No description provided for @navMapa.
  ///
  /// In es, this message translates to:
  /// **'mapa'**
  String get navMapa;

  /// No description provided for @navMisterios.
  ///
  /// In es, this message translates to:
  /// **'misterios'**
  String get navMisterios;

  /// No description provided for @navTutor.
  ///
  /// In es, this message translates to:
  /// **'tutor'**
  String get navTutor;

  /// Cabecera de la sección que aloja la tarjeta del sit spot.
  ///
  /// In es, this message translates to:
  /// **'Tu sit spot'**
  String get seccionSitSpot;

  /// Cabecera de la sección de Misterios abiertos del niño.
  ///
  /// In es, this message translates to:
  /// **'Misterios abiertos'**
  String get seccionMisteriosAbiertos;

  /// Cabecera de la sección que muestra la observación más reciente.
  ///
  /// In es, this message translates to:
  /// **'Última página'**
  String get seccionUltimaPagina;

  /// Invitación discreta a configurar sit spot, sin urgencia (doc 13 §2.1).
  ///
  /// In es, this message translates to:
  /// **'Cuando estés en algún sitio al aire libre que te guste — un parque, un árbol, una esquina — puedes hacerlo tu sit spot. Toca aquí cuando estés.'**
  String get sitSpotInvitacion;

  /// Línea que muestra cuándo fue la última vez que el niño visitó el sit spot.
  ///
  /// In es, this message translates to:
  /// **'Última visita: {cuando}'**
  String sitSpotUltimaVisita(String cuando);

  /// Estado vacío de la sección 'última página' (doc 13 §11.10).
  ///
  /// In es, this message translates to:
  /// **'Aún no has anotado nada. Cuando lo hagas, aparecerá aquí.'**
  String get ultimaPaginaVacia;

  /// Estado vacío de la sección de Misterios.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes Misterios abiertos. El sistema te propondrá alguno pronto.'**
  String get misteriosVacio;

  /// Estado vacío de la pestaña Misterios cuando el catálogo abierto NO está vacío pero todos los Misterios quedan fuera del filtro fenológico/regional. Mensaje pedagógico que invita a volver al cambiar la estación (biblia §5.3).
  ///
  /// In es, this message translates to:
  /// **'Hoy no hay Misterios para tu lugar y esta estación. Vuelve a mirar al cambiar el tiempo.'**
  String get misteriosFueraDeContexto;

  /// Placeholder de las pestañas Mapa y Misterios en S1 — el bottom nav está, pero solo Cuaderno y Tutor llevan a algo.
  ///
  /// In es, this message translates to:
  /// **'Próximamente.'**
  String get navProximamente;

  /// Etiqueta del botón flotante del home que abre la pantalla de nueva observación. Verbo en infinitivo, sentence case (biblia §2.5 voz adulta amable, sin diminutivos).
  ///
  /// In es, this message translates to:
  /// **'anotar'**
  String get homeFabAnotar;

  /// Tooltip largo del botón flotante. Lo lee accesibilidad y aparece en pulsación larga; orienta al niño sobre qué hace el botón.
  ///
  /// In es, this message translates to:
  /// **'anotar lo que ves'**
  String get homeFabAnotarTooltip;

  /// Microcopia breve bajo el saludo del home cuando hay Misterios abiertos. Orienta al niño la primera vez sin gritar — voz adulta amable (biblia §2.5).
  ///
  /// In es, this message translates to:
  /// **'Estos son los Misterios que tu cuaderno tiene abiertos. Ábrelos para leerlos; cuando veas algo en tu sit spot que tenga que ver, anótalo.'**
  String get homeOrientacionConMisterios;

  /// Cabecera de la sección donde el niño ve las preguntas que él mismo ha formulado, paralela al catálogo de Misterios pero suya.
  ///
  /// In es, this message translates to:
  /// **'Tus preguntas'**
  String get seccionTusPreguntas;

  /// Cabecera del catálogo de Misterios curados (los que vienen del adulto), para distinguirlos de las preguntas del niño en la pestaña misterios.
  ///
  /// In es, this message translates to:
  /// **'Misterios del cuaderno'**
  String get seccionMisteriosDelCuaderno;

  /// Estado vacío de la sección 'Tus preguntas'. Voz adulta amable que conecta la formulación con el sit spot, sin urgencia.
  ///
  /// In es, this message translates to:
  /// **'Aún no has formulado ninguna pregunta. Cuando se te ocurra una mientras observas tu lugar, anótala aquí.'**
  String get tusPreguntasVacio;

  /// Etiqueta del botón que abre la pantalla de formular nueva pregunta del niño.
  ///
  /// In es, this message translates to:
  /// **'formular pregunta'**
  String get preguntaFabFormular;

  /// Título de la pantalla donde el niño escribe una pregunta nueva. No usa 'Nueva pregunta' porque la palabra 'nueva' subraya la app, no al niño — la pregunta es suya, no del cuaderno.
  ///
  /// In es, this message translates to:
  /// **'Tu pregunta'**
  String get preguntaFormularTitulo;

  /// Microcopia introductoria al formular una pregunta. Voz adulta amable, deja claro que el niño tiene autoridad sobre el formato. Biblia §2.4 (nunca humillar) + §2.5 (respeto por la edad).
  ///
  /// In es, this message translates to:
  /// **'Una pregunta tuya. La que llevas dándole vueltas, la que se te acaba de ocurrir, la que nadie te ha contado. Escríbela como te suene; no hace falta que esté bien hecha — sólo que sea la tuya.'**
  String get preguntaFormularIntro;

  /// Placeholder neutro del campo de pregunta. Sólo dos signos para señalar que va una pregunta — no impone formato ni ejemplo.
  ///
  /// In es, this message translates to:
  /// **'¿…?'**
  String get preguntaFormularPlaceholder;

  /// Botón de guardar al final del formulario.
  ///
  /// In es, this message translates to:
  /// **'Guardar mi pregunta'**
  String get preguntaFormularBotonGuardar;

  /// Botón discreto que abre una hoja con esqueletos opcionales si el niño está bloqueado. Por defecto el formulario es libre — esto es opt-in.
  ///
  /// In es, this message translates to:
  /// **'necesito ideas'**
  String get preguntaFormularBotonIdeas;

  /// Título de la hoja con esqueletos opcionales. Voz adulta amable que no presupone que el niño los necesita.
  ///
  /// In es, this message translates to:
  /// **'Si necesitas un punto de partida'**
  String get preguntaIdeasTitulo;

  /// Microcopia introductoria a la lista de esqueletos. Subraya que son opt-in.
  ///
  /// In es, this message translates to:
  /// **'No tienes que usar ninguno. Si te ayuda alguno, púlsalo y empieza desde ahí.'**
  String get preguntaIdeasIntro;

  /// Esqueleto 1 — pregunta sostenida con condición. Los puntos son del niño.
  ///
  /// In es, this message translates to:
  /// **'¿siempre … cuando …?'**
  String get preguntaIdea1;

  /// No description provided for @preguntaIdea2.
  ///
  /// In es, this message translates to:
  /// **'¿qué pasa cuando …?'**
  String get preguntaIdea2;

  /// No description provided for @preguntaIdea3.
  ///
  /// In es, this message translates to:
  /// **'¿se parece … a …?'**
  String get preguntaIdea3;

  /// No description provided for @preguntaIdea4.
  ///
  /// In es, this message translates to:
  /// **'¿cómo cambia … con el tiempo?'**
  String get preguntaIdea4;

  /// No description provided for @preguntaIdea5.
  ///
  /// In es, this message translates to:
  /// **'¿qué hace … cuando …?'**
  String get preguntaIdea5;

  /// Título de la página de detalle de una pregunta del niño. Coherente con el título del formulario — la palabra clave es 'tu'.
  ///
  /// In es, this message translates to:
  /// **'Tu pregunta'**
  String get preguntaPaginaTitulo;

  /// Línea bajo la pregunta con la fecha en que el niño la escribió.
  ///
  /// In es, this message translates to:
  /// **'Formulada el {fecha}'**
  String preguntaPaginaFormulada(String fecha);

  /// Estado vacío de la sección 'lo que ya has anotado' en la página de la pregunta. Igual de amable que el del Misterio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has anotado nada para tu pregunta. Vuelve al lugar y mira; cuando veas algo que tenga que ver, anótalo y ánclalo aquí.'**
  String get preguntaPaginaEvidenciaVacia;

  /// Cabecera del listado de observaciones ancladas a la pregunta. Misma palabra que la de Misterio para conservar el lenguaje del oficio.
  ///
  /// In es, this message translates to:
  /// **'Lo que ya has anotado'**
  String get preguntaPaginaCabeceraEvidencia;

  /// Opción del menú de la página de la pregunta para borrarla.
  ///
  /// In es, this message translates to:
  /// **'borrar esta pregunta'**
  String get preguntaPaginaBorrar;

  /// No description provided for @preguntaPaginaConfirmaBorrar.
  ///
  /// In es, this message translates to:
  /// **'Vas a borrar esta pregunta tuya. Las observaciones que tuvieras ancladas se conservan en el cuaderno. No se puede deshacer.'**
  String get preguntaPaginaConfirmaBorrar;

  /// Botón principal de la página de la pregunta abierta — abre PantallaObservacion con la pregunta preseleccionada.
  ///
  /// In es, this message translates to:
  /// **'anotar evidencia para esta pregunta'**
  String get preguntaPaginaBotonEvidencia;

  /// Botón secundario de la página de la pregunta cuando hay >=1 evidencia. Abre la pantalla de cierre amable. Si no hay evidencia, no se muestra (cerrar sin haber observado es prematuro).
  ///
  /// In es, this message translates to:
  /// **'ya tengo mi respuesta sobre esta pregunta'**
  String get preguntaPaginaBotonCerrar;

  /// Título de la pantalla donde el niño escribe su respuesta al cerrar la pregunta.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta'**
  String get preguntaCerrarTitulo;

  /// Microcopia de la pantalla de cierre. Voz adulta amable: nadie corrige, nadie nota. Mismo tono que el cierre de Misterio.
  ///
  /// In es, this message translates to:
  /// **'Cuenta con tus palabras lo que has aprendido. No hay respuesta correcta — esto no se corrige ni se nota; sólo se guarda en tu cuaderno.'**
  String get preguntaCerrarIntro;

  /// No description provided for @preguntaCerrarPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'tu respuesta'**
  String get preguntaCerrarPlaceholder;

  /// Botón de guardar de la pantalla de cierre amable.
  ///
  /// In es, this message translates to:
  /// **'Guardar mi respuesta'**
  String get preguntaCerrarBoton;

  /// Cabecera del bloque de respuesta cerrada que se muestra en la página de la pregunta cerrada.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta'**
  String get preguntaPaginaBloqueRespuesta;

  /// Línea bajo la respuesta con la fecha de cierre.
  ///
  /// In es, this message translates to:
  /// **'Cerrada el {fecha}'**
  String preguntaPaginaCerradaEl(String fecha);

  /// Botón discreto que abre el AlertDialog de confirmación de reapertura. Mismo patrón que reabrir Misterio.
  ///
  /// In es, this message translates to:
  /// **'reabrir esta pregunta'**
  String get preguntaPaginaReabrir;

  /// No description provided for @preguntaPaginaConfirmaReabrir.
  ///
  /// In es, this message translates to:
  /// **'Si la reabres, tu respuesta se borra y la pregunta vuelve a la lista de abiertas. Las anotaciones que ya tenías se conservan.'**
  String get preguntaPaginaConfirmaReabrir;

  /// Título de la pantalla de Nueva Observación.
  ///
  /// In es, this message translates to:
  /// **'nueva observación'**
  String get observacionTitulo;

  /// Cabecera fija con metadatos automáticos (doc 13 §3.2). En S1 solo hora — clima y lugar entrarán en sprints posteriores con la geolocalización.
  ///
  /// In es, this message translates to:
  /// **'Hoy · {hora}'**
  String observacionCabecera(String hora);

  /// No description provided for @observacionCajaFoto.
  ///
  /// In es, this message translates to:
  /// **'foto'**
  String get observacionCajaFoto;

  /// No description provided for @observacionCajaDibujo.
  ///
  /// In es, this message translates to:
  /// **'dibujo'**
  String get observacionCajaDibujo;

  /// Microcopia opcional cuando no hay foto ni dibujo todavía. Sentence case, voz adulta amable (doc 04 §2).
  ///
  /// In es, this message translates to:
  /// **'Si quieres, añade una foto o un dibujo.'**
  String get observacionCajaPlaceholder;

  /// Botón que abre la cámara nativa para capturar una foto y anclarla a la observación.
  ///
  /// In es, this message translates to:
  /// **'tomar foto'**
  String get observacionFotoTomar;

  /// Botón que abre la galería del dispositivo para elegir una foto ya hecha.
  ///
  /// In es, this message translates to:
  /// **'elegir foto'**
  String get observacionFotoElegir;

  /// Botón que retira la foto seleccionada antes de guardar la observación. No borra la foto del dispositivo si vino de la galería.
  ///
  /// In es, this message translates to:
  /// **'quitar foto'**
  String get observacionFotoQuitar;

  /// Botón que abre el lienzo espartano de dibujo (A4).
  ///
  /// In es, this message translates to:
  /// **'hacer dibujo'**
  String get observacionDibujoComenzar;

  /// Botón que retira el dibujo guardado antes de cerrar la observación.
  ///
  /// In es, this message translates to:
  /// **'quitar dibujo'**
  String get observacionDibujoQuitar;

  /// Etiqueta del campo obligatorio (doc 13 §3.2).
  ///
  /// In es, this message translates to:
  /// **'qué viste'**
  String get observacionEtiquetaQueViste;

  /// Placeholder del campo de descripción libre. Itálica (estilo se aplica en el widget).
  ///
  /// In es, this message translates to:
  /// **'describe lo que has visto, sin nombrarlo si no estás segura'**
  String get observacionPlaceholderQueViste;

  /// Etiqueta del campo opcional de identificación propuesta.
  ///
  /// In es, this message translates to:
  /// **'crees que es'**
  String get observacionEtiquetaCreesQueEs;

  /// Placeholder del campo opcional.
  ///
  /// In es, this message translates to:
  /// **'si quieres, propón un nombre'**
  String get observacionPlaceholderCreesQueEs;

  /// No description provided for @confianzaConsenso.
  ///
  /// In es, this message translates to:
  /// **'consenso'**
  String get confianzaConsenso;

  /// No description provided for @confianzaHipotesisActiva.
  ///
  /// In es, this message translates to:
  /// **'hipótesis activa'**
  String get confianzaHipotesisActiva;

  /// No description provided for @confianzaNoSegura.
  ///
  /// In es, this message translates to:
  /// **'no estoy segura'**
  String get confianzaNoSegura;

  /// No description provided for @confianzaConsensoTooltip.
  ///
  /// In es, this message translates to:
  /// **'lo has confirmado con una clave o con el Tutor'**
  String get confianzaConsensoTooltip;

  /// No description provided for @confianzaNoSeguraTooltip.
  ///
  /// In es, this message translates to:
  /// **'no pasa nada, anótalo así'**
  String get confianzaNoSeguraTooltip;

  /// Mensaje de validación amable bajo el botón Guardar (doc 13 §3.2). Sin rojo, sin icono de error, sin 'campo obligatorio'.
  ///
  /// In es, this message translates to:
  /// **'haz una nota antes de guardar'**
  String get observacionAvisoFalta;

  /// Botón principal de la pantalla de observación. Sentence case con mayúscula inicial porque es una acción explícita (criterio de UI: botones llevan inicial; cabeceras de sección no).
  ///
  /// In es, this message translates to:
  /// **'Guardar en el cuaderno'**
  String get observacionBotonGuardar;

  /// Frase canónica de presentación del Tutor (doc 04 §3.1, doc 13 §6.2). Idéntica siempre.
  ///
  /// In es, this message translates to:
  /// **'Soy el Tutor del Cuaderno. Pregúntame lo que necesites.'**
  String get tutorSaludoCanonico;

  /// No description provided for @tutorPlaceholderInput.
  ///
  /// In es, this message translates to:
  /// **'escribe tu pregunta'**
  String get tutorPlaceholderInput;

  /// No description provided for @tutorBotonEnviar.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get tutorBotonEnviar;

  /// Respuesta única del Tutor cuando no hay token (cuenta no vinculada). En S1 era el único estado; tras S4 cubre sólo el caso 'sin cuenta'.
  ///
  /// In es, this message translates to:
  /// **'El Tutor todavía no está conectado. Vuelve en unas semanas.'**
  String get tutorRespuestaCanned;

  /// Aviso que el Tutor muestra cuando hay token vinculado pero la llamada al backend falló por red, 500 o JSON malformado. Voz adulta amable: no le echa la culpa al niño ni le pide que reinicie, sólo nombra que ahora mismo no se puede.
  ///
  /// In es, this message translates to:
  /// **'Ahora mismo no llego al cuaderno. Espera un momento y vuelve a probar.'**
  String get tutorErrorRed;

  /// Título de la pantalla de Ajustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get ajustesTitulo;

  /// Título del AppBar de la pantalla del atlas personal del niño. Sentence case, voz adulta amable. "Atlas" funciona en castellano, eu y ca; "Tu" personaliza sin invadir.
  ///
  /// In es, this message translates to:
  /// **'Tu atlas'**
  String get atlasTitulo;

  /// Subtítulo bajo el AppBar de la pantalla del atlas. Declara la pedagogía de entrada para que el niño no lea el atlas como una colección de logros. Voz adulta amable, frases cortas en minúscula serif italic.
  ///
  /// In es, this message translates to:
  /// **'no es un trofeo. es lo que has visto.'**
  String get atlasSubtitulo;

  /// Cabecera de la sección "primeras veces" del atlas — listado cronológico inverso de identificaciones nuevas que han aparecido en el cuaderno por primera vez.
  ///
  /// In es, this message translates to:
  /// **'Tus primeras veces'**
  String get atlasSeccionPrimerasVeces;

  /// Cabecera de la sección agrupada del atlas — sumario por identificación con conteos.
  ///
  /// In es, this message translates to:
  /// **'Lo que has visto'**
  String get atlasSeccionLoQueHasVisto;

  /// Texto de la columna derecha de "Lo que has visto" cuando el conteo es exactamente 1. Voz adulta amable, sentence case.
  ///
  /// In es, this message translates to:
  /// **'1 vez'**
  String get atlasConteoSingular;

  /// Texto de la columna derecha de "Lo que has visto" cuando el conteo es 2 o más.
  ///
  /// In es, this message translates to:
  /// **'{conteo} veces'**
  String atlasConteoPlural(int conteo);

  /// Cabecera del estado vacío del atlas — el niño aún no ha escrito ningún "crees que es" en sus observaciones, o todavía no tiene observaciones. Voz adulta amable, sin presionar.
  ///
  /// In es, this message translates to:
  /// **'Tu atlas todavía está vacío.'**
  String get atlasVacioCabecera;

  /// Cuerpo del estado vacío del atlas. Explica con voz adulta amable que el atlas no se rellena haciendo cosas extras — se rellena por el oficio normal.
  ///
  /// In es, this message translates to:
  /// **'Cuando vayas anotando lo que crees que ves, esto se irá llenando solo. No hay prisa.'**
  String get atlasVacioCuerpo;

  /// Enlace discreto en la pestaña Cuaderno bajo "ver todas tus páginas" que abre el atlas. Voz adulta amable, minúscula.
  ///
  /// In es, this message translates to:
  /// **'ver tu atlas'**
  String get atlasEnlaceDesdeCuaderno;

  /// Cabecera de la sección de ecos temporales del home (entre Misterios y Última página). El cuaderno detecta observaciones de hace ~1 mes / 6 meses / 1 año (±3 días) y las trae como ritual del oficio del lugar (biblia §3.5: "si vuelves al mismo sitio, ves cómo cambia"). Sin presión: si no hay candidatas, la sección entera no aparece.
  ///
  /// In es, this message translates to:
  /// **'Hace un tiempo, por aquí'**
  String get seccionEcos;

  /// Cabecera de la fila de eco de hace 1 mes. Voz adulta amable, minúscula con puntos suspensivos como invitación a leer. Tres puntos Unicode (…), no tres puntos sueltos.
  ///
  /// In es, this message translates to:
  /// **'hace un mes, por estas fechas…'**
  String get ecoCabeceraUnMes;

  /// Cabecera de la fila de eco de hace ~6 meses. Cierra ciclo equinoccio↔equinoccio o solsticio↔solsticio (biblia §3.5).
  ///
  /// In es, this message translates to:
  /// **'hace seis meses, por estas fechas…'**
  String get ecoCabeceraSeisMeses;

  /// Cabecera de la fila de eco de hace ~1 año. Memoria completa del lugar — el aniversario de cuando empezaste a habitarlo.
  ///
  /// In es, this message translates to:
  /// **'hace un año, por estas fechas…'**
  String get ecoCabeceraUnAno;

  /// Cabecera del bloque "Tu mes en el sit spot" en la página del sit spot activo. Sans-serif gris ceniza, sentence case, voz adulta amable. Sólo se monta a partir de la segunda visita del mes en curso.
  ///
  /// In es, this message translates to:
  /// **'Este mes aquí'**
  String get paginaSitSpotResumenMesCabecera;

  /// Línea principal del bloque "Este mes aquí". Plurales nombrados (una/dos) hasta dos y dígito a partir de tres. ICU plural sólo admite =0/=1/=2 como literales; el resto va por la rama 'other'. Voz adulta amable, frase corta.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Has venido una vez este mes.} =2{Has venido dos veces este mes.} other{Has venido {count} veces este mes.}}'**
  String paginaSitSpotResumenMesVisitas(int count);

  /// Línea secundaria del bloque "Este mes aquí" con las fechas DD/MM de la primera y última visita del mes. Serif gris tenue, lectura calmada.
  ///
  /// In es, this message translates to:
  /// **'La primera fue el {primera}. La última, el {ultima}.'**
  String paginaSitSpotResumenMesPrimeraUltima(String primera, String ultima);

  /// Título del AppBar del modo lectura del cuaderno. Sentence case, voz adulta amable. La pantalla muestra una observación por página con tipografía serif grande — el oficio del niño tratado como un libro suyo, no como una lista.
  ///
  /// In es, this message translates to:
  /// **'Leer tus páginas'**
  String get lecturaTitulo;

  /// Tooltip del IconButton (ícono de libro) que abre el modo lectura desde el AppBar de "Todas tus páginas". Minúscula, voz adulta amable.
  ///
  /// In es, this message translates to:
  /// **'leer tus páginas'**
  String get lecturaTooltip;

  /// Indicador discreto al pie del modo lectura. Mantenemos formato simple (sin "página" ni iconografía) — el contexto ya es claro y la frase es periferia visual.
  ///
  /// In es, this message translates to:
  /// **'{pagina} de {total}'**
  String lecturaPaginaIndicador(int pagina, int total);

  /// Estado vacío del modo lectura — alguien que entra sin observaciones. Voz adulta amable, sin presión. Reusa el tono de los demás estados vacíos del cuaderno.
  ///
  /// In es, this message translates to:
  /// **'Aún no has anotado nada. Cuando lo hagas, podrás abrir tu cuaderno como un libro.'**
  String get lecturaVacioCuerpo;

  /// Etiqueta del switch en Ajustes que activa la pestaña Mapa. Sentence case, voz adulta amable. La palabra "provisional" — que apuntaba a la deuda técnica de B5 (MBTiles offline) — se retira: es información para el equipo de desarrollo, no para la persona adulta que decide. La microcopia de abajo ya cuenta lo que le toca saber (que sale a internet hasta que llegue la versión offline).
  ///
  /// In es, this message translates to:
  /// **'Activar el mapa'**
  String get ajustesMapaOnlineEtiqueta;

  /// Microcopia honesta del bloque del mapa en Ajustes (biblia §2.9 sin extracción + §2.8 offline-first). Explica al adulto qué implica encender el switch sin tecnicismos — no menciona "OpenStreetMap" ni "servidor de tiles" porque el adulto medio no necesita esos términos para decidir.
  ///
  /// In es, this message translates to:
  /// **'Si lo activas, el dispositivo se conectará a internet para mostrar la zona del mundo donde estés. La pestaña \"mapa\" sólo funciona con esto encendido. Más adelante el mapa podrá descargarse una vez y dejará de salir a internet.'**
  String get ajustesMapaOnlineCuerpo;

  /// Opción del menú overflow de PantallaDetalleObservacion, sólo visible cuando la observación tiene foto anclada. Encarna el principio del CLAUDE.md raíz §"Apps del operador": el cuaderno NO replica la guía de identificación dentro — si el niño necesita ayuda, comparte la foto con el adulto que tiene su app naturalista. Voz adulta amable, minúscula.
  ///
  /// In es, this message translates to:
  /// **'compartir foto a tu adulto'**
  String get detalleCompartirFotoOpcion;

  /// Texto que acompaña a la foto en el sheet de compartir del SO. Voz del niño preguntando al adulto. Frase corta, abierta, sin presión. La identificación final la da el adulto desde su app de naturaleza/fósiles, no el cuaderno.
  ///
  /// In es, this message translates to:
  /// **'Mira lo que he visto en mi cuaderno. ¿Sabes qué es?'**
  String get detalleCompartirFotoTextoAdjunto;

  /// Título del AppBar de la pantalla "comparar dos visitas" del sit spot. Sentence case, voz adulta amable. Encarna la mecánica del corazón pedagógico de la biblia §3.5: ver cómo cambia el lugar.
  ///
  /// In es, this message translates to:
  /// **'Comparar dos visitas'**
  String get compararVisitasTitulo;

  /// Etiqueta del botón secundario en PantallaPaginaSitSpot que abre la pantalla del comparador. Minúscula, voz adulta amable.
  ///
  /// In es, this message translates to:
  /// **'comparar dos visitas'**
  String get compararVisitasEnlace;

  /// Microcopia bajo el nombre del sit spot que enmarca la pedagogía sin imponerla. Frase corta, sin signos de puntuación abruptos, en minúscula serif italic.
  ///
  /// In es, this message translates to:
  /// **'elige dos momentos. mira qué cambia.'**
  String get compararVisitasIntro;

  /// Etiqueta sobre el dropdown de la columna izquierda. Default razonable: la observación más antigua del sit spot. "Momento" en lugar de "visita" para que también valga si la niña anotó dos cosas el mismo día (dos momentos del mismo día son dos momentos).
  ///
  /// In es, this message translates to:
  /// **'primer momento'**
  String get compararVisitasColumnaIzquierda;

  /// Etiqueta sobre el dropdown de la columna derecha. Default razonable: la observación más reciente del sit spot.
  ///
  /// In es, this message translates to:
  /// **'segundo momento'**
  String get compararVisitasColumnaDerecha;

  /// Cabecera del estado vacío cuando el sit spot tiene 0 o 1 observaciones. Voz adulta amable, sin reproche. Sentence case con punto final.
  ///
  /// In es, this message translates to:
  /// **'Necesitas dos visitas para comparar.'**
  String get compararVisitasInsuficientesCabecera;

  /// Cuerpo del estado vacío. Explica qué hace falta sin presionar — la biblia §2.7 prohíbe rachas y deberes.
  ///
  /// In es, this message translates to:
  /// **'Cuando vuelvas a tu sit spot otro día y anotes algo, podrás comparar lo que viste antes con lo que ves ahora.'**
  String get compararVisitasInsuficientesCuerpo;

  /// Etiqueta del bloque en Ajustes que abre la pantalla de imprimir plantilla. Voz adulta amable. Refuerza la promesa offline-first §2.8: el campo no tiene wifi.
  ///
  /// In es, this message translates to:
  /// **'Imprimir páginas en blanco para el campo'**
  String get imprimirPlantillaBloque;

  /// Descripción del bloque "Imprimir páginas en blanco" en Ajustes. Vende el oficio, no la herramienta.
  ///
  /// In es, this message translates to:
  /// **'Genera un PDF para llevar el cuaderno en papel a una salida. Sin pantallas, sin pilas.'**
  String get imprimirPlantillaBloqueDescripcion;

  /// Título del AppBar de la pantalla de imprimir plantilla. Sentence case, voz adulta amable.
  ///
  /// In es, this message translates to:
  /// **'Páginas para el campo'**
  String get imprimirPlantillaTitulo;

  /// Microcopia introductoria de la pantalla. Enmarca la pedagogía de salir sin aparato. Voz adulta amable.
  ///
  /// In es, this message translates to:
  /// **'A veces el campo se mira mejor sin pantalla. Aquí preparas tu cuaderno en papel para llevarlo en la mochila.'**
  String get imprimirPlantillaIntro;

  /// Explicación del contenido de cada página, sin tono escolar.
  ///
  /// In es, this message translates to:
  /// **'Cada página tiene espacio para la fecha, dónde estabas, qué viste, lo que crees que es y un recuadro grande para dibujar.'**
  String get imprimirPlantillaContenido;

  /// Cabecera del selector de cantidad de páginas. Sans-serif gris ceniza tamaño 12, como las cabeceras de sección del cuaderno.
  ///
  /// In es, this message translates to:
  /// **'Cuántas páginas'**
  String get imprimirPlantillaSelectorCabecera;

  /// Etiqueta de cada chip del selector. Singular/plural se asume plural ya que las opciones son 4/8/16.
  ///
  /// In es, this message translates to:
  /// **'{paginas} páginas'**
  String imprimirPlantillaOpcionPaginas(int paginas);

  /// Botón principal que dispara la generación del PDF + el lanzador del SO. "O compartir" porque el sistema operativo permite también guardar como PDF, mandar por correo, etc.
  ///
  /// In es, this message translates to:
  /// **'Imprimir o compartir'**
  String get imprimirPlantillaBoton;

  /// Microcopia final que cubre el caso del adulto sin impresora en casa. Voz amable, sin asumir.
  ///
  /// In es, this message translates to:
  /// **'Si no tienes impresora, también puedes guardar el PDF en el móvil y enseñárselo a quien sí la tenga.'**
  String get imprimirPlantillaNotaFinal;

  /// Microcopia serif gris ceniza tamaño 12 que aparece en PantallaDetalleObservacion cuando la observación es la primera del cuaderno con su "crees que es" normalizado. Sin emojis, sin animación: una nota seca y bonita. Voz adulta amable, frase única, en minúscula como las cabeceras del cuaderno.
  ///
  /// In es, this message translates to:
  /// **'primera vez que anotas algo así en el cuaderno.'**
  String get detalleObservacionPrimeraVez;

  /// Título del AppBar de la pantalla "Acerca de El Cuaderno". Voz adulta amable: ni "Acerca de" (frío) ni "Información" (corporativo). El título funciona para niño, adulto y maestra a la vez.
  ///
  /// In es, this message translates to:
  /// **'Cómo se usa este cuaderno'**
  String get acercaTitulo;

  /// Etiqueta del bloque en Ajustes que abre la pantalla. Idéntico al título de AppBar — el niño que lo pulsa sabe a qué entra.
  ///
  /// In es, this message translates to:
  /// **'Cómo se usa este cuaderno'**
  String get acercaBloque;

  /// Descripción del bloque "Cómo se usa este cuaderno" en Ajustes. Tres lectores explícitos para que el adulto sepa que también encontrará lo suyo.
  ///
  /// In es, this message translates to:
  /// **'Qué es, cómo anotar, cómo acompañar. Para ti, para tu adulto y para tu maestra.'**
  String get acercaBloqueDescripcion;

  /// Texto que muestra el idioma activo en Ajustes.
  ///
  /// In es, this message translates to:
  /// **'Idioma del cuaderno: {idioma}'**
  String ajustesIdiomaActual(String idioma);

  /// No description provided for @ajustesIdiomaCambiar.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get ajustesIdiomaCambiar;

  /// No description provided for @ajustesExportar.
  ///
  /// In es, this message translates to:
  /// **'Exportar mi cuaderno'**
  String get ajustesExportar;

  /// No description provided for @ajustesExportarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Recibe una copia legible de tus observaciones y Misterios. El cuaderno es tuyo.'**
  String get ajustesExportarDescripcion;

  /// Exporta el cuaderno como PDF para imprimir o compartir. La tipografía y la paleta del PDF son provisionales — la decisión final queda con la ilustradora botánica + WCAG (B4 + B9 del plan).
  ///
  /// In es, this message translates to:
  /// **'Exportar como PDF'**
  String get ajustesExportarPdf;

  /// No description provided for @ajustesExportarPdfDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Una copia para imprimir o llevar a un papel. El sistema te preguntará dónde guardarla.'**
  String get ajustesExportarPdfDescripcion;

  /// No description provided for @ajustesExportarDialogoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu cuaderno como texto'**
  String get ajustesExportarDialogoTitulo;

  /// No description provided for @ajustesExportarDialogoCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get ajustesExportarDialogoCerrar;

  /// No description provided for @ajustesVistaCuidador.
  ///
  /// In es, this message translates to:
  /// **'Vista del cuidador'**
  String get ajustesVistaCuidador;

  /// No description provided for @ajustesVistaCuidadorDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Una página discreta para una persona adulta que te acompaña.'**
  String get ajustesVistaCuidadorDescripcion;

  /// No description provided for @ajustesBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar mi cuaderno'**
  String get ajustesBorrar;

  /// No description provided for @ajustesBorrarDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Borrar todas tus observaciones, Misterios y sit spot. No se puede deshacer.'**
  String get ajustesBorrarDescripcion;

  /// No description provided for @ajustesBorrarDialogoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar todo?'**
  String get ajustesBorrarDialogoTitulo;

  /// Cuerpo del primer diálogo de borrado, con el reparto.
  ///
  /// In es, this message translates to:
  /// **'Si continúas, se borrarán {observaciones} observaciones, {misterios} Misterios y {sitSpots} sit spot. No se puede deshacer.'**
  String ajustesBorrarDialogoCuerpo(
      int observaciones, int misterios, int sitSpots);

  /// No description provided for @ajustesBorrarDialogoSeguir.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get ajustesBorrarDialogoSeguir;

  /// No description provided for @ajustesBorrarDialogoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get ajustesBorrarDialogoCancelar;

  /// No description provided for @ajustesBorrarConfirmacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Estás segura?'**
  String get ajustesBorrarConfirmacionTitulo;

  /// No description provided for @ajustesBorrarConfirmacionCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Escribe «borrar» abajo para confirmar.'**
  String get ajustesBorrarConfirmacionCuerpo;

  /// Palabra exacta que el niño debe escribir para confirmar el borrado. Equivalente i18n del 'DELETE' de muchas apps adultas.
  ///
  /// In es, this message translates to:
  /// **'borrar'**
  String get ajustesBorrarConfirmacionPalabra;

  /// No description provided for @ajustesBorrarConfirmacionPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'escribe la palabra'**
  String get ajustesBorrarConfirmacionPlaceholder;

  /// No description provided for @ajustesBorrarConfirmacionBoton.
  ///
  /// In es, this message translates to:
  /// **'Borrar todo'**
  String get ajustesBorrarConfirmacionBoton;

  /// No description provided for @ajustesBorradoCompleto.
  ///
  /// In es, this message translates to:
  /// **'Listo. Tu cuaderno está vacío.'**
  String get ajustesBorradoCompleto;

  /// Pregunta del segundo paso del primer arranque (tras elegir idioma). El nombre se persiste como nombre del perfil del niño.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamas?'**
  String get bienvenidaTitulo;

  /// No description provided for @bienvenidaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre se queda en este cuaderno. No sale al servidor a menos que tú decidas vincularlo más tarde.'**
  String get bienvenidaCuerpo;

  /// No description provided for @bienvenidaPlaceholderNombre.
  ///
  /// In es, this message translates to:
  /// **'tu nombre'**
  String get bienvenidaPlaceholderNombre;

  /// No description provided for @bienvenidaBotonContinuar.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get bienvenidaBotonContinuar;

  /// Bloque opt-in que sube las observaciones pendientes al servidor. Lo dispara el adulto/niño explícitamente; sin sync automático.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar mis observaciones'**
  String get ajustesSyncObsTitulo;

  /// No description provided for @ajustesSyncObsDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Sube las observaciones nuevas a tu cuenta del servidor para no perderlas si cambias de dispositivo.'**
  String get ajustesSyncObsDescripcion;

  /// No description provided for @ajustesSyncObsBoton.
  ///
  /// In es, this message translates to:
  /// **'Subir ahora'**
  String get ajustesSyncObsBoton;

  /// No description provided for @ajustesSyncObsEnVuelo.
  ///
  /// In es, this message translates to:
  /// **'Subiendo…'**
  String get ajustesSyncObsEnVuelo;

  /// No description provided for @ajustesSyncObsSinToken.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cuenta vinculada con el servidor. Cuando la haya, este botón subirá tus observaciones.'**
  String get ajustesSyncObsSinToken;

  /// No description provided for @ajustesSyncObsNadaPendiente.
  ///
  /// In es, this message translates to:
  /// **'No hay observaciones pendientes — todo subido.'**
  String get ajustesSyncObsNadaPendiente;

  /// No description provided for @ajustesSyncObsTodasEnviadas.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se ha subido una observación.} other{Se han subido {count} observaciones.}}'**
  String ajustesSyncObsTodasEnviadas(int count);

  /// No description provided for @ajustesSyncObsParcial.
  ///
  /// In es, this message translates to:
  /// **'Subidas {enviadas}, quedan {pendientes} para el siguiente intento.'**
  String ajustesSyncObsParcial(int enviadas, int pendientes);

  /// No description provided for @ajustesSyncObsRechazadas.
  ///
  /// In es, this message translates to:
  /// **'Subidas {enviadas}, el servidor ha rechazado {rechazadas}. Vuelve a abrirlas para revisarlas.'**
  String ajustesSyncObsRechazadas(int enviadas, int rechazadas);

  /// Bloque visible siempre en Ajustes. Punto de entrada para vincular la cuenta del adulto contra el backend (POST /login). El registro NO se hace in-app — el adulto crea la cuenta primero por web (memoria project_el_cuaderno_decisiones_humanas_pendientes ítem 5).
  ///
  /// In es, this message translates to:
  /// **'Cuenta del adulto'**
  String get ajustesCuentaTitulo;

  /// No description provided for @ajustesCuentaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Si tienes una cuenta de Nuevo Ser, puedes vincularla aquí. Sirve para subir tus observaciones, recibir el resumen escrito del cuidador y conectar el Tutor real.'**
  String get ajustesCuentaDescripcion;

  /// No description provided for @ajustesCuentaPlaceholderEmail.
  ///
  /// In es, this message translates to:
  /// **'correo del adulto'**
  String get ajustesCuentaPlaceholderEmail;

  /// No description provided for @ajustesCuentaPlaceholderPassword.
  ///
  /// In es, this message translates to:
  /// **'contraseña'**
  String get ajustesCuentaPlaceholderPassword;

  /// No description provided for @ajustesCuentaBotonEntrar.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get ajustesCuentaBotonEntrar;

  /// No description provided for @ajustesCuentaEntrando.
  ///
  /// In es, this message translates to:
  /// **'Entrando…'**
  String get ajustesCuentaEntrando;

  /// No description provided for @ajustesCuentaSesionIniciada.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada como {email}.'**
  String ajustesCuentaSesionIniciada(String email);

  /// No description provided for @ajustesCuentaSesionIniciadaSinEmail.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada.'**
  String get ajustesCuentaSesionIniciadaSinEmail;

  /// No description provided for @ajustesCuentaCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get ajustesCuentaCerrarSesion;

  /// No description provided for @ajustesCuentaErrorCredenciales.
  ///
  /// In es, this message translates to:
  /// **'El correo o la contraseña no coinciden con ninguna cuenta.'**
  String get ajustesCuentaErrorCredenciales;

  /// No description provided for @ajustesCuentaErrorSinPerfil.
  ///
  /// In es, this message translates to:
  /// **'La cuenta del adulto no tiene ningún niño asociado todavía.'**
  String get ajustesCuentaErrorSinPerfil;

  /// No description provided for @ajustesCuentaErrorRed.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido conectar con el servidor. Inténtalo en un momento.'**
  String get ajustesCuentaErrorRed;

  /// No description provided for @ajustesCuentaErrorVacio.
  ///
  /// In es, this message translates to:
  /// **'Escribe el correo y la contraseña antes de continuar.'**
  String get ajustesCuentaErrorVacio;

  /// Bloque visible sólo en builds de debug. Permite pegar un JWT del backend para probar el Tutor real end-to-end sin pantalla de login.
  ///
  /// In es, this message translates to:
  /// **'Tutor (debug)'**
  String get ajustesTutorDebugTitulo;

  /// No description provided for @ajustesTutorDebugDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Pega aquí un token del backend para activar el Tutor real. Visible sólo en debug.'**
  String get ajustesTutorDebugDescripcion;

  /// No description provided for @ajustesTutorDebugPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'JWT del backend'**
  String get ajustesTutorDebugPlaceholder;

  /// No description provided for @ajustesTutorDebugBotonGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar token'**
  String get ajustesTutorDebugBotonGuardar;

  /// No description provided for @ajustesTutorDebugBotonBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar token'**
  String get ajustesTutorDebugBotonBorrar;

  /// No description provided for @ajustesTutorDebugGuardado.
  ///
  /// In es, this message translates to:
  /// **'Token guardado. Vuelve al Tutor para probarlo.'**
  String get ajustesTutorDebugGuardado;

  /// No description provided for @ajustesTutorDebugBorrado.
  ///
  /// In es, this message translates to:
  /// **'Token borrado. El Tutor vuelve a la respuesta canónica.'**
  String get ajustesTutorDebugBorrado;

  /// Título de la pantalla del cuidador.
  ///
  /// In es, this message translates to:
  /// **'Página del cuidador'**
  String get cuidadorTitulo;

  /// Microcopia que aclara la frontera de privacidad para el adulto que abra esta pantalla con el niño (doc 15 §1).
  ///
  /// In es, this message translates to:
  /// **'Esta es la única vista que comparte el juego con quien te acompaña. No verá tus observaciones ni lo que escribes — solo este resumen y una pregunta para hablar.'**
  String get cuidadorAviso;

  /// No description provided for @cuidadorSemanaActual.
  ///
  /// In es, this message translates to:
  /// **'Semana {isoWeek}'**
  String cuidadorSemanaActual(String isoWeek);

  /// No description provided for @cuidadorPreguntaCabecera.
  ///
  /// In es, this message translates to:
  /// **'Una pregunta para la cena'**
  String get cuidadorPreguntaCabecera;

  /// No description provided for @cuidadorMetricasCabecera.
  ///
  /// In es, this message translates to:
  /// **'Esta semana'**
  String get cuidadorMetricasCabecera;

  /// No description provided for @cuidadorMetricaObservaciones.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin observaciones} =1{Una observación} other{{count} observaciones}}'**
  String cuidadorMetricaObservaciones(int count);

  /// No description provided for @cuidadorMetricaMisterios.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin Misterios anclados} =1{Un Misterio} other{{count} Misterios}}'**
  String cuidadorMetricaMisterios(int count);

  /// No description provided for @cuidadorMetricaSitSpot.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin visitas al sit spot} =1{Una visita al sit spot} other{{count} visitas al sit spot}}'**
  String cuidadorMetricaSitSpot(int count);

  /// Botón opt-in que sube el agregado semanal al backend para que el LLM server-side genere el resumen y la pregunta para la cena. Sin push: lo dispara el adulto explícitamente cuando está con el niño.
  ///
  /// In es, this message translates to:
  /// **'Compartir resumen con el adulto'**
  String get cuidadorSincronizarBoton;

  /// No description provided for @cuidadorSincronizarEnVuelo.
  ///
  /// In es, this message translates to:
  /// **'Pidiéndolo…'**
  String get cuidadorSincronizarEnVuelo;

  /// No description provided for @cuidadorSincronizarSinToken.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay cuenta vinculada con el servidor. Cuando la haya, este botón pedirá un resumen escrito.'**
  String get cuidadorSincronizarSinToken;

  /// No description provided for @cuidadorSincronizarErrorRed.
  ///
  /// In es, this message translates to:
  /// **'Hoy no se ha podido conectar. Puedes volver a intentarlo más tarde.'**
  String get cuidadorSincronizarErrorRed;

  /// No description provided for @cuidadorSincronizarSinResumen.
  ///
  /// In es, this message translates to:
  /// **'El servidor no ha podido generar un resumen esta vez. La pregunta de abajo sigue valiendo.'**
  String get cuidadorSincronizarSinResumen;

  /// Cabecera del párrafo cualitativo que el LLM server-side genera. Solo se muestra si el sync trae un texto no vacío.
  ///
  /// In es, this message translates to:
  /// **'Esta semana, en una frase'**
  String get cuidadorResumenCabecera;

  /// No description provided for @crearSitSpotPermisoDenegadoPermanente.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido pedir permiso. Si quieres anclar la posición, cámbialo en los ajustes del teléfono.'**
  String get crearSitSpotPermisoDenegadoPermanente;

  /// No description provided for @crearSitSpotSinPermisoUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Sin permiso de ubicación. Puedes seguir sin él.'**
  String get crearSitSpotSinPermisoUbicacion;

  /// No description provided for @crearSitSpotErrorLocalizar.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido localizar la posición. Puedes seguir sin ella.'**
  String get crearSitSpotErrorLocalizar;

  /// No description provided for @crearSitSpotPrePermisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Anclar la posición a tu sit spot'**
  String get crearSitSpotPrePermisoTitulo;

  /// No description provided for @crearSitSpotPrePermisoMensaje.
  ///
  /// In es, this message translates to:
  /// **'La posición se queda en este cuaderno y no sale a internet. No la ve el adulto. Es opcional — el sit spot funciona sin ella.'**
  String get crearSitSpotPrePermisoMensaje;

  /// No description provided for @crearSitSpotPrePermisoCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get crearSitSpotPrePermisoCancelar;

  /// No description provided for @crearSitSpotPrePermisoAnclar.
  ///
  /// In es, this message translates to:
  /// **'anclar'**
  String get crearSitSpotPrePermisoAnclar;

  /// No description provided for @sitSpotsJubiladosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sit spots de antes'**
  String get sitSpotsJubiladosTitulo;

  /// No description provided for @misterioPaginaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Misterio'**
  String get misterioPaginaTitulo;

  /// No description provided for @misterioBotonEvidencia.
  ///
  /// In es, this message translates to:
  /// **'anotar evidencia para este misterio'**
  String get misterioBotonEvidencia;

  /// No description provided for @misterioBotonCerrar.
  ///
  /// In es, this message translates to:
  /// **'ya tengo mi respuesta sobre este Misterio'**
  String get misterioBotonCerrar;

  /// No description provided for @misterioCabeceraEvidencia.
  ///
  /// In es, this message translates to:
  /// **'Lo que ya has anotado'**
  String get misterioCabeceraEvidencia;

  /// No description provided for @misterioPaginaEvidenciaVacia.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has anotado nada para este misterio. Cuando lo hagas, aparecerá aquí.'**
  String get misterioPaginaEvidenciaVacia;

  /// No description provided for @misterioBloqueRespuesta.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta'**
  String get misterioBloqueRespuesta;

  /// No description provided for @misterioCerradoEl.
  ///
  /// In es, this message translates to:
  /// **'Cerrado el {fecha}'**
  String misterioCerradoEl(String fecha);

  /// No description provided for @misterioReabrir.
  ///
  /// In es, this message translates to:
  /// **'reabrir este Misterio'**
  String get misterioReabrir;

  /// No description provided for @misterioReabrirTitulo.
  ///
  /// In es, this message translates to:
  /// **'Reabrir este Misterio'**
  String get misterioReabrirTitulo;

  /// No description provided for @misterioReabrirMensaje.
  ///
  /// In es, this message translates to:
  /// **'Si lo reabres, tu respuesta se borra y el Misterio vuelve a la lista de abiertos. Las anotaciones que ya tenías se conservan.'**
  String get misterioReabrirMensaje;

  /// No description provided for @misterioReabrirCancelar.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get misterioReabrirCancelar;

  /// No description provided for @misterioReabrirConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Reabrir'**
  String get misterioReabrirConfirmar;

  /// No description provided for @misterioCerrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu respuesta'**
  String get misterioCerrarTitulo;

  /// No description provided for @misterioCerrarCabeceraMisterio.
  ///
  /// In es, this message translates to:
  /// **'El Misterio'**
  String get misterioCerrarCabeceraMisterio;

  /// No description provided for @misterioCerrarIntro.
  ///
  /// In es, this message translates to:
  /// **'Cuenta con tus palabras lo que has aprendido sobre este Misterio. No hay respuesta correcta — esto no se corrige ni se nota; sólo se guarda en tu cuaderno.'**
  String get misterioCerrarIntro;

  /// No description provided for @misterioCerrarPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Lo que he aprendido sobre este Misterio...'**
  String get misterioCerrarPlaceholder;

  /// No description provided for @misterioCerrarBotonGuardar.
  ///
  /// In es, this message translates to:
  /// **'guardar mi respuesta'**
  String get misterioCerrarBotonGuardar;

  /// No description provided for @misterioCerrarBotonGuardando.
  ///
  /// In es, this message translates to:
  /// **'guardando...'**
  String get misterioCerrarBotonGuardando;

  /// No description provided for @misterioCerrarErrorGuardar.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido guardar la respuesta. Vuelve a probar.'**
  String get misterioCerrarErrorGuardar;

  /// No description provided for @observacionPrePermisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Anclar la posición a esta página'**
  String get observacionPrePermisoTitulo;

  /// No description provided for @observacionPrePermisoMensaje.
  ///
  /// In es, this message translates to:
  /// **'La posición se queda en este cuaderno y no sale a internet. No la ve el adulto. Es opcional — puedes guardar la página sin ella.'**
  String get observacionPrePermisoMensaje;

  /// No description provided for @observacionPrePermisoCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get observacionPrePermisoCancelar;

  /// No description provided for @observacionPrePermisoAnclar.
  ///
  /// In es, this message translates to:
  /// **'anclar'**
  String get observacionPrePermisoAnclar;

  /// No description provided for @detalleObservacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Página del cuaderno'**
  String get detalleObservacionTitulo;

  /// No description provided for @detalleObservacionTooltipOpciones.
  ///
  /// In es, this message translates to:
  /// **'opciones de la página'**
  String get detalleObservacionTooltipOpciones;

  /// No description provided for @detalleObservacionMenuEditar.
  ///
  /// In es, this message translates to:
  /// **'editar este registro'**
  String get detalleObservacionMenuEditar;

  /// No description provided for @detalleObservacionMenuCompartirPdf.
  ///
  /// In es, this message translates to:
  /// **'compartir esta página como PDF'**
  String get detalleObservacionMenuCompartirPdf;

  /// No description provided for @detalleObservacionMenuBorrar.
  ///
  /// In es, this message translates to:
  /// **'borrar este registro'**
  String get detalleObservacionMenuBorrar;

  /// No description provided for @detalleObservacionBorrarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Borrar este registro'**
  String get detalleObservacionBorrarTitulo;

  /// No description provided for @detalleObservacionBorrarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Vas a borrar esta página del cuaderno. La foto y el dibujo, si los tenía, también se borrarán. No se puede deshacer.'**
  String get detalleObservacionBorrarMensaje;

  /// No description provided for @detalleObservacionBorrarCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get detalleObservacionBorrarCancelar;

  /// No description provided for @detalleObservacionBorrarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'borrar'**
  String get detalleObservacionBorrarConfirmar;

  /// No description provided for @listaObservacionesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Todas tus páginas'**
  String get listaObservacionesTitulo;

  /// No description provided for @listaObservacionesPlaceholderBusqueda.
  ///
  /// In es, this message translates to:
  /// **'busca por algo que recuerdes'**
  String get listaObservacionesPlaceholderBusqueda;

  /// No description provided for @listaObservacionesLimpiarBusqueda.
  ///
  /// In es, this message translates to:
  /// **'limpiar búsqueda'**
  String get listaObservacionesLimpiarBusqueda;

  /// No description provided for @listaObservacionesBusquedaSinResultados.
  ///
  /// In es, this message translates to:
  /// **'Ninguna página guarda eso. Prueba con otra palabra.'**
  String get listaObservacionesBusquedaSinResultados;

  /// No description provided for @sitSpotJubilarTitulo.
  ///
  /// In es, this message translates to:
  /// **'Jubilar este sit spot'**
  String get sitSpotJubilarTitulo;

  /// No description provided for @sitSpotJubilarMensaje.
  ///
  /// In es, this message translates to:
  /// **'Vas a jubilar \"{nombre}\". La página seguirá guardada en el cuaderno. No podrás añadir más observaciones a este sit spot, pero sí crear otro nuevo cuando quieras.'**
  String sitSpotJubilarMensaje(String nombre);

  /// No description provided for @sitSpotJubilarCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get sitSpotJubilarCancelar;

  /// No description provided for @sitSpotJubilarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'jubilar'**
  String get sitSpotJubilarConfirmar;

  /// No description provided for @sitSpotExplicacionCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get sitSpotExplicacionCerrar;

  /// No description provided for @preguntaReabrirCancelar.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get preguntaReabrirCancelar;

  /// No description provided for @preguntaReabrirConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Reabrir'**
  String get preguntaReabrirConfirmar;

  /// No description provided for @preguntaBorrarCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get preguntaBorrarCancelar;

  /// No description provided for @preguntaBorrarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'borrar'**
  String get preguntaBorrarConfirmar;

  /// No description provided for @loginProfesorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Acceso del profesor'**
  String get loginProfesorTitulo;

  /// No description provided for @loginProfesorIntro.
  ///
  /// In es, this message translates to:
  /// **'Esta pantalla es para el adulto que acompaña a la clase. No se enseña al niño. La cuenta de profesor se crea desde la web; aquí solo se vincula.'**
  String get loginProfesorIntro;

  /// No description provided for @loginProfesorPlaceholderEmail.
  ///
  /// In es, this message translates to:
  /// **'correo del profesor'**
  String get loginProfesorPlaceholderEmail;

  /// No description provided for @loginProfesorPlaceholderPassword.
  ///
  /// In es, this message translates to:
  /// **'contraseña'**
  String get loginProfesorPlaceholderPassword;

  /// No description provided for @loginProfesorBotonEntrar.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginProfesorBotonEntrar;

  /// No description provided for @loginProfesorEntrando.
  ///
  /// In es, this message translates to:
  /// **'Entrando…'**
  String get loginProfesorEntrando;

  /// No description provided for @loginProfesorErrorVacio.
  ///
  /// In es, this message translates to:
  /// **'Escribe el correo y la contraseña antes de continuar.'**
  String get loginProfesorErrorVacio;

  /// No description provided for @loginProfesorErrorCredenciales.
  ///
  /// In es, this message translates to:
  /// **'El correo o la contraseña no coinciden con ninguna cuenta de profesor.'**
  String get loginProfesorErrorCredenciales;

  /// No description provided for @loginProfesorErrorSinRol.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta no tiene perfil de profesor. Si eres cuidador, busca ese acceso aparte.'**
  String get loginProfesorErrorSinRol;

  /// No description provided for @loginProfesorErrorRolInvalido.
  ///
  /// In es, this message translates to:
  /// **'El servidor no aceptó la petición. Avisa al equipo.'**
  String get loginProfesorErrorRolInvalido;

  /// No description provided for @loginProfesorErrorRed.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido conectar con el servidor. Inténtalo en un momento.'**
  String get loginProfesorErrorRed;

  /// No description provided for @aulaProfesorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Aula'**
  String get aulaProfesorTitulo;

  /// No description provided for @aulaProfesorTooltipCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'cerrar sesión'**
  String get aulaProfesorTooltipCerrarSesion;

  /// No description provided for @aulaProfesorCrearTitulo.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primera aula'**
  String get aulaProfesorCrearTitulo;

  /// No description provided for @aulaProfesorCrearIntro.
  ///
  /// In es, this message translates to:
  /// **'El servidor te dará un código que repartes a la clase. Cada niño se une desde su cuaderno con ese código.'**
  String get aulaProfesorCrearIntro;

  /// No description provided for @aulaProfesorPlaceholderNombre.
  ///
  /// In es, this message translates to:
  /// **'nombre del aula'**
  String get aulaProfesorPlaceholderNombre;

  /// No description provided for @aulaProfesorHintNombre.
  ///
  /// In es, this message translates to:
  /// **'p. ej., 6º A · curso 2026/27'**
  String get aulaProfesorHintNombre;

  /// No description provided for @aulaProfesorJuegosCabecera.
  ///
  /// In es, this message translates to:
  /// **'Juegos del aula'**
  String get aulaProfesorJuegosCabecera;

  /// No description provided for @aulaProfesorBotonCrear.
  ///
  /// In es, this message translates to:
  /// **'Crear aula'**
  String get aulaProfesorBotonCrear;

  /// No description provided for @aulaProfesorCreando.
  ///
  /// In es, this message translates to:
  /// **'Creando…'**
  String get aulaProfesorCreando;

  /// No description provided for @aulaProfesorErrorVacio.
  ///
  /// In es, this message translates to:
  /// **'Pon un nombre al aula y elige al menos un juego.'**
  String get aulaProfesorErrorVacio;

  /// No description provided for @aulaProfesorErrorSesionCaducadaCrear.
  ///
  /// In es, this message translates to:
  /// **'La sesión ha caducado. Vuelve a iniciar sesión.'**
  String get aulaProfesorErrorSesionCaducadaCrear;

  /// No description provided for @aulaProfesorErrorDatosInvalidos.
  ///
  /// In es, this message translates to:
  /// **'Algún dato del aula no es válido. Revisa el nombre y los juegos seleccionados.'**
  String get aulaProfesorErrorDatosInvalidos;

  /// No description provided for @aulaProfesorErrorCodigoUnico.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar un código único para el aula. Inténtalo en un momento.'**
  String get aulaProfesorErrorCodigoUnico;

  /// No description provided for @aulaProfesorErrorGenerico.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido crear el aula (HTTP {codigo}).'**
  String aulaProfesorErrorGenerico(int codigo);

  /// No description provided for @aulaProfesorMensajeKMinimo.
  ///
  /// In es, this message translates to:
  /// **'El aula necesita al menos cinco niños con datos esta semana para que se vean los agregados. Eso protege la privacidad de la clase. Vuelve cuando haya más actividad.'**
  String get aulaProfesorMensajeKMinimo;

  /// No description provided for @aulaProfesorErrorSesionCaducadaCargar.
  ///
  /// In es, this message translates to:
  /// **'La sesión ha caducado. Cierra sesión y vuelve a entrar.'**
  String get aulaProfesorErrorSesionCaducadaCargar;

  /// No description provided for @aulaProfesorErrorCargarAgregados.
  ///
  /// In es, this message translates to:
  /// **'No se han podido cargar los agregados ({error}).'**
  String aulaProfesorErrorCargarAgregados(String error);

  /// No description provided for @aulaProfesorCodigoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Código del aula: {code}'**
  String aulaProfesorCodigoEtiqueta(String code);

  /// No description provided for @aulaProfesorSemanaResumen.
  ///
  /// In es, this message translates to:
  /// **'Semana {iso} · {reporting} de {total} con datos'**
  String aulaProfesorSemanaResumen(String iso, int reporting, int total);

  /// No description provided for @preguntaCenaCuadernoEnReposo.
  ///
  /// In es, this message translates to:
  /// **'Esta semana el cuaderno descansó. ¿Hay algo del lugar que os apetezca volver a mirar despacio?'**
  String get preguntaCenaCuadernoEnReposo;

  /// No description provided for @preguntaCenaObservacionesSinAnclajes.
  ///
  /// In es, this message translates to:
  /// **'¿Qué cosa pequeña ha aparecido esta semana en el cuaderno que no estaba antes?'**
  String get preguntaCenaObservacionesSinAnclajes;

  /// No description provided for @preguntaCenaRegresoAlSitSpot.
  ///
  /// In es, this message translates to:
  /// **'Esta semana ha vuelto al lugar de regreso. ¿Qué le ha sonado distinto allí?'**
  String get preguntaCenaRegresoAlSitSpot;

  /// No description provided for @preguntaCenaUnaPreguntaActiva.
  ///
  /// In es, this message translates to:
  /// **'Esta semana ha quedado dándole vueltas a una pregunta. ¿Cuál cuenta hoy?'**
  String get preguntaCenaUnaPreguntaActiva;

  /// No description provided for @preguntaCenaVariasPreguntasActivas.
  ///
  /// In es, this message translates to:
  /// **'Esta semana ha tenido varias preguntas a la vez. ¿Cuál de todas le tiene más enganchada ahora mismo?'**
  String get preguntaCenaVariasPreguntasActivas;

  /// No description provided for @configuracionInicialEnlacePolitica.
  ///
  /// In es, this message translates to:
  /// **'lee cómo se cuida tu cuaderno'**
  String get configuracionInicialEnlacePolitica;

  /// No description provided for @configuracionInicialPoliticaTitulo.
  ///
  /// In es, this message translates to:
  /// **'cómo se cuida tu cuaderno'**
  String get configuracionInicialPoliticaTitulo;

  /// No description provided for @crearSitSpotTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tu sit spot'**
  String get crearSitSpotTitulo;

  /// No description provided for @crearSitSpotQuitarPosicion.
  ///
  /// In es, this message translates to:
  /// **'quitar posición'**
  String get crearSitSpotQuitarPosicion;

  /// No description provided for @paginaSitSpotBotonAnotar.
  ///
  /// In es, this message translates to:
  /// **'anotar observación aquí'**
  String get paginaSitSpotBotonAnotar;

  /// No description provided for @lienzoDibujoBotonGuardar.
  ///
  /// In es, this message translates to:
  /// **'guardar dibujo'**
  String get lienzoDibujoBotonGuardar;

  /// No description provided for @tarjetaSitSpotQueEs.
  ///
  /// In es, this message translates to:
  /// **'qué es un sit spot'**
  String get tarjetaSitSpotQueEs;

  /// No description provided for @tarjetaSitSpotJubilarOpcion.
  ///
  /// In es, this message translates to:
  /// **'jubilar este sit spot'**
  String get tarjetaSitSpotJubilarOpcion;

  /// No description provided for @editarObservacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'editar página'**
  String get editarObservacionTitulo;

  /// No description provided for @editarObservacionBotonGuardar.
  ///
  /// In es, this message translates to:
  /// **'guardar cambios'**
  String get editarObservacionBotonGuardar;

  /// No description provided for @chipSugerenciaMisterioNo.
  ///
  /// In es, this message translates to:
  /// **'no'**
  String get chipSugerenciaMisterioNo;

  /// No description provided for @chipSugerenciaMisterioAnclar.
  ///
  /// In es, this message translates to:
  /// **'anclar'**
  String get chipSugerenciaMisterioAnclar;

  /// No description provided for @homeBotonVerTodasPaginas.
  ///
  /// In es, this message translates to:
  /// **'ver todas tus páginas'**
  String get homeBotonVerTodasPaginas;

  /// No description provided for @mapaBotonAbrirAjustes.
  ///
  /// In es, this message translates to:
  /// **'abrir Ajustes'**
  String get mapaBotonAbrirAjustes;

  /// No description provided for @mapaBotonEncender.
  ///
  /// In es, this message translates to:
  /// **'encender el mapa'**
  String get mapaBotonEncender;

  /// No description provided for @mapaConfirmarEncenderEncender.
  ///
  /// In es, this message translates to:
  /// **'encender'**
  String get mapaConfirmarEncenderEncender;

  /// No description provided for @mapaConfirmarEncenderCancelar.
  ///
  /// In es, this message translates to:
  /// **'cancelar'**
  String get mapaConfirmarEncenderCancelar;

  /// No description provided for @mapaBotonConfigurarSitSpot.
  ///
  /// In es, this message translates to:
  /// **'configurar sit spot'**
  String get mapaBotonConfigurarSitSpot;

  /// No description provided for @observacionQuitarPosicion.
  ///
  /// In es, this message translates to:
  /// **'quitar posición'**
  String get observacionQuitarPosicion;

  /// No description provided for @sitSpotsJubiladosVacio.
  ///
  /// In es, this message translates to:
  /// **'Aquí aparecerán los sit spots que jubiles. Sus páginas seguirán guardadas con sus observaciones.'**
  String get sitSpotsJubiladosVacio;

  /// No description provided for @sitSpotJubiladoPeriodoCreado.
  ///
  /// In es, this message translates to:
  /// **'Creado el {desde}.'**
  String sitSpotJubiladoPeriodoCreado(String desde);

  /// No description provided for @sitSpotJubiladoPeriodoActivo.
  ///
  /// In es, this message translates to:
  /// **'Estuvo activo del {desde} al {hasta}.'**
  String sitSpotJubiladoPeriodoActivo(String desde, String hasta);

  /// No description provided for @sitSpotJubiladoSinObservaciones.
  ///
  /// In es, this message translates to:
  /// **'Sin observaciones guardadas.'**
  String get sitSpotJubiladoSinObservaciones;

  /// No description provided for @sitSpotJubiladoUnaObservacion.
  ///
  /// In es, this message translates to:
  /// **'1 observación guardada'**
  String get sitSpotJubiladoUnaObservacion;

  /// No description provided for @sitSpotJubiladoVariasObservaciones.
  ///
  /// In es, this message translates to:
  /// **'{cuenta} observaciones guardadas'**
  String sitSpotJubiladoVariasObservaciones(int cuenta);

  /// No description provided for @sitSpotJubiladoPaginaVacia.
  ///
  /// In es, this message translates to:
  /// **'No hay observaciones guardadas en esta página.'**
  String get sitSpotJubiladoPaginaVacia;

  /// No description provided for @paginaSitSpotLoQueAnotaste.
  ///
  /// In es, this message translates to:
  /// **'Lo que ya has anotado aquí'**
  String get paginaSitSpotLoQueAnotaste;

  /// No description provided for @paginaSitSpotVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no has anotado nada en este sit spot. Cuando lo hagas, aparecerá aquí.'**
  String get paginaSitSpotVacio;

  /// No description provided for @paginaSitSpotActivoDesde.
  ///
  /// In es, this message translates to:
  /// **'Activo desde el {desde}.'**
  String paginaSitSpotActivoDesde(String desde);

  /// No description provided for @crearSitSpotIntro.
  ///
  /// In es, this message translates to:
  /// **'Un sit spot es un lugar al que vuelves. Lo ves cambiar con el tiempo.'**
  String get crearSitSpotIntro;

  /// No description provided for @crearSitSpotEtiquetaNombre.
  ///
  /// In es, this message translates to:
  /// **'cómo se llama tu sit spot'**
  String get crearSitSpotEtiquetaNombre;

  /// No description provided for @crearSitSpotHintNombre.
  ///
  /// In es, this message translates to:
  /// **'el roble grande, mi banco, donde fui con la abuela…'**
  String get crearSitSpotHintNombre;

  /// No description provided for @crearSitSpotEtiquetaDonde.
  ///
  /// In es, this message translates to:
  /// **'dónde está, para acordarte (opcional)'**
  String get crearSitSpotEtiquetaDonde;

  /// No description provided for @crearSitSpotHintDonde.
  ///
  /// In es, this message translates to:
  /// **'al final del parque, junto al pino más alto'**
  String get crearSitSpotHintDonde;

  /// No description provided for @crearSitSpotBotonGuardar.
  ///
  /// In es, this message translates to:
  /// **'guardar sit spot'**
  String get crearSitSpotBotonGuardar;

  /// No description provided for @crearSitSpotGuardando.
  ///
  /// In es, this message translates to:
  /// **'guardando…'**
  String get crearSitSpotGuardando;

  /// No description provided for @crearSitSpotPosicionNoAnclada.
  ///
  /// In es, this message translates to:
  /// **'Posición no anclada'**
  String get crearSitSpotPosicionNoAnclada;

  /// No description provided for @crearSitSpotPosicionAnclada.
  ///
  /// In es, this message translates to:
  /// **'Posición anclada al sit spot'**
  String get crearSitSpotPosicionAnclada;

  /// No description provided for @crearSitSpotPosicionPrivada.
  ///
  /// In es, this message translates to:
  /// **'La posición se queda en este cuaderno y no sale a internet.'**
  String get crearSitSpotPosicionPrivada;

  /// No description provided for @crearSitSpotBotonAnclar.
  ///
  /// In es, this message translates to:
  /// **'anclar mi posición'**
  String get crearSitSpotBotonAnclar;

  /// No description provided for @crearSitSpotLocalizando.
  ///
  /// In es, this message translates to:
  /// **'localizando…'**
  String get crearSitSpotLocalizando;

  /// No description provided for @presentacionSitSpotTitulo.
  ///
  /// In es, this message translates to:
  /// **'Un sitio que conoces'**
  String get presentacionSitSpotTitulo;

  /// No description provided for @presentacionSitSpotParrafo1.
  ///
  /// In es, this message translates to:
  /// **'En este cuaderno hay un sitio especial. Lo eliges tú: un banco del parque, una piedra junto al río, un rincón del jardín, una ventana.'**
  String get presentacionSitSpotParrafo1;

  /// No description provided for @presentacionSitSpotParrafo2.
  ///
  /// In es, this message translates to:
  /// **'Lo importante no es que sea bonito. Es que puedas volver. Si vuelves muchas veces, lo verás cambiar — las hojas, los pájaros, la luz, los bichos. El cuaderno se llenará de lo que pase allí.'**
  String get presentacionSitSpotParrafo2;

  /// No description provided for @presentacionSitSpotParrafo3.
  ///
  /// In es, this message translates to:
  /// **'Cuando lo encuentres, le pones nombre. No tiene que ser un nombre serio.'**
  String get presentacionSitSpotParrafo3;

  /// No description provided for @presentacionSitSpotBotonTengoSitio.
  ///
  /// In es, this message translates to:
  /// **'ya pienso en uno'**
  String get presentacionSitSpotBotonTengoSitio;

  /// No description provided for @presentacionSitSpotBotonTodaviaNo.
  ///
  /// In es, this message translates to:
  /// **'todavía no'**
  String get presentacionSitSpotBotonTodaviaNo;

  /// No description provided for @acercaCabeceraNombre.
  ///
  /// In es, this message translates to:
  /// **'El Cuaderno'**
  String get acercaCabeceraNombre;

  /// No description provided for @acercaCabeceraSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'un cuaderno de campo digital — para 9-13 años'**
  String get acercaCabeceraSubtitulo;

  /// No description provided for @acercaCierre.
  ///
  /// In es, this message translates to:
  /// **'el monte espera'**
  String get acercaCierre;

  /// No description provided for @acercaQueEsTitulo.
  ///
  /// In es, this message translates to:
  /// **'qué es esto'**
  String get acercaQueEsTitulo;

  /// No description provided for @acercaQueEsCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Un cuaderno de campo. Es tuyo. Lo que escribas aquí no se borra solo y nadie lo lee a tus espaldas.\n\nNo es un juego para ganar. No tiene puntos, ni rachas, ni nada que celebre nada. Es un sitio donde dejar lo que ves cuando sales a mirar.'**
  String get acercaQueEsCuerpo;

  /// No description provided for @acercaPestanasTitulo.
  ///
  /// In es, this message translates to:
  /// **'las cuatro pestañas'**
  String get acercaPestanasTitulo;

  /// No description provided for @acercaPestanasCuerpo.
  ///
  /// In es, this message translates to:
  /// **'**Cuaderno** — el saludo, el sit spot, los Misterios abiertos y la última página.\n\n**Mapa** — sólo si la persona adulta lo enciende en Ajustes.\n\n**Misterios** — tus preguntas y los Misterios del cuaderno. Aquí formulas las tuyas con el botón *\"formular pregunta\"*.\n\n**Tutor** — alguien con quien hablar cuando no entiendes algo. No es un buscador de internet y no da la respuesta hecha.'**
  String get acercaPestanasCuerpo;

  /// No description provided for @acercaAnotarTitulo.
  ///
  /// In es, this message translates to:
  /// **'anotar una observación'**
  String get acercaAnotarTitulo;

  /// No description provided for @acercaAnotarCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Cuando ves algo que merece la pena, lo anotas. Una página tiene tres campos importantes:\n\n**Qué viste** — lo que vieron tus ojos. *\"Una mariposa blanca con manchas marrones\"* es mejor que *\"una pieris\"*. La identificación viene después.\n\n**Crees que es** — si crees que sabes qué era. Si no, lo dejas vacío. Decir *\"no sé\"* es información: significa que volverás a mirar.\n\n**Nivel de confianza** — tres opciones: *consenso* (estás seguro), *hipótesis activa* (crees que sabes pero te haría falta volver a mirar), *no segura* (viste algo, no sabes qué).'**
  String get acercaAnotarCuerpo;

  /// No description provided for @acercaSitSpotTitulo.
  ///
  /// In es, this message translates to:
  /// **'tu sit spot'**
  String get acercaSitSpotTitulo;

  /// No description provided for @acercaSitSpotCuerpo.
  ///
  /// In es, this message translates to:
  /// **'El lugar al que vuelves muchas veces. No tiene que ser bonito. Tiene que ser tuyo: un banco del parque, una piedra junto al río, una rama gruesa de un árbol del patio.\n\nSi vas siempre a sitios distintos, ves cosas distintas. Si vuelves al mismo sitio, ves **cómo cambia**.\n\nNo tienes prisa por elegirlo. La presentación del cuaderno deja explícito que se puede dejar para después.'**
  String get acercaSitSpotCuerpo;

  /// No description provided for @acercaMisteriosTitulo.
  ///
  /// In es, this message translates to:
  /// **'misterios y preguntas'**
  String get acercaMisteriosTitulo;

  /// No description provided for @acercaMisteriosCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Hay dos tipos de preguntas en la pestaña Misterios:\n\nLos **Misterios del cuaderno** los propone el cuaderno, contextualizados a tu zona y a la estación. No tienes que resolverlos todos.\n\n**Tus preguntas** las formulas tú. Si no se te ocurre cómo empezar, hay un *\"necesito ideas\"* con cinco maneras posibles.\n\nCuando creas que tienes tu respuesta — no la respuesta correcta del libro de ciencias, **tu respuesta** — la guardas. Aquí no hay respuesta correcta: hay tu respuesta.'**
  String get acercaMisteriosCuerpo;

  /// No description provided for @acercaNoHaceTitulo.
  ///
  /// In es, this message translates to:
  /// **'lo que este cuaderno NO hace'**
  String get acercaNoHaceTitulo;

  /// No description provided for @acercaNoHaceCuerpo.
  ///
  /// In es, this message translates to:
  /// **'No tiene puntos, niveles, rachas, premios.\n\nNo envía notificaciones. Cuando te apetezca, abres tú.\n\nNo celebra cuando anotas algo. Tu observación es la celebración.\n\nNo te compara con otros niños. No hay rankings.\n\nNo te dice si algo está bien o mal. Lo que ves está bien por ser visto.'**
  String get acercaNoHaceCuerpo;

  /// No description provided for @acercaPrivacidadTitulo.
  ///
  /// In es, this message translates to:
  /// **'para tu adulto: privacidad'**
  String get acercaPrivacidadTitulo;

  /// No description provided for @acercaPrivacidadCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Esto es un hard limit no negociable: el cuaderno es del niño.\n\n**Sólo se queda en el dispositivo, nunca cruza red:**\n· el texto libre de las observaciones\n· las fotos\n· los dibujos del lienzo\n· las coordenadas precisas\n· las preguntas que formula\n· las respuestas al cerrar Misterios\n· el nombre que ha elegido\n\n**Sólo viaja al servidor con sincronización opt-in:**\n· un *hash* de la observación (no el texto)\n· el código de región provincial (no la posición)\n· un agregado semanal con conteos por tipo, sin contenido\n· las preguntas al Tutor IA, si está activado, con cuota diaria + ZDR + lista negra\n\n**Lo que la persona adulta puede ver:**\n· un párrafo cualitativo resumiendo la semana, sin texto literal\n· una pregunta sugerida para la cena\n\n**Lo que la persona adulta no puede ver:** ninguna observación literal, ninguna foto, ningún dibujo, ninguna coordenada, ninguna conversación con el Tutor.'**
  String get acercaPrivacidadCuerpo;

  /// No description provided for @acercaAcompanarTitulo.
  ///
  /// In es, this message translates to:
  /// **'para tu adulto: cómo acompañar'**
  String get acercaAcompanarTitulo;

  /// No description provided for @acercaAcompanarCuerpo.
  ///
  /// In es, this message translates to:
  /// **'El sit spot es lo más importante. Si la niña no se lo ha apropiado, no volverá. Que lo elija ella. Si todavía no encuentra ninguno, no tiene prisa.\n\nUna observación a la semana es buen ritmo. Hay semanas con cero observaciones — eso también está bien. La biblia del proyecto: *cierre amable y ritmo respetuoso.*\n\nSi activas el resumen semanal en Ajustes, recibirás una pregunta sugerida para la cena. Está pensada para que sea más fácil empezar conversación, no para auditar.\n\n**Lo que es mejor no hacer:**\n· leer su cuaderno por encima del hombro\n· pedir que demuestre lo que ha aprendido\n· corregir si identifica mal — la próxima vez comparará y se corregirá sola\n· felicitar efusivamente cuando anota — convierte el oficio en performance'**
  String get acercaAcompanarCuerpo;

  /// No description provided for @acercaTutorTitulo.
  ///
  /// In es, this message translates to:
  /// **'para tu adulto: el Tutor'**
  String get acercaTutorTitulo;

  /// No description provided for @acercaTutorCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Asistente conversacional limitado por reglas. La biblia del proyecto le pone cinco bumpers:\n\n**ZDR** — el proveedor del modelo no entrena con las conversaciones ni las retiene.\n\n**Sin memoria entre conversaciones.** Cada apertura empieza limpia.\n\n**Lista negra de temas.** Hay temas (sexualidad, violencia, drogas, autolesión, datos personales) que el Tutor no continúa. Redirige amable y al cabo de pocos turnos cierra.\n\n**Cuota de 30 turnos al día.** Cuando se llega, el Tutor responde *\"hablamos mañana\"*. Bumper deliberado contra el efecto adictivo.\n\n**No da respuestas hechas.** Está prompted para devolver la pregunta al lugar.'**
  String get acercaTutorCuerpo;

  /// No description provided for @acercaAulaTitulo.
  ///
  /// In es, this message translates to:
  /// **'para el aula: vista del docente'**
  String get acercaAulaTitulo;

  /// No description provided for @acercaAulaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Cuando este cuaderno se usa en clase, la persona docente accede a un panel agregado desde Ajustes → *\"Acceder como profesor\"*. Lo que ve:\n\n· recuento agregado de la actividad de su aula\n· distribución por dominios (presencia, observación, registro, identificación, relaciones, ciclos, hábitats, hipótesis, tejido)\n\n**Nunca el contenido literal de las observaciones de ningún niño.**\n\nUmbral mínimo: **k≥5**. Si en un dominio hay menos de 5 alumnas con datos, ese dato se oculta para que no sea posible deducir el comportamiento de una niña concreta.\n\nEsta parte está pendiente de cerrar la policy escolar definitiva con la regulación europea para menores en aulas.'**
  String get acercaAulaCuerpo;

  /// No description provided for @acercaIdiomasTitulo.
  ///
  /// In es, this message translates to:
  /// **'idiomas'**
  String get acercaIdiomasTitulo;

  /// No description provided for @acercaIdiomasCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Castellano, euskera y catalán desde el primer arranque. La traducción de euskera y catalán está pendiente de revisión por hablantes nativas con criterio terminológico naturalista.'**
  String get acercaIdiomasCuerpo;

  /// No description provided for @acercaLicenciaTitulo.
  ///
  /// In es, this message translates to:
  /// **'licencia'**
  String get acercaLicenciaTitulo;

  /// No description provided for @acercaLicenciaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Código AGPL-3.0. Contenido (textos, ilustraciones, catálogo de Misterios) CC-BY-SA 4.0. Sin tracking, sin anuncios, sin monetización. Privacidad por diseño.'**
  String get acercaLicenciaCuerpo;

  /// No description provided for @tarjetaMisterioContadorVacio.
  ///
  /// In es, this message translates to:
  /// **'todavía no has anotado nada'**
  String get tarjetaMisterioContadorVacio;

  /// No description provided for @tarjetaMisterioContadorUna.
  ///
  /// In es, this message translates to:
  /// **'1 evidencia anotada'**
  String get tarjetaMisterioContadorUna;

  /// No description provided for @tarjetaMisterioContadorVarias.
  ///
  /// In es, this message translates to:
  /// **'{n} evidencias anotadas'**
  String tarjetaMisterioContadorVarias(int n);

  /// No description provided for @tarjetaMisterioPrefijoCaliente.
  ///
  /// In es, this message translates to:
  /// **'estos días · {base}'**
  String tarjetaMisterioPrefijoCaliente(String base);

  /// No description provided for @tarjetaSitSpotOpcionesTooltip.
  ///
  /// In es, this message translates to:
  /// **'opciones del sit spot'**
  String get tarjetaSitSpotOpcionesTooltip;

  /// No description provided for @editarObservacionEtiquetaDonde.
  ///
  /// In es, this message translates to:
  /// **'dónde estabas'**
  String get editarObservacionEtiquetaDonde;

  /// No description provided for @lienzoTooltipDeshacer.
  ///
  /// In es, this message translates to:
  /// **'deshacer'**
  String get lienzoTooltipDeshacer;

  /// No description provided for @lienzoTooltipBorrar.
  ///
  /// In es, this message translates to:
  /// **'borrar y empezar otra vez'**
  String get lienzoTooltipBorrar;

  /// No description provided for @lienzoAnchoFino.
  ///
  /// In es, this message translates to:
  /// **'trazo fino'**
  String get lienzoAnchoFino;

  /// No description provided for @lienzoAnchoMedio.
  ///
  /// In es, this message translates to:
  /// **'trazo medio'**
  String get lienzoAnchoMedio;

  /// No description provided for @lienzoAnchoGrueso.
  ///
  /// In es, this message translates to:
  /// **'trazo grueso'**
  String get lienzoAnchoGrueso;

  /// No description provided for @lienzoHerramientaPlumilla.
  ///
  /// In es, this message translates to:
  /// **'plumilla'**
  String get lienzoHerramientaPlumilla;

  /// No description provided for @lienzoHerramientaLapicero.
  ///
  /// In es, this message translates to:
  /// **'lapicero'**
  String get lienzoHerramientaLapicero;

  /// No description provided for @lienzoHerramientaCarboncillo.
  ///
  /// In es, this message translates to:
  /// **'carboncillo'**
  String get lienzoHerramientaCarboncillo;

  /// No description provided for @lienzoHerramientaGoma.
  ///
  /// In es, this message translates to:
  /// **'goma'**
  String get lienzoHerramientaGoma;

  /// No description provided for @lienzoColorTinta.
  ///
  /// In es, this message translates to:
  /// **'tinta'**
  String get lienzoColorTinta;

  /// No description provided for @lienzoColorSanguina.
  ///
  /// In es, this message translates to:
  /// **'sanguina'**
  String get lienzoColorSanguina;

  /// No description provided for @lienzoColorSepia.
  ///
  /// In es, this message translates to:
  /// **'sepia'**
  String get lienzoColorSepia;

  /// No description provided for @lienzoColorOcre.
  ///
  /// In es, this message translates to:
  /// **'ocre'**
  String get lienzoColorOcre;

  /// No description provided for @lienzoColorVerdeBotanico.
  ///
  /// In es, this message translates to:
  /// **'verde botánico'**
  String get lienzoColorVerdeBotanico;

  /// No description provided for @pdfPlantillaTituloCabecera.
  ///
  /// In es, this message translates to:
  /// **'Cuaderno de campo'**
  String get pdfPlantillaTituloCabecera;

  /// No description provided for @pdfPlantillaTituloCabeceraConNombre.
  ///
  /// In es, this message translates to:
  /// **'Cuaderno de campo · {nombre}'**
  String pdfPlantillaTituloCabeceraConNombre(String nombre);

  /// No description provided for @pdfPlantillaAutorAnonimo.
  ///
  /// In es, this message translates to:
  /// **'El Cuaderno'**
  String get pdfPlantillaAutorAnonimo;

  /// No description provided for @pdfPlantillaPagina.
  ///
  /// In es, this message translates to:
  /// **'pág. {numero} de {total}'**
  String pdfPlantillaPagina(int numero, int total);

  /// No description provided for @pdfPlantillaSitSpot.
  ///
  /// In es, this message translates to:
  /// **'Sit spot: {nombre}'**
  String pdfPlantillaSitSpot(String nombre);

  /// No description provided for @pdfPlantillaDiaHora.
  ///
  /// In es, this message translates to:
  /// **'Día y hora'**
  String get pdfPlantillaDiaHora;

  /// No description provided for @pdfPlantillaDondeEstabas.
  ///
  /// In es, this message translates to:
  /// **'Dónde estabas'**
  String get pdfPlantillaDondeEstabas;

  /// No description provided for @pdfPlantillaQueViste.
  ///
  /// In es, this message translates to:
  /// **'Qué viste'**
  String get pdfPlantillaQueViste;

  /// No description provided for @pdfPlantillaCreesQueEs.
  ///
  /// In es, this message translates to:
  /// **'Crees que es'**
  String get pdfPlantillaCreesQueEs;

  /// No description provided for @pdfPlantillaDibuja.
  ///
  /// In es, this message translates to:
  /// **'Dibuja'**
  String get pdfPlantillaDibuja;

  /// No description provided for @configuracionInicialPoliticaCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Tu cuaderno es tuyo. Lo que escribes, las fotos y los dibujos que añades, viven solo en tu dispositivo. No salen al servidor.\n\nNo hay anuncios. No se vende lo que escribes a nadie. No hay rachas, niveles ni recompensas que te empujen a volver: vuelve si quieres, cuando quieras.\n\nSi una persona adulta quiere ayudarte a usar el Tutor real, o quiere recibir un resumen para hablar contigo, tiene que entrar a Ajustes y darle a un botón cada vez. Nunca pasa solo. Nunca avisa a nadie sin que tú lo sepas.\n\nCuando quieras, en Ajustes puedes exportar todo tu cuaderno como un archivo y borrarlo del todo de este dispositivo.\n\nEsta es una versión provisional escrita por el equipo que está haciendo el cuaderno. Antes de que lo use mucha gente, una persona experta en leyes va a revisarla.'**
  String get configuracionInicialPoliticaCuerpo;

  /// No description provided for @observacionMapaSonidosComenzar.
  ///
  /// In es, this message translates to:
  /// **'mapa de sonidos'**
  String get observacionMapaSonidosComenzar;

  /// No description provided for @mapaSonidosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Mapa de sonidos'**
  String get mapaSonidosTitulo;

  /// Mapa de sonidos (juego de campo clásico). Voz adulta amable, sin juicio estético (doc 04 §2.3). eu/ca BORRADOR.
  ///
  /// In es, this message translates to:
  /// **'Quédate en un sitio un rato. Tú estás en el centro. Cada sonido que oigas, márcalo donde te llega: cerca, a media distancia o lejos.'**
  String get mapaSonidosIntroduccion;

  /// No description provided for @mapaSonidosAyuda.
  ///
  /// In es, this message translates to:
  /// **'Toca el mapa para marcar. Toca una marca para quitarla.'**
  String get mapaSonidosAyuda;

  /// No description provided for @mapaSonidosCentro.
  ///
  /// In es, this message translates to:
  /// **'tú'**
  String get mapaSonidosCentro;

  /// No description provided for @mapaSonidosDelante.
  ///
  /// In es, this message translates to:
  /// **'delante'**
  String get mapaSonidosDelante;

  /// No description provided for @mapaSonidosGuardar.
  ///
  /// In es, this message translates to:
  /// **'guardar mapa'**
  String get mapaSonidosGuardar;

  /// No description provided for @mapaSonidosDeshacer.
  ///
  /// In es, this message translates to:
  /// **'deshacer'**
  String get mapaSonidosDeshacer;

  /// No description provided for @mapaSonidosTipoPajaro.
  ///
  /// In es, this message translates to:
  /// **'pájaro'**
  String get mapaSonidosTipoPajaro;

  /// No description provided for @mapaSonidosTipoInsecto.
  ///
  /// In es, this message translates to:
  /// **'insecto'**
  String get mapaSonidosTipoInsecto;

  /// No description provided for @mapaSonidosTipoAgua.
  ///
  /// In es, this message translates to:
  /// **'agua'**
  String get mapaSonidosTipoAgua;

  /// No description provided for @mapaSonidosTipoViento.
  ///
  /// In es, this message translates to:
  /// **'viento'**
  String get mapaSonidosTipoViento;

  /// No description provided for @mapaSonidosTipoHojas.
  ///
  /// In es, this message translates to:
  /// **'hojas'**
  String get mapaSonidosTipoHojas;

  /// No description provided for @mapaSonidosTipoAnimal.
  ///
  /// In es, this message translates to:
  /// **'otro animal'**
  String get mapaSonidosTipoAnimal;

  /// No description provided for @mapaSonidosTipoPersona.
  ///
  /// In es, this message translates to:
  /// **'personas'**
  String get mapaSonidosTipoPersona;

  /// No description provided for @mapaSonidosTipoMaquina.
  ///
  /// In es, this message translates to:
  /// **'máquina'**
  String get mapaSonidosTipoMaquina;

  /// Un sonido sin nombre también se apunta: escuchar antes de nombrar (biblia §3.1).
  ///
  /// In es, this message translates to:
  /// **'no sé qué es'**
  String get mapaSonidosTipoNoSe;

  /// Bloque de la página del sit spot con los colores dominantes de las fotos, por estación. No es progreso ni colección: una forma de mirar el mismo sitio a lo largo del año. eu/ca BORRADOR.
  ///
  /// In es, this message translates to:
  /// **'Los colores de este sitio'**
  String get paletaLugarTitulo;

  /// No description provided for @paletaLugarExplicacion.
  ///
  /// In es, this message translates to:
  /// **'Salen de tus fotos de aquí, estación a estación.'**
  String get paletaLugarExplicacion;

  /// Cuántas fotos componen la franja de una estación.
  ///
  /// In es, this message translates to:
  /// **'{numero, plural, =1{1 foto} other{{numero} fotos}}'**
  String paletaLugarFotos(int numero);

  /// No description provided for @estacionPrimavera.
  ///
  /// In es, this message translates to:
  /// **'primavera'**
  String get estacionPrimavera;

  /// No description provided for @estacionVerano.
  ///
  /// In es, this message translates to:
  /// **'verano'**
  String get estacionVerano;

  /// No description provided for @estacionOtono.
  ///
  /// In es, this message translates to:
  /// **'otoño'**
  String get estacionOtono;

  /// No description provided for @estacionInvierno.
  ///
  /// In es, this message translates to:
  /// **'invierno'**
  String get estacionInvierno;
}

class _TextosAppDelegate extends LocalizationsDelegate<TextosApp> {
  const _TextosAppDelegate();

  @override
  Future<TextosApp> load(Locale locale) {
    return SynchronousFuture<TextosApp>(lookupTextosApp(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'es', 'eu'].contains(locale.languageCode);

  @override
  bool shouldReload(_TextosAppDelegate old) => false;
}

TextosApp lookupTextosApp(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return TextosAppCa();
    case 'es':
      return TextosAppEs();
    case 'eu':
      return TextosAppEu();
  }

  throw FlutterError(
      'TextosApp.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
