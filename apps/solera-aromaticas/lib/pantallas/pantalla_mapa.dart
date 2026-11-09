import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

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

/// Mapa de parcelas (verde) y zonas de recolección (lavanda): su área, si
/// está marcada, y su punto. Necesita conexión para las teselas.
class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key, this.conTeselas = true});

  /// Los tests no bajan teselas.
  final bool conTeselas;

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  CapaBase _capa = CapaBase.callejero;

  Future<(List<Parcela>, List<ZonaRecoleccion>)> _cargar() async {
    final bd = BaseDatosSoleraAromaticas.instancia;
    return (
      (await bd.listarParcelas())
          .where((p) => p.tieneUbicacion || tieneArea(p.vertices))
          .toList(),
      (await bd.listarZonasRecoleccion())
          .where((z) => z.tieneUbicacion || tieneArea(z.vertices))
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
          final colorParcela = Colors.green.shade800;
          final colorZona = Theme.of(context).colorScheme.primary;
          LatLng puntoDe(
                  double? latitud, double? longitud, List<LatLng> area) =>
              latitud != null && longitud != null
                  ? LatLng(latitud, longitud)
                  : centroide(area)!;
          final puntos = [
            for (final p in parcelas) ...[
              puntoDe(p.latitud, p.longitud, p.vertices),
              ...p.vertices
            ],
            for (final z in zonas) ...[
              puntoDe(z.latitud, z.longitud, z.vertices),
              ...z.vertices
            ],
          ];
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: centroDePuntos(puntos),
                  initialZoom: puntos.isEmpty ? 5 : 13,
                ),
                children: [
                  if (widget.conTeselas)
                    capaDeTeselas(_capa, paqueteApp: paqueteAppAromaticas),
                  capaDeAreas([
                    for (final parcela in parcelas)
                      (nombre: parcela.nombre, vertices: parcela.vertices),
                  ], color: colorParcela),
                  capaDeAreas([
                    for (final zona in zonas)
                      (nombre: zona.nombre, vertices: zona.vertices),
                  ], color: colorZona),
                  MarkerLayer(markers: [
                    for (final parcela in parcelas)
                      _marcador(
                          puntoDe(parcela.latitud, parcela.longitud,
                              parcela.vertices),
                          parcela.nombre,
                          colorParcela,
                          Icons.location_on, () async {
                        await abrirEdicionParcela(context, parcela: parcela);
                        if (mounted) setState(() {});
                      }),
                    for (final zona in zonas)
                      _marcador(
                          puntoDe(zona.latitud, zona.longitud, zona.vertices),
                          zona.nombre,
                          colorZona,
                          Icons.forest, () async {
                        await abrirEdicionZona(context, zona: zona);
                        if (mounted) setState(() {});
                      }),
                  ]),
                  AtribucionCapa(_capa),
                ],
              ),
              Positioned(
                top: 12,
                right: 12,
                child: FloatingActionButton.small(
                  heroTag: 'arom.mapa.capa',
                  tooltip: SoleraL10n.t('mapa.cambiar_capa'),
                  onPressed: () => setState(() => _capa = _capa.otra),
                  child: Icon(_capa == CapaBase.ortofoto
                      ? Icons.map_outlined
                      : Icons.satellite_alt_outlined),
                ),
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
