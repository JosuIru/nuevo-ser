import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_apicultor.dart';
import 'pantalla_backup.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_gestion_apiarios.dart';
import 'pantalla_terceros.dart';
import '../servicios/cliente_anthropic.dart';

/// Pantalla común de la clave de Anthropic con los textos de Larrea
/// Apícola (la usan Ajustes y el asistente).
Widget pantallaClaveAnthropicApicola() => PantallaClaveAnthropic(
      estado: estadoClaveAnthropicApicola,
      nombreApp: 'Larrea Apícola',
      titulo: SoleraL10n.t('identificacion_con_ia'),
      queIdentifica: SoleraL10n.t('api.ia_que_identifica'),
      descripcion: SoleraL10n.t('api.ia_descripcion_clave'),
      probarClave: probarClaveAnthropic,
    );

/// Pantalla agregadora de ajustes, ordenada por secciones: explotación,
/// IA, preferencias, datos y aplicación. Los libros y documentos están
/// en la pestaña Registros; los Apiarios, aquí y en el menú del mapa.
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
            title: Text(SoleraL10n.t('api.titular_explotacion')),
            subtitle: Text(SoleraL10n.t('api.titular_explotacion_ayuda')),
            onTap: () => _abrir(context, PantallaApicultor()),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('configuracion_fiscal')),
            subtitle: Text(SoleraL10n.t('api.regimen_irpf_iva_provisional')),
            onTap: () => _abrir(context, PantallaConfiguracionFiscal()),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text(SoleraL10n.t('api.clientes_y_proveedores')),
            subtitle: Text(SoleraL10n.t('api.terceros_ayuda')),
            onTap: () => _abrir(context, PantallaTerceros()),
          ),
          ListTile(
            leading: Icon(Icons.hub),
            title: Text(SoleraL10n.t('api.apiarios')),
            subtitle: Text(SoleraL10n.t('api.apiarios_ayuda')),
            onTap: () => _abrir(context, const PantallaGestionApiarios()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text(SoleraL10n.t('api.clave_anthropic_ayuda')),
            onTap: () => _abrir(context, pantallaClaveAnthropicApicola()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SelectorIdioma(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text(SoleraL10n.t('copia_de_seguridad')),
            subtitle: Text(SoleraL10n.t('api.copia_seguridad_ayuda')),
            onTap: () => _abrir(context, const PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text(SoleraL10n.t('api.version_instalada_y_ultima')),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _abrir(
              context,
              PantallaEstadoActualizaciones(
                config: configActualizacionesMonorepo('solera-apicola'),
                nombreApp: 'Larrea Apícola',
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(SoleraL10n.t('acerca_de')),
            subtitle: Text(SoleraL10n.t('api.acerca_de_ayuda')),
            onTap: () => _abrir(context, PantallaAcerca()),
          ),
        ],
      ),
    );
  }
}
