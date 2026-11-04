import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import '../estado/clave_ia.dart';
import 'pantalla_backup.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_terceros.dart';
import 'pantalla_titular.dart';

/// Pantalla agregadora de ajustes, agrupada por secciones (explotación,
/// IA, preferencias, datos, aplicación). Los libros y documentos (Libro
/// PAC, facturas, libro económico, extracto) están en la pestaña
/// Registros.
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  void _abrir(BuildContext context, Widget Function() constructorPantalla) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => constructorPantalla()),
    );
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
            title: Text(SoleraL10n.t('viti.titular_de_la_explotacion')),
            subtitle: Text(SoleraL10n.t('viti.titular_ayuda')),
            onTap: () => _abrir(context, () => PantallaTitular()),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('configuracion_fiscal')),
            subtitle: Text(SoleraL10n.t('viti.regimen_irpf_iva_provisional')),
            onTap: () =>
                _abrir(context, () => PantallaConfiguracionFiscal()),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text(SoleraL10n.t('viti.clientes_y_proveedores')),
            subtitle: Text(SoleraL10n.t('viti.terceros_ayuda_347')),
            onTap: () => _abrir(context, () => PantallaTerceros()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text(SoleraL10n.t('viti.configura_clave_anthropic')),
            onTap: () => _abrir(
              context,
              () => PantallaClaveAnthropic(
                estado: estadoClaveAnthropicViticultura,
                nombreApp: 'Larrea Viticultura',
                titulo: SoleraL10n.t('identificacion_con_ia'),
                queIdentifica: SoleraL10n.t('viti.ia_que_identifica'),
                descripcion: SoleraL10n.t('viti.ia_descripcion_clave'),
                probarClave: probarClaveAnthropicViticultura,
              ),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SoleraL10n.t('viti.idioma_language'),
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 8),
                SelectorIdioma(),
              ],
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text(SoleraL10n.t('copia_de_seguridad')),
            subtitle: Text(SoleraL10n.t('viti.backup_ayuda_zip')),
            onTap: () => _abrir(context, () => const PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text(SoleraL10n.t('viti.version_instalada_y_publicada')),
            trailing: Icon(Icons.chevron_right),
            onTap: () => _abrir(
              context,
              () => PantallaEstadoActualizaciones(
                config: configActualizacionesMonorepo('solera-viticultura'),
                nombreApp: 'Larrea Viticultura',
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(SoleraL10n.t('acerca_de')),
            subtitle: Text(SoleraL10n.t('viti.acerca_ayuda')),
            onTap: () => _abrir(context, () => PantallaAcerca()),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
