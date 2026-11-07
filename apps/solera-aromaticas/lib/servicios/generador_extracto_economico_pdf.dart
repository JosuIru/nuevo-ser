import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/parcela.dart';
import '../modelos/titular.dart';
import '../utiles/textos_aromaticas.dart';

/// Sello hasta que un asesor fiscal valide categorías, régimen y
/// porcentajes. Lo vigila test/sello_provisional_test.dart.
const String selloExtractoEconomico = 'PROVISIONAL';

/// Filas de una tabla de apuntes (función pura).
List<List<String>> filasApuntes(
        Iterable<ApunteEconomico> apuntes, Map<int, Parcela> parcelas) =>
    [
      for (final apunte in apuntes)
        [
          formatearFecha(apunte.fechaMs),
          apunte.concepto,
          nombreCategoriaEconomica(apunte.categoria),
          apunte.parcelaId == null
              ? '—'
              : parcelas[apunte.parcelaId]?.nombre ?? '#${apunte.parcelaId}',
          formatearEuros(apunte.baseCentimos),
          apunte.compensacionReagpPorcentaje > 0
              ? 'REAGP ${formatearNumero(apunte.compensacionReagpPorcentaje, decimales: 0)} %'
              : '${SoleraL10n.t('arom.iva')} ${apunte.tipoIvaPorcentaje} %',
          formatearEuros(apunte.totalCentimos),
        ],
    ];

/// Extracto de ingresos y gastos de un año.
Future<Uint8List> generarExtractoEconomicoPdf({
  required int anyo,
  required Titular titular,
  required ConfiguracionFiscal configuracion,
  required List<ApunteEconomico> apuntes,
  List<Parcela> parcelas = const [],
  pw.ThemeData? tema,
}) {
  final resumen = ResumenEconomico.calcular(apuntes);
  final porId = {for (final parcela in parcelas) parcela.id!: parcela};
  final cabecera = [
    SoleraL10n.t('arom.fecha'),
    SoleraL10n.t('arom.concepto'),
    SoleraL10n.t('arom.categoria'),
    SoleraL10n.t('arom.parcela'),
    SoleraL10n.t('arom.base'),
    SoleraL10n.t('arom.impuesto'),
    SoleraL10n.t('arom.total'),
  ];
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('arom.ingresos_y_gastos')} · $anyo',
    subtituloCabecera: '${titular.nombre}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'} · $selloExtractoEconomico',
    bulletsResumen: [
      '${SoleraL10n.t('arom.regimen_iva')}: ${nombreRegimenIva(configuracion.regimenIva)}',
      '${SoleraL10n.t('arom.ingresos')}: ${formatearEuros(resumen.ingresosBase)}',
      '${SoleraL10n.t('arom.gastos')}: ${formatearEuros(resumen.gastosBase)}',
      '${SoleraL10n.t('arom.resultado')}: ${formatearEuros(resumen.resultado)}',
      '${SoleraL10n.t('arom.compensaciones_reagp')}: ${formatearEuros(resumen.compensacionesReagp)}',
      '${SoleraL10n.t('arom.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('arom.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      SoleraL10n.t('arom.aviso_fiscal'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('arom.ingresos'),
        headers: cabecera,
        filas: filasApuntes(apuntes.where((apunte) => apunte.esIngreso), porId),
        mensajeSiVacia: SoleraL10n.t('arom.sin_apuntes'),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('arom.gastos'),
        headers: cabecera,
        filas:
            filasApuntes(apuntes.where((apunte) => !apunte.esIngreso), porId),
        mensajeSiVacia: SoleraL10n.t('arom.sin_apuntes'),
      ),
    ],
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
