import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/catalogos.dart';
import '../dominio/rotacion.dart';
import '../estado/datos_huerta.dart';
import '../modelos/cosecha.dart';
import '../modelos/observacion_plaga.dart';
import '../modelos/titular.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_huerta.dart';

/// Sello hasta que el organismo de control (o un técnico de certificación)
/// valide el formato. Lo vigila test/sello_provisional_test.dart.
const String selloCuadernoEcologico = 'PROVISIONAL';

/// Años de historial de rotación que se muestran por bancal.
const int aniosHistorialRotacion = 4;

String _o(String texto) => texto.trim().isEmpty ? '—' : texto.trim();

String _numero(num? valor, {int decimales = 1}) =>
    valor == null ? '—' : formatearNumero(valor, decimales: decimales);

/// Todo lo que va en el cuaderno de un año.
class DatosCuadernoEcologico {
  DatosCuadernoEcologico({
    required this.anyo,
    required this.titular,
    required this.datos,
    this.cosechas = const [],
    this.aplicaciones = const [],
    this.observaciones = const [],
  });

  final int anyo;
  final Titular titular;

  /// Parcelas, bancales, cultivos, lotes, insumos y **todas** las siembras
  /// (el historial de rotación mira años anteriores).
  final DatosHuerta datos;
  final List<Cosecha> cosechas;
  final List<Tratamiento> aplicaciones;

  /// Muestreos de plagas: acreditan la necesidad de los fitosanitarios.
  final List<ObservacionPlaga> observaciones;
}

/// Tablas del cuaderno de campo para el certificador ecológico, en este
/// orden: parcelas, rotación por bancal, siembras y plantaciones, semillas
/// usadas, observaciones de plagas, insumos aplicados, tratamientos fitosanitarios (RD 1311/2012),
/// cosechas y totales por cultivo. Funciones puras: se prueban sin PDF.
List<TablaInforme> tablasCuadernoEcologico(DatosCuadernoEcologico entrada) {
  final datos = entrada.datos;
  final (desde, hasta) = intervaloAnyo(entrada.anyo);
  final ordenParcela = {
    for (var indice = 0; indice < datos.parcelas.length; indice++)
      datos.parcelas[indice].id!: indice + 1
  };
  String lugar(int parcelaId, int? bancalId) {
    final parcela = datos.parcela(parcelaId);
    final prefijo =
        '${ordenParcela[parcelaId] ?? '?'} · ${parcela?.nombre ?? '?'}';
    final bancal = datos.bancal(bancalId);
    return bancal == null ? prefijo : '$prefijo · ${bancal.nombre}';
  }

  String lugarBancal(int bancalId) =>
      lugar(datos.bancal(bancalId)?.parcelaId ?? -1, bancalId);

  final siembrasAnyo = [
    for (final siembra in datos.siembras)
      if (siembra.realizada &&
          siembra.fechaRealMs! >= desde &&
          siembra.fechaRealMs! <= hasta)
        siembra
  ]..sort((a, b) => a.fechaRealMs!.compareTo(b.fechaRealMs!));
  final historial = datos.historialRotacion
      .where((paso) => datos.siembras
          .any((siembra) => siembra.id == paso.siembraId && siembra.realizada))
      .toList();
  final reglas = aniosMinimosPorFamilia();
  final lotesUsados = {
    for (final siembra in siembrasAnyo)
      if (siembra.loteSemillaId != null) siembra.loteSemillaId!
  };
  final aplicaciones = [...entrada.aplicaciones]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final fitosanitarios = [
    for (final aplicacion in aplicaciones)
      if (datos.insumo(aplicacion.insumoId)?.esFitosanitario ?? false)
        aplicacion
  ];
  final cosechas = [...entrada.cosechas]
    ..sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
  final totales = <int, ({double kg, int piezas, int pasadas})>{};
  for (final cosecha in cosechas) {
    final anterior =
        totales[cosecha.cultivoId] ?? (kg: 0.0, piezas: 0, pasadas: 0);
    totales[cosecha.cultivoId] = (
      kg: anterior.kg + cosecha.kg,
      piezas: anterior.piezas + (cosecha.unidades ?? 0),
      pasadas: anterior.pasadas + 1,
    );
  }
  final anyosHistorial = [
    for (var desfase = aniosHistorialRotacion - 1; desfase >= 0; desfase--)
      entrada.anyo - desfase
  ];

  return [
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_parcelas'),
      headers: [
        SoleraL10n.t('huer.pdf_orden'),
        SoleraL10n.t('huer.codigo_sigpac'),
        SoleraL10n.t('huer.parcela'),
        'ha',
        SoleraL10n.t('huer.estado_ecologico'),
        SoleraL10n.t('huer.inicio_conversion'),
        SoleraL10n.t('huer.bancales'),
      ],
      filas: [
        for (final parcela in datos.parcelas)
          [
            '${ordenParcela[parcela.id]}',
            _o(parcela.codigoSigpac),
            parcela.nombre,
            _numero(parcela.superficieHa, decimales: 2),
            nombreEstadoEcologico(parcela.estadoEcologico),
            parcela.fechaInicioConversionMs == null
                ? '—'
                : formatearFecha(parcela.fechaInicioConversionMs!),
            '${datos.bancales.where((bancal) => bancal.parcelaId == parcela.id).length}',
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_parcelas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_rotacion_bancal'),
      headers: [
        SoleraL10n.t('huer.bancal'),
        for (final anyo in anyosHistorial) '$anyo',
      ],
      filas: [
        for (final bancal in datos.bancales)
          [
            lugarBancal(bancal.id!),
            for (final anyo in anyosHistorial)
              _o({
                for (final paso in historial)
                  if (paso.bancalId == bancal.id && paso.fecha.year == anyo)
                    nombreFamilia(paso.familiaId)
              }.join(', ')),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_bancales'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_siembras'),
      headers: [
        SoleraL10n.t('huer.fecha'),
        SoleraL10n.t('huer.bancal'),
        SoleraL10n.t('huer.cultivo'),
        SoleraL10n.t('huer.familia_botanica'),
        SoleraL10n.t('huer.tipo_siembra'),
        SoleraL10n.t('huer.cantidad'),
        SoleraL10n.t('huer.lote_semilla'),
        SoleraL10n.t('huer.pdf_rotacion'),
      ],
      filas: [
        for (final siembra in siembrasAnyo)
          [
            formatearFecha(siembra.fechaRealMs!),
            lugarBancal(siembra.bancalId),
            datos.nombreDeCultivo(siembra.cultivoId),
            _o(nombreFamilia(
                datos.cultivo(siembra.cultivoId)?.familiaId ?? '')),
            nombreTipoSiembra(siembra.tipo),
            siembra.cantidad == null
                ? '—'
                : '${_numero(siembra.cantidad, decimales: 0)} ${nombreUnidadSiembra(siembra.unidad)}',
            _o(datos.lote(siembra.loteSemillaId)?.codigo ?? ''),
            () {
              final cultivo = datos.cultivo(siembra.cultivoId);
              if (cultivo == null ||
                  !reglas.containsKey(normalizarFamilia(cultivo.familiaId))) {
                return SoleraL10n.t('huer.pdf_sin_dato');
              }
              final aviso = comprobarRotacion(
                bancalId: siembra.bancalId,
                familiaId: cultivo.familiaId,
                fecha:
                    DateTime.fromMillisecondsSinceEpoch(siembra.fechaRealMs!),
                historial: historial,
                aniosMinimosPorFamilia: reglas,
                excluirSiembraId: siembra.id,
              );
              return aviso == null
                  ? SoleraL10n.t('huer.pdf_sin_aviso')
                  : SoleraL10n.tf('huer.pdf_aviso_rotacion', {
                      'fecha': formatearFechaDia(aviso.fechaAnterior),
                      'n': aviso.aniosMinimos,
                    });
            }(),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_siembras'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_semillas'),
      headers: [
        SoleraL10n.t('huer.codigo_lote'),
        SoleraL10n.t('huer.especie'),
        SoleraL10n.t('huer.variedad'),
        SoleraL10n.t('huer.origen_semilla'),
        SoleraL10n.t('huer.proveedor'),
        SoleraL10n.t('huer.numero_autorizacion'),
      ],
      filas: [
        for (final lote in datos.lotes)
          if (lotesUsados.contains(lote.id))
            [
              lote.codigo,
              nombreEspecie(lote.especieId),
              _o(lote.variedad),
              nombreOrigenSemilla(lote.origen),
              _o(lote.proveedor),
              lote.necesitaAutorizacion
                  ? (lote.faltaAutorizacion
                      ? SoleraL10n.t('huer.falta_autorizacion')
                      : lote.numeroAutorizacion)
                  : '—',
            ],
      ],
      mensajeSiVacia: SoleraL10n.t('huer.pdf_sin_semillas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_observaciones'),
      headers: [
        SoleraL10n.t('huer.fecha'),
        SoleraL10n.t('huer.bancal'),
        SoleraL10n.t('huer.cultivo'),
        SoleraL10n.t('huer.problema'),
        SoleraL10n.t('huer.notas'),
      ],
      filas: [
        for (final observacion in [
          ...entrada.observaciones
        ]..sort((a, b) => a.fechaMs.compareTo(b.fechaMs)))
          [
            formatearFecha(observacion.fechaMs),
            lugarBancal(observacion.bancalId),
            observacion.cultivoId == null
                ? '—'
                : datos.nombreDeCultivo(observacion.cultivoId!),
            nombrePlaga(observacion.plagaId),
            _o(observacion.notas),
          ],
      ],
      // Sin observaciones la sección no aparece.
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_insumos'),
      headers: [
        SoleraL10n.t('huer.fecha'),
        SoleraL10n.t('huer.bancal'),
        SoleraL10n.t('huer.insumo'),
        SoleraL10n.t('huer.tipo_insumo'),
        SoleraL10n.t('huer.pdf_categoria'),
        SoleraL10n.t('huer.permitido_ecologico'),
        SoleraL10n.t('huer.motivo'),
        SoleraL10n.t('huer.dosis_aplicada'),
        SoleraL10n.t('huer.cantidad_total'),
      ],
      filas: [
        for (final aplicacion in aplicaciones)
          () {
            final insumo = datos.insumo(aplicacion.insumoId);
            return [
              formatearFecha(aplicacion.fechaMs),
              lugar(aplicacion.parcelaId, aplicacion.bancalId),
              insumo?.nombre ?? '?',
              nombreTipoInsumo(insumo?.tipo ?? ''),
              _o(nombreCategoriaInsumo(insumo?.categoriaEcologicaId ?? '')),
              insumo == null || !insumo.permitidoEcologico
                  ? SoleraL10n.t('huer.pdf_no_marcado')
                  : _o(insumo.justificantePermitido) == '—'
                      ? SoleraL10n.t('huer.falta_justificante')
                      : insumo.justificantePermitido,
              _o(nombrePlaga(aplicacion.problema)),
              _o(aplicacion.dosisAplicada),
              _o(aplicacion.cantidadTotal),
            ];
          }(),
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_aplicaciones'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_tratamientos'),
      headers: [
        SoleraL10n.t('huer.fecha'),
        SoleraL10n.t('huer.bancal'),
        SoleraL10n.t('huer.problema'),
        SoleraL10n.t('huer.sustancia_activa'),
        SoleraL10n.t('huer.pdf_producto_registro'),
        SoleraL10n.t('huer.superficie_m2'),
        SoleraL10n.t('huer.pdf_aplicador_carne'),
        SoleraL10n.t('huer.equipo_aplicacion'),
        SoleraL10n.t('huer.plazo_seguridad'),
        SoleraL10n.t('huer.eficacia'),
      ],
      filas: [
        for (final aplicacion in fitosanitarios)
          [
            formatearFecha(aplicacion.fechaMs),
            lugar(aplicacion.parcelaId, aplicacion.bancalId),
            _o(nombrePlaga(aplicacion.problema)),
            _o(aplicacion.sustanciaActivaId),
            '${datos.insumo(aplicacion.insumoId)?.nombre ?? '?'} / '
                '${_o(datos.insumo(aplicacion.insumoId)?.numeroRegistro ?? '')}',
            _numero(aplicacion.superficieTratadaM2, decimales: 0),
            '${_o(aplicacion.aplicadorNombre)} / ${_o(aplicacion.carnetAplicador)}',
            _o(aplicacion.equipoAplicacion),
            aplicacion.plazoSeguridadDias?.toString() ?? '—',
            aplicacion.eficacia.isEmpty
                ? '—'
                : nombreEficacia(aplicacion.eficacia),
          ],
      ],
      // Sin fitosanitarios la sección no aparece.
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.cosechas'),
      headers: [
        SoleraL10n.t('huer.fecha'),
        SoleraL10n.t('huer.bancal'),
        SoleraL10n.t('huer.cultivo'),
        SoleraL10n.t('huer.kg'),
        SoleraL10n.t('huer.piezas'),
        SoleraL10n.t('huer.destino'),
        SoleraL10n.t('huer.lote_cosecha'),
      ],
      filas: [
        for (final cosecha in cosechas)
          [
            formatearFecha(cosecha.fechaMs),
            lugarBancal(cosecha.bancalId),
            datos.nombreDeCultivo(cosecha.cultivoId),
            cosecha.kg > 0 ? _numero(cosecha.kg, decimales: 2) : '—',
            cosecha.porUnidades ? '${cosecha.unidades}' : '—',
            nombreDestinoCosecha(cosecha.destino),
            _o(cosecha.loteCosecha),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('huer.sin_cosechas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('huer.pdf_totales_cultivo'),
      headers: [
        SoleraL10n.t('huer.cultivo'),
        SoleraL10n.t('huer.pdf_pasadas'),
        SoleraL10n.t('huer.kg'),
        SoleraL10n.t('huer.piezas'),
      ],
      filas: [
        for (final entrada in totales.entries)
          [
            datos.nombreDeCultivo(entrada.key),
            '${entrada.value.pasadas}',
            _numero(entrada.value.kg, decimales: 2),
            entrada.value.piezas > 0 ? '${entrada.value.piezas}' : '—',
          ],
      ],
    ),
  ];
}

/// Cuaderno de campo para el certificador ecológico de un año, en PDF.
Future<Uint8List> generarCuadernoEcologicoPdf(DatosCuadernoEcologico entrada,
    {pw.ThemeData? tema}) {
  final titular = entrada.titular;
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('huer.cuaderno_ecologico')} · ${entrada.anyo}',
    subtituloCabecera:
        '${_o(titular.nombreHuerta.isEmpty ? titular.nombre : titular.nombreHuerta)}'
        '${titular.nif.isEmpty ? '' : ' · ${titular.nif}'} · $selloCuadernoEcologico',
    bulletsResumen: [
      '${SoleraL10n.t('huer.nombre_titular')}: ${_o(titular.nombre)}',
      '${SoleraL10n.t('huer.registro_explotacion')}: ${_o(titular.registroExplotacion)}',
      '${SoleraL10n.t('huer.municipio')}: ${_o(titular.municipio)}'
          '${titular.comunidadAutonoma.isEmpty ? '' : ' (${titular.comunidadAutonoma})'}',
      '${SoleraL10n.t('huer.organismo_control')}: ${_o(titular.organismoControl)} · '
          '${SoleraL10n.t('huer.codigo_operador_ecologico')}: ${_o(titular.codigoOperadorEcologico)}',
      if (titular.asesorNombre.isNotEmpty)
        '${SoleraL10n.t('huer.asesor')}: ${titular.asesorNombre}'
            '${titular.asesorNumeroRopo.isEmpty ? '' : ' (ROPO ${titular.asesorNumeroRopo})'}',
      SoleraL10n.t('huer.pdf_nota_normativa'),
      SoleraL10n.t('huer.aviso_documento_provisional'),
    ],
    tablas: tablasCuadernoEcologico(entrada),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
