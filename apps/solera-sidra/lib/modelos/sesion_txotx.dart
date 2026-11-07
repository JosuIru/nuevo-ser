import 'codificacion.dart';

/// Un día de txotx: qué kupela se abrió y cuántos litros se sirvieron
/// (estimados). Una sesión por kupela y día.
class SesionTxotx {
  SesionTxotx({
    this.id,
    required this.fechaMs,
    required this.kupelaId,
    required this.litrosServidos,
    this.comensales,
    this.notas = '',
  });

  final int? id;
  final int fechaMs;
  final int kupelaId;
  final double litrosServidos;
  final int? comensales;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'kupela_id': kupelaId,
        'litros_servidos': litrosServidos,
        'comensales': comensales,
        'notas': notas,
      };

  factory SesionTxotx.fromMap(Map<String, Object?> mapa) => SesionTxotx(
        id: mapa['id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        kupelaId: mapa['kupela_id'] as int,
        litrosServidos: comoDecimal(mapa['litros_servidos']) ?? 0,
        comensales: mapa['comensales'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
