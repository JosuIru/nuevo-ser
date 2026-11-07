/// Una entrega o pasada de cosecha de una parcela.
///
/// En frutos secos el peso es **en cáscara** y el rendimiento en grano
/// (pepita) lo da la cooperativa o el comprador; en fruta fresca el
/// rendimiento se deja vacío y el peso es el de la fruta.
class Cosecha {
  Cosecha({
    this.id,
    required this.parcelaId,
    required this.campania,
    required this.fechaMs,
    required this.kgCascara,
    this.rendimientoGranoPorcentaje,
    this.calibre = '',
    this.humedadPorcentaje,
    this.destino = '',
    this.numeroAlbaran = '',
    this.notas = '',
  });

  final int? id;
  final int parcelaId;

  /// Año de la cosecha.
  final int campania;
  final int fechaMs;
  final double kgCascara;

  /// Grano sobre peso en cáscara, en %. Null si no se conoce.
  final double? rendimientoGranoPorcentaje;

  /// Texto libre: «14/16», «18+», «>30 mm», «extra»…
  final String calibre;
  final double? humedadPorcentaje;

  /// Cooperativa, comprador o «autoconsumo».
  final String destino;
  final String numeroAlbaran;
  final String notas;

  /// Kilos de grano, o null sin rendimiento.
  double? get kgGrano => rendimientoGranoPorcentaje == null
      ? null
      : kgCascara * rendimientoGranoPorcentaje! / 100;

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'campania': campania,
        'fecha_ms': fechaMs,
        'kg_cascara': kgCascara,
        'rendimiento_grano_pct': rendimientoGranoPorcentaje,
        'calibre': calibre,
        'humedad_pct': humedadPorcentaje,
        'destino': destino,
        'numero_albaran': numeroAlbaran,
        'notas': notas,
      };

  factory Cosecha.fromMap(Map<String, Object?> mapa) => Cosecha(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        campania: mapa['campania'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        kgCascara: (mapa['kg_cascara'] as num?)?.toDouble() ?? 0,
        rendimientoGranoPorcentaje:
            (mapa['rendimiento_grano_pct'] as num?)?.toDouble(),
        calibre: (mapa['calibre'] as String?) ?? '',
        humedadPorcentaje: (mapa['humedad_pct'] as num?)?.toDouble(),
        destino: (mapa['destino'] as String?) ?? '',
        numeroAlbaran: (mapa['numero_albaran'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
