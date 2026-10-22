import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades_olivo.dart';
import '../modelos/parcela.dart';
import '../utiles/permisos_gps.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../utiles/validacion_numeros.dart';

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
  bool _capturandoGps = false;
  double? _latitud;
  double? _longitud;

  @override
  void initState() {
    super.initState();
    _latitud = widget.latitudInicial;
    _longitud = widget.longitudInicial;
  }

  static const _opcionesRiego = ['secano', 'superficial', 'goteo', 'aspersion', 'mixto'];

  Future<void> _capturarGps() async {
    setState(() => _capturandoGps = true);
    try {
      final permiso = await asegurarPermisoUbicacion();
      if (!permiso) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Permiso de ubicación denegado o GPS desactivado. Activa el GPS y reintenta.'),
          ),
        );
        return;
      }
      final posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      if (!mounted) return;
      setState(() {
        _latitud = posicion.latitude;
        _longitud = posicion.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'GPS capturado: ${posicion.latitude.toStringAsFixed(5)}, ${posicion.longitude.toStringAsFixed(5)} (precisión ±${posicion.accuracy.toStringAsFixed(0)} m)'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturando GPS: $e')),
      );
    } finally {
      if (mounted) setState(() => _capturandoGps = false);
    }
  }

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
    final p = Parcela(
      olivarId: widget.olivarId,
      nombre: _nombreCtrl.text.trim(),
      codigoSigpac: _sigpacCtrl.text.trim(),
      superficieHa: leerNumero(_superficieCtrl.text) ?? 0,
      variedadMayoritariaId: _variedadCtrl.text.trim(),
      marcoPlantacion: _marcoCtrl.text.trim(),
      edadMediaAnyos: leerNumero(_edadCtrl.text)?.round() ?? 0,
      sistemaRiego: _sistemaRiego,
      latitud: _latitud,
      longitud: _longitud,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    );
    await BaseDatosSoleraAceitera().insertarParcela(p);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva parcela')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la parcela',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sigpacCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código SIGPAC',
                  hintText: 'Ej. 23:077:001:00074:0001:WX',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _superficieCtrl,
                decoration: const InputDecoration(
                  labelText: 'Superficie (ha)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                fieldViewBuilder:
                    (context, controlador, foco, alEnviar) {
                  return TextFormField(
                    controller: controlador,
                    focusNode: foco,
                    decoration: const InputDecoration(
                      labelText: 'Variedad mayoritaria',
                      hintText: 'picual, hojiblanca, arbequina…',
                      border: OutlineInputBorder(),
                      helperText:
                          'Sugerencias del catálogo provisional (texto libre admitido)',
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
                decoration: const InputDecoration(
                  labelText: 'Marco de plantación',
                  hintText: '8x6, 7x7, 1.5x4 superintensivo…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _edadCtrl,
                decoration: const InputDecoration(
                  labelText: 'Edad media (años)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: validarNumeroOpcional,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sistemaRiego,
                decoration: const InputDecoration(
                  labelText: 'Sistema de riego',
                  border: OutlineInputBorder(),
                ),
                items: _opcionesRiego
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _sistemaRiego = v ?? 'secano'),
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _latitud == null
                            ? Icons.location_off
                            : Icons.location_on,
                        color: const Color(0xFF5C6B3A),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _latitud == null
                              ? 'Sin coordenadas (opcional)'
                              : 'GPS: ${_latitud!.toStringAsFixed(5)}, ${_longitud!.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _capturandoGps ? null : _capturarGps,
                        icon: _capturandoGps
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        label: const Text('Capturar GPS'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar parcela'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
