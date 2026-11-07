import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import 'pantalla_ficha_parcela.dart';

/// Centro del mapa: la media de las parcelas con ubicación o, si no hay
/// ninguna, el centro de la península.
LatLng centroDeParcelas(Iterable<Parcela> parcelas) {
  final conUbicacion = parcelas.where((parcela) => parcela.tieneUbicacion);
  if (conUbicacion.isEmpty) return const LatLng(40.4, -3.7);
  final latitud =
      conUbicacion.fold<double>(0, (suma, parcela) => suma + parcela.latitud!) /
          conUbicacion.length;
  final longitud = conUbicacion.fold<double>(
          0, (suma, parcela) => suma + parcela.longitud!) /
      conUbicacion.length;
  return LatLng(latitud, longitud);
}

/// Mapa de las parcelas con ubicación (la que se guardó con el GPS al darlas
/// de alta). Necesita conexión para las teselas.
class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('frut.mapa'))),
      body: FutureBuilder<List<Parcela>>(
        future: BaseDatosSoleraFrutal.instancia.listarParcelas(),
        builder: (context, instantanea) {
          final parcelas = instantanea.data;
          if (parcelas == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final conUbicacion =
              parcelas.where((parcela) => parcela.tieneUbicacion).toList();
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDeParcelas(parcelas),
                  initialZoom: conUbicacion.isEmpty ? 5 : 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.coleccionnuevoser.solera_frutal',
                  ),
                  MarkerLayer(markers: [
                    for (final parcela in conUbicacion)
                      Marker(
                        point: LatLng(parcela.latitud!, parcela.longitud!),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PantallaFichaParcela(
                                      parcelaId: parcela.id!))),
                          child: Tooltip(
                            message: parcela.nombre,
                            child: Icon(Icons.location_on,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary),
                          ),
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
                      child: Text(SoleraL10n.t('frut.mapa_sin_ubicaciones')),
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
