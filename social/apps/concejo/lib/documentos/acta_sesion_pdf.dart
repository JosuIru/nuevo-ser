/// El **acta de una asamblea** en PDF: cuándo y dónde, quién vino (por
/// nombre la gente con app; la de sin app, contada), lo hablado en cada
/// punto del orden del día y dos huecos para firmar a mano.
///
/// No se firma en la app (como el acta de un asunto): es el papel que la
/// mesa imprime, firma y guarda con las demás actas.
library;

import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show temaPdfSolera;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/sesion.dart';
import '../l10n/app_localizations.dart';
import '../pantallas/textos_dominio.dart';
import 'piezas_pdf.dart';

Future<Uint8List> actaDeLaSesion({
  required String nombreEspacio,
  required Sesion sesion,
  required String Function(String personaUid) nombreDe,
  required DateTime ahora,
  required AppLocalizations textos,
}) async {
  final nombresConApp = [for (final uid in sesion.asistentesUids) nombreDe(uid)]
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  final documento = pw.Document(theme: await temaPdfSolera());
  documento.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (_) => cabeceraPdf(nombreEspacio, textos.pdfActaAsamblea),
    footer: (contexto) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(textos.pdfGenerada(textos.fechaConAnio(ahora)),
            style: const pw.TextStyle(fontSize: 8, color: grisPdf)),
        pw.Text('${contexto.pageNumber} / ${contexto.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: grisPdf)),
      ],
    ),
    build: (_) => [
      pw.SizedBox(height: 16),
      pw.Text(sesion.titulo,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Text(
          '${textos.fechaConAnio(sesion.inicio)}, '
          '${textos.hora(sesion.inicio)} · '
          '${sesion.lugar}',
          style: const pw.TextStyle(fontSize: 12)),
      if (sesion.convocadaPorUid.isNotEmpty)
        pw.Text(textos.pdfConvocadaPor(nombreDe(sesion.convocadaPorUid)),
            style: const pw.TextStyle(color: grisPdf)),
      seccionPdf(textos.asistencia, [
        pw.Text(textos.asistentesResumen(sesion.asistentes,
            sesion.asistentesUids.length, sesion.asistentesSinApp)),
        if (nombresConApp.isNotEmpty)
          pw.Text(textos.pdfConLaApp(nombresConApp.join(', ')),
              style: const pw.TextStyle(fontSize: 10, color: grisPdf)),
      ]),
      seccionPdf(textos.ordenDelDia, [
        for (final (indice, punto) in sesion.puntos.indexed)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${indice + 1}. ${punto.texto}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 14, top: 2),
                  child: punto.notas.isEmpty
                      ? pw.Text(textos.pdfSinNotas,
                          style: const pw.TextStyle(color: grisPdf))
                      : pw.Text(punto.notas),
                ),
              ],
            ),
          ),
      ]),
      seccionPdf(textos.pdfFirmas, [
        pw.Row(children: [
          pw.Expanded(child: _hueco(textos.pdfNombreYFirma)),
          pw.SizedBox(width: 24),
          pw.Expanded(child: _hueco(textos.pdfNombreYFirma)),
        ]),
      ]),
      pw.SizedBox(height: 16),
      pw.Text(textos.pdfActaAsambleaPie,
          style: const pw.TextStyle(fontSize: 9, color: grisPdf)),
    ],
  ));
  return documento.save();
}

pw.Widget _hueco(String pie) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 36),
        pw.Container(height: 0.5, color: PdfColors.black),
        pw.SizedBox(height: 2),
        pw.Text(pie, style: const pw.TextStyle(fontSize: 9, color: grisPdf)),
      ],
    );
