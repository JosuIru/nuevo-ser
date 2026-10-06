// Solera Zunbeltz — FZ-1: esqueleto con navegación principal e i18n es/eu.
//
// Arranque:
//   main() → AppSoleraZunbeltz → _Orquestador
//     ├── PantallaOnboarding (primer arranque: bienvenida + elección de idioma)
//     └── PantallaPrincipal (NavigationBar con IndexedStack)
//          ├── Hoy       — resumen del día
//          ├── Fincas    — mapa de infraestructuras y tareas (FZ-3)
//          ├── Cuaderno  — cuaderno ganadero (fase posterior)
//          └── Ajustes   — idioma y acerca de
//
// Detalle de fase y decisiones en `CLAUDE.md` del paquete.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'branding.dart';
import 'datos/base_datos.dart';
import 'estado/idioma_app.dart';
import 'estado/sesion_espacio.dart';
import 'estado/version_demo.dart';
import 'l10n/app_localizations.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_fincas.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_proyectos.dart';
import 'servicios/servicio_notificaciones.dart';
import 'servicios/sincronizacion_segundo_plano.dart';
import 'servicios/servicio_sincronizacion.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // En web sqflite va sobre SQLite wasm + IndexedDB; en escritorio
  // (Linux/Windows/macOS) necesita el backend ffi; en móvil usa el nativo
  // y esto no se toca.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await initializeDateFormatting();
  // Precarga el idioma elegido en sesiones previas antes del primer build,
  // para evitar un parpadeo con el idioma del sistema.
  await precargarIdiomaZunbeltz();
  // Persona conectada y sus permisos, guardados de la última sincronización.
  await precargarSesionEspacio();
  // Sin esperar: pedir permiso no debe retrasar el arranque.
  iniciarNotificaciones();
  programarSincronizacionSegundoPlano();
  if (esVersionDemo) {
    try {
      await BaseDatosSoleraZunbeltz().sembrarDemostracionSiVacia();
    } catch (_) {
      // Sin datos de ejemplo la demo sigue siendo usable: se puede cargar
      // a mano desde Ajustes.
    }
  }
  runApp(const AppSoleraZunbeltz());
}

class AppSoleraZunbeltz extends StatelessWidget {
  const AppSoleraZunbeltz({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeAppZunbeltz,
      builder: (contexto, localeActivo, _) {
        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitulo,
          debugShowCheckedModeBanner: false,
          theme: temaZunbeltz(),
          locale: localeActivo,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: localesSoportadosZunbeltz,
          // Si no se eligió idioma manualmente, respetamos el del
          // dispositivo cuando esté soportado; si no, castellano.
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
          home: const _Orquestador(),
          builder: esVersionDemo
              ? (contexto, hijo) => _ConFranjaDemo(hijo: hijo!)
              : null,
        );
      },
    );
  }
}

class _Orquestador extends StatefulWidget {
  const _Orquestador();

  @override
  State<_Orquestador> createState() => _OrquestadorState();
}

class _OrquestadorState extends State<_Orquestador> {
  bool? _mostrarOnboarding;

  @override
  void initState() {
    super.initState();
    _resolver();
  }

  Future<void> _resolver() async {
    final yaVisto = await PantallaOnboarding.yaVisto();
    if (mounted) setState(() => _mostrarOnboarding = !yaVisto);
  }

  @override
  Widget build(BuildContext context) {
    final mostrar = _mostrarOnboarding;
    if (mostrar == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (mostrar) {
      return PantallaOnboarding(
        alTerminar: () => setState(() => _mostrarOnboarding = false),
      );
    }
    return const PantallaPrincipal();
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal>
    with WidgetsBindingObserver {
  int _indice = 0;

  /// Con sincronización configurada, se sincroniza en silencio al abrir la
  /// app, al volver a ella y cada pocos minutos mientras está abierta.
  static const _intervaloSincronizacion = Duration(minutes: 10);
  Timer? _temporizadorSincronizacion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sincronizarEspacioEnSilencio();
    _temporizadorSincronizacion = Timer.periodic(
        _intervaloSincronizacion, (_) => sincronizarEspacioEnSilencio());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) sincronizarEspacioEnSilencio();
  }

  @override
  void dispose() {
    _temporizadorSincronizacion?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static const _pantallas = <Widget>[
    PantallaInicio(),
    PantallaFincas(),
    PantallaProyectos(),
    PantallaAjustes(),
  ];

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: textos.navHoy,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: textos.navFincas,
          ),
          NavigationDestination(
            icon: const Icon(Icons.science_outlined),
            selectedIcon: const Icon(Icons.science),
            label: textos.navProyectos,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: textos.navAjustes,
          ),
        ],
      ),
    );
  }
}

/// Franja fija arriba en la versión de demostración: recuerda que los datos
/// solo viven en este navegador y no se comparten con nadie.
class _ConFranjaDemo extends StatelessWidget {
  final Widget hijo;
  const _ConFranjaDemo({required this.hijo});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: tema.colorScheme.primary,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                AppLocalizations.of(context).demoFranja,
                textAlign: TextAlign.center,
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.colorScheme.onPrimary),
              ),
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: hijo,
          ),
        ),
      ],
    );
  }
}
