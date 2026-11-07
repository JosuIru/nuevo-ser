// Larrea Frutal — esqueleto generado por scripts/nueva_vertical.sh (2026-11-07).
//
//   main() → AppFrutal → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy       plazos de seguridad, colmenas, primeros pasos
//     ├── Parcelas  ficha con filas, polinización y seguimiento de plagas
//     ├── Cuaderno  tratamientos, abonados, riegos y heladas del año
//     ├── Cosecha   parte por parcela y campaña
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_cosecha.dart';
import 'pantallas/pantalla_cuaderno.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_parcelas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppFrutal());
}

class AppFrutal extends StatelessWidget {
  const AppFrutal({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Frutal',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioFrutal,
          crema: colorCremaFrutal,
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
          PantallaParcelas(),
          PantallaCuaderno(),
          PantallaCosecha(),
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
            label: SoleraL10n.t('frut.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.park_outlined),
            label: SoleraL10n.t('frut.parcelas'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            label: SoleraL10n.t('frut.cuaderno'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            label: SoleraL10n.t('frut.cosecha'),
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
