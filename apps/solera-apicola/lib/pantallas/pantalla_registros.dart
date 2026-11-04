import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_extracto_economico.dart';
import 'pantalla_facturas.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_libro_rega.dart';

/// Pestaña Registros: los libros y documentos de la explotación (libro
/// REGA, facturas, libro económico y extracto). Antes estaban en Ajustes.
class PantallaRegistros extends StatelessWidget {
  const PantallaRegistros({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('api.registros'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('api.libros_oficiales')),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(SoleraL10n.t('api.libro_rega')),
            subtitle: Text(SoleraL10n.t('api.libro_rega_ayuda')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const PantallaLibroRega()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('api.economia')),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(SoleraL10n.t('facturas')),
            subtitle: Text(SoleraL10n.t('emision_pdf_y_envio')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, PantallaFacturas()),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(SoleraL10n.t('libro_economico')),
            subtitle: Text(SoleraL10n.t('api.ingresos_y_gastos_provisional')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const PantallaLibroEconomico()),
          ),
          ListTile(
            leading: const Icon(Icons.summarize),
            title: Text(SoleraL10n.t('api.extracto_economico')),
            subtitle: Text(SoleraL10n.t('api.extracto_economico_ayuda')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(
              context,
              PantallaExtractoEconomico(anoInicial: DateTime.now().year),
            ),
          ),
        ],
      ),
    );
  }
}
