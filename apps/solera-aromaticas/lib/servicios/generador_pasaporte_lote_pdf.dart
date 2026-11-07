import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/catalogos.dart';
import '../dominio/trazabilidad.dart';
import '../modelos/lote_producto.dart';
import '../modelos/titular.dart';
import '../utiles/textos_aromaticas.dart';
import 'generador_libro_destilacion_pdf.dart' show textoOrigenLote;

/// Sello hasta que el asesor de regulación de aceites esenciales valide qué
/// puede llevar la ficha según el destino. Lo vigila
/// test/sello_provisional_test.dart.
const String selloPasaporteLote = 'PROVISIONAL';

/// Filas (etiqueta, valor) del pasaporte de un lote. **Solo trazabilidad**:
/// producto, especie, fechas, cantidad, origen y permiso. Nunca usos ni
/// propiedades de salud (hard limit). Función pura.
List<(String, String)> filasPasaporteLote({
  required LoteProducto lote,
  required Titular titular,
  required OrigenLote origen,
}) {
  final especie = especiePorId(lote.especieId);
  final intervalo = origen.intervaloCosecha;
  return [
    (SoleraL10n.t('arom.codigo_lote'), lote.codigo),
    (SoleraL10n.t('arom.pdf_producto'), nombreTipoLote(lote.tipo)),
    (
      SoleraL10n.t('arom.especie'),
      especie == null
          ? lote.especieId
          : '${especie.nombre} (${especie.nombreCientifico})'
    ),
    (SoleraL10n.t('arom.fecha'), formatearFecha(lote.fechaMs)),
    (
      SoleraL10n.t('arom.pdf_cantidad'),
      '${formatearNumero(lote.cantidad)} ${lote.unidad}'
    ),
    if (lote.envase.isNotEmpty) (SoleraL10n.t('arom.envase'), lote.envase),
    if (intervalo != null)
      (
        SoleraL10n.t('arom.pdf_fechas_cosecha'),
        intervalo.$1 == intervalo.$2
            ? formatearFecha(intervalo.$1)
            : '${formatearFecha(intervalo.$1)} – ${formatearFecha(intervalo.$2)}'
      ),
    (SoleraL10n.t('arom.trazabilidad'), textoOrigenLote(origen)),
    if (origen.incluyeSilvestre)
      (SoleraL10n.t('arom.pdf_origen_silvestre'), SoleraL10n.t('arom.si')),
    if (titular.nombre.isNotEmpty)
      (
        SoleraL10n.t('arom.titular'),
        '${titular.nombre}${titular.municipio.isEmpty ? '' : ' · ${titular.municipio}'}'
      ),
    if (titular.registroSanitario.isNotEmpty)
      (SoleraL10n.t('arom.registro_sanitario'), titular.registroSanitario),
  ];
}

/// Pasaporte del lote en PDF: ficha de trazabilidad con un QR que lleva el
/// mismo texto ([textoQrLote]). Sin enlace web: el pasaporte común de la
/// suite (T1) lo sustituirá cuando esté en el core.
Future<Uint8List> generarPasaporteLotePdf({
  required LoteProducto lote,
  required Titular titular,
  required OrigenLote origen,
  pw.ThemeData? tema,
}) async {
  final especie = especiePorId(lote.especieId);
  final textoQr = textoQrLote(
    lote: lote,
    nombreEspecie: especie?.nombre ?? lote.especieId,
    nombreCientifico: especie?.nombreCientifico ?? '',
    titular: titular.nombre,
    origen: origen,
    formatearFecha: formatearFecha,
  );
  final filas =
      filasPasaporteLote(lote: lote, titular: titular, origen: origen);
  final documento = pw.Document(theme: tema);
  documento.addPage(pw.Page(
    pageFormat: PdfPageFormat.a5,
    margin: const pw.EdgeInsets.all(24),
    build: (contexto) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(SoleraL10n.t('arom.pasaporte_lote'),
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text('Larrea Aromáticas · $selloPasaporteLote',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: textoQr,
            width: 150,
            height: 150,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
          },
          children: [
            for (final (etiqueta, valor) in filas)
              pw.TableRow(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text(etiqueta,
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Text(valor, style: const pw.TextStyle(fontSize: 9)),
                ),
              ]),
          ],
        ),
        pw.Spacer(),
        pw.Text(SoleraL10n.t('arom.pdf_aviso_pasaporte'),
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      ],
    ),
  ));
  return documento.save();
}
