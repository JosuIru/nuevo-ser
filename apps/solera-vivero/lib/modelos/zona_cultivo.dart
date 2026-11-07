/// Tipos de zona del vivero.
const List<String> tiposZonaCultivo = [
  'nave',
  'invernadero',
  'umbraculo',
  'exterior',
];

/// Lugar donde están las bandejas o las plantas: una nave, un invernadero,
/// un umbráculo o una parcela de cultivo exterior (esta con GPS).
class ZonaCultivo {
  ZonaCultivo({
    this.id,
    required this.nombre,
    this.tipo = 'nave',
    this.superficieM2,
    this.codigoSigpac = '',
    this.latitud,
    this.longitud,
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Uno de [tiposZonaCultivo].
  final String tipo;
  final double? superficieM2;

  /// Solo para parcelas exteriores (recinto oficial).
  final String codigoSigpac;
  final double? latitud;
  final double? longitud;
  final String notas;

  bool get esExterior => tipo == 'exterior';
  bool get tieneUbicacion => latitud != null && longitud != null;

  ZonaCultivo copiarConUbicacion(double latitudNueva, double longitudNueva) =>
      ZonaCultivo(
        id: id,
        nombre: nombre,
        tipo: tipo,
        superficieM2: superficieM2,
        codigoSigpac: codigoSigpac,
        latitud: latitudNueva,
        longitud: longitudNueva,
        notas: notas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'superficie_m2': superficieM2,
        'codigo_sigpac': codigoSigpac,
        'latitud': latitud,
        'longitud': longitud,
        'notas': notas,
      };

  factory ZonaCultivo.fromMap(Map<String, Object?> mapa) => ZonaCultivo(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? 'nave',
        superficieM2: (mapa['superficie_m2'] as num?)?.toDouble(),
        codigoSigpac: (mapa['codigo_sigpac'] as String?) ?? '',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
