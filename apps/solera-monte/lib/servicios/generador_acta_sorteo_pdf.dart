import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/sorteo_lena.dart';
import '../modelos/monte.dart';
import '../modelos/rodal.dart';
import '../modelos/sorteo_lena.dart';
import '../utiles/textos_monte.dart';
import 'cabecera_monte.dart';

/// Sello hasta que la secretaría de una junta o comunidad piloto valide el
/// formato del acta. Lo vigila test/sello_provisional_test.dart.
const String selloActaSorteo = 'PROVISIONAL';

/// La clave en cuatro grupos de 16 caracteres, para que quepa en la tabla.
String claveEnGrupos(String clave) => [
      for (var inicio = 0; inicio < clave.length; inicio += 16)
        clave.substring(inicio, (inicio + 16).clamp(0, clave.length))
    ].join(' ');

/// Tablas del acta: lista cerrada (en su orden, la de la huella), lotes con
/// su adjudicatario y el orden completo con la clave de cada puesto, para
/// que cualquiera lo repita. Funciones puras.
List<TablaInforme> tablasActaSorteo({
  required SorteoLena sorteo,
  required List<LoteLena> lotes,
  List<Rodal> rodales = const [],
}) {
  final rodalPorId = {for (final rodal in rodales) rodal.id: rodal};
  ResultadoSorteo? resultado;
  if (sorteo.realizado) {
    try {
      resultado = sortear(
          semilla: sorteo.semilla,
          participantes: sorteo.participantes,
          numerosLote: [for (final lote in lotes) lote.numero]);
    } on SorteoNoValido {
      resultado = null;
    }
  }
  final ordenados = [...lotes]..sort((a, b) => a.numero.compareTo(b.numero));
  return [
    TablaInforme(
      titulo: SoleraL10n.t('mont.paso_lista'),
      headers: ['#', SoleraL10n.t('mont.pdf_participante')],
      filas: [
        for (final (indice, participante) in sorteo.participantes.indexed)
          ['${indice + 1}', participante],
      ],
      mensajeSiVacia: SoleraL10n.t('mont.lista_vacia'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_lotes_adjudicados'),
      headers: [
        SoleraL10n.t('mont.numero_lote'),
        SoleraL10n.t('mont.rodal'),
        SoleraL10n.t('mont.estereos_lote'),
        SoleraL10n.t('mont.donde_esta_lote'),
        SoleraL10n.t('mont.pdf_adjudicatario'),
      ],
      filas: [
        for (final lote in ordenados)
          [
            '${lote.numero}',
            rodalPorId[lote.rodalId]?.etiqueta ?? vacioPdf,
            numeroOGuion(lote.cantidad),
            o(lote.descripcion),
            lote.adjudicado
                ? lote.adjudicatario
                : SoleraL10n.t('mont.sin_adjudicar'),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('mont.faltan_lotes'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_orden_sorteo'),
      headers: [
        SoleraL10n.t('mont.pdf_puesto'),
        SoleraL10n.t('mont.pdf_participante'),
        SoleraL10n.t('mont.pdf_clave_sha256'),
        SoleraL10n.t('mont.lote'),
      ],
      filas: [
        if (resultado != null)
          for (final puesto in resultado.orden)
            [
              '${puesto.posicion}',
              puesto.participante,
              claveEnGrupos(puesto.clave),
              puesto.numeroLote == null
                  ? SoleraL10n.t('mont.lista_espera')
                  : '${puesto.numeroLote}',
            ],
      ],
      mensajeSiVacia: SoleraL10n.t('mont.pdf_sin_sortear'),
    ),
  ];
}

/// Acta del sorteo de lotes de leña en PDF, para colgar en el tablón.
Future<Uint8List> generarActaSorteoPdf({
  required Monte monte,
  required SorteoLena sorteo,
  required List<LoteLena> lotes,
  List<Rodal> rodales = const [],
  pw.ThemeData? tema,
}) {
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('mont.acta_sorteo')} · ${sorteo.nombre.isEmpty ? sorteo.campanya : sorteo.nombre}',
    subtituloCabecera: subtituloMonte(monte, selloActaSorteo),
    bulletsResumen: [
      if (sorteo.fechaCierreListaMs != null)
        SoleraL10n.tf('mont.lista_cerrada_el',
            {'fecha': formatearFecha(sorteo.fechaCierreListaMs!)}),
      '${SoleraL10n.t('mont.huella_lista')}: ${o(sorteo.huellaParticipantes)}',
      '${SoleraL10n.t('mont.semilla')}: ${o(sorteo.semilla)}'
          '${sorteo.origenSemilla.isEmpty ? '' : ' (${sorteo.origenSemilla})'}',
      if (sorteo.fechaSorteoMs != null)
        '${SoleraL10n.t('mont.pdf_fecha_sorteo')}: ${formatearFecha(sorteo.fechaSorteoMs!)}',
      SoleraL10n.t('mont.como_verificar'),
      SoleraL10n.t('mont.participantes_ayuda'),
      SoleraL10n.t('mont.pdf_firmas'),
      SoleraL10n.t('mont.aviso_documento_provisional'),
    ],
    tablas: tablasActaSorteo(sorteo: sorteo, lotes: lotes, rodales: rodales),
    operador: monte.titular.isEmpty ? null : monte.titular,
    tema: tema,
  );
}
