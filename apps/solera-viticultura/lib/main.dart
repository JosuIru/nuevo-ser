import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'datos/base_datos.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_lista_cepas.dart';
import 'pantallas/pantalla_mapa.dart';
// pantalla_meteo_viticultura.dart se invoca desde la tarjeta resumen de
// PantallaHoy (push) en lugar de ocupar una pestaña del NavigationBar.
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_registros.dart';
import 'servicios/backup_servicio.dart';

final _autoBackupViticultura = AutoBackup(
  nombreApp: 'solera_viticultura',
  obtenerRutaDb: () => BaseDatosSoleraViticultura.instancia.rutaBaseDatos(),
  estaVacia: () => BaseDatosSoleraViticultura.instancia.estaVacia(),
  reiniciarBd: () => BaseDatosSoleraViticultura.instancia.reiniciar(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Antes de cualquier acceso a la BD: si una restauración de copia se
  // quedó a medias (la app murió), se deshace aquí.
  try {
    await servicioCopiaSeguridadViticultura.recuperarRestauracionInterrumpida();
  } catch (error) {
    debugPrint('No se pudo revisar una restauración interrumpida: $error');
  }
  // Idioma elegido en Ajustes la última vez (si no, castellano).
  await cargarIdiomaSolera();
  await initializeDateFormatting('es_ES', null);
  unawaited(_autoBackupViticultura.restaurarSiProcede());
  runApp(const SoleraViticulturaApp());
}

class SoleraViticulturaApp extends StatefulWidget {
  const SoleraViticulturaApp({super.key});

  @override
  State<SoleraViticulturaApp> createState() => _SoleraViticulturaAppState();
}

class _SoleraViticulturaAppState extends State<SoleraViticulturaApp> with WidgetsBindingObserver {
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
      _autoBackupViticultura.respaldarAhora();
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final ColorScheme esquemaColores = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7D2A2A), // burdeos sobrio
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Larrea Viticultura',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: esquemaColores,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F0E6), // crema papel viejo
      ),
      home: const _Orquestador(),
    );
  }
}

/// Decide si mostrar el onboarding o ir directo al mapa, basándose
/// en el flag persistido `solera_viticultura.onboarding.visto`. Se
/// resuelve antes del primer frame para evitar parpadeo.
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
  Widget build(BuildContext contexto) {
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
  int _indice = 1;

  // Máximo cinco pestañas: Hoy · Mapa · Cepas · Registros · Ajustes.
  // Meteo (tarjeta resumen), la Guía y el asistente se abren desde Hoy.
  final _pantallas = const <Widget>[
    PantallaHoy(),
    PantallaMapa(),
    PantallaListaCepas(),
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
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass),
            label: 'Cepas',
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
