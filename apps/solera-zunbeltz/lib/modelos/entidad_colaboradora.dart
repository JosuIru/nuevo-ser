/// Entidad que impulsa, apoya o colabora con el espacio, con su logo. La
/// lista la mantiene coordinación en el panel de WordPress y llega con
/// `GET /entidades`; no va a la base de datos ni se sincroniza.
class EntidadColaboradora {
  const EntidadColaboradora({
    required this.clave,
    required this.nombre,
    required this.grupo,
    this.enlace = '',
    this.logoUrl = '',
    this.logoPropio = false,
  });

  /// Estable; con ella se busca el logo empaquetado en la app.
  final String clave;
  final String nombre;

  /// `impulsan`, `apoyan`, `colaboran` o `miembro_de`.
  final String grupo;

  /// Web de la entidad, o ''.
  final String enlace;

  /// Dirección del logo en el servidor, o ''.
  final String logoUrl;

  /// Coordinación ha subido otro logo: hay que usar [logoUrl] y no el
  /// empaquetado.
  final bool logoPropio;

  /// `null` si le falta lo imprescindible.
  static EntidadColaboradora? desdeJson(Map<Object?, Object?> json) {
    final clave = json['clave'];
    final nombre = json['nombre'];
    final grupo = json['grupo'];
    if (clave is! String || clave.isEmpty) return null;
    if (nombre is! String || nombre.isEmpty || grupo is! String) return null;
    return EntidadColaboradora(
      clave: clave,
      nombre: nombre,
      grupo: grupo,
      enlace: _soloWeb(json['enlace']),
      logoUrl: _soloWeb(json['logo_url']),
      logoPropio: json['logo_propio'] == true,
    );
  }

  Map<String, Object?> aJson() => {
        'clave': clave,
        'nombre': nombre,
        'grupo': grupo,
        'enlace': enlace,
        'logo_url': logoUrl,
        'logo_propio': logoPropio,
      };
}

String _soloWeb(Object? valor) {
  if (valor is! String) return '';
  final uri = Uri.tryParse(valor);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return '';
  }
  return valor;
}
