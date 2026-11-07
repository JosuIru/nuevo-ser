import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../modelos/explotacion.dart';
import '../modelos/ganado.dart';
import '../modelos/titular.dart';
import '../utiles/textos_ganadera.dart';

/// Sello hasta que un veterinario asesor (o la OCA) valide el formato.
/// Lo vigila test/sello_provisional_test.dart.
const String selloDocumentoMovimiento = 'PROVISIONAL';

/// Fuente con la que se ha montado el documento (se imprime en el PDF).
const String fuenteDocumentoMovimiento =
    'RD 787/2023, art. 20 y disposición final 3.ª, que da nueva redacción al '
    'anexo de datos mínimos del documento de movimiento del RD 728/2007 '
    '(BOE-A-2023-22499, consolidado 24/12/2024), consultado el 2026-11-07';

/// Las tablas del documento de movimiento (pura), en el orden del anexo:
/// 1 explotación de origen, 2 de destino, 3 datos del movimiento y animales,
/// 4 conformidades. En una entrada, la explotación propia es el destino.
List<TablaInforme> tablasDocumentoMovimiento({
  required MovimientoGanado movimiento,
  required LoteGanado lote,
  required List<Animal> animalesDelLote,
  required Titular titular,
  required Explotacion explotacion,
}) {
  String t(String clave) => SoleraL10n.t(clave);
  final propia = [
    [t('gana.codigo_rega'), explotacion.codigoRega],
    [
      t('gana.col_titular_nif'),
      [titular.nombre, titular.nif]
          .where((parte) => parte.isNotEmpty)
          .join(' · ')
    ],
    [t('gana.municipio'), explotacion.municipio],
    [t('gana.provincia'), explotacion.provincia],
  ];
  final otra = [
    [t('gana.codigo_rega'), movimiento.explotacionExterna],
    [t('gana.col_titular_nif'), movimiento.titularExterno],
    [t('gana.municipio'), movimiento.municipioExterno],
    [t('gana.provincia'), movimiento.provinciaExterna],
  ];
  final esEntrada = movimiento.esEntradaEnExplotacion;
  final identificaciones = movimiento.identificaciones.trim().isNotEmpty
      ? movimiento.identificaciones
          .split(',')
          .map((parte) => parte.trim())
          .where((parte) => parte.isNotEmpty)
          .toList()
      : [
          for (final animal in animalesDelLote.where((animal) => animal.activo))
            if (animal.identificacion.isNotEmpty) animal.identificacion
        ];
  final cabeceraDato = [t('gana.col_dato'), t('gana.col_valor')];
  return [
    TablaInforme(
        titulo: t('gana.mov_origen'),
        headers: cabeceraDato,
        filas: esEntrada ? otra : propia),
    TablaInforme(
        titulo: t('gana.mov_destino'),
        headers: cabeceraDato,
        filas: esEntrada ? propia : otra),
    TablaInforme(
      titulo: t('gana.mov_datos'),
      headers: cabeceraDato,
      filas: [
        [t('gana.codigo_remo'), movimiento.codigoRemo],
        [t('gana.col_fecha_salida'), formatearFecha(movimiento.fechaMs)],
        [
          t('gana.col_llegada_prevista'),
          formatearFecha(movimiento.fechaLlegadaPrevistaMs)
        ],
        [t('gana.especie'), nombreEspecie(lote.especie)],
        [
          t('gana.col_numero'),
          movimiento.cabezas > 0
              ? '${movimiento.cabezas}'
              : '${identificaciones.length}'
        ],
        [t('gana.medio_transporte'), movimiento.codigoTransporte],
        [t('gana.col_tipo_transporte'), movimiento.tipoTransporte],
        [
          t('gana.autorizacion_transportista'),
          movimiento.autorizacionTransportista
        ],
        [t('gana.certificado_sanitario'), movimiento.certificadoSanitario],
        [
          t('gana.col_fecha_certificado'),
          formatearFecha(movimiento.fechaCertificadoMs)
        ],
      ],
    ),
    TablaInforme(
      titulo: t('gana.mov_identificacion'),
      headers: [t('gana.col_numero'), t('gana.col_identificacion')],
      filas: [
        for (var indice = 0; indice < identificaciones.length; indice++)
          ['${indice + 1}', identificaciones[indice]]
      ],
      mensajeSiVacia: t('gana.mov_sin_identificacion'),
    ),
    TablaInforme(
      titulo: t('gana.mov_conformidades'),
      headers: [t('gana.col_dato'), t('gana.col_firma')],
      filas: [
        [t('gana.mov_conformidad_origen'), ''],
        [t('gana.mov_conformidad_destino'), ''],
        [t('gana.mov_fecha_llegada'), ''],
      ],
    ),
  ];
}

/// El documento de un movimiento con explotación externa, para imprimir o
/// enviar. **No es el documento oficial**: lo emite o valida la autoridad
/// competente (SITRAN, la OCA o la sede de la comunidad).
Future<Uint8List> generarDocumentoMovimientoPdf({
  required MovimientoGanado movimiento,
  required LoteGanado lote,
  required List<Animal> animalesDelLote,
  required Titular titular,
  required Explotacion explotacion,
  pw.ThemeData? tema,
}) =>
    generarInformePeriodicoPdfBytes(
      tituloCabecera: SoleraL10n.t('gana.documento_movimiento'),
      subtituloCabecera: [
        lote.nombre,
        nombreTipoMovimiento(movimiento.tipo),
        formatearFecha(movimiento.fechaMs),
        selloDocumentoMovimiento,
      ].join(' · '),
      bulletsResumen: [
        SoleraL10n.t('gana.mov_aviso_no_oficial'),
        '${SoleraL10n.t('gana.fuente')}: $fuenteDocumentoMovimiento',
      ],
      tablas: tablasDocumentoMovimiento(
          movimiento: movimiento,
          lote: lote,
          animalesDelLote: animalesDelLote,
          titular: titular,
          explotacion: explotacion),
      operador: titular.nombre.isEmpty ? null : titular.nombre,
      marcaAgua: selloDocumentoMovimiento,
      tema: tema,
    );
