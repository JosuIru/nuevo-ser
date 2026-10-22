import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_acerca.dart';
import 'pantalla_backup.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_cuaderno_mapa.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_facturas.dart';
import 'pantalla_fincas.dart';
import 'pantalla_importar_csv.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_reportes.dart';
import 'pantalla_terceros.dart';
import 'pantalla_titular.dart';
import 'pantalla_tracks.dart';

/// Ajustes ordenados por secciones, en el mismo orden que el resto de la
/// suite Solera: explotación, registros y documentos, inteligencia
/// artificial, preferencias, datos y aplicación.
class PantallaAjustes extends StatelessWidget {
  const PantallaAjustes({super.key});

  @override
  Widget build(BuildContext context) {
    void abrir(Widget Function() constructorPantalla) =>
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => constructorPantalla()),
        );

    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_explotacion')),
          _EntradaAjustes(
            icono: Icons.person_outline,
            titulo: 'Datos del titular',
            subtitulo: 'NIF, REGEPA, asesor, aplicador (para cuaderno MAPA)',
            alPulsar: () => abrir(() => PantallaTitular()),
          ),
          _EntradaAjustes(
            icono: Icons.agriculture,
            titulo: 'Fincas',
            subtitulo: 'Crear, renombrar y borrar fincas',
            alPulsar: () => abrir(() => PantallaFincas()),
          ),
          _EntradaAjustes(
            icono: Icons.account_balance,
            titulo: SoleraL10n.t('configuracion_fiscal'),
            subtitulo: 'Régimen IRPF + IVA · provisional',
            alPulsar: () => abrir(() => PantallaConfiguracionFiscal()),
          ),
          _EntradaAjustes(
            icono: Icons.contacts,
            titulo: 'Clientes y proveedores',
            subtitulo: 'Terceros con NIF · alimentan el modelo 347',
            alPulsar: () => abrir(() => PantallaTerceros()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_registros')),
          _EntradaAjustes(
            icono: Icons.bar_chart,
            titulo: 'Estadísticas',
            subtitulo: 'Plantas por cultivo, cosecha por campaña',
            alPulsar: () => abrir(() => const PantallaEstadisticas()),
          ),
          _EntradaAjustes(
            icono: Icons.timeline,
            titulo: 'Recorridos de inspección',
            subtitulo: 'Lista de tracks GPS grabados',
            alPulsar: () => abrir(() => PantallaTracks()),
          ),
          _EntradaAjustes(
            icono: Icons.upload_file,
            titulo: 'Importar / exportar plantas (CSV)',
            subtitulo: 'Alta masiva desde hoja de cálculo o backup completo',
            alPulsar: () => abrir(() => const PantallaImportarCsv()),
          ),
          _EntradaAjustes(
            icono: Icons.picture_as_pdf,
            titulo: 'Informe de campaña (PDF)',
            subtitulo: 'Generar y compartir PDF por finca y año',
            alPulsar: () => abrir(() => const PantallaReportes()),
          ),
          _EntradaAjustes(
            icono: Icons.description,
            titulo: 'Cuaderno de explotación digital (MAPA)',
            subtitulo: 'Genera PDF conforme RD 1311/2012 por finca y campaña',
            alPulsar: () => abrir(() => PantallaCuadernoMapa()),
          ),
          _EntradaAjustes(
            icono: Icons.receipt,
            titulo: SoleraL10n.t('facturas'),
            subtitulo: SoleraL10n.t('emision_pdf_y_envio'),
            alPulsar: () => abrir(() => PantallaFacturas()),
          ),
          _EntradaAjustes(
            icono: Icons.menu_book,
            titulo: SoleraL10n.t('libro_economico'),
            subtitulo: 'Ingresos, gastos y extracto anual · provisional',
            alPulsar: () => abrir(() => const PantallaLibroEconomico()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
          _EntradaAjustes(
            icono: Icons.psychology,
            titulo: SoleraL10n.t('identificacion_con_ia'),
            subtitulo: 'Configurar clave Anthropic para identificar plagas '
                'y enfermedades por foto',
            alPulsar: () => abrir(() => const PantallaClaveAnthropic()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SelectorIdioma(),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
          _EntradaAjustes(
            icono: Icons.archive,
            titulo: 'Backup y restauración',
            subtitulo: 'Empaquetar BD + fotos en zip o restaurar desde zip',
            alPulsar: () => abrir(() => PantallaBackup()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
          _EntradaAjustes(
            icono: Icons.system_update,
            titulo: SoleraL10n.t('comprobar_actualizaciones'),
            subtitulo: 'Versión instalada y última publicada',
            alPulsar: () => abrir(
              () => PantallaEstadoActualizaciones(
                config: configActualizacionesMonorepo('agro'),
                nombreApp: 'Solera',
              ),
            ),
          ),
          _EntradaAjustes(
            icono: Icons.info_outline,
            titulo: SoleraL10n.t('acerca_de'),
            alPulsar: () => abrir(() => const PantallaAcerca()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EntradaAjustes extends StatelessWidget {
  const _EntradaAjustes({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    required this.alPulsar,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: subtitulo == null ? null : Text(subtitulo!),
      trailing: const Icon(Icons.chevron_right),
      onTap: alPulsar,
    );
  }
}
