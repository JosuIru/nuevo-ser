import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/titular.dart';
import '../utiles/textos_sidra.dart';

/// Sello hasta que el asesor fiscal fije el régimen y los tipos
/// (BLOQUEOS-PENDIENTES.md). Lo vigila test/sello_provisional_test.dart.
const String selloExtractoEconomico = 'PROVISIONAL';

/// Tablas del extracto: apuntes del periodo y totales por categoría.
List<TablaInforme> tablasExtractoEconomico(List<ApunteEconomico> apuntes) {
  final resumen = ResumenEconomico.calcular(apuntes);
  final ordenados = [...apuntes]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('sidr.apuntes'),
      headers: [
        SoleraL10n.t('sidr.fecha'),
        SoleraL10n.t('sidr.concepto'),
        SoleraL10n.t('sidr.categoria'),
        SoleraL10n.t('sidr.base'),
        SoleraL10n.t('sidr.iva'),
        SoleraL10n.t('sidr.compensacion_corto'),
        SoleraL10n.t('sidr.total'),
      ],
      filas: [
        for (final apunte in ordenados)
          [
            formatearFecha(apunte.fechaMs),
            apunte.concepto,
            nombreValor('categoria', apunte.categoria),
            '${apunte.esIngreso ? '' : '−'}${formatearEuros(apunte.baseCentimos)}',
            apunte.conCompensacionReagp
                ? '—'
                : '${apunte.tipoIvaPorcentaje} % · ${formatearEuros(apunte.cuotaIvaCentimos)}',
            apunte.conCompensacionReagp
                ? formatearEuros(apunte.compensacionReagpCentimos)
                : '—',
            formatearEuros(apunte.totalCentimos),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.sin_apuntes'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.por_categoria'),
      headers: [SoleraL10n.t('sidr.categoria'), SoleraL10n.t('sidr.base')],
      filas: [
        for (final MapEntry(key: categoria, value: base)
            in resumen.basePorCategoria.entries)
          [nombreValor('categoria', categoria), formatearEuros(base)],
      ],
    ),
  ];
}

/// Extracto de ingresos y gastos de un mes en PDF.
Future<Uint8List> generarExtractoEconomicoPdf({
  required DateTime mes,
  required Titular titular,
  required List<ApunteEconomico> apuntes,
  pw.ThemeData? tema,
}) {
  final resumen = ResumenEconomico.calcular(apuntes);
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('sidr.ingresos_y_gastos')} · ${DateFormat.yMMMM(SoleraL10n.idioma).format(mes)}',
    subtituloCabecera: '${titular.nombre}'
        ' · ${nombreValor('regimen', titular.regimenFiscal)}'
        ' · $selloExtractoEconomico',
    bulletsResumen: [
      '${SoleraL10n.t('sidr.resultado')}: ${formatearEuros(resumen.resultado)}',
      '${SoleraL10n.t('sidr.actividad_agraria')}: ${formatearEuros(resumen.ingresosActividadAgraria)} · '
          '${SoleraL10n.t('sidr.transformacion')}: ${formatearEuros(resumen.ingresosTransformacion)}',
      '${SoleraL10n.t('sidr.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('sidr.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      if (resumen.compensacionesCobradas > 0 ||
          resumen.compensacionesPagadas > 0)
        '${SoleraL10n.t('sidr.compensaciones_reagp')}: '
            '+${formatearEuros(resumen.compensacionesCobradas)} / '
            '−${formatearEuros(resumen.compensacionesPagadas)}',
      SoleraL10n.t('sidr.aviso_fiscal_provisional'),
    ],
    tablas: tablasExtractoEconomico(apuntes),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
