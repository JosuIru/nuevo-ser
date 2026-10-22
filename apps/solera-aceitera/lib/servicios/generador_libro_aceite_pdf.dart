import 'dart:io';

import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/lote_aceite.dart';
import '../modelos/molturacion.dart';
import '../modelos/movimiento.dart';
import '../modelos/titular.dart';

/// Genera el Libro de Movimientos del Aceite (RD 760/2021 + AICA) en
/// PDF firmable. Cubre los tres bloques que la inspección AICA pide:
///
///  1. **Lotes de la campaña** — identificador, fecha, kg netos,
///     categoría comercial (virgen extra / virgen / lampante /
///     por_clasificar), DOP si aplica, ubicación física y parámetros
///     analíticos clave (acidez, peróxidos, K232, K270).
///  2. **Molturaciones de la campaña** — fecha, kg molturados,
///     rendimiento %, kg de aceite obtenido, lote generado y
///     referencias de batidora/decanter.
///  3. **Movimientos cronológicos** — cada entrada/traslado/mezcla/
///     envasado/venta_granel/autoconsumo/merma con su lote, kg
///     movidos, ubicación destino y referencia de venta cuando aplica.
///
/// La plantilla `informe_periodico` del core mantiene cabecera,
/// footer y tablas en el mismo estilo que el resto de la suite
/// Solera. Si `lote` es null se genera el libro completo de la
/// campaña; si se pasa un lote concreto, se reduce a las tablas de
/// ese lote (útil para presentar el ciclo de vida individual ante
/// AICA cuando la inspección pregunta por una referencia concreta).
///
/// **Limitación PROVISIONAL v0.1**: el formato exacto vigente del
/// libro de movimientos cambia con cada actualización de la AICA y
/// del RD 760/2021. El subtítulo del PDF lleva el sello
/// `PROVISIONAL` literal hasta que un auditor AICA real audite el
/// formato — registrado como bloqueo F1-A5 en
/// `BLOQUEOS-PENDIENTES.md` y custodiado por el test guardrail
/// `test/sello_provisional_test.dart`.
Future<File> generarLibroMovimientosAceite({
  required Campania campania,
  required LoteAceite? lote,
}) async {
  final basedatos = BaseDatosSoleraAceitera.instancia;
  final titular = await basedatos.obtenerTitular();
  final olivar = await basedatos.obtenerOlivar();
  final lotesCampania =
      await basedatos.listarLotesAceite(campaniaId: campania.id);
  final indiceLotesPorId = <int, LoteAceite>{
    for (final l in lotesCampania)
      if (l.id != null) l.id!: l,
  };

  final lotesAMostrar = lote == null ? lotesCampania : [lote];

  // Movimientos: si filtramos por lote, sólo los suyos. Si no, todos
  // los de la campaña (resueltos por intersección con `lotesCampania`).
  final List<_FilaMovimiento> movimientosFiltrados = [];
  if (lote != null) {
    final movimientosLote =
        await basedatos.listarMovimientos(loteAceiteId: lote.id);
    for (final m in movimientosLote) {
      movimientosFiltrados.add(_FilaMovimiento(movimiento: m, lote: lote));
    }
  } else {
    final todos = await basedatos.listarMovimientos();
    for (final m in todos) {
      final loteAsociado = indiceLotesPorId[m.loteAceiteId];
      if (loteAsociado == null) continue;
      movimientosFiltrados
          .add(_FilaMovimiento(movimiento: m, lote: loteAsociado));
    }
  }
  movimientosFiltrados
      .sort((a, b) => a.movimiento.fechaMs.compareTo(b.movimiento.fechaMs));

  // Molturaciones de la campaña — filtrar por lote si procede usando
  // el campo `loteAceiteId` que la molturación rellena al crear el
  // lote (flujo PantallaNuevaMolturacion).
  final basedatosCrudo = await basedatos.basedatos;
  final filasMolturacion = await basedatosCrudo.query(
    'molturaciones',
    where: 'campania_id = ?',
    whereArgs: [campania.id],
    orderBy: 'fecha_ms ASC',
  );
  final molturaciones =
      filasMolturacion.map(Molturacion.fromMap).toList(growable: false);
  final molturacionesFiltradas = lote == null
      ? molturaciones
      : molturaciones.where((m) => m.loteAceiteId == lote.id).toList();

  final formatoFecha = DateFormat('dd/MM/yyyy');

  final ambito = lote == null
      ? 'campaña completa'
      : 'lote ${lote.identificadorLote}';
  final tituloCabecera = 'Libro de Movimientos del Aceite · $ambito';
  final subtituloCabecera =
      'Campaña ${campania.anyoComercial}/${campania.anyoComercial + 1}'
      ' · RD 760/2021 + AICA · PROVISIONAL';

  final totalKgLotes =
      lotesAMostrar.fold<double>(0, (acc, l) => acc + l.kgNetos);
  final totalKgMolturados = molturacionesFiltradas.fold<double>(
      0, (acc, m) => acc + m.kgMolturados);
  final totalAceiteObtenido = molturacionesFiltradas.fold<double>(
      0, (acc, m) => acc + m.aceiteObtenidoKg);

  final bulletsResumen = <String>[
    'Titular: ${_etiquetaTitularRazonSocial(titular)} · NIF ${_etiquetaNif(titular)}',
    if (titular != null && titular.numeroAica.isNotEmpty)
      'AICA: ${titular.numeroAica}',
    if (titular != null && titular.rgseaa.isNotEmpty)
      'RGSEAA: ${titular.rgseaa}',
    if (titular != null && titular.direccion.isNotEmpty)
      'Dirección: ${titular.direccion}',
    if (olivar != null && olivar.nombre.isNotEmpty)
      'Olivar: ${olivar.nombre}'
          '${olivar.municipio.isNotEmpty ? " · ${olivar.municipio}" : ""}'
          '${olivar.provincia.isNotEmpty ? " (${olivar.provincia})" : ""}',
    'Lotes incluidos: ${lotesAMostrar.length}'
        ' · ${totalKgLotes.toStringAsFixed(1)} kg netos',
    'Molturaciones registradas: ${molturacionesFiltradas.length}'
        ' · ${totalKgMolturados.toStringAsFixed(1)} kg aceituna molturados'
        ' → ${totalAceiteObtenido.toStringAsFixed(1)} kg aceite',
    'Movimientos registrados: ${movimientosFiltrados.length}',
  ];

  final filasLotes = [
    for (final l in lotesAMostrar)
      [
        formatoFecha
            .format(DateTime.fromMillisecondsSinceEpoch(l.fechaCreacionMs)),
        l.identificadorLote,
        l.kgNetos.toStringAsFixed(1),
        l.categoria,
        l.dopId.isEmpty ? '—' : l.dopId,
        l.ubicacionFisica.isEmpty ? '—' : l.ubicacionFisica,
        _formatoOpcional(l.acidez, decimales: 2),
        _formatoOpcional(l.peroxidos, decimales: 1),
        _formatoOpcional(l.k232, decimales: 2),
        _formatoOpcional(l.k270, decimales: 2),
      ],
  ];

  final filasMolturaciones = [
    for (final m in molturacionesFiltradas)
      [
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(m.fechaMs)),
        m.kgMolturados.toStringAsFixed(1),
        m.rendimientoPorcentaje.toStringAsFixed(2),
        m.aceiteObtenidoKg.toStringAsFixed(1),
        m.loteAceiteId == null
            ? '—'
            : (indiceLotesPorId[m.loteAceiteId]?.identificadorLote ??
                '#${m.loteAceiteId}'),
        m.batidoraReferencia.isEmpty ? '—' : m.batidoraReferencia,
        m.decanterReferencia.isEmpty ? '—' : m.decanterReferencia,
      ],
  ];

  final filasMovimientos = [
    for (final fila in movimientosFiltrados)
      [
        formatoFecha.format(
            DateTime.fromMillisecondsSinceEpoch(fila.movimiento.fechaMs)),
        fila.lote.identificadorLote,
        fila.movimiento.tipo,
        fila.movimiento.kgMovidos.toStringAsFixed(1),
        fila.movimiento.ubicacionDestino.isEmpty
            ? '—'
            : fila.movimiento.ubicacionDestino,
        fila.movimiento.ventaId == null
            ? '—'
            : '#${fila.movimiento.ventaId}',
      ],
  ];

  final prefijoCampania = '${campania.anyoComercial}-${campania.anyoComercial + 1}';
  final prefijoLote =
      lote == null ? 'campania' : 'lote-${_slug(lote.identificadorLote)}';

  return generarInformePeriodicoPdf(
    tema: await temaPdfSolera(),
    tituloCabecera: tituloCabecera,
    subtituloCabecera: subtituloCabecera,
    bulletsResumen: bulletsResumen,
    tablas: [
      TablaInforme(
        titulo: 'Lotes',
        headers: const [
          'Fecha',
          'Identificador',
          'Kg netos',
          'Categoría',
          'DOP',
          'Ubicación',
          'Acidez',
          'Peróxidos',
          'K232',
          'K270',
        ],
        filas: filasLotes,
        mensajeSiVacia: 'Sin lotes registrados en esta campaña.',
      ),
      TablaInforme(
        titulo: 'Molturaciones',
        headers: const [
          'Fecha',
          'Kg molturados',
          'Rend. (%)',
          'Aceite (kg)',
          'Lote generado',
          'Batidora',
          'Decanter',
        ],
        filas: filasMolturaciones,
        mensajeSiVacia: 'Sin molturaciones registradas en esta campaña.',
      ),
      TablaInforme(
        titulo: 'Movimientos',
        headers: const [
          'Fecha',
          'Lote',
          'Tipo',
          'Kg movidos',
          'Destino',
          'Venta',
        ],
        filas: filasMovimientos,
        mensajeSiVacia:
            'Sin movimientos registrados (entradas, traslados, mezclas, '
            'envasados, ventas o autoconsumo) en esta campaña.',
      ),
    ],
    prefijoNombreFichero: 'libro_aceite-$prefijoLote-$prefijoCampania',
    operador: (titular == null || titular.razonSocial.isEmpty)
        ? null
        : titular.razonSocial,
  );
}

class _FilaMovimiento {
  final Movimiento movimiento;
  final LoteAceite lote;

  const _FilaMovimiento({required this.movimiento, required this.lote});
}

String _etiquetaTitularRazonSocial(Titular? titular) {
  if (titular == null || titular.razonSocial.isEmpty) return '—';
  return titular.razonSocial;
}

String _etiquetaNif(Titular? titular) {
  if (titular == null || titular.nif.isEmpty) return '—';
  return titular.nif;
}

String _formatoOpcional(double? valor, {int decimales = 2}) {
  if (valor == null) return '—';
  return valor.toStringAsFixed(decimales);
}

String _slug(String entrada) {
  final sinAcentos = entrada
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâã]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöôõ]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n');
  final filtrado = sinAcentos.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  return filtrado.replaceAll(RegExp(r'^-+|-+$'), '');
}
