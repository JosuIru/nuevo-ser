/// Titular de la explotación (tabla de una sola fila).
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.registroSanitario = '',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Número del RGSEAA o del registro autonómico de pequeñas producciones.
  final String registroSanitario;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'registro_sanitario': registroSanitario,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        registroSanitario: (mapa['registro_sanitario'] as String?) ?? '',
      );
}
