/// Titular y datos generales de la explotación (tabla de una sola fila).
///
/// Hace de «Explotación» de la ficha: una instalación de la app es una
/// explotación. Los campos son los de la cabecera del cuaderno de
/// explotación (titular, NIF, registro y asesor).
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.registroExplotacion = '',
    this.municipio = '',
    this.asesorNombre = '',
    this.asesorNumeroRopo = '',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Número del registro de explotaciones agrarias (REGEPA o el autonómico).
  final String registroExplotacion;
  final String municipio;

  /// Asesor de gestión integrada de plagas, si lo hay, y su número ROPO.
  final String asesorNombre;
  final String asesorNumeroRopo;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'registro_explotacion': registroExplotacion,
        'municipio': municipio,
        'asesor_nombre': asesorNombre,
        'asesor_numero_ropo': asesorNumeroRopo,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        registroExplotacion: (mapa['registro_explotacion'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        asesorNombre: (mapa['asesor_nombre'] as String?) ?? '',
        asesorNumeroRopo: (mapa['asesor_numero_ropo'] as String?) ?? '',
      );
}
