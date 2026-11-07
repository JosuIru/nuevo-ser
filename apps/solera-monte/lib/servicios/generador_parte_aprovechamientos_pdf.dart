import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/aprovechamientos.dart';
import '../dominio/catalogos.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/monte.dart';
import '../modelos/rodal.dart';
import '../modelos/sorteo_lena.dart';
import '../utiles/textos_monte.dart';
import 'cabecera_monte.dart';

/// Sello hasta que el técnico forestal de la comunidad autónoma valide el
/// formato. Lo vigila test/sello_provisional_test.dart.
const String selloParteAprovechamientos = 'PROVISIONAL';

/// Lo que entra en el parte de una campaña.
class DatosParteAprovechamientos {
  DatosParteAprovechamientos({
    required this.campanya,
    required this.monte,
    this.rodales = const [],
    this.aprovechamientos = const [],
    this.sorteos = const [],
    this.lotes = const [],
    DateTime? hoy,
  }) : hoy = hoy ?? DateTime.now();

  final int campanya;
  final Monte monte;
  final List<Rodal> rodales;

  /// Aprovechamientos de la campaña.
  final List<Aprovechamiento> aprovechamientos;

  /// Sorteos de leña de la campaña y sus lotes.
  final List<SorteoLena> sorteos;
  final List<LoteLena> lotes;
  final DateTime hoy;
}

/// Tablas del parte: aprovechamientos con su trámite, totales por tipo y
/// unidad, y lotes de leña vecinal adjudicados. Funciones puras.
List<TablaInforme> tablasParteAprovechamientos(
    DatosParteAprovechamientos datos) {
  final rodalPorId = {for (final rodal in datos.rodales) rodal.id: rodal};
  final sorteoPorId = {for (final sorteo in datos.sorteos) sorteo.id: sorteo};
  final porFecha = [...datos.aprovechamientos]
    ..sort((a, b) => a.fechaInicioMs.compareTo(b.fechaInicioMs));
  final totales = totalesPorTipoYUnidad(datos.aprovechamientos);
  final lotes = [
    for (final lote in datos.lotes)
      if (sorteoPorId.containsKey(lote.sorteoId)) lote
  ]..sort((a, b) {
      final porSorteo = a.sorteoId.compareTo(b.sorteoId);
      return porSorteo != 0 ? porSorteo : a.numero.compareTo(b.numero);
    });
  return [
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_aprovechamientos'),
      headers: [
        SoleraL10n.t('mont.pdf_que_y_donde'),
        SoleraL10n.t('mont.pdf_fechas'),
        SoleraL10n.t('mont.pdf_cantidad'),
        SoleraL10n.t('mont.pdf_reparto'),
        SoleraL10n.t('mont.pdf_tramite'),
      ],
      filas: [
        for (final aprovechamiento in porFecha)
          () {
            final rodal = rodalPorId[aprovechamiento.rodalId];
            final unidad = nombreUnidad(aprovechamiento.unidad);
            final cientifico = rodal == null
                ? ''
                : nombreCientificoEspecie(rodal.especiePrincipalId);
            return [
              [
                nombreTipoAprovechamiento(aprovechamiento.tipo),
                rodal == null
                    ? SoleraL10n.t('mont.todo_el_monte')
                    : '${rodal.etiqueta}${rodal.superficieHa > 0 ? ' (${formatearNumero(rodal.superficieHa, decimales: 2)} ha)' : ''}',
                if (rodal != null)
                  '${nombreEspecie(rodal.especiePrincipalId)}'
                      '${cientifico.isEmpty ? '' : ' ($cientifico)'}',
              ].join('\n'),
              '${formatearFecha(aprovechamiento.fechaInicioMs)}\n'
                  '${aprovechamiento.fechaFinMs == null ? SoleraL10n.t('mont.en_curso') : formatearFecha(aprovechamiento.fechaFinMs!)}',
              [
                if (aprovechamiento.cantidadPrevista != null)
                  '${SoleraL10n.t('mont.previsto')}: ${formatearNumero(aprovechamiento.cantidadPrevista!)} $unidad',
                '${SoleraL10n.t('mont.pdf_obtenido')}: ${formatearNumero(aprovechamiento.cantidad)} $unidad',
              ].join('\n'),
              '${nombreModalidad(aprovechamiento.modalidad)}\n'
                  '${o(aprovechamiento.adjudicatario)}',
              '${nombreTramite(aprovechamiento.tramite)}'
                  '${aprovechamiento.referenciaTramite.isEmpty ? '' : ' ${aprovechamiento.referenciaTramite}'}'
                  '${aprovechamiento.fechaComunicacionCuantiaMs == null ? '' : '\n${SoleraL10n.t('mont.pdf_cuantia_comunicada')} ${formatearFecha(aprovechamiento.fechaComunicacionCuantiaMs!)}'}',
            ];
          }(),
      ],
      mensajeSiVacia: SoleraL10n.t('mont.sin_aprovechamientos'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_avisos'),
      headers: [
        SoleraL10n.t('mont.aprovechamiento'),
        SoleraL10n.t('mont.pdf_aviso'),
      ],
      filas: [
        for (final aprovechamiento in porFecha)
          for (final aviso in avisosAprovechamiento(aprovechamiento, datos.hoy))
            [
              '${nombreTipoAprovechamiento(aprovechamiento.tipo)} · '
                  '${rodalPorId[aprovechamiento.rodalId]?.etiqueta ?? SoleraL10n.t('mont.todo_el_monte')}',
              textoAvisoAprovechamiento(
                  aviso, limiteComunicacionCuantia(aprovechamiento)),
            ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_totales'),
      headers: [
        SoleraL10n.t('mont.tipo_aprovechamiento'),
        SoleraL10n.t('mont.cantidad_obtenida'),
        SoleraL10n.t('mont.pdf_m3_orientativos'),
      ],
      filas: [
        for (final MapEntry(key: (tipo, unidad), value: cantidad)
            in totales.entries)
          [
            nombreTipoAprovechamiento(tipo),
            '${formatearNumero(cantidad)} ${nombreUnidad(unidad)}',
            tiposMaderablesYLenosos.contains(tipo) &&
                    aMetrosCubicos(cantidad, unidad) != null
                ? formatearNumero(aMetrosCubicos(cantidad, unidad)!)
                : vacioPdf,
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_lotes_vecinales'),
      headers: [
        SoleraL10n.t('mont.sorteos_lena'),
        SoleraL10n.t('mont.numero_lote'),
        SoleraL10n.t('mont.rodal'),
        SoleraL10n.t('mont.estereos_lote'),
        SoleraL10n.t('mont.pdf_adjudicatario'),
      ],
      filas: [
        for (final lote in lotes)
          [
            () {
              final sorteo = sorteoPorId[lote.sorteoId]!;
              return '${sorteo.nombre.isEmpty ? '${sorteo.campanya}' : sorteo.nombre}'
                  '${sorteo.realizado ? '' : ' (${SoleraL10n.t('mont.sin_sortear')})'}';
            }(),
            '${lote.numero}',
            rodalPorId[lote.rodalId]?.etiqueta ?? vacioPdf,
            numeroOGuion(lote.cantidad),
            lote.adjudicado
                ? lote.adjudicatario
                : SoleraL10n.t('mont.sin_adjudicar'),
          ],
      ],
    ),
  ];
}

/// Parte de aprovechamientos de una campaña en PDF: la información que pide
/// la declaración, la comunicación o la autorización de la comunidad
/// autónoma. **No es la solicitud oficial**: no hay modelo estatal y cada
/// comunidad tiene el suyo.
Future<Uint8List> generarParteAprovechamientosPdf(
    DatosParteAprovechamientos datos,
    {pw.ThemeData? tema}) {
  final monte = datos.monte;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('mont.parte_aprovechamientos')} · ${datos.campanya}',
    subtituloCabecera: subtituloMonte(monte, selloParteAprovechamientos),
    bulletsResumen: [
      ...identificacionMonte(monte),
      SoleraL10n.t('mont.pdf_aviso_art37'),
      SoleraL10n.t('mont.pdf_aviso_art37_4'),
      SoleraL10n.t('mont.pdf_aviso_no_autoriza'),
      SoleraL10n.t('mont.pdf_aviso_estereo'),
      SoleraL10n.t('mont.aviso_documento_provisional'),
    ],
    tablas: tablasParteAprovechamientos(datos),
    operador: monte.titular.isEmpty ? null : monte.titular,
    tema: tema,
  );
}
