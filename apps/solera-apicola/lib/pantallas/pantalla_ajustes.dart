import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_apicultor.dart';
import 'pantalla_backup.dart';
import 'pantalla_facturas.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_gestion_apiarios.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_libro_rega.dart';
import 'pantalla_terceros.dart';

/// Pantalla agregadora de ajustes, ordenada por secciones: explotación,
/// registros y documentos, IA, preferencias, datos y aplicación.
/// El Libro REGA y los Apiarios siguen también en el menú del mapa.
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  void _abrir(BuildContext context, Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_explotacion')),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Titular de la explotación'),
            subtitle: Text('NIF, nº REGA, contacto y veterinario asesor'),
            onTap: () => _abrir(context, PantallaApicultor()),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('configuracion_fiscal')),
            subtitle: Text('Régimen IRPF + IVA · provisional'),
            onTap: () => _abrir(context, PantallaConfiguracionFiscal()),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text('Clientes y proveedores'),
            subtitle: Text('Terceros con NIF · alimentan el modelo 347'),
            onTap: () => _abrir(context, PantallaTerceros()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_registros')),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Libro REGA'),
            subtitle: Text('Registro oficial de la explotación en PDF'),
            onTap: () => _abrir(context, const PantallaLibroRega()),
          ),
          ListTile(
            leading: Icon(Icons.hub),
            title: Text('Apiarios'),
            subtitle: Text('Asentamientos y sus colmenas'),
            onTap: () => _abrir(context, const PantallaGestionApiarios()),
          ),
          ListTile(
            leading: Icon(Icons.receipt),
            title: Text(SoleraL10n.t('facturas')),
            subtitle: Text(SoleraL10n.t('emision_pdf_y_envio')),
            onTap: () => _abrir(context, PantallaFacturas()),
          ),
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text(SoleraL10n.t('libro_economico')),
            subtitle: Text('Ingresos, gastos y extracto anual · provisional'),
            onTap: () => _abrir(context, PantallaLibroEconomico()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text('Configura tu clave Anthropic (Claude vision)'),
            onTap: () => _abrir(context, PantallaClaveAnthropic()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SelectorIdioma(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Copia de seguridad'),
            subtitle: Text('Empaqueta BD + fotos como zip, y restaura'),
            onTap: () => _abrir(context, PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text('Versión instalada y última publicada'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _abrir(
              context,
              PantallaEstadoActualizaciones(
                config: configActualizacionesMonorepo('solera-apicola'),
                nombreApp: 'Solera Apícola',
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(SoleraL10n.t('acerca_de')),
            subtitle: Text('Versión, créditos, compromisos legales'),
            onTap: () => _abrir(context, PantallaAcerca()),
          ),
        ],
      ),
    );
  }
}
