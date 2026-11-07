/// Titular y datos generales de la huerta (tabla de una sola fila).
///
/// Hace de «Huerta» de la ficha: una instalación de la app es una huerta
/// (explotación). Lleva los datos de cabecera del cuaderno para el
/// certificador ecológico y del cuaderno de tratamientos.
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.nombreHuerta = '',
    this.registroExplotacion = '',
    this.municipio = '',
    this.comunidadAutonoma = '',
    this.organismoControl = '',
    this.codigoOperadorEcologico = '',
    this.asesorNombre = '',
    this.asesorNumeroRopo = '',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Nombre comercial de la huerta (el que va en las cestas).
  final String nombreHuerta;

  /// Número del registro de explotaciones agrarias (REGEPA o el autonómico).
  final String registroExplotacion;
  final String municipio;
  final String comunidadAutonoma;

  /// Autoridad u organismo de control ecológico (CPAEN, ENEEK, CCPAE…).
  final String organismoControl;

  /// Código de operador que da el organismo de control.
  final String codigoOperadorEcologico;

  /// Asesor de gestión integrada de plagas, si lo hay, y su número ROPO.
  final String asesorNombre;
  final String asesorNumeroRopo;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'nombre_huerta': nombreHuerta,
        'registro_explotacion': registroExplotacion,
        'municipio': municipio,
        'comunidad_autonoma': comunidadAutonoma,
        'organismo_control': organismoControl,
        'codigo_operador_ecologico': codigoOperadorEcologico,
        'asesor_nombre': asesorNombre,
        'asesor_numero_ropo': asesorNumeroRopo,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        nombreHuerta: (mapa['nombre_huerta'] as String?) ?? '',
        registroExplotacion: (mapa['registro_explotacion'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        comunidadAutonoma: (mapa['comunidad_autonoma'] as String?) ?? '',
        organismoControl: (mapa['organismo_control'] as String?) ?? '',
        codigoOperadorEcologico:
            (mapa['codigo_operador_ecologico'] as String?) ?? '',
        asesorNombre: (mapa['asesor_nombre'] as String?) ?? '',
        asesorNumeroRopo: (mapa['asesor_numero_ropo'] as String?) ?? '',
      );
}
