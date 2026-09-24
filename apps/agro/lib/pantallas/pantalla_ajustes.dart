import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'pantalla_facturas.dart';

import 'pantalla_backup.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_cuaderno_mapa.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_fincas.dart';
import 'pantalla_importar_csv.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_reportes.dart';
import 'pantalla_terceros.dart';
import 'pantalla_titular.dart';
import 'pantalla_tracks.dart';

class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Solera'),
            subtitle: Text('Versión 0.3.0 — gestor de fincas: frutales, trufas, olivar, pistacho, dehesa'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.agriculture),
            title: Text('Fincas'),
            subtitle: Text('Crear, renombrar y borrar fincas'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaFincas()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Estadísticas'),
            subtitle: Text('Plantas por cultivo, cosecha por campaña'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaEstadisticas()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.timeline),
            title: Text('Recorridos de inspección'),
            subtitle: Text('Lista de tracks GPS grabados'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTracks()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.upload_file),
            title: Text('Importar / exportar plantas (CSV)'),
            subtitle: Text('Alta masiva desde hoja de cálculo o backup completo'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaImportarCsv()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('Informe de campaña (PDF)'),
            subtitle: Text('Generar y compartir PDF por finca y año'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaReportes()),
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
            leading: Icon(Icons.archive),
            title: Text('Backup y restauración'),
            subtitle: Text('Empaquetar BD + fotos en zip o restaurar desde zip'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaBackup()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.system_update),
            title: Text('Actualizaciones'),
            subtitle: Text('Versión instalada y última publicada'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PantallaEstadoActualizaciones(
                  config: configActualizacionesMonorepo('agro'),
                  nombreApp: 'Solera',
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.cloud_off),
            title: Text('Sincronización en la nube'),
            subtitle: Text('Disponible en próximas versiones'),
            enabled: false,
          ),
          ListTile(
            leading: Icon(Icons.psychology),
            title: Text('Identificación con IA'),
            subtitle: Text('Configurar clave Anthropic para identificar plagas y enfermedades por foto'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaClaveAnthropic()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Datos del titular'),
            subtitle: Text('NIF, REGEPA, asesor, aplicador (para cuaderno MAPA)'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTitular()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Cuaderno de explotación digital (MAPA)'),
            subtitle: Text('Genera PDF conforme RD 1311/2012 por finca y campaña'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaCuadernoMapa()),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text(SoleraL10n.t('configuracion_fiscal')),
            subtitle: Text('Régimen IRPF + IVA · provisional'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaConfiguracionFiscal()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text('Clientes y proveedores'),
            subtitle: Text('Terceros con NIF · alimentan el modelo 347'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaTerceros()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text(SoleraL10n.t('libro_economico')),
            subtitle: Text('Ingresos, gastos y extracto anual · provisional'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PantallaLibroEconomico()),
            ),
          ),
        ],
      ),
    );
  }
}
