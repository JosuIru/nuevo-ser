import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/informe_ecoregimen.dart';
import '../modelos/explotacion.dart';
import '../modelos/titular.dart';
import '../utiles/textos_ganadera.dart';

/// Sello hasta que un técnico PAC valide la lectura del eco-régimen. Lo
/// vigila test/sello_provisional_test.dart.
const String selloInformeEcoregimen = 'PROVISIONAL';

const String fuenteInformeEcoregimen =
    'RD 1048/2022, art. 30.2 y anexo V (BOE-A-2022-23048, consolidado '
    '08/07/2026), consultado el 2026-11-07';

String _carga(double? valor) =>
    valor == null ? '—' : formatearNumero(valor, decimales: 2);

/// Avisos de una pieza, en texto.
String avisosDeRecinto(InformeRecinto informe) {
  final parametros = informe.parametros;
  return [
    if (informe.sinSuperficie) SoleraL10n.t('gana.eco_sin_superficie'),
    if (informe.pocosDias)
      SoleraL10n.tf('gana.eco_pocos_dias', {'n': parametros!.diasMinimos}),
    if (informe.cargaPorDebajo)
      SoleraL10n.tf('gana.eco_por_debajo',
          {'minimo': formatearNumero(parametros!.cargaMinima, decimales: 2)}),
    if (informe.cargaPorEncima)
      SoleraL10n.tf('gana.eco_por_encima',
          {'maximo': formatearNumero(parametros!.cargaMaxima, decimales: 2)}),
  ].join(' · ');
}

/// La tabla por recinto (pura).
List<TablaInforme> tablasInformeEcoregimen(List<InformeRecinto> informes) => [
      TablaInforme(
        titulo: SoleraL10n.t('gana.eco_por_recinto'),
        headers: [
          SoleraL10n.t('gana.col_pieza'),
          SoleraL10n.t('gana.recinto_sigpac'),
          SoleraL10n.t('gana.tipo_pasto'),
          'ha',
          SoleraL10n.t('gana.col_dias_ganado'),
          SoleraL10n.t('gana.col_ugm_media'),
          SoleraL10n.t('gana.col_carga_media'),
          SoleraL10n.t('gana.col_carga_min_max'),
          SoleraL10n.t('gana.col_avisos'),
        ],
        filas: [
          for (final informe in informes)
            [
              informe.pieza.nombre,
              informe.pieza.recintoSigpac,
              nombreTipoPasto(informe.pieza.tipoPasto),
              informe.pieza.superficieHa == null
                  ? '—'
                  : formatearNumero(informe.pieza.superficieHa!, decimales: 2),
              '${informe.diasConGanado}',
              formatearNumero(informe.ugmDiaMedia, decimales: 2),
              _carga(informe.cargaMedia),
              '${_carga(informe.cargaMinima)} – ${_carga(informe.cargaMaxima)}',
              avisosDeRecinto(informe),
            ]
        ],
        mensajeSiVacia: SoleraL10n.t('gana.sin_piezas'),
      ),
    ];

/// El informe del eco-régimen de una campaña. **Ayuda, no declaración.**
Future<Uint8List> generarInformeEcoregimenPdf({
  required int campana,
  required String nombreTramite,
  required List<InformeRecinto> informes,
  required Titular titular,
  required Explotacion explotacion,
  pw.ThemeData? tema,
}) =>
    generarInformePeriodicoPdfBytes(
      tituloCabecera: '${SoleraL10n.t('gana.informe_ecoregimen')} $campana',
      subtituloCabecera: [
        explotacion.codigoRega,
        titular.nombre,
        selloInformeEcoregimen,
      ].where((parte) => parte.isNotEmpty).join(' · '),
      bulletsResumen: [
        SoleraL10n.t('gana.eco_aviso_ayuda'),
        SoleraL10n.tf('gana.eco_tabla_usada', {'tabla': nombreTramite}),
        SoleraL10n.t('gana.eco_como_se_calcula'),
        '${SoleraL10n.t('gana.fuente')}: $fuenteInformeEcoregimen',
      ],
      tablas: tablasInformeEcoregimen(informes),
      operador: titular.nombre.isEmpty ? null : titular.nombre,
      marcaAgua: selloInformeEcoregimen,
      tema: tema,
    );
