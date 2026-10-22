import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../datos/base_datos.dart';

/// Genera el Libro de Trazabilidad en PDF (7 secciones).
class GeneradorLibroTrazabilidad {
  final _formatter = DateFormat('d/M/yyyy', 'es_ES');

  Future<pw.Document> generar({
    required BaseDatosSoleraQuesera bd,
    required int desdeMs,
    required int hastaMs,
  }) async {
    final doc = pw.Document(theme: await temaPdfSolera());

    final queseria = await bd.obtenerQueseria();
    final partidas = await bd.listarPartidasLeche(
      desdeMs: desdeMs,
      hastaMs: hastaMs,
    );
    final lotes = await bd.listarLotes();
    final lotesFiltrados =
        lotes.where((l) => l.fechaMs >= desdeMs && l.fechaMs <= hastaMs).toList();
    final temps = await bd.listarTemperaturasRecientes(limite: 90);
    final analiticas = await bd.listarAnaliticas();
    final incidencias = await bd.listarIncidencias();
    final ventas = await bd.listarVentas(
      desdeMs: desdeMs,
      hastaMs: hastaMs,
    );

    final desdeStr = _formatter.format(DateTime.fromMillisecondsSinceEpoch(desdeMs));
    final hastaStr = _formatter.format(DateTime.fromMillisecondsSinceEpoch(hastaMs));
    final ahoraStr = _formatter.format(DateTime.now());

    // ─── Portada ─────────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('SOLERA QUESERA',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber,
                    )),
                pw.SizedBox(height: 8),
                pw.Text('Libro de Trazabilidad APPCC',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 40),
                if (queseria.razonSocial.isNotEmpty) ...[
                  pw.Text(queseria.razonSocial,
                      style: const pw.TextStyle(fontSize: 16)),
                  pw.Text('NIF: ${queseria.nif}'),
                  pw.Text('RGSEAA: ${queseria.rgseaa}'),
                ],
                pw.SizedBox(height: 40),
                pw.Text('Período: $desdeStr — $hastaStr',
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 20),
                pw.Text('Generado: $ahoraStr',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            ),
          ),
        ],
      ),
    );

    // ─── 1. Datos de la quesería ─────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('1. Datos de la quesería')),
          _tablaInfo([
            ['Razón social', queseria.razonSocial],
            ['NIF', queseria.nif],
            ['Dirección', queseria.direccion],
            ['RGSEAA', queseria.rgseaa],
            ['Teléfono', queseria.telefono],
            ['Email', queseria.email],
          ]),
        ],
      ),
    );

    // ─── 2. Recepción de leche ──────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('2. Recepción de leche')),
          if (partidas.isEmpty)
            pw.Paragraph(
                text: 'No hay partidas registradas en el período.',
                style: pw.TextStyle(color: PdfColors.grey))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                <String>[
                  'Fecha', 'Proveedor', 'Vol (L)', 'T°C', 'pH',
                  'Grasa%', 'Prot%', 'Antib.'
                ],
                ...partidas.map((p) => [
                      _formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(p.fechaMs)),
                      'Prov #${p.proveedorId}',
                      p.volumenLitros.toStringAsFixed(1),
                      p.temperaturaRecepcion?.toStringAsFixed(1) ?? '-',
                      p.ph?.toStringAsFixed(2) ?? '-',
                      p.grasa?.toStringAsFixed(1) ?? '-',
                      p.proteina?.toStringAsFixed(1) ?? '-',
                      p.antibioticosPositivos ? 'SÍ' : 'No',
                    ]),
              ],
            ),
        ],
      ),
    );

    // ─── 3. Producción ──────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('3. Producción')),
          if (lotesFiltrados.isEmpty)
            pw.Paragraph(
                text: 'No hay lotes en el período.',
                style: pw.TextStyle(color: PdfColors.grey))
          else ...[
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                <String>[
                  'Lote', 'Fecha', 'Tipo', 'Vol (L)', 'Peso (kg)',
                  'Rend', 'Piezas', 'Estado'
                ],
                ...lotesFiltrados.map((l) => [
                      l.numeroLote,
                      _formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(l.fechaMs)),
                      l.tipoQuesoId,
                      l.volumenLecheTotal.toStringAsFixed(1),
                      l.pesoTotalObtenido.toStringAsFixed(1),
                      l.rendimientoReal.toStringAsFixed(2),
                      l.numPiezasProducidas.toString(),
                      l.estado,
                    ]),
              ],
            ),
            ...lotesFiltrados.map((l) => pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    'Lote ${l.numeroLote}: fermento ${l.fermentoNombre} '
                    '(lote ${l.fermentoLoteComercial}) · cuajo ${l.cuajoTipo} '
                    '(lote ${l.cuajoLoteComercial}) · sal ${l.salLote}',
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                )),
          ],
        ],
      ),
    );

    // ─── 4. Curación ────────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('4. Control de curación')),
          pw.Header(level: 2, child: pw.Text('Temperatura y humedad')),
          if (temps.isEmpty)
            pw.Paragraph(
                text: 'Sin registros de temperatura.',
                style: pw.TextStyle(color: PdfColors.grey))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                <String>['Fecha', 'Cava', 'T°C', 'HR%', 'Resp.'],
                ...temps.map((t) => [
                      _formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(t.fechaMs)),
                      t.cavaId,
                      t.temperatura.toStringAsFixed(1),
                      t.humedadRelativa.toStringAsFixed(0),
                      t.responsable,
                    ]),
              ],
            ),
        ],
      ),
    );

    // ─── 5. Analíticas ──────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('5. Analíticas y autocontrol')),
          if (analiticas.isEmpty)
            pw.Paragraph(
                text: 'No hay analíticas registradas.',
                style: pw.TextStyle(color: PdfColors.grey))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                <String>['Fecha', 'Tipo', 'Laboratorio', 'Resultado'],
                ...analiticas.map((a) => [
                      _formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(a.fechaMs)),
                      a.tipo,
                      a.laboratorio,
                      a.conforme ? 'Conforme' : 'NO CONFORME',
                    ]),
              ],
            ),
        ],
      ),
    );

    // ─── 6. Incidencias ─────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(
              level: 1,
              child: pw.Text('6. Incidencias y acciones correctivas')),
          if (incidencias.isEmpty)
            pw.Paragraph(
                text: 'No hay incidencias registradas.',
                style: pw.TextStyle(color: PdfColors.grey))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                <String>[
                  'Fecha', 'Tipo', 'Descripción', 'Causa',
                  'C. Correctiva', 'Estado'
                ],
                ...incidencias.map((i) => [
                      _formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(i.fechaMs)),
                      i.tipo,
                      i.descripcion.length > 40
                          ? '${i.descripcion.substring(0, 40)}…'
                          : i.descripcion,
                      i.causa.length > 30
                          ? '${i.causa.substring(0, 30)}…'
                          : i.causa,
                      i.accionCorrectiva.length > 30
                          ? '${i.accionCorrectiva.substring(0, 30)}…'
                          : i.accionCorrectiva,
                      i.cerrada ? 'Cerrada' : 'Abierta',
                    ]),
              ],
            ),
        ],
      ),
    );

    // ─── 7. Expedición ──────────────────────────
    final totalIngresos =
        ventas.fold(0.0, (double sum, v) => sum + v.total);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('7. Expedición / Ventas')),
          if (ventas.isEmpty)
            pw.Paragraph(
                text: 'No hay ventas registradas en el período.',
                style: pw.TextStyle(color: PdfColors.grey))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerAlignment: pw.Alignment.centerLeft,
              data: [
                <String>[
                  'Fecha', 'Cliente', 'Tipo', 'Factura',
                  'Base', 'IVA%', 'Total'
                ],
                ...ventas.map((v) => [
                      _formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(v.fechaMs)),
                      v.clienteNombre.length > 20
                          ? '${v.clienteNombre.substring(0, 20)}…'
                          : v.clienteNombre,
                      v.tipo,
                      v.numeroFactura,
                      '${v.baseImponible.toStringAsFixed(2)}€',
                      '${v.ivaPorcentaje.toStringAsFixed(0)}%',
                      '${v.total.toStringAsFixed(2)}€',
                    ]),
              ],
            ),
          pw.SizedBox(height: 16),
          pw.Paragraph(
            text: 'Total ingresos período: ${totalIngresos.toStringAsFixed(2)}€',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _tablaInfo(List<List<String>> filas) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 10),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {0: const pw.FixedColumnWidth(120)},
      data: [
        ['Campo', 'Valor'],
        ...filas,
      ],
    );
  }
}
