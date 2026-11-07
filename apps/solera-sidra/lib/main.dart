// Larrea Sagardoa — sidra natural y txakoli (Colección Nuevo Ser).
//
//   main() → AppSidra → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy        bodega, txotx de hoy y lo que queda por revisar
//     ├── Pomaradas  parcelas, variedades y tratamientos
//     ├── Bodega     kupelas; entradas de fruta, prensados y embotellados
//     ├── Txotx      temporada: qué kupela se abre y cuánto se sirve
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_bodega.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_pomaradas.dart';
import 'pantallas/pantalla_txotx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppSidra());
}

class AppSidra extends StatelessWidget {
  const AppSidra({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Sagardoa',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioSidra,
          crema: colorCremaSidra,
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
          PantallaPomaradas(),
          PantallaBodega(),
          PantallaTxotx(),
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
            label: SoleraL10n.t('sidr.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.park_outlined),
            label: SoleraL10n.t('sidr.pomaradas'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.propane_tank_outlined),
            label: SoleraL10n.t('sidr.bodega'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_bar_outlined),
            label: SoleraL10n.t('sidr.txotx'),
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
