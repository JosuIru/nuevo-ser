import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/incendios.dart';
import '../modelos/arbol_singular.dart';
import '../modelos/contorno.dart';
import '../modelos/incendios.dart';
import '../modelos/rodal.dart';
import '../utiles/geodesia.dart';
import '../utiles/permisos_gps.dart';
import '../utiles/textos_monte.dart';

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

class _DatosMapa {
  _DatosMapa(this.rodales, this.infraestructuras, this.arboles);

  final List<Rodal> rodales;
  final List<InfraestructuraIncendios> infraestructuras;
  final List<ArbolSingular> arboles;
}

/// Mapa del monte: rodales con su contorno, pistas y cortafuegos, puntos de
/// agua y árboles. Sin cobertura no se ven las teselas, pero lo dibujado sí.
class PantallaMapaMonte extends StatefulWidget {
  const PantallaMapaMonte({super.key});

  @override
  State<PantallaMapaMonte> createState() => _PantallaMapaMonteState();
}

class _PantallaMapaMonteState extends State<PantallaMapaMonte> {
  final Future<_DatosMapa> _datos = () async {
    final bd = BaseDatosSoleraMonte.instancia;
    return _DatosMapa(
        await bd.listarRodales(),
        await bd.listarInfraestructuras(soloActivas: true),
        await bd.listarArboles());
  }();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('mont.mapa'))),
      body: FutureBuilder<_DatosMapa>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final conContorno =
              datos.rodales.where((rodal) => rodal.tieneContorno).toList();
          final lineas = datos.infraestructuras
              .where((i) => i.esLineal && i.traza.length >= 2)
              .toList();
          final puntos =
              datos.infraestructuras.where((i) => i.tieneUbicacion).toList();
          final arboles = datos.arboles.where((a) => a.tieneUbicacion).toList();
          final todos = [
            for (final rodal in conContorno) ...aLatLng(rodal.contorno),
            for (final linea in lineas) ...aLatLng(linea.traza),
            for (final punto in puntos) LatLng(punto.latitud!, punto.longitud!),
            for (final arbol in arboles)
              LatLng(arbol.latitud!, arbol.longitud!),
          ];
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
                          'com.coleccionnuevoser.solera_monte',
                    ),
                    PolygonLayer(polygons: [
                      for (final rodal in conContorno)
                        Polygon(
                          points: aLatLng(rodal.contorno),
                          color: colorPrimarioMonte.withValues(alpha: 0.25),
                          borderColor: colorPrimarioMonte,
                          borderStrokeWidth: 2,
                          label: rodal.codigo,
                        ),
                    ]),
                    PolylineLayer(polylines: [
                      for (final linea in lineas)
                        Polyline(
                          points: aLatLng(linea.traza),
                          strokeWidth: 3,
                          color: linea.tipo == 'pista'
                              ? Colors.brown
                              : Colors.deepOrange,
                        ),
                    ]),
                    MarkerLayer(markers: [
                      for (final punto in puntos)
                        Marker(
                          point: LatLng(punto.latitud!, punto.longitud!),
                          child: Icon(
                              punto.tipo == 'punto_agua'
                                  ? Icons.water_drop
                                  : Icons.local_fire_department_outlined,
                              color: Colors.blue.shade700),
                        ),
                      for (final arbol in arboles)
                        Marker(
                          point: LatLng(arbol.latitud!, arbol.longitud!),
                          child: const Icon(Icons.park, color: Colors.green),
                        ),
                    ]),
                  ],
                ),
              ),
              SizedBox(
                height: 160,
                child: ListView(
                  children: [
                    for (final rodal in datos.rodales)
                      ListTile(
                        dense: true,
                        leading: Icon(rodal.tieneContorno
                            ? Icons.pentagon_outlined
                            : Icons.add_location_alt_outlined),
                        title: Text(rodal.etiqueta),
                        subtitle: Text(rodal.tieneContorno
                            ? '${formatearNumero(rodal.superficieCalculadaHa, decimales: 2)} ha (${SoleraL10n.t('mont.calculada')}) · ${nombreEspecie(rodal.especiePrincipalId)}'
                            : SoleraL10n.t('mont.sin_contorno')),
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

/// Trazar caminando: en cada esquina (o recodo de la pista), «Añadir punto
/// aquí» guarda la posición del GPS. [cerrado] = polígono (rodal); si no,
/// línea (pista, cortafuegos). Devuelve los vértices al guardar.
class PantallaTrazado extends StatefulWidget {
  const PantallaTrazado({
    super.key,
    required this.titulo,
    required this.verticesIniciales,
    required this.cerrado,
  });

  final String titulo;
  final List<(double, double)> verticesIniciales;
  final bool cerrado;

  @override
  State<PantallaTrazado> createState() => _PantallaTrazadoState();
}

class _PantallaTrazadoState extends State<PantallaTrazado> {
  late List<(double, double)> _vertices = [...widget.verticesIniciales];
  bool _buscando = false;

  Future<void> _anadirPunto() async {
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _buscando = true);
    final posicion = await posicionActual();
    if (!mounted) return;
    setState(() => _buscando = false);
    if (posicion == null) {
      mensajero
          .showSnackBar(SnackBar(content: Text(SoleraL10n.t('mont.sin_gps'))));
      return;
    }
    setState(() =>
        _vertices = [..._vertices, (posicion.latitude, posicion.longitude)]);
  }

  @override
  Widget build(BuildContext context) {
    final medida = widget.cerrado
        ? '${formatearNumero(superficieHectareas(aLatLng(_vertices)), decimales: 2)} ha · '
            '${formatearNumero(perimetroMetros(aLatLng(_vertices)), decimales: 0)} m'
        : '${formatearNumero(longitudTrazaMetros(_vertices), decimales: 0)} m';
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
              SoleraL10n.t(widget.cerrado
                  ? 'mont.explicacion_contorno'
                  : 'mont.explicacion_traza'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _buscando ? null : _anadirPunto,
            icon: const Icon(Icons.my_location),
            label: Text(SoleraL10n.t(
                _buscando ? 'mont.buscando_gps' : 'mont.anadir_punto_aqui')),
          ),
          const SizedBox(height: 12),
          Text('${_vertices.length} ${SoleraL10n.t('mont.puntos')} · $medida',
              style: Theme.of(context).textTheme.titleMedium),
          Text(SoleraL10n.t('mont.superficie_orientativa'),
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
                child: Text(SoleraL10n.t('mont.quitar_ultimo')),
              ),
              TextButton(
                onPressed: _vertices.isEmpty
                    ? null
                    : () => setState(() => _vertices = []),
                child: Text(SoleraL10n.t('borrar')),
              ),
              const Spacer(),
              FilledButton(
                  onPressed: () => Navigator.pop(context, _vertices),
                  child: Text(SoleraL10n.t('guardar'))),
            ],
          ),
        ],
      ),
    );
  }
}
