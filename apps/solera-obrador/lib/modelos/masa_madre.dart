/// Cultivo de masa madre que se mantiene con refrescos.
class MasaMadre {
  MasaMadre({
    this.id,
    required this.nombre,
    this.harinaBase = '',
    required this.creadaMs,
    this.notas = '',
    this.recordatorioHoras,
  });

  final int? id;
  final String nombre;
  final String harinaBase;
  final int creadaMs;
  final String notas;

  /// Cada cuántas horas recordar el refresco (null: sin recordatorio).
  /// Columna de la v2.
  final int? recordatorioHoras;

  MasaMadre conRecordatorio(int? horas) => MasaMadre(
        id: id,
        nombre: nombre,
        harinaBase: harinaBase,
        creadaMs: creadaMs,
        notas: notas,
        recordatorioHoras: horas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'harina_base': harinaBase,
        'creada_ms': creadaMs,
        'notas': notas,
        'recordatorio_horas': recordatorioHoras,
      };

  factory MasaMadre.fromMap(Map<String, Object?> mapa) => MasaMadre(
        id: mapa['id'] as int?,
        nombre: mapa['nombre'] as String,
        harinaBase: (mapa['harina_base'] as String?) ?? '',
        creadaMs: mapa['creada_ms'] as int,
        notas: (mapa['notas'] as String?) ?? '',
        recordatorioHoras: mapa['recordatorio_horas'] as int?,
      );
}

/// Refresco: masa madre + harina + agua, y cómo respondió.
class RefrescoMasaMadre {
  RefrescoMasaMadre({
    this.id,
    required this.masaMadreId,
    required this.fechaMs,
    required this.gramosMasaMadre,
    required this.gramosHarina,
    required this.gramosAgua,
    this.temperaturaC,
    this.horasHastaPico,
    this.notas = '',
  });

  final int? id;
  final int masaMadreId;
  final int fechaMs;
  final double gramosMasaMadre;
  final double gramosHarina;
  final double gramosAgua;
  final double? temperaturaC;
  final double? horasHastaPico;
  final String notas;

  /// Hidratación del refresco (agua / harina × 100).
  double get hidratacionPorcentaje =>
      gramosHarina == 0 ? 0 : gramosAgua / gramosHarina * 100;

  /// Proporción masa madre : harina : agua relativa a la masa madre,
  /// p. ej. «1:2:2». Con un decimal cuando no es entera.
  String get proporcion {
    if (gramosMasaMadre == 0) return '—';
    String parte(double valor) {
      final relativo = valor / gramosMasaMadre;
      return relativo == relativo.roundToDouble()
          ? relativo.toStringAsFixed(0)
          : relativo.toStringAsFixed(1);
    }

    return '1:${parte(gramosHarina)}:${parte(gramosAgua)}';
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'masa_madre_id': masaMadreId,
        'fecha_ms': fechaMs,
        'gramos_masa_madre': gramosMasaMadre,
        'gramos_harina': gramosHarina,
        'gramos_agua': gramosAgua,
        'temperatura_c': temperaturaC,
        'horas_hasta_pico': horasHastaPico,
        'notas': notas,
      };

  factory RefrescoMasaMadre.fromMap(Map<String, Object?> mapa) =>
      RefrescoMasaMadre(
        id: mapa['id'] as int?,
        masaMadreId: mapa['masa_madre_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        gramosMasaMadre: (mapa['gramos_masa_madre'] as num).toDouble(),
        gramosHarina: (mapa['gramos_harina'] as num).toDouble(),
        gramosAgua: (mapa['gramos_agua'] as num).toDouble(),
        temperaturaC: (mapa['temperatura_c'] as num?)?.toDouble(),
        horasHastaPico: (mapa['horas_hasta_pico'] as num?)?.toDouble(),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
