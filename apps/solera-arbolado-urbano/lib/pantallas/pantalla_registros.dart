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
      appBar: AppBar(title: Text(SoleraL10n.t('arb.registros'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('arb.informes')),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(SoleraL10n.t('arb.informe_municipal')),
            subtitle: Text(SoleraL10n.t('arb.actuaciones_campana_pdf')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaInformeMunicipal()),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('arb.chapas')),
          ListTile(
            leading: const Icon(Icons.qr_code_2),
            title: Text(SoleraL10n.t('arb.generar_qr')),
            subtitle: Text(SoleraL10n.t('arb.codigos_qr_chapas')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaGenerarQr()),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('arb.facturacion')),
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
