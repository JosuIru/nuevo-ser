import 'dart:typed_data';

import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TablaInforme, generarInformePeriodicoPdfBytes;
import 'package:pdf/widgets.dart' as pw;

import '../dominio/campania.dart';
import '../dominio/catalogos.dart';
import '../dominio/saldo_kupelas.dart';
import '../modelos/embotellado.dart';
import '../modelos/kupela.dart';
import '../modelos/partida_manzana.dart';
import '../modelos/pomarada.dart';
import '../modelos/prensado.dart';
import '../modelos/sesion_txotx.dart';
import '../modelos/titular.dart';
import '../utiles/textos_sidra.dart';

/// Sello del documento: no se encontró qué libro exige la entidad de control
/// de la DOP; este sigue los registros del ap. E del pliego de Euskal
/// Sagardoa (jul-2024) hasta que HAZI o el Consejo Regulador digan el formato
/// (BLOQUEOS-PENDIENTES.md). Lo vigila test/sello_provisional_test.dart.
const String selloLibroElaboracion = 'PROVISIONAL';

/// Lo que entra en el libro de una campaña.
class DatosLibroElaboracion {
  DatosLibroElaboracion({
    required this.campania,
    required this.pomaradas,
    required this.partidas,
    required this.prensados,
    required this.partidasPorPrensado,
    required this.kupelas,
    required this.trasiegos,
    required this.sesionesTxotx,
    required this.embotellados,
    required this.saldoAlCierre,
  });

  final int campania;
  final List<Pomarada> pomaradas;

  /// Todo filtrado ya a la campaña.
  final List<PartidaManzana> partidas;
  final List<Prensado> prensados;
  final Map<int, List<int>> partidasPorPrensado;
  final List<Kupela> kupelas;
  final List<Trasiego> trasiegos;
  final List<SesionTxotx> sesionesTxotx;
  final List<Embotellado> embotellados;

  /// Saldo de todas las kupelas al cierre de la campaña (o a hoy).
  final SaldoKupelas saldoAlCierre;

  double get litrosEmbotellados =>
      embotellados.fold<double>(0, (suma, lote) => suma + lote.litros);
  int get botellas =>
      embotellados.fold<int>(0, (suma, lote) => suma + lote.botellas);
  double get litrosTxotx => sesionesTxotx.fold<double>(
      0, (suma, sesion) => suma + sesion.litrosServidos);
  int get contraetiquetasUsadas => embotellados.fold<int>(0,
      (suma, lote) => suma + (lote.conDop ? (lote.etiquetasUsadas ?? 0) : 0));
  double get kilosEntrados =>
      partidas.fold<double>(0, (suma, partida) => suma + partida.kilos);
  double get litrosMosto => prensados.fold<double>(
      0, (suma, prensado) => suma + prensado.litrosMosto);
}

List<T> _porFecha<T>(List<T> lista, int Function(T) fecha) =>
    [...lista]..sort((a, b) => fecha(a).compareTo(fecha(b)));

/// Tablas del libro: registro de entrada, prensados, kupelas, trasiegos,
/// txotx, embotellado y balance de existencias (los registros del ap. E).
List<TablaInforme> tablasLibroElaboracion(DatosLibroElaboracion datos) {
  final kupelas = {for (final kupela in datos.kupelas) kupela.id: kupela};
  final pomaradas = {
    for (final pomarada in datos.pomaradas) pomarada.id: pomarada
  };
  final partidas = {for (final partida in datos.partidas) partida.id: partida};
  String kupela(int? id) => id == null ? '—' : (kupelas[id]?.codigo ?? '#$id');
  String siNo(bool valor) =>
      valor ? SoleraL10n.t('sidr.si') : SoleraL10n.t('sidr.no');
  String litros(num valor) => formatearNumero(valor, decimales: 0);

  final movimientosKupela = <int, ({double entra, double sale})>{};
  for (final MapEntry(key: id, value: movimientos)
      in datos.saldoAlCierre.movimientos.entries) {
    double entra = 0, sale = 0;
    for (final movimiento in movimientos) {
      if (movimiento.litros >= 0) {
        entra += movimiento.litros;
      } else {
        sale -= movimiento.litros;
      }
    }
    movimientosKupela[id] = (entra: entra, sale: sale);
  }

  return [
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_registro_entrada'),
      headers: [
        SoleraL10n.t('sidr.fecha_entrega'),
        SoleraL10n.t('sidr.pdf_origen'),
        SoleraL10n.t('sidr.procedencia'),
        SoleraL10n.t('sidr.variedades'),
        SoleraL10n.t('sidr.fecha_recoleccion'),
        'kg',
        SoleraL10n.t('sidr.estado_fruta'),
        SoleraL10n.t('sidr.pdf_documento'),
        SoleraL10n.t('sidr.pdf_registrada'),
      ],
      filas: [
        for (final partida
            in _porFecha(datos.partidas, (p) => p.fechaEntregaMs))
          [
            formatearFecha(partida.fechaEntregaMs),
            partida.propia
                ? '${SoleraL10n.t('sidr.propia')}: ${pomaradas[partida.pomaradaId]?.nombre ?? '—'}'
                : partida.proveedor,
            partida.procedencia.isEmpty ? '—' : partida.procedencia,
            partida.variedades.isEmpty
                ? '—'
                : partida.variedades.map(nombreVariedad).join(', '),
            partida.fechaRecoleccionMs == null
                ? '—'
                : formatearFecha(partida.fechaRecoleccionMs!),
            litros(partida.kilos),
            nombreValor('estado_fruta', partida.estadoFruta),
            partida.documentoTransporte.isEmpty
                ? '—'
                : partida.documentoTransporte,
            siNo(partida.procedenciaRegistrada(
                pomaradaRegistrada:
                    pomaradas[partida.pomaradaId]?.registradaDop ?? false)),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.sin_entradas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.prensados'),
      headers: [
        SoleraL10n.t('sidr.fecha'),
        SoleraL10n.t('sidr.pdf_partidas'),
        'kg',
        SoleraL10n.t('sidr.pdf_litros_mosto'),
        '%',
        SoleraL10n.t('sidr.pdf_presion'),
        SoleraL10n.t('sidr.densidad'),
        SoleraL10n.t('sidr.kupela'),
      ],
      filas: [
        for (final prensado in _porFecha(datos.prensados, (p) => p.fechaMs))
          [
            formatearFecha(prensado.fechaMs),
            (datos.partidasPorPrensado[prensado.id] ?? const [])
                .map((id) => partidas[id] == null
                    ? '#$id'
                    : '${formatearFecha(partidas[id]!.fechaEntregaMs)} ${litros(partidas[id]!.kilos)} kg')
                .join('; '),
            litros(prensado.kilosFruta),
            litros(prensado.litrosMosto),
            prensado.rendimientoPorcentaje == null
                ? '—'
                : formatearNumero(prensado.rendimientoPorcentaje!,
                    decimales: 0),
            prensado.presionBar == null
                ? '—'
                : formatearNumero(prensado.presionBar!),
            prensado.densidadMosto == null
                ? '—'
                : formatearNumero(prensado.densidadMosto!, decimales: 0),
            kupela(prensado.kupelaId),
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.sin_prensados'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_kupelas_partidas'),
      headers: [
        SoleraL10n.t('sidr.kupela'),
        SoleraL10n.t('sidr.producto'),
        SoleraL10n.t('sidr.capacidad'),
        SoleraL10n.t('sidr.pdf_entra'),
        SoleraL10n.t('sidr.pdf_sale'),
        SoleraL10n.t('sidr.pdf_al_cierre'),
        SoleraL10n.t('sidr.calificacion'),
      ],
      filas: [
        for (final kupela in datos.kupelas)
          if (movimientosKupela.containsKey(kupela.id))
            [
              kupela.etiqueta,
              productoDopPorId(kupela.productoDopId)?.nombre ??
                  nombreValor('producto', kupela.producto),
              litros(kupela.capacidadLitros),
              litros(movimientosKupela[kupela.id]!.entra),
              litros(movimientosKupela[kupela.id]!.sale),
              litros(datos.saldoAlCierre.litrosEn(kupela.id!)),
              nombreValor('calificacion', kupela.calificacion),
            ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.sin_kupelas'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_trasiegos'),
      headers: [
        SoleraL10n.t('sidr.fecha'),
        SoleraL10n.t('sidr.pdf_de'),
        SoleraL10n.t('sidr.pdf_a'),
        SoleraL10n.t('sidr.litros'),
        SoleraL10n.t('sidr.motivo'),
      ],
      filas: [
        for (final trasiego in _porFecha(datos.trasiegos, (t) => t.fechaMs))
          [
            formatearFecha(trasiego.fechaMs),
            kupela(trasiego.kupelaOrigenId),
            trasiego.esRetirada
                ? SoleraL10n.t('sidr.retirada')
                : kupela(trasiego.kupelaDestinoId),
            litros(trasiego.litros),
            trasiego.motivo.isEmpty ? '—' : trasiego.motivo,
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.txotx'),
      headers: [
        SoleraL10n.t('sidr.fecha'),
        SoleraL10n.t('sidr.kupela'),
        SoleraL10n.t('sidr.litros'),
      ],
      filas: [
        for (final sesion in _porFecha(datos.sesionesTxotx, (s) => s.fechaMs))
          [
            formatearFecha(sesion.fechaMs),
            kupela(sesion.kupelaId),
            litros(sesion.litrosServidos),
          ],
      ],
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_embotellado'),
      headers: [
        SoleraL10n.t('sidr.pdf_envasado'),
        SoleraL10n.t('sidr.pdf_lote'),
        SoleraL10n.t('sidr.pdf_partida'),
        SoleraL10n.t('sidr.botellas'),
        SoleraL10n.t('sidr.litros'),
        SoleraL10n.t('sidr.pdf_etiquetado'),
        SoleraL10n.t('sidr.pdf_contraetiquetas'),
        SoleraL10n.t('sidr.pdf_n_etiquetas'),
        SoleraL10n.t('sidr.destino'),
      ],
      filas: [
        for (final lote in _porFecha(datos.embotellados, (e) => e.fechaMs))
          [
            formatearFecha(lote.fechaMs),
            lote.codigoLote,
            kupela(lote.kupelaId),
            '${lote.botellas} × ${lote.mililitrosBotella} ml',
            litros(lote.litros),
            lote.fechaEtiquetadoMs == null
                ? '—'
                : formatearFecha(lote.fechaEtiquetadoMs!),
            lote.conDop && lote.etiquetaDesde != null
                ? '${lote.etiquetaDesde}–${lote.etiquetaHasta ?? '?'}'
                : '—',
            lote.etiquetasUsadas == null ? '—' : '${lote.etiquetasUsadas}',
            lote.destino.isEmpty ? '—' : lote.destino,
          ],
      ],
      mensajeSiVacia: SoleraL10n.t('sidr.sin_embotellados'),
    ),
    TablaInforme(
      titulo: SoleraL10n.t('sidr.pdf_balance'),
      headers: [
        SoleraL10n.t('sidr.pdf_concepto'),
        SoleraL10n.t('sidr.pdf_cantidad')
      ],
      filas: [
        [
          SoleraL10n.t('sidr.pdf_fruta_entrada'),
          '${litros(datos.kilosEntrados)} kg'
        ],
        [
          SoleraL10n.t('sidr.pdf_litros_mosto'),
          '${litros(datos.litrosMosto)} l'
        ],
        [
          SoleraL10n.t('sidr.pdf_litros_txotx'),
          '${litros(datos.litrosTxotx)} l'
        ],
        [
          SoleraL10n.t('sidr.pdf_embotellado'),
          '${datos.botellas} · ${litros(datos.litrosEmbotellados)} l'
        ],
        [
          SoleraL10n.t('sidr.pdf_contraetiquetas_usadas'),
          '${datos.contraetiquetasUsadas}'
        ],
        [
          SoleraL10n.t('sidr.pdf_existencias'),
          '${litros(datos.saldoAlCierre.litrosTotales(datos.kupelas))} l'
        ],
      ],
    ),
  ];
}

/// Libro de elaboración y embotellado de una campaña, en PDF.
Future<Uint8List> generarLibroElaboracionPdf({
  required Titular titular,
  required DatosLibroElaboracion datos,
  pw.ThemeData? tema,
}) {
  return generarInformePeriodicoPdfBytes(
    tituloCabecera:
        '${SoleraL10n.t('sidr.libro_elaboracion')} · ${nombreCampania(datos.campania)}',
    subtituloCabecera: '${titular.nombre}'
        '${titular.inscripcionDop.isEmpty ? '' : ' · ${SoleraL10n.t('sidr.dop')} ${titular.inscripcionDop}'}'
        '${titular.registroSanitario.isEmpty ? '' : ' · RGSEAA ${titular.registroSanitario}'}'
        ' · $selloLibroElaboracion',
    bulletsResumen: [
      SoleraL10n.tf('sidr.pdf_resumen_libro', {
        'kilos': formatearNumero(datos.kilosEntrados, decimales: 0),
        'mosto': formatearNumero(datos.litrosMosto, decimales: 0),
        'botellas': datos.botellas,
      }),
      SoleraL10n.t('sidr.aviso_no_certifica'),
      SoleraL10n.t('sidr.aviso_documento_provisional'),
    ],
    tablas: tablasLibroElaboracion(datos),
    operador: titular.nombre.isEmpty ? null : titular.nombre,
    tema: tema,
  );
}
