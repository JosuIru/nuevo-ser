import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;

/// Un apiario (colmenar): asentamiento fijo con un código REGA propio.
/// Las colmenas pueden estar asociadas a un apiario o estar como
/// **ubicación puntual** (`apiarioId == null`) — útil para registrar
/// una colmena temporal en un sitio donde no se va a quedar (mielada
/// puntual, recogida de enjambre, traslado en tránsito).
///
/// El campo `codigoSitran` es el identificador del asentamiento en
/// SITRAN-AP (sistema de información de movimiento animal). En v0.1
/// es free-text; en F2 con backend se valida contra la BBDD oficial.
class Apiario {
  final int? id;
  final String nombre;
  final double? latitudCentroide;
  final double? longitudCentroide;
  final int colorEntero;
  final String notas;
  final int fechaCreacionMs;

  // SITRAN-AP
  final String codigoSitran;
  final double? superficieHectareas;

  /// Terreno del colmenar marcado en el mapa: JSON `[[lat,lng],…]`
  /// (nuevo_ser_mapa).
  final String contorno;

  List<LatLng> get vertices => leerContorno(contorno);

  Apiario({
    this.id,
    required this.nombre,
    this.latitudCentroide,
    this.longitudCentroide,
    required this.colorEntero,
    this.notas = '',
    required this.fechaCreacionMs,
    this.codigoSitran = '',
    this.superficieHectareas,
    this.contorno = contornoVacio,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'latitud_centroide': latitudCentroide,
        'longitud_centroide': longitudCentroide,
        'color_entero': colorEntero,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'codigo_sitran': codigoSitran,
        'superficie_hectareas': superficieHectareas,
        'contorno': contorno,
      };

  factory Apiario.fromMap(Map<String, Object?> mapa) => Apiario(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        latitudCentroide: (mapa['latitud_centroide'] as num?)?.toDouble(),
        longitudCentroide: (mapa['longitud_centroide'] as num?)?.toDouble(),
        colorEntero: (mapa['color_entero'] as int?) ?? 0xFFB8860B,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: mapa['fecha_creacion_ms'] as int,
        codigoSitran: (mapa['codigo_sitran'] as String?) ?? '',
        superficieHectareas: (mapa['superficie_hectareas'] as num?)?.toDouble(),
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
      );
}
