import 'package:flutter/material.dart';

import 'pantalla_cava.dart';
import 'pantalla_lista_lotes.dart';

/// Pestaña «Lotes» de la barra inferior: los lotes de producción y la
/// cava (piezas en afinado), con pestañas internas Lotes · Cava.
///
/// Cada una conserva su barra superior (filtro de lotes, recuento y
/// registro de la cava); las pestañas van debajo. Se usa un
/// IndexedStack en vez de TabBarView para que no se deslice la barra
/// superior entera y cada lista conserve su estado.
class PantallaLotesYCava extends StatefulWidget {
  const PantallaLotesYCava({super.key});

  @override
  State<PantallaLotesYCava> createState() => _PantallaLotesYCavaState();
}

class _PantallaLotesYCavaState extends State<PantallaLotesYCava>
    with SingleTickerProviderStateMixin {
  late final TabController _controladorPestanas =
      TabController(length: 2, vsync: this)
        ..addListener(() {
          if (mounted) setState(() {});
        });

  late final List<Widget> _pantallas = [
    PantallaListaLotes(barraPestanas: _barraPestanas()),
    PantallaCava(barraPestanas: _barraPestanas()),
  ];

  PreferredSizeWidget _barraPestanas() => TabBar(
        controller: _controladorPestanas,
        tabs: const [
          Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Lotes'),
          Tab(icon: Icon(Icons.kitchen_outlined), text: 'Cava'),
        ],
      );

  @override
  void dispose() {
    _controladorPestanas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _controladorPestanas.index,
      children: _pantallas,
    );
  }
}
