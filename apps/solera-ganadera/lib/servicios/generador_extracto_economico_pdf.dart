import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/titular.dart';
import '../utiles/textos_ganadera.dart';

/// Sello hasta que un asesor fiscal valide el régimen (REAGP o general), las
/// categorías y los porcentajes. Lo vigila test/sello_provisional_test.dart.
const String selloExtractoEconomico = 'PROVISIONAL';

/// Una fila del extracto (pura).
List<String> filaExtracto(ApunteEconomico apunte) => [
      formatearFecha(apunte.fechaMs),
      apunte.concepto,
      nombreCategoriaEconomica(apunte.categoria),
      apunte.tercero,
      formatearEuros(apunte.baseCentimos),
      '${apunte.esReagp ? 'REAGP' : SoleraL10n.t('gana.iva')} '
          '${formatearNumero(apunte.porcentaje, decimales: apunte.porcentaje % 1 == 0 ? 0 : 1)} %',
      formatearEuros(apunte.totalCentimos),
    ];

/// Extracto de ingresos y gastos de un periodo.
Future<Uint8List> generarExtractoEconomicoPdf({
  required String periodo,
  required Titular titular,
  required List<ApunteEconomico> apuntes,
  pw.ThemeData? tema,
}) {
  final resumen = ResumenEconomico.calcular(apuntes);
  final cabecera = [
    SoleraL10n.t('gana.fecha'),
    SoleraL10n.t('gana.concepto'),
    SoleraL10n.t('gana.categoria'),
    SoleraL10n.t('gana.tercero'),
    SoleraL10n.t('gana.base'),
    SoleraL10n.t('gana.iva_o_compensacion'),
    SoleraL10n.t('gana.total'),
  ];
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('gana.ingresos_y_gastos')} · $periodo',
    subtituloCabecera: [
      titular.nombre,
      titular.nif,
      selloExtractoEconomico,
    ].where((parte) => parte.isNotEmpty).join(' · '),
    bulletsResumen: [
      '${SoleraL10n.t('gana.ingresos')}: ${formatearEuros(resumen.ingresosBase)}',
      '${SoleraL10n.t('gana.gastos')}: ${formatearEuros(resumen.gastosBase)}',
      '${SoleraL10n.t('gana.resultado')}: ${formatearEuros(resumen.resultado)}',
      '${SoleraL10n.t('gana.compensacion_reagp')}: ${formatearEuros(resumen.compensacionReagp)} · '
          '${SoleraL10n.t('gana.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('gana.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      SoleraL10n.t('gana.aviso_fiscal'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('gana.ingresos'),
        headers: cabecera,
        filas: [
          for (final apunte in apuntes.where((apunte) => apunte.esIngreso))
            filaExtracto(apunte)
        ],
        mensajeSiVacia: SoleraL10n.t('gana.sin_apuntes'),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('gana.gastos'),
        headers: cabecera,
        filas: [
          for (final apunte in apuntes.where((apunte) => !apunte.esIngreso))
            filaExtracto(apunte)
        ],
        mensajeSiVacia: SoleraL10n.t('gana.sin_apuntes'),
      ),
    ],
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    marcaAgua: selloExtractoEconomico,
    tema: tema,
  );
}
