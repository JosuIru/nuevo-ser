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
  /// **'Adjunta el informe PDF que acabas de guardar.'**
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
  /// **'Es la herramienta del Espacio Test Zunbeltz. Sirve para dos cosas: llevar el seguimiento de tu proyecto de test (lo que produces, lo que vendes, lo que gastas y lo que ganas) y cuidar las fincas (las infraestructuras del mapa y sus tareas de mantenimiento).\nTodo se guarda en tu móvil y funciona sin cobertura en el monte. Si sincronizas, además lo compartes con el resto del equipo a través del servidor de Zunbeltz.'**
  String get ayudaQueEsB;

  /// No description provided for @ayudaPestanasT.
  ///
  /// In es, this message translates to:
  /// **'Moverse por la app'**
  String get ayudaPestanasT;

  /// No description provided for @ayudaPestanasB.
  ///
  /// In es, this message translates to:
  /// **'Abajo tienes cuatro pestañas. Tócalas para cambiar de pantalla:\n• Hoy: la bandeja del espacio — alarmas, tareas vencidas y próximas, peticiones y avisos.\n• Fincas: el mapa con los puntos, las zonas y las tareas.\n• Proyectos: el proceso de test, sus números y el convenio.\n• Ajustes: idioma, sincronización, actualizaciones, envío de informes e información sobre el Espacio Test.\nEn Hoy, los iconos de arriba abren los contactos, el tiempo y esta ayuda.\nPara volver atrás, usa la flecha de arriba a la izquierda.'**
  String get ayudaPestanasB;

  /// No description provided for @ayudaIdiomaDatosT.
  ///
  /// In es, this message translates to:
  /// **'Idioma, fotos, tiempo e internet'**
  String get ayudaIdiomaDatosT;

  /// No description provided for @ayudaIdiomaDatosB.
  ///
  /// In es, this message translates to:
  /// **'• Cambia entre castellano y euskera en Ajustes → Idioma.\n• Las fotos se guardan en tu propio móvil.\n• En Hoy o en Fincas, el icono de la nube (arriba) abre el tiempo de la finca: cómo está ahora, las próximas 24 horas, el agua (lluvia caída, lluvia prevista y lo que pierden suelo y pasto) y los próximos 7 días. Toca un día para ver más detalle.\n• Avisos: helada, nieve, tormenta, lluvia, viento fuerte, calor, estrés por calor del ganado y días buenos para el manejo.\n» Todo funciona sin internet menos el tiempo, la sincronización y las actualizaciones. Sin cobertura, el tiempo muestra la última previsión que se descargó y avisa de cuándo es.'**
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
  /// **'Los proyectos los crea coordinación, y cada uno es de una persona tester.\n1. En Proyectos, pulsa + (solo coordinación).\n2. Pon el nombre, la actividad y elige la persona tester. Si quieres, también la finca y las fechas.\n3. Pulsa Guardar.\n» Cada persona tester ve solo su proyecto. Coordinación ve todos y, al terminar el test, lo cierra desde el menú del proyecto (⋮ → Cerrar proyecto).'**
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
  /// **'• En tu proyecto, el botón de compartir (arriba) saca el «Informe del proyecto (PDF)», lo exporta a CSV (se abre con Excel) o lo manda con «Enviar al coordinador». El correo al que se manda se pone en Ajustes → «Coordinador (envío de informes)».\n• El informe incluye las cuentas del convenio: balance del test y del proyecto, reparto, fianza, acompañamiento e incidencias.\n• Los PDF salen con la marca «BORRADOR». La versión definitiva la saca coordinación con el proyecto cerrado.\n• En la lista de Proyectos, el botón del gráfico saca la «Comparativa (PDF)» entre proyectos.\n• En Ajustes, «Exportar espacio (CSV)» saca las fincas y los puntos del mapa.'**
  String get ayudaInformesB;

  /// No description provided for @ayudaSyncT.
  ///
  /// In es, this message translates to:
  /// **'Compartir el espacio con el equipo'**
  String get ayudaSyncT;

  /// No description provided for @ayudaSyncB.
  ///
  /// In es, this message translates to:
  /// **'Con la sincronización, todo el equipo comparte el mismo espacio: fincas, puntos, zonas, tareas, proyectos, peticiones y avisos.\n1. Pide a coordinación tu token personal. Es tu llave: cada persona tiene el suyo y no se comparte.\n2. En Ajustes → Sincronización, pon la dirección del WordPress de Zunbeltz y tu token.\n3. La app sincroniza sola al abrirla, al volver a ella y cada 10 minutos si hay cobertura. También puedes pulsar el botón de sincronizar en Hoy.\n» Sin cobertura puedes seguir trabajando: lo que hagas sube en cuanto vuelva la conexión. Las fotos se quedan en tu móvil.'**
  String get ayudaSyncB;

  /// No description provided for @ayudaRolesT.
  ///
  /// In es, this message translates to:
  /// **'Quién puede hacer qué'**
  String get ayudaRolesT;

  /// No description provided for @ayudaRolesB.
  ///
  /// In es, this message translates to:
  /// **'Cada persona tiene un rol, que le da coordinación.\n• Coordinación: crea, reparte y cierra tareas; gestiona fincas, zonas, puntos y todos los proyectos; acepta o descarta peticiones; ve lo que pasa en el espacio.\n• Tester: ve sus tareas y las generales (las que no son de nadie), cambia su estado, coge una general o suelta una suya. Pide tareas en vez de crearlas. Añade y mueve puntos (un corral móvil, un bidón), da avisos y apunta el día a día de su proyecto mientras esté abierto.\n» En Ajustes ves con qué nombre y rol estás conectada. Sin sincronización estás en «Modo local» y puedes editarlo todo.'**
  String get ayudaRolesB;

  /// No description provided for @ayudaProblemasT.
  ///
  /// In es, this message translates to:
  /// **'Problemas frecuentes'**
  String get ayudaProblemasT;

  /// No description provided for @ayudaProblemasB.
  ///
  /// In es, this message translates to:
  /// **'• «Tu rol no permite…»: eso no te toca. Una tarea, cógela si está sin asignar o pide a coordinación que te la asigne.\n• «… cambios revertidos: tu rol no los permite» al sincronizar: tocaste algo que tu rol no permite y se ha dejado como estaba.\n• «Token incorrecto»: revisa que lo copiaste entero. Si lo has perdido, coordinación te genera uno nuevo y el viejo deja de valer.\n• Falta algo o ves cosas que ya no son tuyas: en Ajustes, «Sincronizar todo desde cero».\n• No sale la previsión del tiempo: necesita internet. Lo demás funciona sin cobertura.\n• La actualización se descarga pero no se instala: en los ajustes del móvil, permite «instalar apps desconocidas» para Solera Zunbeltz.\n» Con sincronización, tus datos están también en el servidor de Zunbeltz: si cambias de móvil, configura el nuevo con tu token y lo recuperas.'**
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
  /// **'Sincronización'**
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
  /// **'{enviados} cambios enviados · {recibidos} recibidos{retirados, plural, =0{} other{ · {retirados} retirados de este móvil}}'**
  String ajustesSyncResultado(int enviados, int recibidos, int retirados);

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

  /// En la versión web no se pueden adjuntar fotos (no hay sistema de ficheros).
  ///
  /// In es, this message translates to:
  /// **'Las fotos se añaden desde la app del móvil.'**
  String get fotosSoloEnMovil;

  /// Franja superior de la versión web de demostración.
  ///
  /// In es, this message translates to:
  /// **'Versión de prueba: los datos se guardan solo en este navegador y no se comparten con nadie.'**
  String get demoFranja;

  /// Sincronización completa: baja todo y retira lo que ya no corresponde.
  ///
  /// In es, this message translates to:
  /// **'Sincronizar todo desde cero'**
  String get ajustesSyncCompleta;

  /// No description provided for @ajustesSyncCompletaDetalle.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a bajar todo el espacio y quita de este móvil lo que ya no te corresponde.'**
  String get ajustesSyncCompletaDetalle;

  /// No description provided for @ajustesDemoSoloLocal.
  ///
  /// In es, this message translates to:
  /// **'Los datos de ejemplo solo se cargan en modo local, para que no lleguen al WordPress de Zunbeltz.'**
  String get ajustesDemoSoloLocal;

  /// No description provided for @fincaNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva finca'**
  String get fincaNueva;

  /// No description provided for @fincaNuevaNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get fincaNuevaNombre;

  /// No description provided for @fincaNuevaSuperficie.
  ///
  /// In es, this message translates to:
  /// **'Superficie (ha)'**
  String get fincaNuevaSuperficie;

  /// No description provided for @fincaNuevaCentro.
  ///
  /// In es, this message translates to:
  /// **'Se coloca en el centro del mapa. Muévelo antes si hace falta.'**
  String get fincaNuevaCentro;

  /// No description provided for @fincaNuevaCreada.
  ///
  /// In es, this message translates to:
  /// **'Finca «{nombre}» creada'**
  String fincaNuevaCreada(String nombre);

  /// No description provided for @proyectoEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar proyecto'**
  String get proyectoEditar;

  /// No description provided for @proyectoPersonaTester.
  ///
  /// In es, this message translates to:
  /// **'Persona tester'**
  String get proyectoPersonaTester;

  /// No description provided for @proyectoSinPersona.
  ///
  /// In es, this message translates to:
  /// **'Sin asignar'**
  String get proyectoSinPersona;

  /// No description provided for @proyectoCerrar.
  ///
  /// In es, this message translates to:
  /// **'Cerrar proyecto'**
  String get proyectoCerrar;

  /// No description provided for @proyectoReabrir.
  ///
  /// In es, this message translates to:
  /// **'Reabrir proyecto'**
  String get proyectoReabrir;

  /// No description provided for @proyectoCerrarPregunta.
  ///
  /// In es, this message translates to:
  /// **'Al cerrarlo, la persona tester ya no podrá apuntar en él y los informes saldrán como versión definitiva. ¿Cerrar el proyecto?'**
  String get proyectoCerrarPregunta;

  /// No description provided for @proyectoCerradoAviso.
  ///
  /// In es, this message translates to:
  /// **'Proyecto cerrado el {fecha}. Solo coordinación puede cambiarlo.'**
  String proyectoCerradoAviso(String fecha);

  /// No description provided for @proyectoCerradoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get proyectoCerradoEtiqueta;

  /// No description provided for @proyectoMas.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get proyectoMas;

  /// No description provided for @peticionesTitulo.
  ///
  /// In es, this message translates to:
  /// **'Peticiones de tarea'**
  String get peticionesTitulo;

  /// No description provided for @peticionNueva.
  ///
  /// In es, this message translates to:
  /// **'Pedir una tarea'**
  String get peticionNueva;

  /// No description provided for @peticionQue.
  ///
  /// In es, this message translates to:
  /// **'Qué hace falta'**
  String get peticionQue;

  /// No description provided for @peticionDetalles.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get peticionDetalles;

  /// No description provided for @peticionFinca.
  ///
  /// In es, this message translates to:
  /// **'Finca'**
  String get peticionFinca;

  /// No description provided for @peticionSinFinca.
  ///
  /// In es, this message translates to:
  /// **'Sin finca concreta'**
  String get peticionSinFinca;

  /// No description provided for @peticionUrgente.
  ///
  /// In es, this message translates to:
  /// **'Es urgente'**
  String get peticionUrgente;

  /// No description provided for @peticionUrgenteEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Urgente'**
  String get peticionUrgenteEtiqueta;

  /// No description provided for @peticionEnviada.
  ///
  /// In es, this message translates to:
  /// **'Petición guardada. Coordinación la verá al sincronizar.'**
  String get peticionEnviada;

  /// No description provided for @peticionesVacio.
  ///
  /// In es, this message translates to:
  /// **'No hay peticiones.'**
  String get peticionesVacio;

  /// No description provided for @peticionCrearTarea.
  ///
  /// In es, this message translates to:
  /// **'Crear la tarea'**
  String get peticionCrearTarea;

  /// No description provided for @peticionDescartar.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get peticionDescartar;

  /// No description provided for @peticionMotivo.
  ///
  /// In es, this message translates to:
  /// **'Motivo (lo verá quien la pidió)'**
  String get peticionMotivo;

  /// No description provided for @peticionRetirar.
  ///
  /// In es, this message translates to:
  /// **'Retirar la petición'**
  String get peticionRetirar;

  /// No description provided for @peticionEstadoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get peticionEstadoPendiente;

  /// No description provided for @peticionEstadoAceptada.
  ///
  /// In es, this message translates to:
  /// **'Aceptada: tarea creada'**
  String get peticionEstadoAceptada;

  /// No description provided for @peticionEstadoDescartada.
  ///
  /// In es, this message translates to:
  /// **'Descartada'**
  String get peticionEstadoDescartada;

  /// No description provided for @peticionDe.
  ///
  /// In es, this message translates to:
  /// **'Pide {nombre}'**
  String peticionDe(String nombre);

  /// No description provided for @peticionRespuesta.
  ///
  /// In es, this message translates to:
  /// **'Respuesta: {texto}'**
  String peticionRespuesta(String texto);

  /// No description provided for @peticionNecesitaFinca.
  ///
  /// In es, this message translates to:
  /// **'Para crear la tarea, elige antes una finca.'**
  String get peticionNecesitaFinca;

  /// No description provided for @personaDesconocida.
  ///
  /// In es, this message translates to:
  /// **'alguien del espacio'**
  String get personaDesconocida;

  /// No description provided for @avisoCategoriaGanado.
  ///
  /// In es, this message translates to:
  /// **'Ganado'**
  String get avisoCategoriaGanado;

  /// No description provided for @avisoCategoriaInstalaciones.
  ///
  /// In es, this message translates to:
  /// **'Instalaciones'**
  String get avisoCategoriaInstalaciones;

  /// No description provided for @avisoCategoriaSeguimiento.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento individual'**
  String get avisoCategoriaSeguimiento;

  /// No description provided for @avisoCategoriaNoticias.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get avisoCategoriaNoticias;

  /// No description provided for @avisoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Dar un aviso'**
  String get avisoNuevo;

  /// No description provided for @avisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Qué pasa'**
  String get avisoTitulo;

  /// No description provided for @avisoDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get avisoDescripcion;

  /// No description provided for @avisoCategoria.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get avisoCategoria;

  /// No description provided for @avisoEsAlarma.
  ///
  /// In es, this message translates to:
  /// **'Es una alarma (animal enfermo, rotura importante, falta de alimento…)'**
  String get avisoEsAlarma;

  /// No description provided for @avisoAlarma.
  ///
  /// In es, this message translates to:
  /// **'Alarma'**
  String get avisoAlarma;

  /// No description provided for @avisoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Aviso guardado. Llegará al resto al sincronizar.'**
  String get avisoGuardado;

  /// No description provided for @avisoResolver.
  ///
  /// In es, this message translates to:
  /// **'Marcar como resuelto'**
  String get avisoResolver;

  /// No description provided for @avisoReabrir.
  ///
  /// In es, this message translates to:
  /// **'Reabrir'**
  String get avisoReabrir;

  /// No description provided for @avisoResuelto.
  ///
  /// In es, this message translates to:
  /// **'Resuelto'**
  String get avisoResuelto;

  /// No description provided for @avisoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar aviso'**
  String get avisoBorrar;

  /// No description provided for @avisosVacio.
  ///
  /// In es, this message translates to:
  /// **'Sin avisos en esta categoría.'**
  String get avisosVacio;

  /// No description provided for @avisoDe.
  ///
  /// In es, this message translates to:
  /// **'Avisa {nombre}'**
  String avisoDe(String nombre);

  /// No description provided for @hoyAlarmasAbiertas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 alarma abierta} other{{n} alarmas abiertas}}'**
  String hoyAlarmasAbiertas(int n);

  /// No description provided for @hoyTareasVencidas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Ninguna tarea vencida} =1{1 tarea vencida} other{{n} tareas vencidas}}'**
  String hoyTareasVencidas(int n);

  /// No description provided for @hoyTareasProximas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =0{Nada para los próximos 7 días} =1{1 tarea en los próximos 7 días} other{{n} tareas en los próximos 7 días}}'**
  String hoyTareasProximas(int n);

  /// No description provided for @hoyPeticionesPendientes.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 petición pendiente} other{{n} peticiones pendientes}}'**
  String hoyPeticionesPendientes(int n);

  /// No description provided for @hoyActividad.
  ///
  /// In es, this message translates to:
  /// **'Lo último en el espacio'**
  String get hoyActividad;

  /// No description provided for @hoyActividadVacia.
  ///
  /// In es, this message translates to:
  /// **'Todavía no ha llegado actividad. Sincroniza para verla.'**
  String get hoyActividadVacia;

  /// No description provided for @hoyAvisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get hoyAvisos;

  /// No description provided for @hoyTareas.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get hoyTareas;

  /// No description provided for @hoyTiempo.
  ///
  /// In es, this message translates to:
  /// **'El tiempo'**
  String get hoyTiempo;

  /// No description provided for @actividadCrear.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha añadido {cosa}'**
  String actividadCrear(String persona, String cosa);

  /// No description provided for @actividadEditar.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha cambiado {cosa}'**
  String actividadEditar(String persona, String cosa);

  /// No description provided for @actividadBorrar.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha borrado {cosa}'**
  String actividadBorrar(String persona, String cosa);

  /// No description provided for @actividadMover.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha movido {cosa}'**
  String actividadMover(String persona, String cosa);

  /// No description provided for @actividadEstado.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha marcado {cosa} como «{estado}»'**
  String actividadEstado(String persona, String cosa, String estado);

  /// No description provided for @actividadAsignar.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha asignado {cosa} a {responsable}'**
  String actividadAsignar(String persona, String cosa, String responsable);

  /// No description provided for @actividadDesasignar.
  ///
  /// In es, this message translates to:
  /// **'{persona} ha dejado sin asignar {cosa}'**
  String actividadDesasignar(String persona, String cosa);

  /// No description provided for @actividadEn.
  ///
  /// In es, this message translates to:
  /// **'en {lugar}'**
  String actividadEn(String lugar);

  /// No description provided for @actividadDesdePanel.
  ///
  /// In es, this message translates to:
  /// **'desde la oficina'**
  String get actividadDesdePanel;

  /// No description provided for @tipoEntidadTarea.
  ///
  /// In es, this message translates to:
  /// **'la tarea'**
  String get tipoEntidadTarea;

  /// No description provided for @tipoEntidadPunto.
  ///
  /// In es, this message translates to:
  /// **'el punto'**
  String get tipoEntidadPunto;

  /// No description provided for @tipoEntidadFinca.
  ///
  /// In es, this message translates to:
  /// **'la finca'**
  String get tipoEntidadFinca;

  /// No description provided for @tipoEntidadZona.
  ///
  /// In es, this message translates to:
  /// **'la zona'**
  String get tipoEntidadZona;

  /// No description provided for @tipoEntidadProyecto.
  ///
  /// In es, this message translates to:
  /// **'el proyecto'**
  String get tipoEntidadProyecto;

  /// No description provided for @tipoEntidadApunte.
  ///
  /// In es, this message translates to:
  /// **'el apunte'**
  String get tipoEntidadApunte;

  /// No description provided for @tipoEntidadVenta.
  ///
  /// In es, this message translates to:
  /// **'la venta'**
  String get tipoEntidadVenta;

  /// No description provided for @tipoEntidadRegistro.
  ///
  /// In es, this message translates to:
  /// **'el registro'**
  String get tipoEntidadRegistro;

  /// No description provided for @tipoEntidadValidacion.
  ///
  /// In es, this message translates to:
  /// **'la prueba de producto'**
  String get tipoEntidadValidacion;

  /// No description provided for @tipoEntidadPeticion.
  ///
  /// In es, this message translates to:
  /// **'la petición'**
  String get tipoEntidadPeticion;

  /// No description provided for @tipoEntidadAviso.
  ///
  /// In es, this message translates to:
  /// **'el aviso'**
  String get tipoEntidadAviso;

  /// No description provided for @tipoEntidadOtra.
  ///
  /// In es, this message translates to:
  /// **'un dato'**
  String get tipoEntidadOtra;

  /// No description provided for @notificacionCanalAlarmas.
  ///
  /// In es, this message translates to:
  /// **'Alarmas del espacio'**
  String get notificacionCanalAlarmas;

  /// No description provided for @notificacionCanalAvisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos y recordatorios'**
  String get notificacionCanalAvisos;

  /// No description provided for @notificacionAlarma.
  ///
  /// In es, this message translates to:
  /// **'Alarma: {titulo}'**
  String notificacionAlarma(String titulo);

  /// No description provided for @notificacionAlarmas.
  ///
  /// In es, this message translates to:
  /// **'{n} alarmas nuevas en el espacio'**
  String notificacionAlarmas(int n);

  /// No description provided for @notificacionPeticiones.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Nueva petición de tarea} other{{n} peticiones de tarea nuevas}}'**
  String notificacionPeticiones(int n);

  /// No description provided for @notificacionCambios.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 cambio en el espacio} other{{n} cambios en el espacio}}'**
  String notificacionCambios(int n);

  /// No description provided for @notificacionVencidas.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{Tienes 1 tarea vencida} other{Tienes {n} tareas vencidas}}'**
  String notificacionVencidas(int n);

  /// No description provided for @notificacionVencidasCuerpo.
  ///
  /// In es, this message translates to:
  /// **'Siguen pendientes hasta que se marquen como hechas.'**
  String get notificacionVencidasCuerpo;

  /// No description provided for @apuAsumidoPor.
  ///
  /// In es, this message translates to:
  /// **'Lo asume'**
  String get apuAsumidoPor;

  /// No description provided for @apuAmortizacion.
  ///
  /// In es, this message translates to:
  /// **'Es amortización (infraestructura o material)'**
  String get apuAmortizacion;

  /// No description provided for @apuAmortizacionDetalle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta en el balance del proyecto, no en el del test.'**
  String get apuAmortizacionDetalle;

  /// No description provided for @convenioTitulo.
  ///
  /// In es, this message translates to:
  /// **'Convenio'**
  String get convenioTitulo;

  /// No description provided for @convenioBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get convenioBalance;

  /// No description provided for @convenioPresupuesto.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto'**
  String get convenioPresupuesto;

  /// No description provided for @convenioFianza.
  ///
  /// In es, this message translates to:
  /// **'Fianza'**
  String get convenioFianza;

  /// No description provided for @convenioAcompanamiento.
  ///
  /// In es, this message translates to:
  /// **'Acompañamiento'**
  String get convenioAcompanamiento;

  /// No description provided for @convenioIncidencias.
  ///
  /// In es, this message translates to:
  /// **'Incidencias'**
  String get convenioIncidencias;

  /// No description provided for @convenioProvisional.
  ///
  /// In es, this message translates to:
  /// **'Orientativo, según el convenio tester. No es contabilidad ni declaración fiscal.'**
  String get convenioProvisional;

  /// No description provided for @balanceIngresos.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get balanceIngresos;

  /// No description provided for @balanceGastosTest.
  ///
  /// In es, this message translates to:
  /// **'Gastos del test (sin amortizaciones)'**
  String get balanceGastosTest;

  /// No description provided for @balanceAmortizaciones.
  ///
  /// In es, this message translates to:
  /// **'Amortizaciones'**
  String get balanceAmortizaciones;

  /// No description provided for @balanceTest.
  ///
  /// In es, this message translates to:
  /// **'Balance del test'**
  String get balanceTest;

  /// No description provided for @balanceProyecto.
  ///
  /// In es, this message translates to:
  /// **'Balance del proyecto (coste real)'**
  String get balanceProyecto;

  /// No description provided for @balanceAsumeTester.
  ///
  /// In es, this message translates to:
  /// **'Gastos que asume la persona tester'**
  String get balanceAsumeTester;

  /// No description provided for @balanceAsumeZunbeltz.
  ///
  /// In es, this message translates to:
  /// **'Gastos que asume Zunbeltz'**
  String get balanceAsumeZunbeltz;

  /// No description provided for @balanceReparto.
  ///
  /// In es, this message translates to:
  /// **'Reparto del resultado'**
  String get balanceReparto;

  /// No description provided for @balanceRepartoDetalle.
  ///
  /// In es, this message translates to:
  /// **'{tipo}: {zunbeltz} % Zunbeltz · {tester} % tester'**
  String balanceRepartoDetalle(String tipo, int zunbeltz, int tester);

  /// No description provided for @balanceBeneficio.
  ///
  /// In es, this message translates to:
  /// **'Beneficio'**
  String get balanceBeneficio;

  /// No description provided for @balancePerdida.
  ///
  /// In es, this message translates to:
  /// **'Pérdida'**
  String get balancePerdida;

  /// No description provided for @balanceParteZunbeltz.
  ///
  /// In es, this message translates to:
  /// **'Parte de Zunbeltz'**
  String get balanceParteZunbeltz;

  /// No description provided for @balanceParteTester.
  ///
  /// In es, this message translates to:
  /// **'Parte de la persona tester'**
  String get balanceParteTester;

  /// No description provided for @balancePrevistoReal.
  ///
  /// In es, this message translates to:
  /// **'Previsto frente a real'**
  String get balancePrevistoReal;

  /// No description provided for @balancePrevisto.
  ///
  /// In es, this message translates to:
  /// **'Previsto'**
  String get balancePrevisto;

  /// No description provided for @balanceReal.
  ///
  /// In es, this message translates to:
  /// **'Real'**
  String get balanceReal;

  /// No description provided for @balancePorcentajes.
  ///
  /// In es, this message translates to:
  /// **'Cambiar porcentajes del reparto'**
  String get balancePorcentajes;

  /// No description provided for @balancePorcentajeBeneficio.
  ///
  /// In es, this message translates to:
  /// **'% para Zunbeltz si hay beneficio'**
  String get balancePorcentajeBeneficio;

  /// No description provided for @balancePorcentajePerdida.
  ///
  /// In es, this message translates to:
  /// **'% para Zunbeltz si hay pérdida'**
  String get balancePorcentajePerdida;

  /// No description provided for @presupuestoVacio.
  ///
  /// In es, this message translates to:
  /// **'Sin presupuesto. Coordinación añade las partidas del anexo II.'**
  String get presupuestoVacio;

  /// No description provided for @presupuestoNuevaPartida.
  ///
  /// In es, this message translates to:
  /// **'Añadir partida'**
  String get presupuestoNuevaPartida;

  /// No description provided for @presupuestoTotal.
  ///
  /// In es, this message translates to:
  /// **'Total previsto'**
  String get presupuestoTotal;

  /// No description provided for @fianzaReferencia.
  ///
  /// In es, this message translates to:
  /// **'Fianza de referencia (10 % de lo que asume Zunbeltz)'**
  String get fianzaReferencia;

  /// No description provided for @fianzaDepositado.
  ///
  /// In es, this message translates to:
  /// **'Depositado'**
  String get fianzaDepositado;

  /// No description provided for @fianzaDevuelto.
  ///
  /// In es, this message translates to:
  /// **'Devuelto'**
  String get fianzaDevuelto;

  /// No description provided for @fianzaRetenido.
  ///
  /// In es, this message translates to:
  /// **'Retenido (incluidas incidencias)'**
  String get fianzaRetenido;

  /// No description provided for @fianzaPendiente.
  ///
  /// In es, this message translates to:
  /// **'En depósito ahora'**
  String get fianzaPendiente;

  /// No description provided for @fianzaNuevoMovimiento.
  ///
  /// In es, this message translates to:
  /// **'Añadir movimiento'**
  String get fianzaNuevoMovimiento;

  /// No description provided for @acompanamientoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Añadir actividad'**
  String get acompanamientoNuevo;

  /// No description provided for @acompanamientoVacio.
  ///
  /// In es, this message translates to:
  /// **'Sin actividades de acompañamiento todavía.'**
  String get acompanamientoVacio;

  /// No description provided for @acompanamientoIndicadores.
  ///
  /// In es, this message translates to:
  /// **'Indicadores del anexo IV ({meses} meses)'**
  String acompanamientoIndicadores(int meses);

  /// No description provided for @acompanamientoSoporte.
  ///
  /// In es, this message translates to:
  /// **'Soporte integral: formación, visita de referencia y asesoramiento'**
  String get acompanamientoSoporte;

  /// No description provided for @acompanamientoDifusion.
  ///
  /// In es, this message translates to:
  /// **'Difusión: visita recibida, mercado y medio'**
  String get acompanamientoDifusion;

  /// No description provided for @acompanamientoSeguimiento.
  ///
  /// In es, this message translates to:
  /// **'Seguimiento: reunión y visita a la finca cada mes'**
  String get acompanamientoSeguimiento;

  /// No description provided for @acompanamientoVenta.
  ///
  /// In es, this message translates to:
  /// **'Venta: búsqueda de canales o mercado'**
  String get acompanamientoVenta;

  /// No description provided for @acompanamientoAsistidas.
  ///
  /// In es, this message translates to:
  /// **'{asistidas} de {propuestas}'**
  String acompanamientoAsistidas(int asistidas, int propuestas);

  /// No description provided for @acompanamientoValoraciones.
  ///
  /// In es, this message translates to:
  /// **'Valoración de la implicación (0-10)'**
  String get acompanamientoValoraciones;

  /// No description provided for @acompanamientoValoracionZunbeltz.
  ///
  /// In es, this message translates to:
  /// **'Según Zunbeltz'**
  String get acompanamientoValoracionZunbeltz;

  /// No description provided for @acompanamientoValoracionTester.
  ///
  /// In es, this message translates to:
  /// **'Según la persona tester'**
  String get acompanamientoValoracionTester;

  /// No description provided for @acompanamientoHoras.
  ///
  /// In es, this message translates to:
  /// **'Horas'**
  String get acompanamientoHoras;

  /// No description provided for @acompanamientoAsistencia.
  ///
  /// In es, this message translates to:
  /// **'Asistencia'**
  String get acompanamientoAsistencia;

  /// No description provided for @incidenciasVacio.
  ///
  /// In es, this message translates to:
  /// **'Sin incidencias.'**
  String get incidenciasVacio;

  /// No description provided for @incidenciaNueva.
  ///
  /// In es, this message translates to:
  /// **'Registrar incidencia'**
  String get incidenciaNueva;

  /// No description provided for @incidenciaNivel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get incidenciaNivel;

  /// No description provided for @incidenciaRetencion.
  ///
  /// In es, this message translates to:
  /// **'Retención de fianza (€)'**
  String get incidenciaRetencion;

  /// No description provided for @incidenciasPrivado.
  ///
  /// In es, this message translates to:
  /// **'Solo lo ven coordinación y la persona tester de este proyecto.'**
  String get incidenciasPrivado;

  /// No description provided for @convenioTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get convenioTipo;

  /// No description provided for @convenioConcepto.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get convenioConcepto;

  /// No description provided for @convenioImporte.
  ///
  /// In es, this message translates to:
  /// **'Importe (€)'**
  String get convenioImporte;

  /// No description provided for @convenioFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get convenioFecha;

  /// No description provided for @convenioDescripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get convenioDescripcion;

  /// No description provided for @convenioCumple.
  ///
  /// In es, this message translates to:
  /// **'Cumple'**
  String get convenioCumple;

  /// No description provided for @convenioNoCumple.
  ///
  /// In es, this message translates to:
  /// **'Todavía no'**
  String get convenioNoCumple;

  /// No description provided for @marcaBorrador.
  ///
  /// In es, this message translates to:
  /// **'BORRADOR'**
  String get marcaBorrador;

  /// No description provided for @informeBorradorAviso.
  ///
  /// In es, this message translates to:
  /// **'Borrador: la versión definitiva la genera coordinación con el proyecto cerrado.'**
  String get informeBorradorAviso;

  /// No description provided for @ayudaHoyAvisosT.
  ///
  /// In es, this message translates to:
  /// **'Hoy y los avisos'**
  String get ayudaHoyAvisosT;

  /// No description provided for @ayudaHoyAvisosB.
  ///
  /// In es, this message translates to:
  /// **'Hoy es la bandeja del espacio. Arriba salen las alarmas abiertas; luego tus tareas vencidas y las de los próximos 7 días; las peticiones; y los avisos, por categorías: Ganado, Instalaciones, Seguimiento individual y Noticias. Coordinación ve además las peticiones pendientes y «Lo último en el espacio»: quién ha hecho qué, desde la app o desde la oficina.\n1. Para avisar de algo, pulsa «Dar un aviso».\n2. Elige la categoría, escribe qué pasa y, si quieres, la finca.\n3. Si es grave (un animal enfermo, una rotura importante, falta de alimento), marca «Es una alarma»: al resto le saltará una notificación.\n4. Toca un aviso para verlo y, cuando esté arreglado, márcalo como resuelto.\n» En Noticias, debajo de lo que publica coordinación, salen las «Noticias del sector»: titulares de fuera (administración, sindicatos agrarios, prensa del sector) de los canales que elige coordinación en el panel. Toca una para leerla entera en el navegador. No avisan con notificación.'**
  String get ayudaHoyAvisosB;

  /// No description provided for @ayudaPeticionesT.
  ///
  /// In es, this message translates to:
  /// **'Pedir una tarea'**
  String get ayudaPeticionesT;

  /// No description provided for @ayudaPeticionesB.
  ///
  /// In es, this message translates to:
  /// **'Si ves que hace falta algo (comprar pienso, arreglar una cancela…), pídeselo a coordinación:\n1. Desde Hoy, o desde la ficha del punto, pulsa «Pedir una tarea».\n2. Escribe qué hace falta; marca «Es urgente» si corre prisa.\n3. Guarda. Coordinación la verá al sincronizar y la convertirá en tarea o te contestará.\n» Tus peticiones y su respuesta están en Fincas → Tareas → botón de peticiones (arriba).'**
  String get ayudaPeticionesB;

  /// No description provided for @ayudaConvenioT.
  ///
  /// In es, this message translates to:
  /// **'El convenio: cuentas, fianza y acompañamiento'**
  String get ayudaConvenioT;

  /// No description provided for @ayudaConvenioB.
  ///
  /// In es, this message translates to:
  /// **'En tu proyecto, el botón del apretón de manos (arriba) abre el Convenio:\n• Balance: el del test (sin amortizaciones, el que se reparte) y el del proyecto (con ellas, el coste real), quién asume cada gasto y el reparto (por defecto 25 % Zunbeltz / 75 % tester si hay beneficio; 50 / 50 si hay pérdida).\n• Presupuesto: lo previsto, comparado con lo gastado.\n• Fianza: depósitos, devoluciones y retenciones.\n• Acompañamiento: formaciones, visitas, asesoramientos, reuniones… y si se cumplen los indicadores del anexo IV.\n• Incidencias: solo las ven coordinación y la persona tester del proyecto.\n» Al apuntar un gasto, indica quién lo asume y si es una amortización. Coordinación lleva el resto.'**
  String get ayudaConvenioB;

  /// No description provided for @ayudaNotificacionesT.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get ayudaNotificacionesT;

  /// No description provided for @ayudaNotificacionesB.
  ///
  /// In es, this message translates to:
  /// **'La app te avisa en el móvil:\n• Cuando llega una alarma de otra persona.\n• A coordinación: cuando hay peticiones nuevas y un resumen de lo que ha cambiado en el espacio.\n• Cada mañana a las 9:00, si tienes tareas vencidas, hasta que las marques como hechas.\n» Acepta el permiso de notificaciones la primera vez que lo pida la app. Con la app cerrada, el móvil Android comprueba si hay novedades cada 15 minutos más o menos cuando hay conexión; con el móvil en reposo puede tardar algo más. Si tu móvil corta las apps en segundo plano para ahorrar batería, quita a Solera Zunbeltz de esa lista.'**
  String get ayudaNotificacionesB;

  /// No description provided for @contactosTitulo.
  ///
  /// In es, this message translates to:
  /// **'Contactos'**
  String get contactosTitulo;

  /// No description provided for @contactosVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay contactos.'**
  String get contactosVacio;

  /// No description provided for @contactosTodos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get contactosTodos;

  /// No description provided for @contactoNuevo.
  ///
  /// In es, this message translates to:
  /// **'Añadir contacto'**
  String get contactoNuevo;

  /// No description provided for @contactoEditar.
  ///
  /// In es, this message translates to:
  /// **'Editar contacto'**
  String get contactoEditar;

  /// No description provided for @contactoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get contactoNombre;

  /// No description provided for @contactoTipo.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get contactoTipo;

  /// No description provided for @contactoTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get contactoTelefono;

  /// No description provided for @contactoCorreo.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get contactoCorreo;

  /// No description provided for @contactoLocalidad.
  ///
  /// In es, this message translates to:
  /// **'Localidad'**
  String get contactoLocalidad;

  /// No description provided for @contactoNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get contactoNotas;

  /// No description provided for @contactoLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get contactoLlamar;

  /// No description provided for @contactoEscribir.
  ///
  /// In es, this message translates to:
  /// **'Escribir'**
  String get contactoEscribir;

  /// No description provided for @contactoBorrar.
  ///
  /// In es, this message translates to:
  /// **'Borrar contacto'**
  String get contactoBorrar;

  /// No description provided for @contactoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Contacto guardado.'**
  String get contactoGuardado;

  /// No description provided for @tipoContactoMatadero.
  ///
  /// In es, this message translates to:
  /// **'Matadero'**
  String get tipoContactoMatadero;

  /// No description provided for @tipoContactoVeterinaria.
  ///
  /// In es, this message translates to:
  /// **'Veterinaria'**
  String get tipoContactoVeterinaria;

  /// No description provided for @tipoContactoExperto.
  ///
  /// In es, this message translates to:
  /// **'Persona experta'**
  String get tipoContactoExperto;

  /// No description provided for @tipoContactoComprador.
  ///
  /// In es, this message translates to:
  /// **'Comprador / tienda'**
  String get tipoContactoComprador;

  /// No description provided for @tipoContactoProveedor.
  ///
  /// In es, this message translates to:
  /// **'Proveedor'**
  String get tipoContactoProveedor;

  /// No description provided for @tipoContactoAdministracion.
  ///
  /// In es, this message translates to:
  /// **'Administración'**
  String get tipoContactoAdministracion;

  /// No description provided for @tipoContactoOtro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get tipoContactoOtro;

  /// No description provided for @calculadoraTitulo.
  ///
  /// In es, this message translates to:
  /// **'Calculadora de transformación'**
  String get calculadoraTitulo;

  /// No description provided for @calculadoraIntro.
  ///
  /// In es, this message translates to:
  /// **'De un animal de X kg a kg de producto, precio y margen. Prueba caminos (canal, despiece, elaborado) y guárdalos para compararlos.'**
  String get calculadoraIntro;

  /// No description provided for @calculadoraReferencia.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento de referencia'**
  String get calculadoraReferencia;

  /// No description provided for @calculadoraSinReferencias.
  ///
  /// In es, this message translates to:
  /// **'Coordinación puede guardar rendimientos de referencia en la oficina. Mientras, pon los porcentajes a mano.'**
  String get calculadoraSinReferencias;

  /// No description provided for @calculadoraNinguna.
  ///
  /// In es, this message translates to:
  /// **'Ninguno (a mano)'**
  String get calculadoraNinguna;

  /// No description provided for @calculadoraPesoVivo.
  ///
  /// In es, this message translates to:
  /// **'Peso vivo por animal (kg)'**
  String get calculadoraPesoVivo;

  /// No description provided for @calculadoraAnimales.
  ///
  /// In es, this message translates to:
  /// **'Animales'**
  String get calculadoraAnimales;

  /// No description provided for @calculadoraRendimientoCanal.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento a canal (%)'**
  String get calculadoraRendimientoCanal;

  /// No description provided for @calculadoraRendimientoProducto.
  ///
  /// In es, this message translates to:
  /// **'Producto vendible sobre canal (%)'**
  String get calculadoraRendimientoProducto;

  /// No description provided for @calculadoraPrecioKg.
  ///
  /// In es, this message translates to:
  /// **'Precio de venta (€/kg)'**
  String get calculadoraPrecioKg;

  /// No description provided for @calculadoraCosteSacrificio.
  ///
  /// In es, this message translates to:
  /// **'Matadero por animal (€)'**
  String get calculadoraCosteSacrificio;

  /// No description provided for @calculadoraCosteTransformacion.
  ///
  /// In es, this message translates to:
  /// **'Transformación y envasado (€/kg)'**
  String get calculadoraCosteTransformacion;

  /// No description provided for @calculadoraOtrosCostes.
  ///
  /// In es, this message translates to:
  /// **'Otros costes (€)'**
  String get calculadoraOtrosCostes;

  /// No description provided for @calculadoraKgCanal.
  ///
  /// In es, this message translates to:
  /// **'Kg de canal'**
  String get calculadoraKgCanal;

  /// No description provided for @calculadoraKgProducto.
  ///
  /// In es, this message translates to:
  /// **'Kg de producto'**
  String get calculadoraKgProducto;

  /// No description provided for @calculadoraIngreso.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get calculadoraIngreso;

  /// No description provided for @calculadoraCostes.
  ///
  /// In es, this message translates to:
  /// **'Costes'**
  String get calculadoraCostes;

  /// No description provided for @calculadoraMargen.
  ///
  /// In es, this message translates to:
  /// **'Margen'**
  String get calculadoraMargen;

  /// No description provided for @calculadoraMargenKgVivo.
  ///
  /// In es, this message translates to:
  /// **'Margen por kg vivo'**
  String get calculadoraMargenKgVivo;

  /// No description provided for @calculadoraGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar este camino'**
  String get calculadoraGuardar;

  /// No description provided for @calculadoraNombreEscenario.
  ///
  /// In es, this message translates to:
  /// **'Nombre (p. ej. «Despiece y venta directa»)'**
  String get calculadoraNombreEscenario;

  /// No description provided for @calculadoraEscenarios.
  ///
  /// In es, this message translates to:
  /// **'Caminos guardados'**
  String get calculadoraEscenarios;

  /// No description provided for @calculadoraOrientativo.
  ///
  /// In es, this message translates to:
  /// **'Cálculo orientativo: los rendimientos reales dependen del animal, del matadero y del despiece.'**
  String get calculadoraOrientativo;

  /// No description provided for @alimentacionExcel.
  ///
  /// In es, this message translates to:
  /// **'Alimentación por días (Excel)'**
  String get alimentacionExcel;

  /// No description provided for @ayudaContactosT.
  ///
  /// In es, this message translates to:
  /// **'Contactos del espacio'**
  String get ayudaContactosT;

  /// No description provided for @ayudaContactosB.
  ///
  /// In es, this message translates to:
  /// **'La agenda compartida: mataderos, veterinaria, personas expertas, compradores…\n1. En Hoy, pulsa el icono de contactos (arriba).\n2. Filtra por tipo y toca un contacto para llamar o escribir.\n3. Para añadir uno, pulsa «Añadir contacto». Puedes corregir los que añadas tú; coordinación los gestiona todos, también desde la oficina.'**
  String get ayudaContactosB;

  /// No description provided for @ayudaCalculadoraT.
  ///
  /// In es, this message translates to:
  /// **'Calculadora de transformación y Excel de alimentación'**
  String get ayudaCalculadoraT;

  /// No description provided for @ayudaCalculadoraB.
  ///
  /// In es, this message translates to:
  /// **'En tu proyecto, el botón de la calculadora (arriba):\n1. Elige un rendimiento de referencia (los pone coordinación) o escribe los porcentajes.\n2. Pon el peso vivo, el precio por kg y los costes: verás los kg de producto, el ingreso, el margen y a cuánto sale el kg vivo.\n3. «Guardar este camino» para compararlo con otros (canal, despiece, elaborado…).\n» En el botón de compartir del proyecto, «Alimentación por días (Excel)» saca los kg suministrados cada día y por lote.'**
  String get ayudaCalculadoraB;

  /// No description provided for @ayudaActualizacionesT.
  ///
  /// In es, this message translates to:
  /// **'Instalar una versión nueva'**
  String get ayudaActualizacionesT;

  /// No description provided for @ayudaActualizacionesB.
  ///
  /// In es, this message translates to:
  /// **'Cuando sale una versión nueva, la app te avisa al abrirla («Versión disponible»). Pulsa «Actualizar», o «Descartar por ahora» si te viene mal.\n1. También puedes mirarlo en Ajustes → Actualizaciones: ves la versión instalada, la última publicada y qué trae. «Buscar ahora» lo vuelve a comprobar.\n2. Pulsa «Descargar e instalar» y confirma en el instalador del móvil.\n3. Vuelve a abrir la app.\n» La primera vez, Android puede pedir que permitas «instalar apps desconocidas» para Solera Zunbeltz. Tus datos se conservan al actualizar.'**
  String get ayudaActualizacionesB;

  /// No description provided for @ayudaWebT.
  ///
  /// In es, this message translates to:
  /// **'Usar la app en el ordenador'**
  String get ayudaWebT;

  /// No description provided for @ayudaWebB.
  ///
  /// In es, this message translates to:
  /// **'La app también funciona en el navegador, útil en la oficina o con pantalla grande.\n1. Abre la dirección que te dé coordinación (la del WordPress de Zunbeltz, terminada en /app/).\n2. La dirección del servidor ya viene puesta: en Ajustes → Sincronización solo tienes que poner tu token.\n3. A partir de ahí funciona igual que en el móvil.\n» En el navegador no se pueden añadir fotos: se añaden desde el móvil. Si arriba ves la franja «Versión de prueba», es la demostración: lo que apuntes ahí se queda en ese navegador y no lo ve nadie más.'**
  String get ayudaWebB;

  /// No description provided for @noticiasSectorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Noticias del sector'**
  String get noticiasSectorTitulo;

  /// No description provided for @noticiasSectorVerTodas.
  ///
  /// In es, this message translates to:
  /// **'Ver todas ({n})'**
  String noticiasSectorVerTodas(int n);

  /// No description provided for @noticiasSectorVacio.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay noticias del sector. Los canales los añade coordinación en el panel de WordPress.'**
  String get noticiasSectorVacio;

  /// No description provided for @noticiasSectorActualizadas.
  ///
  /// In es, this message translates to:
  /// **'Actualizado: {fecha}'**
  String noticiasSectorActualizadas(String fecha);

  /// No description provided for @noticiasSectorDestacada.
  ///
  /// In es, this message translates to:
  /// **'Destacada'**
  String get noticiasSectorDestacada;

  /// No description provided for @noticiasSectorSinAbrir.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido abrir la noticia.'**
  String get noticiasSectorSinAbrir;

  /// No description provided for @noticiasSectorSinServidor.
  ///
  /// In es, this message translates to:
  /// **'Las noticias del sector llegan del servidor del espacio: configúralo en Ajustes → Sincronización.'**
  String get noticiasSectorSinServidor;

  /// No description provided for @numeroNoValido.
  ///
  /// In es, this message translates to:
  /// **'Hay un número que no se entiende. Escríbelo, por ejemplo, así: 1200 o 1.200,50.'**
  String get numeroNoValido;

  /// No description provided for @comProductoObligatorio.
  ///
  /// In es, this message translates to:
  /// **'Indica qué producto has vendido.'**
  String get comProductoObligatorio;

  /// No description provided for @puntoCoordenadasNoValidas.
  ///
  /// In es, this message translates to:
  /// **'Revisa las coordenadas: latitud entre -90 y 90 y longitud entre -180 y 180, por ejemplo 42,795 y -1,912.'**
  String get puntoCoordenadasNoValidas;

  /// No description provided for @comunBorrarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'¿Borrarlo? No se puede deshacer y desaparece también de los demás móviles.'**
  String get comunBorrarConfirmar;

  /// No description provided for @errorSyncConfiguracion.
  ///
  /// In es, this message translates to:
  /// **'Pon la dirección del WordPress y tu token en Ajustes → Sincronización.'**
  String get errorSyncConfiguracion;

  /// No description provided for @errorSyncSinConexion.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido contactar con el servidor. Comprueba la cobertura y la dirección.'**
  String get errorSyncSinConexion;

  /// No description provided for @errorSyncToken.
  ///
  /// In es, this message translates to:
  /// **'Token incorrecto o persona desactivada. Pide uno nuevo a coordinación.'**
  String get errorSyncToken;

  /// No description provided for @errorSyncPluginAntiguo.
  ///
  /// In es, this message translates to:
  /// **'Ese WordPress no tiene el plugin de Solera Zunbeltz (0.3 o posterior).'**
  String get errorSyncPluginAntiguo;

  /// No description provided for @errorSyncServidor.
  ///
  /// In es, this message translates to:
  /// **'El servidor ha respondido con un error ({codigo}). Prueba más tarde.'**
  String errorSyncServidor(int codigo);

  /// No description provided for @errorSyncRespuesta.
  ///
  /// In es, this message translates to:
  /// **'El servidor ha respondido algo inesperado. Revisa que la dirección sea la del WordPress de Zunbeltz.'**
  String get errorSyncRespuesta;

  /// No description provided for @informePeriodo.
  ///
  /// In es, this message translates to:
  /// **'Periodo de las cifras'**
  String get informePeriodo;

  /// No description provided for @informeTodoElProyecto.
  ///
  /// In es, this message translates to:
  /// **'todo el proyecto'**
  String get informeTodoElProyecto;

  /// No description provided for @informeConvenioAcumulado.
  ///
  /// In es, this message translates to:
  /// **'Cuentas del convenio (todo el proyecto, sea cual sea el periodo):'**
  String get informeConvenioAcumulado;

  /// No description provided for @ajustesSyncOcupado.
  ///
  /// In es, this message translates to:
  /// **'Ya hay una sincronización en marcha. Se terminará sola; prueba de nuevo en un momento.'**
  String get ajustesSyncOcupado;
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
