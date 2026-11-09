import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show contornoVacio, leerContorno;

import 'codificacion.dart';

/// Qué se cultiva en la parcela: manzano (pomarada) o vid (viña de txakoli).
const List<String> cultivosParcela = ['manzano', 'vid'];

/// Pomarada (o viña de txakoli). Los campos de identificación son los que
/// el pliego de la DOP Euskal Sagardoa (jul-2024, ap. E) pide registrar:
/// polígono, parcela, recinto, superficie, número de árboles, edad y
/// variedad.
class Pomarada {
  Pomarada({
    this.id,
    required this.nombre,
    this.cultivo = 'manzano',
    this.municipio = '',
    this.poligono = '',
    this.parcela = '',
    this.recinto = '',
    this.superficieHa = 0,
    this.numeroArboles = 0,
    this.anioPlantacion,
    this.variedades = const {},
    this.registradaDop = false,
    this.latitud,
    this.longitud,
    this.contorno = contornoVacio,
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Uno de [cultivosParcela].
  final String cultivo;
  final String municipio;
  final String poligono;
  final String parcela;
  final String recinto;
  final double superficieHa;

  /// Manzanos (o cepas) plantados.
  final int numeroArboles;
  final int? anioPlantacion;

  /// Ids del catálogo de variedades.
  final Set<String> variedades;

  /// Inscrita en los registros de la DOP (la app no lo comprueba: lo dice
  /// la persona).
  final bool registradaDop;
  final double? latitud;
  final double? longitud;

  /// Área marcada en el mapa: JSON `[[lat,lng],…]` (nuevo_ser_mapa).
  final String contorno;

  List<LatLng> get vertices => leerContorno(contorno);
  final String notas;

  bool get tieneUbicacion => latitud != null && longitud != null;

  /// `polígono/parcela/recinto`, o vacío si falta todo.
  String get referenciaSigpac =>
      [poligono, parcela, recinto].every((parte) => parte.trim().isEmpty)
          ? ''
          : [poligono, parcela, recinto].map((parte) => parte.trim()).join('/');

  /// Árboles por hectárea, o null sin superficie.
  double? get densidadArbolesHa => superficieHa > 0 && numeroArboles > 0
      ? numeroArboles / superficieHa
      : null;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'cultivo': cultivo,
        'municipio': municipio,
        'poligono': poligono,
        'parcela': parcela,
        'recinto': recinto,
        'superficie_ha': superficieHa,
        'numero_arboles': numeroArboles,
        'anio_plantacion': anioPlantacion,
        'variedades': codificarIds(variedades),
        'registrada_dop': registradaDop ? 1 : 0,
        'latitud': latitud,
        'longitud': longitud,
        'contorno': contorno,
        'notas': notas,
      };

  factory Pomarada.fromMap(Map<String, Object?> mapa) => Pomarada(
        id: mapa['id'] as int?,
        nombre: mapa['nombre'] as String,
        cultivo: cultivosParcela.contains(mapa['cultivo'])
            ? mapa['cultivo'] as String
            : 'manzano',
        municipio: (mapa['municipio'] as String?) ?? '',
        poligono: (mapa['poligono'] as String?) ?? '',
        parcela: (mapa['parcela'] as String?) ?? '',
        recinto: (mapa['recinto'] as String?) ?? '',
        superficieHa: comoDecimal(mapa['superficie_ha']) ?? 0,
        numeroArboles: (mapa['numero_arboles'] as int?) ?? 0,
        anioPlantacion: mapa['anio_plantacion'] as int?,
        variedades: decodificarIds(mapa['variedades']),
        registradaDop: comoBooleano(mapa['registrada_dop']),
        latitud: comoDecimal(mapa['latitud']),
        longitud: comoDecimal(mapa['longitud']),
        contorno: (mapa['contorno'] as String?) ?? contornoVacio,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Un manzano concreto (opcional): para quien marca árboles viejos,
/// injertos o variedades raras dentro de la pomarada.
class Manzano {
  Manzano({
    this.id,
    required this.pomaradaId,
    required this.etiqueta,
    this.variedadId = '',
    this.anioPlantacion,
    this.notas = '',
  });

  final int? id;
  final int pomaradaId;

  /// Cómo lo reconoce la persona: «fila 3, n.º 12», «el viejo del borde»…
  final String etiqueta;
  final String variedadId;
  final int? anioPlantacion;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'pomarada_id': pomaradaId,
        'etiqueta': etiqueta,
        'variedad_id': variedadId,
        'anio_plantacion': anioPlantacion,
        'notas': notas,
      };

  factory Manzano.fromMap(Map<String, Object?> mapa) => Manzano(
        id: mapa['id'] as int?,
        pomaradaId: mapa['pomarada_id'] as int,
        etiqueta: mapa['etiqueta'] as String,
        variedadId: (mapa['variedad_id'] as String?) ?? '',
        anioPlantacion: mapa['anio_plantacion'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
