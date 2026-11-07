import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../modelos/bandeja.dart';

// Hoja de etiquetas con el QR de las bandejas, para plastificar y pegar en
// el lateral. Patrón de Arbolado urbano (`generador_qr_arbol.dart`): el QR
// lleva el código tal cual, que es lo que busca el escáner en la BD. Aquí
// van varias por página (3 × 7 en A4) en vez de una: las bandejas son
// muchas y pequeñas. No es un documento oficial.

/// Columnas y filas de etiquetas por página A4.
const int columnasEtiquetas = 3;
const int filasEtiquetas = 7;

/// Texto de cada etiqueta: el código y una línea (formato y zona).
class EtiquetaBandeja {
  const EtiquetaBandeja(this.codigoQr, this.linea);
  final String codigoQr;
  final String linea;
}

/// Reparte las etiquetas en páginas de [columnasEtiquetas] × [filasEtiquetas].
List<List<EtiquetaBandeja>> paginasDeEtiquetas(
    List<EtiquetaBandeja> etiquetas) {
  const porPagina = columnasEtiquetas * filasEtiquetas;
  return [
    for (var inicio = 0; inicio < etiquetas.length; inicio += porPagina)
      etiquetas.sublist(
          inicio,
          inicio + porPagina > etiquetas.length
              ? etiquetas.length
              : inicio + porPagina),
  ];
}

EtiquetaBandeja etiquetaDeBandeja(Bandeja bandeja,
        {String nombreZona = '', String nombreFormato = ''}) =>
    EtiquetaBandeja(
      bandeja.codigoQr,
      [
        nombreFormato,
        if (bandeja.numeroAlveolos > 0) '${bandeja.numeroAlveolos}',
        nombreZona,
        bandeja.ubicacion,
      ].where((parte) => parte.isNotEmpty).join(' · '),
    );

pw.Widget _etiqueta(EtiquetaBandeja etiqueta) => pw.Container(
      margin: const pw.EdgeInsets.all(3),
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey500, width: 0.5)),
      child: pw.Row(children: [
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: etiqueta.codigoQr,
          width: 70,
          height: 70,
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(etiqueta.codigoQr,
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              if (etiqueta.linea.isNotEmpty)
                pw.Text(etiqueta.linea, style: const pw.TextStyle(fontSize: 7)),
            ],
          ),
        ),
      ]),
    );

/// PDF A4 con las etiquetas QR de las bandejas.
Future<Uint8List> generarEtiquetasQrBandejas(List<EtiquetaBandeja> etiquetas,
    {pw.ThemeData? tema}) {
  final documento = pw.Document(theme: tema);
  for (final pagina in paginasDeEtiquetas(etiquetas)) {
    documento.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 20, marginRight: 20, marginTop: 24, marginBottom: 24),
      build: (_) => pw.GridView(
        crossAxisCount: columnasEtiquetas,
        childAspectRatio: 1.7,
        children: [for (final etiqueta in pagina) _etiqueta(etiqueta)],
      ),
    ));
  }
  return documento.save();
}
