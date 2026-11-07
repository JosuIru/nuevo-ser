// Larrea Monte — esqueleto generado por scripts/nueva_vertical.sh (2026-11-07).
//
//   main() → AppMonte → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy                época de peligro, trámites y plazos, plan del año
//     ├── Monte              rodales (mapa y contorno), árboles, incendios
//     ├── Plan               actuaciones previstas y ejecutadas
//     ├── Aprovechamientos   campaña y sorteos de leña vecinal
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_aprovechamientos.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_monte.dart';
import 'pantallas/pantalla_plan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppMonte());
}

class AppMonte extends StatelessWidget {
  const AppMonte({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Monte',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioMonte,
          crema: colorCremaMonte,
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
          PantallaMonte(),
          PantallaPlan(),
          PantallaAprovechamientos(),
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
            label: SoleraL10n.t('mont.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.forest_outlined),
            label: SoleraL10n.t('mont.monte'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_note_outlined),
            label: SoleraL10n.t('mont.plan'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.carpenter_outlined),
            label: SoleraL10n.t('mont.aprovechamientos_corto'),
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
