import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'datos/base_datos.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_lista_colmenas.dart';
import 'pantallas/pantalla_mapa.dart';
// pantalla_meteo_apicola.dart se invoca desde la tarjeta resumen de
// PantallaHoy (push) en lugar de ocupar una pestaña del NavigationBar.
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_registros.dart';
import 'servicios/copia_seguridad_apicola.dart';

final _autoBackupApicola = AutoBackup(
  nombreApp: 'solera_apicola',
  obtenerRutaDb: () => BaseDatosSoleraApicola.instancia.rutaBaseDatos(),
  estaVacia: () => BaseDatosSoleraApicola.instancia.estaVacia(),
  reiniciarBd: () => BaseDatosSoleraApicola.instancia.reiniciar(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Idioma elegido en Ajustes la última vez (si no, castellano).
  await cargarIdiomaSolera();
  await initializeDateFormatting('es_ES', null);
  // Antes del primer acceso a la BD: si una restauración se quedó a
  // medias (la app murió mientras cambiaba ficheros), se deshace.
  try {
    await servicioCopiaSeguridadApicola.recuperarRestauracionInterrumpida();
  } catch (_) {
    // Si no se puede, la app arranca igual; la carpeta de trabajo sigue
    // ahí para el siguiente intento.
  }
  unawaited(_autoBackupApicola.restaurarSiProcede());
  runApp(const SoleraApicolaApp());
}

class SoleraApicolaApp extends StatefulWidget {
  const SoleraApicolaApp({super.key});

  @override
  State<SoleraApicolaApp> createState() => _SoleraApicolaAppState();
}

class _SoleraApicolaAppState extends State<SoleraApicolaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _autoBackupApicola.respaldarAhora();
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final ColorScheme esquemaColores = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB8860B), // ámbar miel oscuro
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Larrea Apícola',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: esquemaColores,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF6E8), // crema panal
      ),
      home: const _OrquestadorArranque(),
    );
  }
}

/// Decide qué pantalla mostrar al arrancar — onboarding la primera vez,
/// PantallaMapa a partir de la segunda. El flag se persiste en
/// SharedPreferences (`solera_apicola.onboarding.visto`).
class _OrquestadorArranque extends StatefulWidget {
  const _OrquestadorArranque();

  @override
  State<_OrquestadorArranque> createState() => _OrquestadorArranqueState();
}

class _OrquestadorArranqueState extends State<_OrquestadorArranque> {
  bool? _onboardingVisto;

  @override
  void initState() {
    super.initState();
    _comprobarOnboarding();
  }

  Future<void> _comprobarOnboarding() async {
    final visto = await PantallaOnboarding.yaVisto();
    if (mounted) setState(() => _onboardingVisto = visto);
  }

  @override
  Widget build(BuildContext context) {
    final visto = _onboardingVisto;
    if (visto == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!visto) {
      return PantallaOnboarding(
        alTerminar: () => setState(() => _onboardingVisto = true),
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
  int _indice = 1;

  // Meteo está en Hoy (tarjeta resumen que abre `PantallaMeteoApicola`)
  // y la Guía, en el icono de libro de la barra de Hoy: abajo quedan
  // Hoy · Mapa · Colmenas · Registros · Ajustes.
  final _pantallas = const <Widget>[
    PantallaHoy(),
    PantallaMapa(),
    PantallaListaColmenas(),
    PantallaRegistros(),
    PantallaAjustes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.hive_outlined),
            selectedIcon: Icon(Icons.hive),
            label: 'Colmenas',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Registros',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
