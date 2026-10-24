import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utiles/teselas_mapa.dart';
import 'cache_teselas.dart';

/// `TileProvider` de flutter_map que pide cada tesela a un
/// [ObtenedorTeselas] (disco primero, red después; ver `cache_teselas.dart`).
///
/// [capa] da nombre a la carpeta de la caché («pnoa», «osm»…) y
/// [capaRespaldo] a la del `fallbackUrl` del `TileLayer`, si lo tiene.
/// No cierra nada al desecharse: el obtenedor es de toda la app.
class ProveedorTeselasCacheadas extends TileProvider {
  ProveedorTeselasCacheadas({
    required this.obtenedor,
    required this.capa,
    this.capaRespaldo,
  });

  final ObtenedorTeselas obtenedor;
  final String capa;
  final String? capaRespaldo;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final urlRespaldo =
        capaRespaldo == null ? null : getTileFallbackUrl(coordinates, options);
    return ImagenTeselaCacheada(
      obtenedor: obtenedor,
      peticion: PeticionTesela(
        capa: capa,
        tesela: TeselaXYZ(coordinates.z, coordinates.x, coordinates.y),
        url: getTileUrl(coordinates, options),
        cabeceras: Map.unmodifiable(headers),
        capaRespaldo: urlRespaldo == null ? null : capaRespaldo,
        urlRespaldo: urlRespaldo,
      ),
    );
  }
}

/// La imagen de una tesela servida por un [ObtenedorTeselas].
@immutable
class ImagenTeselaCacheada extends ImageProvider<ImagenTeselaCacheada> {
  const ImagenTeselaCacheada({required this.obtenedor, required this.peticion});

  final ObtenedorTeselas obtenedor;
  final PeticionTesela peticion;

  @override
  Future<ImagenTeselaCacheada> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
          ImagenTeselaCacheada key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(
        codec: _cargar(key, decode),
        scale: 1,
        debugLabel: peticion.url,
      );

  Future<ui.Codec> _cargar(
      ImagenTeselaCacheada key, ImageDecoderCallback decode) async {
    try {
      final bytes = await obtenedor.obtener(peticion);
      return await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (_) {
      // Que no se quede en la caché de imágenes como fallida: al volver a
      // pasar por aquí (o al volver la red) se pide otra vez.
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ImagenTeselaCacheada &&
      other.peticion.capa == peticion.capa &&
      other.peticion.url == peticion.url;

  @override
  int get hashCode => Object.hash(peticion.capa, peticion.url);
}
