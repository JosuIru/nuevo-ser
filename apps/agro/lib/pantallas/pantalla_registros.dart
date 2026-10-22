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
      appBar: AppBar(title: const Text('Registros')),
      body: ListView(
        children: [
          const CabeceraSeccionAjustes('Cuaderno e informes'),
          _EntradaRegistro(
            icono: Icons.description,
            titulo: 'Cuaderno de explotación digital (MAPA)',
            subtitulo: 'Genera PDF conforme RD 1311/2012 por finca y campaña',
            alPulsar: () => abrir(() => PantallaCuadernoMapa()),
          ),
          _EntradaRegistro(
            icono: Icons.picture_as_pdf,
            titulo: 'Informe de campaña (PDF)',
            subtitulo: 'Generar y compartir PDF por finca y año',
            alPulsar: () => abrir(() => const PantallaReportes()),
          ),
          _EntradaRegistro(
            icono: Icons.bar_chart,
            titulo: 'Estadísticas',
            subtitulo: 'Plantas por cultivo, cosecha por campaña',
            alPulsar: () => abrir(() => const PantallaEstadisticas()),
          ),
          _EntradaRegistro(
            icono: Icons.timeline,
            titulo: 'Recorridos de inspección',
            subtitulo: 'Lista de tracks GPS grabados',
            alPulsar: () => abrir(() => PantallaTracks()),
          ),
          const CabeceraSeccionAjustes('Economía'),
          _EntradaRegistro(
            icono: Icons.menu_book,
            titulo: SoleraL10n.t('libro_economico'),
            subtitulo: 'Ingresos, gastos y extracto anual · provisional',
            alPulsar: () => abrir(() => const PantallaLibroEconomico()),
          ),
          _EntradaRegistro(
            icono: Icons.receipt,
            titulo: SoleraL10n.t('facturas'),
            subtitulo: SoleraL10n.t('emision_pdf_y_envio'),
            alPulsar: () => abrir(() => PantallaFacturas()),
          ),
          const CabeceraSeccionAjustes('Importar y exportar'),
          _EntradaRegistro(
            icono: Icons.upload_file,
            titulo: 'Importar / exportar plantas (CSV)',
            subtitulo: 'Alta masiva desde hoja de cálculo o exportación completa',
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
