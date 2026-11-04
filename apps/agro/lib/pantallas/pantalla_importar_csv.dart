import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/csv_plantas.dart';

/// Pantalla "Importar/Exportar plantas". Flujo de importación:
/// 1) Usuario pulsa "Seleccionar CSV" → file_picker.
/// 2) Parseamos en memoria y mostramos preview (cuántas válidas, qué
///    fincas se crearán, errores por fila).
/// 3) Si el usuario confirma, persistimos.
///
/// Esto evita lo más frustrante en imports masivos: meter 1000 filas
/// y luego descubrir que 50 estaban mal y no saber cuáles. El preview
/// le da control antes de tocar la BD.
class PantallaImportarCsv extends StatefulWidget {
  const PantallaImportarCsv({super.key});

  @override
  State<PantallaImportarCsv> createState() => _PantallaImportarCsvState();
}

class _PantallaImportarCsvState extends State<PantallaImportarCsv> {
  ResultadoParseoCsv? _parseo;
  String? _nombreFichero;
  bool _trabajando = false;

  Future<void> _seleccionarCsv() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
    );
    if (resultado == null || resultado.files.isEmpty) return;
    final ruta = resultado.files.first.path;
    if (ruta == null) return;
    final contenido = await File(ruta).readAsString();
    if (!mounted) return;
    setState(() {
      _parseo = parsearCsvPlantas(contenido);
      _nombreFichero = resultado.files.first.name;
    });
  }

  Future<void> _confirmarImport() async {
    final parseo = _parseo;
    if (parseo == null || parseo.filasValidas.isEmpty) return;
    setState(() => _trabajando = true);
    final insertadas = await importarPlantasDesdeParseo(parseo);
    if (!mounted) return;
    setState(() {
      _trabajando = false;
      _parseo = null;
      _nombreFichero = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(SoleraL10n.tf('agro.importadas_n_plantas', {'n': insertadas}))),
    );
  }

  Future<void> _exportar() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await exportarPlantasACsv();
      if (!mounted) return;
      await Share.shareXFiles([XFile(fichero.path)], subject: SoleraL10n.t('agro.plantas_exportadas'));
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('agro.importar_exportar_plantas'))),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(SoleraL10n.t('agro.importar_csv'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('agro.importar_csv_columnas'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.upload_file),
              onPressed: _seleccionarCsv,
              label: Text(_nombreFichero == null
                  ? SoleraL10n.t('agro.seleccionar_csv')
                  : SoleraL10n.tf('agro.cambiar_csv', {'fichero': _nombreFichero})),
            ),
            if (_parseo != null) ...[
              const SizedBox(height: 16),
              _PreviewParseo(parseo: _parseo!),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                onPressed: _parseo!.filasValidas.isEmpty || _trabajando ? null : _confirmarImport,
                label: Text(_parseo!.filasValidas.length == 1
                    ? SoleraL10n.t('agro.importar_una_planta')
                    : SoleraL10n.tf('agro.importar_n_plantas', {'n': _parseo!.filasValidas.length})),
              ),
            ],
            const Divider(height: 32),
            Text(SoleraL10n.t('agro.exportar_csv'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              SoleraL10n.t('agro.exportar_csv_explicacion'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              onPressed: _trabajando ? null : _exportar,
              label: Text(SoleraL10n.t('agro.exportar_y_compartir')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewParseo extends StatelessWidget {
  final ResultadoParseoCsv parseo;
  const _PreviewParseo({required this.parseo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(SoleraL10n.t('agro.resumen_del_csv'), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(SoleraL10n.tf('agro.total_filas_leidas', {'n': parseo.total})),
            Text('  · ${SoleraL10n.tf('agro.filas_validas_n', {'n': parseo.filasValidas.length})}', style: const TextStyle(color: Colors.green)),
            Text('  · ${SoleraL10n.tf('agro.filas_con_error_n', {'n': parseo.filasInvalidas.length})}', style: TextStyle(color: parseo.filasInvalidas.isEmpty ? Colors.grey : Colors.red)),
            if (parseo.nombresFincasNuevas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(SoleraL10n.t('agro.fincas_nuevas_que_se_crearan'), style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final n in parseo.nombresFincasNuevas) Text('  · $n'),
            ],
            if (parseo.filasInvalidas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(SoleraL10n.t('agro.filas_con_error'), style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final inv in parseo.filasInvalidas.take(20))
                Text('  · ${SoleraL10n.tf('agro.linea_motivo', {'n': inv.numeroLinea, 'motivo': inv.motivo})}', style: const TextStyle(color: Colors.red)),
              if (parseo.filasInvalidas.length > 20)
                Text('  · ${SoleraL10n.tf('agro.y_n_mas', {'n': parseo.filasInvalidas.length - 20})}', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
