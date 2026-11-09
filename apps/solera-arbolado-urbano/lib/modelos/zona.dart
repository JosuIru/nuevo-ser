import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;

/// Sector de la ciudad bajo el que se agrupan árboles. Equivalente B2B
/// a `Vinedo`/`Apiario` de las hermanas. Centroide aproximado y nombre
/// humano (parque, paseo, calle, distrito).
///
/// El campo `codigoMunicipal` es la identificación interna del
/// ayuntamiento (p. ej. "PASEO-VALLE-OSORIO" o un código catastral
/// urbano). Se usa para casar contra el inventario municipal preexistente.
class Zona {
  final int? id;
  final String nombre;
  final String codigoMunicipal;
  final double? latitudCentroide;
  final double? longitudCentroide;
  final int colorEntero;
  final String notas;
  final int fechaCreacionMs;

  /// Área de la zona marcada en el mapa: JSON `[[lat,lng],…]`
  /// (nuevo_ser_mapa). El centroide se calcula de ella al guardar.
  final String contorno;

  List<LatLng> get vertices => leerContorno(contorno);

  Zona({
    this.id,
    required this.nombre,
    this.codigoMunicipal = '',
    this.latitudCentroide,
    this.longitudCentroide,
    this.colorEntero = 0xFF2E7D32,
    this.notas = '',
    required this.fechaCreacionMs,
    this.contorno = contornoVacio,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'codigo_municipal': codigoMunicipal,
        'latitud_centroide': latitudCentroide,
        'longitud_centroide': longitudCentroide,
        'color_entero': colorEntero,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'contorno': contorno,
      };

  factory Zona.fromMap(Map<String, Object?> mapa) => Zona(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        codigoMunicipal: (mapa['codigo_municipal'] as String?) ?? '',
        latitudCentroide: (mapa['latitud_centroide'] as num?)?.toDouble(),
        longitudCentroide: (mapa['longitud_centroide'] as num?)?.toDouble(),
        colorEntero: (mapa['color_entero'] as int?) ?? 0xFF2E7D32,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
      );
}
