/// Tipos de producto de un lote y su unidad de medida.
const Map<String, String> unidadPorTipoLote = {
  'planta_seca': 'kg',
  'planta_fresca': 'kg',
  'aceite_esencial': 'ml',
  'hidrolato': 'l',
};

/// Destinos del lote. **No hay destino «medicamento»** (hard limit: un
/// medicamento a base de plantas exige la AEMPS). Cada destino cambia el
/// régimen (alimentario, cosmético, REACH/CLP): **por verificar**, y todo
/// lo que depende de él sale con sello PROVISIONAL.
const List<String> destinosLote = [
  'sin_decidir',
  'alimentario',
  'cosmetico',
  'otros_usos',
];

/// Lote de producto (planta seca o fresca, aceite esencial, hidrolato).
/// La trazabilidad hacia atrás sale del secado o la destilación que lo
/// generó (`dominio/trazabilidad.dart`).
class LoteProducto {
  LoteProducto({
    this.id,
    required this.codigo,
    required this.tipo,
    required this.especieId,
    required this.fechaMs,
    this.destino = 'sin_decidir',
    this.cantidad = 0,
    this.cantidadDisponible,
    this.envase = '',
    this.fechaConsumoPreferenteMs,
    this.notas = '',
  });

  final int? id;

  /// Código visible del lote (el de la etiqueta y el pasaporte).
  final String codigo;

  /// Clave de [unidadPorTipoLote].
  final String tipo;
  final String especieId;
  final int fechaMs;

  /// Uno de [destinosLote].
  final String destino;

  /// Cantidad producida en la [unidad] del tipo.
  final double cantidad;

  /// Lo que queda sin vender; null = igual que [cantidad].
  final double? cantidadDisponible;
  final String envase;
  final int? fechaConsumoPreferenteMs;
  final String notas;

  String get unidad => unidadPorTipoLote[tipo] ?? 'kg';
  double get disponible => cantidadDisponible ?? cantidad;

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'tipo': tipo,
        'especie_id': especieId,
        'fecha_ms': fechaMs,
        'destino': destino,
        'cantidad': cantidad,
        'cantidad_disponible': cantidadDisponible,
        'envase': envase,
        'fecha_consumo_preferente_ms': fechaConsumoPreferenteMs,
        'notas': notas,
      };

  factory LoteProducto.fromMap(Map<String, Object?> mapa) => LoteProducto(
        id: mapa['id'] as int?,
        codigo: (mapa['codigo'] as String?) ?? '',
        tipo: unidadPorTipoLote.containsKey(mapa['tipo'])
            ? mapa['tipo'] as String
            : 'planta_seca',
        especieId: (mapa['especie_id'] as String?) ?? '',
        fechaMs: mapa['fecha_ms'] as int,
        destino: destinosLote.contains(mapa['destino'])
            ? mapa['destino'] as String
            : 'sin_decidir',
        cantidad: (mapa['cantidad'] as num?)?.toDouble() ?? 0,
        cantidadDisponible: (mapa['cantidad_disponible'] as num?)?.toDouble(),
        envase: (mapa['envase'] as String?) ?? '',
        fechaConsumoPreferenteMs: mapa['fecha_consumo_preferente_ms'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Código de lote propuesto: prefijo del tipo + año + número correlativo
/// de tres cifras («AE-2026-003»). La persona lo puede cambiar.
String proponerCodigoLote(String tipo, int anyo, Iterable<String> existentes) {
  final prefijo = switch (tipo) {
    'aceite_esencial' => 'AE',
    'hidrolato' => 'HI',
    'planta_fresca' => 'PF',
    _ => 'PS',
  };
  final usados = existentes.toSet();
  var numero = 1;
  String candidato() => '$prefijo-$anyo-${numero.toString().padLeft(3, '0')}';
  while (usados.contains(candidato())) {
    numero++;
  }
  return candidato();
}
