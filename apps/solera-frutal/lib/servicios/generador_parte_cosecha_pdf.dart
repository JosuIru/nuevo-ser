import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_cosecha.dart';
import '../modelos/cosecha.dart';
import '../modelos/helada.dart';
import '../modelos/parcela.dart';
import '../modelos/titular.dart';
import '../utiles/textos_frutal.dart';

/// Sello hasta que un técnico valide el formato (y el asesor del seguro,
/// la parte de siniestros). Lo vigila test/sello_provisional_test.dart.
const String selloParteCosecha = 'PROVISIONAL';

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

String _numero(num? valor, {int decimales = 1}) =>
    valor == null ? '—' : formatearNumero(valor, decimales: decimales);

/// Tablas del parte de cosecha y rendimientos: totales por parcela,
/// entregas, y heladas o pedrisco de la campaña (memoria para el seguro).
List<TablaInforme> tablasParteCosecha({
  required List<Parcela> parcelas,
  required List<Cosecha> cosechas,
  List<Helada> heladas = const [],
}) {
  final porId = {for (final parcela in parcelas) parcela.id!: parcela};
  String nombre(int? id) => id == null
      ? SoleraL10n.t('frut.toda_explotacion')
      : porId[id]?.nombre ?? '#$id';
  final resumenes = ResumenCosechaParcela.calcular(cosechas);
  return [
    TablaInforme(
      titulo: SoleraL10n.t('frut.por_parcela'),
      headers: [
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.especie'),
        'ha',
        SoleraL10n.t('frut.entregas'),
        SoleraL10n.t('frut.pdf_kg'),
        'kg/ha',
        SoleraL10n.t('frut.rendimiento_grano'),
        SoleraL10n.t('frut.pdf_kg_grano'),
        SoleraL10n.t('frut.humedad'),
      ],
      filas: [
        for (final resumen in resumenes)
          [
            nombre(resumen.parcelaId),
            nombreEspecie(porId[resumen.parcelaId]?.especieId ?? ''),
            _numero(porId[resumen.parcelaId]?.superficieHa, decimales: 2),
            '${resumen.entregas}',
            _numero(resumen.kgCascara, decimales: 0),
            _numero(
                resumen.kgCascaraPorHectarea(
                    porId[resumen.parcelaId]?.superficieHa ?? 0),
                decimales: 0),
            _numero(resumen.rendimientoMedioPorcentaje),
            resumen.rendimientoMedioPorcentaje == null
                ? '—'
                : _numero(resumen.kgGrano, decimales: 0),
            _numero(resumen.humedadMediaPorcentaje),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('frut.sin_cosechas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.entregas'),
      headers: [
        SoleraL10n.t('frut.fecha'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.pdf_kg'),
        SoleraL10n.t('frut.rendimiento_grano'),
        SoleraL10n.t('frut.calibre'),
        SoleraL10n.t('frut.humedad'),
        SoleraL10n.t('frut.destino'),
        SoleraL10n.t('frut.numero_albaran'),
      ],
      filas: [
        for (final cosecha in [
          ...cosechas
        ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs)))
          [
            formatearFecha(cosecha.fechaMs),
            nombre(cosecha.parcelaId),
            _numero(cosecha.kgCascara, decimales: 0),
            _numero(cosecha.rendimientoGranoPorcentaje),
            _o(cosecha.calibre),
            _numero(cosecha.humedadPorcentaje),
            _o(cosecha.destino),
            _o(cosecha.numeroAlbaran),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('frut.pdf_heladas_pedrisco'),
      headers: [
        SoleraL10n.t('frut.fecha'),
        SoleraL10n.t('frut.parcela'),
        SoleraL10n.t('frut.pdf_tipo'),
        SoleraL10n.t('frut.temperatura_minima'),
        SoleraL10n.t('frut.estado_fenologico'),
        SoleraL10n.t('frut.danio_estimado'),
        SoleraL10n.t('frut.comunicada_seguro'),
      ],
      filas: [
        for (final helada in [
          ...heladas
        ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs)))
          [
            formatearFecha(helada.fechaMs),
            nombre(helada.parcelaId),
            SoleraL10n.t(helada.esPedrisco ? 'frut.pedrisco' : 'frut.helada'),
            _numero(helada.temperaturaMinimaC),
            _o(helada.estadoFenologico),
            _numero(helada.danioEstimadoPorcentaje, decimales: 0),
            SoleraL10n.t(helada.comunicadaAlSeguro ? 'frut.si' : 'frut.no'),
          ],
      ],
      // Sin heladas la sección no aparece.
    ),
  ];
}

/// Parte de cosecha y rendimientos de una campaña en PDF.
Future<Uint8List> generarParteCosechaPdf({
  required int campania,
  required Titular titular,
  required List<Parcela> parcelas,
  required List<Cosecha> cosechas,
  List<Helada> heladas = const [],
  pw.ThemeData? tema,
}) {
  final totalKilos =
      cosechas.fold<double>(0, (suma, cosecha) => suma + cosecha.kgCascara);
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('frut.parte_cosecha')} · $campania',
    subtituloCabecera: '${_o(titular.nombre)}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'} · $selloParteCosecha',
    bulletsResumen: [
      '${SoleraL10n.t('frut.pdf_kg')}: ${formatearNumero(totalKilos, decimales: 0)}',
      '${SoleraL10n.t('frut.entregas')}: ${cosechas.length}',
      SoleraL10n.t('frut.aviso_documento_provisional'),
    ],
    tablas: tablasParteCosecha(
        parcelas: parcelas, cosechas: cosechas, heladas: heladas),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
