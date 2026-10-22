import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_especies_arboreas.dart';
import '../datos/catalogos_generados/catalogo_sustratos_alcorque.dart';
import '../modelos/arbol.dart';
import '../utiles/permisos_gps.dart';
import 'pantalla_escaner_qr.dart';

/// Alta o edición de árbol. Modo alta: `arbolExistente == null`.
///
/// Versión minimalista v0.1: especie y tipo de alcorque son free-text.
/// Cuando entren los catálogos curados (F1U-4) se sustituyen por
/// Autocomplete validado.
class PantallaNuevoArbol extends StatefulWidget {
  final Arbol? arbolExistente;
  final int? zonaIdInicial;
  final double? latitudInicial;
  final double? longitudInicial;
  final String? qrPayloadInicial;

  const PantallaNuevoArbol({
    super.key,
    this.arbolExistente,
    this.zonaIdInicial,
    this.latitudInicial,
    this.longitudInicial,
    this.qrPayloadInicial,
  });

  bool get esEdicion => arbolExistente != null;

  @override
  State<PantallaNuevoArbol> createState() => _PantallaNuevoArbolState();
}

class _PantallaNuevoArbolState extends State<PantallaNuevoArbol> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorIdentificador = TextEditingController();
  final _controladorQr = TextEditingController();
  final _controladorEspecie = TextEditingController();
  final _controladorEdad = TextEditingController();
  final _controladorPerimetro = TextEditingController();
  final _controladorAltura = TextEditingController();
  final _controladorAlcorque = TextEditingController();
  final _controladorNotas = TextEditingController();
  EstadoArbol _estado = EstadoArbol.sano;
  int? _riesgoVta;
  double? _latitud;
  double? _longitud;
  DateTime? _fechaPlantacion;
  List<String> _rutasFotos = [];
  bool _capturandoGps = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final existente = widget.arbolExistente;
    if (existente != null) {
      _controladorIdentificador.text = existente.identificadorMunicipal;
      _controladorQr.text = existente.qrPayload;
      // Si la especie está en catálogo, cargar el nombre canónico para que el
      // operario lea "Plátano de sombra" en vez del id "platano_sombra".
      final especieCanonica = especiePorId(existente.especieId);
      _controladorEspecie.text =
          especieCanonica?.nombreCanonico ?? existente.especieId;
      _controladorEdad.text = existente.edadEstimadaAnos?.toString() ?? '';
      _controladorPerimetro.text = existente.perimetroTroncoCm?.toString() ?? '';
      _controladorAltura.text = existente.alturaEstimadaMetros?.toString() ?? '';
      final alcorqueCanonico = sustratoAlcorquePorId(existente.tipoAlcorqueId);
      _controladorAlcorque.text =
          alcorqueCanonico?.nombreCanonico ?? existente.tipoAlcorqueId;
      _controladorNotas.text = existente.notas;
      _estado = existente.estado;
      _riesgoVta = existente.riesgoVta;
      _latitud = existente.latitud;
      _longitud = existente.longitud;
      if (existente.fechaPlantacionMs != null) {
        _fechaPlantacion = DateTime.fromMillisecondsSinceEpoch(existente.fechaPlantacionMs!);
      }
      _rutasFotos = GestorFotos.decodificar(existente.rutasFotosJson);
    } else {
      _latitud = widget.latitudInicial;
      _longitud = widget.longitudInicial;
      if (widget.qrPayloadInicial != null) {
        _controladorQr.text = widget.qrPayloadInicial!;
      }
      if (_latitud == null || _longitud == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _capturarGps());
      }
    }
  }

  @override
  void dispose() {
    _controladorIdentificador.dispose();
    _controladorQr.dispose();
    _controladorEspecie.dispose();
    _controladorEdad.dispose();
    _controladorPerimetro.dispose();
    _controladorAltura.dispose();
    _controladorAlcorque.dispose();
    _controladorNotas.dispose();
    super.dispose();
  }

  Future<void> _capturarGps() async {
    setState(() => _capturandoGps = true);
    final permitido = await asegurarPermisoUbicacion();
    if (!permitido) {
      if (!mounted) return;
      setState(() => _capturandoGps = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta permiso de ubicación o GPS desactivado.')),
      );
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 10));
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

  Future<void> _escanearQr() async {
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PantallaEscanerQr()),
    );
    if (payload != null && payload.isNotEmpty) {
      setState(() => _controladorQr.text = payload);
    }
  }

  Future<void> _elegirFechaPlantacion() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaPlantacion ?? hoy,
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (fecha != null) setState(() => _fechaPlantacion = fecha);
  }

  /// Resuelve el id estable del catálogo a partir del texto del campo:
  /// si coincide con un nombre canónico devuelve el id; si no, devuelve
  /// el texto crudo en minúsculas para preservar entrada libre.
  String _resolverIdEspecie(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return '';
    for (final e in catalogoEspeciesArboreas) {
      if (e.id == consultaNormalizada) return e.id;
      if (e.nombreCanonico.toLowerCase() == consultaNormalizada) return e.id;
    }
    return consultaNormalizada;
  }

  String _resolverIdAlcorque(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return '';
    for (final s in catalogoSustratosAlcorque) {
      if (s.id == consultaNormalizada) return s.id;
      if (s.nombreCanonico.toLowerCase() == consultaNormalizada) return s.id;
    }
    return consultaNormalizada;
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final db = BaseDatosSoleraArbolado.instancia;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final identificador = _controladorIdentificador.text.trim();
    final idEspecie = _resolverIdEspecie(_controladorEspecie.text);
    final idAlcorque = _resolverIdAlcorque(_controladorAlcorque.text);

    if (widget.esEdicion) {
      final id = widget.arbolExistente!.id!;
      await db.actualizarArbol(id, {
        'identificador_municipal': identificador,
        'qr_payload': _controladorQr.text.trim(),
        'especie_id': idEspecie,
        'edad_estimada_anos': int.tryParse(_controladorEdad.text.trim()),
        'fecha_plantacion_ms': _fechaPlantacion?.millisecondsSinceEpoch,
        'perimetro_tronco_cm': leerNumero(_controladorPerimetro.text),
        'altura_estimada_metros': leerNumero(_controladorAltura.text),
        'riesgo_vta': _riesgoVta,
        'estado': _estadoString(_estado),
        'tipo_alcorque_id': idAlcorque,
        'latitud': _latitud,
        'longitud': _longitud,
        'notas': _controladorNotas.text.trim(),
        'rutas_fotos_json': fotosJson,
      });
    } else {
      // Validar que el identificador municipal no esté ya en uso.
      final existente = await db.obtenerArbolPorIdentificadorMunicipal(identificador);
      if (existente != null) {
        if (!mounted) return;
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya existe un árbol con identificador ${existente.identificadorMunicipal}.')),
        );
        return;
      }
      await db.guardarArbol(Arbol(
        zonaId: widget.zonaIdInicial,
        identificadorMunicipal: identificador,
        qrPayload: _controladorQr.text.trim(),
        especieId: idEspecie,
        edadEstimadaAnos: int.tryParse(_controladorEdad.text.trim()),
        fechaPlantacionMs: _fechaPlantacion?.millisecondsSinceEpoch,
        perimetroTroncoCm: leerNumero(_controladorPerimetro.text),
        alturaEstimadaMetros: leerNumero(_controladorAltura.text),
        riesgoVta: _riesgoVta,
        estado: _estado,
        tipoAlcorqueId: idAlcorque,
        latitud: _latitud,
        longitud: _longitud,
        notas: _controladorNotas.text.trim(),
        rutasFotosJson: fotosJson,
        fechaCreacionMs: ahora,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _estadoString(EstadoArbol e) {
    switch (e) {
      case EstadoArbol.sano:
        return 'sano';
      case EstadoArbol.observacion:
        return 'observacion';
      case EstadoArbol.riesgo:
        return 'riesgo';
      case EstadoArbol.caido:
        return 'caido';
      case EstadoArbol.sustituido:
        return 'sustituido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(widget.esEdicion ? 'Editar árbol' : 'Nuevo árbol')),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _controladorIdentificador,
              decoration: const InputDecoration(
                labelText: 'Identificador municipal *',
                hintText: 'IRU-2024-PASEO-042',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Identificador obligatorio' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorQr,
              decoration: InputDecoration(
                labelText: 'Payload del QR de chapa',
                hintText: 'IRU:2024-PASEO-042',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear chapa',
                  onPressed: _escanearQr,
                ),
              ),
            ),
            const SizedBox(height: 12),
            CampoAutocompleteCatalogo<EspecieArborea>(
              controlador: _controladorEspecie,
              labelText: 'Especie',
              hintText: 'Plátano de sombra, tilo, fresno…',
              opcionesCompletas: catalogoEspeciesArboreas,
              buscar: buscarEspecies,
              displayStringForOption: (e) => e.nombreCanonico,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controladorPerimetro,
                    validator: validarNumeroOpcional,
                    decoration: const InputDecoration(
                      labelText: 'Perímetro tronco (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _controladorAltura,
                    validator: validarNumeroOpcional,
                    decoration: const InputDecoration(
                      labelText: 'Altura (m)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorEdad,
              decoration: const InputDecoration(
                labelText: 'Edad estimada (años)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            CampoAutocompleteCatalogo<SustratoAlcorque>(
              controlador: _controladorAlcorque,
              labelText: 'Tipo de alcorque',
              hintText: 'Alcorque mineral, sellado con asfalto…',
              opcionesCompletas: catalogoSustratosAlcorque,
              buscar: buscarSustratosAlcorque,
              displayStringForOption: (s) => s.nombreCanonico,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EstadoArbol>(
              initialValue: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: EstadoArbol.sano, child: Text('Sano')),
                DropdownMenuItem(value: EstadoArbol.observacion, child: Text('Observación')),
                DropdownMenuItem(value: EstadoArbol.riesgo, child: Text('Riesgo')),
                DropdownMenuItem(value: EstadoArbol.caido, child: Text('Caído / eliminado')),
                DropdownMenuItem(value: EstadoArbol.sustituido, child: Text('Sustituido')),
              ],
              onChanged: (v) => setState(() => _estado = v ?? EstadoArbol.sano),
            ),
            const SizedBox(height: 12),
            _SelectorRiesgoVta(
              valor: _riesgoVta,
              alCambiar: (v) => setState(() => _riesgoVta = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.gps_fixed),
              title: Text(_latitud == null
                  ? 'Sin ubicación'
                  : '${_latitud!.toStringAsFixed(6)}, ${_longitud!.toStringAsFixed(6)}'),
              trailing: _capturandoGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: _capturarGps,
                      child: Text(_latitud == null ? 'Capturar' : 'Recapturar'),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(_fechaPlantacion == null
                  ? 'Sin fecha de plantación'
                  : 'Plantado ${formatoFecha.format(_fechaPlantacion!)}'),
              trailing: TextButton(
                onPressed: _elegirFechaPlantacion,
                child: Text(_fechaPlantacion == null ? 'Elegir' : 'Cambiar'),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Fotos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectorFotos(rutas: _rutasFotos, alCambiar: (r) => setState(() => _rutasFotos = r)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorNotas,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check),
              label: Text(widget.esEdicion ? 'Guardar cambios' : 'Guardar árbol'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector compacto del riesgo VTA — Visual Tree Assessment simplificado.
/// 1 = sin riesgo observable, 5 = peligro inminente que requiere actuación
/// urgente. La decisión de actuar la firma siempre el técnico.
class _SelectorRiesgoVta extends StatelessWidget {
  final int? valor;
  final ValueChanged<int?> alCambiar;
  const _SelectorRiesgoVta({required this.valor, required this.alCambiar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 130, child: Text('Riesgo VTA')),
          Expanded(
            child: SegmentedButton<int?>(
              segments: const [
                ButtonSegment(value: null, label: Text('—')),
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
                ButtonSegment(value: 5, label: Text('5')),
              ],
              selected: {valor},
              onSelectionChanged: (s) => alCambiar(s.first),
              showSelectedIcon: false,
            ),
          ),
        ],
      ),
    );
  }
}
