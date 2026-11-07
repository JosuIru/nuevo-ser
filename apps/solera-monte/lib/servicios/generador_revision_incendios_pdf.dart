import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/incendios.dart';
import '../modelos/incendios.dart';
import '../modelos/monte.dart';
import '../utiles/textos_monte.dart';
import 'cabecera_monte.dart';

/// Sello hasta que el técnico forestal (y, si la hay, la norma autonómica de
/// prevención) valide el formato. Lo vigila test/sello_provisional_test.dart.
const String selloRevisionIncendios = 'PROVISIONAL';

class DatosRevisionIncendios {
  DatosRevisionIncendios({
    required this.anyo,
    required this.monte,
    this.infraestructuras = const [],
    this.revisiones = const [],
  });

  final int anyo;
  final Monte monte;
  final List<InfraestructuraIncendios> infraestructuras;

  /// Todas las revisiones (el PDF toma las del año).
  final List<RevisionIncendios> revisiones;
}

String _ubicacion(InfraestructuraIncendios infraestructura) {
  if (infraestructura.esLineal) {
    final metros = longitudInfraestructuraMetros(infraestructura);
    return metros > 0 ? '${formatearNumero(metros, decimales: 0)} m' : vacioPdf;
  }
  if (!infraestructura.tieneUbicacion) return vacioPdf;
  return '${infraestructura.latitud!.toStringAsFixed(5)}, '
      '${infraestructura.longitud!.toStringAsFixed(5)}';
}

/// Tablas de la hoja de revisión: el estado de cada infraestructura en la
/// campaña y todas las revisiones del año. Funciones puras.
List<TablaInforme> tablasRevisionIncendios(DatosRevisionIncendios datos) {
  final activas = datos.infraestructuras.where((i) => i.activa).toList();
  final delAnyo = datos.revisiones
      .where((r) =>
          DateTime.fromMillisecondsSinceEpoch(r.fechaMs).year == datos.anyo)
      .toList()
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final porId = {for (final i in datos.infraestructuras) i.id: i};
  return [
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_estado_campanya'),
      headers: [
        SoleraL10n.t('mont.infraestructura'),
        SoleraL10n.t('mont.nombre'),
        SoleraL10n.t('mont.pdf_ubicacion_longitud'),
        SoleraL10n.t('mont.capacidad_m3'),
        SoleraL10n.t('mont.pdf_estado'),
        SoleraL10n.t('mont.pdf_ultima_revision'),
        SoleraL10n.t('mont.trabajos_necesarios'),
      ],
      filas: [
        for (final infraestructura in activas)
          () {
            final ultima = delAnyo
                .where((r) => r.infraestructuraId == infraestructura.id)
                .lastOrNull;
            return [
              nombreTipoInfraestructura(infraestructura.tipo),
              infraestructura.nombre,
              _ubicacion(infraestructura),
              numeroOGuion(infraestructura.capacidadM3),
              textoEstadoCampanya(estadoCampanya(
                  infraestructura, datos.revisiones, datos.anyo)),
              ultima == null ? vacioPdf : formatearFecha(ultima.fechaMs),
              ultima == null ? vacioPdf : o(ultima.trabajosNecesarios),
            ];
          }(),
      ],
      mensajeSiVacia: SoleraL10n.t('mont.sin_infraestructuras'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('mont.pdf_revisiones_anyo'),
      headers: [
        SoleraL10n.t('mont.fecha'),
        SoleraL10n.t('mont.infraestructura'),
        SoleraL10n.t('mont.pdf_estado'),
        SoleraL10n.t('mont.trabajos_necesarios'),
        SoleraL10n.t('mont.revisor'),
      ],
      filas: [
        for (final revision in delAnyo)
          [
            formatearFecha(revision.fechaMs),
            porId[revision.infraestructuraId]?.nombre ??
                '#${revision.infraestructuraId}',
            nombreEstadoRevision(revision.estado),
            o(revision.trabajosNecesarios),
            o(revision.revisor),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('mont.sin_revisiones'),
    ),
  ];
}

/// Hoja de revisión de las infraestructuras de incendios de un año en PDF.
Future<Uint8List> generarRevisionIncendiosPdf(DatosRevisionIncendios datos,
    {pw.ThemeData? tema}) {
  final monte = datos.monte;
  final inicio = monte.inicioEpocaPeligroEn(datos.anyo);
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('mont.hoja_revision_incendios')} · ${datos.anyo}',
    subtituloCabecera: subtituloMonte(monte, selloRevisionIncendios),
    bulletsResumen: [
      ...identificacionMonte(monte),
      inicio == null
          ? SoleraL10n.t('mont.pdf_sin_epoca_peligro')
          : SoleraL10n.tf('mont.epoca_peligro_empieza',
              {'fecha': formatearFecha(inicio.millisecondsSinceEpoch)}),
      SoleraL10n.t('mont.pdf_aviso_incendios'),
      SoleraL10n.t('mont.aviso_documento_provisional'),
    ],
    tablas: tablasRevisionIncendios(datos),
    operador: monte.titular.isEmpty ? null : monte.titular,
    tema: tema,
  );
}
