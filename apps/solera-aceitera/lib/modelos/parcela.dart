/// Parcela del olivar. Entidad análoga a Vinedo/Apiario/Zona en las
/// otras Larrea. Cada parcela tiene su polígono SIGPAC, superficie,
/// variedad mayoritaria y régimen de riego.
///
/// El marco de plantación es texto libre porque va desde "7x7" o "8x6"
/// (tradicional) hasta "1.5x4 superintensivo" — formatos heterogéneos
/// que el agricultor reconoce por convención local.
class Parcela {
  final int? id;
  final int olivarId; // FK Olivar
  final String nombre;
  final String codigoSigpac;
  final double superficieHa;
  /// FK textual al catálogo `variedades_olivo` (id de la variedad
  /// mayoritaria). Cadena vacía si la parcela es mezcla sin variedad
  /// dominante.
  final String variedadMayoritariaId;
  final String marcoPlantacion;
  final int edadMediaAnyos;
  /// Uno de: `secano` / `superficial` / `goteo` / `aspersion` / `mixto`.
  final String sistemaRiego;
  final double? latitud;
  final double? longitud;
  /// GeoJSON del polígono SIGPAC. Cadena vacía si no se dibujó.
  final String poligonoGeoJson;
  final String notas;
  final String rutasFotosJson;
  final int fechaCreacionMs;

  Parcela({
    this.id,
    required this.olivarId,
    this.nombre = '',
    this.codigoSigpac = '',
    this.superficieHa = 0,
    this.variedadMayoritariaId = '',
    this.marcoPlantacion = '',
    this.edadMediaAnyos = 0,
    this.sistemaRiego = 'secano',
    this.latitud,
    this.longitud,
    this.poligonoGeoJson = '',
    this.notas = '',
    this.rutasFotosJson = '[]',
    required this.fechaCreacionMs,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'olivar_id': olivarId,
        'nombre': nombre,
        'codigo_sigpac': codigoSigpac,
        'superficie_ha': superficieHa,
        'variedad_mayoritaria_id': variedadMayoritariaId,
        'marco_plantacion': marcoPlantacion,
        'edad_media_anyos': edadMediaAnyos,
        'sistema_riego': sistemaRiego,
        'latitud': latitud,
        'longitud': longitud,
        'poligono_geojson': poligonoGeoJson,
        'notas': notas,
        'rutas_fotos_json': rutasFotosJson,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory Parcela.fromMap(Map<String, Object?> mapa) => Parcela(
        id: mapa['id'] as int?,
        olivarId: (mapa['olivar_id'] as int?) ?? 0,
        nombre: (mapa['nombre'] as String?) ?? '',
        codigoSigpac: (mapa['codigo_sigpac'] as String?) ?? '',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble() ?? 0,
        variedadMayoritariaId: (mapa['variedad_mayoritaria_id'] as String?) ?? '',
        marcoPlantacion: (mapa['marco_plantacion'] as String?) ?? '',
        edadMediaAnyos: (mapa['edad_media_anyos'] as int?) ?? 0,
        sistemaRiego: (mapa['sistema_riego'] as String?) ?? 'secano',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        poligonoGeoJson: (mapa['poligono_geojson'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
        rutasFotosJson: (mapa['rutas_fotos_json'] as String?) ?? '[]',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
