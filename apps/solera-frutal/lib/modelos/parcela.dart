import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;

/// Especies que cubre Larrea Frutal (identificadores; el nombre visible sale
/// de `frut.especie_<id>` y los datos agronómicos, del catálogo de especies).
const List<String> especiesFrutal = [
  'almendro',
  'avellano',
  'nogal',
  'castano',
  'pistachero',
  'hueso',
  'pepita',
];

/// Sistemas de riego de una parcela de regadío.
const List<String> sistemasRiego = ['goteo', 'aspersion', 'superficie'];

/// Parcela (recinto SIGPAC o parte de él) con una especie principal.
///
/// El marco de plantación es texto libre («7x6», «6 x 5,5») porque así lo
/// escribe la gente; [arbolesPorHectareaDesdeMarco] lo interpreta.
class Parcela {
  Parcela({
    this.id,
    required this.nombre,
    required this.especieId,
    this.variedadPrincipalId = '',
    this.codigoSigpac = '',
    this.superficieHa = 0,
    this.marcoPlantacion = '',
    this.anyoPlantacion,
    this.regadio = false,
    this.sistemaRiego = '',
    this.latitud,
    this.longitud,
    this.contorno = contornoVacio,
    this.notas = '',
    this.fechaCreacionMs = 0,
  });

  final int? id;
  final String nombre;

  /// Uno de [especiesFrutal].
  final String especieId;

  /// Id del catálogo de variedades o nombre libre si no está.
  final String variedadPrincipalId;

  /// Provincia:municipio:agregado:zona:polígono:parcela:recinto.
  final String codigoSigpac;
  final double superficieHa;
  final String marcoPlantacion;
  final int? anyoPlantacion;

  /// Secano (false) o regadío (true).
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

  /// Árboles por hectárea según el marco, o null si no se entiende.
  double? get arbolesPorHectarea =>
      arbolesPorHectareaDesdeMarco(marcoPlantacion);

  Parcela copiarConUbicacion(double latitud, double longitud) => Parcela(
        id: id,
        nombre: nombre,
        especieId: especieId,
        variedadPrincipalId: variedadPrincipalId,
        codigoSigpac: codigoSigpac,
        superficieHa: superficieHa,
        marcoPlantacion: marcoPlantacion,
        anyoPlantacion: anyoPlantacion,
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
        'especie_id': especieId,
        'variedad_principal_id': variedadPrincipalId,
        'codigo_sigpac': codigoSigpac,
        'superficie_ha': superficieHa,
        'marco_plantacion': marcoPlantacion,
        'anyo_plantacion': anyoPlantacion,
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
        especieId: (mapa['especie_id'] as String?) ?? 'almendro',
        variedadPrincipalId: (mapa['variedad_principal_id'] as String?) ?? '',
        codigoSigpac: (mapa['codigo_sigpac'] as String?) ?? '',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble() ?? 0,
        marcoPlantacion: (mapa['marco_plantacion'] as String?) ?? '',
        anyoPlantacion: mapa['anyo_plantacion'] as int?,
        regadio: (mapa['regadio'] as int?) == 1,
        sistemaRiego: (mapa['sistema_riego'] as String?) ?? '',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );
}

/// «7x6», «7 x 6», «6,5×5» → árboles por hectárea (10 000 / (a·b)).
/// Null si el texto no tiene dos medidas positivas.
double? arbolesPorHectareaDesdeMarco(String marco) {
  final partes = marco
      .toLowerCase()
      .replaceAll('×', 'x')
      .replaceAll('*', 'x')
      .replaceAll(',', '.')
      .split('x')
      .map((parte) =>
          double.tryParse(parte.replaceAll(RegExp(r'[^0-9.]'), '').trim()))
      .toList();
  if (partes.length != 2 || partes.contains(null)) return null;
  final superficieArbol = partes[0]! * partes[1]!;
  if (superficieArbol <= 0) return null;
  return 10000 / superficieArbol;
}
