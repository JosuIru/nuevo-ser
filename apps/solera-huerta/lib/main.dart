// Larrea Huerta — horticultura diversificada con cestas para grupos de consumo.
//
//   main() → AppHuerta → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy        siembras próximas, cestas de la semana, plazos, pendientes
//     ├── Parcelas   parcelas → bancales con su plan de rotación
//     ├── Cuaderno   siembras, cosechas y aplicaciones de insumos del año
//     ├── Cestas     reparto de la cosecha de la semana y entregas
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_cestas.dart';
import 'pantallas/pantalla_cuaderno.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_parcelas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const AppHuerta());
}

class AppHuerta extends StatelessWidget {
  const AppHuerta({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: 'Larrea Huerta',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimarioHuerta,
          crema: colorCremaHuerta,
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
          PantallaCestas(),
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
            label: SoleraL10n.t('huer.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            label: SoleraL10n.t('huer.parcelas'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            label: SoleraL10n.t('huer.cuaderno'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_basket_outlined),
            label: SoleraL10n.t('huer.cestas'),
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
