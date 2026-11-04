import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/track.dart';
import '../servicios/grabador_track.dart';

class PantallaTracks extends StatefulWidget {
  PantallaTracks({super.key});

  @override
  State<PantallaTracks> createState() => _PantallaTracksState();
}

class _PantallaTracksState extends State<PantallaTracks> {
  List<Track> _tracks = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final lista = await BaseDatosAgro.instancia.listarTracks();
      if (!mounted) return;
      setState(() {
        _tracks = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar los recorridos: $e')));
    }
  }

  Future<void> _verTrack(Track track) async {
    final List<TrackPunto> puntos;
    try {
      puntos = await BaseDatosAgro.instancia.obtenerPuntosTrack(track.id!);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir el recorrido: $e')));
      return;
    }
    if (!mounted) return;
    if (puntos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Este recorrido no tiene puntos guardados.')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, scrollController) {
          final puntosLatLng = puntos.map((p) => LatLng(p.latitud, p.longitud)).toList();
          // Defensa contra el degenerado de un solo punto: bounds.fromPoints
          // crea rectángulo cero y CameraFit zooms a infinito.
          final MapOptions opcionesMapa = puntosLatLng.length >= 2
              ? MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: LatLngBounds.fromPoints(puntosLatLng),
                    padding: const EdgeInsets.all(40),
                  ),
                )
              : MapOptions(initialCenter: puntosLatLng.first, initialZoom: 16);
          return ListView(
            controller: scrollController,
            children: [
              SizedBox(
                height: 320,
                child: FlutterMap(
                  options: opcionesMapa,
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.josu.agro',
                      maxZoom: 19,
                    ),
                    // Las condiciones de uso de OSM y Esri piden citarlos.
                    SimpleAttributionWidget(source: const Text('OpenStreetMap')),
                    if (puntosLatLng.length >= 2)
                      PolylineLayer(polylines: [
                        Polyline(points: puntosLatLng, color: Color(0xFF558B2F), strokeWidth: 4),
                      ]),
                    MarkerLayer(markers: [
                      Marker(point: puntosLatLng.first, child: Icon(Icons.flag, color: Colors.green)),
                      if (puntosLatLng.length >= 2)
                        Marker(point: puntosLatLng.last, child: Icon(Icons.flag, color: Colors.red)),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.nombre.isEmpty ? 'Recorrido' : track.nombre,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(_resumen(track, puntos.length)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.download),
                            onPressed: () async {
                              final fichero = await _exportarGpx(track, puntos);
                              if (!context.mounted) return;
                              await Share.shareXFiles([XFile(fichero.path)], subject: 'Recorrido GPX');
                            },
                            label: Text('GPX'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final navegadorSheet = Navigator.of(sheetCtx);
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Text('¿Borrar este recorrido?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Borrar', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (ok != true) return;
                              await BaseDatosAgro.instancia.borrarTrack(track.id!);
                              if (!mounted) return;
                              navegadorSheet.pop();
                              _cargar();
                            },
                            label: Text('Borrar', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<File> _exportarGpx(Track track, List<TrackPunto> puntos) async {
    final gpx = generarGpx(track, puntos);
    final dir = await getTemporaryDirectory();
    final nombre = 'solera-recorrido-${track.id ?? track.fechaMs}.gpx';
    final fichero = File(path_lib.join(dir.path, nombre));
    await fichero.writeAsString(gpx);
    return fichero;
  }

  String _resumen(Track track, int nPuntos) {
    final partes = <String>[];
    if (track.distanciaMetros != null) {
      final km = track.distanciaMetros! / 1000;
      partes.add(km < 1 ? '${track.distanciaMetros!.toStringAsFixed(0)} m' : '${km.toStringAsFixed(2)} km');
    }
    if (track.duracionMs != null) {
      final mins = (track.duracionMs! / 60000).round();
      partes.add(mins < 60 ? '$mins min' : '${(mins / 60).toStringAsFixed(1)} h');
    }
    partes.add('$nPuntos puntos');
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recorridos de inspección')),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : _tracks.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Aún no has grabado ningún recorrido.\nUsa el botón ⏺ del mapa para empezar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _tracks.length,
                  itemBuilder: (_, i) {
                    final t = _tracks[i];
                    final fecha = DateFormat('dd MMM yyyy HH:mm', 'es_ES').format(DateTime.fromMillisecondsSinceEpoch(t.fechaMs));
                    final km = t.distanciaMetros != null ? (t.distanciaMetros! / 1000).toStringAsFixed(2) : '–';
                    return ListTile(
                      leading: Icon(Icons.timeline, color: Color(0xFF558B2F)),
                      title: Text(t.nombre.isEmpty ? 'Recorrido del $fecha' : t.nombre),
                      subtitle: Text('$km km · $fecha'),
                      onTap: () => _verTrack(t),
                    );
                  },
                ),
    );
  }
}
