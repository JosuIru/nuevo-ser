/// Origen del material de reproducción, como lo pide el certificador: en
/// ecológico se usa semilla ecológica o en conversión y, si no la hay, la
/// convencional exige una autorización (Reglamento (UE) 2018/848,
/// anexo II, parte I, punto 1.8: **por verificar** el texto vigente).
const List<String> origenesSemilla = [
  'propia',
  'ecologica',
  'conversion',
  'no_ecologica_autorizada',
  'intercambio',
];

/// Lote de semilla (comprada o propia del banco de semillas).
class LoteSemilla {
  LoteSemilla({
    this.id,
    required this.codigo,
    required this.especieId,
    this.variedad = '',
    this.origen = 'ecologica',
    this.proveedor = '',
    this.anyoObtencion,
    this.cantidad = '',
    this.germinacionPorcentaje,
    this.numeroAutorizacion = '',
    this.cosechaOrigenId,
    this.fechaMs = 0,
    this.notas = '',
  });

  final int? id;

  /// Código del lote: el de la etiqueta o uno propio («TOM-CB-2026»).
  final String codigo;

  /// Id del catálogo de cultivos o nombre libre.
  final String especieId;
  final String variedad;

  /// Uno de [origenesSemilla].
  final String origen;

  /// Casa de semillas, red de semillas o persona del intercambio.
  final String proveedor;

  /// Año en que se obtuvo la semilla.
  final int? anyoObtencion;

  /// Texto libre: «25 g», «2 sobres», «300 semillas».
  final String cantidad;
  final double? germinacionPorcentaje;

  /// Autorización del organismo de control para semilla no ecológica.
  final String numeroAutorizacion;

  /// Si es propia, la cosecha de la que sale (trazabilidad del banco).
  final int? cosechaOrigenId;
  final int fechaMs;
  final String notas;

  bool get necesitaAutorizacion => origen == 'no_ecologica_autorizada';

  /// Semilla no ecológica sin número de autorización apuntado.
  bool get faltaAutorizacion =>
      necesitaAutorizacion && numeroAutorizacion.trim().isEmpty;

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'especie_id': especieId,
        'variedad': variedad,
        'origen': origen,
        'proveedor': proveedor,
        'anyo_obtencion': anyoObtencion,
        'cantidad': cantidad,
        'germinacion_pct': germinacionPorcentaje,
        'numero_autorizacion': numeroAutorizacion,
        'cosecha_origen_id': cosechaOrigenId,
        'fecha_ms': fechaMs,
        'notas': notas,
      };

  factory LoteSemilla.fromMap(Map<String, Object?> mapa) => LoteSemilla(
        id: mapa['id'] as int?,
        codigo: (mapa['codigo'] as String?) ?? '',
        especieId: (mapa['especie_id'] as String?) ?? '',
        variedad: (mapa['variedad'] as String?) ?? '',
        origen: (mapa['origen'] as String?) ?? 'ecologica',
        proveedor: (mapa['proveedor'] as String?) ?? '',
        anyoObtencion: mapa['anyo_obtencion'] as int?,
        cantidad: (mapa['cantidad'] as String?) ?? '',
        germinacionPorcentaje: (mapa['germinacion_pct'] as num?)?.toDouble(),
        numeroAutorizacion: (mapa['numero_autorizacion'] as String?) ?? '',
        cosechaOrigenId: mapa['cosecha_origen_id'] as int?,
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
