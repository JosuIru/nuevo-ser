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
      appBar: AppBar(title: Text(SoleraL10n.t('viti.registros'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('viti.cuaderno_oficial')),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(SoleraL10n.t('viti.libro_pac')),
            subtitle: Text(SoleraL10n.t('viti.cuaderno_explotacion_rd')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, () => const PantallaLibroPac()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('viti.economia')),
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
            subtitle: Text(SoleraL10n.t('viti.ingresos_y_gastos_provisional')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, () => const PantallaLibroEconomico()),
          ),
          ListTile(
            leading: const Icon(Icons.summarize),
            title: Text(SoleraL10n.t('viti.extracto_economico_anual')),
            subtitle: Text(SoleraL10n.t('viti.resumen_anual_pdf_provisional')),
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
