import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:geolocator/geolocator.dart';

import '../utiles/numeros_formulario.dart';
import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import '../utiles/permisos_gps.dart';

class PantallaNuevoApiario extends StatefulWidget {
  final Apiario? apiarioExistente;

  const PantallaNuevoApiario({super.key, this.apiarioExistente});

  bool get esEdicion => apiarioExistente != null;

  @override
  State<PantallaNuevoApiario> createState() => _PantallaNuevoApiarioState();
}

class _PantallaNuevoApiarioState extends State<PantallaNuevoApiario> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _codigoSitran = TextEditingController();
  final _superficie = TextEditingController();
  final _notas = TextEditingController();
  double? _latitud;
  double? _longitud;
  int _colorEntero = 0xFFB8860B;
  bool _guardando = false;
  bool _capturandoGps = false;

  static const _colores = <Map<String, Object>>[
    {'label': 'Ocre', 'value': 0xFFB8860B},
    {'label': 'Verde', 'value': 0xFF2E7D32},
    {'label': 'Azul', 'value': 0xFF1565C0},
    {'label': 'Rojo', 'value': 0xFFC62828},
    {'label': 'Morado', 'value': 0xFF6A1B9A},
    {'label': 'Gris', 'value': 0xFF546E7A},
  ];

  @override
  void initState() {
    super.initState();
    final existente = widget.apiarioExistente;
    if (existente != null) {
      _nombre.text = existente.nombre;
      _codigoSitran.text = existente.codigoSitran;
      _superficie.text = existente.superficieHectareas?.toString() ?? '';
      _notas.text = existente.notas;
      _latitud = existente.latitudCentroide;
      _longitud = existente.longitudCentroide;
      _colorEntero = existente.colorEntero;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _codigoSitran.dispose();
    _superficie.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _capturarGps() async {
    setState(() => _capturandoGps = true);
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido) {
      if (!mounted) return;
      setState(() => _capturandoGps = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Falta permiso de ubicación o GPS desactivado.')),
      );
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _latitud = pos.latitude;
        _longitud = pos.longitude;
        _capturandoGps = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _capturandoGps = false);
    }
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final superficie = leerNumero(_superficie.text);
    final db = BaseDatosSoleraApicola.instancia;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final cambios = <String, Object?>{
      'nombre': _nombre.text.trim(),
      'latitud_centroide': _latitud,
      'longitud_centroide': _longitud,
      'color_entero': _colorEntero,
      'notas': _notas.text.trim(),
      'codigo_sitran': _codigoSitran.text.trim(),
      'superficie_hectareas': superficie,
    };
    if (widget.esEdicion) {
      await db.actualizarApiario(widget.apiarioExistente!.id!, cambios);
    } else {
      await db.guardarApiario(
        Apiario(
          nombre: _nombre.text.trim(),
          latitudCentroide: _latitud,
          longitudCentroide: _longitud,
          colorEntero: _colorEntero,
          notas: _notas.text.trim(),
          fechaCreacionMs: ahora,
          codigoSitran: _codigoSitran.text.trim(),
          superficieHectareas: superficie,
        ),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.esEdicion ? 'Editar apiario' : 'Nuevo apiario'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Nombre obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codigoSitran,
              decoration: const InputDecoration(
                labelText: 'Código SITRAN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _superficie,
              decoration: const InputDecoration(
                labelText: 'Superficie (ha)',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: validarDecimalOpcional,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _colorEntero,
              decoration: const InputDecoration(
                labelText: 'Color',
                border: OutlineInputBorder(),
              ),
              items: _colores
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item['value'] as int,
                      child: Text(item['label'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  setState(() => _colorEntero = v ?? _colorEntero),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notas,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _capturandoGps ? null : _capturarGps,
              icon: _capturandoGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Tomar GPS del colmenar'),
            ),
            const SizedBox(height: 8),
            Text(
              _latitud == null || _longitud == null
                  ? 'Sin ubicación fijada'
                  : 'Centroide: ${_latitud!.toStringAsFixed(6)}, ${_longitud!.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (widget.esEdicion) ...[
              const SizedBox(height: 12),
              Text(
                'Editarás el apiario ${widget.apiarioExistente!.nombre}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(widget.esEdicion ? 'Guardar cambios' : 'Crear apiario'),
          ),
        ),
      ),
    );
  }
}
