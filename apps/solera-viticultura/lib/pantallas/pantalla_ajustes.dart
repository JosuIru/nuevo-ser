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
            title: Text('Titular de la explotación'),
            subtitle: Text('Datos requeridos por el libro oficial PAC'),
            onTap: () => _abrir(context, () => PantallaTitular()),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('configuracion_fiscal')),
            subtitle: Text('Régimen IRPF + IVA · provisional'),
            onTap: () =>
                _abrir(context, () => PantallaConfiguracionFiscal()),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text('Clientes y proveedores'),
            subtitle: Text('Terceros con NIF · alimentan el modelo 347'),
            onTap: () => _abrir(context, () => PantallaTerceros()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text('Configura tu clave de Anthropic (Claude)'),
            onTap: () => _abrir(
              context,
              () => PantallaClaveAnthropic(
                estado: estadoClaveAnthropicViticultura,
                nombreApp: 'Larrea Viticultura',
                titulo: 'Identificación con IA',
                queIdentifica:
                    'Identifica mildiu, oídio, botritis y otras incidencias por foto',
                descripcion:
                    'Larrea Viticultura puede usar Claude, de Anthropic, para analizar la foto que adjuntas '
                    'a una incidencia y proponer un diagnóstico, severidad y recomendaciones de manejo '
                    'cultural. Con la misma clave funciona el asistente (chat) de la pantalla Hoy. '
                    'Tú pagas el uso a Anthropic con tu clave; sin clave la app funciona igual, '
                    'sin el botón de IA.',
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
                Text('Idioma / Language',
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(height: 8),
                SelectorIdioma(),
              ],
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup y restauración'),
            subtitle: Text('Empaqueta BD + fotos como zip'),
            onTap: () => _abrir(context, () => const PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text('Versión instalada y última publicada'),
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
            subtitle: Text('Versión, créditos, compromisos legales'),
            onTap: () => _abrir(context, () => PantallaAcerca()),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
