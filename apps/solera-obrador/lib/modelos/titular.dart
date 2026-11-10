/// Titular de la explotación (tabla de una sola fila).
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.registroSanitario = '',
    this.direccion = '',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Número del RGSEAA o del registro autonómico de pequeñas producciones.
  final String registroSanitario;

  /// Dirección del obrador para la etiqueta (Reglamento (UE) 1169/2011,
  /// art. 9.1.h). Columna de la v3.
  final String direccion;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'registro_sanitario': registroSanitario,
        'direccion': direccion,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        registroSanitario: (mapa['registro_sanitario'] as String?) ?? '',
        direccion: (mapa['direccion'] as String?) ?? '',
      );
}
