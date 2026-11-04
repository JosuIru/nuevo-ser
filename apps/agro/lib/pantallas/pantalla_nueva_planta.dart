import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/finca.dart';
import '../modelos/planta.dart';
import '../utiles/permisos_gps.dart';

/// Alta o edición de planta. Se invoca desde el FAB del mapa, modo
/// censo, lista de plantas o ficha (botón editar).
///
/// Modo alta: `plantaExistente == null`. Camino feliz corto: cultivo,
/// (finca opcional), guardar.
/// Modo edición: `plantaExistente != null`. Carga los valores actuales
/// y permite cambiarlos. La ubicación es editable (puedes recapturar
/// GPS si la primera medida fue mala) pero ojo — al editar se
/// sustituye, no se mantiene historial de la posición.
class PantallaNuevaPlanta extends StatefulWidget {
  final int? fincaIdInicial;
  final double? latitudInicial;
  final double? longitudInicial;
  final Planta? plantaExistente;

  const PantallaNuevaPlanta({
    super.key,
    this.fincaIdInicial,
    this.latitudInicial,
    this.longitudInicial,
    this.plantaExistente,
  });

  @override
  State<PantallaNuevaPlanta> createState() => _PantallaNuevaPlantaState();
}

class _PantallaNuevaPlantaState extends State<PantallaNuevaPlanta> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorVariedad = TextEditingController();
  final _controladorPatron = TextEditingController();
  final _controladorEtiqueta = TextEditingController();
  final _controladorNotas = TextEditingController();

  String _cultivoId = 'olivo';
  int? _fincaId;
  double? _latitud;
  double? _longitud;
  double? _precision;
  DateTime? _fechaPlantacion;
  List<String> _rutasFotos = [];
  List<Finca> _fincas = [];
  bool _guardando = false;

  bool get _esEdicion => widget.plantaExistente != null;

  @override
  void initState() {
    super.initState();
    final existente = widget.plantaExistente;
    if (existente != null) {
      _cultivoId = existente.cultivoId;
      _fincaId = existente.fincaId;
      _latitud = existente.latitud;
      _longitud = existente.longitud;
      _precision = existente.precisionMetros;
      _fechaPlantacion = existente.fechaPlantacionMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(existente.fechaPlantacionMs!);
      _controladorVariedad.text = existente.variedad;
      _controladorPatron.text = existente.patron;
      _controladorEtiqueta.text = existente.etiqueta;
      _controladorNotas.text = existente.notas;
      _rutasFotos = GestorFotos.decodificar(existente.rutasFotosJson);
    } else {
      _fincaId = widget.fincaIdInicial;
      _latitud = widget.latitudInicial;
      _longitud = widget.longitudInicial;
      if (_latitud == null || _longitud == null) {
        _capturarPosicion();
      }
    }
    _cargarFincas();
  }

  @override
  void dispose() {
    _controladorVariedad.dispose();
    _controladorPatron.dispose();
    _controladorEtiqueta.dispose();
    _controladorNotas.dispose();
    super.dispose();
  }

  Future<void> _cargarFincas() async {
    final fincas = await BaseDatosAgro.instancia.listarFincas();
    if (!mounted) return;
    setState(() => _fincas = fincas);
  }

  Future<void> _capturarPosicion() async {
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido) return;
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitud = pos.latitude;
        _longitud = pos.longitude;
        _precision = pos.accuracy;
      });
    } catch (_) {}
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta la posición: pulsa «Capturar GPS» o vuelve al mapa.')),
      );
      return;
    }
    setState(() => _guardando = true);
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final existente = widget.plantaExistente;
    if (existente != null) {
      // Edición: respetar fechaCreacionMs original.
      await BaseDatosAgro.instancia.actualizarPlanta(existente.id!, {
        'finca_id': _fincaId,
        'cultivo_id': _cultivoId,
        'variedad': _controladorVariedad.text.trim(),
        'latitud': _latitud,
        'longitud': _longitud,
        'precision_metros': _precision,
        'fecha_plantacion_ms': _fechaPlantacion?.millisecondsSinceEpoch,
        'patron': _controladorPatron.text.trim(),
        'etiqueta': _controladorEtiqueta.text.trim(),
        'notas': _controladorNotas.text.trim(),
        'rutas_fotos_json': fotosJson,
      });
    } else {
      final ahora = DateTime.now().millisecondsSinceEpoch;
      final planta = Planta(
        fincaId: _fincaId,
        cultivoId: _cultivoId,
        variedad: _controladorVariedad.text.trim(),
        latitud: _latitud!,
        longitud: _longitud!,
        precisionMetros: _precision,
        fechaPlantacionMs: _fechaPlantacion?.millisecondsSinceEpoch,
        patron: _controladorPatron.text.trim(),
        etiqueta: _controladorEtiqueta.text.trim(),
        notas: _controladorNotas.text.trim(),
        rutasFotosJson: fotosJson,
        fechaCreacionMs: ahora,
      );
      await BaseDatosAgro.instancia.guardarPlanta(planta);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cultivo = cultivoPorId(_cultivoId);
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar planta' : 'Nueva planta')),
      body: AbsorbPointer(
        absorbing: _guardando,
        child: Form(
          key: _claveFormulario,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _cultivoId,
                decoration: const InputDecoration(labelText: 'Cultivo *', border: OutlineInputBorder()),
                items: [
                  for (final c in catalogoCultivos)
                    DropdownMenuItem(value: c.id, child: Text(c.nombreVisible)),
                ],
                onChanged: (v) => setState(() => _cultivoId = v ?? 'generico'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _fincaId,
                decoration: const InputDecoration(
                  labelText: 'Finca (vacío = punto suelto)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('— Punto suelto —')),
                  for (final f in _fincas) DropdownMenuItem<int?>(value: f.id, child: Text(f.nombre)),
                ],
                onChanged: (v) => setState(() => _fincaId = v),
              ),
              const SizedBox(height: 12),
              if (cultivo.variedadesSugeridas.isNotEmpty)
                _AutocompleteCampo(
                  controlador: _controladorVariedad,
                  etiqueta: 'Variedad',
                  sugerencias: cultivo.variedadesSugeridas,
                )
              else
                TextFormField(
                  controller: _controladorVariedad,
                  decoration: const InputDecoration(labelText: 'Variedad', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 12),
              if (cultivo.patronesSugeridos.isNotEmpty)
                _AutocompleteCampo(
                  controlador: _controladorPatron,
                  etiqueta: cultivo.categoria == CategoriaCultivo.micorricicoTrufa ? 'Hospedero' : 'Patrón',
                  sugerencias: cultivo.patronesSugeridos,
                )
              else
                TextFormField(
                  controller: _controladorPatron,
                  decoration: const InputDecoration(labelText: 'Patrón', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controladorEtiqueta,
                decoration: const InputDecoration(
                  labelText: 'Etiqueta corta (p. ej., A-17, fila 3)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(_fechaPlantacion == null
                    ? 'Fecha de plantación (opcional)'
                    : 'Plantada el ${_fechaPlantacion!.day}/${_fechaPlantacion!.month}/${_fechaPlantacion!.year}'),
                trailing: _fechaPlantacion == null
                    ? null
                    : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _fechaPlantacion = null)),
                onTap: () async {
                  final ahora = DateTime.now();
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: _fechaPlantacion ?? ahora,
                    firstDate: DateTime(1900),
                    lastDate: ahora,
                  );
                  if (pick != null) setState(() => _fechaPlantacion = pick);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controladorNotas,
                decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _latitud == null
                              ? 'Sin posición'
                              : '${_latitud!.toStringAsFixed(6)}, ${_longitud!.toStringAsFixed(6)}'
                                  '${_precision != null ? '  ±${_precision!.toStringAsFixed(0)} m' : ''}',
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.gps_fixed),
                        onPressed: _capturarPosicion,
                        label: const Text('GPS'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Fotos de la planta', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                'Foto del árbol, del tronco con la etiqueta y del entorno. Sirven para identificar la planta en campo.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              SelectorFotos(
                rutas: _rutasFotos,
                alCambiar: (nuevas) => setState(() => _rutasFotos = nuevas),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _guardando ? null : _guardar,
                label: Text(_esEdicion ? 'Guardar cambios' : 'Guardar planta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutocompleteCampo extends StatelessWidget {
  final TextEditingController controlador;
  final String etiqueta;
  final List<String> sugerencias;

  const _AutocompleteCampo({
    required this.controlador,
    required this.etiqueta,
    required this.sugerencias,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        final q = textEditingValue.text.toLowerCase();
        if (q.isEmpty) return sugerencias;
        return sugerencias.where((s) => s.toLowerCase().contains(q));
      },
      onSelected: (s) => controlador.text = s,
      fieldViewBuilder: (context, txt, fn, onSubmit) {
        // Mantenemos el texto sincronizado con `controlador`.
        if (txt.text != controlador.text) {
          txt.text = controlador.text;
        }
        txt.addListener(() {
          controlador.text = txt.text;
        });
        return TextFormField(
          controller: txt,
          focusNode: fn,
          decoration: InputDecoration(labelText: etiqueta, border: const OutlineInputBorder()),
          onFieldSubmitted: (_) => onSubmit(),
        );
      },
    );
  }
}
