import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/monte.dart';
import '../modelos/rodal.dart';
import '../utiles/textos_monte.dart';
import 'cabecera_monte.dart';

/// Sello hasta que un asesor fiscal valide categorías, régimen y
/// porcentajes. Lo vigila test/sello_provisional_test.dart.
const String selloExtractoEconomico = 'PROVISIONAL';

/// Filas de una tabla de apuntes (función pura).
List<List<String>> filasApuntes(
        Iterable<ApunteEconomico> apuntes, Map<int, Rodal> rodales) =>
    [
      for (final apunte in apuntes)
        [
          formatearFecha(apunte.fechaMs),
          apunte.concepto,
          nombreCategoriaEconomica(apunte.categoria),
          apunte.rodalId == null
              ? vacioPdf
              : rodales[apunte.rodalId]?.codigo ?? '#${apunte.rodalId}',
          o(apunte.tercero),
          formatearEuros(apunte.baseCentimos),
          apunte.compensacionReagpPorcentaje > 0
              ? 'REAGP ${formatearNumero(apunte.compensacionReagpPorcentaje, decimales: 0)} %'
              : '${SoleraL10n.t('mont.iva')} ${apunte.tipoIvaPorcentaje} %',
          formatearEuros(apunte.totalCentimos),
        ],
    ];

/// Extracto de ingresos y gastos del monte de un año.
Future<Uint8List> generarExtractoEconomicoPdf({
  required int anyo,
  required Monte monte,
  required String regimen,
  required List<ApunteEconomico> apuntes,
  List<Rodal> rodales = const [],
  pw.ThemeData? tema,
}) {
  final resumen = ResumenEconomico.calcular(apuntes);
  final porId = {for (final rodal in rodales) rodal.id!: rodal};
  final cabecera = [
    SoleraL10n.t('mont.fecha'),
    SoleraL10n.t('mont.concepto'),
    SoleraL10n.t('mont.categoria'),
    SoleraL10n.t('mont.rodal'),
    SoleraL10n.t('mont.tercero'),
    SoleraL10n.t('mont.base'),
    SoleraL10n.t('mont.impuesto'),
    SoleraL10n.t('mont.total'),
  ];
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('mont.ingresos_y_gastos')} · $anyo',
    subtituloCabecera: subtituloMonte(monte, selloExtractoEconomico),
    bulletsResumen: [
      '${SoleraL10n.t('mont.regimen_fiscal')}: ${nombreRegimenFiscal(regimen)}',
      '${SoleraL10n.t('mont.ingresos')}: ${formatearEuros(resumen.ingresosBase)}',
      '${SoleraL10n.t('mont.gastos')}: ${formatearEuros(resumen.gastosBase)}',
      '${SoleraL10n.t('mont.resultado_economico')}: ${formatearEuros(resumen.resultado)}',
      if (resumen.compensacionesReagp > 0)
        '${SoleraL10n.t('mont.compensaciones_reagp')}: ${formatearEuros(resumen.compensacionesReagp)}',
      '${SoleraL10n.t('mont.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('mont.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      SoleraL10n.t('mont.aviso_fiscal'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('mont.pdf_por_categoria'),
        headers: [
          SoleraL10n.t('mont.categoria'),
          SoleraL10n.t('mont.ingresos'),
          SoleraL10n.t('mont.gastos'),
        ],
        filas: [
          for (final MapEntry(:key, :value)
              in resumen.ingresosPorCategoria.entries)
            [nombreCategoriaEconomica(key), formatearEuros(value), vacioPdf],
          for (final MapEntry(:key, :value)
              in resumen.gastosPorCategoria.entries)
            [nombreCategoriaEconomica(key), vacioPdf, formatearEuros(value)],
        ],
      ),
      TablaInforme(
        titulo: SoleraL10n.t('mont.ingresos'),
        headers: cabecera,
        filas: filasApuntes(apuntes.where((apunte) => apunte.esIngreso), porId),
        mensajeSiVacia: SoleraL10n.t('mont.sin_apuntes'),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('mont.gastos'),
        headers: cabecera,
        filas:
            filasApuntes(apuntes.where((apunte) => !apunte.esIngreso), porId),
        mensajeSiVacia: SoleraL10n.t('mont.sin_apuntes'),
      ),
    ],
    operador: monte.titular.isEmpty ? null : monte.titular,
    tema: tema,
  );
}
