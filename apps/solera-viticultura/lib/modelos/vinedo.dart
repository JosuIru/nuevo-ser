import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;

/// Un viñedo: parcela vitícola con un nombre, una localización
/// aproximada (centroide para centrar el mapa al abrirla) y un color
/// de identificación. Las cepas pueden estar asociadas a un viñedo o
/// estar como **punto suelto** (`vinedoId == null` en Cepa) — útil para
/// catalogar una cepa singular fuera del viñedo principal.
///
/// Los campos SIGPAC y `superficieHectareas` son requeridos por el
/// libro oficial de explotación de la PAC (RD 1311/2012). En v0.1
/// son free-text porque no validamos contra la BBDD pública del
/// SIGPAC todavía — eso entra en F2 con backend.
class Vinedo {
  final int? id;
  final String nombre;
  final double? latitudCentroide;
  final double? longitudCentroide;
  final int colorEntero;
  final String notas;
  final int fechaCreacionMs;

  // SIGPAC: la quíntupla oficial que identifica una parcela en
  // España. Provincia y municipio son códigos INE; polígono, parcela
  // y recinto son números dentro del catastro rústico.
  final String sigpacProvincia;
  final String sigpacMunicipio;
  final String sigpacPoligono;
  final String sigpacParcela;
  final String sigpacRecinto;
  final double? superficieHectareas;

  /// Área marcada en el mapa: JSON `[[lat,lng],…]` (nuevo_ser_mapa).
  final String contorno;

  List<LatLng> get vertices => leerContorno(contorno);

  Vinedo({
    this.id,
    required this.nombre,
    this.latitudCentroide,
    this.longitudCentroide,
    required this.colorEntero,
    this.notas = '',
    required this.fechaCreacionMs,
    this.sigpacProvincia = '',
    this.sigpacMunicipio = '',
    this.sigpacPoligono = '',
    this.sigpacParcela = '',
    this.sigpacRecinto = '',
    this.superficieHectareas,
    this.contorno = contornoVacio,
  });

  /// Devuelve la referencia SIGPAC formateada o cadena vacía si el
  /// viñedo aún no la tiene configurada. Formato canónico para
  /// inspección: `PR:MU:PO:PA:RE`.
  String get referenciaSigpac {
    if (sigpacProvincia.isEmpty &&
        sigpacMunicipio.isEmpty &&
        sigpacPoligono.isEmpty &&
        sigpacParcela.isEmpty &&
        sigpacRecinto.isEmpty) {
      return '';
    }
    return [
      sigpacProvincia,
      sigpacMunicipio,
      sigpacPoligono,
      sigpacParcela,
      sigpacRecinto,
    ].map((s) => s.isEmpty ? '—' : s).join(':');
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'latitud_centroide': latitudCentroide,
        'longitud_centroide': longitudCentroide,
        'color_entero': colorEntero,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'sigpac_provincia': sigpacProvincia,
        'sigpac_municipio': sigpacMunicipio,
        'sigpac_poligono': sigpacPoligono,
        'sigpac_parcela': sigpacParcela,
        'sigpac_recinto': sigpacRecinto,
        'superficie_hectareas': superficieHectareas,
        'contorno': contorno,
      };

  factory Vinedo.fromMap(Map<String, Object?> mapa) => Vinedo(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        latitudCentroide: (mapa['latitud_centroide'] as num?)?.toDouble(),
        longitudCentroide: (mapa['longitud_centroide'] as num?)?.toDouble(),
        colorEntero: (mapa['color_entero'] as int?) ?? 0xFF7D2A2A,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: mapa['fecha_creacion_ms'] as int,
        sigpacProvincia: (mapa['sigpac_provincia'] as String?) ?? '',
        sigpacMunicipio: (mapa['sigpac_municipio'] as String?) ?? '',
        sigpacPoligono: (mapa['sigpac_poligono'] as String?) ?? '',
        sigpacParcela: (mapa['sigpac_parcela'] as String?) ?? '',
        sigpacRecinto: (mapa['sigpac_recinto'] as String?) ?? '',
        superficieHectareas: (mapa['superficie_hectareas'] as num?)?.toDouble(),
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
      );
}
