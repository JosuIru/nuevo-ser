import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_apicultor.dart';
import 'pantalla_backup.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_gestion_apiarios.dart';
import 'pantalla_terceros.dart';
import '../servicios/cliente_anthropic.dart';

/// Pantalla común de la clave de Anthropic con los textos de Solera
/// Apícola (la usan Ajustes y el asistente).
Widget pantallaClaveAnthropicApicola() => PantallaClaveAnthropic(
      estado: estadoClaveAnthropicApicola,
      nombreApp: 'Solera Apícola',
      titulo: 'Identificación con IA',
      queIdentifica: 'Identifica varroa, nosema, loque y otras patologías por foto',
      descripcion:
          'Solera Apícola puede usar Claude AI de Anthropic para analizar la foto que adjuntas '
          'a una incidencia y proponer un diagnóstico, severidad y manejo cultural. Si detecta '
          'una patología de declaración obligatoria (loque americana, vespa velutina, escarabajo '
          'de las colmenas) lo destaca con banner rojo. La misma clave sirve para el asistente '
          '(chat) de la pantalla Hoy.',
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
          ListTile(
            leading: Icon(Icons.hub),
            title: Text('Apiarios'),
            subtitle: Text('Asentamientos, código SITRAN y sus colmenas'),
            onTap: () => _abrir(context, const PantallaGestionApiarios()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text('Clave de Anthropic para la foto y el asistente'),
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
            title: Text('Copia de seguridad'),
            subtitle: Text('Empaqueta BD + fotos como zip, y restaura'),
            onTap: () => _abrir(context, const PantallaBackup()),
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
