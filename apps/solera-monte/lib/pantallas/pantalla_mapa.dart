import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/incendios.dart';
import '../estado/cambios_datos.dart';
import '../modelos/arbol_singular.dart';
import '../modelos/incendios.dart';
import '../modelos/rodal.dart';
import '../utiles/textos_monte.dart';

/// Los otros rodales, para verlos de fondo al marcar el área de [rodal].
List<AreaDeFondo> areasDeFondoPara(List<Rodal> rodales, Rodal? rodal) => [
      for (final otro in rodales)
        if (otro.id != rodal?.id && otro.tieneContorno)
          (nombre: otro.codigo, vertices: otro.contorno),
    ];

/// Dónde abrir el mapa si el rodal aún no tiene área: en los demás.
LatLng? centroDeRodales(List<Rodal> rodales) =>
    centroide([for (final rodal in rodales) ...rodal.contorno]);

/// Abre el editor común de áreas (dibujar, caminar la linde con «Mi
/// posición», ajustar esquinas, importar) y guarda el contorno del rodal.
/// La superficie declarada no se toca: la comparación declarada/dibujada
/// sigue en `dominio/superficies.dart`.
Future<void> editarAreaRodal(BuildContext context, Rodal rodal) async {
  final bd = BaseDatosSoleraMonte.instancia;
  final rodales = await bd.listarRodales();
  if (!context.mounted) return;
  final esquinas = await editarArea(context,
      inicial: rodal.contorno,
      titulo: rodal.etiqueta,
      centro: centroDeRodales(rodales),
      areasDeFondo: areasDeFondoPara(rodales, rodal),
      paqueteApp: paqueteAppMonte);
  if (esquinas == null) return;
  await bd.guardarRodal(rodal.conContorno(esquinas));
  avisarCambioDatos();
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
  const PantallaMapaMonte({super.key, this.conTeselas = true});

  /// Los tests no bajan teselas.
  final bool conTeselas;

  @override
  State<PantallaMapaMonte> createState() => _PantallaMapaMonteState();
}

class _PantallaMapaMonteState extends State<PantallaMapaMonte> {
  late Future<_DatosMapa> _datos = _cargar();
  CapaBase _capa = CapaBase.callejero;

  static Future<_DatosMapa> _cargar() async {
    final bd = BaseDatosSoleraMonte.instancia;
    return _DatosMapa(
        await bd.listarRodales(),
        await bd.listarInfraestructuras(soloActivas: true),
        await bd.listarArboles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('mont.mapa')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('mapa.cambiar_capa'),
            icon: Icon(_capa == CapaBase.ortofoto
                ? Icons.map_outlined
                : Icons.satellite_alt_outlined),
            onPressed: () => setState(() => _capa = _capa.otra),
          ),
        ],
      ),
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
            for (final rodal in conContorno) ...rodal.contorno,
            for (final linea in lineas) ...linea.traza,
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
                    if (widget.conTeselas)
                      capaDeTeselas(_capa, paqueteApp: paqueteAppMonte),
                    capaDeAreas([
                      for (final rodal in conContorno)
                        (nombre: rodal.codigo, vertices: rodal.contorno),
                    ], color: colorPrimarioMonte),
                    PolylineLayer(polylines: [
                      for (final linea in lineas)
                        Polyline(
                          points: linea.traza,
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
                    AtribucionCapa(_capa),
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
                        onTap: () async {
                          await editarAreaRodal(context, rodal);
                          if (!mounted) return;
                          setState(() {
                            _datos = _cargar();
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

/// Trazar una línea caminando (pista, cortafuegos, faja): en cada recodo,
/// «Añadir punto aquí» guarda la posición del GPS. Devuelve los vértices al
/// guardar. Las áreas (rodales) van con el editor común de `nuevo_ser_mapa`,
/// que no hace líneas.
class PantallaTrazado extends StatefulWidget {
  const PantallaTrazado({
    super.key,
    required this.titulo,
    required this.verticesIniciales,
    this.leerGps = leerPosicionActual,
  });

  final String titulo;
  final List<LatLng> verticesIniciales;

  /// Se sustituye en los tests.
  final Future<LecturaGps?> Function() leerGps;

  @override
  State<PantallaTrazado> createState() => _PantallaTrazadoState();
}

class _PantallaTrazadoState extends State<PantallaTrazado> {
  late List<LatLng> _vertices = [...widget.verticesIniciales];
  bool _buscando = false;

  Future<void> _anadirPunto() async {
    final mensajero = ScaffoldMessenger.of(context);
    setState(() => _buscando = true);
    final lectura = await widget.leerGps();
    if (!mounted) return;
    setState(() => _buscando = false);
    if (lectura == null) {
      mensajero
          .showSnackBar(SnackBar(content: Text(SoleraL10n.t('mont.sin_gps'))));
      return;
    }
    setState(() => _vertices = [..._vertices, lectura.posicion]);
  }

  @override
  Widget build(BuildContext context) {
    final medida =
        '${formatearNumero(longitudTrazaMetros(_vertices), decimales: 0)} m';
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(SoleraL10n.t('mont.explicacion_traza'),
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
          for (final (indice, vertice) in _vertices.indexed)
            ListTile(
              dense: true,
              leading: Text('${indice + 1}'),
              title: Text('${vertice.latitude.toStringAsFixed(6)}, '
                  '${vertice.longitude.toStringAsFixed(6)}'),
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
