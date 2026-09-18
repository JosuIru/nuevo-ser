import 'dart:convert';

import 'package:latlong2/latlong.dart';

import '../utiles/geodesia.dart';
import 'constantes.dart';

/// Una zona dibujada sobre el mapa de una finca: una parcela de pasto, un
/// cercado provisional, una zona de pastoreo de la temporada, un vedado…
///
/// A diferencia de [PuntoInfraestructura], que es una ubicación (dos
/// números), una zona es un **recinto**: una lista ordenada de vértices que
/// cierra un polígono. Se persiste como JSON (`[[lat,long],…]`) en lugar de
/// una tabla de vértices aparte: un polígono no se consulta nunca por
/// vértice, siempre entero, así que una tabla hija solo añadiría *joins*.
///
/// La superficie se guarda calculada ([superficieHaCalculada]) para no
/// recalcularla en cada pintado de la lista, y por separado de
/// [superficieHaOficial], que es la de SIGPAC cuando Zunbeltz la aporte. La
/// oficial manda: la calculada es orientativa.
class ZonaFinca {
  ZonaFinca({
    this.id,
    required this.fincaId,
    this.tipo = tipoZonaPorDefecto,
    this.nombre = '',
    this.verticesJson = '[]',
    this.superficieHaCalculada = 0,
    this.superficieHaOficial,
    this.estado = estadoZonaPorDefecto,
    this.recintoSigpac = '',
    this.notas = '',
    this.rutasFotosJson = '[]',
    this.fechaCreacionMs = 0,
  });

  final int? id;
  final int fincaId;

  /// Código de `tiposZona` (parcela, cercado, pastoreo, siega, vedado…).
  final String tipo;

  final String nombre;

  /// Vértices como JSON `[[latitud, longitud], …]`, en orden de trazado y
  /// sin repetir el primero al final (el anillo se cierra al pintar).
  final String verticesJson;

  /// Superficie en hectáreas calculada a partir del trazado. Orientativa.
  final double superficieHaCalculada;

  /// Superficie oficial (SIGPAC) en hectáreas, si se conoce. Manda sobre la
  /// calculada en todo lo que se muestre o se imprima.
  final double? superficieHaOficial;

  /// Código de `estadosZona` (en uso / en descanso / vedada).
  final String estado;

  /// Referencia SIGPAC del recinto, si corresponde a uno.
  final String recintoSigpac;

  final String notas;
  final String rutasFotosJson;
  final int fechaCreacionMs;

  /// Vértices decodificados. Devuelve lista vacía si el JSON está corrupto o
  /// tiene una forma inesperada: una zona ilegible no debe tirar el mapa.
  List<LatLng> get vertices => decodificarVertices(verticesJson);

  /// Superficie a mostrar: la oficial si la hay, si no la calculada.
  double get superficieHa => superficieHaOficial ?? superficieHaCalculada;

  /// ¿Tiene superficie oficial de SIGPAC (y por tanto no es orientativa)?
  bool get tieneSuperficieOficial => superficieHaOficial != null;

  /// El polígono está cerrado y es medible (tres vértices o más).
  bool get esPoligonoValido => vertices.length >= 3;

  /// Centroide de los vértices, para centrar el mapa o poner la etiqueta.
  LatLng? get centro => centroide(vertices);

  /// ¿Cae este punto dentro de la zona? Para abrir su ficha al tocar el mapa.
  bool contiene(LatLng punto) => puntoDentroDePoligono(punto, vertices);

  /// Codifica vértices a JSON `[[lat,long],…]`.
  static String codificarVertices(List<LatLng> vertices) => jsonEncode(
      vertices.map((v) => [v.latitude, v.longitude]).toList(growable: false));

  /// Decodifica el JSON de vértices. Tolera basura: devuelve lo que puede
  /// leer y descarta los pares mal formados.
  static List<LatLng> decodificarVertices(String json) {
    try {
      final crudo = jsonDecode(json);
      if (crudo is! List) return const [];

      final leidos = <LatLng>[];
      for (final par in crudo) {
        if (par is! List || par.length < 2) continue;
        final latitud = par[0];
        final longitud = par[1];
        if (latitud is! num || longitud is! num) continue;
        leidos.add(LatLng(latitud.toDouble(), longitud.toDouble()));
      }
      return leidos;
    } catch (_) {
      return const [];
    }
  }

  /// Construye una zona a partir de un trazado, calculando su superficie.
  factory ZonaFinca.desdeTrazado({
    int? id,
    required int fincaId,
    required List<LatLng> vertices,
    String tipo = tipoZonaPorDefecto,
    String nombre = '',
    double? superficieHaOficial,
    String estado = estadoZonaPorDefecto,
    String recintoSigpac = '',
    String notas = '',
    String rutasFotosJson = '[]',
    int fechaCreacionMs = 0,
  }) =>
      ZonaFinca(
        id: id,
        fincaId: fincaId,
        tipo: tipo,
        nombre: nombre,
        verticesJson: codificarVertices(vertices),
        superficieHaCalculada: superficieHectareas(vertices),
        superficieHaOficial: superficieHaOficial,
        estado: estado,
        recintoSigpac: recintoSigpac,
        notas: notas,
        rutasFotosJson: rutasFotosJson,
        fechaCreacionMs: fechaCreacionMs,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'finca_id': fincaId,
        'tipo': tipo,
        'nombre': nombre,
        'vertices_json': verticesJson,
        'superficie_ha_calculada': superficieHaCalculada,
        'superficie_ha_oficial': superficieHaOficial,
        'estado': estado,
        'recinto_sigpac': recintoSigpac,
        'notas': notas,
        'rutas_fotos_json': rutasFotosJson,
        'fecha_creacion_ms': fechaCreacionMs,
      };

  factory ZonaFinca.fromMap(Map<String, Object?> mapa) => ZonaFinca(
        id: mapa['id'] as int?,
        fincaId: (mapa['finca_id'] as int?) ?? 0,
        tipo: (mapa['tipo'] as String?) ?? tipoZonaPorDefecto,
        nombre: (mapa['nombre'] as String?) ?? '',
        verticesJson: (mapa['vertices_json'] as String?) ?? '[]',
        superficieHaCalculada:
            (mapa['superficie_ha_calculada'] as num?)?.toDouble() ?? 0,
        superficieHaOficial:
            (mapa['superficie_ha_oficial'] as num?)?.toDouble(),
        estado: (mapa['estado'] as String?) ?? estadoZonaPorDefecto,
        recintoSigpac: (mapa['recinto_sigpac'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
        rutasFotosJson: (mapa['rutas_fotos_json'] as String?) ?? '[]',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
      );

  ZonaFinca copiarCon({
    int? id,
    int? fincaId,
    String? tipo,
    String? nombre,
    String? verticesJson,
    double? superficieHaCalculada,
    double? superficieHaOficial,
    String? estado,
    String? recintoSigpac,
    String? notas,
    String? rutasFotosJson,
    int? fechaCreacionMs,
  }) =>
      ZonaFinca(
        id: id ?? this.id,
        fincaId: fincaId ?? this.fincaId,
        tipo: tipo ?? this.tipo,
        nombre: nombre ?? this.nombre,
        verticesJson: verticesJson ?? this.verticesJson,
        superficieHaCalculada:
            superficieHaCalculada ?? this.superficieHaCalculada,
        superficieHaOficial: superficieHaOficial ?? this.superficieHaOficial,
        estado: estado ?? this.estado,
        recintoSigpac: recintoSigpac ?? this.recintoSigpac,
        notas: notas ?? this.notas,
        rutasFotosJson: rutasFotosJson ?? this.rutasFotosJson,
        fechaCreacionMs: fechaCreacionMs ?? this.fechaCreacionMs,
      );

  /// Sustituye el trazado y recalcula la superficie orientativa.
  ZonaFinca conTrazado(List<LatLng> nuevosVertices) => copiarCon(
        verticesJson: codificarVertices(nuevosVertices),
        superficieHaCalculada: superficieHectareas(nuevosVertices),
      );
}
