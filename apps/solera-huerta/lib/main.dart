// Larrea Huerta — horticultura diversificada con cestas para grupos de consumo.
//
//   main() → AppHuerta → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy        siembras próximas, cestas de la semana, plazos, pendientes
//     ├── Parcelas   parcelas → bancales con su plan de rotación
//     ├── Cuaderno   siembras, cosechas y aplicaciones de insumos del año
//     ├── Cestas     reparto de la cosecha de la semana y entregas
//     │              (no sale en el perfil «huerto de casa»)
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'estado/aviso_helada_programado.dart';
import 'estado/perfil_huerta.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_cestas.dart';
import 'pantallas/pantalla_cuaderno.dart';
import 'pantallas/pantalla_hoy.dart';
import 'pantallas/pantalla_parcelas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  await cargarPerfilHuerta();
  await cargarAvisarHeladas();
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
  void initState() {
    super.initState();
    perfilHuerta.addListener(_alCambiarPerfil);
  }

  @override
  void dispose() {
    perfilHuerta.removeListener(_alCambiarPerfil);
    super.dispose();
  }

  /// El perfil se cambia en Ajustes, la última pestaña: se sigue en ella
  /// aunque aparezca o desaparezca Cestas.
  void _alCambiarPerfil() => setState(() => _pestanaActual =
      perfilHuerta.value == PerfilHuerta.profesional ? 4 : 3);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PerfilHuerta>(
      valueListenable: perfilHuerta,
      builder: (context, perfil, _) => _construir(perfil),
    );
  }

  Widget _construir(PerfilHuerta perfil) {
    final conCestas = perfil == PerfilHuerta.profesional;
    final pantallas = <Widget>[
      // Con clave: al aparecer o desaparecer Cestas, cada pantalla conserva
      // su estado (p. ej. lo escrito en Ajustes sin guardar).
      const PantallaHoy(key: ValueKey('hoy')),
      const PantallaParcelas(key: ValueKey('parcelas')),
      const PantallaCuaderno(key: ValueKey('cuaderno')),
      if (conCestas) const PantallaCestas(key: ValueKey('cestas')),
      const PantallaAjustes(key: ValueKey('ajustes')),
    ];
    final pestana = _pestanaActual.clamp(0, pantallas.length - 1);
    return Scaffold(
      body: IndexedStack(
        index: pestana,
        children: pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pestana,
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
          if (conCestas)
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
