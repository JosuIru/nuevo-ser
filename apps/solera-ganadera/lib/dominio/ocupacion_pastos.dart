import '../modelos/carga_ganadera.dart';
import '../modelos/ganado.dart';
import '../modelos/pieza_pasto.dart';

/// Un rebaño con lo que hace falta para pintarlo: dónde está, cuántas
/// cabezas y cuántas UGM tiene ahora.
class EstadoLote {
  const EstadoLote({
    required this.lote,
    required this.piezaId,
    required this.cabezas,
    required this.ugm,
  });

  final LoteGanado lote;

  /// Null si está fuera de la explotación o nunca se ha movido.
  final int? piezaId;
  final int cabezas;
  final double ugm;
}

/// Lo que hay ahora en una pieza.
class OcupacionPieza {
  const OcupacionPieza({required this.pieza, required this.lotes});

  final PiezaPasto pieza;
  final List<EstadoLote> lotes;

  double get ugm => lotes.fold(0.0, (suma, lote) => suma + lote.ugm);
  int get cabezas => lotes.fold(0, (suma, lote) => suma + lote.cabezas);

  /// UGM/ha, o null si la pieza no tiene superficie.
  double? get carga => cargaPorHectarea(ugm, pieza.superficieHa);
}

/// El estado de cada rebaño activo (pura). [tabla] son las filas del
/// trámite con el que se cuenta la carga.
List<EstadoLote> estadosDeLotes({
  required List<LoteGanado> lotes,
  required List<Animal> animales,
  required List<MovimientoGanado> movimientos,
  required List<CoeficienteUgm> tabla,
  required DateTime ahora,
}) =>
    [
      for (final lote in lotes.where((lote) => lote.activo))
        () {
          final suyos =
              animales.where((animal) => animal.loteId == lote.id).toList();
          return EstadoLote(
            lote: lote,
            piezaId: piezaActualDeLote(movimientos
                .where((movimiento) => movimiento.loteId == lote.id)),
            cabezas: cabezasDeLote(lote, suyos),
            ugm: ugmDeLote(lote, suyos, ahora, tabla),
          );
        }(),
    ];

/// Cada pieza activa con los rebaños que tiene ahora (las vacías también).
List<OcupacionPieza> ocupacionDePiezas(
        List<PiezaPasto> piezas, List<EstadoLote> estados) =>
    [
      for (final pieza in piezas.where((pieza) => pieza.activa))
        OcupacionPieza(
          pieza: pieza,
          lotes: estados.where((estado) => estado.piezaId == pieza.id).toList(),
        ),
    ];
