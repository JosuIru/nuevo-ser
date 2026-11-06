/// El canal en papel (`docs/04-concejo.md` §4.5), que es obligatorio: en un
/// pueblo mucha gente no usará la app y la decisión no puede quedarse sin
/// ella.
///
/// - **Hoja del asunto**: para el tablón del concejo, el bar o el
///   consultorio.
/// - **Papeletas** para recortar (o la hoja de objeciones, en
///   consentimiento).
/// - **Hoja de recuento**: para que dos personas de la mesa cuenten las
///   papeletas en papel y firmen antes de pasar las cifras a la app.
///
/// Los textos llegan ya traducidos ([AppLocalizations]); la letra es la del
/// core (Archivo), que tiene «€» y «—».
library;

import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show temaPdfSolera;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../l10n/app_localizations.dart';
import '../pantallas/textos_dominio.dart';
import 'piezas_pdf.dart';

/// Hoja del asunto, para colgar en el tablón.
Future<Uint8List> hojaDelAsunto({
  required String nombreEspacio,
  required Asunto asunto,
  required AppLocalizations textos,
}) async {
  final documento = pw.Document(theme: await temaPdfSolera());
  final reglas = asunto.reglas;
  documento.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    header: (_) => cabeceraPdf(nombreEspacio, textos.pdfHojaAsunto),
    build: (_) => [
      pw.SizedBox(height: 16),
      pw.Text(asunto.titulo,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFE6EFE7),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(textos.tipoDecision(asunto.tipoDecision),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(textos.explicaTipoDecision(asunto.tipoDecision)),
            if (asunto.compromisoPrevio.isNotEmpty)
              pw.Text('«${asunto.compromisoPrevio}»',
                  style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
      pw.SizedBox(height: 12),
      pw.Text(asunto.resumen, style: const pw.TextStyle(fontSize: 14)),
      if (asunto.texto.isNotEmpty)
        seccionPdf(textos.verTextoCompleto, [pw.Text(asunto.texto)]),
      seccionPdf(textos.seccionEntorno, [pw.Text(asunto.efectoEntorno)]),
      if (asunto.costeEuros != null)
        seccionPdf(
            textos.seccionCoste, [pw.Text(textos.euros(asunto.costeEuros!))]),
      seccionPdf(textos.seccionCalendario, [
        pw.Text(textos.calendarioDebate(textos.fecha(asunto.inicioDebate))),
        pw.Text(textos.calendarioDecision(textos.fecha(asunto.inicioDecision),
            textos.fecha(asunto.finDecision))),
      ]),
      seccionPdf(textos.seccionComoSeDecide, [
        for (final linea in comoSeDecide(asunto, textos)) pw.Text(linea),
        if (reglas.opciones.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          for (final opcion in reglas.opciones)
            pw.Bullet(
              text: opcion.costeEuros == null
                  ? opcion.texto
                  : '${opcion.texto} — ${textos.euros(opcion.costeEuros!)}',
            ),
        ],
      ]),
      seccionPdf(
          textos.pdfComoParticipar, [pw.Text(textos.pdfParticiparTexto)]),
    ],
  ));
  return documento.save();
}

pw.Widget _casilla() => pw.Container(
      width: 14,
      height: 14,
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
    );

pw.Widget _papeleta(
    String nombreEspacio, Asunto asunto, AppLocalizations textos) {
  final reglas = asunto.reglas;
  final casillas = switch (reglas.forma) {
    FormaDecision.votacion => [
        (textos.votoSi, null),
        (textos.votoNo, null),
        (textos.votoAbstencion, null),
      ],
    _ => [
        for (final opcion in reglas.opciones)
          (
            opcion.texto,
            opcion.costeEuros == null ? null : textos.euros(opcion.costeEuros!),
          ),
      ],
  };
  final instruccion = switch (reglas.forma) {
    FormaDecision.votacion => textos.pdfMarcaUna,
    FormaDecision.presupuesto =>
      textos.pdfMarcaPropuestas(textos.euros(reglas.bolsaEuros ?? 0)),
    _ => textos.pdfMarcaVarias,
  };
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(nombreEspacio,
            style: const pw.TextStyle(color: grisPdf, fontSize: 9)),
        pw.Text(asunto.titulo,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
        pw.SizedBox(height: 4),
        pw.Text(instruccion, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 6),
        for (final (texto, coste) in casillas)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3),
            child: pw.Row(children: [
              _casilla(),
              pw.SizedBox(width: 8),
              pw.Expanded(child: pw.Text(texto)),
              if (coste != null) pw.Text(coste),
            ]),
          ),
        pw.SizedBox(height: 6),
        pw.Text(
          reglas.esSecreta
              ? textos.pdfPapeletaSecreta
              : textos.pdfPapeletaNominal,
          style: const pw.TextStyle(fontSize: 9, color: grisPdf),
        ),
        if (!reglas.esSecreta) ...[
          pw.SizedBox(height: 8),
          pw.Text('${textos.pdfNombre}: ______________________________'),
        ],
      ],
    ),
  );
}

pw.Widget _lineaDeCorte(AppLocalizations textos) => pw.Row(children: [
      pw.Expanded(
        child: pw.Container(
          height: 0,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                  color: grisPdf, width: 0.5, style: pw.BorderStyle.dashed),
            ),
          ),
        ),
      ),
      pw.SizedBox(width: 6),
      pw.Text(textos.pdfRecorta,
          style: const pw.TextStyle(fontSize: 7, color: grisPdf)),
    ]);

/// Papeletas para recortar, tantas como quepan en [paginas] hojas A4. En
/// consentimiento no hay papeleta: sale la hoja de objeciones.
Future<Uint8List> papeletas({
  required String nombreEspacio,
  required Asunto asunto,
  required AppLocalizations textos,
  int paginas = 1,
}) async {
  final documento = pw.Document(theme: await temaPdfSolera());
  final reglas = asunto.reglas;
  if (reglas.forma == FormaDecision.consentimiento) {
    documento.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          cabeceraPdf(nombreEspacio, textos.pdfHojaObjeciones),
          pw.SizedBox(height: 12),
          pw.Text(asunto.titulo,
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(textos.pdfObjecionesTexto),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: grisPdf, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(3),
            },
            children: [
              pw.TableRow(children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(textos.pdfNombre,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(textos.pdfDanoYComoEvitarlo,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ]),
              for (var fila = 0; fila < 9; fila++)
                pw.TableRow(children: [
                  pw.SizedBox(height: 56),
                  pw.SizedBox(height: 56),
                ]),
            ],
          ),
        ],
      ),
    ));
    return documento.save();
  }

  // Cuantas más opciones, menos papeletas por hoja.
  final opciones =
      reglas.forma == FormaDecision.votacion ? 3 : reglas.opciones.length;
  final porPagina = opciones <= 3 ? 4 : (opciones <= 6 ? 3 : 2);
  for (var pagina = 0; pagina < paginas; pagina++) {
    documento.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      build: (_) => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < porPagina; i++) ...[
            _papeleta(nombreEspacio, asunto, textos),
            if (i < porPagina - 1) _lineaDeCorte(textos),
          ],
        ],
      ),
    ));
  }
  return documento.save();
}

/// Hoja para contar las papeletas en papel entre dos personas de la mesa.
Future<Uint8List> hojaDeRecuento({
  required String nombreEspacio,
  required Asunto asunto,
  required AppLocalizations textos,
}) async {
  final documento = pw.Document(theme: await temaPdfSolera());
  final reglas = asunto.reglas;
  final filas = reglas.forma == FormaDecision.votacion
      ? [textos.votoSi, textos.votoNo, textos.votoAbstencion]
      : [for (final opcion in reglas.opciones) opcion.texto];
  pw.Widget celda(String texto, {bool negrita = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(texto,
            style:
                negrita ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
      );
  pw.Widget firma() => pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 40),
            pw.Container(height: 0.5, color: PdfColors.black),
            pw.SizedBox(height: 2),
            pw.Text('${textos.pdfFirma} · ${textos.pdfNombre}',
                style: const pw.TextStyle(fontSize: 9, color: grisPdf)),
          ],
        ),
      );
  documento.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(40),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        cabeceraPdf(nombreEspacio, textos.pdfHojaRecuento),
        pw.SizedBox(height: 12),
        pw.Text(asunto.titulo,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        for (final linea in comoSeDecide(asunto, textos))
          pw.Text(linea, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 8),
        pw.Text(textos.pdfRecuentoTexto),
        pw.SizedBox(height: 12),
        if (reglas.forma != FormaDecision.consentimiento)
          pw.Table(
            border: pw.TableBorder.all(color: grisPdf, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(4),
              1: pw.FlexColumnWidth(1)
            },
            children: [
              pw.TableRow(children: [
                celda(textos.pdfOpcion, negrita: true),
                celda(textos.pdfMarcas, negrita: true),
              ]),
              for (final fila in filas)
                pw.TableRow(children: [celda(fila), celda('')]),
              pw.TableRow(children: [
                celda(textos.pdfPapeletasTotales, negrita: true),
                celda(''),
              ]),
              if (reglas.forma != FormaDecision.votacion)
                pw.TableRow(children: [celda(textos.pdfEnBlanco), celda('')]),
              pw.TableRow(
                  children: [celda(textos.pdfPersonasAnotadas), celda('')]),
            ],
          ),
        pw.SizedBox(height: 16),
        pw.Text('${textos.pdfFecha}: ____ / ____ / ________'),
        pw.SizedBox(height: 12),
        pw.Row(children: [firma(), pw.SizedBox(width: 24), firma()]),
      ],
    ),
  ));
  return documento.save();
}

/// La hoja que la mesa da a cada persona con la dirección del pueblo y su
/// código personal (`docs/04-concejo.md` §4.1).
Future<Uint8List> hojaDeCodigo({
  required String nombreEspacio,
  required String nombrePersona,
  required String direccion,
  required String codigo,
  required AppLocalizations textos,
}) async {
  final documento = pw.Document(theme: await temaPdfSolera());
  pw.Widget dato(String etiqueta, String valor, double tamano) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(etiqueta,
                style: const pw.TextStyle(color: grisPdf, fontSize: 11)),
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 4),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: verdePdf, width: 1.2),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(valor,
                  style: pw.TextStyle(
                      fontSize: tamano,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: tamano > 20 ? 2 : 0)),
            ),
          ],
        ),
      );
  documento.addPage(pw.Page(
    pageFormat: PdfPageFormat.a5,
    margin: const pw.EdgeInsets.all(32),
    build: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        cabeceraPdf(nombreEspacio, textos.pdfHojaCodigo),
        pw.SizedBox(height: 18),
        pw.Text(textos.pdfHolaPersona(nombrePersona),
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(textos.pdfCodigoTexto),
        pw.SizedBox(height: 16),
        dato(textos.campoDireccion, direccion, 13),
        dato(textos.campoCodigo, codigo, 26),
        pw.Spacer(),
        pw.Text(textos.pdfCodigoGuardalo,
            style: const pw.TextStyle(fontSize: 10, color: grisPdf)),
      ],
    ),
  ));
  return documento.save();
}
