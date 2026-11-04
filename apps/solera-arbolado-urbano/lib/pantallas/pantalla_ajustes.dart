import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_ayuntamiento.dart';
import 'pantalla_backup.dart';
import '../servicios/cliente_anthropic.dart';
import 'pantalla_tecnicos.dart';

/// Pantalla agregadora de ajustes, por secciones como el resto de la
/// suite: Ayuntamiento (titular y técnicos) · Inteligencia artificial ·
/// Preferencias · Datos · Aplicación. Los documentos (informe municipal,
/// QR, facturas) están en la pestaña Registros.
class PantallaAjustes extends StatelessWidget {
  PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          // «Explotación» no encaja en un ayuntamiento: título literal.
          CabeceraSeccionAjustes(SoleraL10n.t('arb.ayuntamiento')),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('arb.ayuntamiento')),
            subtitle: Text(SoleraL10n.t('arb.datos_titular_informe')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaAyuntamiento()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text(SoleraL10n.t('arb.tecnicos_operarios')),
            subtitle: Text(SoleraL10n.t('arb.personas_autorizadas_firmar')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTecnicos()),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text(SoleraL10n.t('arb.configura_clave_anthropic')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaClaveAnthropic(
                  estado: estadoClaveAnthropic,
                  nombreApp: 'Larrea Arbolado Urbano',
                  titulo: SoleraL10n.t('identificacion_con_ia'),
                  queIdentifica: SoleraL10n.t('arb.ia_que_identifica'),
                  descripcion: SoleraL10n.t('arb.ia_descripcion'),
                  probarClave: probarClaveAnthropic,
                ),
              ),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SelectorIdioma(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text(SoleraL10n.t('copia_de_seguridad')),
            subtitle: Text(SoleraL10n.t('arb.empaqueta_bd_fotos_zip')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaBackup()),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text(SoleraL10n.t('arb.version_instalada_publicada')),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaEstadoActualizaciones(
                  config: configActualizacionesMonorepo('solera-arbolado-urbano'),
                  nombreApp: 'Larrea Arbolado Urbano',
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(SoleraL10n.t('acerca_de')),
            subtitle: Text(SoleraL10n.t('arb.version_creditos_compromisos')),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaAcerca()),
            ),
          ),
        ],
      ),
    );
  }
}
