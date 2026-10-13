import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Piezas componibles para construir informes PDF con un estilo
/// visual consistente en toda la suite Solera (agro, viticultura,
/// apícola, arbolado) y en cualquier app del monorepo que necesite
/// generar informes.
///
/// El estilo (tamaños, colores grey, separadores) deriva del PDF
/// de campaña original de `apps/agro`. Mantenerlo coherente en una
/// sola pieza facilita aplicar branding (logo, paleta) en el
/// futuro sin tener que tocar cada app.

/// Cabecera del informe: título destacado a la izquierda, subtítulo
/// (típicamente un periodo o etiqueta) a la derecha en gris,
/// separados por una línea inferior. Pensada como `header` de un
/// `pw.MultiPage`.
///
/// Si se pasa [logo], va a la izquierda del título con 28 pt de alto.
pw.Widget cabeceraInformePdf({
  required String titulo,
  required String subtitulo,
  pw.ImageProvider? logo,
}) {
  final textoTitulo = pw.Text(
    titulo,
    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  );
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: 1)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logo == null)
          textoTitulo
        else
          pw.Row(children: [
            pw.Image(logo, height: 28),
            pw.SizedBox(width: 10),
            textoTitulo,
          ]),
        pw.SizedBox(width: 12),
        // El subtítulo cede espacio (y pasa a dos líneas) antes que pisar
        // el título.
        pw.Flexible(
          child: pw.Text(
            subtitulo,
            textAlign: pw.TextAlign.right,
            style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ),
        ),
      ],
    ),
  );
}

/// Footer "Página X de Y" alineado a la derecha, en gris pequeño.
/// Se usa como `footer` de un `pw.MultiPage` (recibe el contexto
/// para acceder al número de página actual y total).
pw.Widget footerPaginacionPdf(pw.Context ctx) {
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    child: pw.Text(
      'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
    ),
  );
}

/// Footer con una franja de logos (financiadores, entidades que apoyan)
/// encima de la paginación. Los logos se escalan a [altoLogo] y se
/// reparten en una o varias filas si no caben.
pw.Widget footerConLogosPdf(
  pw.Context ctx,
  List<pw.ImageProvider> logos, {
  double altoLogo = 18,
}) {
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
        decoration: const pw.BoxDecoration(
          border: pw.Border(
              top: pw.BorderSide(width: 0.5, color: PdfColors.grey400)),
        ),
        child: pw.Wrap(
          alignment: pw.WrapAlignment.center,
          crossAxisAlignment: pw.WrapCrossAlignment.center,
          spacing: 14,
          runSpacing: 4,
          children: [
            for (final logo in logos) pw.Image(logo, height: altoLogo),
          ],
        ),
      ),
      footerPaginacionPdf(ctx),
    ],
  );
}

/// Encabezado de sección: título destacado + separador inferior fino.
/// Pensado para insertar entre bloques del informe.
pw.Widget tituloSeccionPdf(String titulo) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      titulo,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    ),
  );
}

/// Tabla con estilo consistente: header gris, celdas pequeñas,
/// alineamiento por columna opcional (típicamente centrar las
/// numéricas a la derecha). Wrapper sobre `pw.TableHelper.fromTextArray`
/// que aplica el estilo de la suite — mantener la apariencia en un
/// único sitio facilita cambios futuros de branding.
pw.Widget tablaInformePdf({
  required List<String> headers,
  required List<List<String>> filas,
  Map<int, pw.Alignment>? alineamientoCeldas,
}) {
  return pw.TableHelper.fromTextArray(
    headers: headers,
    data: filas,
    cellStyle: const pw.TextStyle(fontSize: 10),
    headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
    cellAlignments: alineamientoCeldas ?? const {},
  );
}

/// Texto en gris para mostrar cuando una sección queda vacía
/// (p. ej. "Sin cosechas registradas en el periodo."). Mantiene el
/// tono mesurado del producto: sin emoji, sin fanfarria, sólo el
/// dato.
pw.Widget mensajeVacioPdf(String texto) {
  return pw.Text(
    texto,
    style: const pw.TextStyle(color: PdfColors.grey700),
  );
}
