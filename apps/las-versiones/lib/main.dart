import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nuevo_ser_companion/nuevo_ser_companion.dart' as companion;
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'datos/repositorio_cuaderno.dart';
import 'datos/repositorio_estado_brecha.dart';
import 'datos/repositorio_evaluacion_fuente.dart';
import 'datos/repositorio_flags_narrativos.dart';
import 'datos/repositorio_mosaico.dart';
import 'datos/repositorio_preguntas_brecha.dart';
import 'datos/repositorio_recoleccion_fuentes.dart';
import 'datos/repositorio_reconstruccion.dart';
import 'datos/reseteo_archivo.dart';
import 'datos/sincronizador_mosaico.dart';
import 'dominio/avances.dart';
import 'dominio/brecha.dart';
import 'dominio/catalogo_brechas.dart';
import 'dominio/cuaderno.dart';
import 'dominio/escenas_arco_1.dart';
import 'dominio/escenas_arco_2.dart';
import 'dominio/escenas_arco_3.dart';
import 'dominio/escenas_arco_4.dart';
import 'dominio/mosaico_arco_1.dart';
import 'dominio/mosaico_arco_2.dart';
import 'dominio/mosaico_arco_3.dart';
import 'dominio/mosaico_arco_4.dart';
import 'nucleo/paleta_archivo.dart';
import 'vista/pantalla_avances.dart';
import 'vista/pantalla_brecha.dart';
import 'vista/pantalla_cinematica.dart';
import 'vista/pantalla_configuracion_inicial.dart';
import 'vista/pantalla_cuaderno.dart';
import 'vista/pantalla_esqueleto.dart';
import 'vista/pantalla_login.dart';
import 'vista/pantalla_ajustes_audio.dart';
import 'vista/pantalla_menu.dart';
import 'vista/pantalla_perfiles.dart';
import 'vista/pantalla_mosaico_arco_1.dart';
import 'vista/pantalla_mosaico_arco_2.dart';
import 'vista/pantalla_mosaico_arco_3.dart';
import 'vista/pantalla_mosaico_arco_4.dart';
import 'vista/pantalla_resumenes.dart';
import 'sonido/servicio_sonoro_archivo.dart';
import 'datos/registro_maestria_archivo.dart';
import 'dominio/atico/oficios_atico.dart';
import 'dominio/escenas_cortas.dart';
import 'vista/atico/pantalla_atico.dart';

/// Clave global del idioma elegido por la Cronista en el primer
/// arranque. Sigue el namespace `nuevoser.<juego>.*` que el CLAUDE.md
/// raíz prescribe para juegos nuevos de la Colección. La cuenta del
/// backend, la versión de paquete sonoro, etc. seguirán el mismo
/// patrón cuando lleguen.
const _claveIdiomaApp = 'nuevoser.lasversiones.idioma_app';

/// Claves globales de la cuenta del backend (token JWT + email del
/// niño). El servidor codifica `nino_id` dentro del token, así que
/// estas claves NO son por-perfil aunque más adelante el juego
/// adopte multi-perfil local.
const _claveTokenBackend = 'nuevoser.lasversiones.token_backend';
const _claveEmailBackend = 'nuevoser.lasversiones.email_backend';

/// URL base del backend `nuevo-ser-core`. Provisional — la decisión
/// del dominio definitivo es humana (mismo bloqueante que para los
/// otros juegos de la Colección). Cuando llegue el dominio real, se
/// sustituye sin tocar el cliente.
const _urlBaseBackend = 'https://nuevoser.example.org';

/// Locale activo de la app. Es global para que `AppLasVersiones`
/// pueda quedarse `StatelessWidget` y a la vez reaccionar al cambio
/// de idioma sin tener que reconstruir todo el árbol manualmente.
final ValueNotifier<Locale?> localeAppLasVersiones =
    ValueNotifier<Locale?>(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Precarga del idioma elegido en sesiones previas. Si lo hay se
  // aplica al ValueNotifier ANTES del primer build de MaterialApp
  // para evitar un flash con el idioma del sistema. Si no lo hay
  // (primer arranque), el orquestador abrirá la configuración inicial.
  final repoIdioma = RepositorioIdiomaApp(
    prefs: SharedPreferences.getInstance,
    clave: _claveIdiomaApp,
  );
  final codigoIdiomaPersistido = await repoIdioma.cargar();
  if (codigoIdiomaPersistido != null) {
    localeAppLasVersiones.value = Locale(codigoIdiomaPersistido);
  }

  // Cuenta del backend. Hoy (sin pantalla de login) sólo se rellena
  // a mano via flujos debug; el sincronizador del Mosaico lo lee y,
  // si no hay token, se queda en local sin tocar la red.
  final repoCuenta = RepositorioCuentaBackend(
    prefs: SharedPreferences.getInstance,
    claveToken: _claveTokenBackend,
    claveEmail: _claveEmailBackend,
  );

  // Gestor multi-perfil del juego (F2-26). El namespace concentra
  // todas las claves del juego (`nuevoser.lasversiones.*`); las
  // claves globales (idioma, cuenta backend) se declaran como
  // `clavesGlobalesNoMigrables` para que la migración silenciosa
  // a `perfil.principal.*` del primer arranque no las toque. La
  // pantalla de Configuración Inicial sigue mostrando el selector
  // trilingüe sólo cuando no hay idioma persistido — el cambio a
  // multi-perfil no afecta ese flujo.
  final gestorPerfiles = GestorPerfiles(
    namespace: 'nuevoser.lasversiones',
    sufijoNombreVisible: 'nombre_jugador',
    clavesGlobalesNoMigrables: const {
      _claveIdiomaApp,
      _claveTokenBackend,
      _claveEmailBackend,
    },
  );

  // Reset total del Archivo. Borra todas las claves del namespace
  // `nuevoser.lasversiones.*` — incluidos perfiles, idioma y cuenta —
  // cubre cualquier repositorio del juego que respete la convención
  // sin tener que listarlos uno a uno.
  const reseteoArchivo = ReseteoArchivo(
    prefs: SharedPreferences.getInstance,
  );

  // Motor sonoro (F2-27 dejó las preferencias; aquí empieza a sonar).
  // Tolera no tener plugin ni assets: si falta algo, calla.
  final repoAudio = RepositorioPreferenciasAudio(gestor: gestorPerfiles);
  await ServicioSonoroArchivo.instancia.inicializar(repoAudio);

  runApp(AppLasVersiones(
    repoIdioma: repoIdioma,
    repoFlags: RepositorioFlagsNarrativos(gestor: gestorPerfiles),
    repoEstadoBrecha: RepositorioEstadoBrecha(gestor: gestorPerfiles),
    repoCuaderno: RepositorioCuaderno(gestor: gestorPerfiles),
    repoMosaico: RepositorioMosaico(gestor: gestorPerfiles),
    repoPreguntas: RepositorioPreguntasBrecha(gestor: gestorPerfiles),
    repoRecoleccion: RepositorioRecoleccionFuentes(gestor: gestorPerfiles),
    repoEvaluacion: RepositorioEvaluacionFuente(gestor: gestorPerfiles),
    repoReconstruccion: RepositorioReconstruccion(gestor: gestorPerfiles),
    repoAudio: repoAudio,
    repoCuenta: repoCuenta,
    gestorPerfiles: gestorPerfiles,
    reseteoArchivo: reseteoArchivo,
  ));
}

class AppLasVersiones extends StatelessWidget {
  final RepositorioIdiomaApp repoIdioma;
  final RepositorioFlagsNarrativos repoFlags;
  final RepositorioEstadoBrecha repoEstadoBrecha;
  final RepositorioCuaderno repoCuaderno;
  final RepositorioMosaico repoMosaico;
  final RepositorioPreguntasBrecha repoPreguntas;
  final RepositorioRecoleccionFuentes repoRecoleccion;
  final RepositorioEvaluacionFuente repoEvaluacion;
  final RepositorioReconstruccion repoReconstruccion;
  final RepositorioPreferenciasAudio repoAudio;
  final RepositorioCuentaBackend repoCuenta;
  final GestorPerfiles gestorPerfiles;
  final ReseteoArchivo reseteoArchivo;

  const AppLasVersiones({
    super.key,
    required this.repoIdioma,
    required this.repoFlags,
    required this.repoEstadoBrecha,
    required this.repoCuaderno,
    required this.repoMosaico,
    required this.repoPreguntas,
    required this.repoRecoleccion,
    required this.repoEvaluacion,
    required this.repoReconstruccion,
    required this.repoAudio,
    required this.repoCuenta,
    required this.gestorPerfiles,
    required this.reseteoArchivo,
  });

  @override
  Widget build(BuildContext contexto) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeAppLasVersiones,
      builder: (ctx, localeActivo, _) {
        return MaterialApp(
          title: 'Las Versiones',
          theme: _temaArchivo(),
          debugShowCheckedModeBanner: false,
          locale: localeActivo,
          // Hasta que arranque la generación gen-l10n no hay delegate
          // de strings — la pantalla esqueleto y la de configuración
          // inicial llevan sus textos hardcoded en los tres idiomas.
          // Pero sí declaramos los locales soportados para que Flutter
          // formatee fechas/números si algún componente los necesita.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('eu'),
            Locale('ca'),
          ],
          localeResolutionCallback: (localeDispositivo, soportados) {
            if (localeDispositivo != null) {
              for (final soportado in soportados) {
                if (soportado.languageCode == localeDispositivo.languageCode) {
                  return soportado;
                }
              }
            }
            return const Locale('es');
          },
          home: Orquestador(
            repoIdioma: repoIdioma,
            repoFlags: repoFlags,
            repoEstadoBrecha: repoEstadoBrecha,
            repoCuaderno: repoCuaderno,
            repoMosaico: repoMosaico,
            repoPreguntas: repoPreguntas,
            repoRecoleccion: repoRecoleccion,
            repoEvaluacion: repoEvaluacion,
            repoReconstruccion: repoReconstruccion,
            repoAudio: repoAudio,
            repoCuenta: repoCuenta,
            gestorPerfiles: gestorPerfiles,
            reseteoArchivo: reseteoArchivo,
          ),
        );
      },
    );
  }
}

ThemeData _temaArchivo() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PaletaArchivo.ambarLacre,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: PaletaArchivo.fondoProfundo,
  );
}

/// Orquestador del juego. Cinco estados posibles, en orden:
///
/// 1. **Configuración inicial** si la Cronista nunca eligió idioma.
/// 2. **Brecha** si una Brecha está abierta (su flag de disparo
///    activo y su flag de completado aún no). Las cinemáticas
///    pendientes que apunten al cierre de la Brecha (caso típico:
///    1.1.7 después de cerrar 1.1) esperan a que la Brecha termine.
/// 3. **Cinemática** si hay una escena pendiente cuyos
///    `flagsRequeridos` están todos activos y cuyo `flagDeSalida`
///    aún no lo está.
/// 4. **Mosaico de arco** si el flag del arco completado está
///    activo y el flag de mosaico entregado aún no.
/// 5. **Esqueleto** si todas las unidades narrativas implementadas
///    están vistas y todos los mosaicos del arco están entregados.
class Orquestador extends StatefulWidget {
  final RepositorioIdiomaApp repoIdioma;
  final RepositorioFlagsNarrativos repoFlags;
  final RepositorioEstadoBrecha repoEstadoBrecha;
  final RepositorioCuaderno repoCuaderno;
  final RepositorioMosaico repoMosaico;
  final RepositorioPreguntasBrecha repoPreguntas;
  final RepositorioRecoleccionFuentes repoRecoleccion;
  final RepositorioEvaluacionFuente repoEvaluacion;
  final RepositorioReconstruccion repoReconstruccion;
  final RepositorioPreferenciasAudio repoAudio;
  final RepositorioCuentaBackend repoCuenta;
  final GestorPerfiles gestorPerfiles;
  final ReseteoArchivo reseteoArchivo;

  const Orquestador({
    super.key,
    required this.repoIdioma,
    required this.repoFlags,
    required this.repoEstadoBrecha,
    required this.repoCuaderno,
    required this.repoMosaico,
    required this.repoPreguntas,
    required this.repoRecoleccion,
    required this.repoEvaluacion,
    required this.repoReconstruccion,
    required this.repoAudio,
    required this.repoCuenta,
    required this.gestorPerfiles,
    required this.reseteoArchivo,
  });

  @override
  State<Orquestador> createState() => _OrquestadorState();
}

class _OrquestadorState extends State<Orquestador> {
  bool _cargando = true;
  bool _idiomaElegido = false;
  bool _sesionIniciada = false;
  String? _nombrePerfilActivo;
  Set<String> _flagsActivos = const {};

  /// Preferencia por perfil (se guarda como flag): si está activa, las
  /// cinemáticas se ven enteras; si no (por defecto), en versión corta
  /// cuando la escena la tiene (`EscenasCortas`).
  static const String _flagEscenasEnteras = 'preferencia_escenas_enteras';

  /// Motor de maestría (P1 hoy). Lee el perfil activo en cada registro,
  /// así que sirve tras cambiar de perfil sin recrearlo.
  late final RegistroMaestriaArchivo _registroMaestria = RegistroMaestriaArchivo(
    repositorio: RepositorioHabilidades(gestor: widget.gestorPerfiles),
  );
  EscenaCinematica? _escenaEnReproduccion;
  Brecha? _brechaAbierta;
  FaseBrecha _faseBrechaActiva = FaseBrecha.formulacionPreguntas;

  late final companion.ClienteCompanion _clienteCompanion;
  late final ClienteApi _clienteApi;
  late final SincronizadorMosaicoArco1 _sincronizadorMosaico;
  late final SincronizadorMosaicoArco2 _sincronizadorMosaicoArco2;
  late final SincronizadorMosaicoArco3 _sincronizadorMosaicoArco3;
  late final SincronizadorMosaicoArco4 _sincronizadorMosaicoArco4;

  @override
  void initState() {
    super.initState();
    _clienteCompanion = companion.ClienteCompanion(urlBase: _urlBaseBackend);
    _clienteApi = ClienteApi(urlBase: _urlBaseBackend);
    _sincronizadorMosaico = SincronizadorMosaicoArco1(
      repoCuenta: widget.repoCuenta,
      repoMosaico: widget.repoMosaico,
      clienteCompanion: _clienteCompanion,
    );
    _sincronizadorMosaicoArco2 = SincronizadorMosaicoArco2(
      repoCuenta: widget.repoCuenta,
      repoMosaico: widget.repoMosaico,
      clienteCompanion: _clienteCompanion,
    );
    _sincronizadorMosaicoArco3 = SincronizadorMosaicoArco3(
      repoCuenta: widget.repoCuenta,
      repoMosaico: widget.repoMosaico,
      clienteCompanion: _clienteCompanion,
    );
    _sincronizadorMosaicoArco4 = SincronizadorMosaicoArco4(
      repoCuenta: widget.repoCuenta,
      repoMosaico: widget.repoMosaico,
      clienteCompanion: _clienteCompanion,
    );
    _cargarEstadoInicial();
  }

  @override
  void dispose() {
    _clienteCompanion.cerrar();
    _clienteApi.cerrar();
    super.dispose();
  }

  Future<void> _cargarEstadoInicial() async {
    final codigo = await widget.repoIdioma.cargar();
    final flags = await widget.repoFlags.activos();
    final token = await widget.repoCuenta.cargarToken();
    final perfilesInfo = await widget.gestorPerfiles.listarPerfilesConInfo();
    if (!mounted) return;
    _flagsActivos = flags;
    _idiomaElegido = codigo != null;
    _sesionIniciada = token != null && token.isNotEmpty;
    final activo = perfilesInfo.where((p) => p.esActivo).toList();
    _nombrePerfilActivo =
        activo.isNotEmpty ? activo.first.nombreVisible : null;
    final brecha = _proximaBrechaPendiente();
    FaseBrecha faseInicial = FaseBrecha.formulacionPreguntas;
    if (brecha != null) {
      faseInicial = await widget.repoEstadoBrecha.faseActiva(brecha.id) ??
          FaseBrecha.formulacionPreguntas;
    }
    if (!mounted) return;
    setState(() {
      _brechaAbierta = brecha;
      _faseBrechaActiva = faseInicial;
      _escenaEnReproduccion = brecha == null ? _proximaEscenaPendiente() : null;
      _cargando = false;
    });
  }

  /// Devuelve la primera escena pendiente cuyos `flagsRequeridos`
  /// están todos activos y cuyo `flagDeSalida` aún no lo está. `null`
  /// si no hay nada que reproducir ahora.
  ///
  /// Recorre los catálogos en orden de arco: Arco 1 → Arco 2. Esto
  /// garantiza que las cinemáticas latentes del Arco 1 (`1.A`, `1.B`,
  /// `1.B.1`, `1.C`) que se anclan a Brechas cerradas se disparen
  /// antes que el Arco 2 — el cierre del Arco 1 (1.Z) activa
  /// `arco_1_cerrado_por_la_cronista`, que es la única precondición
  /// del Arco 2, así que el orden temporal queda correcto.
  EscenaCinematica? _proximaEscenaPendiente() {
    if (!_idiomaElegido) return null;
    for (final catalogo in [
      EscenasArco1.todas,
      EscenasArco2.todas,
      EscenasArco3.todas,
      EscenasArco4.todas,
    ]) {
      for (final escena in catalogo) {
        final yaVista = _flagsActivos.contains(escena.flagDeSalida);
        if (yaVista) continue;
        final precondicionesOk = escena.flagsRequeridos.every(
          _flagsActivos.contains,
        );
        if (precondicionesOk) return escena;
      }
    }
    return null;
  }

  /// Devuelve la Brecha cuyo flag de disparo está activo y cuyo
  /// flag de completado aún no lo está. `null` si ninguna está
  /// abierta — entonces el orquestador pasa a evaluar cinemáticas
  /// como hasta ahora.
  Brecha? _proximaBrechaPendiente() {
    if (!_idiomaElegido) return null;
    for (final entrada in CatalogoBrechas.brechaPorFlagDeDisparo.entries) {
      final flagDisparo = entrada.key;
      final brecha = entrada.value;
      final disparada = _flagsActivos.contains(flagDisparo);
      final yaCompletada = _flagsActivos.contains(brecha.flagDeCompletado);
      if (disparada && !yaCompletada) return brecha;
    }
    return null;
  }

  Future<void> _alElegirIdioma(String codigo) async {
    await widget.repoIdioma.guardar(codigo);
    localeAppLasVersiones.value = Locale(codigo);
    if (!mounted) return;
    _idiomaElegido = true;
    final brecha = _proximaBrechaPendiente();
    FaseBrecha faseInicial = FaseBrecha.formulacionPreguntas;
    if (brecha != null) {
      faseInicial = await widget.repoEstadoBrecha.faseActiva(brecha.id) ??
          FaseBrecha.formulacionPreguntas;
    }
    if (!mounted) return;
    setState(() {
      _brechaAbierta = brecha;
      _faseBrechaActiva = faseInicial;
      _escenaEnReproduccion = brecha == null ? _proximaEscenaPendiente() : null;
    });
  }

  Future<void> _alEstablecerFlag(String flag) async {
    await widget.repoFlags.activar(flag);
    if (!mounted) return;
    // No reconstruimos la pantalla con cada flag — la cinemática
    // sigue su curso. Sólo guardamos que ya está activo para que el
    // próximo arranque lo recuerde.
    _flagsActivos = {..._flagsActivos, flag};
  }

  Future<void> _alTerminarEscena(EscenaCinematica escena) async {
    // Cierre de escena: el flag de salida más los flags
    // institucionales declarados por los catálogos del juego.
    // Se mira primero Arco 1 y luego Arco 2 — los `flagDeSalida` son
    // únicos por escena, así que la unión es trivial: como mucho un
    // catálogo aporta entradas para una escena dada.
    final flagsACerrar = <String>{
      escena.flagDeSalida,
      ...?EscenasArco1.flagsDeCierrePorEscena[escena.flagDeSalida],
      ...?EscenasArco2.flagsDeCierrePorEscena[escena.flagDeSalida],
      ...?EscenasArco3.flagsDeCierrePorEscena[escena.flagDeSalida],
      ...?EscenasArco4.flagsDeCierrePorEscena[escena.flagDeSalida],
    };
    for (final flag in flagsACerrar) {
      await widget.repoFlags.activar(flag);
    }
    // Si el flag de salida tiene entrada de Cuaderno asociada, se
    // registra al cerrar la escena. Mantenemos el catálogo del
    // Cuaderno separado del catálogo de escenas para poder editar
    // textos de Cuaderno sin tocar el de escenas.
    final entrada = CatalogoCuaderno.entradasPorFlag[escena.flagDeSalida];
    if (entrada != null) {
      await widget.repoCuaderno.registrarEntrada(entrada.id);
    }
    if (!mounted) return;
    _flagsActivos = {..._flagsActivos, ...flagsACerrar};
    // Tras cerrar la escena puede haberse abierto una Brecha (caso
    // 1.1.2 → flag aralar_dolmen_alcanzado activa Brecha 1.1).
    final brecha = _proximaBrechaPendiente();
    FaseBrecha faseInicial = FaseBrecha.formulacionPreguntas;
    if (brecha != null) {
      faseInicial = await widget.repoEstadoBrecha.faseActiva(brecha.id) ??
          FaseBrecha.formulacionPreguntas;
    }
    if (!mounted) return;
    setState(() {
      _brechaAbierta = brecha;
      _faseBrechaActiva = faseInicial;
      _escenaEnReproduccion = brecha == null ? _proximaEscenaPendiente() : null;
    });
  }

  Future<void> _alAvanzarFaseBrecha() async {
    final brecha = _brechaAbierta;
    if (brecha == null) return;
    final indiceSiguiente = _faseBrechaActiva.index + 1;
    if (indiceSiguiente >= FaseBrecha.values.length) return;
    final siguiente = FaseBrecha.values[indiceSiguiente];
    await widget.repoEstadoBrecha.establecerFase(brecha.id, siguiente);
    if (!mounted) return;
    setState(() => _faseBrechaActiva = siguiente);
  }

  Future<void> _alCompletarBrecha() async {
    final brecha = _brechaAbierta;
    if (brecha == null) return;
    // El cierre de la Brecha sólo activa su propio flag de
    // completado. El flag `arco_1_completado` que dispara el
    // Mosaico se activa al cerrar la cinemática 1.4.4 ("Aprendiz
    // I") tras la 1.4.3 (gran Concilio). Hasta F8.4 lo activaba
    // 1.B (mosaico tras una sola Brecha); con las Brechas 1.2/1.3
    // y luego 1.4 entrando al catálogo (F8.4/F8.5/F8.6), el flag
    // se mueve a su sitio canónico — el Mosaico cierra el arco
    // entero, no una sola Estación.
    await widget.repoFlags.activar(brecha.flagDeCompletado);
    await widget.repoEstadoBrecha.borrar(brecha.id);
    if (!mounted) return;
    _flagsActivos = {..._flagsActivos, brecha.flagDeCompletado};
    setState(() {
      _brechaAbierta = null;
      _escenaEnReproduccion = _proximaEscenaPendiente();
    });
  }

  /// `true` si la Cronista debe ver la pantalla del Mosaico ahora
  /// — el arco está completado y el Mosaico aún no se ha entregado.
  bool get _mosaicoArco1Pendiente {
    if (!_idiomaElegido) return false;
    return _flagsActivos.contains(MosaicoArco1.flagDeArcoCompletado) &&
        !_flagsActivos.contains(MosaicoArco1.flagDeMosaicoEntregado);
  }

  /// `true` si la Cronista debe ver la pantalla del Mosaico del
  /// Arco 2 ahora — el arco está completado (cierre de 2.4.8) y el
  /// Mosaico aún no se ha entregado.
  bool get _mosaicoArco2Pendiente {
    if (!_idiomaElegido) return false;
    return _flagsActivos.contains(MosaicoArco2.flagDeArcoCompletado) &&
        !_flagsActivos.contains(MosaicoArco2.flagDeMosaicoEntregado);
  }

  /// `true` si la Cronista debe ver la pantalla del Mosaico del
  /// Arco 3 ahora — el arco está completado (cierre de 3.6.10 *El
  /// silencio segundo*) y el Mosaico aún no se ha entregado.
  bool get _mosaicoArco3Pendiente {
    if (!_idiomaElegido) return false;
    return _flagsActivos.contains(MosaicoArco3.flagDeArcoCompletado) &&
        !_flagsActivos.contains(MosaicoArco3.flagDeMosaicoEntregado);
  }

  /// `true` si la Cronista debe ver la pantalla del Mosaico del
  /// Arco 4 ahora — el último día de Archivo grande está cerrado
  /// (cinemática 4.G.3 *El silencio que vuelve*) y el Mosaico aún no
  /// se ha entregado. Tras la entrega encadena la cinemática
  /// `M4.entrega` (Andrés en el ático del Archivo) y después la
  /// víspera + ceremonia de graduación a Cronista (4.H.1, 4.H.2) y el
  /// cierre del MVP (4.Z).
  bool get _mosaicoArco4Pendiente {
    if (!_idiomaElegido) return false;
    return _flagsActivos.contains(MosaicoArco4.flagDeArcoCompletado) &&
        !_flagsActivos.contains(MosaicoArco4.flagDeMosaicoEntregado);
  }

  Future<void> _alEntregarMosaicoArco1() async {
    await widget.repoFlags.activar(MosaicoArco1.flagDeMosaicoEntregado);
    if (!mounted) return;
    _flagsActivos = {
      ..._flagsActivos,
      MosaicoArco1.flagDeMosaicoEntregado,
    };
    // Tras entregar, la cinemática `entregaDelMosaico` (Andrés +
    // Marina) queda pendiente — su `flagsRequeridos` referencia
    // `mosaico_arco_1_entregado`. Recalculamos la próxima escena
    // para que el orquestador la dispare antes del esqueleto.
    setState(() {
      _escenaEnReproduccion = _proximaEscenaPendiente();
    });
    // Sincronización opt-in: el Mosaico ya está en local (ese es el
    // único compromiso). Si hay token, se intenta archivar en el
    // backend. No bloquea ni avisa al jugador — un `SyncMosaicoError`
    // o `SyncMosaicoSinToken` no debe interrumpir el flujo narrativo
    // (cinemática 1.M1.entrega) que entra justo después.
    _sincronizarMosaicoEnSegundoPlano();
  }

  Future<void> _sincronizarMosaicoEnSegundoPlano() async {
    final resultado = await _sincronizadorMosaico.sincronizar();
    if (kDebugMode) {
      switch (resultado) {
        case SyncMosaicoSinToken():
          debugPrint('Mosaico Arco 1: sin token, queda local.');
        case SyncMosaicoExito():
          debugPrint('Mosaico Arco 1: archivado en backend.');
        case SyncMosaicoError(:final razon):
          debugPrint('Mosaico Arco 1: error de sync — $razon');
      }
    }
  }

  Future<void> _alEntregarMosaicoArco2() async {
    await widget.repoFlags.activar(MosaicoArco2.flagDeMosaicoEntregado);
    if (!mounted) return;
    _flagsActivos = {
      ..._flagsActivos,
      MosaicoArco2.flagDeMosaicoEntregado,
    };
    // Tras entregar, la cinemática `M2.entrega` (Andrés con
    // auriculares en el ático) queda pendiente — su `flagsRequeridos`
    // referencia `mosaico_arco_2_entregado`. Recalculamos la próxima
    // escena para que el orquestador la dispare antes del esqueleto;
    // luego encadenarán las dos cinemáticas del cierre del Arco 2
    // (2.Z.1 con Antonio y 2.Z.2 La grabación).
    setState(() {
      _escenaEnReproduccion = _proximaEscenaPendiente();
    });
    // Sincronización opt-in: el Mosaico ya está en local. Si hay
    // token, se intenta archivar en el backend con
    // `format='audio_guia_arco_2'`. No bloquea ni avisa al jugador
    // — un `SyncMosaicoError` o `SyncMosaicoSinToken` no debe
    // interrumpir el flujo narrativo (cinemática `M2.entrega`) que
    // entra justo después.
    _sincronizarMosaicoArco2EnSegundoPlano();
  }

  Future<void> _sincronizarMosaicoArco2EnSegundoPlano() async {
    final resultado = await _sincronizadorMosaicoArco2.sincronizar();
    if (kDebugMode) {
      switch (resultado) {
        case SyncMosaicoSinToken():
          debugPrint('Mosaico Arco 2: sin token, queda local.');
        case SyncMosaicoExito():
          debugPrint('Mosaico Arco 2: archivado en backend.');
        case SyncMosaicoError(:final razon):
          debugPrint('Mosaico Arco 2: error de sync — $razon');
      }
    }
  }

  Future<void> _alEntregarMosaicoArco3() async {
    await widget.repoFlags.activar(MosaicoArco3.flagDeMosaicoEntregado);
    if (!mounted) return;
    _flagsActivos = {
      ..._flagsActivos,
      MosaicoArco3.flagDeMosaicoEntregado,
    };
    // Tras entregar, la cinemática `M3.entrega` (Andrés en el ático
    // archivando la cartela) queda pendiente — su `flagsRequeridos`
    // referencia `mosaico_arco_3_entregado`. Recalculamos la próxima
    // escena para que el orquestador la dispare antes del esqueleto;
    // después encadenará la 3.Z (Aprendiz III en el patio del
    // Archivo) que cierra el Arco 3 entero.
    setState(() {
      _escenaEnReproduccion = _proximaEscenaPendiente();
    });
    // Sincronización opt-in con `format='ficha_museo_arco_3'`. No
    // bloquea ni avisa al jugador.
    _sincronizarMosaicoArco3EnSegundoPlano();
  }

  Future<void> _sincronizarMosaicoArco3EnSegundoPlano() async {
    final resultado = await _sincronizadorMosaicoArco3.sincronizar();
    if (kDebugMode) {
      switch (resultado) {
        case SyncMosaicoSinToken():
          debugPrint('Mosaico Arco 3: sin token, queda local.');
        case SyncMosaicoExito():
          debugPrint('Mosaico Arco 3: archivado en backend.');
        case SyncMosaicoError(:final razon):
          debugPrint('Mosaico Arco 3: error de sync — $razon');
      }
    }
  }

  Future<void> _alEntregarMosaicoArco4() async {
    await widget.repoFlags.activar(MosaicoArco4.flagDeMosaicoEntregado);
    if (!mounted) return;
    _flagsActivos = {
      ..._flagsActivos,
      MosaicoArco4.flagDeMosaicoEntregado,
    };
    // Tras entregar, la cinemática `M4.entrega` (Andrés en el ático
    // archivando la doble cartela) queda pendiente — su
    // `flagsRequeridos` referencia `mosaico_arco_4_entregado`.
    // Recalculamos la próxima escena para que el orquestador la
    // dispare antes del esqueleto; después encadenarán la víspera
    // (4.H.1), la ceremonia de graduación a Cronista (4.H.2) y el
    // cierre del MVP (4.Z).
    setState(() {
      _escenaEnReproduccion = _proximaEscenaPendiente();
    });
    // Sincronización opt-in con `format='doble_cartela_arco_4'`. No
    // bloquea ni avisa al jugador.
    _sincronizarMosaicoArco4EnSegundoPlano();
  }

  Future<void> _sincronizarMosaicoArco4EnSegundoPlano() async {
    final resultado = await _sincronizadorMosaicoArco4.sincronizar();
    if (kDebugMode) {
      switch (resultado) {
        case SyncMosaicoSinToken():
          debugPrint('Mosaico Arco 4: sin token, queda local.');
        case SyncMosaicoExito():
          debugPrint('Mosaico Arco 4: archivado en backend.');
        case SyncMosaicoError(:final razon):
          debugPrint('Mosaico Arco 4: error de sync — $razon');
      }
    }
  }

  /// Abre el Cuaderno como ruta superpuesta al estado actual del
  /// orquestador. Cruza el catálogo (fuente de verdad del contenido)
  /// con los IDs registrados en el repositorio (qué entradas ya
  /// están escritas) y respeta el orden del catálogo.
  Future<void> _alAbrirCuaderno() async {
    final idsRegistrados = await widget.repoCuaderno.idsRegistrados();
    final entradasVisibles = CatalogoCuaderno.todas
        .where((entrada) => idsRegistrados.contains(entrada.id))
        .toList(growable: false);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaCuaderno(entradas: entradasVisibles),
      ),
    );
  }

  /// Abre la pantalla de cuenta/login como ruta superpuesta. La
  /// pantalla decide su modo según haya o no sesión iniciada — si la
  /// hay, muestra el email actual y el botón "CERRAR SESIÓN"; si no,
  /// el formulario de login. La petición real al backend la hace
  /// [_intentarLogin]; el cierre de sesión, [_cerrarSesion].
  Future<void> _alAbrirSesion() async {
    if (!mounted) return;
    final emailActual =
        _sesionIniciada ? await widget.repoCuenta.cargarEmail() : null;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaLogin(
          alIntentarLogin: _intentarLogin,
          emailActual: emailActual,
          alCerrarSesion: _sesionIniciada ? _cerrarSesion : null,
        ),
      ),
    );
    // Tras volver de la pantalla, el token puede haber cambiado —
    // recargamos la marca de sesión iniciada para refrescar el botón
    // del esqueleto. No tocamos flags ni recalculamos la próxima
    // escena: el login es opt-in y no afecta al curso narrativo.
    final token = await widget.repoCuenta.cargarToken();
    if (!mounted) return;
    setState(() {
      _sesionIniciada = token != null && token.isNotEmpty;
    });
  }

  /// Cierra la sesión del adulto borrando token y email persistidos.
  /// El progreso, los Mosaicos y el Cuaderno NO se tocan — viven en
  /// claves separadas y siguen disponibles para el próximo arranque.
  Future<void> _cerrarSesion() async {
    await widget.repoCuenta.cerrarSesion();
  }

  /// Abre el Menú principal — la única superficie de meta-navegación
  /// del esqueleto desde F2-24. Consolida los antiguos botones
  /// CUADERNO/SESIÓN/AJUSTES en un solo engranaje. Tras volver
  /// recargamos el estado completo del orquestador para reflejar lo
  /// que haya pasado (reset → vuelta a configuración inicial; cambio
  /// de idioma → la app se reconstruye al cambiar el `localeApp`).
  Future<void> _alAbrirMenu() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaMenu(
          alAbrirCuaderno: () {
            Navigator.of(context).pop();
            _alAbrirCuaderno();
          },
          alAbrirAvances: () {
            Navigator.of(context).pop();
            _alAbrirAvances();
          },
          alAbrirResumenes: () {
            Navigator.of(context).pop();
            _alAbrirResumenes();
          },
          alAbrirAtico: aticoAbierto(_flagsActivos)
              ? () {
                  Navigator.of(context).pop();
                  _alAbrirAtico();
                }
              : null,
          alAbrirCuenta: () {
            Navigator.of(context).pop();
            _alAbrirSesion();
          },
          alAbrirPerfiles: () {
            Navigator.of(context).pop();
            _alAbrirPerfiles();
          },
          alAbrirAjustesAudio: () {
            Navigator.of(context).pop();
            _alAbrirAjustesAudio();
          },
          escenasCortas: !_flagsActivos.contains(_flagEscenasEnteras),
          alCambiarEscenasCortas: _alCambiarEscenasCortas,
          nombrePerfilActivo: _nombrePerfilActivo,
          sesionIniciada: _sesionIniciada,
          alCambiarIdioma: (codigo) async {
            await widget.repoIdioma.guardar(codigo);
            localeAppLasVersiones.value = Locale(codigo);
          },
          idiomaActivo: localeAppLasVersiones.value?.languageCode,
          alResetearArchivo: _resetearArchivo,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _cargando = true);
    await _cargarEstadoInicial();
  }

  /// Abre la pantalla de Avances con el estado agregado del juego.
  Future<void> _alAbrirAvances() async {
    if (!mounted) return;
    final idsCuaderno = await widget.repoCuaderno.idsRegistrados();
    if (!mounted) return;
    final avances = calcularAvances(
      flagsActivos: _flagsActivos,
      idsCuadernoRegistrados: idsCuaderno,
      mosaicoArco1Entregado:
          _flagsActivos.contains('mosaico_arco_1_entregado'),
      mosaicoArco2Entregado:
          _flagsActivos.contains('mosaico_arco_2_entregado'),
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaAvances(avances: avances),
      ),
    );
  }

  /// Abre la pantalla de Resúmenes con los Mosaicos entregados y sus
  /// marcas tal como las dejó la Cronista.
  Future<void> _alCambiarEscenasCortas(bool cortas) async {
    if (cortas) {
      await widget.repoFlags.desactivar(_flagEscenasEnteras);
      _flagsActivos = {..._flagsActivos}..remove(_flagEscenasEnteras);
    } else {
      await widget.repoFlags.activar(_flagEscenasEnteras);
      _flagsActivos = {..._flagsActivos, _flagEscenasEnteras};
    }
    if (mounted) setState(() {});
  }

  Future<void> _alAbrirAtico() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaAtico(
          flagsActivos: _flagsActivos,
          registro: _registroMaestria,
        ),
      ),
    );
  }

  Future<void> _alAbrirResumenes() async {
    if (!mounted) return;
    final pantalla = await PantallaResumenes.cargandoDesde(
      repoMosaico: widget.repoMosaico,
      mosaicoArco1Entregado:
          _flagsActivos.contains('mosaico_arco_1_entregado'),
      mosaicoArco2Entregado:
          _flagsActivos.contains('mosaico_arco_2_entregado'),
    );
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => pantalla),
    );
  }

  /// Abre la pantalla de ajustes de audio. Estos ajustes son
  /// **por perfil** (cada Cronista tiene su modo silencio y sus
  /// volúmenes por capa). Al volver, el servicio sonoro relee las
  /// preferencias para aplicarlas.
  Future<void> _alAbrirAjustesAudio() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaAjustesAudio(repoAudio: widget.repoAudio),
      ),
    );
    await ServicioSonoroArchivo.instancia.cargarPreferenciasDelPerfil();
  }

  /// Abre la pantalla de gestión de perfiles. Tras volver, el
  /// orquestador recarga su estado por si hubo cambio de perfil
  /// activo (cada Cronista tiene su progreso aislado).
  Future<void> _alAbrirPerfiles() async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PantallaPerfiles(
          gestor: widget.gestorPerfiles,
          alCambiarAPerfil: _cambiarAPerfil,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _cargando = true);
    await _cargarEstadoInicial();
  }

  /// Cambia el perfil activo y re-despacha el orquestador desde el
  /// arranque. El nuevo perfil tiene su propio idioma elegido (o
  /// no), así que reaparece la `PantallaConfiguracionInicial` si la
  /// nueva Cronista todavía no eligió. El idioma de la app es
  /// global del dispositivo, así que **no** se borra el `Locale`;
  /// se recarga del repo por si el perfil destino tiene uno
  /// distinto guardado (en caso futuro de idioma por-perfil).
  Future<void> _cambiarAPerfil(String idPerfil) async {
    await widget.gestorPerfiles.cambiarAPerfil(idPerfil);
    await ServicioSonoroArchivo.instancia.cargarPreferenciasDelPerfil();
    if (!mounted) return;
    final codigo = await widget.repoIdioma.cargar();
    if (!mounted) return;
    localeAppLasVersiones.value =
        codigo != null ? Locale(codigo) : null;
    _flagsActivos = const {};
    _idiomaElegido = false;
    _escenaEnReproduccion = null;
    _brechaAbierta = null;
    _faseBrechaActiva = FaseBrecha.formulacionPreguntas;
    setState(() {
      _cargando = true;
    });
    Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    await _cargarEstadoInicial();
  }

  /// Borra todas las claves del namespace del juego y limpia el
  /// estado en memoria. Tras esto el orquestador re-despacha a la
  /// `PantallaConfiguracionInicial` igual que en el primer arranque
  /// del dispositivo. El `Locale` global vuelve a `null` para que la
  /// elección del idioma reaparezca como decisión real (no quede el
  /// idioma anterior aplicado al fondo).
  Future<void> _resetearArchivo() async {
    await widget.reseteoArchivo.borrarTodo();
    localeAppLasVersiones.value = null;
    if (!mounted) return;
    _flagsActivos = const {};
    _idiomaElegido = false;
    _sesionIniciada = false;
    setState(() {
      _brechaAbierta = null;
      _faseBrechaActiva = FaseBrecha.formulacionPreguntas;
      _escenaEnReproduccion = null;
    });
  }

  /// Llama al backend, persiste token y email en éxito, y devuelve
  /// `null` o un mensaje de error en castellano para que la
  /// `PantallaLogin` lo enseñe inline. La función NO toca el estado
  /// del orquestador — el refresco del flag `_sesionIniciada` lo
  /// hace [_alAbrirSesion] tras el `Navigator.pop` que dispara la
  /// pantalla en éxito.
  Future<String?> _intentarLogin(String email, String password) async {
    try {
      final respuesta = await _clienteApi.iniciarSesion(
        email: email,
        password: password,
      );
      await widget.repoCuenta.guardarToken(respuesta.token);
      await widget.repoCuenta.guardarEmail(email);
      return null;
    } on ExcepcionApi catch (e) {
      if (e.codigo == 401 || e.codigo == 403) {
        return 'Email o contraseña incorrectos.';
      }
      return 'No se pudo iniciar sesión (${e.codigo}). Inténtalo de nuevo.';
    } on TimeoutException {
      return 'Tiempo de espera agotado. Comprueba la conexión.';
    } on SocketException {
      return 'Sin conexión. Comprueba la red.';
    }
  }

  @override
  Widget build(BuildContext contexto) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: PaletaArchivo.fondoProfundo,
        body: SizedBox.expand(),
      );
    }
    if (!_idiomaElegido) {
      return PantallaConfiguracionInicial(alElegirIdioma: _alElegirIdioma);
    }
    final brecha = _brechaAbierta;
    if (brecha != null) {
      return PantallaBrecha(
        key: ValueKey('brecha-${brecha.id}-${_faseBrechaActiva.name}'),
        brecha: brecha,
        faseActiva: _faseBrechaActiva,
        alAvanzarFase: _alAvanzarFaseBrecha,
        alCompletarBrecha: _alCompletarBrecha,
        alAbrirMenu: _alAbrirMenu,
        repoPreguntas: widget.repoPreguntas,
        repoRecoleccion: widget.repoRecoleccion,
        repoEvaluacion: widget.repoEvaluacion,
        repoReconstruccion: widget.repoReconstruccion,
        registro: _registroMaestria,
      );
    }
    final escena = _escenaEnReproduccion;
    if (escena != null) {
      // Key por id de escena para que el StatefulWidget se reinicie
      // limpio al cambiar de escena. El menú principal está siempre
      // accesible vía engranaje arriba-derecha (F2-25) para que la
      // Cronista pueda salir o consultar el Cuaderno sin terminar
      // la cinemática primero.
      final corta = _flagsActivos.contains(_flagEscenasEnteras)
          ? null
          : EscenasCortas.para(escena.id);
      return PantallaCinematica(
        // La clave es el id de la escena (contrato con los tests del
        // orquestador). Cambiar «escenas cortas» a mitad de una escena
        // se nota desde la siguiente.
        key: ValueKey(escena.id),
        escena: corta ?? escena,
        escenaEntera: corta == null ? null : escena,
        alEstablecerFlag: _alEstablecerFlag,
        alTerminar: () => _alTerminarEscena(escena),
        alAbrirMenu: _alAbrirMenu,
      );
    }
    if (_mosaicoArco1Pendiente) {
      return PantallaMosaicoArco1(
        alEntregar: _alEntregarMosaicoArco1,
        repoMosaico: widget.repoMosaico,
        alAbrirMenu: _alAbrirMenu,
      );
    }
    if (_mosaicoArco2Pendiente) {
      return PantallaMosaicoArco2(
        alEntregar: _alEntregarMosaicoArco2,
        repoMosaico: widget.repoMosaico,
        alAbrirMenu: _alAbrirMenu,
      );
    }
    if (_mosaicoArco3Pendiente) {
      return PantallaMosaicoArco3(
        alEntregar: _alEntregarMosaicoArco3,
        repoMosaico: widget.repoMosaico,
        alAbrirMenu: _alAbrirMenu,
      );
    }
    if (_mosaicoArco4Pendiente) {
      return PantallaMosaicoArco4(
        alEntregar: _alEntregarMosaicoArco4,
        repoMosaico: widget.repoMosaico,
        alAbrirMenu: _alAbrirMenu,
      );
    }
    return PantallaEsqueleto(
      alAbrirMenu: _alAbrirMenu,
    );
  }
}
