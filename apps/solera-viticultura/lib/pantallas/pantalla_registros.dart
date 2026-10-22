import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_extracto_economico.dart';
import 'pantalla_facturas.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_libro_pac.dart';

/// Pestaña «Registros»: los libros y documentos de la explotación
/// (cuaderno oficial PAC, facturas, libro económico y su extracto), en
/// un solo sitio. Antes vivían en Ajustes y en el menú del mapa; el
/// Libro PAC sigue también como atajo en el menú del mapa (misma
/// pantalla).
class PantallaRegistros extends StatelessWidget {
  const PantallaRegistros({super.key});

  void _abrir(BuildContext context, Widget Function() constructorPantalla) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => constructorPantalla()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registros')),
      body: ListView(
        children: [
          const CabeceraSeccionAjustes('Cuaderno oficial'),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Libro PAC'),
            subtitle: const Text('Cuaderno de explotación (RD 1311/2012)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, () => const PantallaLibroPac()),
          ),
          const CabeceraSeccionAjustes('Economía'),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(SoleraL10n.t('facturas')),
            subtitle: Text(SoleraL10n.t('emision_pdf_y_envio')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, () => PantallaFacturas()),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(SoleraL10n.t('libro_economico')),
            subtitle: const Text('Ingresos y gastos · provisional'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, () => const PantallaLibroEconomico()),
          ),
          ListTile(
            leading: const Icon(Icons.summarize),
            title: const Text('Extracto económico anual'),
            subtitle: const Text('Resumen del año en PDF · provisional'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(
              context,
              () => PantallaExtractoEconomico(anoInicial: DateTime.now().year),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
