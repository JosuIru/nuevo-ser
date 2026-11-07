import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pendientes/pendientes.dart';

import 'lista_comprobacion.dart';

const PdfColor _colorAcento = PdfColor.fromInt(0xFF5B6B2E);
const PdfColor _colorSuave = PdfColor.fromInt(0xFF6B665D);
const PdfColor _colorBorde = PdfColor.fromInt(0xFFD9D3C6);

/// Máximo de líneas del cuerpo de un bloqueo que se imprimen: el resto se
/// consulta en el archivo (la ruta va impresa).
const int _maximoLineasCuerpo = 14;

/// PDF A4 con una sección por responsable, casillas para marcar a mano y
/// hueco para la firma. [directorioFuentes] contiene Archivo-Regular.ttf y
/// Archivo-Bold.ttf (las de `nuevo_ser_core/assets/fuentes`): Helvetica no
/// tiene «—» ni «·».
Future<Uint8List> generarPdfListaComprobacion(ListaComprobacion lista,
    {required String directorioFuentes}) async {
  pw.Font fuente(String nombre) => pw.Font.ttf(ByteData.sublistView(
      File('$directorioFuentes/$nombre.ttf').readAsBytesSync()));
  final tema = pw.ThemeData.withFont(
      base: fuente('Archivo-Regular'), bold: fuente('Archivo-Bold'));
  final documento = pw.Document(
      theme: tema,
      title: 'Lista de comprobación — ${lista.vertical.nombreVisible}');
  final fecha = lista.generadaEn.toIso8601String().substring(0, 10);

  for (final seccion in lista.secciones) {
    documento.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(48, 44, 48, 44),
      header: (contexto) => pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 6),
        margin: const pw.EdgeInsets.only(bottom: 12),
        decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _colorBorde))),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('${lista.vertical.nombreVisible} · lista de comprobación',
                style: const pw.TextStyle(fontSize: 9, color: _colorSuave)),
            pw.Text('Generada el $fecha',
                style: const pw.TextStyle(fontSize: 9, color: _colorSuave)),
          ],
        ),
      ),
      footer: (contexto) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
            'Página ${contexto.pageNumber} de ${contexto.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _colorSuave)),
      ),
      build: (contexto) => [
        pw.Text('Para: ${seccion.responsable.nombreVisible}',
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold,
                color: _colorAcento)),
        pw.SizedBox(height: 6),
        pw.Text(
            'Marque cada punto cuando lo haya revisado. Si algo no es correcto, '
            'anótelo al lado: con eso basta para que lo corrijamos. Esta lista '
            'no tiene validez jurídica por sí sola; su firma indica que ha '
            'revisado el contenido.',
            style: const pw.TextStyle(fontSize: 10, color: _colorSuave)),
        if (seccion.catalogos.isNotEmpty) ...[
          _titulo('Catálogos de datos'),
          for (final catalogo in seccion.catalogos) _filaCatalogo(catalogo),
        ],
        if (seccion.sellos.isNotEmpty) ...[
          _titulo('Documentos que hoy salen con el sello PROVISIONAL'),
          for (final sello in seccion.sellos)
            _casilla(sello.ruta.split('/').last.replaceAll('.dart', ''),
                detalle: sello.ruta),
        ],
        if (seccion.bloqueos.isNotEmpty) ...[
          _titulo('Cuestiones abiertas'),
          for (final bloqueo in seccion.bloqueos) _filaBloqueo(bloqueo),
        ],
        pw.SizedBox(height: 28),
        _bloqueFirma(),
      ],
    ));
  }
  if (lista.secciones.isEmpty) {
    documento.addPage(pw.Page(
        build: (contexto) => pw.Text(
            'No hay nada pendiente para ${lista.vertical.nombreVisible}.')));
  }
  return documento.save();
}

pw.Widget _titulo(String texto) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
      child: pw.Text(texto,
          style: pw.TextStyle(fontSize: 12.5, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _cuadro() => pw.Container(
      width: 10,
      height: 10,
      margin: const pw.EdgeInsets.only(top: 2, right: 8),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
    );

pw.Widget _casilla(String texto, {String? detalle, List<pw.Widget>? extra}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cuadro(),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(texto, style: const pw.TextStyle(fontSize: 10.5)),
                if (detalle != null)
                  pw.Text(detalle,
                      style: const pw.TextStyle(
                          fontSize: 8.5, color: _colorSuave)),
                ...?extra,
              ],
            ),
          ),
        ],
      ),
    );

pw.Widget _filaCatalogo(EstadoCatalogo catalogo) {
  final porFirmar = catalogo.filas - catalogo.revisadasPorPersona;
  return _casilla(
    '${catalogo.nombreArchivo} — ${catalogo.filas} filas, '
    '$porFirmar por firmar',
    detalle: '${catalogo.ruta} · ${catalogo.revisadasPorFuentePublica} '
        'contrastadas con fuente documental, ${catalogo.sinRevisar} sin '
        'revisar, ${catalogo.revisadasPorPersona} ya firmadas',
  );
}

pw.Widget _filaBloqueo(Bloqueo bloqueo) {
  final lineas = quitarMarcasMarkdown(bloqueo.cuerpo)
      .split('\n')
      .where((linea) => linea.trim().isNotEmpty)
      .toList();
  final recortadas = lineas.take(_maximoLineasCuerpo).toList();
  if (lineas.length > recortadas.length) {
    recortadas.add('[… ${lineas.length - recortadas.length} líneas más en el '
        'archivo]');
  }
  return _casilla(
    bloqueo.titulo,
    detalle: 'apps/${bloqueo.aplicacion}/BLOQUEOS-PENDIENTES.md:${bloqueo.linea}',
    extra: [
      if (recortadas.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3),
          child: pw.Text(recortadas.join('\n'),
              style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
        ),
    ],
  );
}

pw.Widget _bloqueFirma() {
  pw.Widget linea(String etiqueta) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16),
        child: pw.Row(children: [
          pw.SizedBox(
              width: 90,
              child: pw.Text(etiqueta, style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(
              child: pw.Container(
                  height: 1, color: PdfColors.black)),
        ]),
      );
  return pw.Column(children: [
    linea('Nombre'),
    linea('Profesión / cargo'),
    linea('Fecha'),
    linea('Firma'),
  ]);
}

/// Texto plano para imprimir: sin `**`, `__` ni comillas invertidas, y con
/// las casillas `- [ ]` como guiones.
String quitarMarcasMarkdown(String texto) => texto
    .replaceAll(RegExp(r'\*\*|__|`'), '')
    .replaceAllMapped(
        RegExp(r'^(\s*)[-*]\s+\[[ xX]\]\s*', multiLine: true),
        (coincidencia) => '${coincidencia.group(1)}– ')
    .replaceAllMapped(RegExp(r'^(\s*)[-*]\s+', multiLine: true),
        (coincidencia) => '${coincidencia.group(1)}– ');
