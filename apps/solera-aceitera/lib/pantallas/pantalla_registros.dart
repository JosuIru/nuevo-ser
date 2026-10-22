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
      appBar: AppBar(title: const Text('Registros')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const CabeceraSeccionAjustes('Aceite y almazara'),
          _entradaQueAbre(
            context,
            icono: Icons.menu_book,
            titulo: 'Libro de movimientos del aceite',
            subtitulo: 'Entradas, salidas, mezclas y envasados por lote '
                '(AICA, RD 760/2021) · exportar PDF',
            construirPantalla: (_) => const PantallaLibroAceite(),
          ),
          _entradaQueAbre(
            context,
            icono: Icons.water_drop,
            titulo: 'Lotes de aceite',
            subtitulo: 'Cada lote con sus movimientos y analíticas · '
                'registrar una partida de aceituna',
            construirPantalla: (_) => const PantallaListaLotes(),
          ),
          _entradaQueAbre(
            context,
            icono: Icons.local_fire_department,
            titulo: 'Campañas de recolección',
            subtitulo: 'Abrir la campaña de este año y ver las anteriores',
            construirPantalla: (_) => const PantallaCampanias(),
          ),
          const CabeceraSeccionAjustes('Olivar y cuentas'),
          _entradaQueAbre(
            context,
            icono: Icons.picture_as_pdf,
            titulo: 'Cuaderno PAC olivar',
            subtitulo: 'Genera el PDF del Cuaderno de Explotación PAC '
                '(RD 1311/2012) · sello PROVISIONAL',
            construirPantalla: (_) => const PantallaCuadernoPac(),
          ),
          _entradaQueAbre(
            context,
            icono: Icons.book,
            titulo: 'Libro económico anual',
            subtitulo:
                'Ingresos / gastos / resumen + extracto PDF · PROVISIONAL',
            construirPantalla: (_) => const PantallaLibroEconomico(),
          ),
        ],
      ),
    );
  }
}
