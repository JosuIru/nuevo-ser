/// El acta del asunto en PDF (`docs/04-concejo.md` §4.6): asunto, reglas,
/// participación, resultado (con app y papel por separado, para que se
/// pueda rehacer a mano), debate, compromisos y firmas de la mesa.
///
/// Mientras no la firman dos personas de la mesa sale con la marca
/// BORRADOR en cada página y un aviso arriba (patrón de Zunbeltz).
library;

import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show marcaAguaPdf, temaPdfSolera;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../dominio/consentimiento.dart';
import '../dominio/debate.dart';
import '../dominio/recuento.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/urna.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import '../pantallas/textos_dominio.dart';
import 'piezas_pdf.dart';

Future<Uint8List> actaDelAsunto({
  required EstadoConcejo estado,
  required String asuntoUid,
  required AppLocalizations textos,
}) async {
  final asunto = estado.asunto(asuntoUid);
  final reglas = asunto.reglas;
  final urna = estado.urna(asuntoUid);
  final acta = estado.acta(asuntoUid);
  final debate = estado.debate(asuntoUid);
  final compromisos = estado.compromisosDelActa(asuntoUid);
  final documento = pw.Document(theme: await temaPdfSolera());

  documento.addPage(pw.MultiPage(
    pageTheme: pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      buildForeground:
          acta.definitiva ? null : (_) => marcaAguaPdf(textos.pdfMarcaBorrador),
    ),
    header: (_) => cabeceraPdf(estado.nombreEspacio, textos.pdfActa),
    footer: (contexto) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(textos.pdfGenerada(textos.fechaConAnio(estado.ahora)),
            style: const pw.TextStyle(fontSize: 8, color: grisPdf)),
        pw.Text('${contexto.pageNumber} / ${contexto.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: grisPdf)),
      ],
    ),
    build: (_) => [
      pw.SizedBox(height: 12),
      if (!acta.definitiva)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.red800),
          ),
          child: pw.Text(textos.pdfActaBorradorAviso,
              style: pw.TextStyle(
                  color: PdfColors.red800, fontWeight: pw.FontWeight.bold)),
        ),
      pw.SizedBox(height: 8),
      pw.Text(asunto.titulo,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Text(asunto.resumen),
      pw.SizedBox(height: 6),
      pw.Text(
          '${textos.tipoDecision(asunto.tipoDecision)}. '
          '${textos.explicaTipoDecision(asunto.tipoDecision)}',
          style: const pw.TextStyle(fontSize: 10)),
      if (asunto.compromisoPrevio.isNotEmpty)
        pw.Text('«${asunto.compromisoPrevio}»',
            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
      seccionPdf(textos.seccionCalendario, [
        pw.Text(
            textos.calendarioDebate(textos.fechaConAnio(asunto.inicioDebate))),
        pw.Text(textos.calendarioDecision(
            textos.fechaConAnio(asunto.inicioDecision),
            textos.fechaConAnio(asunto.finDecision))),
      ]),
      seccionPdf(textos.seccionComoSeDecide,
          [for (final linea in comoSeDecide(asunto, textos)) pw.Text(linea)]),
      if (reglas.forma == FormaDecision.consentimiento)
        ..._consentimiento(estado.consentimiento(asuntoUid), estado, textos)
      else ...[
        seccionPdf(textos.pdfParticipacion, [
          pw.Text(textos.pdfParticipacionDetalle(
            urna.personasQueHanParticipado,
            urna.personasQueHanParticipado - urna.participacionesPresenciales,
            urna.participacionesPresenciales,
          )),
          if (reglas.quorumPersonas > 0)
            pw.Text(hayQuorum(reglas, urna)
                ? textos.pdfQuorumAlcanzado
                : textos.pdfQuorumNoAlcanzado),
        ]),
        seccionPdf(textos.pdfResultado, [
          pw.Text(_desenlace(reglas, urna, textos),
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _tablaMarcas(reglas, urna, textos),
          pw.SizedBox(height: 4),
          if (reglas.forma == FormaDecision.presupuesto)
            ..._presupuesto(reglas, urna, textos),
          for (final conteo in urna.conteosPresenciales)
            pw.Text(
              textos.pdfConteoFirmado(
                conteo.papeletasTotales,
                conteo.firmadoPorUids.map(estado.nombreDe).join(' · '),
              ),
              style: const pw.TextStyle(fontSize: 9),
            ),
          for (final aviso in urna.avisos())
            if (aviso == AvisoUrna.papeletasPresencialesNoCuadran)
              pw.Text(textos.avisoPapeletasNoCuadran,
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.red800)),
        ]),
      ],
      seccionPdf(textos.pdfDebate, [
        pw.Text(
          [
            for (final tipo in TipoAportacion.values)
              '${textos.columna(tipo)}: ${debate.columna(tipo).length}',
          ].join(' · '),
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.Text(debate.resumenMesa.isEmpty
            ? textos.pdfSinResumen
            : debate.resumenMesa),
      ]),
      seccionPdf(textos.seccionCompromisos, [
        if (compromisos.isEmpty) pw.Text(textos.sinCompromisos),
        for (final compromiso in compromisos)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ${compromiso.que}'),
                pw.Text(
                  textos.pdfCompromisoLinea(compromiso.responsable,
                      textos.fechaConAnio(compromiso.fechaLimite)),
                  style: const pw.TextStyle(fontSize: 9, color: grisPdf),
                ),
              ],
            ),
          ),
      ]),
      seccionPdf(textos.pdfFirmas, [
        pw.SizedBox(height: 4),
        pw.Row(children: [
          for (var posicion = 0; posicion < 2; posicion++) ...[
            if (posicion > 0) pw.SizedBox(width: 24),
            pw.Expanded(
              child: _hueco(
                posicion < acta.firmas.length
                    ? textos.pdfFirmadaPor(
                        estado.nombreDe(acta.firmas[posicion].personaUid),
                        textos.fechaConAnio(acta.firmas[posicion].firmada))
                    : textos.pdfFaltaFirma,
              ),
            ),
          ],
        ]),
      ]),
    ],
  ));
  return documento.save();
}

pw.Widget _hueco(String pie) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 28),
        pw.Container(height: 0.5, color: PdfColors.black),
        pw.SizedBox(height: 2),
        pw.Text(pie, style: const pw.TextStyle(fontSize: 9, color: grisPdf)),
      ],
    );

String _desenlace(ReglasDecision reglas, Urna urna, AppLocalizations textos) {
  switch (reglas.forma) {
    case FormaDecision.votacion:
      return switch (contarVotacion(reglas, urna).desenlace) {
        DesenlaceVotacion.aprobada => textos.resultadoAprobada,
        DesenlaceVotacion.rechazada => textos.resultadoRechazada,
        DesenlaceVotacion.sinQuorum => textos.resultadoSinQuorum,
      };
    case FormaDecision.eleccionEntreOpciones:
      final resultado = contarEleccion(reglas, urna);
      if (!resultado.hayQuorum) return textos.resultadoSinQuorum;
      if (resultado.empate) return textos.resultadoEmpate;
      final ganadora =
          reglas.opciones.firstWhere((o) => resultado.ganadoras.contains(o.id));
      return '${textos.resultadoGanadora}: ${ganadora.texto}';
    case FormaDecision.presupuesto:
      final resultado = contarPresupuesto(reglas, urna);
      return resultado.hayQuorum
          ? textos.sobrante(textos.euros(resultado.sobranteEuros))
          : textos.resultadoSinQuorum;
    case FormaDecision.consentimiento:
      return '';
  }
}

/// Marcas por opción en la app, en papel y en total.
pw.Widget _tablaMarcas(
    ReglasDecision reglas, Urna urna, AppLocalizations textos) {
  final filas = reglas.forma == FormaDecision.votacion
      ? [
          (votoSi, textos.votoSi),
          (votoNo, textos.votoNo),
          (votoAbstencion, textos.votoAbstencion),
        ]
      : [for (final opcion in reglas.opciones) (opcion.id, opcion.texto)];
  final enLaApp = marcasEnLaApp(urna);
  final enPapel = marcasEnPapel(urna);
  pw.Widget celda(String texto, {bool negrita = false, bool derecha = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: pw.Text(texto,
            textAlign: derecha ? pw.TextAlign.right : pw.TextAlign.left,
            style:
                negrita ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null),
      );
  return pw.Table(
    border: pw.TableBorder.all(color: grisPdf, width: 0.5),
    columnWidths: const {
      0: pw.FlexColumnWidth(4),
      1: pw.FlexColumnWidth(1),
      2: pw.FlexColumnWidth(1),
      3: pw.FlexColumnWidth(1),
    },
    children: [
      pw.TableRow(children: [
        celda(textos.pdfOpcion, negrita: true),
        celda(textos.pdfEnLaApp, negrita: true, derecha: true),
        celda(textos.pdfEnPapel, negrita: true, derecha: true),
        celda(textos.pdfTotal, negrita: true, derecha: true),
      ]),
      for (final (id, texto) in filas)
        pw.TableRow(children: [
          celda(texto),
          celda('${enLaApp[id] ?? 0}', derecha: true),
          celda('${enPapel[id] ?? 0}', derecha: true),
          celda('${(enLaApp[id] ?? 0) + (enPapel[id] ?? 0)}',
              negrita: true, derecha: true),
        ]),
      pw.TableRow(children: [
        celda(textos.pdfPapeletasTotales),
        celda('${urna.papeletas.length}', derecha: true),
        celda('${urna.papeletasPresencialesContadas}', derecha: true),
        celda('${papeletasTotales(urna)}', negrita: true, derecha: true),
      ]),
    ],
  );
}

List<pw.Widget> _presupuesto(
    ReglasDecision reglas, Urna urna, AppLocalizations textos) {
  final resultado = contarPresupuesto(reglas, urna);
  return [
    pw.SizedBox(height: 6),
    for (final linea in resultado.lineas)
      pw.Text(
        '${linea.opcion.texto} (${textos.euros(linea.opcion.costeEuros!)}): '
        '${switch (linea.motivo) {
          MotivoPresupuesto.entra => textos.presupuestoEntra,
          MotivoPresupuesto.noCabe => textos.presupuestoNoCabe,
          MotivoPresupuesto.sinApoyos => textos.presupuestoSinApoyos,
        }}',
        style: const pw.TextStyle(fontSize: 10),
      ),
  ];
}

List<pw.Widget> _consentimiento(EstadoConsentimiento consentimiento,
    EstadoConcejo estado, AppLocalizations textos) {
  String estadoObjecion(EstadoObjecion estadoActual) => switch (estadoActual) {
        EstadoObjecion.viva => textos.estadoViva,
        EstadoObjecion.integrada => textos.estadoIntegrada,
        EstadoObjecion.retirada => textos.estadoRetirada,
        EstadoObjecion.noEsObjecion => textos.estadoNoEsObjecion,
      };
  return [
    seccionPdf(textos.pdfResultado, [
      pw.Text(
        switch (consentimiento.desenlace) {
          DesenlaceConsentimiento.aprobada => textos.consentimientoAprobado,
          DesenlaceConsentimiento.pasaAVotacionOAsamblea =>
            textos.consentimientoPasa,
          DesenlaceConsentimiento.enCurso => textos.recuentoEnCurso,
        },
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    ]),
    seccionPdf(textos.pdfObjeciones, [
      if (consentimiento.objeciones.isEmpty) pw.Text(textos.sinObjeciones),
      for (final objecion in consentimiento.objeciones)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${estado.nombreDe(objecion.autorUid)} · '
                '${textos.rondaConsentimiento(objecion.ronda, consentimiento.rondasMaximas)} · '
                '${estadoObjecion(objecion.estado)}',
                style: const pw.TextStyle(fontSize: 9, color: grisPdf),
              ),
              pw.Text(objecion.motivo),
              if (objecion.respuesta.isNotEmpty)
                pw.Text(textos.pdfRespuestaMesa(objecion.respuesta),
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          ),
        ),
    ]),
  ];
}
