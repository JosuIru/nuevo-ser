/// Parcela de cultivo (recinto SIGPAC o parte de él) con una especie
/// principal. La recolección silvestre va en `ZonaRecoleccion`.
class Parcela {
  Parcela({
    this.id,
    required this.nombre,
    required this.especieId,
    this.codigoSigpac = '',
    this.superficieHa = 0,
    this.anyoPlantacion,
    this.ecologico = false,
    this.regadio = false,
    this.latitud,
    this.longitud,
    this.notas = '',
    this.fechaCreacionMs = 0,
  });

  final int? id;
  final String nombre;

  /// Id del catálogo de especies o nombre libre si no está.
  final String especieId;

  /// Provincia:municipio:agregado:zona:polígono:parcela:recinto.
  final String codigoSigpac;
  final double superficieHa;
  final int? anyoPlantacion;

  /// Inscrita en agricultura ecológica (lo certifica el organismo de control).
  final bool ecologico;
  final bool regadio;
  final double? latitud;
  final double? longitud;
  final String notas;
  final int fechaCreacionMs;

  bool get tieneUbicacion => latitud != null && longitud != null;

  Parcela copiarConUbicacion(double latitud, double longitud) =>
      Parcela.fromMap({...toMap(), 'latitud': latitud, 'longitud': longitud});

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'especie_id': especieId,
        'codigo_sigpac': codigoSigpac,
        'superficie_ha': superficieHa,
        'anyo_plantacion': anyoPlantacion,
        'ecologico': ecologico ? 1 : 0,
        'regadio': regadio ? 1 : 0,
        'latitud': latitud,
        'longitud': longitud,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory Parcela.fromMap(Map<String, Object?> mapa) => Parcela(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        especieId: (mapa['especie_id'] as String?) ?? '',
        codigoSigpac: (mapa['codigo_sigpac'] as String?) ?? '',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble() ?? 0,
        anyoPlantacion: mapa['anyo_plantacion'] as int?,
        ecologico: (mapa['ecologico'] as int?) == 1,
        regadio: (mapa['regadio'] as int?) == 1,
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
