/// Pedido que se repite (bar, tienda, comedor): qué, cuánto y qué días.
class PedidoFijo {
  PedidoFijo({
    this.id,
    required this.cliente,
    required this.recetaId,
    required this.piezas,
    required this.diasSemana,
    this.activo = true,
    this.notas = '',
  });

  final int? id;
  final String cliente;
  final int recetaId;
  final int piezas;

  /// Días con `DateTime.weekday` (1 = lunes … 7 = domingo).
  final Set<int> diasSemana;
  final bool activo;
  final String notas;

  bool tocaEl(DateTime fecha) => activo && diasSemana.contains(fecha.weekday);

  Map<String, Object?> toMap() => {
        'id': id,
        'cliente': cliente,
        'receta_id': recetaId,
        'piezas': piezas,
        'dias_semana': (diasSemana.toList()..sort()).join(','),
        'activo': activo ? 1 : 0,
        'notas': notas,
      };

  factory PedidoFijo.fromMap(Map<String, Object?> mapa) => PedidoFijo(
        id: mapa['id'] as int?,
        cliente: mapa['cliente'] as String,
        recetaId: mapa['receta_id'] as int,
        piezas: mapa['piezas'] as int,
        diasSemana: ((mapa['dias_semana'] as String?) ?? '')
            .split(',')
            .map(int.tryParse)
            .whereType<int>()
            .where((dia) => dia >= 1 && dia <= 7)
            .toSet(),
        activo: (mapa['activo'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Piezas por receta que piden los pedidos fijos para [fecha].
Map<int, int> piezasPedidasPara(DateTime fecha, Iterable<PedidoFijo> pedidos) {
  final piezasPorReceta = <int, int>{};
  for (final pedido in pedidos.where((pedido) => pedido.tocaEl(fecha))) {
    piezasPorReceta.update(pedido.recetaId, (piezas) => piezas + pedido.piezas,
        ifAbsent: () => pedido.piezas);
  }
  return piezasPorReceta;
}
