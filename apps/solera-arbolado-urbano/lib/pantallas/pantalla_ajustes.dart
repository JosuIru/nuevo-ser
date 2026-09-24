import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_ayuntamiento.dart';
import 'pantalla_backup.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_facturas.dart';
import 'pantalla_generar_qr.dart';
import 'pantalla_tecnicos.dart';

/// Pantalla agregadora de ajustes. Reúne todos los puntos de
/// configuración (ayuntamiento, técnicos, IA, backup, acerca) en una
/// lista limpia.
class PantallaAjustes extends StatelessWidget {
  PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('Ayuntamiento'),
            subtitle: Text('Datos del titular para el informe municipal'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaAyuntamiento()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Técnicos / operarios'),
            subtitle: Text('Personas autorizadas a firmar partes'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTecnicos()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text('Identificación con IA'),
            subtitle: Text('Configura tu clave Anthropic (Claude vision)'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaClaveAnthropic()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.qr_code_2),
            title: Text('Generar QR'),
            subtitle: Text('Códigos QR para chapas de árboles'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaGenerarQr()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text(SoleraL10n.t('facturas')),
            subtitle: Text(SoleraL10n.t('emision_pdf_y_envio')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaFacturas()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup y restauración'),
            subtitle: Text('Empaqueta BD + fotos como zip'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaBackup()),
            ),
          ),
          Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Idioma / Language',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              SelectorIdioma(),
            ],
          ),
        ),
      ),
      Divider(height: 1),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text('Actualizaciones'),
            subtitle: Text('Versión instalada y última publicada'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaEstadoActualizaciones(
                  config: configActualizacionesMonorepo('solera-arbolado-urbano'),
                  nombreApp: 'Solera Arbolado Urbano',
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Acerca de'),
            subtitle: Text('Versión, créditos, compromisos legales'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaAcerca()),
            ),
          ),
        ],
      ),
    );
  }
}
