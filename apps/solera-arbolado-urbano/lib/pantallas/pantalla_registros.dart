import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_facturas.dart';
import 'pantalla_generar_qr.dart';
import 'pantalla_informe_municipal.dart';

/// Pestaña Registros: los documentos que salen de la app (informe
/// municipal, chapas QR, facturas). Mismo estilo que Ajustes.
class PantallaRegistros extends StatelessWidget {
  const PantallaRegistros({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registros')),
      body: ListView(
        children: [
          const CabeceraSeccionAjustes('Informes'),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Informe municipal'),
            subtitle: const Text('Actuaciones de una campaña en PDF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaInformeMunicipal()),
            ),
          ),
          const CabeceraSeccionAjustes('Chapas'),
          ListTile(
            leading: const Icon(Icons.qr_code_2),
            title: const Text('Generar QR'),
            subtitle: const Text('Códigos QR para chapas de árboles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaGenerarQr()),
            ),
          ),
          const CabeceraSeccionAjustes('Facturación'),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: Text(SoleraL10n.t('facturas')),
            subtitle: Text(SoleraL10n.t('emision_pdf_y_envio')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaFacturas()),
            ),
          ),
        ],
      ),
    );
  }
}
