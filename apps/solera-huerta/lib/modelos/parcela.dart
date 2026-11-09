import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;

/// Situación de la parcela frente a la producción ecológica. La app no
/// certifica nada: es lo que dice el certificado del organismo de control.
const List<String> estadosEcologicos = [
  'ecologica',
  'conversion',
  'convencional',
];

/// Sistemas de riego de una parcela de regadío.
const List<String> sistemasRiego = ['goteo', 'aspersion', 'manta', 'otro'];

/// Parcela (recinto SIGPAC o parte de él) dividida en bancales.
class Parcela {
  Parcela({
    this.id,
    required this.nombre,
    this.codigoSigpac = '',
    this.superficieHa = 0,
    this.estadoEcologico = 'ecologica',
    this.fechaInicioConversionMs,
    this.regadio = true,
    this.sistemaRiego = '',
    this.latitud,
    this.longitud,
    this.contorno = contornoVacio,
    this.notas = '',
    this.fechaCreacionMs = 0,
  });

  final int? id;
  final String nombre;

  /// Provincia:municipio:agregado:zona:polígono:parcela:recinto.
  final String codigoSigpac;
  final double superficieHa;

  /// Uno de [estadosEcologicos].
  final String estadoEcologico;

  /// Inicio del periodo de conversión (lo fija el organismo de control).
  final int? fechaInicioConversionMs;
  final bool regadio;

  /// Uno de [sistemasRiego] si es de regadío; vacío si no.
  final String sistemaRiego;
  final double? latitud;
  final double? longitud;

  /// Área marcada en el mapa: JSON `[[lat,lng],…]` (nuevo_ser_mapa).
  final String contorno;

  List<LatLng> get vertices => leerContorno(contorno);
  final String notas;
  final int fechaCreacionMs;

  bool get tieneUbicacion => latitud != null && longitud != null;

  Parcela copiarConUbicacion(double latitud, double longitud) => Parcela(
        id: id,
        nombre: nombre,
        codigoSigpac: codigoSigpac,
        superficieHa: superficieHa,
        estadoEcologico: estadoEcologico,
        fechaInicioConversionMs: fechaInicioConversionMs,
        regadio: regadio,
        sistemaRiego: sistemaRiego,
        latitud: latitud,
        longitud: longitud,
        contorno: contorno,
        notas: notas,
        fechaCreacionMs: fechaCreacionMs,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'codigo_sigpac': codigoSigpac,
        'superficie_ha': superficieHa,
        'estado_ecologico': estadoEcologico,
        'fecha_inicio_conversion_ms': fechaInicioConversionMs,
        'regadio': regadio ? 1 : 0,
        'sistema_riego': regadio ? sistemaRiego : '',
        'latitud': latitud,
        'longitud': longitud,
        'contorno': contorno,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory Parcela.fromMap(Map<String, Object?> mapa) => Parcela(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        codigoSigpac: (mapa['codigo_sigpac'] as String?) ?? '',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble() ?? 0,
        estadoEcologico: (mapa['estado_ecologico'] as String?) ?? 'ecologica',
        fechaInicioConversionMs: mapa['fecha_inicio_conversion_ms'] as int?,
        regadio: (mapa['regadio'] as int?) == 1,
        sistemaRiego: (mapa['sistema_riego'] as String?) ?? '',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}
