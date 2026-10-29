import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../modelos/lote_produccion.dart';

/// Genera el Informe de Simulación de Trazabilidad en PDF.
///
/// Este documento es lo que el quesero puede mostrar al inspector
/// como constancia de que realiza ejercicios periódicos de
/// trazabilidad, tal como exige el Reglamento CE 178/2002.
///
/// Incluye: datos del ejercicio, árbol de trazabilidad completo,
/// verificación punto por punto, y espacio para firma del inspector.
class GeneradorInformeSimulacion {
  final _formatter = DateFormat('d/M/yyyy HH:mm', 'es_ES');

  Future<pw.Document> generar({
    required Map<String, Object?> resultado,
    required LoteProduccion loteSeleccionado,
    required bool aleatorio,
    required int tiempoSegundos,
    required List<String> verificaciones,
    required bool cadenaCompleta,
    required String inspector,
    required String realizador,
    required String notas,
  }) async {
    final doc = pw.Document(theme: await temaPdfSolera());

    final fechaSimulacion = DateTime.now();

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
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber,
                    )),
                pw.SizedBox(height: 8),
                pw.Text('INFORME DE SIMULACIÓN DE TRAZABILIDAD',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Reglamento CE 178/2002 — Artículo 18',
                    style:
                        pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    children: [
                      _filaInfo('Elemento simulado',
                          loteSeleccionado.numeroLote),
                      _filaInfo('Tipo de queso',
                          loteSeleccionado.tipoQuesoId),
                      _filaInfo('Fecha del lote',
                          _formatter.format(DateTime.fromMillisecondsSinceEpoch(
                              loteSeleccionado.fechaMs))),
                      _filaInfo('Método de selección',
                          aleatorio ? 'Aleatorio' : 'Manual'),
                      _filaInfo('Fecha del ejercicio',
                          _formatter.format(fechaSimulacion)),
                      _filaInfo('Tiempo de resolución',
                          '$tiempoSegundos segundos'),
                      _filaInfo('Realizado por',
                          realizador.isNotEmpty ? realizador : '—'),
                      _filaInfo('Inspector / verificador',
                          inspector.isNotEmpty ? inspector : 'Pendiente de firma'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Cadena de trazabilidad: ${cadenaCompleta ? "COMPLETA" : "INCOMPLETA — REQUIERE REVISIÓN"}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: cadenaCompleta ? PdfColors.green : PdfColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // ─── Árbol de trazabilidad ──────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1, child: pw.Text('Árbol de trazabilidad')),
          pw.Paragraph(
            text:
                'Reconstrucción de la cadena para el lote ${loteSeleccionado.numeroLote} '
                '(${loteSeleccionado.tipoQuesoId}):',
          ),
          pw.SizedBox(height: 16),

          // Hacia atrás
          pw.Header(level: 2, child: pw.Text('1. Trazabilidad hacia atrás (materias primas)')),
          ..._renderPartidas(resultado['partidas_leche'] as List? ?? []),

          // Insumos
          pw.Header(level: 2, child: pw.Text('2. Insumos')),
          _insumo('Fermento', resultado['fermento'] as String?),
          _insumo('Cuajo', resultado['cuajo'] as String?),
          pw.SizedBox(height: 8),

          // Piezas
          pw.Header(level: 2, child: pw.Text('3. Piezas producidas')),
          ..._renderPiezas(resultado['piezas'] as List? ?? []),

          // Eventos
          pw.Header(level: 2, child: pw.Text('4. Eventos de curación')),
          ..._renderEventos(resultado['eventos_curacion'] as List? ?? []),

          // Analíticas
          pw.Header(level: 2, child: pw.Text('5. Analíticas')),
          ..._renderAnaliticas(resultado['analiticas'] as List? ?? []),

          // Hacia adelante
          pw.Header(level: 2, child: pw.Text('6. Trazabilidad hacia adelante (ventas)')),
          ..._renderVentas(resultado['ventas'] as List? ?? []),
        ],
      ),
    );

    // ─── Verificación ───────────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1,
              child: pw.Text('Verificación de la cadena')),
          pw.SizedBox(height: 16),
          ...verificaciones.map((v) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(v, style: pw.TextStyle(fontSize: 11)),
              )),
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.SizedBox(height: 16),
          pw.Text(
            cadenaCompleta
                ? 'RESULTADO: La cadena de trazabilidad está completa. '
                    'No se detectaron roturas.'
                : 'RESULTADO: Se detectaron puntos débiles en la cadena. '
                    'Revisar las advertencias marcadas con ⚠️ o ❌.',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: cadenaCompleta ? PdfColors.green : PdfColors.red,
            ),
          ),
        ],
      ),
    );

    // ─── Firma del inspector ────────────────────
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => [
          pw.Header(level: 1,
              child: pw.Text('Firma del responsable')),
          pw.SizedBox(height: 40),
          _filaInfo('Realizado por', realizador.isNotEmpty ? realizador : '________________________'),
          pw.SizedBox(height: 16),
          _filaInfo('Inspeccionado por', inspector.isNotEmpty ? inspector : '________________________'),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Firma: ________________________',
                      style: pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text('Fecha: ____/____/________',
                      style: pw.TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          if (notas.isNotEmpty) ...[
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Header(level: 2, child: pw.Text('Notas')),
            pw.Paragraph(text: notas),
          ],
          pw.SizedBox(height: 60),
          pw.Paragraph(
            text:
                'Documento generado por Larrea Quesera. '
                'Este informe no sustituye la documentación APPCC oficial '
                'sino que complementa el registro de ejercicios de trazabilidad '
                'exigido por el Reglamento CE 178/2002.',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return doc;
  }

  List<pw.Widget> _renderPartidas(List partidas) {
    if (partidas.isEmpty) {
      return [pw.Paragraph(text: 'No se encontraron partidas de leche.',
          style: pw.TextStyle(color: PdfColors.red))];
    }
    return [
      pw.TableHelper.fromTextArray(
        headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: pw.TextStyle(fontSize: 9),
        headerAlignment: pw.Alignment.centerLeft,
        data: [
          <String>['Partida', 'Proveedor', 'Volumen', 'Fecha'],
          ...partidas.map((p) => [
                '#${p['partida_id']}',
                (p['proveedor'] as String?) ?? '',
                '${p['volumen']}L',
                (p['fecha'] as String?)?.substring(0, 10) ?? '',
              ]),
        ],
      ),
    ];
  }

  List<pw.Widget> _renderPiezas(List piezas) {
    if (piezas.isEmpty) {
      return [pw.Paragraph(text: 'No hay piezas registradas.',
          style: pw.TextStyle(color: PdfColors.orange))];
    }
    return [
      pw.TableHelper.fromTextArray(
        headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: pw.TextStyle(fontSize: 9),
        headerAlignment: pw.Alignment.centerLeft,
        data: [
          <String>['Pieza', 'Peso inicial', 'Peso actual', 'Estado', 'Ubicación'],
          ...piezas.map((p) => [
                (p['numero'] as String?) ?? '',
                '${p['peso_inicial']}kg',
                '${p['peso_actual'] ?? p['peso_inicial']}kg',
                (p['estado'] as String?) ?? '',
                (p['ubicacion'] as String?) ?? '',
              ]),
        ],
      ),
    ];
  }

  List<pw.Widget> _renderEventos(List eventos) {
    if (eventos.isEmpty) {
      return [pw.Paragraph(text: 'Sin eventos de curación registrados.',
          style: pw.TextStyle(color: PdfColors.orange))];
    }
    return [
      pw.TableHelper.fromTextArray(
        headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: pw.TextStyle(fontSize: 9),
        headerAlignment: pw.Alignment.centerLeft,
        data: [
          <String>['Pieza', 'Evento', 'Fecha'],
          ...eventos.take(20).map((e) => [
                (e['pieza'] as String?) ?? '',
                (e['tipo'] as String?) ?? '',
                ((e['fecha'] as String?) ?? '').substring(0, 10),
              ]),
        ],
      ),
    ];
  }

  List<pw.Widget> _renderAnaliticas(List analiticas) {
    if (analiticas.isEmpty) {
      return [pw.Paragraph(text: 'Sin analíticas.',
          style: pw.TextStyle(color: PdfColors.orange))];
    }
    return analiticas.map((a) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            children: [
              pw.Text(
                  '${a['tipo']}: ${a['conforme'] == true ? "Conforme" : "NO CONFORME"}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: a['conforme'] == true
                        ? PdfColors.green
                        : PdfColors.red,
                  )),
            ],
          ),
        )).toList();
  }

  List<pw.Widget> _renderVentas(List ventas) {
    if (ventas.isEmpty) {
      return [pw.Paragraph(text: 'No hay ventas de este lote.',
          style: pw.TextStyle(color: PdfColors.orange))];
    }
    return [
      pw.TableHelper.fromTextArray(
        headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        cellStyle: pw.TextStyle(fontSize: 9),
        headerAlignment: pw.Alignment.centerLeft,
        data: [
          <String>['Cliente', 'Fecha', 'Factura', 'Total'],
          ...ventas.map((v) => [
                (v['cliente'] as String?) ?? '',
                ((v['fecha'] as String?) ?? '').substring(0, 10),
                (v['factura'] as String?) ?? '',
                '${v['total']}€',
              ]),
        ],
      ),
    ];
  }

  pw.Widget _insumo(String label, String? valor) {
    final v = (valor ?? '').replaceAll(' ()', '');
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text('$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Text(v.isNotEmpty ? v : 'No registrado',
              style: pw.TextStyle(
                fontSize: 10,
                color: v.isNotEmpty ? PdfColors.black : PdfColors.orange,
              )),
        ],
      ),
    );
  }

  pw.Widget _filaInfo(String label, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 140,
              child: pw.Text(label,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 11))),
          pw.Text(valor, style: pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
