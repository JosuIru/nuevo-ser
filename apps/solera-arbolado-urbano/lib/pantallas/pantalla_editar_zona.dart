import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../modelos/zona.dart';

/// Paquete de la app, para identificarse ante OpenStreetMap.
const String paqueteAppArbolado =
    'com.coleccionnuevoser.solera_arbolado_urbano';

/// Alta o edición de una zona (parque, paseo, barrio…): nombre, área en
/// el mapa y notas. El centroide de la zona sale de su área.
class PantallaEditarZona extends StatefulWidget {
  const PantallaEditarZona({
    super.key,
    this.zona,
    this.otrasZonas = const [],
    this.centroInicial,
  });

  final Zona? zona;

  /// Se ven de fondo al dibujar, para no pisar zonas vecinas.
  final List<Zona> otrasZonas;

  /// Dónde abrir el mapa si la zona aún no tiene área.
  final LatLng? centroInicial;

  @override
  State<PantallaEditarZona> createState() => _PantallaEditarZonaState();
}

class _PantallaEditarZonaState extends State<PantallaEditarZona> {
  final _claveFormulario = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.zona?.nombre ?? '');
  late final _notas = TextEditingController(text: widget.zona?.notas ?? '');
  late List<LatLng> _area = widget.zona?.vertices ?? const [];
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _notas.dispose();
    super.dispose();
  }

  LatLng? get _centroDelMapa {
    final zona = widget.zona;
    if (zona?.latitudCentroide != null && zona?.longitudCentroide != null) {
      return LatLng(zona!.latitudCentroide!, zona.longitudCentroide!);
    }
    return widget.centroInicial;
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final original = widget.zona;
    // Nada más rellena el centroide: sale del área si la hay.
    final centro = centroide(_area);
    final latitud = centro?.latitude ?? original?.latitudCentroide;
    final longitud = centro?.longitude ?? original?.longitudCentroide;
    final baseDatos = BaseDatosSoleraArbolado.instancia;
    final contorno = codificarContorno(_area);
    if (original?.id != null) {
      await baseDatos.actualizarZona(original!.id!, {
        'nombre': _nombre.text.trim(),
        'notas': _notas.text.trim(),
        'contorno': contorno,
        'latitud_centroide': latitud,
        'longitud_centroide': longitud,
      });
    } else {
      await baseDatos.guardarZona(Zona(
        nombre: _nombre.text.trim(),
        notas: _notas.text.trim(),
        contorno: contorno,
        latitudCentroide: latitud,
        longitudCentroide: longitud,
        fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arb.zona'))),
      body: Form(
        key: _claveFormulario,
        child: CuerpoResponsivoSolera(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nombre,
                decoration: InputDecoration(
                  labelText: '${SoleraL10n.t('arb.nombre')} *',
                  border: const OutlineInputBorder(),
                ),
                validator: (texto) => (texto ?? '').trim().isEmpty
                    ? SoleraL10n.tf('arb.campo_obligatorio',
                        {'campo': SoleraL10n.t('arb.nombre')})
                    : null,
              ),
              const SizedBox(height: 12),
              CampoArea(
                vertices: _area,
                centro: _centroDelMapa,
                areasDeFondo: [
                  for (final otra in widget.otrasZonas)
                    if (otra.id != widget.zona?.id)
                      (nombre: otra.nombre, vertices: otra.vertices),
                ],
                paqueteApp: paqueteAppArbolado,
                alCambiar: (vertices) => setState(() => _area = vertices),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notas,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('arb.notas'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child:
              textoOGuardando(SoleraL10n.t('guardar'), guardando: _guardando),
        ),
      ]),
    );
  }
}
