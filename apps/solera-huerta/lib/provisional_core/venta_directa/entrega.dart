// PROVISIONAL CORE — módulo transversal T2 (venta directa). Ver socio.dart.

/// Cómo acabó la entrega de una cesta.
const List<String> resultadosEntrega = ['entregada', 'no_recogida', 'aplazada'];

/// Entrega (o intento de entrega) de una cesta.
class Entrega {
  Entrega({
    this.id,
    required this.cestaId,
    required this.fechaMs,
    this.resultado = 'entregada',
    this.recogidaPor = '',
    this.notas = '',
  });

  final int? id;
  final int cestaId;
  final int fechaMs;

  /// Uno de [resultadosEntrega].
  final String resultado;

  /// Quién la recogió, si no fue el socio.
  final String recogidaPor;
  final String notas;

  bool get entregada => resultado == 'entregada';

  Map<String, Object?> toMap() => {
        'id': id,
        'cesta_id': cestaId,
        'fecha_ms': fechaMs,
        'resultado': resultado,
        'recogida_por': recogidaPor,
        'notas': notas,
      };

  factory Entrega.fromMap(Map<String, Object?> mapa) => Entrega(
        id: mapa['id'] as int?,
        cestaId: mapa['cesta_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        resultado: (mapa['resultado'] as String?) ?? 'entregada',
        recogidaPor: (mapa['recogida_por'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
