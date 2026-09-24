import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../datos/almacenador_medios.dart';
import '../../dominio/fenologia.dart';
import '../../dominio/observacion.dart';
import '../../dominio/paleta_del_lugar.dart';
import '../../nucleo/i18n/generado/textos_app.dart';
import '../tema/tipografia.dart';

/// Extrae los colores dominantes de una foto (ruta absoluta). Por
/// defecto decodifica la foto a 48 px de ancho, en el dispositivo: la
/// foto no sale de él.
typedef ExtractorColores = Future<List<int>> Function(String rutaAbsoluta);

Future<List<int>> extraerColoresDeFoto(String rutaAbsoluta) async {
  final bytes = await File(rutaAbsoluta).readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: 48);
  final fotograma = await codec.getNextFrame();
  final datos = await fotograma.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  fotograma.image.dispose();
  codec.dispose();
  if (datos == null) return const [];
  return coloresDominantes(datos.buffer.asUint8List());
}

/// «Los colores de este sitio»: una franja de colores por estación,
/// sacada de las fotos que el niño ha hecho en su sit spot. Si no hay
/// fotos (o no se pueden leer), el bloque no aparece: nada de huecos
/// que rellenar ni estaciones «pendientes».
class BloquePaletaDelLugar extends StatefulWidget {
  const BloquePaletaDelLugar({
    super.key,
    required this.observaciones,
    required this.almacenadorMedios,
    this.extractor = extraerColoresDeFoto,
    this.maximoFotos = 60,
  });

  final List<Observacion> observaciones;
  final AlmacenadorMedios almacenadorMedios;
  final ExtractorColores extractor;

  /// Tope de fotos a leer (las más recientes), para no tardar en
  /// cuadernos muy largos.
  final int maximoFotos;

  @override
  State<BloquePaletaDelLugar> createState() => _EstadoBloquePaletaDelLugar();
}

class _EstadoBloquePaletaDelLugar extends State<BloquePaletaDelLugar> {
  List<PaletaEstacional> _franjas = const [];

  @override
  void initState() {
    super.initState();
    _calcular();
  }

  @override
  void didUpdateWidget(covariant BloquePaletaDelLugar anterior) {
    super.didUpdateWidget(anterior);
    if (!identical(anterior.observaciones, widget.observaciones)) _calcular();
  }

  Future<void> _calcular() async {
    final conFoto = widget.observaciones
        .where((o) => o.fotoRutaLocal != null)
        .toList()
      ..sort((a, b) => b.cuandoOcurrio.compareTo(a.cuandoOcurrio));
    final fotos = <({DateTime fecha, List<int> colores})>[];
    for (final observacion in conFoto.take(widget.maximoFotos)) {
      try {
        final ruta = await widget.almacenadorMedios.resolverAbsoluta(observacion.fotoRutaLocal!);
        final colores = await widget.extractor(ruta);
        fotos.add((fecha: observacion.cuandoOcurrio, colores: colores));
      } catch (_) {
        // Foto borrada a mano o ilegible: se sigue con las demás.
      }
    }
    if (!mounted) return;
    setState(() => _franjas = paletasPorEstacion(fotos));
  }

  String _nombreEstacion(Estacion estacion, TextosApp textos) {
    switch (estacion) {
      case Estacion.primavera:
        return textos.estacionPrimavera;
      case Estacion.verano:
        return textos.estacionVerano;
      case Estacion.otono:
        return textos.estacionOtono;
      case Estacion.invierno:
        return textos.estacionInvierno;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_franjas.isEmpty) return const SizedBox.shrink();
    final textos = TextosApp.of(context);
    final esquema = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textos.paletaLugarTitulo,
          style: TipografiaCuaderno.serif(color: esquema.onSurface, tamano: TipografiaCuaderno.tamano16),
        ),
        const SizedBox(height: 4),
        Text(
          textos.paletaLugarExplicacion,
          style: TipografiaCuaderno.sans(color: esquema.tertiary, tamano: TipografiaCuaderno.tamano12),
        ),
        const SizedBox(height: 10),
        for (final franja in _franjas)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Semantics(
              label: '${_nombreEstacion(franja.estacion, textos)}, '
                  '${textos.paletaLugarFotos(franja.numeroFotos)}',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_nombreEstacion(franja.estacion, textos)} · '
                      '${textos.paletaLugarFotos(franja.numeroFotos)}',
                      style: TipografiaCuaderno.sans(
                          color: esquema.tertiary, tamano: TipografiaCuaderno.tamano12),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 28,
                        child: Row(
                          children: [
                            for (final color in franja.colores)
                              Expanded(child: ColoredBox(color: Color(color))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
