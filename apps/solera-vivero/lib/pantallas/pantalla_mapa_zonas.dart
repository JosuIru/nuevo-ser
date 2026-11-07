import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/zona_cultivo.dart';

/// Centro del mapa: la media de las zonas con ubicación o, si no hay
/// ninguna, el centro de la península.
LatLng centroDeZonas(Iterable<ZonaCultivo> zonas) {
  final conUbicacion = zonas.where((zona) => zona.tieneUbicacion);
  if (conUbicacion.isEmpty) return const LatLng(40.4, -3.7);
  final latitud =
      conUbicacion.fold<double>(0, (suma, zona) => suma + zona.latitud!) /
          conUbicacion.length;
  final longitud =
      conUbicacion.fold<double>(0, (suma, zona) => suma + zona.longitud!) /
          conUbicacion.length;
  return LatLng(latitud, longitud);
}

/// Mapa de las zonas con ubicación (parcelas exteriores, sobre todo).
/// Necesita conexión para las teselas. Copiado de Frutal.
class PantallaMapaZonas extends StatelessWidget {
  const PantallaMapaZonas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('vive.mapa'))),
      body: FutureBuilder<List<ZonaCultivo>>(
        future: BaseDatosSoleraVivero.instancia.listarZonas(),
        builder: (context, instantanea) {
          final zonas = instantanea.data;
          if (zonas == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final conUbicacion =
              zonas.where((zona) => zona.tieneUbicacion).toList();
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDeZonas(zonas),
                  initialZoom: conUbicacion.isEmpty ? 5 : 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.coleccionnuevoser.solera_vivero',
                  ),
                  MarkerLayer(markers: [
                    for (final zona in conUbicacion)
                      Marker(
                        point: LatLng(zona.latitud!, zona.longitud!),
                        width: 44,
                        height: 44,
                        child: Tooltip(
                          message: zona.nombre,
                          child: Icon(Icons.location_on,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                  ]),
                  const SimpleAttributionWidget(
                      source: Text('OpenStreetMap contributors')),
                ],
              ),
              if (conUbicacion.isEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(SoleraL10n.t('vive.mapa_sin_ubicaciones')),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
