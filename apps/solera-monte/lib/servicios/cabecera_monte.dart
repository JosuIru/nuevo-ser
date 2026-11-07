import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../modelos/monte.dart';
import '../utiles/textos_monte.dart';

/// Lo que se escribe en una celda vacía. Guion corto: la letra del PDF no
/// tiene la raya ni el «…» (salen como un cuadro).
const String vacioPdf = '-';

/// Texto o [vacioPdf] si está vacío.
String o(String texto) => texto.trim().isEmpty ? vacioPdf : texto.trim();

/// Número o [vacioPdf] si es null.
String numeroOGuion(num? valor, {int? decimales}) =>
    valor == null ? vacioPdf : formatearNumero(valor, decimales: decimales);

/// Línea de cabecera de los PDF: monte, titular, NIF, figura y CA.
String subtituloMonte(Monte monte, String sello) => [
      o(monte.nombre),
      if (monte.titular.isNotEmpty) monte.titular,
      if (monte.nif.isNotEmpty) monte.nif,
      nombreFigura(monte.figura),
      if (monte.comunidadAutonoma.isNotEmpty) monte.comunidadAutonoma,
      sello,
    ].join(' · ');

/// Datos de identificación del monte para el resumen de los PDF.
List<String> identificacionMonte(Monte monte) => [
      if (monte.municipio.isNotEmpty)
        '${SoleraL10n.t('mont.municipio')}: ${monte.municipio}',
      if (monte.numeroCatalogo.isNotEmpty)
        '${SoleraL10n.t('mont.numero_catalogo')}: ${monte.numeroCatalogo}',
      '${SoleraL10n.t('mont.instrumento_gestion')}: '
          '${nombreInstrumento(monte.instrumentoGestion)}'
          '${monte.referenciaInstrumento.isEmpty ? '' : ' (${monte.referenciaInstrumento})'}'
          '${monte.finVigenciaInstrumentoMs == null ? '' : ' · ${SoleraL10n.t('mont.vigente_hasta')} ${formatearFecha(monte.finVigenciaInstrumentoMs!)}'}',
      if (monte.tecnicoForestal.isNotEmpty)
        '${SoleraL10n.t('mont.tecnico_forestal')}: ${monte.tecnicoForestal}',
    ];
