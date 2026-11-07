import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/pieza_pasto.dart';
import '../utiles/geodesia.dart';
import '../utiles/permisos_gps.dart';
import '../utiles/textos_ganadera.dart';

/// Pide la posición actual con el GPS; null si no hay permiso o no llega.
Future<LatLng?> posicionActual() async {
  if (!await asegurarPermisoUbicacion()) return null;
  try {
    final posicion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 30),
    );
    return LatLng(posicion.latitude, posicion.longitude);
  } catch (error) {
    debugPrint('Sin posición GPS: $error');
    return null;
  }
}

/// El contorno de una pieza en el formato del modelo.
List<LatLng> verticesDe(PiezaPasto pieza) => [
      for (final (latitud, longitud) in pieza.contorno)
        LatLng(latitud, longitud)
    ];

/// Mapa de las piezas de pasto con su contorno. Sin cobertura no se ven las
/// teselas, pero los contornos sí.
class PantallaMapaPastos extends StatefulWidget {
  const PantallaMapaPastos({super.key});

  @override
  State<PantallaMapaPastos> createState() => _PantallaMapaPastosState();
}

class _PantallaMapaPastosState extends State<PantallaMapaPastos> {
  late Future<List<PiezaPasto>> _piezas = _cargar();

  static Future<List<PiezaPasto>> _cargar() =>
      BaseDatosSoleraGanadera.instancia.listarPiezas(soloActivas: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('gana.mapa_pastos'))),
      body: FutureBuilder<List<PiezaPasto>>(
        future: _piezas,
        builder: (context, instantanea) {
          final piezas = instantanea.data ?? const <PiezaPasto>[];
          final conContorno =
              piezas.where((pieza) => pieza.contorno.length >= 3).toList();
          final todos = [for (final pieza in conContorno) ...verticesDe(pieza)];
          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        todos.isEmpty ? const LatLng(42.8, -1.65) : todos.first,
                    initialZoom: todos.isEmpty ? 8 : 14,
                    initialCameraFit: todos.length < 2
                        ? null
                        : CameraFit.coordinates(
                            coordinates: todos,
                            padding: const EdgeInsets.all(32)),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.coleccionnuevoser.solera_ganadera',
                    ),
                    PolygonLayer(polygons: [
                      for (final pieza in conContorno)
                        Polygon(
                          points: verticesDe(pieza),
                          color: colorPrimarioGanadera.withValues(alpha: 0.25),
                          borderColor: colorAcentoGanadera,
                          borderStrokeWidth: 2,
                          label: pieza.nombre,
                        ),
                    ]),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    for (final pieza in piezas)
                      ListTile(
                        dense: true,
                        leading: Icon(pieza.contorno.length >= 3
                            ? Icons.pentagon_outlined
                            : Icons.add_location_alt_outlined),
                        title: Text(pieza.nombre),
                        subtitle: Text(pieza.contorno.length >= 3
                            ? '${formatearNumero(superficieHectareas(verticesDe(pieza)), decimales: 2)} ha (${SoleraL10n.t('gana.calculada')})'
                            : SoleraL10n.t('gana.sin_contorno')),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      PantallaContornoPieza(pieza: pieza)));
                          setState(() {
                            _piezas = _cargar();
                          });
                        },
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
}

/// Trazar el contorno de una pieza caminando su linde: en cada esquina,
/// «Añadir punto aquí» guarda la posición del GPS.
class PantallaContornoPieza extends StatefulWidget {
  const PantallaContornoPieza({super.key, required this.pieza});

  final PiezaPasto pieza;

  @override
  State<PantallaContornoPieza> createState() => _PantallaContornoPiezaState();
}

class _PantallaContornoPiezaState extends State<PantallaContornoPieza> {
  late List<(double, double)> _vertices = [...widget.pieza.contorno];
  bool _buscando = false;

  Future<void> _anadirPunto() async {
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _buscando = true);
    final posicion = await posicionActual();
    if (!mounted) return;
    setState(() => _buscando = false);
    if (posicion == null) {
      mensajero
          .showSnackBar(SnackBar(content: Text(SoleraL10n.t('gana.sin_gps'))));
      return;
    }
    setState(() =>
        _vertices = [..._vertices, (posicion.latitude, posicion.longitude)]);
  }

  Future<void> _guardar() async {
    final vertices = [for (final (lat, lon) in _vertices) LatLng(lat, lon)];
    final calculada = superficieHectareas(vertices);
    final pieza = widget.pieza.conContorno(_vertices);
    await BaseDatosSoleraGanadera.instancia.guardarPieza(
        pieza.superficieHa == null && calculada > 0
            ? PiezaPasto.fromMap(pieza.toMap()..['superficie_ha'] = calculada)
            : pieza);
    avisarCambioDatos();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vertices = [for (final (lat, lon) in _vertices) LatLng(lat, lon)];
    return Scaffold(
      appBar: AppBar(title: Text(widget.pieza.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(SoleraL10n.t('gana.explicacion_contorno'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _buscando ? null : _anadirPunto,
            icon: const Icon(Icons.my_location),
            label: Text(SoleraL10n.t(
                _buscando ? 'gana.buscando_gps' : 'gana.anadir_punto_aqui')),
          ),
          const SizedBox(height: 12),
          Text(
              '${_vertices.length} ${SoleraL10n.t('gana.puntos')} · '
              '${formatearNumero(superficieHectareas(vertices), decimales: 2)} ha · '
              '${formatearNumero(perimetroMetros(vertices), decimales: 0)} m',
              style: Theme.of(context).textTheme.titleMedium),
          Text(SoleraL10n.t('gana.superficie_orientativa'),
              style: Theme.of(context).textTheme.bodySmall),
          for (final (indice, (latitud, longitud)) in _vertices.indexed)
            ListTile(
              dense: true,
              leading: Text('${indice + 1}'),
              title: Text(
                  '${latitud.toStringAsFixed(6)}, ${longitud.toStringAsFixed(6)}'),
            ),
          Row(
            children: [
              TextButton(
                onPressed: _vertices.isEmpty
                    ? null
                    : () => setState(() =>
                        _vertices = _vertices.sublist(0, _vertices.length - 1)),
                child: Text(SoleraL10n.t('gana.quitar_ultimo')),
              ),
              TextButton(
                onPressed: _vertices.isEmpty
                    ? null
                    : () => setState(() => _vertices = []),
                child: Text(SoleraL10n.t('borrar')),
              ),
              const Spacer(),
              FilledButton(
                  onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
            ],
          ),
        ],
      ),
    );
  }
}
