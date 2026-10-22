import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../modelos/arbol.dart';

/// Genera una hoja imprimible con códigos QR de los árboles.
/// Cada página muestra el QR + identificador municipal + especie,
/// lista para plastificar y colocar como chapa en el tronco.
class GeneradorQrArbol {
  Future<pw.Document> generar({
    required List<Arbol> arboles,
    required String municipio,
    String? calidadImagen, // Sin uso directo; mantenemos compatibilidad
  }) async {
    final doc = pw.Document(theme: await temaPdfSolera());

    // Generar cada QR como imagen inline usando el widget PdfQrCode
    for (final arbol in arboles) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (ctx) => [
            pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('MUNICIPIO DE $municipio',
                      style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 200,
                    height: 200,
                    color: PdfColors.white,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: arbol.qrPayload.isNotEmpty
                          ? arbol.qrPayload
                          : arbol.identificadorMunicipal,
                      width: 200,
                      height: 200,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(arbol.identificadorMunicipal,
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Especie: ${arbol.especieId}',
                      style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 4),
                  if (arbol.alturaEstimadaMetros != null)
                    pw.Text(
                        'Altura: ${arbol.alturaEstimadaMetros!.toStringAsFixed(1)} m · '
                        'Perímetro: ${arbol.perimetroTroncoCm?.toStringAsFixed(0) ?? "?"} cm',
                        style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Text(
                      'Árbol inventariado · Para incidencias escanea el código',
                      style: const pw.TextStyle(
                          fontSize: 8, color: PdfColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return doc;
  }

  /// Vista previa/imprime directamente.
  Future<void> imprimir({
    required List<Arbol> arboles,
    required String municipio,
  }) async {
    final doc = await generar(
      arboles: arboles,
      municipio: municipio,
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'qrs_arbolado_$municipio.pdf',
    );
  }
}
