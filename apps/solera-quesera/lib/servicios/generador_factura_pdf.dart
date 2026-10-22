import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../modelos/factura.dart';

/// Genera una factura PDF conforme al Reglamento de Facturación
/// español (RD 1619/2012). Campos obligatorios:
/// - Nº de factura secuencial
/// - Fecha de emisión
/// - NIF + nombre + dirección del emisor
/// - NIF + nombre + dirección del receptor
/// - Base imponible, tipo de IVA, cuota, total
/// - Descripción de la operación
class GeneradorFacturaPdf {
  final _formatter = DateFormat('d/M/yyyy', 'es_ES');

  Future<pw.Document> generar({
    required Factura factura,
    required String emisorNombre,
    required String emisorNif,
    required String emisorDireccion,
    String emisorTelefono = '',
    String emisorEmail = '',
  }) async {
    final doc = pw.Document(theme: await temaPdfSolera());
    final lineas = jsonDecode(factura.lineasJson) as List<dynamic>;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          // ─── Cabecera ────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SOLERA QUESERA',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber,
                      )),
                  pw.Text('Factura Simplificada',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Nº ${factura.numeroFactura}',
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('Fecha: ${_formatter.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          factura.fechaEmisionMs))}'),
                  if (factura.fechaVencimientoMs != null)
                    pw.Text(
                        'Vencimiento: ${_formatter.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                factura.fechaVencimientoMs!))}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 16),

          // ─── Emisor ──────────────────────────────
          pw.Header(level: 1, child: pw.Text('Datos del emisor')),
          pw.Text(emisorNombre),
          pw.Text(emisorNif),
          pw.Text(emisorDireccion),
          if (emisorTelefono.isNotEmpty) pw.Text('Tel: $emisorTelefono'),
          if (emisorEmail.isNotEmpty) pw.Text('Email: $emisorEmail'),
          pw.SizedBox(height: 16),

          // ─── Receptor ────────────────────────────
          pw.Header(level: 1, child: pw.Text('Datos del receptor')),
          pw.Text(factura.clienteNombre),
          pw.Text(
              factura.clienteNif.isNotEmpty ? factura.clienteNif : 'Sin NIF'),
          pw.Text(factura.clienteDireccion.isNotEmpty
              ? factura.clienteDireccion
              : ''),
          pw.SizedBox(height: 24),

          // ─── Líneas de factura ────────────────────
          pw.Header(level: 1, child: pw.Text('Descripción')),
          if (lineas.isEmpty)
            pw.Paragraph(text: 'Sin líneas detalladas')
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerAlignment: pw.Alignment.centerLeft,
              border: pw.TableBorder.all(
                  color: PdfColors.grey300, width: 0.5),
              data: [
                <String>[
                  'Descripción', 'Cantidad', 'Precio', 'Importe'
                ],
                ...lineas.map((l) => [
                      (l['descripcion'] as String?) ?? '',
                      (l['cantidad'] as num?)?.toStringAsFixed(0) ?? '1',
                      '${(l['precioUnitario'] as num?)?.toStringAsFixed(2) ?? "0.00"}€',
                      '${(l['importe'] as num?)?.toStringAsFixed(2) ?? "0.00"}€',
                    ]),
              ],
            ),
          pw.SizedBox(height: 24),

          // ─── Totales ─────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      'Base imponible: ${factura.baseImponible.toStringAsFixed(2)}€'),
                  pw.Text('IVA ${factura.ivaPorcentaje.toStringAsFixed(0)}%: '
                      '${(factura.baseImponible * factura.ivaPorcentaje / 100).toStringAsFixed(2)}€'),
                  pw.Divider(),
                  pw.Text(
                    'TOTAL: ${factura.total.toStringAsFixed(2)}€',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),

          // ─── Pie ─────────────────────────────────
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${factura.estado == "pagada" ? "✅ PAGADA" : factura.estado == "vencida" ? "⚠️ VENCIDA" : "📄 EMITIDA"}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: factura.estado == 'pagada'
                      ? PdfColors.green
                      : factura.estado == 'vencida'
                          ? PdfColors.red
                          : PdfColors.blue,
                ),
              ),
              pw.Text(
                'Generado por Solera Quesera · ${_formatter.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Factura generada electrónicamente. Válida como justificante '
            'fiscal conforme al RD 1619/2012.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return doc;
  }
}
