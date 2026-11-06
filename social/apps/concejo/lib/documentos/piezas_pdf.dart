/// Piezas comunes de los PDF de Concejo (papel y acta).
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../l10n/app_localizations.dart';
import '../pantallas/textos_dominio.dart';

const grisPdf = PdfColor.fromInt(0xFF5F6B62);
const verdePdf = PdfColor.fromInt(0xFF3E6B48);

/// Nombre del espacio a la izquierda y el documento a la derecha.
pw.Widget cabeceraPdf(String nombreEspacio, String documento) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: verdePdf, width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(nombreEspacio,
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: verdePdf)),
          pw.Text(documento, style: const pw.TextStyle(color: grisPdf)),
        ],
      ),
    );

pw.Widget seccionPdf(String titulo, List<pw.Widget> contenido) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(titulo,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 3),
          ...contenido,
        ],
      ),
    );

/// Las reglas del asunto en líneas cortas.
List<String> comoSeDecide(Asunto asunto, AppLocalizations textos) {
  final reglas = asunto.reglas;
  return [
    textos.forma(reglas.forma),
    if (reglas.forma == FormaDecision.votacion) textos.mayoria(reglas.mayoria),
    if (reglas.forma == FormaDecision.presupuesto && reglas.bolsaEuros != null)
      textos.euros(reglas.bolsaEuros!),
    reglas.quorumPersonas > 0
        ? textos.quorum(reglas.quorumPersonas)
        : textos.sinQuorumRegla,
    if (reglas.forma != FormaDecision.consentimiento)
      reglas.esSecreta ? textos.votoSecreto : textos.votoNominal,
  ];
}
