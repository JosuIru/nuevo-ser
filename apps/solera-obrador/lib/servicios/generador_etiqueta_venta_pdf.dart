import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/etiqueta_venta.dart';

/// Sello de la etiqueta de venta hasta que un técnico valide el formato
/// (tamaño de letra real, nombres de alérgenos, menciones). Lo vigila
/// test/sello_provisional_test.dart.
const String selloEtiquetaVenta = 'PROVISIONAL';

/// Hoja(s) A4 con [copias] etiquetas iguales en la rejilla de [formato].
/// La lógica (qué dice la etiqueta, dónde va cada celda) está en
/// `dominio/etiqueta_venta.dart`; aquí solo se dibuja.
Future<Uint8List> generarEtiquetaVentaPdf({
  required ContenidoEtiqueta contenido,
  required FormatoEtiqueta formato,
  required int copias,
  pw.ThemeData? tema,
}) async {
  final documento = pw.Document(theme: tema);
  final totalCopias = copias < 1 ? 1 : copias;
  final hojas = hojasNecesarias(totalCopias, formato);
  final esCartel = formato == FormatoEtiqueta.suelta;
  for (var hoja = 0; hoja < hojas; hoja++) {
    final primera = hoja * formato.porHoja;
    final ultima = (primera + formato.porHoja).clamp(0, totalCopias);
    documento.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Stack(
          children: [
            for (var indice = primera; indice < ultima; indice++)
              _celda(
                contenido,
                formato,
                celdaEtiqueta(indice, formato),
                esCartel,
              ),
          ],
        ),
      ),
    );
  }
  return documento.save();
}

pw.Widget _celda(
  ContenidoEtiqueta contenido,
  FormatoEtiqueta formato,
  CeldaEtiqueta celda,
  bool esCartel,
) {
  const mm = PdfPageFormat.mm;
  final letra = formato.tamanoLetraPt;
  final estilo = pw.TextStyle(fontSize: letra, lineSpacing: letra * 0.15);
  final negrita = estilo.copyWith(fontWeight: pw.FontWeight.bold);
  return pw.Positioned(
    left: celda.izquierdaMm * mm,
    top: celda.arribaMm * mm,
    child: pw.Container(
      width: celda.anchoMm * mm,
      height: celda.altoMm * mm,
      padding: const pw.EdgeInsets.all(3 * mm),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.grey400,
          width: esCartel ? 1 : 0.3,
        ),
      ),
      child: pw.Stack(
        children: [
          pw.ClipRect(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  contenido.denominacion,
                  style: negrita.copyWith(
                    fontSize: letra * (esCartel ? 2 : 1.4),
                  ),
                ),
                pw.SizedBox(height: letra * 0.3),
                for (final linea in contenido.lineas)
                  pw.RichText(
                    text: pw.TextSpan(
                      style: estilo,
                      children: [
                        if (linea.titulo != null)
                          pw.TextSpan(text: '${linea.titulo}: '),
                        for (final fragmento in linea.fragmentos)
                          pw.TextSpan(
                            text: fragmento.texto,
                            style: fragmento.destacado ? negrita : null,
                          ),
                      ],
                    ),
                  ),
                if (contenido.tablaNutricional.isNotEmpty) ...[
                  pw.SizedBox(height: letra * 0.3),
                  pw.Text(contenido.tituloNutricional ?? '', style: negrita),
                  pw.Table(
                    border: pw.TableBorder.all(width: 0.3),
                    children: [
                      for (final (nutriente, valor)
                          in contenido.tablaNutricional)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: pw.Text(nutriente, style: estilo),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: pw.Text(valor, style: estilo),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          pw.Positioned(
            right: 0,
            bottom: 0,
            child: pw.Text(
              selloEtiquetaVenta,
              style: estilo.copyWith(
                fontSize: letra * 0.8,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
