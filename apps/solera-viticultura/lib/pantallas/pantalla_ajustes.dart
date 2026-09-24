import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_backup.dart';
import 'pantalla_facturas.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_terceros.dart';
import 'pantalla_titular.dart';

/// Pantalla agregadora de ajustes. Reúne todos los puntos de
/// configuración (titular, IA, backup, acerca) en una lista limpia.
/// El menú overflow del mapa redirige aquí en lugar de abrir cada uno
/// como entrada propia, para que la cabecera del mapa no se llene
/// según vaya creciendo el conjunto.
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Titular de la explotación'),
            subtitle: Text('Datos requeridos por el libro oficial PAC'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTitular()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('configuracion_fiscal')),
            subtitle: Text('Régimen IRPF + IVA · provisional'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => PantallaConfiguracionFiscal()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text('Clientes y proveedores'),
            subtitle: Text('Terceros con NIF · alimentan el modelo 347'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTerceros()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text(SoleraL10n.t('libro_economico')),
            subtitle: Text(
                'Ingresos, gastos y extracto anual · provisional'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaLibroEconomico()),
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
                  config: configActualizacionesMonorepo('solera-viticultura'),
                  nombreApp: 'Solera Viticultura',
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
