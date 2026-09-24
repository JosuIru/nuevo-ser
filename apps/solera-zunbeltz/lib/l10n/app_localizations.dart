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

  /// No description provided for @appTitulo.
  ///
  /// In es, this message translates to:
  /// **'Solera Zunbeltz'**
  String get appTitulo;

  /// No description provided for @navHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get navHoy;

  /// No description provided for @navFincas.
  ///
  /// In es, this message translates to:
  /// **'Fincas'**
  String get navFincas;

  /// No description provided for @navSeguimiento.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento'**
  String get navSeguimiento;

  /// No description provided for @navAjustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navAjustes;

  /// No description provided for @onboardingTitulo.
  ///
  /// In es, this message translates to:
  /// **'Solera Zunbeltz'**
  String get onboardingTitulo;

  /// No description provided for @onboardingCuerpo.
  ///
  /// In es, this message translates to:
  /// **'La herramienta del Espacio Test Agrario: gestiona las fincas, reparte las tareas de mantenimiento y lleva el seguimiento del testaje. Funciona sin cobertura en el monte.'**
  String get onboardingCuerpo;

  /// No description provided for @onboardingBoton.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get onboardingBoton;

  /// No description provided for @hoyTitulo.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get hoyTitulo;

  /// No description provided for @hoyResumenTareas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Sin tareas abiertas} =1{1 tarea abierta} other{{n} tareas abiertas}}'**
  String hoyResumenTareas(int n);

  /// No description provided for @hoyVacio.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay nada registrado. Empieza por marcar una infraestructura en el mapa de Fincas.'**
  String get hoyVacio;

  /// No description provided for @hoyVerTablero.
  ///
  /// In es, this message translates to:
  /// **'Ver tareas'**
  String get hoyVerTablero;

  /// No description provided for @ajustesIdioma.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get ajustesIdioma;

  /// No description provided for @ajustesIdiomaCastellano.
  ///
  /// In es, this message translates to:
  /// **'Castellano'**
  String get ajustesIdiomaCastellano;

  /// No description provided for @ajustesIdiomaEuskera.
  ///
  /// In es, this message translates to:
  /// **'Euskara'**
  String get ajustesIdiomaEuskera;

  /// No description provided for @ajustesAcercaDe.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get ajustesAcercaDe;

  /// No description provided for @ajustesVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String ajustesVersion(String version);

  /// No description provided for @ajustesProvisional.
  ///
  /// In es, this message translates to:
  /// **'Versión preliminar. Los partes e informes que genera son orientativos y su formato está pendiente de validación. El papeleo oficial (libro de explotación, cuaderno PAC, trazabilidad…) llega en fases posteriores.'**
  String get ajustesProvisional;

  /// No description provided for @comunGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get comunGuardar;

  /// No description provided for @comunCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get comunCancelar;

  /// No description provided for @comunBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get comunBorrar;

  /// No description provided for @comunFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get comunFecha;

  /// No description provided for @mapaNuevoPunto.
  ///
  /// In es, this message translates to:
  /// **'Nuevo punto'**
  String get mapaNuevoPunto;

  /// No description provided for @mapaUsarGps.
  ///
  /// In es, this message translates to:
  /// **'Usar GPS actual'**
  String get mapaUsarGps;

  /// No description provided for @mapaUsarCentro.
  ///
  /// In es, this message translates to:
  /// **'Usar centro del mapa'**
  String get mapaUsarCentro;

  /// No description provided for @mapaElegirFinca.
  ///
  /// In es, this message translates to:
  /// **'¿En qué finca?'**
  String get mapaElegirFinca;

  /// No description provided for @mapaSinPuntos.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay puntos. Toca el mapa o pulsa «Nuevo punto» para marcar el primero.'**
  String get mapaSinPuntos;

  /// No description provided for @mapaTocaParaAnadir.
  ///
  /// In es, this message translates to:
  /// **'Toca el mapa para añadir un punto'**
  String get mapaTocaParaAnadir;

  /// No description provided for @mapaTocaNuevaUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Toca la nueva ubicación del punto'**
  String get mapaTocaNuevaUbicacion;

  /// No description provided for @puntoRecolocado.
  ///
  /// In es, this message translates to:
  /// **'Punto recolocado'**
  String get puntoRecolocado;

  /// No description provided for @fichaRecolocar.
  ///
  /// In es, this message translates to:
  /// **'Recolocar en el mapa'**
  String get fichaRecolocar;

  /// No description provided for @mapaGpsNoDisponible.
  ///
  /// In es, this message translates to:
  /// **'GPS no disponible — rellena la ubicación a mano.'**
  String get mapaGpsNoDisponible;

  /// No description provided for @mapaCapas.
  ///
  /// In es, this message translates to:
  /// **'Capas'**
  String get mapaCapas;

  /// No description provided for @mapaMapa.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get mapaMapa;

  /// No description provided for @mapaGps.
  ///
  /// In es, this message translates to:
  /// **'GPS'**
  String get mapaGps;

  /// No description provided for @mapaTablero.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get mapaTablero;

  /// No description provided for @puntoNuevoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo punto de infraestructura'**
  String get puntoNuevoTitulo;

  /// No description provided for @puntoFinca.
  ///
  /// In es, this message translates to:
  /// **'Finca'**
  String get puntoFinca;

  /// No description provided for @puntoTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get puntoTipo;

  /// No description provided for @puntoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get puntoNombre;

  /// No description provided for @puntoEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get puntoEstado;

  /// No description provided for @puntoNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get puntoNotas;

  /// No description provided for @puntoFotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get puntoFotos;

  /// No description provided for @puntoLatitud.
  ///
  /// In es, this message translates to:
  /// **'Latitud'**
  String get puntoLatitud;

  /// No description provided for @puntoLongitud.
  ///
  /// In es, this message translates to:
  /// **'Longitud'**
  String get puntoLongitud;

  /// No description provided for @puntoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Punto guardado'**
  String get puntoGuardado;

  /// No description provided for @fichaPuntoTareas.
  ///
  /// In es, this message translates to:
  /// **'Tareas del punto'**
  String get fichaPuntoTareas;

  /// No description provided for @fichaSinTareas.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas en este punto.'**
  String get fichaSinTareas;

  /// No description provided for @fichaNuevaTarea.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get fichaNuevaTarea;

  /// No description provided for @fichaBorrarPunto.
  ///
  /// In es, this message translates to:
  /// **'Borrar punto'**
  String get fichaBorrarPunto;

  /// No description provided for @fichaCoordenadas.
  ///
  /// In es, this message translates to:
  /// **'Coordenadas'**
  String get fichaCoordenadas;

  /// No description provided for @fichaSinCoordenadas.
  ///
  /// In es, this message translates to:
  /// **'Sin coordenadas'**
  String get fichaSinCoordenadas;

  /// No description provided for @tareaNuevaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get tareaNuevaTitulo;

  /// No description provided for @tareaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Título'**
  String get tareaTitulo;

  /// No description provided for @tareaDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get tareaDescripcion;

  /// No description provided for @tareaResponsable.
  ///
  /// In es, this message translates to:
  /// **'Responsable'**
  String get tareaResponsable;

  /// No description provided for @tareaPrioridad.
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get tareaPrioridad;

  /// No description provided for @tareaEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get tareaEstado;

  /// No description provided for @tareaFechaObjetivo.
  ///
  /// In es, this message translates to:
  /// **'Fecha objetivo'**
  String get tareaFechaObjetivo;

  /// No description provided for @tareaSinFecha.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha'**
  String get tareaSinFecha;

  /// No description provided for @tareaFotosAntes.
  ///
  /// In es, this message translates to:
  /// **'Fotos antes'**
  String get tareaFotosAntes;

  /// No description provided for @tareaFotosDespues.
  ///
  /// In es, this message translates to:
  /// **'Fotos después'**
  String get tareaFotosDespues;

  /// No description provided for @tareaCoste.
  ///
  /// In es, this message translates to:
  /// **'Coste (€)'**
  String get tareaCoste;

  /// No description provided for @tareaGuardada.
  ///
  /// In es, this message translates to:
  /// **'Tarea guardada'**
  String get tareaGuardada;

  /// No description provided for @tareaTituloObligatorio.
  ///
  /// In es, this message translates to:
  /// **'Pon un título a la tarea.'**
  String get tareaTituloObligatorio;

  /// No description provided for @tareaRecurrencia.
  ///
  /// In es, this message translates to:
  /// **'Periodicidad'**
  String get tareaRecurrencia;

  /// No description provided for @tareaMarcarHecha.
  ///
  /// In es, this message translates to:
  /// **'Marcar hecha'**
  String get tareaMarcarHecha;

  /// No description provided for @tareaSiguienteGenerada.
  ///
  /// In es, this message translates to:
  /// **'Hecha. Siguiente tarea generada.'**
  String get tareaSiguienteGenerada;

  /// No description provided for @tableroTitulo.
  ///
  /// In es, this message translates to:
  /// **'Tareas de mantenimiento'**
  String get tableroTitulo;

  /// No description provided for @tableroTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get tableroTodas;

  /// No description provided for @tableroFiltroFinca.
  ///
  /// In es, this message translates to:
  /// **'Finca'**
  String get tableroFiltroFinca;

  /// No description provided for @tableroFiltroEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get tableroFiltroEstado;

  /// No description provided for @tableroSinTareas.
  ///
  /// In es, this message translates to:
  /// **'No hay tareas con estos filtros.'**
  String get tableroSinTareas;

  /// No description provided for @tableroPartePdf.
  ///
  /// In es, this message translates to:
  /// **'Parte PDF'**
  String get tableroPartePdf;

  /// No description provided for @tableroGenerandoPdf.
  ///
  /// In es, this message translates to:
  /// **'Generando parte…'**
  String get tableroGenerandoPdf;

  /// No description provided for @tareaDeFinca.
  ///
  /// In es, this message translates to:
  /// **'Tarea de finca'**
  String get tareaDeFinca;

  /// No description provided for @parteTitulo.
  ///
  /// In es, this message translates to:
  /// **'Parte de mantenimiento'**
  String get parteTitulo;

  /// No description provided for @parteSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Espacio Test Agrario Zunbeltz · documento PROVISIONAL'**
  String get parteSubtitulo;

  /// No description provided for @parteProvisional.
  ///
  /// In es, this message translates to:
  /// **'DOCUMENTO PROVISIONAL — formato pendiente de validación.'**
  String get parteProvisional;

  /// No description provided for @parteResumenTareas.
  ///
  /// In es, this message translates to:
  /// **'Tareas incluidas: {n}'**
  String parteResumenTareas(int n);

  /// No description provided for @parteColPunto.
  ///
  /// In es, this message translates to:
  /// **'Punto'**
  String get parteColPunto;

  /// No description provided for @parteColTarea.
  ///
  /// In es, this message translates to:
  /// **'Tarea'**
  String get parteColTarea;

  /// No description provided for @parteColResponsable.
  ///
  /// In es, this message translates to:
  /// **'Responsable'**
  String get parteColResponsable;

  /// No description provided for @parteColPrioridad.
  ///
  /// In es, this message translates to:
  /// **'Prioridad'**
  String get parteColPrioridad;

  /// No description provided for @parteColEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get parteColEstado;

  /// No description provided for @parteColFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha objetivo'**
  String get parteColFecha;

  /// No description provided for @parteSinResponsable.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get parteSinResponsable;

  /// No description provided for @segTitulo.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento'**
  String get segTitulo;

  /// No description provided for @segIndicadores.
  ///
  /// In es, this message translates to:
  /// **'Indicadores del periodo'**
  String get segIndicadores;

  /// No description provided for @segTodasFincas.
  ///
  /// In es, this message translates to:
  /// **'Todas las fincas'**
  String get segTodasFincas;

  /// No description provided for @segAlimentacion.
  ///
  /// In es, this message translates to:
  /// **'Alimentación (kg)'**
  String get segAlimentacion;

  /// No description provided for @segPariciones.
  ///
  /// In es, this message translates to:
  /// **'Pariciones'**
  String get segPariciones;

  /// No description provided for @segProductos.
  ///
  /// In es, this message translates to:
  /// **'Productos comercializados'**
  String get segProductos;

  /// No description provided for @segIngresos.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get segIngresos;

  /// No description provided for @segGastos.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get segGastos;

  /// No description provided for @segBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get segBalance;

  /// No description provided for @segPestanaActividad.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get segPestanaActividad;

  /// No description provided for @segPestanaEconomico.
  ///
  /// In es, this message translates to:
  /// **'Económico'**
  String get segPestanaEconomico;

  /// No description provided for @segNuevaActividad.
  ///
  /// In es, this message translates to:
  /// **'Registrar actividad'**
  String get segNuevaActividad;

  /// No description provided for @segNuevoApunte.
  ///
  /// In es, this message translates to:
  /// **'Apunte económico'**
  String get segNuevoApunte;

  /// No description provided for @segSinRegistros.
  ///
  /// In es, this message translates to:
  /// **'Sin registros todavía.'**
  String get segSinRegistros;

  /// No description provided for @segInformePdf.
  ///
  /// In es, this message translates to:
  /// **'Informe de seguimiento (PDF)'**
  String get segInformePdf;

  /// No description provided for @segGenerandoInforme.
  ///
  /// In es, this message translates to:
  /// **'Generando informe…'**
  String get segGenerandoInforme;

  /// No description provided for @actNuevaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Registrar actividad'**
  String get actNuevaTitulo;

  /// No description provided for @actTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo de actividad'**
  String get actTipo;

  /// No description provided for @actCantidad.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get actCantidad;

  /// No description provided for @actLote.
  ///
  /// In es, this message translates to:
  /// **'Lote / rebaño'**
  String get actLote;

  /// No description provided for @actNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get actNotas;

  /// No description provided for @actGuardada.
  ///
  /// In es, this message translates to:
  /// **'Actividad registrada'**
  String get actGuardada;

  /// No description provided for @actCantidadObligatoria.
  ///
  /// In es, this message translates to:
  /// **'Indica una cantidad mayor que cero.'**
  String get actCantidadObligatoria;

  /// No description provided for @apuNuevoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo apunte económico'**
  String get apuNuevoTitulo;

  /// No description provided for @apuTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get apuTipo;

  /// No description provided for @apuConcepto.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get apuConcepto;

  /// No description provided for @apuImporte.
  ///
  /// In es, this message translates to:
  /// **'Importe (€)'**
  String get apuImporte;

  /// No description provided for @apuNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get apuNotas;

  /// No description provided for @apuGuardado.
  ///
  /// In es, this message translates to:
  /// **'Apunte guardado'**
  String get apuGuardado;

  /// No description provided for @apuImporteObligatorio.
  ///
  /// In es, this message translates to:
  /// **'Indica un importe mayor que cero.'**
  String get apuImporteObligatorio;

  /// No description provided for @informeSegTitulo.
  ///
  /// In es, this message translates to:
  /// **'Informe de seguimiento'**
  String get informeSegTitulo;

  /// No description provided for @informeSegResumenPeriodo.
  ///
  /// In es, this message translates to:
  /// **'Registros: {actividades} · apuntes: {apuntes}'**
  String informeSegResumenPeriodo(int actividades, int apuntes);

  /// No description provided for @informeSegTablaActividad.
  ///
  /// In es, this message translates to:
  /// **'Registros de actividad'**
  String get informeSegTablaActividad;

  /// No description provided for @informeSegTablaEconomico.
  ///
  /// In es, this message translates to:
  /// **'Apuntes económicos'**
  String get informeSegTablaEconomico;

  /// No description provided for @informeSegColTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get informeSegColTipo;

  /// No description provided for @informeSegColCantidad.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get informeSegColCantidad;

  /// No description provided for @informeSegColConcepto.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get informeSegColConcepto;

  /// No description provided for @informeSegColImporte.
  ///
  /// In es, this message translates to:
  /// **'Importe (€)'**
  String get informeSegColImporte;

  /// No description provided for @meteoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Previsión'**
  String get meteoTitulo;

  /// No description provided for @meteoHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get meteoHoy;

  /// No description provided for @meteoSinConexion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la previsión. Revisa la conexión e inténtalo de nuevo.'**
  String get meteoSinConexion;

  /// No description provided for @meteoReintentar.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get meteoReintentar;

  /// No description provided for @meteoOrientativo.
  ///
  /// In es, this message translates to:
  /// **'Previsión orientativa (Open-Meteo). No sustituye el criterio del ganadero ni del veterinario.'**
  String get meteoOrientativo;

  /// No description provided for @avisoHelada.
  ///
  /// In es, this message translates to:
  /// **'Helada'**
  String get avisoHelada;

  /// No description provided for @avisoLluvia.
  ///
  /// In es, this message translates to:
  /// **'Lluvia'**
  String get avisoLluvia;

  /// No description provided for @avisoViento.
  ///
  /// In es, this message translates to:
  /// **'Viento fuerte'**
  String get avisoViento;

  /// No description provided for @avisoCalor.
  ///
  /// In es, this message translates to:
  /// **'Calor'**
  String get avisoCalor;

  /// No description provided for @avisoBuenManejo.
  ///
  /// In es, this message translates to:
  /// **'Buen día de manejo'**
  String get avisoBuenManejo;

  /// No description provided for @acercaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Acerca del Espacio Test'**
  String get acercaTitulo;

  /// No description provided for @acercaIntro.
  ///
  /// In es, this message translates to:
  /// **'Zunbeltz es el primer Espacio Test Agroganadero de Navarra: una incubadora donde personas emprendedoras prueban un proyecto de ganadería ecológica extensiva durante un periodo acotado, con acompañamiento de ganaderas y ganaderos expertos, sobre las fincas de Zunbeltz (231 ha) y La Planilla (197 ha). Impulsado por el Gobierno de Navarra, la Mancomunidad de Andía y los municipios de la zona, con financiación de la UE, y gestionado por la Asociación Zunbeltz Elkartea.'**
  String get acercaIntro;

  /// No description provided for @acercaEnlaces.
  ///
  /// In es, this message translates to:
  /// **'Enlaces'**
  String get acercaEnlaces;

  /// No description provided for @acercaFuentes.
  ///
  /// In es, this message translates to:
  /// **'Información de fuentes públicas.'**
  String get acercaFuentes;

  /// No description provided for @navProyectos.
  ///
  /// In es, this message translates to:
  /// **'Proyectos'**
  String get navProyectos;

  /// No description provided for @proyectosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Proyectos de test'**
  String get proyectosTitulo;

  /// No description provided for @proyectosVacio.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay proyectos. Pulsa + para añadir el primero.'**
  String get proyectosVacio;

  /// No description provided for @proyectoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo proyecto'**
  String get proyectoNuevo;

  /// No description provided for @proyectoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre del proyecto'**
  String get proyectoNombre;

  /// No description provided for @proyectoPersona.
  ///
  /// In es, this message translates to:
  /// **'Persona tester'**
  String get proyectoPersona;

  /// No description provided for @proyectoActividad.
  ///
  /// In es, this message translates to:
  /// **'Actividad / vertical'**
  String get proyectoActividad;

  /// No description provided for @proyectoFinca.
  ///
  /// In es, this message translates to:
  /// **'Finca (apoyo)'**
  String get proyectoFinca;

  /// No description provided for @proyectoSinFinca.
  ///
  /// In es, this message translates to:
  /// **'Sin finca'**
  String get proyectoSinFinca;

  /// No description provided for @proyectoFechaInicio.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get proyectoFechaInicio;

  /// No description provided for @proyectoFechaFin.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get proyectoFechaFin;

  /// No description provided for @proyectoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Proyecto guardado'**
  String get proyectoGuardado;

  /// No description provided for @proyectoNombreObligatorio.
  ///
  /// In es, this message translates to:
  /// **'Pon un nombre al proyecto.'**
  String get proyectoNombreObligatorio;

  /// No description provided for @proyectoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar proyecto'**
  String get proyectoBorrar;

  /// No description provided for @rentTitulo.
  ///
  /// In es, this message translates to:
  /// **'Rentabilidad'**
  String get rentTitulo;

  /// No description provided for @rentVentas.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get rentVentas;

  /// No description provided for @rentOtrosIngresos.
  ///
  /// In es, this message translates to:
  /// **'Otros ingresos'**
  String get rentOtrosIngresos;

  /// No description provided for @rentGastos.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get rentGastos;

  /// No description provided for @rentBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get rentBalance;

  /// No description provided for @rentMargen.
  ///
  /// In es, this message translates to:
  /// **'Margen'**
  String get rentMargen;

  /// No description provided for @rentProyeccion.
  ///
  /// In es, this message translates to:
  /// **'Proyección anual'**
  String get rentProyeccion;

  /// No description provided for @detProduccion.
  ///
  /// In es, this message translates to:
  /// **'Producción'**
  String get detProduccion;

  /// No description provided for @detValidacion.
  ///
  /// In es, this message translates to:
  /// **'Validación'**
  String get detValidacion;

  /// No description provided for @detComercial.
  ///
  /// In es, this message translates to:
  /// **'Comercialización'**
  String get detComercial;

  /// No description provided for @detEconomico.
  ///
  /// In es, this message translates to:
  /// **'Económico'**
  String get detEconomico;

  /// No description provided for @detSinDatos.
  ///
  /// In es, this message translates to:
  /// **'Sin datos todavía.'**
  String get detSinDatos;

  /// No description provided for @detInformePdf.
  ///
  /// In es, this message translates to:
  /// **'Informe del proyecto (PDF)'**
  String get detInformePdf;

  /// No description provided for @comNuevaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nueva venta'**
  String get comNuevaTitulo;

  /// No description provided for @comProducto.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get comProducto;

  /// No description provided for @comCanal.
  ///
  /// In es, this message translates to:
  /// **'Canal'**
  String get comCanal;

  /// No description provided for @comCantidad.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get comCantidad;

  /// No description provided for @comUnidad.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get comUnidad;

  /// No description provided for @comPrecio.
  ///
  /// In es, this message translates to:
  /// **'Precio unitario (€)'**
  String get comPrecio;

  /// No description provided for @comIngreso.
  ///
  /// In es, this message translates to:
  /// **'Ingreso (€)'**
  String get comIngreso;

  /// No description provided for @comGuardada.
  ///
  /// In es, this message translates to:
  /// **'Venta guardada'**
  String get comGuardada;

  /// No description provided for @valNuevaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nueva validación de producto'**
  String get valNuevaTitulo;

  /// No description provided for @valDescripcion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué se valida?'**
  String get valDescripcion;

  /// No description provided for @valResultado.
  ///
  /// In es, this message translates to:
  /// **'Resultado'**
  String get valResultado;

  /// No description provided for @valValoracion.
  ///
  /// In es, this message translates to:
  /// **'Valoración'**
  String get valValoracion;

  /// No description provided for @valSinValorar.
  ///
  /// In es, this message translates to:
  /// **'Sin valorar'**
  String get valSinValorar;

  /// No description provided for @valGuardada.
  ///
  /// In es, this message translates to:
  /// **'Validación guardada'**
  String get valGuardada;

  /// No description provided for @infProyTitulo.
  ///
  /// In es, this message translates to:
  /// **'Informe del proyecto de test'**
  String get infProyTitulo;

  /// No description provided for @infProyResumen.
  ///
  /// In es, this message translates to:
  /// **'Proyecto: {nombre} · tester: {persona}'**
  String infProyResumen(String nombre, String persona);

  /// No description provided for @comparativaPdf.
  ///
  /// In es, this message translates to:
  /// **'Comparativa (PDF)'**
  String get comparativaPdf;

  /// No description provided for @comparativaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Comparativa de proyectos de test'**
  String get comparativaTitulo;

  /// No description provided for @comparativaColProyecto.
  ///
  /// In es, this message translates to:
  /// **'Proyecto'**
  String get comparativaColProyecto;

  /// No description provided for @comparativaColTester.
  ///
  /// In es, this message translates to:
  /// **'Tester'**
  String get comparativaColTester;

  /// No description provided for @comparativaTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get comparativaTotal;

  /// No description provided for @periodoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get periodoEtiqueta;

  /// No description provided for @periodoTodo.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get periodoTodo;

  /// No description provided for @periodoAnio.
  ///
  /// In es, this message translates to:
  /// **'Este año'**
  String get periodoAnio;

  /// No description provided for @periodoTrimestre.
  ///
  /// In es, this message translates to:
  /// **'Este trimestre'**
  String get periodoTrimestre;

  /// No description provided for @periodoTrimestreAnterior.
  ///
  /// In es, this message translates to:
  /// **'Trimestre anterior'**
  String get periodoTrimestreAnterior;

  /// No description provided for @detDesgloseGastos.
  ///
  /// In es, this message translates to:
  /// **'Desglose de gastos'**
  String get detDesgloseGastos;

  /// No description provided for @detIvaSoportado.
  ///
  /// In es, this message translates to:
  /// **'IVA soportado'**
  String get detIvaSoportado;

  /// No description provided for @detIvaRepercutido.
  ///
  /// In es, this message translates to:
  /// **'IVA repercutido'**
  String get detIvaRepercutido;

  /// No description provided for @apuCategoria.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get apuCategoria;

  /// No description provided for @apuIva.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get apuIva;

  /// No description provided for @comIva.
  ///
  /// In es, this message translates to:
  /// **'IVA'**
  String get comIva;

  /// No description provided for @ivaNoFiscal.
  ///
  /// In es, this message translates to:
  /// **'Cálculo orientativo. No es un módulo de declaración fiscal: el régimen (REAGP / general) lo define vuestro asesor.'**
  String get ivaNoFiscal;

  /// No description provided for @detExportarCsv.
  ///
  /// In es, this message translates to:
  /// **'Exportar CSV'**
  String get detExportarCsv;

  /// No description provided for @enviarCoordinador.
  ///
  /// In es, this message translates to:
  /// **'Enviar al coordinador'**
  String get enviarCoordinador;

  /// No description provided for @enviarCoordinadorTexto.
  ///
  /// In es, this message translates to:
  /// **'Informe del proyecto de test para el coordinador del Espacio Test Zunbeltz.'**
  String get enviarCoordinadorTexto;

  /// No description provided for @enviarCoordinadorSinDestino.
  ///
  /// In es, this message translates to:
  /// **'Configura el correo del coordinador en Ajustes.'**
  String get enviarCoordinadorSinDestino;

  /// No description provided for @enviarCoordinadorAdjuntar.
  ///
  /// In es, this message translates to:
  /// **'Adjunta el informe (ya generado en):'**
  String get enviarCoordinadorAdjuntar;

  /// No description provided for @ajustesCoordinador.
  ///
  /// In es, this message translates to:
  /// **'Coordinador (envío de informes)'**
  String get ajustesCoordinador;

  /// No description provided for @ajustesCoordinadorVacio.
  ///
  /// In es, this message translates to:
  /// **'Sin configurar'**
  String get ajustesCoordinadorVacio;

  /// No description provided for @coordinadorCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo del coordinador'**
  String get coordinadorCorreo;

  /// No description provided for @ayudaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get ayudaTitulo;

  /// No description provided for @ayudaIntro.
  ///
  /// In es, this message translates to:
  /// **'Una guía paso a paso para usar la app. Toca un apartado para abrirlo, o escribe arriba lo que buscas. Si te pierdes, vuelve atrás con la flecha de arriba a la izquierda.'**
  String get ayudaIntro;

  /// No description provided for @ayudaBuscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar en la ayuda'**
  String get ayudaBuscar;

  /// No description provided for @ayudaSinResultados.
  ///
  /// In es, this message translates to:
  /// **'No hay ningún apartado con esa palabra. Prueba con otra: «tarea», «zona», «venta», «token»…'**
  String get ayudaSinResultados;

  /// No description provided for @ayudaConsejo.
  ///
  /// In es, this message translates to:
  /// **'Bueno saber'**
  String get ayudaConsejo;

  /// No description provided for @ayudaGrupoEmpezar.
  ///
  /// In es, this message translates to:
  /// **'Primeros pasos'**
  String get ayudaGrupoEmpezar;

  /// No description provided for @ayudaGrupoFincas.
  ///
  /// In es, this message translates to:
  /// **'Fincas y tareas'**
  String get ayudaGrupoFincas;

  /// No description provided for @ayudaGrupoProyectos.
  ///
  /// In es, this message translates to:
  /// **'Tu proyecto de test'**
  String get ayudaGrupoProyectos;

  /// No description provided for @ayudaGrupoEquipo.
  ///
  /// In es, this message translates to:
  /// **'Trabajar en equipo'**
  String get ayudaGrupoEquipo;

  /// No description provided for @ayudaGrupoProblemas.
  ///
  /// In es, this message translates to:
  /// **'Si algo falla'**
  String get ayudaGrupoProblemas;

  /// No description provided for @ayudaQueEsT.
  ///
  /// In es, this message translates to:
  /// **'¿Qué es esta app?'**
  String get ayudaQueEsT;

  /// No description provided for @ayudaQueEsB.
  ///
  /// In es, this message translates to:
  /// **'Es la herramienta del Espacio Test Zunbeltz. Sirve para dos cosas: llevar el seguimiento de tu proyecto de test (lo que produces, lo que vendes, lo que gastas y lo que ganas) y cuidar las fincas (las infraestructuras del mapa y sus tareas de mantenimiento).\nTodo se guarda en tu móvil y funciona sin cobertura en el monte.'**
  String get ayudaQueEsB;

  /// No description provided for @ayudaPestanasT.
  ///
  /// In es, this message translates to:
  /// **'Moverse por la app'**
  String get ayudaPestanasT;

  /// No description provided for @ayudaPestanasB.
  ///
  /// In es, this message translates to:
  /// **'Abajo tienes cuatro pestañas. Tócalas para cambiar de pantalla:\n• Hoy: un resumen con las tareas abiertas.\n• Fincas: el mapa con los puntos, las zonas y las tareas.\n• Proyectos: tu proceso de test y tus números.\n• Ajustes: idioma, ayuda, envío de informes y sincronización.\nPara volver atrás, usa la flecha de arriba a la izquierda.'**
  String get ayudaPestanasB;

  /// No description provided for @ayudaIdiomaDatosT.
  ///
  /// In es, this message translates to:
  /// **'Idioma, fotos, tiempo e internet'**
  String get ayudaIdiomaDatosT;

  /// No description provided for @ayudaIdiomaDatosB.
  ///
  /// In es, this message translates to:
  /// **'• Cambia entre castellano y euskera en Ajustes → Idioma.\n• Las fotos se guardan en tu propio móvil.\n• En Fincas, el icono de la nube (arriba) abre el tiempo de la finca: cómo está ahora, las próximas 24 horas, el agua (lluvia caída, lluvia prevista y lo que pierden suelo y pasto) y los próximos 7 días. Toca un día para ver más detalle.\n• Avisos: helada, nieve, tormenta, lluvia, viento fuerte, calor, estrés por calor del ganado y días buenos para el manejo.\n» Todo funciona sin internet menos el tiempo y la sincronización de tareas. Sin cobertura, el tiempo muestra la última previsión que se descargó y avisa de cuándo es.'**
  String get ayudaIdiomaDatosB;

  /// No description provided for @ayudaFincasT.
  ///
  /// In es, this message translates to:
  /// **'Marcar un punto en el mapa'**
  String get ayudaFincasT;

  /// No description provided for @ayudaFincasB.
  ///
  /// In es, this message translates to:
  /// **'Un punto es cada infraestructura: abrevadero, manga, cierre, refugio, balsa…\n1. Entra en Fincas.\n2. Toca el sitio exacto en el mapa. O pulsa «Nuevo punto» (abajo a la derecha) y elige «Usar GPS actual» si estás junto a la instalación, o «Usar centro del mapa».\n3. Elige el tipo y el estado, ponle nombre y, si quieres, añade fotos.\n4. Pulsa Guardar.\n» El color del punto dice su estado: verde, operativo; ocre, revisar; rojizo, averiado. El botón «GPS» centra el mapa en ti y «Capas» cambia entre mapa y satélite.'**
  String get ayudaFincasB;

  /// No description provided for @ayudaZonasT.
  ///
  /// In es, this message translates to:
  /// **'Dibujar una zona (parcela, cercado…)'**
  String get ayudaZonasT;

  /// No description provided for @ayudaZonasB.
  ///
  /// In es, this message translates to:
  /// **'1. En Fincas, pulsa «Dibujar zona».\n2. Toca en el mapa las esquinas de la zona, una detrás de otra. Si te equivocas, pulsa «Deshacer».\n3. Con tres esquinas o más, pulsa «Cerrar zona».\n4. Elige la finca, el tipo (parcela de pasto, cercado, zona de pastoreo…), el nombre y el estado, y guarda.\n» La superficie que sale del dibujo es orientativa. Si tienes la oficial del recinto SIGPAC, ponla en «Superficie oficial SIGPAC» y será la que se use.'**
  String get ayudaZonasB;

  /// No description provided for @ayudaEditarMapaT.
  ///
  /// In es, this message translates to:
  /// **'Mover o borrar un punto o una zona'**
  String get ayudaEditarMapaT;

  /// No description provided for @ayudaEditarMapaB.
  ///
  /// In es, this message translates to:
  /// **'1. Toca el punto o la zona en el mapa para abrir su ficha.\n2. Para mover un punto: pulsa «Recolocar en el mapa» (arriba) y toca el sitio nuevo.\n3. Para corregir una zona: pulsa «Volver a dibujar» (arriba) y marca de nuevo sus esquinas.\n4. Para borrarlo: pulsa la papelera y confirma.'**
  String get ayudaEditarMapaB;

  /// No description provided for @ayudaTareasT.
  ///
  /// In es, this message translates to:
  /// **'Apuntar una tarea de mantenimiento'**
  String get ayudaTareasT;

  /// No description provided for @ayudaTareasB.
  ///
  /// In es, this message translates to:
  /// **'1. Abre la ficha de un punto o de una zona y pulsa «Nueva tarea».\n2. Escribe qué hay que hacer. Si quieres, añade responsable, prioridad, fecha objetivo, fotos de antes y después y el coste.\n3. Pulsa Guardar.\n» La tarea queda unida a ese punto o zona: la verás en su ficha y en el tablero de tareas.'**
  String get ayudaTareasB;

  /// No description provided for @ayudaRecurrentesT.
  ///
  /// In es, this message translates to:
  /// **'Tareas que se repiten'**
  String get ayudaRecurrentesT;

  /// No description provided for @ayudaRecurrentesB.
  ///
  /// In es, this message translates to:
  /// **'Lo que se hace siempre (rellenar comederos, revisar el vallado…) no hace falta apuntarlo cada vez.\n1. Al crear la tarea, elige una «Periodicidad»: diaria, semanal, quincenal, mensual o trimestral.\n2. Cuando la marques como hecha, la app crea sola la siguiente, con la fecha que toca.\n» En la lista, las tareas periódicas llevan el símbolo de repetir.'**
  String get ayudaRecurrentesB;

  /// No description provided for @ayudaTableroT.
  ///
  /// In es, this message translates to:
  /// **'Llevar las tareas al día'**
  String get ayudaTableroT;

  /// No description provided for @ayudaTableroB.
  ///
  /// In es, this message translates to:
  /// **'1. En Fincas, pulsa «Tareas» (arriba) para ver el tablero con todas.\n2. Filtra por finca y por estado. Si sincronizas con el equipo, «Mis tareas» deja solo las que tienes asignadas.\n3. Para darla por hecha, pulsa el círculo con la marca, a la derecha de la tarea.\n4. Toca una tarea para cambiar su estado (pendiente, en curso, hecha, bloqueada), asignártela o soltarla.\n5. Con «Parte PDF» sacas el parte de mantenimiento de lo que tengas filtrado, para imprimirlo o enviarlo.'**
  String get ayudaTableroB;

  /// No description provided for @ayudaProyectosT.
  ///
  /// In es, this message translates to:
  /// **'Crear tu proyecto'**
  String get ayudaProyectosT;

  /// No description provided for @ayudaProyectosB.
  ///
  /// In es, this message translates to:
  /// **'1. Entra en Proyectos y pulsa +.\n2. Pon el nombre del proyecto, la persona tester y la actividad. Si quieres, también la finca y las fechas de inicio y fin.\n3. Pulsa Guardar. Toca el proyecto en la lista para entrar en él.'**
  String get ayudaProyectosB;

  /// No description provided for @ayudaApuntarT.
  ///
  /// In es, this message translates to:
  /// **'Apuntar tu día a día'**
  String get ayudaApuntarT;

  /// No description provided for @ayudaApuntarB.
  ///
  /// In es, this message translates to:
  /// **'Dentro del proyecto hay cuatro pestañas: Producción, Comercialización, Validación y Económico.\n1. Ve a la pestaña de lo que quieras apuntar.\n2. Pulsa + y rellena lo que toque: lo producido; una venta (producto, canal, cantidad y precio); una prueba de producto y su resultado; o un gasto o ingreso con su categoría.\n3. Guarda. Los números de arriba se actualizan solos.'**
  String get ayudaApuntarB;

  /// No description provided for @ayudaNumerosT.
  ///
  /// In es, this message translates to:
  /// **'Entender tus números'**
  String get ayudaNumerosT;

  /// No description provided for @ayudaNumerosB.
  ///
  /// In es, this message translates to:
  /// **'Arriba del proyecto ves la rentabilidad: ventas, otros ingresos, gastos, balance, margen y la proyección a un año.\n• Con el filtro «Periodo» (arriba) lo miras para todo, este año, este trimestre o el trimestre anterior.\n• Si hay gastos, verás el desglose por categorías y el IVA soportado y repercutido.\n» El IVA es un cálculo orientativo, no una declaración fiscal: el régimen lo decide vuestro asesor.'**
  String get ayudaNumerosB;

  /// No description provided for @ayudaInformesT.
  ///
  /// In es, this message translates to:
  /// **'Sacar informes y enviarlos'**
  String get ayudaInformesT;

  /// No description provided for @ayudaInformesB.
  ///
  /// In es, this message translates to:
  /// **'• En tu proyecto, el botón de compartir (arriba) saca el «Informe del proyecto (PDF)», lo exporta a CSV (se abre con Excel) o lo manda con «Enviar al coordinador».\n• Para enviarlo al coordinador, pon antes su correo en Ajustes → Coordinador.\n• En la lista de Proyectos, el botón del gráfico (arriba) saca la «Comparativa (PDF)» entre todos los proyectos.\n• En Ajustes, «Exportar espacio (CSV)» saca las fincas y los puntos del mapa, para pasarlos a coordinación.'**
  String get ayudaInformesB;

  /// No description provided for @ayudaSyncT.
  ///
  /// In es, this message translates to:
  /// **'Compartir las tareas con el equipo'**
  String get ayudaSyncT;

  /// No description provided for @ayudaSyncB.
  ///
  /// In es, this message translates to:
  /// **'Si en el Espacio Test usáis la sincronización, las tareas se comparten entre los móviles de todo el equipo.\n1. Pide a coordinación tu token personal. Es tu llave: cada persona tiene el suyo y no se comparte.\n2. En Ajustes → Sincronización de tareas, pon la dirección del WordPress de Zunbeltz y tu token.\n3. Pulsa «Sincronizar ahora» cuando tengas cobertura: suben tus cambios y bajan los del resto.\n» Solo se comparten las tareas. Los puntos, las zonas y los proyectos siguen solo en tu móvil.'**
  String get ayudaSyncB;

  /// No description provided for @ayudaRolesT.
  ///
  /// In es, this message translates to:
  /// **'Quién puede hacer qué'**
  String get ayudaRolesT;

  /// No description provided for @ayudaRolesB.
  ///
  /// In es, this message translates to:
  /// **'Cada persona tiene un rol, que le da coordinación.\n• Coordinación: ve, crea, cambia y reparte todas las tareas.\n• Tester: ve todas y crea las suyas. Puede cambiar las que ha creado o tiene asignadas, y coger las que están sin asignar.\n» En Ajustes ves con qué nombre y rol estás conectada. Sin sincronización estás en «Modo local» y puedes editarlo todo.'**
  String get ayudaRolesB;

  /// No description provided for @ayudaProblemasT.
  ///
  /// In es, this message translates to:
  /// **'Problemas frecuentes'**
  String get ayudaProblemasT;

  /// No description provided for @ayudaProblemasB.
  ///
  /// In es, this message translates to:
  /// **'• «Tu rol no permite…»: esa tarea no es tuya. Cógela si está sin asignar, o pide a coordinación que te la asigne.\n• «Cambios revertidos» al sincronizar: tocaste algo que tu rol no permite y se ha dejado como estaba.\n• «Token incorrecto»: revisa que lo copiaste entero. Si lo has perdido, coordinación te genera uno nuevo y el viejo deja de valer.\n• «Sin finca reconocida»: esa tarea es de una finca que en tu móvil tiene otro nombre. Las fincas tienen que llamarse igual en todos los móviles.\n• No sale la previsión del tiempo: necesita internet. Lo demás funciona sin cobertura.\n» Tus datos viven en tu móvil. Si lo cambias o lo pierdes, habla antes con coordinación.'**
  String get ayudaProblemasB;

  /// No description provided for @ayudaPie.
  ///
  /// In es, this message translates to:
  /// **'Si algo no queda claro, pregunta a coordinación del Espacio Test.'**
  String get ayudaPie;

  /// No description provided for @ajustesExportarEspacio.
  ///
  /// In es, this message translates to:
  /// **'Exportar espacio (CSV)'**
  String get ajustesExportarEspacio;

  /// No description provided for @ajustesSyncTitulo.
  ///
  /// In es, this message translates to:
  /// **'Sincronización de tareas'**
  String get ajustesSyncTitulo;

  /// No description provided for @ajustesSyncUrl.
  ///
  /// In es, this message translates to:
  /// **'WordPress de Zunbeltz'**
  String get ajustesSyncUrl;

  /// No description provided for @ajustesSyncToken.
  ///
  /// In es, this message translates to:
  /// **'Token personal'**
  String get ajustesSyncToken;

  /// No description provided for @ajustesSyncSinConfigurar.
  ///
  /// In es, this message translates to:
  /// **'Sin configurar'**
  String get ajustesSyncSinConfigurar;

  /// No description provided for @ajustesSyncAhora.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar ahora'**
  String get ajustesSyncAhora;

  /// No description provided for @ajustesSyncResultado.
  ///
  /// In es, this message translates to:
  /// **'{subidas} tareas subidas · {bajadas} bajadas{omitidas, plural, =0{} other{ · {omitidas} sin finca reconocida}}'**
  String ajustesSyncResultado(int subidas, int bajadas, int omitidas);

  /// No description provided for @ajustesDemo.
  ///
  /// In es, this message translates to:
  /// **'Cargar datos de demostración'**
  String get ajustesDemo;

  /// No description provided for @demoCargada.
  ///
  /// In es, this message translates to:
  /// **'Datos de demostración cargados'**
  String get demoCargada;

  /// No description provided for @demoYaHay.
  ///
  /// In es, this message translates to:
  /// **'Ya hay proyectos; bórralos para recargar la demostración.'**
  String get demoYaHay;

  /// No description provided for @zonaDibujar.
  ///
  /// In es, this message translates to:
  /// **'Dibujar zona'**
  String get zonaDibujar;

  /// No description provided for @zonaNuevaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nueva zona'**
  String get zonaNuevaTitulo;

  /// No description provided for @zonaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Zonas'**
  String get zonaTitulo;

  /// No description provided for @zonaFinca.
  ///
  /// In es, this message translates to:
  /// **'Finca'**
  String get zonaFinca;

  /// No description provided for @zonaTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo de zona'**
  String get zonaTipo;

  /// No description provided for @zonaNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get zonaNombre;

  /// No description provided for @zonaEstado.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get zonaEstado;

  /// No description provided for @zonaNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get zonaNotas;

  /// No description provided for @zonaFotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get zonaFotos;

  /// No description provided for @zonaRecintoSigpac.
  ///
  /// In es, this message translates to:
  /// **'Recinto SIGPAC'**
  String get zonaRecintoSigpac;

  /// No description provided for @zonaSuperficie.
  ///
  /// In es, this message translates to:
  /// **'Superficie'**
  String get zonaSuperficie;

  /// No description provided for @zonaSuperficieOficial.
  ///
  /// In es, this message translates to:
  /// **'Superficie oficial SIGPAC (ha)'**
  String get zonaSuperficieOficial;

  /// No description provided for @zonaPerimetro.
  ///
  /// In es, this message translates to:
  /// **'Perímetro'**
  String get zonaPerimetro;

  /// No description provided for @zonaOrientativa.
  ///
  /// In es, this message translates to:
  /// **'orientativa'**
  String get zonaOrientativa;

  /// No description provided for @zonaAvisoSuperficie.
  ///
  /// In es, this message translates to:
  /// **'La superficie del trazado es orientativa: la oficial es la del recinto SIGPAC. Si la tenéis, ponedla en «Superficie oficial» y será la que se use.'**
  String get zonaAvisoSuperficie;

  /// No description provided for @zonaGuardada.
  ///
  /// In es, this message translates to:
  /// **'Zona guardada'**
  String get zonaGuardada;

  /// No description provided for @zonaBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar zona'**
  String get zonaBorrar;

  /// No description provided for @zonaTareas.
  ///
  /// In es, this message translates to:
  /// **'Tareas de la zona'**
  String get zonaTareas;

  /// No description provided for @zonaSinTareas.
  ///
  /// In es, this message translates to:
  /// **'Sin tareas en esta zona.'**
  String get zonaSinTareas;

  /// No description provided for @zonaNuevaTarea.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get zonaNuevaTarea;

  /// No description provided for @zonaRedibujar.
  ///
  /// In es, this message translates to:
  /// **'Volver a dibujar'**
  String get zonaRedibujar;

  /// No description provided for @zonaTrazadoActualizado.
  ///
  /// In es, this message translates to:
  /// **'Trazado actualizado'**
  String get zonaTrazadoActualizado;

  /// No description provided for @zonaTrazadoCorto.
  ///
  /// In es, this message translates to:
  /// **'Marca al menos tres esquinas para cerrar la zona.'**
  String get zonaTrazadoCorto;

  /// No description provided for @dibujoTocaVertices.
  ///
  /// In es, this message translates to:
  /// **'Toca las esquinas de la zona. Con tres o más, pulsa «Cerrar zona».'**
  String get dibujoTocaVertices;

  /// No description provided for @dibujoDeshacer.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get dibujoDeshacer;

  /// No description provided for @dibujoCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar zona'**
  String get dibujoCerrar;

  /// No description provided for @dibujoCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get dibujoCancelar;

  /// No description provided for @dibujoEnCurso.
  ///
  /// In es, this message translates to:
  /// **'{esquinas} · ≈ {ha} ha'**
  String dibujoEnCurso(String esquinas, String ha);

  /// No description provided for @dibujoEsquinas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Sin esquinas} =1{1 esquina} other{{n} esquinas}}'**
  String dibujoEsquinas(int n);

  /// No description provided for @tareaDeZona.
  ///
  /// In es, this message translates to:
  /// **'Tarea de zona'**
  String get tareaDeZona;

  /// No description provided for @parteColZona.
  ///
  /// In es, this message translates to:
  /// **'Zona'**
  String get parteColZona;

  /// No description provided for @ajustesSesionComo.
  ///
  /// In es, this message translates to:
  /// **'Sesión de {nombre}'**
  String ajustesSesionComo(String nombre);

  /// No description provided for @ajustesSesionConectada.
  ///
  /// In es, this message translates to:
  /// **'Sesión iniciada: {nombre}'**
  String ajustesSesionConectada(String nombre);

  /// No description provided for @ajustesSesionLocal.
  ///
  /// In es, this message translates to:
  /// **'Modo local'**
  String get ajustesSesionLocal;

  /// No description provided for @ajustesSesionLocalDetalle.
  ///
  /// In es, this message translates to:
  /// **'Sin sincronización: en este dispositivo se puede editar todo.'**
  String get ajustesSesionLocalDetalle;

  /// No description provided for @ajustesSyncRechazadas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cambio revertido: tu rol no lo permite} other{{n} cambios revertidos: tu rol no los permite}}'**
  String ajustesSyncRechazadas(int n);

  /// No description provided for @tareaSinAsignar.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get tareaSinAsignar;

  /// No description provided for @tareaAsignarme.
  ///
  /// In es, this message translates to:
  /// **'Asignármela'**
  String get tareaAsignarme;

  /// No description provided for @tareaSoltar.
  ///
  /// In es, this message translates to:
  /// **'Soltar la tarea'**
  String get tareaSoltar;

  /// No description provided for @tareaCambiarEstado.
  ///
  /// In es, this message translates to:
  /// **'Cambiar estado'**
  String get tareaCambiarEstado;

  /// No description provided for @tareaSinPermiso.
  ///
  /// In es, this message translates to:
  /// **'Tu rol no permite cambiar esta tarea.'**
  String get tareaSinPermiso;

  /// No description provided for @tareaNoPuedesCrear.
  ///
  /// In es, this message translates to:
  /// **'Tu rol no permite crear tareas.'**
  String get tareaNoPuedesCrear;

  /// No description provided for @tableroMisTareas.
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get tableroMisTareas;

  /// No description provided for @meteoAhora.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get meteoAhora;

  /// No description provided for @meteoSensacion.
  ///
  /// In es, this message translates to:
  /// **'Sensación'**
  String get meteoSensacion;

  /// No description provided for @meteoHumedad.
  ///
  /// In es, this message translates to:
  /// **'Humedad'**
  String get meteoHumedad;

  /// No description provided for @meteoViento.
  ///
  /// In es, this message translates to:
  /// **'Viento'**
  String get meteoViento;

  /// No description provided for @meteoRachas.
  ///
  /// In es, this message translates to:
  /// **'rachas'**
  String get meteoRachas;

  /// No description provided for @meteoLuz.
  ///
  /// In es, this message translates to:
  /// **'{horas} h {minutos} min de luz'**
  String meteoLuz(int horas, int minutos);

  /// No description provided for @meteoAmanecer.
  ///
  /// In es, this message translates to:
  /// **'Amanece'**
  String get meteoAmanecer;

  /// No description provided for @meteoAnochecer.
  ///
  /// In es, this message translates to:
  /// **'Anochece'**
  String get meteoAnochecer;

  /// No description provided for @meteoAltitud.
  ///
  /// In es, this message translates to:
  /// **'Datos del modelo a {metros} m de altitud'**
  String meteoAltitud(int metros);

  /// No description provided for @meteoProximasHoras.
  ///
  /// In es, this message translates to:
  /// **'Próximas 24 horas'**
  String get meteoProximasHoras;

  /// No description provided for @meteoAgua.
  ///
  /// In es, this message translates to:
  /// **'Agua y pasto'**
  String get meteoAgua;

  /// No description provided for @meteoLluviaPasada.
  ///
  /// In es, this message translates to:
  /// **'Lluvia últimos 7 días'**
  String get meteoLluviaPasada;

  /// No description provided for @meteoLluviaPrevista.
  ///
  /// In es, this message translates to:
  /// **'Lluvia prevista (7 días)'**
  String get meteoLluviaPrevista;

  /// No description provided for @meteoEvapotranspiracion.
  ///
  /// In es, this message translates to:
  /// **'Agua que pierden suelo y pasto (7 días)'**
  String get meteoEvapotranspiracion;

  /// No description provided for @meteoBalanceSeco.
  ///
  /// In es, this message translates to:
  /// **'Se prevé que suelo y pasto pierdan más agua de la que va a llover: ojo al pasto, las balsas y los abrevaderos.'**
  String get meteoBalanceSeco;

  /// No description provided for @meteoBalanceHumedo.
  ///
  /// In es, this message translates to:
  /// **'Se prevé más lluvia de la que pierden suelo y pasto.'**
  String get meteoBalanceHumedo;

  /// No description provided for @meteoDiasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Próximos 7 días'**
  String get meteoDiasTitulo;

  /// No description provided for @meteoSensacionMin.
  ///
  /// In es, this message translates to:
  /// **'Sensación mínima'**
  String get meteoSensacionMin;

  /// No description provided for @meteoHorasLluvia.
  ///
  /// In es, this message translates to:
  /// **'Horas de lluvia'**
  String get meteoHorasLluvia;

  /// No description provided for @meteoNieve.
  ///
  /// In es, this message translates to:
  /// **'Nieve'**
  String get meteoNieve;

  /// No description provided for @meteoUv.
  ///
  /// In es, this message translates to:
  /// **'Índice UV máximo'**
  String get meteoUv;

  /// No description provided for @meteoThi.
  ///
  /// In es, this message translates to:
  /// **'Índice de estrés por calor (THI) máximo'**
  String get meteoThi;

  /// No description provided for @meteoThiNota.
  ///
  /// In es, this message translates to:
  /// **'El THI y su umbral de alerta (75, índice de seguridad del ganado LCI) son orientativos y están pendientes de validar con el veterinario para vacuno de carne y ovino en extensivo.'**
  String get meteoThiNota;

  /// No description provided for @meteoGuardada.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Previsión guardada el {fecha}.'**
  String meteoGuardada(String fecha);

  /// No description provided for @meteoActualizado.
  ///
  /// In es, this message translates to:
  /// **'Actualizado {fecha}'**
  String meteoActualizado(String fecha);

  /// No description provided for @avisoNieve.
  ///
  /// In es, this message translates to:
  /// **'Nieve'**
  String get avisoNieve;

  /// No description provided for @avisoTormenta.
  ///
  /// In es, this message translates to:
  /// **'Tormenta'**
  String get avisoTormenta;

  /// No description provided for @avisoEstresCalor.
  ///
  /// In es, this message translates to:
  /// **'Estrés por calor'**
  String get avisoEstresCalor;

  /// No description provided for @meteoEvapotranspiracionDia.
  ///
  /// In es, this message translates to:
  /// **'Agua que pierden suelo y pasto'**
  String get meteoEvapotranspiracionDia;

  /// Textos de la pantalla de actualizaciones del core (claves actualizaciones*). Euskera: borrador pendiente de revisión nativa.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones'**
  String get actualizacionesTitulo;

  /// No description provided for @actualizacionesVersionInstalada.
  ///
  /// In es, this message translates to:
  /// **'Versión instalada'**
  String get actualizacionesVersionInstalada;

  /// No description provided for @actualizacionesUltimaPublicada.
  ///
  /// In es, this message translates to:
  /// **'Última publicada'**
  String get actualizacionesUltimaPublicada;

  /// No description provided for @actualizacionesSinConexion.
  ///
  /// In es, this message translates to:
  /// **'sin conexión'**
  String get actualizacionesSinConexion;

  /// No description provided for @actualizacionesNingunaTodavia.
  ///
  /// In es, this message translates to:
  /// **'ninguna todavía'**
  String get actualizacionesNingunaTodavia;

  /// No description provided for @actualizacionesPublicadaEl.
  ///
  /// In es, this message translates to:
  /// **'Publicada el'**
  String get actualizacionesPublicadaEl;

  /// No description provided for @actualizacionesComprobadoEl.
  ///
  /// In es, this message translates to:
  /// **'Comprobado el'**
  String get actualizacionesComprobadoEl;

  /// No description provided for @actualizacionesHayVersionNueva.
  ///
  /// In es, this message translates to:
  /// **'Hay una versión nueva.'**
  String get actualizacionesHayVersionNueva;

  /// No description provided for @actualizacionesTienesLaUltima.
  ///
  /// In es, this message translates to:
  /// **'Tienes la última versión.'**
  String get actualizacionesTienesLaUltima;

  /// No description provided for @actualizacionesQueTrae.
  ///
  /// In es, this message translates to:
  /// **'Qué trae'**
  String get actualizacionesQueTrae;

  /// No description provided for @actualizacionesDescargando.
  ///
  /// In es, this message translates to:
  /// **'Descargando…'**
  String get actualizacionesDescargando;

  /// No description provided for @actualizacionesDescargarEInstalar.
  ///
  /// In es, this message translates to:
  /// **'Descargar e instalar'**
  String get actualizacionesDescargarEInstalar;

  /// No description provided for @actualizacionesBuscarAhora.
  ///
  /// In es, this message translates to:
  /// **'Buscar ahora'**
  String get actualizacionesBuscarAhora;

  /// No description provided for @actualizacionesVersionDisponible.
  ///
  /// In es, this message translates to:
  /// **'Versión disponible'**
  String get actualizacionesVersionDisponible;

  /// No description provided for @actualizacionesTienesInstalada.
  ///
  /// In es, this message translates to:
  /// **'Tienes instalada la'**
  String get actualizacionesTienesInstalada;

  /// No description provided for @actualizacionesTocaParaActualizar.
  ///
  /// In es, this message translates to:
  /// **'Toca para actualizar.'**
  String get actualizacionesTocaParaActualizar;

  /// No description provided for @actualizacionesActualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get actualizacionesActualizar;

  /// No description provided for @actualizacionesDescartar.
  ///
  /// In es, this message translates to:
  /// **'Descartar por ahora'**
  String get actualizacionesDescartar;

  /// No description provided for @actualizacionesInstaladorAbierto.
  ///
  /// In es, this message translates to:
  /// **'Se ha abierto el instalador. Confirma la actualización y vuelve a abrir la app.'**
  String get actualizacionesInstaladorAbierto;

  /// No description provided for @actualizacionesDescargaEnNavegador.
  ///
  /// In es, this message translates to:
  /// **'Se ha abierto la descarga en el navegador.'**
  String get actualizacionesDescargaEnNavegador;

  /// No description provided for @actualizacionesErrorDescarga.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido descargar. Comprueba la conexión y vuelve a probar.'**
  String get actualizacionesErrorDescarga;

  /// No description provided for @actualizacionesErrorInstalador.
  ///
  /// In es, this message translates to:
  /// **'Descargada, pero Android no ha dejado abrir el instalador. Permite «instalar apps desconocidas» para esta app en los ajustes del móvil.'**
  String get actualizacionesErrorInstalador;

  /// No description provided for @ajustesActualizacionesSubtitulo.
  ///
  /// In es, this message translates to:
  /// **'Versión instalada y última publicada'**
  String get ajustesActualizacionesSubtitulo;
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
