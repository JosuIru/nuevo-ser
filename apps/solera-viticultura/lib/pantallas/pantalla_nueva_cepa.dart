import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_portainjertos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../modelos/cepa.dart';
import '../utiles/permisos_gps.dart';

/// Alta o edición de cepa. Modo alta: `cepaExistente == null`. Modo
/// edición: viene con la cepa cargada y al guardar hace UPDATE.
///
/// Versión minimalista v0.1: variedad y portainjerto son `TextField`
/// libres. Cuando entre el catálogo curado (F1-4) se sustituyen por
/// `Autocomplete` validado.
class PantallaNuevaCepa extends StatefulWidget {
  final Cepa? cepaExistente;
  final int? vinedoIdInicial;
  final double? latitudInicial;
  final double? longitudInicial;

  const PantallaNuevaCepa({
    super.key,
    this.cepaExistente,
    this.vinedoIdInicial,
    this.latitudInicial,
    this.longitudInicial,
  });

  bool get esEdicion => cepaExistente != null;

  @override
  State<PantallaNuevaCepa> createState() => _PantallaNuevaCepaState();
}

class _PantallaNuevaCepaState extends State<PantallaNuevaCepa> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorVariedad = TextEditingController();
  final _controladorPortainjerto = TextEditingController();
  final _controladorEtiqueta = TextEditingController();
  final _controladorNotas = TextEditingController();
  double? _latitud;
  double? _longitud;
  DateTime? _fechaPlantacion;
  List<String> _rutasFotos = [];
  bool _capturandoGps = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final existente = widget.cepaExistente;
    if (existente != null) {
      _controladorVariedad.text = existente.variedadId;
      _controladorPortainjerto.text = existente.portainjertoId;
      _controladorEtiqueta.text = existente.etiqueta;
      _controladorNotas.text = existente.notas;
      _latitud = existente.latitud;
      _longitud = existente.longitud;
      if (existente.fechaPlantacionMs != null) {
        _fechaPlantacion = DateTime.fromMillisecondsSinceEpoch(existente.fechaPlantacionMs!);
      }
      _rutasFotos = GestorFotos.decodificar(existente.rutasFotosJson);
    } else {
      _latitud = widget.latitudInicial;
      _longitud = widget.longitudInicial;
      if (_latitud == null || _longitud == null) {
        // Si no vino con coordenadas (alta desde la lista), pedir GPS
        // automáticamente al abrir.
        WidgetsBinding.instance.addPostFrameCallback((_) => _capturarGps());
      }
    }
  }

  @override
  void dispose() {
    _controladorVariedad.dispose();
    _controladorPortainjerto.dispose();
    _controladorEtiqueta.dispose();
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
        SnackBar(content: Text(SoleraL10n.t('viti.falta_permiso_ubicacion'))),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('viti.no_se_pudo_obtener_ubicacion'))),
      );
    }
  }

  Future<void> _elegirFechaPlantacion() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaPlantacion ?? DateTime(hoy.year - 5, hoy.month, hoy.day),
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (fecha != null) setState(() => _fechaPlantacion = fecha);
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('viti.falta_capturar_gps'))),
      );
      return;
    }
    setState(() => _guardando = true);
    final db = BaseDatosSoleraViticultura.instancia;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final variedad = _controladorVariedad.text.trim().toLowerCase();

    if (widget.esEdicion) {
      final id = widget.cepaExistente!.id!;
      await db.actualizarCepa(id, {
        'variedad_id': variedad,
        'portainjerto_id': _controladorPortainjerto.text.trim(),
        'latitud': _latitud,
        'longitud': _longitud,
        'fecha_plantacion_ms': _fechaPlantacion?.millisecondsSinceEpoch,
        'etiqueta': _controladorEtiqueta.text.trim(),
        'notas': _controladorNotas.text.trim(),
        'rutas_fotos_json': fotosJson,
      });
    } else {
      await db.guardarCepa(Cepa(
        vinedoId: widget.vinedoIdInicial,
        variedadId: variedad,
        portainjertoId: _controladorPortainjerto.text.trim(),
        latitud: _latitud!,
        longitud: _longitud!,
        fechaPlantacionMs: _fechaPlantacion?.millisecondsSinceEpoch,
        etiqueta: _controladorEtiqueta.text.trim(),
        notas: _controladorNotas.text.trim(),
        rutasFotosJson: fotosJson,
        fechaCreacionMs: ahora,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(widget.esEdicion ? SoleraL10n.t('viti.editar_cepa') : SoleraL10n.t('viti.nueva_cepa'))),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CampoAutocompleteCatalogo<Variedad>(
              controlador: _controladorVariedad,
              labelText: SoleraL10n.t('viti.variedad_obligatoria_etiqueta'),
              hintText: 'tempranillo, garnacha, albariño…',
              opcionesCompletas: catalogoVariedades,
              buscar: buscarVariedades,
              displayStringForOption: (v) => v.nombreCanonico,
              validator: (v) => (v ?? '').trim().isEmpty ? SoleraL10n.t('viti.variedad_obligatoria') : null,
            ),
            const SizedBox(height: 12),
            CampoAutocompleteCatalogo<Portainjerto>(
              controlador: _controladorPortainjerto,
              labelText: SoleraL10n.t('viti.portainjerto'),
              hintText: '110-R, SO4, 41-B…',
              opcionesCompletas: catalogoPortainjertos,
              buscar: buscarPortainjertos,
              displayStringForOption: (p) => p.nombreCanonico,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorEtiqueta,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.etiqueta'),
                hintText: SoleraL10n.t('viti.etiqueta_ayuda'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.gps_fixed),
              title: Text(_latitud == null
                  ? SoleraL10n.t('viti.sin_ubicacion')
                  : '${_latitud!.toStringAsFixed(6)}, ${_longitud!.toStringAsFixed(6)}'),
              trailing: _capturandoGps
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : TextButton(
                      onPressed: _capturarGps,
                      child: Text(_latitud == null ? SoleraL10n.t('viti.capturar') : SoleraL10n.t('viti.recapturar')),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: Text(_fechaPlantacion == null
                  ? SoleraL10n.t('viti.sin_fecha_plantacion')
                  : SoleraL10n.tf('viti.plantada_fecha', {'fecha': formatoFecha.format(_fechaPlantacion!)})),
              trailing: TextButton(
                onPressed: _elegirFechaPlantacion,
                child: Text(_fechaPlantacion == null ? SoleraL10n.t('viti.elegir') : SoleraL10n.t('viti.cambiar')),
              ),
            ),
            const SizedBox(height: 8),
            Text(SoleraL10n.t('viti.fotos'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectorFotos(rutas: _rutasFotos, alCambiar: (r) => setState(() => _rutasFotos = r)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorNotas,
              decoration: InputDecoration(
                labelText: SoleraL10n.t('viti.notas'),
                border: const OutlineInputBorder(),
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
              label: Text(widget.esEdicion ? SoleraL10n.t('viti.guardar_cambios') : SoleraL10n.t('viti.guardar_cepa')),
            ),
          ],
        ),
      ),
    );
  }
}
