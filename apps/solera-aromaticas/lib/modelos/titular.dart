/// Titular y datos generales de la explotación (tabla de una sola fila).
///
/// Hace de «Explotación» de la ficha: una instalación de la app es una
/// explotación. Lleva los datos de cabecera del cuaderno de explotación
/// (titular, NIF, registro, asesor) y el registro sanitario si lo tiene.
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.registroExplotacion = '',
    this.registroSanitario = '',
    this.municipio = '',
    this.comunidadAutonoma = '',
    this.asesorNombre = '',
    this.asesorNumeroRopo = '',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Número del registro de explotaciones agrarias (REGEPA o el autonómico).
  final String registroExplotacion;

  /// Número del registro sanitario (RGSEAA o autonómico), si lo tiene. La
  /// app no dice si hace falta: depende del destino (BLOQUEOS).
  final String registroSanitario;
  final String municipio;

  /// Comunidad autónoma de la explotación (texto libre).
  final String comunidadAutonoma;

  /// Asesor de gestión integrada de plagas, si lo hay, y su número ROPO.
  final String asesorNombre;
  final String asesorNumeroRopo;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'registro_explotacion': registroExplotacion,
        'registro_sanitario': registroSanitario,
        'municipio': municipio,
        'comunidad_autonoma': comunidadAutonoma,
        'asesor_nombre': asesorNombre,
        'asesor_numero_ropo': asesorNumeroRopo,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        registroExplotacion: (mapa['registro_explotacion'] as String?) ?? '',
        registroSanitario: (mapa['registro_sanitario'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        comunidadAutonoma: (mapa['comunidad_autonoma'] as String?) ?? '',
        asesorNombre: (mapa['asesor_nombre'] as String?) ?? '',
        asesorNumeroRopo: (mapa['asesor_numero_ropo'] as String?) ?? '',
      );
}
