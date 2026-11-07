/// La **convocatoria** de una asamblea en PDF, para el tablón, el bar o el
/// consultorio: día, hora, lugar y orden del día. De los puntos que son
/// asuntos de la app sale también su resumen, para llegar sabiendo de qué
/// se habla.
library;

import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show temaPdfSolera;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/asunto.dart';
import '../dominio/sesion.dart';
import '../l10n/app_localizations.dart';
import '../pantallas/textos_dominio.dart';
import 'piezas_pdf.dart';

Future<Uint8List> convocatoriaDeLaSesion({
  required String nombreEspacio,
  required Sesion sesion,
  required Asunto? Function(String uid) buscarAsunto,
  required AppLocalizations textos,
}) async {
  final documento = pw.Document(theme: await temaPdfSolera());
  documento.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (_) => cabeceraPdf(nombreEspacio, textos.pdfConvocatoria),
    build: (_) => [
      pw.SizedBox(height: 16),
      pw.Text(sesion.titulo,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      if (sesion.anulada) ...[
        pw.SizedBox(height: 8),
        pw.Text(textos.asambleaAnulada(sesion.motivoAnulacion),
            style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800)),
      ],
      pw.SizedBox(height: 12),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFE6EFE7),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(textos.fechaYHora(sesion.inicio),
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(sesion.lugar, style: const pw.TextStyle(fontSize: 16)),
          ],
        ),
      ),
      seccionPdf(textos.ordenDelDia, [
        for (final (indice, punto) in sesion.puntos.indexed) ...[
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text('${indice + 1}. ${punto.texto}',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          if (punto.asuntoUid != null && buscarAsunto(punto.asuntoUid!) != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16, top: 2),
              child: pw.Text(buscarAsunto(punto.asuntoUid!)!.resumen,
                  style: const pw.TextStyle(color: grisPdf)),
            ),
        ],
      ]),
      pw.SizedBox(height: 24),
      pw.Text(textos.pdfConvocatoriaPie,
          style: const pw.TextStyle(color: grisPdf)),
    ],
  ));
  return documento.save();
}
