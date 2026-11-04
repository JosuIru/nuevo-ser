import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_campanias.dart';
import 'pantalla_cuaderno_pac.dart';
import 'pantalla_libro_aceite.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_lista_lotes.dart';

/// Registros y libros de la almazara y del olivar: el libro de
/// movimientos del aceite (AICA) con los lotes de los que sale, las
/// campañas de recolección, el cuaderno PAC y el libro económico.
class PantallaRegistros extends StatelessWidget {
  const PantallaRegistros({super.key});

  static const _colorIconos = Color(0xFF5C6B3A);
  static const _margenTarjetas =
      EdgeInsets.symmetric(horizontal: 16, vertical: 4);

  Widget _entradaQueAbre(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required WidgetBuilder construirPantalla,
  }) {
    return Card(
      margin: _margenTarjetas,
      child: ListTile(
        leading: Icon(icono, color: _colorIconos),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: construirPantalla)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.registros'))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('acei.aceite_y_almazara')),
          _entradaQueAbre(
            context,
            icono: Icons.menu_book,
            titulo: SoleraL10n.t('acei.libro_movimientos_aceite'),
            subtitulo: SoleraL10n.t('acei.registros_libro_aceite_sub'),
            construirPantalla: (_) => const PantallaLibroAceite(),
          ),
          _entradaQueAbre(
            context,
            icono: Icons.water_drop,
            titulo: SoleraL10n.t('acei.lotes_de_aceite'),
            subtitulo: SoleraL10n.t('acei.registros_lotes_sub'),
            construirPantalla: (_) => const PantallaListaLotes(),
          ),
          _entradaQueAbre(
            context,
            icono: Icons.local_fire_department,
            titulo: SoleraL10n.t('acei.campanias_de_recoleccion'),
            subtitulo: SoleraL10n.t('acei.registros_campanias_sub'),
            construirPantalla: (_) => const PantallaCampanias(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('acei.olivar_y_cuentas')),
          _entradaQueAbre(
            context,
            icono: Icons.picture_as_pdf,
            titulo: SoleraL10n.t('acei.cuaderno_pac_olivar'),
            subtitulo: SoleraL10n.t('acei.registros_cuaderno_sub'),
            construirPantalla: (_) => const PantallaCuadernoPac(),
          ),
          _entradaQueAbre(
            context,
            icono: Icons.book,
            titulo: SoleraL10n.t('acei.libro_economico_anual'),
            subtitulo: SoleraL10n.t('acei.registros_economico_sub'),
            construirPantalla: (_) => const PantallaLibroEconomico(),
          ),
        ],
      ),
    );
  }
}
