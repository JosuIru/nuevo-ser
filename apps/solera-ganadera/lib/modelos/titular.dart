/// Titular de la explotación (tabla de una sola fila). Datos del punto 3
/// del anexo V del RD 787/2023 (libro de registro).
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.telefono = '',
    this.correo = '',
    this.direccion = '',
  });

  final int? id;
  final String nombre;
  final String nif;
  final String telefono;
  final String correo;
  final String direccion;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        telefono: (mapa['telefono'] as String?) ?? '',
        correo: (mapa['correo'] as String?) ?? '',
        direccion: (mapa['direccion'] as String?) ?? '',
      );
}
