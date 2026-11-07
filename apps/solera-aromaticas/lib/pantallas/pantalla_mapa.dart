import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import '../modelos/zona_recoleccion.dart';
import 'pantalla_editar_origen.dart';

/// Centro del mapa: la media de los puntos o, sin ninguno, el centro de la
/// península.
LatLng centroDePuntos(Iterable<LatLng> puntos) {
  if (puntos.isEmpty) return const LatLng(40.4, -3.7);
  final latitud =
      puntos.fold<double>(0, (suma, punto) => suma + punto.latitude) /
          puntos.length;
  final longitud =
      puntos.fold<double>(0, (suma, punto) => suma + punto.longitude) /
          puntos.length;
  return LatLng(latitud, longitud);
}

/// Mapa de parcelas (verde) y zonas de recolección (lavanda) con ubicación,
/// la que se guardó con el GPS. Necesita conexión para las teselas.
class PantallaMapa extends StatelessWidget {
  const PantallaMapa({super.key});

  Future<(List<Parcela>, List<ZonaRecoleccion>)> _cargar() async {
    final bd = BaseDatosSoleraAromaticas.instancia;
    return (
      (await bd.listarParcelas()).where((p) => p.tieneUbicacion).toList(),
      (await bd.listarZonasRecoleccion())
          .where((z) => z.tieneUbicacion)
          .toList(),
    );
  }

  Marker _marcador(LatLng punto, String nombre, Color color, IconData icono,
          VoidCallback alTocar) =>
      Marker(
        point: punto,
        width: 44,
        height: 44,
        child: GestureDetector(
          onTap: alTocar,
          child: Tooltip(
            message: nombre,
            child: Icon(icono, size: 40, color: color),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arom.mapa'))),
      body: FutureBuilder<(List<Parcela>, List<ZonaRecoleccion>)>(
        future: _cargar(),
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final (parcelas, zonas) = datos;
          final puntos = [
            for (final p in parcelas) LatLng(p.latitud!, p.longitud!),
            for (final z in zonas) LatLng(z.latitud!, z.longitud!),
          ];
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDePuntos(puntos),
                  initialZoom: puntos.isEmpty ? 5 : 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.coleccionnuevoser.solera_aromaticas',
                  ),
                  MarkerLayer(markers: [
                    for (final parcela in parcelas)
                      _marcador(
                          LatLng(parcela.latitud!, parcela.longitud!),
                          parcela.nombre,
                          Colors.green.shade800,
                          Icons.location_on,
                          () => abrirEdicionParcela(context, parcela: parcela)),
                    for (final zona in zonas)
                      _marcador(
                          LatLng(zona.latitud!, zona.longitud!),
                          zona.nombre,
                          Theme.of(context).colorScheme.primary,
                          Icons.forest,
                          () => abrirEdicionZona(context, zona: zona)),
                  ]),
                  const SimpleAttributionWidget(
                      source: Text('OpenStreetMap contributors')),
                ],
              ),
              if (puntos.isEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(SoleraL10n.t('arom.mapa_sin_ubicaciones')),
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
