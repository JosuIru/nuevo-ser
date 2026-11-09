import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../modelos/parcela.dart';
import 'pantalla_ficha_parcela.dart';
import 'pantalla_parcelas.dart' show paqueteAppFrutal;

/// Punto de la parcela en el mapa: el suyo o, si solo tiene área, el
/// centro del área. Null si no tiene ninguno de los dos.
LatLng? puntoDeParcela(Parcela parcela) => parcela.tieneUbicacion
    ? LatLng(parcela.latitud!, parcela.longitud!)
    : centroide(parcela.vertices);

/// Centro del mapa: la media de los puntos (el de cada parcela y las
/// esquinas de su área) o, si no hay ninguno, el centro de la península.
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

/// Mapa de las parcelas: su área, si está marcada, y su punto. Necesita
/// conexión para las teselas.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key, this.conTeselas = true});

  /// Los tests no bajan teselas.
  final bool conTeselas;

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  CapaBase _capa = CapaBase.callejero;

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
          final enElMapa = parcelas
              .where((parcela) => puntoDeParcela(parcela) != null)
              .toList();
          final colorParcela = Theme.of(context).colorScheme.primary;
          final puntos = [
            for (final parcela in enElMapa) ...[
              puntoDeParcela(parcela)!,
              ...parcela.vertices,
            ],
          ];
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDePuntos(puntos),
                  initialZoom: puntos.isEmpty ? 5 : 14,
                ),
                children: [
                  if (widget.conTeselas)
                    capaDeTeselas(_capa, paqueteApp: paqueteAppFrutal),
                  capaDeAreas([
                    for (final parcela in enElMapa)
                      (nombre: parcela.nombre, vertices: parcela.vertices),
                  ], color: colorParcela),
                  MarkerLayer(markers: [
                    for (final parcela in enElMapa)
                      Marker(
                        point: puntoDeParcela(parcela)!,
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PantallaFichaParcela(
                                        parcelaId: parcela.id!)));
                            if (mounted) setState(() {});
                          },
                          child: Tooltip(
                            message: parcela.nombre,
                            child: Icon(Icons.location_on,
                                size: 40, color: colorParcela),
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
                  heroTag: 'frut.mapa.capa',
                  tooltip: SoleraL10n.t('mapa.cambiar_capa'),
                  onPressed: () => setState(() => _capa = _capa.otra),
                  child: Icon(_capa == CapaBase.ortofoto
                      ? Icons.map_outlined
                      : Icons.satellite_alt_outlined),
                ),
              ),
              if (enElMapa.isEmpty)
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
