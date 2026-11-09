import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../modelos/zona_cultivo.dart';
import 'formularios.dart' show mostrarFormularioZona, paqueteAppVivero;

/// Punto de la zona en el mapa: el guardado o, si solo tiene área, el
/// centro del área. Null si no tiene ninguno de los dos.
LatLng? puntoDeZona(ZonaCultivo zona) => zona.tieneUbicacion
    ? LatLng(zona.latitud!, zona.longitud!)
    : centroide(zona.vertices);

/// Centro del mapa: la media de las zonas con punto o área o, si no hay
/// ninguna, el centro de la península.
LatLng centroDeZonas(Iterable<ZonaCultivo> zonas) {
  final puntos = zonas.map(puntoDeZona).whereType<LatLng>().toList();
  if (puntos.isEmpty) return const LatLng(40.4, -3.7);
  final latitud =
      puntos.fold<double>(0, (suma, punto) => suma + punto.latitude) /
          puntos.length;
  final longitud =
      puntos.fold<double>(0, (suma, punto) => suma + punto.longitude) /
          puntos.length;
  return LatLng(latitud, longitud);
}

/// Mapa de las zonas con punto o área (parcelas exteriores, sobre todo).
/// Necesita conexión para las teselas. Tocar una zona abre su ficha.
class PantallaMapaZonas extends StatefulWidget {
  const PantallaMapaZonas({super.key, this.conTeselas = true});

  /// Los tests no bajan teselas.
  final bool conTeselas;

  @override
  State<PantallaMapaZonas> createState() => _PantallaMapaZonasState();
}

class _PantallaMapaZonasState extends State<PantallaMapaZonas> {
  CapaBase _capa = CapaBase.callejero;

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
          final situadas =
              zonas.where((zona) => puntoDeZona(zona) != null).toList();
          final colorZona = Theme.of(context).colorScheme.primary;
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDeZonas(situadas),
                  initialZoom: situadas.isEmpty ? 5 : 15,
                ),
                children: [
                  if (widget.conTeselas)
                    capaDeTeselas(_capa, paqueteApp: paqueteAppVivero),
                  capaDeAreas([
                    for (final zona in situadas)
                      (nombre: zona.nombre, vertices: zona.vertices),
                  ], color: colorZona),
                  MarkerLayer(markers: [
                    for (final zona in situadas)
                      Marker(
                        point: puntoDeZona(zona)!,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () async {
                            final guardado = await mostrarFormularioZona(
                                context,
                                existente: zona);
                            if (guardado && mounted) setState(() {});
                          },
                          child: Tooltip(
                            message: zona.nombre,
                            child: Icon(Icons.location_on,
                                size: 40, color: colorZona),
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
                  heroTag: 'vive.mapa.capa',
                  tooltip: SoleraL10n.t('mapa.cambiar_capa'),
                  onPressed: () => setState(() => _capa = _capa.otra),
                  child: Icon(_capa == CapaBase.ortofoto
                      ? Icons.map_outlined
                      : Icons.satellite_alt_outlined),
                ),
              ),
              if (situadas.isEmpty)
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
