// Larrea Ganadera — ganadería extensiva pequeña y mixta, con el pasto en el
// centro.
//
//   main() → AppGanadera → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy        dónde está cada rebaño, avisos sanitarios, supresiones
//     ├── Rebaños    rebaños → animales, movimientos y manejo
//     ├── Pastos     piezas de pasto con su carga y el mapa
//     ├── Manejo     calendario sanitario y visitas
//     └── Ajustes    titular, explotación, documentos, economía, IA, ayuda

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_manejo.dart';
import 'pantallas/pantalla_pastos.dart';
import 'pantallas/pantalla_rebanos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppGanadera());
}

class AppGanadera extends StatelessWidget {
  const AppGanadera({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Ganadera',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioGanadera,
          crema: colorCremaGanadera,
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
          PantallaRebanos(),
          PantallaPastos(),
          PantallaManejo(),
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
            label: SoleraL10n.t('gana.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.pets_outlined),
            label: SoleraL10n.t('gana.rebanos'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            label: SoleraL10n.t('gana.pastos'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.medical_services_outlined),
            label: SoleraL10n.t('gana.manejo'),
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
