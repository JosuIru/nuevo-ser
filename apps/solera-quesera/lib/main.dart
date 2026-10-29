import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_lotes_y_cava.dart';
import 'pantallas/pantalla_mapa.dart';
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_registros.dart';
import 'servicios/backup_servicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Antes de tocar la BD: si una restauración de copia se quedó a medias
  // (la app murió mientras sustituía ficheros), se deshace aquí.
  try {
    await BackupServicioQuesera.instancia.recuperarRestauracionInterrumpida();
  } catch (error) {
    debugPrint('No se pudo comprobar la restauración interrumpida: $error');
  }
  // Idioma elegido en Ajustes la última vez (si no, castellano).
  await cargarIdiomaSolera();
  await initializeDateFormatting('es_ES', null);
  runApp(const SoleraQueseraApp());
}

class SoleraQueseraApp extends StatelessWidget {
  const SoleraQueseraApp({super.key});

  @override
  Widget build(BuildContext contexto) {
    final ColorScheme esquemaColores = ColorScheme.fromSeed(
      seedColor: const Color(0xFFC8923B), // dorado queso / corteza
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Larrea Quesera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: esquemaColores,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDF6E8), // crema leche
      ),
      home: _AppConIdioma(),
    );
  }
}

class _AppConIdioma extends StatelessWidget {
  const _AppConIdioma();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (_, __, ___) => const _Orquestador(),
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
  int _indice = 0;

  final _pantallas = <Widget>[
    PantallaHoy(),
    PantallaMapa(),
    const PantallaLotesYCava(),
    const PantallaRegistros(),
    PantallaAjustes(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: SoleraL10n.t('mapa'),
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Lotes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Registros',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: SoleraL10n.t('ajustes'),
          ),
        ],
      ),
    );
  }
}
