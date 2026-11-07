import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/resumen_economico.dart';
import '../modelos/apunte_economico.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/vivero.dart';
import '../utiles/textos_vivero.dart';

/// Sello hasta que un asesor fiscal valide régimen, tipos y categorías. Lo
/// vigila test/sello_provisional_test.dart.
const String selloExtractoEconomico = 'PROVISIONAL';

String _identidad(String texto) => texto;

/// Filas de las ventas de planta (función pura).
List<List<String>> filasVentas(Iterable<VentaPlanta> ventas,
        {String Function(String) nombreEspecie = _identidad}) =>
    [
      for (final venta in [
        ...ventas
      ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs)))
        [
          formatearFecha(venta.fechaMs),
          nombreEspecie(venta.especieId),
          '${venta.cantidad}',
          venta.cliente.isEmpty ? '—' : venta.cliente,
          formatearEuros(venta.baseCentimos),
        ],
    ];

/// Filas de una tabla de apuntes (función pura).
List<List<String>> filasApuntes(Iterable<ApunteEconomico> apuntes) => [
      for (final apunte in apuntes)
        [
          formatearFecha(apunte.fechaMs),
          apunte.concepto,
          nombreCategoriaEconomica(apunte.categoria),
          formatearEuros(apunte.baseCentimos),
          apunte.compensacionReagpPorcentaje > 0
              ? 'REAGP ${formatearNumero(apunte.compensacionReagpPorcentaje, decimales: 0)} %'
              : '${SoleraL10n.t('vive.iva')} ${apunte.tipoIvaPorcentaje} %',
          formatearEuros(apunte.totalCentimos),
        ],
    ];

/// Extracto de ingresos y gastos de un año, con las ventas de planta.
Future<Uint8List> generarExtractoEconomicoPdf({
  required int anyo,
  required Vivero vivero,
  required ConfiguracionFiscal configuracion,
  required List<ApunteEconomico> apuntes,
  required List<VentaPlanta> ventas,
  String Function(String) nombreEspecie = _identidad,
  pw.ThemeData? tema,
}) {
  final resumen = ResumenEconomico.calcular(
      apuntes: apuntes, ventas: ventas, configuracion: configuracion);
  final cabecera = [
    SoleraL10n.t('vive.fecha'),
    SoleraL10n.t('vive.concepto'),
    SoleraL10n.t('vive.categoria'),
    SoleraL10n.t('vive.base'),
    SoleraL10n.t('vive.impuesto'),
    SoleraL10n.t('vive.total'),
  ];
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: '${SoleraL10n.t('vive.ingresos_y_gastos')} · $anyo',
    subtituloCabecera: '${vivero.nombre}'
        '${vivero.nif.isEmpty ? '' : ' · ${vivero.nif}'} · $selloExtractoEconomico',
    bulletsResumen: [
      '${SoleraL10n.t('vive.regimen_iva')}: ${nombreRegimenIva(configuracion.regimenIva)}',
      '${SoleraL10n.t('vive.ventas_planta')}: ${formatearEuros(resumen.ventasBase)}',
      '${SoleraL10n.t('vive.ingresos')}: ${formatearEuros(resumen.ingresosBase)}',
      '${SoleraL10n.t('vive.gastos')}: ${formatearEuros(resumen.gastosBase)}',
      '${SoleraL10n.t('vive.resultado')}: ${formatearEuros(resumen.resultado)}',
      '${SoleraL10n.t('vive.compensaciones_reagp')}: ${formatearEuros(resumen.compensacionesReagp)}',
      '${SoleraL10n.t('vive.iva_repercutido')}: ${formatearEuros(resumen.ivaRepercutido)} · '
          '${SoleraL10n.t('vive.iva_soportado')}: ${formatearEuros(resumen.ivaSoportado)}',
      SoleraL10n.t('vive.aviso_fiscal'),
    ],
    tablas: [
      TablaInforme(
        titulo: SoleraL10n.t('vive.ventas_planta'),
        headers: [
          SoleraL10n.t('vive.fecha'),
          SoleraL10n.t('vive.especie'),
          SoleraL10n.t('vive.cantidad'),
          SoleraL10n.t('vive.cliente'),
          SoleraL10n.t('vive.base'),
        ],
        filas: filasVentas(ventas, nombreEspecie: nombreEspecie),
        mensajeSiVacia: SoleraL10n.t('vive.sin_ventas'),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('vive.otros_ingresos'),
        headers: cabecera,
        filas: filasApuntes(apuntes.where((apunte) => apunte.esIngreso)),
      ),
      TablaInforme(
        titulo: SoleraL10n.t('vive.gastos'),
        headers: cabecera,
        filas: filasApuntes(apuntes.where((apunte) => !apunte.esIngreso)),
        mensajeSiVacia: SoleraL10n.t('vive.sin_apuntes'),
      ),
    ],
    operador: vivero.nombre.isEmpty ? null : vivero.nombre,
    tema: tema,
  );
}
