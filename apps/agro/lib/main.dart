import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show cargarIdiomaSolera;
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_lista_plantas.dart';
import 'pantallas/pantalla_mapa.dart';
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_registros.dart';
import 'servicios/backup_servicio.dart';
import 'servicios/grabador_track.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Idioma elegido en Ajustes la última vez (si no, castellano).
  await cargarIdiomaSolera();
  // En Linux/Windows/macOS sqflite no tiene plugin nativo y necesita el
  // adapter FFI. En Android el plugin nativo manda y este bloque es
  // no-op (no entra al if). Sin esto la BD lanza
  // "databaseFactory not initialized" y todas las pantallas que tocan
  // BD fallan al cargarse.
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Si la app murió a mitad de restaurar una copia, deja la BD y las
  // fotos como estaban antes. Tiene que ir antes del primer acceso a la BD.
  try {
    await servicioCopiaSeguridadAgro.recuperarRestauracionInterrumpida();
  } catch (error) {
    debugPrint('No se pudo revisar la restauración interrumpida: $error');
  }
  // intl/DateFormat con locale `es_ES` (usado en lista de plantas y
  // ficha) requiere cargar los datos de localización antes del runApp.
  // Sin esto, cualquier build que toque DateFormat(..., 'es_ES') lanza
  // LocaleDataException y deja la pantalla en blanco.
  await initializeDateFormatting('es_ES', null);
  // Recupera recorridos GPS que quedaron grabándose si la app murió por
  // crash o kill OS. Sesiones con ≥2 puntos se consolidan automáticamente
  // como "Recorrido recuperado DD/MM HH:mm"; las de menos se descartan.
  unawaited(GrabadorTrack.instancia.consolidarSesionesPendientes());
  final yaCompletado = await PantallaOnboarding.yaCompletado();
  runApp(AplicacionSolera(mostrarOnboarding: !yaCompletado));
}

class AplicacionSolera extends StatelessWidget {
  final bool mostrarOnboarding;
  const AplicacionSolera({super.key, this.mostrarOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF558B2F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F1E8),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF558B2F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: mostrarOnboarding ? '/onboarding' : '/',
      routes: {
        '/': (_) => const PantallaPrincipal(),
        '/onboarding': (_) => const PantallaOnboarding(),
      },
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indice = 0;

  // IndexedStack mantiene el estado de cada pantalla al saltar entre
  // pestañas (no se pierde el zoom del mapa, los filtros aplicados, ni
  // la posición del scroll). Las pantallas que necesiten refrescar al
  // entrar lo hacen explícitamente en su initState.
  //
  // El acceso al meteo se ha movido a la pantalla Hoy (tarjeta resumen
  // que abre `PantallaMeteoAgro` en push) para reducir el número de
  // iconos del NavigationBar. La Guía de cultivos y plagas se abre
  // desde el icono de libro en la barra superior de Hoy.
  final _pantallas = const <Widget>[
    PantallaHoy(),
    PantallaMapa(),
    PantallaListaPlantas(),
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
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: 'Plantas',
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
