/// Olivar — explotación olivarera con identidad persistente. Entidad
/// análoga a Queseria/Apiario/Viñedo en las otras Larrea. Single-row
/// en v0.1 (un olivar por dispositivo). Multi-olivar llega con backend
/// multi-operador (F4) — sobre todo para cooperativas que gestionan
/// varios socios.
class Olivar {
  final int? id;
  final String nombre;
  final int titularId; // FK al titular fiscal
  final String municipio;
  final String provincia;
  final String comarca;
  final bool certificacionEcologico;
  final bool certificacionIntegrada;
  /// FK textual al catálogo `do_aceite` (id de la DOP). Cadena vacía
  /// significa olivar sin DOP.
  final String dopId;
  final String notas;
  final String rutasFotosJson;

  Olivar({
    this.id,
    this.nombre = '',
    required this.titularId,
    this.municipio = '',
    this.provincia = '',
    this.comarca = '',
    this.certificacionEcologico = false,
    this.certificacionIntegrada = false,
    this.dopId = '',
    this.notas = '',
    this.rutasFotosJson = '[]',
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'titular_id': titularId,
        'municipio': municipio,
        'provincia': provincia,
        'comarca': comarca,
        'certificacion_ecologico': certificacionEcologico ? 1 : 0,
        'certificacion_integrada': certificacionIntegrada ? 1 : 0,
        'dop_id': dopId,
        'notas': notas,
        'rutas_fotos_json': rutasFotosJson,
      };

  factory Olivar.fromMap(Map<String, Object?> mapa) => Olivar(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        titularId: (mapa['titular_id'] as int?) ?? 0,
        municipio: (mapa['municipio'] as String?) ?? '',
        provincia: (mapa['provincia'] as String?) ?? '',
        comarca: (mapa['comarca'] as String?) ?? '',
        certificacionEcologico: (mapa['certificacion_ecologico'] as int? ?? 0) == 1,
        certificacionIntegrada: (mapa['certificacion_integrada'] as int? ?? 0) == 1,
        dopId: (mapa['dop_id'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
        rutasFotosJson: (mapa['rutas_fotos_json'] as String?) ?? '[]',
      );
}
