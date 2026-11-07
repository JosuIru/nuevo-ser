// Larrea Vivero — esqueleto generado por scripts/nueva_vertical.sh (2026-11-07).
//
//   main() → AppVivero → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy       primeros pasos, avisos y accesos (Ajustes y Cuaderno)
//     ├── Material  lotes de semilla, esquejes y plantones
//     ├── Bandejas  bandejas con QR y zonas
//     ├── Plantas   stock y partidas con su trazabilidad
//     └── Salidas   ventas y entregas con los datos del pasaporte

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_bandejas.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_material.dart';
import 'pantallas/pantalla_plantas.dart';
import 'pantallas/pantalla_salidas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppVivero());
}

class AppVivero extends StatelessWidget {
  const AppVivero({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Vivero',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioVivero,
          crema: colorCremaVivero,
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
          PantallaMaterial(),
          PantallaBandejas(),
          PantallaPlantas(),
          PantallaSalidas(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestanaActual,
        onDestinationSelected: (indice) =>
            setState(() => _pestanaActual = indice),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            label: SoleraL10n.t('vive.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grain_outlined),
            label: SoleraL10n.t('vive.material'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_on_outlined),
            label: SoleraL10n.t('vive.bandejas'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.spa_outlined),
            label: SoleraL10n.t('vive.plantas'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_shipping_outlined),
            label: SoleraL10n.t('vive.salidas'),
          ),
        ],
      ),
    );
  }
}
