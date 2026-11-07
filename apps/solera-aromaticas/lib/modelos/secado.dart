import 'lista_ids.dart';

/// Métodos de secado.
const List<String> metodosSecado = [
  'sombra_natural',
  'secadero_aire',
  'secadero_calor',
  'otro',
];

/// Secado de una o varias cosechas: kg frescos → kg secos.
///
/// Como la molturación de aceitera: [cosechasUsadasIds] son las cosechas
/// que entraron juntas, y [loteProductoId] el lote de planta seca que sale.
class Secado {
  Secado({
    this.id,
    required this.fechaInicioMs,
    required this.especieId,
    this.cosechasUsadasIds = const [],
    this.kgFrescos = 0,
    this.kgSecos = 0,
    this.dias,
    this.metodo = 'sombra_natural',
    this.temperaturaMaximaC,
    this.loteProductoId,
    this.notas = '',
  });

  final int? id;
  final int fechaInicioMs;
  final String especieId;
  final List<int> cosechasUsadasIds;
  final double kgFrescos;
  final double kgSecos;
  final int? dias;

  /// Uno de [metodosSecado].
  final String metodo;

  /// Solo en secadero con calor, si se controla.
  final double? temperaturaMaximaC;
  final int? loteProductoId;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_inicio_ms': fechaInicioMs,
        'especie_id': especieId,
        'cosechas_usadas_json': codificarIds(cosechasUsadasIds),
        'kg_frescos': kgFrescos,
        'kg_secos': kgSecos,
        'dias': dias,
        'metodo': metodo,
        'temperatura_maxima_c': temperaturaMaximaC,
        'lote_producto_id': loteProductoId,
        'notas': notas,
      };

  factory Secado.fromMap(Map<String, Object?> mapa) => Secado(
        id: mapa['id'] as int?,
        fechaInicioMs: mapa['fecha_inicio_ms'] as int,
        especieId: (mapa['especie_id'] as String?) ?? '',
        cosechasUsadasIds:
            decodificarIds(mapa['cosechas_usadas_json'] as String?),
        kgFrescos: (mapa['kg_frescos'] as num?)?.toDouble() ?? 0,
        kgSecos: (mapa['kg_secos'] as num?)?.toDouble() ?? 0,
        dias: mapa['dias'] as int?,
        metodo: metodosSecado.contains(mapa['metodo'])
            ? mapa['metodo'] as String
            : 'otro',
        temperaturaMaximaC: (mapa['temperatura_maxima_c'] as num?)?.toDouble(),
        loteProductoId: mapa['lote_producto_id'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
