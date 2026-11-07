/// Datos del vivero (tabla de una sola fila): el operador profesional.
///
/// Hace de «Titular» de la suite: una instalación de la app es un vivero.
/// Lleva lo que va en las cabeceras de los documentos y en la letra B del
/// pasaporte fitosanitario.
class Vivero {
  Vivero({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.codigoRopveg = '',
    this.autorizadoPasaporte = false,
    this.comunidadAutonoma = '',
    this.municipio = '',
    this.personaContactoFitosanitaria = '',
    this.registroExplotacion = '',
    this.asesorNombre = '',
    this.asesorNumeroRopo = '',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Número de registro en el ROPVEG (RD 1054/2021, art. 8.1): «ES-» más
  /// dos dígitos de la comunidad, dos de la provincia y cuatro del operador.
  final String codigoRopveg;

  /// Si la comunidad autónoma ha autorizado al vivero a expedir pasaportes
  /// fitosanitarios (RD 1054/2021, art. 22). Sin autorización, la app solo
  /// saca borradores de etiqueta, nunca un pasaporte.
  final bool autorizadoPasaporte;
  final String comunidadAutonoma;
  final String municipio;

  /// Persona de contacto para asuntos fitosanitarios (art. 22.1.d).
  final String personaContactoFitosanitaria;

  /// Registro de explotaciones agrarias, si el vivero es agrario.
  final String registroExplotacion;

  /// Asesor de gestión integrada de plagas, si lo hay, y su número ROPO.
  final String asesorNombre;
  final String asesorNumeroRopo;

  /// El código ROPVEG normalizado: mayúsculas, sin espacios y con el guion
  /// tras «ES» si falta.
  String get codigoRopvegNormalizado => normalizarCodigoRopveg(codigoRopveg);

  /// Lo que va en la letra B del pasaporte: «ES-» y el número sin el
  /// prefijo (RD 1054/2021, art. 16.3.b). Vacío si no hay código.
  String get letraBPasaporte => codigoRopvegNormalizado;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'codigo_ropveg': codigoRopveg,
        'autorizado_pasaporte': autorizadoPasaporte ? 1 : 0,
        'comunidad_autonoma': comunidadAutonoma,
        'municipio': municipio,
        'persona_contacto_fitosanitaria': personaContactoFitosanitaria,
        'registro_explotacion': registroExplotacion,
        'asesor_nombre': asesorNombre,
        'asesor_numero_ropo': asesorNumeroRopo,
      };

  factory Vivero.fromMap(Map<String, Object?> mapa) => Vivero(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        codigoRopveg: (mapa['codigo_ropveg'] as String?) ?? '',
        autorizadoPasaporte: (mapa['autorizado_pasaporte'] as int?) == 1,
        comunidadAutonoma: (mapa['comunidad_autonoma'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        personaContactoFitosanitaria:
            (mapa['persona_contacto_fitosanitaria'] as String?) ?? '',
        registroExplotacion: (mapa['registro_explotacion'] as String?) ?? '',
        asesorNombre: (mapa['asesor_nombre'] as String?) ?? '',
        asesorNumeroRopo: (mapa['asesor_numero_ropo'] as String?) ?? '',
      );
}

/// «es 0915 0001» → «ES-09150001». No inventa dígitos: si falta el prefijo
/// ES lo añade; el resto se deja como venga, sin espacios.
String normalizarCodigoRopveg(String codigo) {
  final limpio = codigo.toUpperCase().replaceAll(RegExp(r'[\s.]'), '');
  if (limpio.isEmpty) return '';
  if (limpio.startsWith('ES-')) return limpio;
  if (limpio.startsWith('ES')) return 'ES-${limpio.substring(2)}';
  return 'ES-$limpio';
}

/// Si el código tiene la forma del art. 8.1 del RD 1054/2021 (operador con
/// sede en España: «ES-» y ocho dígitos) o la del 8.2 («ES-00», dos letras
/// del Estado y cuatro dígitos). Es una comprobación de forma, no de que el
/// número exista en el registro.
bool tieneFormaCodigoRopveg(String codigo) {
  final normalizado = normalizarCodigoRopveg(codigo);
  return RegExp(r'^ES-\d{8}$').hasMatch(normalizado) ||
      RegExp(r'^ES-00[A-Z]{2}\d{4}$').hasMatch(normalizado);
}
