import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_cava.dart';
import 'pantallas/pantalla_lista_lotes.dart';
import 'pantallas/pantalla_mapa.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_onboarding.dart';
import 'pantallas/pantalla_trazabilidad.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Solera Quesera',
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
    PantallaCava(),
    PantallaListaLotes(),
    PantallaTrazabilidad(),
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
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: SoleraL10n.t('hoy'),
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: SoleraL10n.t('mapa'),
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: SoleraL10n.t('cava'),
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: SoleraL10n.t('lotes'),
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: SoleraL10n.t('doc'),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: SoleraL10n.t('ajustes'),
          ),
        ],
      ),
    );
  }
}
