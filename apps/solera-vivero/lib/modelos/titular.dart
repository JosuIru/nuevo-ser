/// Titular de la explotación (tabla de una sola fila).
class Titular {
  Titular({this.id, this.nombre = '', this.nif = ''});

  final int? id;
  final String nombre;
  final String nif;

  Map<String, Object?> toMap() => {'id': id, 'nombre': nombre, 'nif': nif};

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
      );
}
