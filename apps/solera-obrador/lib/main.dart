// Larrea Obrador — esqueleto generado por scripts/nueva_vertical.sh (2026-11-07).
//
//   main() → AppObrador → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy          qué hornear, controles del día, masa madre
//     ├── Recetas      fichas técnicas con alérgenos, coste y sal
//     ├── Ingredientes alérgenos, trazas, precio
//     ├── Autocontrol  cuaderno del mes
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_autocontrol.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_ingredientes.dart';
import 'pantallas/pantalla_recetas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppObrador());
}

class AppObrador extends StatelessWidget {
  const AppObrador({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Obrador',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioObrador,
          crema: colorCremaObrador,
        )),
        home: const PantallaPrincipal(),
      ),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _pestanaActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pestanaActual,
        children: const [
          PantallaHoy(),
          PantallaRecetas(),
          PantallaIngredientes(),
          PantallaAutocontrol(),
          PantallaAjustes(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestanaActual,
        onDestinationSelected: (indice) =>
            setState(() => _pestanaActual = indice),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            label: SoleraL10n.t('obra.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            label: SoleraL10n.t('obra.recetas'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            label: SoleraL10n.t('obra.ingredientes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check_outlined),
            label: SoleraL10n.t('obra.autocontrol'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: SoleraL10n.t('ajustes'),
          ),
        ],
      ),
    );
  }
}
