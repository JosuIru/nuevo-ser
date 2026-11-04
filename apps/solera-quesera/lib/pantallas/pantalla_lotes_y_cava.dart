import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

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

  PreferredSizeWidget _barraPestanas() =>
      _BarraPestanasLotesYCava(controlador: _controladorPestanas);

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

/// Pestañas Lotes · Cava. Es un widget propio (y no un `TabBar` creado
/// una sola vez) para que los textos se vuelvan a pedir en cada build y
/// cambien al cambiar de idioma.
class _BarraPestanasLotesYCava extends StatelessWidget
    implements PreferredSizeWidget {
  const _BarraPestanasLotesYCava({required this.controlador});

  final TabController controlador;

  @override
  Size get preferredSize => _construirBarra().preferredSize;

  @override
  Widget build(BuildContext context) => _construirBarra();

  TabBar _construirBarra() => TabBar(
        controller: controlador,
        tabs: [
          Tab(icon: const Icon(Icons.inventory_2_outlined), text: SoleraL10n.t('ques.lotes')),
          Tab(icon: const Icon(Icons.kitchen_outlined), text: SoleraL10n.t('ques.cava')),
        ],
      );
}
