import '../modelos/embotellado.dart';
import '../modelos/kupela.dart';
import '../modelos/prensado.dart';
import '../modelos/sesion_txotx.dart';

/// Un movimiento de litros en una kupela, para el libro y la ficha.
class MovimientoKupela {
  MovimientoKupela(this.fechaMs, this.tipo, this.litros, {this.otraKupelaId});

  final int fechaMs;

  /// `prensado`, `trasiego_entrada`, `trasiego_salida`, `retirada`, `txotx`
  /// o `embotellado`.
  final String tipo;

  /// Positivo si entra, negativo si sale.
  final double litros;
  final int? otraKupelaId;
}

/// Litros que hay en cada kupela según lo apuntado: entra el mosto de los
/// prensados y los trasiegos de llegada; salen los trasiegos, lo servido en
/// el txotx y lo embotellado. Es una cuenta, no una medida: la merma de la
/// fermentación no se ve hasta que se apunta como retirada.
class SaldoKupelas {
  SaldoKupelas._(this.movimientos);

  /// Kupela → movimientos en orden de fecha.
  final Map<int, List<MovimientoKupela>> movimientos;

  factory SaldoKupelas.calcular({
    required Iterable<Prensado> prensados,
    required Iterable<Trasiego> trasiegos,
    required Iterable<SesionTxotx> sesionesTxotx,
    required Iterable<Embotellado> embotellados,
    int? hastaMs,
  }) {
    final porKupela = <int, List<MovimientoKupela>>{};
    void anotar(int kupelaId, MovimientoKupela movimiento) {
      if (hastaMs != null && movimiento.fechaMs > hastaMs) return;
      porKupela.putIfAbsent(kupelaId, () => []).add(movimiento);
    }

    for (final prensado in prensados) {
      anotar(
        prensado.kupelaId,
        MovimientoKupela(prensado.fechaMs, 'prensado', prensado.litrosMosto),
      );
    }
    for (final trasiego in trasiegos) {
      anotar(
        trasiego.kupelaOrigenId,
        MovimientoKupela(
          trasiego.fechaMs,
          trasiego.esRetirada ? 'retirada' : 'trasiego_salida',
          -trasiego.litros,
          otraKupelaId: trasiego.kupelaDestinoId,
        ),
      );
      if (!trasiego.esRetirada) {
        anotar(
          trasiego.kupelaDestinoId!,
          MovimientoKupela(
            trasiego.fechaMs,
            'trasiego_entrada',
            trasiego.litros,
            otraKupelaId: trasiego.kupelaOrigenId,
          ),
        );
      }
    }
    for (final sesion in sesionesTxotx) {
      anotar(
        sesion.kupelaId,
        MovimientoKupela(sesion.fechaMs, 'txotx', -sesion.litrosServidos),
      );
    }
    for (final embotellado in embotellados) {
      anotar(
        embotellado.kupelaId,
        MovimientoKupela(
          embotellado.fechaMs,
          'embotellado',
          -embotellado.litros,
        ),
      );
    }
    for (final lista in porKupela.values) {
      lista.sort((a, b) => a.fechaMs.compareTo(b.fechaMs));
    }
    return SaldoKupelas._(porKupela);
  }

  double litrosEn(int kupelaId) => (movimientos[kupelaId] ?? const [])
      .fold<double>(0, (suma, movimiento) => suma + movimiento.litros);

  /// Lo apuntado deja la kupela en negativo: falta un prensado o sobra una
  /// salida.
  bool quedaEnNegativo(int kupelaId) => litrosEn(kupelaId) < -0.5;

  /// Lo apuntado supera la capacidad de la kupela.
  bool superaCapacidad(Kupela kupela) =>
      kupela.capacidadLitros > 0 &&
      litrosEn(kupela.id!) > kupela.capacidadLitros + 0.5;

  /// Litros totales en bodega (sin las negativas).
  double litrosTotales(Iterable<Kupela> kupelas) => kupelas.fold<double>(
        0,
        (suma, kupela) => suma + litrosEn(kupela.id!).clamp(0, double.infinity),
      );
}

/// Kupelas de las que procede el contenido de [kupelaId], siguiendo los
/// trasiegos hacia atrás (incluida ella misma). Para la trazabilidad
/// botella → kupela → prensados → partidas.
Set<int> kupelasDeOrigen(
  int kupelaId,
  Iterable<Trasiego> trasiegos, {
  int? hastaMs,
}) {
  final visitadas = <int>{kupelaId};
  final pendientes = [kupelaId];
  while (pendientes.isNotEmpty) {
    final actual = pendientes.removeLast();
    for (final trasiego in trasiegos) {
      if (trasiego.kupelaDestinoId != actual) continue;
      if (hastaMs != null && trasiego.fechaMs > hastaMs) continue;
      if (visitadas.add(trasiego.kupelaOrigenId)) {
        pendientes.add(trasiego.kupelaOrigenId);
      }
    }
  }
  return visitadas;
}
