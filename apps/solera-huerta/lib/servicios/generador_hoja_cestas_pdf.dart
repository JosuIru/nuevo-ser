import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../estado/semana_cestas.dart';
import '../modelos/titular.dart';
import '../provisional_core/venta_directa/semanas.dart';
import '../utiles/textos_huerta.dart';

/// Sello hasta que se verifique la normativa de venta directa (RD 1086/2020
/// y la autonómica de proximidad). Lo vigila test/sello_provisional_test.dart.
const String selloHojaCestas = 'PROVISIONAL';

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

String _cantidad(double kg, int piezas) => [
      if (kg > 0) formatearKilos(kg),
      if (piezas > 0) SoleraL10n.tf('huer.n_piezas', {'n': piezas}),
    ].join(' + ').ifEmpty('—');

extension on String {
  String ifEmpty(String otro) => isEmpty ? otro : this;
}

/// Tablas de la hoja de cestas de una semana: lo que hay que preparar por
/// cultivo (cosechado, repartido y sobrante), y el contenido y la entrega de
/// cada cesta. Funciones puras: se prueban sin PDF.
List<TablaInforme> tablasHojaCestas(SemanaCestas semana) {
  final suscripciones = semana.queTocan;
  final repartido = <int, ({double kg, int piezas, int cestas})>{};
  for (final suscripcion in suscripciones) {
    final cesta = semana.cestaDe(suscripcion.id!);
    if (cesta == null) continue;
    for (final linea in semana.lineasDe(cesta.id!)) {
      final anterior =
          repartido[linea.cultivoId] ?? (kg: 0.0, piezas: 0, cestas: 0);
      repartido[linea.cultivoId] = (
        kg: anterior.kg + linea.kg,
        piezas: anterior.piezas + (linea.unidades ?? 0),
        cestas: anterior.cestas + 1,
      );
    }
  }
  final cultivos = {...repartido.keys, ...semana.real.keys}.toList()..sort();
  return [
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_preparar_por_cultivo'),
      headers: [
        SoleraL10n.t('huer.cultivo'),
        SoleraL10n.t('huer.pdf_cosechado'),
        SoleraL10n.t('huer.pdf_repartido'),
        SoleraL10n.t('huer.pdf_n_cestas'),
        SoleraL10n.t('huer.pdf_sobrante'),
      ],
      filas: [
        for (final cultivoId in cultivos)
          () {
            final real = semana.real[cultivoId];
            final reparto = repartido[cultivoId];
            final kgReal = real?.kg ?? 0;
            final piezasReal = real?.unidades ?? 0;
            final kgRepartido = reparto?.kg ?? 0;
            final piezasRepartidas = reparto?.piezas ?? 0;
            final kgSobra = ((kgReal - kgRepartido) * 1000).round() / 1000;
            final piezasSobra = piezasReal - piezasRepartidas;
            return [
              semana.datos.nombreDeCultivo(cultivoId),
              _cantidad(kgReal, piezasReal),
              _cantidad(kgRepartido, piezasRepartidas),
              '${reparto?.cestas ?? 0}',
              real == null
                  ? '—'
                  : _cantidad(kgSobra > 0 ? kgSobra : 0,
                      piezasSobra > 0 ? piezasSobra : 0),
            ];
          }(),
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_cosecha_real'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_reparto_cestas'),
      headers: [
        SoleraL10n.t('huer.pdf_socio'),
        SoleraL10n.t('huer.tamano_cesta'),
        SoleraL10n.t('huer.punto_entrega'),
        SoleraL10n.t('huer.pdf_contenido'),
        SoleraL10n.t('huer.notas'),
        SoleraL10n.t('huer.entrega'),
      ],
      filas: [
        for (final suscripcion in suscripciones)
          () {
            final socio = semana.socio(suscripcion.socioId);
            final cesta = semana.cestaDe(suscripcion.id!);
            final entrega = cesta == null ? null : semana.entregaDe(cesta.id!);
            return [
              socio?.nombre ?? '?',
              nombreTamanoCesta(suscripcion.tamano),
              _o(socio?.puntoEntrega ?? ''),
              cesta == null
                  ? SoleraL10n.t('huer.sin_componer')
                  : _o(semana.resumenLineas(cesta.id!)),
              _o(socio?.notas ?? ''),
              entrega == null
                  ? '[ ]'
                  : '${nombreResultadoEntrega(entrega.resultado)} '
                      '${formatearFecha(entrega.fechaMs)}',
            ];
          }(),
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_cestas_semana'),
    ),
  ];
}

/// Hoja de cestas de la semana y de reparto, en PDF.
Future<Uint8List> generarHojaCestasPdf({
  required SemanaCestas semana,
  required Titular titular,
  pw.ThemeData? tema,
}) {
  final suscripciones = semana.queTocan;
  final compuestas =
      suscripciones.where((s) => semana.cestaDe(s.id!) != null).length;
  final nombre =
      titular.nombreHuerta.isEmpty ? titular.nombre : titular.nombreHuerta;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera: SoleraL10n.tf('huer.pdf_titulo_cestas', {
      'n': numeroSemanaIso(semana.lunes),
      'fecha': formatearFechaDia(semana.lunes),
    }),
    subtituloCabecera: '${_o(nombre)} · $selloHojaCestas',
    bulletsResumen: [
      SoleraL10n.tf('huer.pdf_resumen_cestas',
          {'total': suscripciones.length, 'compuestas': compuestas}),
      SoleraL10n.t('huer.pdf_nota_venta_directa'),
      SoleraL10n.t('huer.aviso_documento_provisional'),
    ],
    tablas: tablasHojaCestas(semana),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
