import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      SnackBar(content: Text('Importadas $insertadas plantas.')),
    );
  }

  Future<void> _exportar() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await exportarPlantasACsv();
      if (!mounted) return;
      await Share.shareXFiles([XFile(fichero.path)], subject: 'Plantas exportadas');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar / exportar plantas')),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Importar CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Columnas esperadas: cultivo_id, variedad, latitud, longitud, etiqueta, finca, '
              'fecha_plantacion (YYYY-MM-DD), patron, notas. Solo cultivo_id, latitud y longitud son obligatorios.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.upload_file),
              onPressed: _seleccionarCsv,
              label: Text(_nombreFichero == null ? 'Seleccionar CSV' : 'Cambiar CSV ($_nombreFichero)'),
            ),
            if (_parseo != null) ...[
              const SizedBox(height: 16),
              _PreviewParseo(parseo: _parseo!),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                onPressed: _parseo!.filasValidas.isEmpty || _trabajando ? null : _confirmarImport,
                label: Text('Importar ${_parseo!.filasValidas.length} planta${_parseo!.filasValidas.length == 1 ? '' : 's'}'),
              ),
            ],
            const Divider(height: 32),
            const Text('Exportar CSV', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            const Text(
              'Genera un CSV con todas las plantas (incluidos puntos sueltos). Útil para hacer backup, '
              'editar en hoja de cálculo y reimportar, o pasar datos a otro dispositivo.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              onPressed: _trabajando ? null : _exportar,
              label: const Text('Exportar y compartir'),
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
            Text('Resumen del CSV', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text('Total de filas leídas: ${parseo.total}'),
            Text('  · Válidas: ${parseo.filasValidas.length}', style: const TextStyle(color: Colors.green)),
            Text('  · Con error: ${parseo.filasInvalidas.length}', style: TextStyle(color: parseo.filasInvalidas.isEmpty ? Colors.grey : Colors.red)),
            if (parseo.nombresFincasNuevas.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Fincas nuevas que se crearán:', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final n in parseo.nombresFincasNuevas) Text('  · $n'),
            ],
            if (parseo.filasInvalidas.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Filas con error:', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final inv in parseo.filasInvalidas.take(20))
                Text('  · Línea ${inv.numeroLinea}: ${inv.motivo}', style: const TextStyle(color: Colors.red)),
              if (parseo.filasInvalidas.length > 20)
                Text('  · …y ${parseo.filasInvalidas.length - 20} más', style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
