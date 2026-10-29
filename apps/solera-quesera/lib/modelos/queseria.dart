/// Quesería — establecimiento quesero con identidad persistente.
/// Entidad análoga a Finca/Viñedo/Apiario en las otras Larrea.
///
/// Single-row en v0.1 (una quesería por dispositivo). Multi-quesería
/// llega con backend multi-operador (F4).
class Queseria {
  final int? id;
  final String razonSocial;
  final String nif;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final String rgseaa; // Registro General Sanitario
  final String telefono;
  final String email;
  final String notas;
  final String rutasFotosJson;

  Queseria({
    this.id,
    this.razonSocial = '',
    this.nif = '',
    this.direccion = '',
    this.latitud,
    this.longitud,
    this.rgseaa = '',
    this.telefono = '',
    this.email = '',
    this.notas = '',
    this.rutasFotosJson = '[]',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'razon_social': razonSocial,
        'nif': nif,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'rgseaa': rgseaa,
        'telefono': telefono,
        'email': email,
        'notas': notas,
        'rutas_fotos_json': rutasFotosJson,
      };

  factory Queseria.fromMap(Map<String, Object?> mapa) => Queseria(
        id: mapa['id'] as int?,
        razonSocial: (mapa['razon_social'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        direccion: (mapa['direccion'] as String?) ?? '',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        rgseaa: (mapa['rgseaa'] as String?) ?? '',
        telefono: (mapa['telefono'] as String?) ?? '',
        email: (mapa['email'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
        rutasFotosJson: (mapa['rutas_fotos_json'] as String?) ?? '[]',
      );
}
