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
      appBar: AppBar(title: const Text('Registros')),
      body: ListView(
        children: [
          const CabeceraSeccionAjustes('Libros oficiales'),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Libro REGA'),
            subtitle: const Text('Registro oficial de la explotación en PDF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const PantallaLibroRega()),
          ),
          const CabeceraSeccionAjustes('Economía'),
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
            subtitle: const Text('Ingresos y gastos · provisional'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _abrir(context, const PantallaLibroEconomico()),
          ),
          ListTile(
            leading: const Icon(Icons.summarize),
            title: const Text('Extracto económico'),
            subtitle: const Text('Resumen anual en PDF · provisional'),
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
