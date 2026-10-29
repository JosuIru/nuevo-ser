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
          CabeceraSeccionAjustes('Ayuntamiento'),
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
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text(SoleraL10n.t('identificacion_con_ia')),
            subtitle: Text('Configura tu clave Anthropic (Claude vision)'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaClaveAnthropic(
                  estado: estadoClaveAnthropic,
                  nombreApp: 'Larrea Arbolado Urbano',
                  titulo: SoleraL10n.t('identificacion_con_ia'),
                  queIdentifica: 'Identifica especies y plagas urbanas por foto',
                  descripcion:
                      'Larrea Arbolado Urbano puede usar Claude AI de Anthropic para analizar la foto que adjuntas a una incidencia y proponer un diagnóstico fitosanitario, severidad y manejo cultural. Si detecta una plaga de declaración obligatoria (picudo rojo, fuego bacteriano) o riesgo sanitario público (procesionaria, lagarta peluda) lo destaca con banner. Cuidado con la privacidad ciudadana: las fotos pueden capturar transeúntes; encuadra al árbol.',
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
            title: Text('Backup y restauración'),
            subtitle: Text('Empaqueta BD + fotos como zip'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaBackup()),
            ),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text(SoleraL10n.t('comprobar_actualizaciones')),
            subtitle: Text('Versión instalada y última publicada'),
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
