import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_ajustes.dart';
import 'pantalla_hoy.dart';
import 'pantalla_lista_arboles.dart';
import 'pantalla_mapa.dart';
import 'pantalla_registros.dart';

/// Pestañas de la barra inferior, en su orden.
enum PestanaPrincipal { hoy, mapa, arboles, registros, ajustes }

/// Armazón de la app: barra inferior Hoy · Mapa · Árboles · Registros ·
/// Ajustes. Arranca en el Mapa, que es el uso principal del operario.
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  /// Pestaña con la que arranca la app.
  static const PestanaPrincipal pestanaInicial = PestanaPrincipal.mapa;

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indicePestana = PantallaPrincipal.pestanaInicial.index;

  /// Se dispara al cambiar de pestaña: el mapa y la lista releen la BD
  /// para recoger lo que se haya cambiado desde la otra.
  final ValueNotifier<int> _avisoRecargaDatos = ValueNotifier<int>(0);

  late final List<Widget> _pantallas = [
    const PantallaHoy(),
    PantallaMapa(avisoRecarga: _avisoRecargaDatos),
    PantallaListaArboles(avisoRecarga: _avisoRecargaDatos),
    const PantallaRegistros(),
    PantallaAjustes(),
  ];

  @override
  void dispose() {
    _avisoRecargaDatos.dispose();
    super.dispose();
  }

  void _seleccionarPestana(int indice) {
    if (indice == _indicePestana) return;
    setState(() => _indicePestana = indice);
    _avisoRecargaDatos.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indicePestana, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indicePestana,
        onDestinationSelected: _seleccionarPestana,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: SoleraL10n.t('arb.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: SoleraL10n.t('mapa'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.park_outlined),
            selectedIcon: const Icon(Icons.park),
            label: SoleraL10n.t('arb.arboles'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: SoleraL10n.t('arb.registros'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: SoleraL10n.t('ajustes'),
          ),
        ],
      ),
    );
  }
}
