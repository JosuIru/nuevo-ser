import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/pieza_pasto.dart';
import '../utiles/textos_ganadera.dart';

/// Las otras piezas, para verlas de fondo al marcar el área de [pieza].
List<AreaDeFondo> areasDeFondoPara(
        List<PiezaPasto> piezas, PiezaPasto? pieza) =>
    [
      for (final otra in piezas)
        if (otra.id != pieza?.id && otra.tieneContorno)
          (nombre: otra.nombre, vertices: otra.contorno),
    ];

/// Abre el editor común de áreas (dibujar, caminar con «Mi posición»,
/// ajustar esquinas, importar) y guarda el área de la pieza. Si la pieza no
/// tenía superficie, guarda la calculada.
Future<void> editarAreaPieza(BuildContext context, PiezaPasto pieza) async {
  final baseDatos = BaseDatosSoleraGanadera.instancia;
  final piezas = await baseDatos.listarPiezas();
  if (!context.mounted) return;
  final esquinas = await editarArea(context,
      inicial: pieza.contorno,
      titulo: pieza.nombre,
      areasDeFondo: areasDeFondoPara(piezas, pieza),
      centro: centroDePiezas(piezas),
      paqueteApp: paqueteAppGanadera);
  if (esquinas == null) return;
  await baseDatos.guardarPieza(pieza.conContorno(esquinas));
  avisarCambioDatos();
}

/// Dónde abrir el mapa si la pieza aún no tiene área: en las demás.
LatLng? centroDePiezas(List<PiezaPasto> piezas) =>
    centroide([for (final pieza in piezas) ...pieza.contorno]);

/// Mapa de las piezas de pasto con su área. Sin cobertura no se ven las
/// teselas, pero las áreas sí.
class PantallaMapaPastos extends StatefulWidget {
  const PantallaMapaPastos({super.key, this.conTeselas = true});

  /// Los tests no bajan teselas.
  final bool conTeselas;

  @override
  State<PantallaMapaPastos> createState() => _PantallaMapaPastosState();
}

class _PantallaMapaPastosState extends State<PantallaMapaPastos> {
  late Future<List<PiezaPasto>> _piezas = _cargar();
  CapaBase _capa = CapaBase.callejero;

  static Future<List<PiezaPasto>> _cargar() =>
      BaseDatosSoleraGanadera.instancia.listarPiezas(soloActivas: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('gana.mapa_pastos')),
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
      body: FutureBuilder<List<PiezaPasto>>(
        future: _piezas,
        builder: (context, instantanea) {
          final piezas = instantanea.data ?? const <PiezaPasto>[];
          final conContorno =
              piezas.where((pieza) => pieza.tieneContorno).toList();
          final todos = [for (final pieza in conContorno) ...pieza.contorno];
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
                      capaDeTeselas(_capa, paqueteApp: paqueteAppGanadera),
                    capaDeAreas([
                      for (final pieza in conContorno)
                        (nombre: pieza.nombre, vertices: pieza.contorno),
                    ], color: colorAcentoGanadera),
                    AtribucionCapa(_capa),
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
                        leading: Icon(pieza.tieneContorno
                            ? Icons.pentagon_outlined
                            : Icons.add_location_alt_outlined),
                        title: Text(pieza.nombre),
                        subtitle: Text(pieza.tieneContorno
                            ? '${formatearNumero(pieza.superficieCalculadaHa, decimales: 2)} ha (${SoleraL10n.t('gana.calculada')})'
                            : SoleraL10n.t('gana.sin_contorno')),
                        onTap: () async {
                          await editarAreaPieza(context, pieza);
                          if (!mounted) return;
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
