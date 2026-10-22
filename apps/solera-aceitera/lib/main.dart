// Solera Aceitera — F1-A3 con navegación principal completa.
//
// Arranque:
//   main() → AppSoleraAceitera → _Orquestador
//     ├── PantallaOnboarding (primer arranque, hasta tener titular+olivar)
//     └── PantallaPrincipal (NavigationBar con IndexedStack)
//          ├── Hoy        — dashboard de la campaña activa
//          ├── Mapa       — flutter_map con parcelas que tienen coords
//          ├── Parcelas   — listado + ficha + alta + tratamientos
//          ├── Lotes      — listado + ficha (con movimientos y analíticas)
//          ├── Libro      — vista cronológica del libro de movimientos
//          └── Ajustes    — titular, olivar y gestión de campañas
//
// Detalle de fase y diferenciadores en `CLAUDE.md` del paquete.

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show cargarIdiomaSolera;
import 'package:intl/date_symbol_data_local.dart';

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_libro_aceite.dart';
import 'pantallas/pantalla_lista_lotes.dart';
import 'pantallas/pantalla_lista_parcelas.dart';
import 'pantallas/pantalla_mapa.dart';
import 'pantallas/pantalla_onboarding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Idioma elegido en Ajustes la última vez (si no, castellano).
  await cargarIdiomaSolera();
  await initializeDateFormatting('es_ES', null);
  runApp(const AppSoleraAceitera());
}

class AppSoleraAceitera extends StatelessWidget {
  const AppSoleraAceitera({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solera Aceitera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrimarioAceitera,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: colorCremaAceitera,
      ),
      home: const _Orquestador(),
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

  final _pantallas = const <Widget>[
    PantallaHoy(),
    PantallaMapa(),
    PantallaListaParcelas(),
    PantallaListaLotes(),
    PantallaLibroAceite(),
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
            icon: Icon(Icons.park_outlined),
            selectedIcon: Icon(Icons.park),
            label: 'Parcelas',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Lotes',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Libro',
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
