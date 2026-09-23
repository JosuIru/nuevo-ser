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

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'branding.dart';
import 'estado/idioma_app.dart';
import 'estado/sesion_espacio.dart';
import 'l10n/app_localizations.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_fincas.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_proyectos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // En escritorio (Linux/Windows/macOS) sqflite necesita el backend ffi;
  // en móvil usa el nativo y esto no se toca.
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await initializeDateFormatting();
  // Precarga el idioma elegido en sesiones previas antes del primer build,
  // para evitar un parpadeo con el idioma del sistema.
  await precargarIdiomaZunbeltz();
  // Persona conectada y sus permisos, guardados de la última sincronización.
  await precargarSesionEspacio();
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

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indice = 0;

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
