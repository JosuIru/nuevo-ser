import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'pantalla_cuaderno_mapa.dart';
import 'pantalla_estadisticas.dart';
import 'pantalla_facturas.dart';
import 'pantalla_importar_csv.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_reportes.dart';
import 'pantalla_tracks.dart';

/// Pestaña Registros: los documentos y libros de la explotación
/// (cuaderno MAPA, informes, facturas, libro económico, recorridos,
/// estadísticas e importación). Antes vivían dentro de Ajustes.
class PantallaRegistros extends StatelessWidget {
  const PantallaRegistros({super.key});

  @override
  Widget build(BuildContext context) {
    void abrir(Widget Function() constructorPantalla) =>
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => constructorPantalla()),
        );

    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('agro.registros'))),
      body: ListView(
        children: [
          CabeceraSeccionAjustes(SoleraL10n.t('agro.cuaderno_e_informes')),
          _EntradaRegistro(
            icono: Icons.description,
            titulo: SoleraL10n.t('agro.cuaderno_explotacion_mapa'),
            subtitulo: SoleraL10n.t('agro.cuaderno_explotacion_mapa_sub'),
            alPulsar: () => abrir(() => PantallaCuadernoMapa()),
          ),
          _EntradaRegistro(
            icono: Icons.picture_as_pdf,
            titulo: SoleraL10n.t('agro.informe_campana_pdf'),
            subtitulo: SoleraL10n.t('agro.informe_campana_sub'),
            alPulsar: () => abrir(() => const PantallaReportes()),
          ),
          _EntradaRegistro(
            icono: Icons.bar_chart,
            titulo: SoleraL10n.t('agro.estadisticas'),
            subtitulo: SoleraL10n.t('agro.estadisticas_sub'),
            alPulsar: () => abrir(() => const PantallaEstadisticas()),
          ),
          _EntradaRegistro(
            icono: Icons.timeline,
            titulo: SoleraL10n.t('agro.recorridos_inspeccion'),
            subtitulo: SoleraL10n.t('agro.recorridos_inspeccion_sub'),
            alPulsar: () => abrir(() => PantallaTracks()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('agro.economia')),
          _EntradaRegistro(
            icono: Icons.menu_book,
            titulo: SoleraL10n.t('libro_economico'),
            subtitulo: SoleraL10n.t('agro.libro_economico_sub'),
            alPulsar: () => abrir(() => const PantallaLibroEconomico()),
          ),
          _EntradaRegistro(
            icono: Icons.receipt,
            titulo: SoleraL10n.t('facturas'),
            subtitulo: SoleraL10n.t('emision_pdf_y_envio'),
            alPulsar: () => abrir(() => PantallaFacturas()),
          ),
          CabeceraSeccionAjustes(SoleraL10n.t('agro.importar_y_exportar')),
          _EntradaRegistro(
            icono: Icons.upload_file,
            titulo: SoleraL10n.t('agro.importar_exportar_plantas_csv'),
            subtitulo: SoleraL10n.t('agro.importar_exportar_plantas_csv_sub'),
            alPulsar: () => abrir(() => const PantallaImportarCsv()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EntradaRegistro extends StatelessWidget {
  const _EntradaRegistro({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.alPulsar,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: const Icon(Icons.chevron_right),
      onTap: alPulsar,
    );
  }
}
