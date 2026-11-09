// Capas base del mapa, las de Larrea Zunbeltz (`mapa_sin_cobertura.dart`):
// callejero de OpenStreetMap y ortofoto PNOA del IGN (WMTS, hasta z19) con
// Esri World Imagery de respaldo. La ortofoto es la que sirve para seguir
// lindes; el callejero, para orientarse.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

const String urlCallejeroOsm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String urlOrtofotoPnoa = 'https://www.ign.es/wmts/pnoa-ma?'
    'request=GetTile&service=WMTS&VERSION=1.0.0&Layer=OI.OrthoimageCoverage'
    '&Style=default&Format=image/jpeg&TileMatrixSet=GoogleMapsCompatible'
    '&TileMatrix={z}&TileRow={y}&TileCol={x}';
const String urlOrtofotoEsri = 'https://server.arcgisonline.com/ArcGIS/rest/'
    'services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

enum CapaBase { callejero, ortofoto }

extension TextoCapaBase on CapaBase {
  String get nombre => switch (this) {
        CapaBase.callejero => SoleraL10n.t('mapa.capa_callejero'),
        CapaBase.ortofoto => SoleraL10n.t('mapa.capa_ortofoto'),
      };

  CapaBase get otra =>
      this == CapaBase.callejero ? CapaBase.ortofoto : CapaBase.callejero;

  String get atribucion => switch (this) {
        CapaBase.callejero => '© OpenStreetMap',
        CapaBase.ortofoto => 'PNOA © IGN · Esri',
      };
}

/// La capa de teselas. [paqueteApp] identifica a la app ante OpenStreetMap
/// (lo pide su política de uso).
TileLayer capaDeTeselas(CapaBase capa, {required String paqueteApp}) =>
    switch (capa) {
      CapaBase.callejero => TileLayer(
          urlTemplate: urlCallejeroOsm,
          userAgentPackageName: paqueteApp,
          maxNativeZoom: 19,
          maxZoom: 22,
        ),
      CapaBase.ortofoto => TileLayer(
          urlTemplate: urlOrtofotoPnoa,
          fallbackUrl: urlOrtofotoEsri,
          userAgentPackageName: paqueteApp,
          maxNativeZoom: 19,
          maxZoom: 22,
        ),
    };

/// Atribución pequeña abajo a la izquierda.
class AtribucionCapa extends StatelessWidget {
  const AtribucionCapa(this.capa, {super.key});

  final CapaBase capa;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          color: Colors.white70,
          child: Text(capa.atribucion,
              style: const TextStyle(fontSize: 10, color: Colors.black87)),
        ),
      );
}

/// Las áreas de una app sobre su mapa (parcelas, zonas, rodales…): relleno
/// suave, borde de [color] y el nombre en medio. Las de menos de tres
/// esquinas no se pintan.
PolygonLayer capaDeAreas(
  List<({String nombre, List<LatLng> vertices})> areas, {
  required Color color,
}) =>
    PolygonLayer(polygons: [
      for (final area in areas)
        if (area.vertices.length >= 3)
          Polygon(
            points: area.vertices,
            color: color.withValues(alpha: 0.22),
            borderColor: color,
            borderStrokeWidth: 2.5,
            label: area.nombre,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                shadows: [Shadow(color: Colors.white, blurRadius: 4)]),
          ),
    ]);
