/// La explotación ganadera (tabla de una sola fila): código REGA
/// (RD 479/2004) y los puntos 1, 2, 4 y 5 del anexo V del RD 787/2023.
class Explotacion {
  Explotacion({
    this.id,
    this.codigoRega = '',
    this.nombre = '',
    this.direccion = '',
    this.municipio = '',
    this.provincia = '',
    this.latitud,
    this.longitud,
    this.clasificacion = '',
    this.capacidadMaxima = 0,
    this.especies = const {},
  });

  final int? id;

  /// «ES» + 12 cifras en las explotaciones españolas.
  final String codigoRega;
  final String nombre;
  final String direccion;
  final String municipio;
  final String provincia;
  final double? latitud;
  final double? longitud;

  /// Clasificación según la normativa sectorial, como la da la OCA.
  final String clasificacion;

  /// Capacidad máxima (cabezas), si procede; 0 = sin indicar.
  final int capacidadMaxima;

  /// Especies autorizadas (códigos de `especiesGanado`).
  final Set<String> especies;

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo_rega': codigoRega,
        'nombre': nombre,
        'direccion': direccion,
        'municipio': municipio,
        'provincia': provincia,
        'latitud': latitud,
        'longitud': longitud,
        'clasificacion': clasificacion,
        'capacidad_maxima': capacidadMaxima,
        'especies': (especies.toList()..sort()).join('|'),
      };

  factory Explotacion.fromMap(Map<String, Object?> mapa) => Explotacion(
        id: mapa['id'] as int?,
        codigoRega: (mapa['codigo_rega'] as String?) ?? '',
        nombre: (mapa['nombre'] as String?) ?? '',
        direccion: (mapa['direccion'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        provincia: (mapa['provincia'] as String?) ?? '',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        clasificacion: (mapa['clasificacion'] as String?) ?? '',
        capacidadMaxima: (mapa['capacidad_maxima'] as num?)?.toInt() ?? 0,
        especies: ((mapa['especies'] as String?) ?? '')
            .split('|')
            .where((codigo) => codigo.isNotEmpty)
            .toSet(),
      );
}

/// ¿Tiene forma de código REGA español? «ES» + 12 cifras (2 de provincia,
/// 3 de municipio y 7 de explotación). Solo avisa: no lo comprueba en REGA.
bool pareceCodigoRega(String codigo) =>
    RegExp(r'^ES\d{12}$').hasMatch(codigo.replaceAll(' ', '').toUpperCase());
