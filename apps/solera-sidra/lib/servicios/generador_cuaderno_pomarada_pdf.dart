import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/campania.dart';
import '../dominio/catalogos.dart';
import '../modelos/partida_manzana.dart';
import '../modelos/pomarada.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_sidra.dart';

/// Sello del documento hasta que el técnico de la pomarada valide el
/// formato frente al RD 1311/2012 (BLOQUEOS-PENDIENTES.md). Lo vigila
/// test/sello_provisional_test.dart.
const String selloCuadernoPomarada = 'PROVISIONAL';

/// Tablas del cuaderno de la pomarada de una campaña: parcelas,
/// tratamientos fitosanitarios y cosecha propia. Sin marcas ni dosis
/// propuestas: lo que hay es lo que la persona apuntó.
List<TablaInforme> tablasCuadernoPomarada({
  required List<Pomarada> pomaradas,
  required List<Tratamiento> tratamientos,
  required List<PartidaManzana> partidasPropias,
}) {
  final porId = {for (final pomarada in pomaradas) pomarada.id: pomarada};
  String parcela(int? id) {
    final pomarada = porId[id];
    if (pomarada == null) return '—';
    return pomarada.referenciaSigpac.isEmpty
        ? pomarada.nombre
        : '${pomarada.nombre} (${pomarada.referenciaSigpac})';
  }

  String texto(String valor) => valor.trim().isEmpty ? '—' : valor;
  String cultivoYVariedad(int? id) {
    final pomarada = porId[id];
    if (pomarada == null) return '—';
    return [
      nombreValor('cultivo', pomarada.cultivo),
      if (pomarada.variedades.isNotEmpty)
        pomarada.variedades.map(nombreVariedad).join(', '),
    ].join(': ');
  }

  return [
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_parcelas'),
      headers: [
        SoleraL10n.t('sidr.pdf_n_orden'),
        SoleraL10n.t('sidr.pomarada'),
        SoleraL10n.t('sidr.sigpac'),
        SoleraL10n.t('sidr.municipio'),
        'ha',
        SoleraL10n.t('sidr.pdf_arboles'),
        SoleraL10n.t('sidr.pdf_plantacion'),
        SoleraL10n.t('sidr.variedades'),
        SoleraL10n.t('sidr.dop'),
      ],
      filas: [
        for (final (indice, pomarada) in pomaradas.indexed)
          [
            '${indice + 1}',
            pomarada.nombre,
            texto(pomarada.referenciaSigpac),
            texto(pomarada.municipio),
            pomarada.superficieHa > 0
                ? formatearNumero(pomarada.superficieHa, decimales: 2)
                : '—',
            pomarada.numeroArboles > 0 ? '${pomarada.numeroArboles}' : '—',
            pomarada.anioPlantacion?.toString() ?? '—',
            pomarada.variedades.isEmpty
                ? '—'
                : pomarada.variedades.map(nombreVariedad).join(', '),
            pomarada.registradaDop
                ? SoleraL10n.t('sidr.si')
                : SoleraL10n.t('sidr.no'),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.pdf_sin_parcelas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_tratamientos'),
      headers: [
        SoleraL10n.t('sidr.fecha'),
        SoleraL10n.t('sidr.pomarada'),
        SoleraL10n.t('sidr.pdf_cultivo_variedad'),
        SoleraL10n.t('sidr.plaga_objetivo'),
        SoleraL10n.t('sidr.sustancia_activa'),
        SoleraL10n.t('sidr.pdf_producto'),
        SoleraL10n.t('sidr.pdf_cantidad'),
        'ha',
        SoleraL10n.t('sidr.pdf_equipo'),
        SoleraL10n.t('sidr.pdf_aplicador_asesor'),
        SoleraL10n.t('sidr.eficacia'),
      ],
      filas: [
        for (final tratamiento in [
          ...tratamientos
        ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs)))
          [
            formatearFecha(tratamiento.fechaMs),
            parcela(tratamiento.pomaradaId),
            cultivoYVariedad(tratamiento.pomaradaId),
            tratamiento.plagaObjetivoId.isEmpty
                ? SoleraL10n.t('sidr.preventivo')
                : nombrePlaga(tratamiento.plagaObjetivoId),
            tratamiento.sustanciaActivaId.isEmpty
                ? '—'
                : nombreSustancia(tratamiento.sustanciaActivaId),
            // El nombre comercial se completa a mano: la app no guarda marcas.
            '_____ · ${SoleraL10n.t('sidr.pdf_n_registro')} ${texto(tratamiento.numeroRegistroProducto)}',
            texto(tratamiento.cantidadAplicada),
            tratamiento.superficieTratadaHa == null
                ? '—'
                : formatearNumero(tratamiento.superficieTratadaHa!,
                    decimales: 2),
            texto(tratamiento.equipoAplicacion),
            [
              texto(tratamiento.aplicador),
              if (tratamiento.carnetAplicador.isNotEmpty)
                '(${tratamiento.carnetAplicador})',
              if (tratamiento.asesor.isNotEmpty)
                '· ${SoleraL10n.t('sidr.asesor')}: ${tratamiento.asesor}',
            ].join(' '),
            nombreValor('eficacia', tratamiento.eficacia),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.pdf_sin_tratamientos'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_cosecha_propia'),
      headers: [
        SoleraL10n.t('sidr.fecha_recoleccion'),
        SoleraL10n.t('sidr.fecha_entrega'),
        SoleraL10n.t('sidr.pomarada'),
        SoleraL10n.t('sidr.kilos'),
        SoleraL10n.t('sidr.variedades'),
        SoleraL10n.t('sidr.estado_fruta'),
      ],
      filas: [
        for (final partida in [
          ...partidasPropias
        ]..sort((a, b) => a.fechaEntregaMs.compareTo(b.fechaEntregaMs)))
          [
            partida.fechaRecoleccionMs == null
                ? '—'
                : formatearFecha(partida.fechaRecoleccionMs!),
            formatearFecha(partida.fechaEntregaMs),
            parcela(partida.pomaradaId),
            formatearNumero(partida.kilos, decimales: 0),
            partida.variedades.isEmpty
                ? '—'
                : partida.variedades.map(nombreVariedad).join(', '),
            nombreValor('estado_fruta', partida.estadoFruta),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.pdf_sin_cosecha'),
    ),
  ];
}

/// Cuaderno de la pomarada (fitosanitarios y cosecha) de una campaña.
Future<Uint8List> generarCuadernoPomaradaPdf({
  required int campania,
  required Titular titular,
  required List<Pomarada> pomaradas,
  required List<Tratamiento> tratamientos,
  required List<PartidaManzana> partidasPropias,
  pw.ThemeData? tema,
}) {
  final incompletos =
      tratamientos.where((tratamiento) => tratamiento.estaIncompleto).length;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('sidr.cuaderno_pomarada')} · ${nombreCampania(campania)}',
    subtituloCabecera: '${titular.nombre}'
        '${titular.nif.isEmpty ? '' : ' · NIF ${titular.nif}'}'
        '${titular.registroExplotacion.isEmpty ? '' : ' · REA ${titular.registroExplotacion}'}'
        ' · RD 1311/2012 · $selloCuadernoPomarada',
    bulletsResumen: [
      SoleraL10n.tf(
          'sidr.pdf_resumen_tratamientos', {'n': tratamientos.length}),
      if (incompletos > 0)
        SoleraL10n.tf('sidr.tratamientos_incompletos', {'n': incompletos}),
      SoleraL10n.t('sidr.aviso_no_recomienda'),
      SoleraL10n.t('sidr.pdf_nombre_comercial_a_mano'),
      SoleraL10n.t('sidr.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoPomarada(
      pomaradas: pomaradas,
      tratamientos: tratamientos,
      partidasPropias: partidasPropias,
    ),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
