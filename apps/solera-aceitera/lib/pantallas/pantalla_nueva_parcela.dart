import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades_olivo.dart';
import '../modelos/parcela.dart';
import '../utiles/textos_visibles.dart';

/// Paquete de la app, para identificarse ante OpenStreetMap.
const String paqueteAppAceitera = 'com.coleccionnuevoser.solera_aceitera';

/// Si hay área y no punto, el punto es el centro del área (el mapa y la
/// meteo usan el punto).
(double?, double?) puntoOCentroDelArea(
    double? latitud, double? longitud, List<LatLng> area) {
  if (latitud != null && longitud != null) return (latitud, longitud);
  final centro = centroide(area);
  return (centro?.latitude, centro?.longitude);
}

/// Formulario de alta de una parcela nueva. Sin catálogo curado en
/// F1-A3 — la variedad y el sistema de riego son texto libre. F1-A6
/// añade autocomplete contra catálogo CSV.
class PantallaNuevaParcela extends StatefulWidget {
  final int olivarId;
  final double? latitudInicial;
  final double? longitudInicial;

  const PantallaNuevaParcela({
    super.key,
    required this.olivarId,
    this.latitudInicial,
    this.longitudInicial,
  });

  @override
  State<PantallaNuevaParcela> createState() => _PantallaNuevaParcelaState();
}

class _PantallaNuevaParcelaState extends State<PantallaNuevaParcela> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _sigpacCtrl = TextEditingController();
  final _superficieCtrl = TextEditingController();
  final _variedadCtrl = TextEditingController();
  final _marcoCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  String _sistemaRiego = 'secano';
  bool _guardando = false;
  double? _latitud;
  double? _longitud;
  List<LatLng> _area = const [];

  @override
  void initState() {
    super.initState();
    _latitud = widget.latitudInicial;
    _longitud = widget.longitudInicial;
  }

  static const _opcionesRiego = [
    'secano',
    'superficial',
    'goteo',
    'aspersion',
    'mixto'
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _sigpacCtrl.dispose();
    _superficieCtrl.dispose();
    _variedadCtrl.dispose();
    _marcoCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final (latitud, longitud) = puntoOCentroDelArea(_latitud, _longitud, _area);
    final p = Parcela(
      olivarId: widget.olivarId,
      nombre: _nombreCtrl.text.trim(),
      codigoSigpac: _sigpacCtrl.text.trim(),
      superficieHa: leerNumero(_superficieCtrl.text) ?? 0,
      variedadMayoritariaId: _variedadCtrl.text.trim(),
      marcoPlantacion: _marcoCtrl.text.trim(),
      edadMediaAnyos: leerNumero(_edadCtrl.text)?.round() ?? 0,
      sistemaRiego: _sistemaRiego,
      latitud: latitud,
      longitud: longitud,
      contorno: codificarContorno(_area),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    );
    await BaseDatosSoleraAceitera().insertarParcela(p);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('acei.nueva_parcela'))),
      bottomNavigationBar: BarraGuardarSolera(botones: [
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: textoOGuardando(SoleraL10n.t('acei.guardar_parcela'),
              guardando: _guardando),
        ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: CuerpoResponsivoSolera(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.nombre_de_la_parcela'),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? SoleraL10n.t('acei.obligatorio')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sigpacCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.codigo_sigpac'),
                  hintText: SoleraL10n.t('acei.ejemplo_sigpac'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _superficieCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.superficie_ha'),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: validarNumeroOpcional,
              ),
              const SizedBox(height: 12),
              Autocomplete<VariedadOlivo>(
                displayStringForOption: (v) => v.nombreCanonico,
                optionsBuilder: (entrada) {
                  final texto = entrada.text.trim();
                  if (texto.isEmpty) return const Iterable.empty();
                  return buscarVariedadesOlivo(texto).take(8);
                },
                onSelected: (v) {
                  _variedadCtrl.text = v.id;
                },
                fieldViewBuilder: (context, controlador, foco, alEnviar) {
                  return TextFormField(
                    controller: controlador,
                    focusNode: foco,
                    decoration: InputDecoration(
                      labelText: SoleraL10n.t('acei.variedad_mayoritaria'),
                      hintText: SoleraL10n.t('acei.ejemplo_variedades'),
                      border: OutlineInputBorder(),
                      helperText:
                          SoleraL10n.t('acei.sugerencias_catalogo_provisional'),
                    ),
                    onChanged: (texto) {
                      // Si el usuario escribe texto libre que no coincide
                      // con ninguna sugerencia, lo respetamos tal cual.
                      _variedadCtrl.text = texto.trim();
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marcoCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.marco_de_plantacion'),
                  hintText: SoleraL10n.t('acei.ejemplo_marco'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _edadCtrl,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.edad_media_anyos'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: validarNumeroOpcional,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sistemaRiego,
                decoration: InputDecoration(
                  labelText: SoleraL10n.t('acei.sistema_de_riego'),
                  border: OutlineInputBorder(),
                ),
                items: _opcionesRiego
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(nombreSistemaRiego(r))))
                    .toList(),
                onChanged: (v) => setState(() => _sistemaRiego = v ?? 'secano'),
              ),
              const SizedBox(height: 12),
              CampoPunto(
                latitud: _latitud,
                longitud: _longitud,
                centro: centroide(_area),
                areasDeFondo: [(nombre: '', vertices: _area)],
                paqueteApp: paqueteAppAceitera,
                alCambiar: (latitud, longitud) => setState(() {
                  _latitud = latitud;
                  _longitud = longitud;
                }),
              ),
              const SizedBox(height: 8),
              CampoArea(
                vertices: _area,
                centro: _latitud == null || _longitud == null
                    ? null
                    : LatLng(_latitud!, _longitud!),
                paqueteApp: paqueteAppAceitera,
                alCambiar: (vertices) => setState(() => _area = vertices),
                alUsarSuperficie: (hectareas) => setState(() => _superficieCtrl
                    .text = formatearNumero(hectareas, decimales: 2)),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
