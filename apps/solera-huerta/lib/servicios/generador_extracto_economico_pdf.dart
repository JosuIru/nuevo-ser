import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/parcela.dart';
import '../modelos/titular.dart';
import '../utiles/textos_huerta.dart';

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
              : '${SoleraL10n.t('huer.iva')} ${apunte.tipoIvaPorcentaje} %',
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
    SoleraL10n.t('huer.fecha'),
    SoleraL10n.t('huer.concepto'),
    SoleraL10n.t('huer.categoria'),
    SoleraL10n.t('huer.parcela'),
    SoleraL10n.t('huer.base'),
    SoleraL10n.t('huer.impuesto'),
    SoleraL10n.t('huer.total'),
  ];
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('huer.ingresos_y_gastos')} · $anyo',
    subtituloCabecera: '${titular.nombre}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'} · $selloExtractoEconomico',
    bulletsResumen: [
      '${SoleraL10n.t('huer.regimen_iva')}: ${nombreRegimenIva(configuracion.regimenIva)}',
      '${SoleraL10n.t('huer.ingresos')}: ${formatearEuros(resumen.ingresosBase)}',
      '${SoleraL10n.t('huer.gastos')}: ${formatearEuros(resumen.gastosBase)}',
      '${SoleraL10n.t('huer.resultado')}: ${formatearEuros(resumen.resultado)}',
      '${SoleraL10n.t('huer.compensaciones_reagp')}: ${formatearEuros(resumen.compensacionesReagp)}',
      '${SoleraL10n.t('huer.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('huer.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      SoleraL10n.t('huer.aviso_fiscal'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('huer.ingresos'),
        headers: cabecera,
        filas: filasApuntes(apuntes.where((apunte) => apunte.esIngreso), porId),
        mensajeSiVacia: SoleraL10n.t('huer.sin_apuntes'),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('huer.gastos'),
        headers: cabecera,
        filas:
            filasApuntes(apuntes.where((apunte) => !apunte.esIngreso), porId),
        mensajeSiVacia: SoleraL10n.t('huer.sin_apuntes'),
      ),
    ],
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
