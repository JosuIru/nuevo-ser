import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'guardar_pdf.dart';
import 'widgets_pdf.dart';

/// Tabla declarativa para incluir en un informe periódico. La app
/// la rellena desde su BD; el módulo de informes la renderiza con
/// el estilo consistente de la suite.
class TablaInforme {
  final String titulo;
  final List<String> headers;
  final List<List<String>> filas;

  /// Texto a mostrar cuando `filas` está vacía. Si es `null`, la
  /// tabla simplemente no aparece en el PDF (sin sección, sin
  /// título, sin mensaje de vacío) — útil para tablas opcionales
  /// como "incidencias abiertas" que solo se incluyen si las hay.
  final String? mensajeSiVacia;

  /// Alineamiento por columna (índice → alineamiento). Pensado
  /// para alinear columnas numéricas a la derecha, típicamente.
  /// Si es `null`, todo a la izquierda por defecto.
  final Map<int, pw.Alignment>? alineamientoCeldas;

  TablaInforme({
    required this.titulo,
    required this.headers,
    required this.filas,
    this.mensajeSiVacia,
    this.alineamientoCeldas,
  });
}

/// Genera un PDF "informe periódico" con un layout estándar:
/// cabecera (título + subtítulo) + sección "Resumen" con bullets +
/// una o varias tablas + footer con paginación + guardado a
/// directorio temporal.
///
/// El layout cubre los informes de Solera (campaña por finca),
/// Solera Viticultura (libro PAC anual), Solera Apícola (libro
/// REGA), Solera Arbolado (informe de podas planificadas)...
/// Cada app construye sus listas de bullets y de tablas; el módulo
/// se encarga del estilo, la cabecera/footer y el guardado.
///
/// Si una `TablaInforme` tiene `filas` vacía y `mensajeSiVacia` no
/// es `null`, se renderiza la sección con el mensaje en gris. Si
/// `mensajeSiVacia` es `null` la sección se omite por completo.
Future<File> generarInformePeriodicoPdf({
  required String tituloCabecera,
  required String subtituloCabecera,
  required List<String> bulletsResumen,
  required List<TablaInforme> tablas,
  required String prefijoNombreFichero,
  String? operador,
  DateTime? fechaGeneracion,
  String? marcaAgua,
  pw.ThemeData? tema,
}) async {
  final documento = construirInformePeriodicoPdf(
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bulletsResumen,
    tablas: tablas,
    operador: operador,
    fechaGeneracion: fechaGeneracion,
    marcaAgua: marcaAgua,
    tema: tema,
  );
  return guardarPdfTemporal(
    documento: documento,
    prefijoNombre: prefijoNombreFichero,
  );
}

/// Como [generarInformePeriodicoPdf] pero devuelve los bytes del PDF sin
/// tocar el disco. Es la variante que sirve en web (no hay sistema de
/// ficheros) y para quien solo quiere pasarlo a `printing`.
Future<Uint8List> generarInformePeriodicoPdfBytes({
  required String tituloCabecera,
  required String subtituloCabecera,
  required List<String> bulletsResumen,
  required List<TablaInforme> tablas,
  String? operador,
  DateTime? fechaGeneracion,
  String? marcaAgua,
  pw.ThemeData? tema,
}) {
  return construirInformePeriodicoPdf(
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bulletsResumen,
    tablas: tablas,
    operador: operador,
    fechaGeneracion: fechaGeneracion,
    marcaAgua: marcaAgua,
    tema: tema,
  ).save();
}

/// Construye el documento del informe periódico en memoria.
///
/// Si [marcaAgua] no es `null`, cada página lleva ese texto en grande, en
/// diagonal y en gris claro por encima del contenido (p. ej. "BORRADOR"
/// para que una copia de trabajo no pase por versión definitiva).
///
/// [tema] fija las fuentes. Sin él se usa Helvetica, que solo cubre
/// Latin-1: el «€» y el «—» no salen. Para importes conviene pasar
/// `pw.ThemeData.withFont` con una TTF incrustada.
pw.Document construirInformePeriodicoPdf({
  required String tituloCabecera,
  required String subtituloCabecera,
  required List<String> bulletsResumen,
  required List<TablaInforme> tablas,
  String? operador,
  DateTime? fechaGeneracion,
  String? marcaAgua,
  pw.ThemeData? tema,
}) {
  final fecha = fechaGeneracion ?? DateTime.now();
  final fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(fecha);

  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        theme: tema,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        buildForeground: marcaAgua == null
            ? null
            : (_) => marcaAguaPdf(marcaAgua),
      ),
      header: (_) => cabeceraInformePdf(
        titulo: tituloCabecera,
        subtitulo: subtituloCabecera,
      ),
      footer: footerPaginacionPdf,
      build: (_) => [
        pw.SizedBox(height: 12),
        tituloSeccionPdf('Resumen'),
        for (final bullet in bulletsResumen) pw.Bullet(text: bullet),
        if (operador != null && operador.isNotEmpty) pw.Bullet(text: 'Operador: $operador'),
        pw.Bullet(text: 'Generado: $fechaFormateada'),
        for (final tabla in tablas) ..._renderizarTabla(tabla),
      ],
    ),
  );
  return pdf;
}

/// Texto de marca de agua a página completa: diagonal, grande y casi
/// transparente para no impedir la lectura.
pw.Widget marcaAguaPdf(String texto) {
  return pw.FullPage(
    ignoreMargins: true,
    child: pw.Center(
      child: pw.Transform.rotate(
        angle: math.pi / 5,
        child: pw.Opacity(
          opacity: 0.12,
          child: pw.Text(
            texto,
            style: pw.TextStyle(
              fontSize: 96,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
      ),
    ),
  );
}

List<pw.Widget> _renderizarTabla(TablaInforme tabla) {
  if (tabla.filas.isEmpty && tabla.mensajeSiVacia == null) {
    return const [];
  }
  return [
    pw.SizedBox(height: 16),
    tituloSeccionPdf(tabla.titulo),
    if (tabla.filas.isEmpty)
      mensajeVacioPdf(tabla.mensajeSiVacia!)
    else
      tablaInformePdf(
        headers: tabla.headers,
        filas: tabla.filas,
        alineamientoCeldas: tabla.alineamientoCeldas,
      ),
  ];
}
