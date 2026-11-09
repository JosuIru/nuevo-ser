import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../modelos/pomarada.dart';
import 'pantalla_pomaradas.dart' show PantallaFichaPomarada, paqueteAppSidra;

/// Punto de la pomarada en el mapa: el guardado o, si solo tiene área, el
/// centro del área. Null si no tiene ninguno de los dos.
LatLng? puntoDePomarada(Pomarada pomarada) => pomarada.tieneUbicacion
    ? LatLng(pomarada.latitud!, pomarada.longitud!)
    : centroide(pomarada.vertices);

/// Centro del mapa: la media de las pomaradas con punto o área o, si no hay
/// ninguna, el centro de Euskal Herria (donde está casi toda la sidra DOP).
LatLng centroDePomaradas(Iterable<Pomarada> pomaradas) {
  final puntos = pomaradas.map(puntoDePomarada).whereType<LatLng>().toList();
  if (puntos.isEmpty) return const LatLng(43.1, -2.3);
  final latitud =
      puntos.fold<double>(0, (suma, punto) => suma + punto.latitude) /
          puntos.length;
  final longitud =
      puntos.fold<double>(0, (suma, punto) => suma + punto.longitude) /
          puntos.length;
  return LatLng(latitud, longitud);
}

/// Mapa de las pomaradas (y viñas de txakoli): su área, si está marcada, y
/// su punto. Tocar el punto abre la ficha. Necesita conexión para las
/// teselas.
class PantallaMapaPomaradas extends StatefulWidget {
  const PantallaMapaPomaradas({super.key, this.conTeselas = true});

  /// Los tests no bajan teselas.
  final bool conTeselas;

  @override
  State<PantallaMapaPomaradas> createState() => _PantallaMapaPomaradasState();
}

class _PantallaMapaPomaradasState extends State<PantallaMapaPomaradas> {
  CapaBase _capa = CapaBase.callejero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.mapa'))),
      body: FutureBuilder<List<Pomarada>>(
        future: BaseDatosSoleraSidra.instancia.listarPomaradas(),
        builder: (context, instantanea) {
          final pomaradas = instantanea.data;
          if (pomaradas == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final situadas = pomaradas
              .where((pomarada) => puntoDePomarada(pomarada) != null)
              .toList();
          final colorPomarada = Theme.of(context).colorScheme.primary;
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDePomaradas(situadas),
                  initialZoom: situadas.isEmpty ? 8 : 15,
                ),
                children: [
                  if (widget.conTeselas)
                    capaDeTeselas(_capa, paqueteApp: paqueteAppSidra),
                  capaDeAreas([
                    for (final pomarada in situadas)
                      (nombre: pomarada.nombre, vertices: pomarada.vertices),
                  ], color: colorPomarada),
                  MarkerLayer(markers: [
                    for (final pomarada in situadas)
                      Marker(
                        point: puntoDePomarada(pomarada)!,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PantallaFichaPomarada(
                                        pomarada: pomarada)));
                            if (mounted) setState(() {});
                          },
                          child: Tooltip(
                            message: pomarada.nombre,
                            child: Icon(
                                pomarada.cultivo == 'vid'
                                    ? Icons.wine_bar
                                    : Icons.location_on,
                                size: 40,
                                color: colorPomarada),
                          ),
                        ),
                      ),
                  ]),
                  AtribucionCapa(_capa),
                ],
              ),
              Positioned(
                top: 12,
                right: 12,
                child: FloatingActionButton.small(
                  heroTag: 'sidr.mapa.capa',
                  tooltip: SoleraL10n.t('mapa.cambiar_capa'),
                  onPressed: () => setState(() => _capa = _capa.otra),
                  child: Icon(_capa == CapaBase.ortofoto
                      ? Icons.map_outlined
                      : Icons.satellite_alt_outlined),
                ),
              ),
              if (pomaradas.isEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(SoleraL10n.t('sidr.sin_pomaradas')),
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
