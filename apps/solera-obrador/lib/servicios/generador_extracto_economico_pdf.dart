import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/titular.dart';
import '../utiles/textos_obrador.dart';

/// Sello hasta que un asesor fiscal valide categorías y tipos de IVA.
/// Lo vigila test/sello_provisional_test.dart.
const String selloExtractoEconomico = 'PROVISIONAL';

/// Extracto de ingresos y gastos de un periodo.
Future<Uint8List> generarExtractoEconomicoPdf({
  required String periodo,
  required Titular titular,
  required List<ApunteEconomico> apuntes,
  pw.ThemeData? tema,
}) {
  final resumen = ResumenEconomico.calcular(apuntes);
  final formato = DateFormat('dd/MM/yyyy');
  List<String> fila(ApunteEconomico apunte) => [
        formato.format(DateTime.fromMillisecondsSinceEpoch(apunte.fechaMs)),
        apunte.concepto,
        nombreCategoriaEconomica(apunte.categoria),
        formatearEuros(apunte.baseCentimos),
        '${apunte.tipoIvaPorcentaje} %',
        formatearEuros(apunte.totalCentimos),
      ];
  final cabecera = [
    SoleraL10n.t('obra.fecha'),
    SoleraL10n.t('obra.concepto'),
    SoleraL10n.t('obra.categoria'),
    SoleraL10n.t('obra.base'),
    SoleraL10n.t('obra.iva'),
    SoleraL10n.t('obra.total'),
  ];
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('obra.ingresos_y_gastos')} · $periodo',
    subtituloCabecera: '${titular.nombre}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'} · $selloExtractoEconomico',
    bulletsResumen: [
      '${SoleraL10n.t('obra.ingresos')}: ${formatearEuros(resumen.ingresosBase)}',
      '${SoleraL10n.t('obra.gastos')}: ${formatearEuros(resumen.gastosBase)}',
      '${SoleraL10n.t('obra.resultado')}: ${formatearEuros(resumen.resultado)}',
      '${SoleraL10n.t('obra.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('obra.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      SoleraL10n.t('obra.aviso_fiscal'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('obra.ingresos'),
        headers: cabecera,
        filas: [
          for (final apunte in apuntes.where((apunte) => apunte.esIngreso))
            fila(apunte)
        ],
        mensajeSiVacia: SoleraL10n.t('obra.sin_apuntes'),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('obra.gastos'),
        headers: cabecera,
        filas: [
          for (final apunte in apuntes.where((apunte) => !apunte.esIngreso))
            fila(apunte)
        ],
        mensajeSiVacia: SoleraL10n.t('obra.sin_apuntes'),
      ),
    ],
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
