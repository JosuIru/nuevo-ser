import 'dart:math' as math;
import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/pasaporte.dart';
import '../modelos/lote_material.dart';
import '../modelos/pasaporte_emitido.dart';
import '../modelos/salida.dart';
import '../modelos/vivero.dart';
import '../utiles/textos_vivero.dart';

// Etiqueta con los datos del pasaporte fitosanitario y registro de los
// pasaportes preparados.
//
// Formato: Reglamento de Ejecución (UE) 2017/2313 de la Comisión, de 13 de
// diciembre de 2017, anexo, partes A (traslado en la Unión) y B (zona
// protegida): título «Plant Passport» / «Pasaporte fitosanitario» (o
// «– PZ» / «– ZP»), bandera de la Unión (en color o en blanco y negro),
// letras A (nombre botánico), B (ES- y nº de registro), C (código de
// trazabilidad y, si procede, su soporte de datos) y D (origen); todo dentro
// de un rectángulo, legible sin ayuda óptica y separado del resto (art. 2).
// El tamaño y la letra del modelo son «meros ejemplos».
// https://eur-lex.europa.eu/legal-content/ES/TXT/?uri=CELEX:32017R2313
// (consultado el 2026-11-07).
//
// La app NO expide el pasaporte: la etiqueta lleva el sello PROVISIONAL
// hasta que el técnico de sanidad vegetal de la comunidad valide el
// formato, y BORRADOR si el vivero no está autorizado o faltan datos.

/// Sello de la etiqueta y del registro. Lo vigila
/// test/sello_provisional_test.dart.
const String selloPasaporte = 'PROVISIONAL';

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

/// Datos de un registro guardado, en la forma de la etiqueta.
DatosPasaporte datosDesdeRegistro(PasaporteEmitido pasaporte,
        {required bool operadorAutorizado}) =>
    DatosPasaporte(
      esZonaProtegida: pasaporte.esZonaProtegida,
      nombreBotanico: pasaporte.nombreBotanico,
      variedad: pasaporte.variedad,
      codigoOperador: pasaporte.codigoOperador,
      codigoTrazabilidad: pasaporte.codigoTrazabilidad,
      paisOrigen: pasaporte.paisOrigen,
      plagasZonaProtegida: pasaporte.plagasZonaProtegida,
      cantidad: pasaporte.cantidad,
      operadorAutorizado: operadorAutorizado && !pasaporte.esBorrador,
      faltan: const [],
    );

/// Las filas de la etiqueta (letra, valor), en el orden del anexo.
List<(String, String)> filasEtiquetaPasaporte(DatosPasaporte datos) => [
      ('A', _o(datos.letraA)),
      ('B', _o(datos.codigoOperador)),
      ('C', _o(datos.codigoTrazabilidad)),
      ('D', _o(datos.paisOrigen)),
      if (datos.esZonaProtegida) ('ZP', _o(datos.plagasZonaProtegida)),
    ];

/// Avisos que la etiqueta lleva fuera del recuadro.
List<String> avisosEtiquetaPasaporte(DatosPasaporte datos) => [
      '$selloPasaporte · ${SoleraL10n.t('vive.pdf_formato_por_validar')}',
      if (datos.esBorrador) SoleraL10n.t('vive.pdf_borrador_no_valido'),
    ];

/// Bandera de la Unión en blanco y negro (estrellas blancas sobre fondo
/// negro), que el anexo admite.
pw.Widget _bandera(double ancho) => pw.CustomPaint(
      size: PdfPoint(ancho, ancho * 2 / 3),
      painter: (lienzo, tamanio) {
        lienzo
          ..setFillColor(PdfColors.black)
          ..drawRect(0, 0, tamanio.x, tamanio.y)
          ..fillPath()
          ..setFillColor(PdfColors.white);
        final centroX = tamanio.x / 2;
        final centroY = tamanio.y / 2;
        final radio = tamanio.y / 3;
        final radioEstrella = tamanio.y / 18;
        for (var estrella = 0; estrella < 12; estrella++) {
          final angulo = estrella * math.pi / 6;
          final x = centroX + radio * math.cos(angulo);
          final y = centroY + radio * math.sin(angulo);
          for (var punta = 0; punta < 10; punta++) {
            final anguloPunta = math.pi / 2 + punta * math.pi / 5;
            final r = punta.isEven ? radioEstrella : radioEstrella * 0.4;
            final px = x + r * math.cos(anguloPunta);
            final py = y + r * math.sin(anguloPunta);
            if (punta == 0) {
              lienzo.moveTo(px, py);
            } else {
              lienzo.lineTo(px, py);
            }
          }
          lienzo.closePath();
        }
        lienzo.fillPath();
      },
    );

pw.Widget _etiqueta(DatosPasaporte datos) {
  final filas = filasEtiquetaPasaporte(datos);
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1)),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    _bandera(30),
                    pw.SizedBox(width: 6),
                    pw.Expanded(
                      child: pw.Text(datos.titulo,
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ),
                  ]),
                  pw.SizedBox(height: 4),
                  for (final (letra, valor) in filas)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.SizedBox(
                              width: 16,
                              child: pw.Text(letra,
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold))),
                          pw.Expanded(
                              child: pw.Text(valor,
                                  style: const pw.TextStyle(fontSize: 9))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 6),
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: contenidoQrPasaporte(datos),
              width: 54,
              height: 54,
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 3),
      for (final aviso in avisosEtiquetaPasaporte(datos))
        pw.Text(aviso,
            style: pw.TextStyle(
                fontSize: 6,
                color: datos.esBorrador ? PdfColors.red800 : PdfColors.grey700,
                fontWeight: pw.FontWeight.bold)),
    ],
  );
}

/// Etiqueta imprimible (10 × 6,5 cm) con los datos del pasaporte de un
/// registro, con sello PROVISIONAL.
Future<Uint8List> generarEtiquetaPasaportePdf(
  DatosPasaporte datos, {
  pw.ThemeData? tema,
}) {
  final documento = pw.Document(theme: tema);
  documento.addPage(pw.Page(
    pageFormat: const PdfPageFormat(
        10 * PdfPageFormat.cm, 6.5 * PdfPageFormat.cm,
        marginAll: 0.4 * PdfPageFormat.cm),
    build: (_) => _etiqueta(datos),
  ));
  return documento.save();
}

/// Tablas del registro de pasaportes y de trazabilidad de un año: lo que
/// entró con pasaporte (origen), lo que salió (destino) y los pasaportes
/// preparados, como pide el RD 1054/2021, art. 20 (3 años).
List<TablaInforme> tablasRegistroPasaportes({
  required List<LoteMaterial> lotesRecibidos,
  required List<Salida> salidas,
  required List<PasaporteEmitido> pasaportes,
  required Map<int, String> codigoPartidaPorId,
  String Function(String) nombreEspecie = _identidad,
}) {
  final salidasPorId = {for (final salida in salidas) salida.id!: salida};
  final lotes = lotesRecibidos.where((lote) => !lote.esPropio).toList()
    ..sort((a, b) => a.fechaEntradaMs.compareTo(b.fechaEntradaMs));
  final ordenadas = [...salidas]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final registros = [...pasaportes]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('vive.pdf_origen'),
      headers: [
        SoleraL10n.t('vive.fecha_entrada'),
        SoleraL10n.t('vive.codigo_lote'),
        SoleraL10n.t('vive.especie'),
        SoleraL10n.t('vive.proveedor'),
        SoleraL10n.t('vive.proveedor_ropveg'),
        SoleraL10n.t('vive.pasaporte_recibido'),
        SoleraL10n.t('vive.pais_origen'),
      ],
      filas: [
        for (final lote in lotes)
          [
            formatearFecha(lote.fechaEntradaMs),
            lote.codigo,
            _o(nombreEspecie(lote.especieId)),
            _o(lote.proveedorNombre),
            _o(lote.proveedorCodigoRopveg),
            _o(lote.pasaporteRecibido),
            _o(lote.paisOrigen),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('vive.pdf_sin_entradas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('vive.pdf_destino'),
      headers: [
        SoleraL10n.t('vive.fecha'),
        SoleraL10n.t('vive.partida'),
        SoleraL10n.t('vive.cantidad'),
        SoleraL10n.t('vive.cliente'),
        SoleraL10n.t('vive.cliente_ropveg'),
        SoleraL10n.t('vive.codigo_trazabilidad'),
        SoleraL10n.t('vive.pdf_pasaporte'),
      ],
      filas: [
        for (final salida in ordenadas)
          [
            formatearFecha(salida.fechaMs),
            codigoPartidaPorId[salida.partidaId] ?? '#${salida.partidaId}',
            '${salida.cantidad}',
            _o(salida.clienteNombre),
            _o(salida.clienteCodigoRopveg),
            _o(salida.codigoTrazabilidad),
            textoNecesidadPasaporte(evaluarNecesidadPasaporte(salida,
                necesitaPasaporteEspecie: true)),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('vive.sin_salidas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('vive.pasaportes_registrados'),
      headers: [
        SoleraL10n.t('vive.fecha'),
        SoleraL10n.t('vive.cliente'),
        'A',
        'B',
        'C',
        'D',
        'ZP',
        SoleraL10n.t('vive.cantidad'),
        SoleraL10n.t('vive.preparado_por'),
        SoleraL10n.t('vive.pdf_estado'),
      ],
      filas: [
        for (final pasaporte in registros)
          [
            formatearFecha(pasaporte.fechaMs),
            _o(salidasPorId[pasaporte.salidaId]?.clienteNombre ?? ''),
            _o(pasaporte.variedad.isEmpty
                ? pasaporte.nombreBotanico
                : '${pasaporte.nombreBotanico} \'${pasaporte.variedad}\''),
            _o(pasaporte.codigoOperador),
            _o(pasaporte.codigoTrazabilidad),
            _o(pasaporte.paisOrigen),
            pasaporte.esZonaProtegida ? _o(pasaporte.plagasZonaProtegida) : '—',
            '${pasaporte.cantidad}',
            _o(pasaporte.preparadoPor),
            [
              if (pasaporte.anulado) SoleraL10n.t('vive.anulado'),
              if (pasaporte.esBorrador) SoleraL10n.t('vive.borrador'),
            ].join(' · ').ifEmpty('—'),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('vive.sin_pasaportes'),
    ),
  ];
}

String _identidad(String texto) => texto;

extension on String {
  String ifEmpty(String alternativa) => isEmpty ? alternativa : this;
}

/// Registro de pasaportes y de trazabilidad de un año en PDF.
Future<Uint8List> generarRegistroPasaportesPdf({
  required int anyo,
  required Vivero vivero,
  required List<LoteMaterial> lotesRecibidos,
  required List<Salida> salidas,
  required List<PasaporteEmitido> pasaportes,
  required Map<int, String> codigoPartidaPorId,
  String Function(String) nombreEspecie = _identidad,
  pw.ThemeData? tema,
}) {
  final vigentes = pasaportes.where((pasaporte) => !pasaporte.anulado).length;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('vive.registro_pasaportes')} · $anyo',
    subtituloCabecera: '${_o(vivero.nombre)}'
        '${vivero.codigoRopveg.isEmpty ? '' : ' · ${vivero.codigoRopvegNormalizado}'}'
        ' · $selloPasaporte',
    bulletsResumen: [
      '${SoleraL10n.t('vive.salidas')}: ${salidas.length}',
      '${SoleraL10n.t('vive.pasaportes_registrados')}: $vigentes',
      SoleraL10n.t('vive.aviso_conservar_tres_anos'),
      SoleraL10n.t(vivero.autorizadoPasaporte
          ? 'vive.aviso_documento_provisional'
          : 'vive.sin_autorizacion_borrador'),
    ],
    tablas: tablasRegistroPasaportes(
      lotesRecibidos: lotesRecibidos,
      salidas: salidas,
      pasaportes: pasaportes,
      codigoPartidaPorId: codigoPartidaPorId,
      nombreEspecie: nombreEspecie,
    ),
    operador: vivero.nombre.isEmpty ? null : vivero.nombre,
    tema: tema,
  );
}
