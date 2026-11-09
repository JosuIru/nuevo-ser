// Editor común de áreas de la suite Larrea. Devuelve las esquinas y no
// toca la BD de ninguna app: cada una guarda el resultado con
// `codificarContorno` en su columna.
//
//   final esquinas = await editarArea(context, inicial: leerContorno(...));
//   null → canceló; [] → quitó el área; si no, el área nueva.

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, buscarLugarEnMapa;

import '../editor/estado_editor_area.dart';
import '../geometria/edicion_contorno.dart';
import '../geometria/geodesia.dart';
import '../geometria/importar_contornos.dart';
import '../gps/ubicacion.dart';
import 'capas.dart';
import 'formato.dart';

/// Centro de la Península, si no hay nada mejor.
const LatLng centroPeninsula = LatLng(40.2, -3.7);

/// Otra área para ver de fondo (las vecinas), sin editarla.
typedef AreaDeFondo = ({String nombre, List<LatLng> vertices});

/// Abre el editor. [centro] se usa si no hay área inicial (la parcela, la
/// finca, el último punto conocido…).
Future<List<LatLng>?> editarArea(
  BuildContext context, {
  List<LatLng> inicial = const [],
  LatLng? centro,
  String? titulo,
  List<AreaDeFondo> areasDeFondo = const [],
  String paqueteApp = 'com.coleccionnuevoser.larrea',
}) =>
    Navigator.of(context).push<List<LatLng>>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PantallaEditorArea(
        inicial: inicial,
        centro: centro,
        titulo: titulo,
        areasDeFondo: areasDeFondo,
        paqueteApp: paqueteApp,
      ),
    ));

class PantallaEditorArea extends StatefulWidget {
  const PantallaEditorArea({
    super.key,
    this.inicial = const [],
    this.centro,
    this.titulo,
    this.areasDeFondo = const [],
    this.paqueteApp = 'com.coleccionnuevoser.larrea',
    this.conTeselas = true,
    this.leerGps = leerPosicionActual,
  });

  final List<LatLng> inicial;
  final LatLng? centro;
  final String? titulo;
  final List<AreaDeFondo> areasDeFondo;
  final String paqueteApp;

  /// Los tests no bajan teselas.
  final bool conTeselas;

  /// Se sustituye en los tests.
  final Future<LecturaGps?> Function() leerGps;

  @override
  State<PantallaEditorArea> createState() => _PantallaEditorAreaState();
}

class _PantallaEditorAreaState extends State<PantallaEditorArea> {
  late final EstadoEditorArea _editor = EstadoEditorArea(widget.inicial);
  final MapController _controladorMapa = MapController();
  // Se sigue la linde sobre la foto aérea.
  CapaBase _capa = CapaBase.ortofoto;
  bool _leyendoGps = false;

  bool get _hayCambios => _editor.puedeDeshacer;

  LatLng get _centroInicial =>
      centroide(widget.inicial) ?? widget.centro ?? centroPeninsula;

  double get _zoomInicial =>
      widget.inicial.isNotEmpty || widget.centro != null ? 17 : 6;

  void _alListo() {
    if (widget.inicial.length < 2) return;
    try {
      _controladorMapa.fitCamera(CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(widget.inicial),
        padding: const EdgeInsets.fromLTRB(48, 48, 48, 160),
        maxZoom: 19,
      ));
    } catch (_) {}
  }

  void _avisar(String texto) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _anadirMiPosicion() async {
    setState(() => _leyendoGps = true);
    final lectura = await widget.leerGps();
    if (!mounted) return;
    setState(() => _leyendoGps = false);
    if (lectura == null) {
      _avisar(SoleraL10n.t('mapa.sin_gps'));
      return;
    }
    final metros = lectura.precisionMetros.round().toString();
    // Con más de 25 m de error la esquina no sirve: se avisa y no se pone.
    if (lectura.precisionMetros > 25) {
      _avisar(SoleraL10n.tf('mapa.precision_baja', {'metros': metros}));
      return;
    }
    setState(() => _editor.anadirPosicion(lectura.posicion));
    _avisar(SoleraL10n.tf('mapa.esquina_gps', {'metros': metros}));
    try {
      _controladorMapa.move(lectura.posicion, _controladorMapa.camera.zoom);
    } catch (_) {}
  }

  Future<void> _irAMiUbicacion() async {
    setState(() => _leyendoGps = true);
    final lectura = await widget.leerGps();
    if (!mounted) return;
    setState(() => _leyendoGps = false);
    if (lectura == null) {
      _avisar(SoleraL10n.t('mapa.sin_gps'));
      return;
    }
    _controladorMapa.move(lectura.posicion, 18);
  }

  Future<void> _buscar() async {
    final lugar = await buscarLugarEnMapa(context);
    if (lugar == null || !mounted) return;
    _controladorMapa.move(lugar, 16);
  }

  Future<void> _importar() async {
    final ContornosLeidos leidos;
    try {
      final elegido = await FilePicker.platform
          .pickFiles(type: FileType.any, withData: true);
      final fichero = elegido?.files.singleOrNull;
      final bytes = fichero?.bytes;
      if (fichero == null || bytes == null) return;
      leidos = leerContornos(fichero.name, Uint8List.fromList(bytes));
    } catch (_) {
      if (mounted) _avisar(SoleraL10n.t('mapa.area_error_fichero'));
      return;
    }
    if (!mounted) return;
    if (leidos.poligonos.isEmpty) {
      _avisar(SoleraL10n.t('mapa.area_ninguna_en_fichero'));
      return;
    }
    final elegido = leidos.poligonos.length == 1
        ? leidos.poligonos.single
        : await showDialog<PoligonoImportado>(
            context: context,
            builder: (contexto) => SimpleDialog(
              title: Text(SoleraL10n.t('mapa.area_elegir_importada')),
              children: [
                for (final poligono in leidos.poligonos)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(contexto, poligono),
                    child: Text(
                        '${poligono.nombre.isEmpty ? SoleraL10n.t('mapa.sin_nombre') : poligono.nombre}'
                        ' · ${formatearHectareas(superficieHectareas(poligono.vertices))} ha'),
                  ),
              ],
            ),
          );
    if (elegido == null || !mounted) return;
    setState(() => _editor.reemplazar(elegido.vertices));
    if (leidos.supuestoUtm30) _avisar(SoleraL10n.t('mapa.area_supuesto_utm'));
    try {
      _controladorMapa.fitCamera(CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(elegido.vertices),
          padding: const EdgeInsets.fromLTRB(48, 48, 48, 160)));
    } catch (_) {}
  }

  Future<void> _salir() async {
    if (!_hayCambios) {
      Navigator.pop(context);
      return;
    }
    final salir = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(SoleraL10n.t('mapa.salir_sin_guardar')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(SoleraL10n.t('mapa.seguir'))),
          TextButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(SoleraL10n.t('mapa.salir'))),
        ],
      ),
    );
    if (salir == true && mounted) Navigator.pop(context);
  }

  void _guardar() {
    if (!_editor.esArea) {
      _avisar(SoleraL10n.t('mapa.area_faltan'));
      return;
    }
    Navigator.pop(context, _editor.esquinas);
  }

  List<Marker> _asas(ColorScheme colores) {
    final esquinas = _editor.esquinas;
    return [
      if (_editor.esArea)
        for (final (lado, medio) in puntosMedios(esquinas).indexed)
          Marker(
            point: medio,
            width: 26,
            height: 26,
            child: GestureDetector(
              key: ValueKey('mapa.lado.$lado'),
              onTap: () => setState(() => _editor.insertarEnLado(lado)),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: colores.primary),
                ),
                child: Icon(Icons.add, size: 16, color: colores.primary),
              ),
            ),
          ),
      for (final (indice, esquina) in esquinas.indexed)
        Marker(
          point: esquina,
          width: 32,
          height: 32,
          child: GestureDetector(
            key: ValueKey('mapa.esquina.$indice'),
            onTap: () => setState(() => _editor.elegir(indice)),
            child: Center(
              child: Container(
                width: _editor.elegida == indice ? 26 : 16,
                height: _editor.elegida == indice ? 26 : 16,
                decoration: BoxDecoration(
                  color: _editor.elegida == indice
                      ? colores.tertiary
                      : colores.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final esquinas = _editor.esquinas;
    final resumen = _editor.esArea
        ? SoleraL10n.tf('mapa.area_resumen', {
            'hectareas': formatearHectareas(_editor.hectareas),
            'metros': formatearMetros(_editor.perimetro),
          })
        : esquinas.length >= 2
            ? SoleraL10n.tf('mapa.area_recorrido',
                {'metros': formatearMetros(_editor.perimetro)})
            : '';
    final ayuda = _editor.elegida != null
        ? SoleraL10n.t('mapa.area_ayuda_elegida')
        : esquinas.isEmpty
            ? SoleraL10n.t('mapa.area_ayuda_vacia')
            : '';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (seFue, _) {
        if (!seFue) _salir();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: SoleraL10n.t('mapa.salir'),
              onPressed: _salir),
          title: Text(widget.titulo ?? SoleraL10n.t('mapa.area_titulo')),
          actions: [
            IconButton(
              tooltip: SoleraL10n.t('mapa.buscar'),
              icon: const Icon(Icons.search),
              onPressed: _buscar,
            ),
            PopupMenuButton<String>(
              onSelected: (opcion) => switch (opcion) {
                'importar' => _importar(),
                'borrar' => setState(_editor.borrarTodo),
                'quitar' => Navigator.pop(context, const <LatLng>[]),
                _ => null,
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'importar',
                    child: Text(SoleraL10n.t('mapa.area_importar'))),
                if (esquinas.isNotEmpty)
                  PopupMenuItem(
                      value: 'borrar',
                      child: Text(SoleraL10n.t('mapa.area_borrar'))),
                if (widget.inicial.isNotEmpty)
                  PopupMenuItem(
                      value: 'quitar',
                      child: Text(SoleraL10n.t('mapa.area_quitar'))),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _controladorMapa,
              options: MapOptions(
                initialCenter: _centroInicial,
                initialZoom: _zoomInicial,
                maxZoom: 22,
                onMapReady: _alListo,
                onTap: (_, punto) => setState(() => _editor.tocarMapa(punto)),
              ),
              children: [
                if (widget.conTeselas)
                  capaDeTeselas(_capa, paqueteApp: widget.paqueteApp),
                PolygonLayer(polygons: [
                  for (final fondo in widget.areasDeFondo)
                    if (fondo.vertices.length >= 3)
                      Polygon(
                        points: fondo.vertices,
                        color: Colors.white.withValues(alpha: 0.12),
                        borderColor: Colors.white70,
                        borderStrokeWidth: 1.5,
                        label: fondo.nombre,
                      ),
                  if (_editor.esArea)
                    Polygon(
                      points: esquinas,
                      color: colores.primary.withValues(alpha: 0.25),
                      borderColor: colores.primary,
                      borderStrokeWidth: 3,
                    ),
                ]),
                if (!_editor.esArea && esquinas.length >= 2)
                  PolylineLayer(polylines: [
                    Polyline(
                        points: esquinas,
                        color: colores.primary,
                        strokeWidth: 3),
                  ]),
                MarkerLayer(markers: _asas(colores)),
                AtribucionCapa(_capa),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'mapa.capa',
                    tooltip: SoleraL10n.t('mapa.cambiar_capa'),
                    onPressed: () => setState(() => _capa = _capa.otra),
                    child: Icon(_capa == CapaBase.ortofoto
                        ? Icons.map_outlined
                        : Icons.satellite_alt_outlined),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'mapa.ubicacion',
                    tooltip: SoleraL10n.t('mapa.mi_ubicacion'),
                    onPressed: _leyendoGps ? null : _irAMiUbicacion,
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
            if (ayuda.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                right: 64,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(ayuda),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  [
                    SoleraL10n.tf(
                        'mapa.area_esquinas', {'n': '${esquinas.length}'}),
                    if (resumen.isNotEmpty) resumen,
                  ].join(' · '),
                  key: const ValueKey('mapa.resumen'),
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                if (_editor.esArea)
                  Text(SoleraL10n.t('mapa.area_orientativa'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _leyendoGps ? null : _anadirMiPosicion,
                      icon: _leyendoGps
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.gps_fixed),
                      label: Text(SoleraL10n.t('mapa.area_mi_posicion')),
                    ),
                    if (_editor.elegida != null)
                      OutlinedButton.icon(
                        onPressed:
                            esquinas.length > esquinasMinimas || !_editor.esArea
                                ? () => setState(_editor.quitarElegida)
                                : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        label: Text(SoleraL10n.t('mapa.area_quitar_esquina')),
                      ),
                    OutlinedButton.icon(
                      onPressed: _editor.puedeDeshacer
                          ? () => setState(_editor.deshacer)
                          : null,
                      icon: const Icon(Icons.undo),
                      label: Text(SoleraL10n.t('mapa.area_deshacer')),
                    ),
                    FilledButton.icon(
                      onPressed: _editor.esArea ? _guardar : null,
                      icon: const Icon(Icons.check),
                      label: Text(SoleraL10n.t('mapa.area_guardar')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
