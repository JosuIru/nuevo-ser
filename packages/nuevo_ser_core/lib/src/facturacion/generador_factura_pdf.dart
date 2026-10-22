import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../pdf/tema_pdf.dart';
import 'factura.dart';

/// Datos de quien emite la factura (el titular de la explotación).
/// Las líneas vacías no se imprimen.
class DatosEmisorFactura {
  /// Nombre o razón social.
  final String nombre;
  final String nif;
  final String direccion;
  final String telefono;
  final String email;

  const DatosEmisorFactura({
    required this.nombre,
    this.nif = '',
    this.direccion = '',
    this.telefono = '',
    this.email = '',
  });
}

/// Genera la factura en PDF conforme al Reglamento de Facturación
/// español (RD 1619/2012): nº secuencial, fecha de emisión, datos de
/// emisor y receptor, descripción, base imponible, tipo y cuota de IVA
/// y total.
///
/// Lo que cambia de una app a otra (marca de la cabecera, su color,
/// título del documento, firma del pie y texto legal) va en el
/// constructor; los valores por defecto reproducen la factura de agro.
class GeneradorFacturaPdf {
  /// Rótulo grande de la cabecera (p. ej. «SOLERA», «SOLERA QUESERA»).
  final String marca;

  /// Color del rótulo de la cabecera.
  final PdfColor colorMarca;

  /// Título bajo el rótulo (p. ej. «Factura», «Factura Simplificada»).
  final String tituloDocumento;

  /// Nombre que firma el pie: «Generado por <nombreAplicacion> · fecha».
  final String nombreAplicacion;

  /// Texto legal en letra pequeña al final.
  final String textoLegal;

  final DateFormat _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');

  GeneradorFacturaPdf({
    this.marca = 'SOLERA',
    this.colorMarca = PdfColors.amber,
    this.tituloDocumento = 'Factura',
    this.nombreAplicacion = 'Solera',
    this.textoLegal = 'Factura electrónica válida conforme RD 1619/2012.',
  });

  /// Documento PDF de [factura]. [fechaGeneracion] (por defecto, ahora)
  /// es la fecha que sale en el pie.
  Future<pw.Document> generar({
    required Factura factura,
    required DatosEmisorFactura emisor,
    DateTime? fechaGeneracion,
  }) async {
    // Tema con Archivo incrustada: Helvetica deja «€» y «—» en blanco.
    final documento = pw.Document(theme: await temaPdfSolera());
    final lineas = jsonDecode(factura.lineasJson) as List<dynamic>;
    final textoEstado = factura.estado == 'pagada'
        ? 'PAGADA'
        : factura.estado == 'vencida'
            ? 'VENCIDA'
            : 'EMITIDA';
    final colorEstado = factura.estado == 'pagada'
        ? PdfColors.green
        : factura.estado == 'vencida'
            ? PdfColors.red
            : PdfColors.blue;

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (contexto) => [
          // ─── Cabecera ────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(marca,
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: colorMarca)),
                  pw.Text(tituloDocumento,
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Nº ${factura.numeroFactura}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Fecha: ${_fecha(factura.fechaEmisionMs)}'),
                  if (factura.fechaVencimientoMs != null)
                    pw.Text(
                        'Vencimiento: ${_fecha(factura.fechaVencimientoMs!)}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.SizedBox(height: 16),

          // ─── Emisor ──────────────────────────────
          pw.Header(level: 1, child: pw.Text('Datos del emisor')),
          pw.Text(emisor.nombre),
          if (emisor.nif.isNotEmpty) pw.Text(emisor.nif),
          if (emisor.direccion.isNotEmpty) pw.Text(emisor.direccion),
          if (emisor.telefono.isNotEmpty) pw.Text('Tel: ${emisor.telefono}'),
          if (emisor.email.isNotEmpty) pw.Text('Email: ${emisor.email}'),
          pw.SizedBox(height: 16),

          // ─── Receptor ────────────────────────────
          pw.Header(level: 1, child: pw.Text('Datos del receptor')),
          pw.Text(factura.clienteNombre),
          pw.Text(
              factura.clienteNif.isNotEmpty ? factura.clienteNif : 'Sin NIF'),
          if (factura.clienteDireccion.isNotEmpty)
            pw.Text(factura.clienteDireccion),
          pw.SizedBox(height: 24),

          // ─── Líneas ──────────────────────────────
          pw.Header(level: 1, child: pw.Text('Descripción')),
          if (lineas.isEmpty)
            pw.Paragraph(text: 'Sin líneas detalladas')
          else
            pw.TableHelper.fromTextArray(
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerAlignment: pw.Alignment.centerLeft,
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              data: [
                <String>['Descripción', 'Cantidad', 'Precio', 'Importe'],
                ...lineas.map((linea) => [
                      (linea['descripcion'] as String?) ?? '',
                      textoCantidadFactura(linea['cantidad'] as num?),
                      textoImporteFactura(linea['precioUnitario'] as num?),
                      textoImporteFactura(linea['importe'] as num?),
                    ]),
              ],
            ),
          pw.SizedBox(height: 24),

          // ─── Totales ─────────────────────────────
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                      'Base imponible: ${textoImporteFactura(factura.baseImponible)}'),
                  pw.Text(
                      'IVA ${textoCantidadFactura(factura.ivaPorcentaje)} %: ${textoImporteFactura(factura.cuotaIva)}'),
                  pw.Divider(),
                  pw.Text('TOTAL: ${textoImporteFactura(factura.total)}',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),

          // ─── Pie ─────────────────────────────────
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(textoEstado,
                  style: pw.TextStyle(fontSize: 10, color: colorEstado)),
              pw.Text(
                  'Generado por $nombreAplicacion · '
                  '${_formatoFecha.format(fechaGeneracion ?? DateTime.now())}',
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(textoLegal,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
        ],
      ),
    );
    return documento;
  }

  /// Atajo: los bytes del PDF de [generar].
  Future<Uint8List> generarBytes({
    required Factura factura,
    required DatosEmisorFactura emisor,
    DateTime? fechaGeneracion,
  }) async {
    final documento = await generar(
        factura: factura, emisor: emisor, fechaGeneracion: fechaGeneracion);
    return documento.save();
  }

  String _fecha(int milisegundos) =>
      _formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(milisegundos));
}

/// Cantidad de una línea de factura: entera sin decimales («2»); con
/// decimales, a la española («2,5»), que antes se redondeaba. Sin
/// cantidad, «1».
String textoCantidadFactura(num? cantidad) {
  if (cantidad == null) return '1';
  if (cantidad == cantidad.roundToDouble()) return cantidad.toStringAsFixed(0);
  return cantidad.toString().replaceAll('.', ',');
}

/// Importe en euros a la española para la factura: «1.234,50 €» (punto de
/// millares, coma decimal, espacio antes del símbolo). Sin importe, «0,00 €».
String textoImporteFactura(num? importe) {
  final centimos = ((importe ?? 0) * 100).round();
  final negativo = centimos < 0;
  final absoluto = centimos.abs();
  final enteros = (absoluto ~/ 100).toString();
  final decimales = (absoluto % 100).toString().padLeft(2, '0');
  final conMillares = StringBuffer();
  for (var i = 0; i < enteros.length; i++) {
    if (i > 0 && (enteros.length - i) % 3 == 0) conMillares.write('.');
    conMillares.write(enteros[i]);
  }
  return '${negativo ? '-' : ''}$conMillares,$decimales €';
}
