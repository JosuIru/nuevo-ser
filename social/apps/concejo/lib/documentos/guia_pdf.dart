/// La guía de la app en papel, para repartir en la primera reunión: la
/// parte de todo el mundo y la de la mesa, con los mismos textos que la
/// pantalla.
library;

import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show temaPdfSolera;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../l10n/app_localizations.dart';
import '../pantallas/pantalla_guia.dart';
import 'piezas_pdf.dart';

Future<Uint8List> guiaEnPdf({
  required String nombreEspacio,
  required AppLocalizations textos,
}) async {
  final documento = pw.Document(theme: await temaPdfSolera());
  List<pw.Widget> parte(String titulo, List<ApartadoGuia> apartados) => [
        pw.SizedBox(height: 14),
        pw.Text(titulo,
            style: pw.TextStyle(
                fontSize: 16, fontWeight: pw.FontWeight.bold, color: verdePdf)),
        for (final apartado in apartados)
          seccionPdf(apartado.titulo, [
            for (final (indice, paso) in apartado.pasos.indexed)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(width: 16, child: pw.Text('${indice + 1}.')),
                    pw.Expanded(child: pw.Text(paso)),
                  ],
                ),
              ),
          ]),
      ];
  documento.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (_) => cabeceraPdf(nombreEspacio, textos.guiaTitulo),
    build: (_) => [
      ...parte(textos.guiaParaTodos, guiaParaTodos(textos)),
      ...parte(textos.guiaParaLaMesa, guiaParaLaMesa(textos)),
    ],
  ));
  return documento.save();
}
