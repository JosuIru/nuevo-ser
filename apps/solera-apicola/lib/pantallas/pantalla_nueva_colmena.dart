import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_razas_abeja.dart';
import '../datos/catalogos_generados/catalogo_tipos_colmena.dart';
import '../modelos/colmena.dart';
import '../utiles/permisos_gps.dart';

/// Alta o edición de colmena. Modo alta: `colmenaExistente == null`.
///
/// Versión minimalista v0.1: matrícula, tipo y raza son free-text.
/// Cuando entren los catálogos curados (F1A-4) se sustituyen por
/// Autocomplete validado.
class PantallaNuevaColmena extends StatefulWidget {
  final Colmena? colmenaExistente;
  final int? apiarioIdInicial;
  final double? latitudInicial;
  final double? longitudInicial;

  const PantallaNuevaColmena({
    super.key,
    this.colmenaExistente,
    this.apiarioIdInicial,
    this.latitudInicial,
    this.longitudInicial,
  });

  bool get esEdicion => colmenaExistente != null;

  @override
  State<PantallaNuevaColmena> createState() => _PantallaNuevaColmenaState();
}

class _PantallaNuevaColmenaState extends State<PantallaNuevaColmena> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorMatricula = TextEditingController();
  final _controladorTipo = TextEditingController();
  final _controladorRaza = TextEditingController();
  final _controladorAnoReina = TextEditingController();
  final _controladorNotas = TextEditingController();
  EstadoColmena _estado = EstadoColmena.viva;
  double? _latitud;
  double? _longitud;
  DateTime? _fechaAlta;
  List<String> _rutasFotos = [];
  bool _capturandoGps = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final existente = widget.colmenaExistente;
    if (existente != null) {
      _controladorMatricula.text = existente.matricula;
      // Si el id está en catálogo, mostrar el nombre canónico para que el
      // usuario lea "Abeja ibérica" en vez del id "iberica". Si es texto
      // libre legacy, se muestra tal cual.
      final tipoCanonico = tipoColmenaPorId(existente.tipoColmenaId);
      _controladorTipo.text = tipoCanonico?.nombreCanonico ?? existente.tipoColmenaId;
      final razaCanonica = razaAbejaPorId(existente.razaId);
      _controladorRaza.text = razaCanonica?.nombreCanonico ?? existente.razaId;
      _controladorAnoReina.text = existente.anoReina?.toString() ?? '';
      _controladorNotas.text = existente.notas;
      _estado = existente.estado;
      _latitud = existente.ultimaLatitud;
      _longitud = existente.ultimaLongitud;
      if (existente.fechaAltaMs != null) {
        _fechaAlta = DateTime.fromMillisecondsSinceEpoch(existente.fechaAltaMs!);
      }
      _rutasFotos = GestorFotos.decodificar(existente.rutasFotosJson);
    } else {
      _latitud = widget.latitudInicial;
      _longitud = widget.longitudInicial;
      _fechaAlta = DateTime.now();
      if (_latitud == null || _longitud == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _capturarGps());
      }
    }
  }

  @override
  void dispose() {
    _controladorMatricula.dispose();
    _controladorTipo.dispose();
    _controladorRaza.dispose();
    _controladorAnoReina.dispose();
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

  Future<void> _elegirFechaAlta() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaAlta ?? hoy,
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (fecha != null) setState(() => _fechaAlta = fecha);
  }

  /// Resuelve el id estable del catálogo a partir del texto del campo:
  /// si coincide con un nombre canónico (case-insensitive) devuelve el
  /// id; si no, devuelve el texto crudo en minúsculas para preservar
  /// entrada libre cuando el catálogo aún no cubre el caso.
  String _resolverIdTipoColmena(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return '';
    for (final tipo in catalogoTiposColmena) {
      if (tipo.id == consultaNormalizada) return tipo.id;
      if (tipo.nombreCanonico.toLowerCase() == consultaNormalizada) return tipo.id;
    }
    return consultaNormalizada;
  }

  String _resolverIdRaza(String texto) {
    final consultaNormalizada = texto.trim().toLowerCase();
    if (consultaNormalizada.isEmpty) return '';
    for (final raza in catalogoRazasAbeja) {
      if (raza.id == consultaNormalizada) return raza.id;
      if (raza.nombreCanonico.toLowerCase() == consultaNormalizada) return raza.id;
    }
    return consultaNormalizada;
  }

  Future<void> _guardar() async {
    if (!(_claveFormulario.currentState?.validate() ?? false)) return;
    setState(() => _guardando = true);
    final db = BaseDatosSoleraApicola.instancia;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    final fotosJson = GestorFotos.codificar(_rutasFotos);
    final anoReina = int.tryParse(_controladorAnoReina.text.trim());
    final idTipoColmena = _resolverIdTipoColmena(_controladorTipo.text);
    final idRaza = _resolverIdRaza(_controladorRaza.text);

    if (widget.esEdicion) {
      final id = widget.colmenaExistente!.id!;
      await db.actualizarColmena(id, {
        'matricula': _controladorMatricula.text.trim(),
        'tipo_colmena_id': idTipoColmena,
        'raza_id': idRaza,
        'ano_reina': anoReina,
        'estado': _estadoString(_estado),
        'ultima_latitud': _latitud,
        'ultima_longitud': _longitud,
        'fecha_alta_ms': _fechaAlta?.millisecondsSinceEpoch,
        'notas': _controladorNotas.text.trim(),
        'rutas_fotos_json': fotosJson,
      });
    } else {
      final existente = await db.obtenerColmenaPorMatricula(_controladorMatricula.text.trim());
      if (existente != null) {
        if (!mounted) return;
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya existe una colmena con matrícula ${existente.matricula}.')),
        );
        return;
      }
      await db.guardarColmena(Colmena(
        apiarioId: widget.apiarioIdInicial,
        matricula: _controladorMatricula.text.trim(),
        tipoColmenaId: idTipoColmena,
        razaId: idRaza,
        anoReina: anoReina,
        estado: _estado,
        ultimaLatitud: _latitud,
        ultimaLongitud: _longitud,
        fechaAltaMs: _fechaAlta?.millisecondsSinceEpoch,
        notas: _controladorNotas.text.trim(),
        rutasFotosJson: fotosJson,
        fechaCreacionMs: ahora,
      ));
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  String _estadoString(EstadoColmena e) {
    switch (e) {
      case EstadoColmena.viva:
        return 'viva';
      case EstadoColmena.vacia:
        return 'vacia';
      case EstadoColmena.descolmenada:
        return 'descolmenada';
      case EstadoColmena.enjambreNuevo:
        return 'enjambre_nuevo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: Text(widget.esEdicion ? 'Editar colmena' : 'Nueva colmena')),
      body: Form(
        key: _claveFormulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _controladorMatricula,
              decoration: const InputDecoration(
                labelText: 'Matrícula *',
                hintText: 'IB-2024-042',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Matrícula obligatoria' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            CampoAutocompleteCatalogo<TipoColmena>(
              controlador: _controladorTipo,
              labelText: 'Tipo de colmena',
              hintText: 'Layens, Dadant, Langstroth, Warré…',
              opcionesCompletas: catalogoTiposColmena,
              buscar: buscarTiposColmena,
              displayStringForOption: (t) => t.nombreCanonico,
            ),
            const SizedBox(height: 12),
            CampoAutocompleteCatalogo<RazaAbeja>(
              controlador: _controladorRaza,
              labelText: 'Raza',
              hintText: 'ibérica, cárnica, ligústica, buckfast…',
              opcionesCompletas: catalogoRazasAbeja,
              buscar: buscarRazasAbeja,
              displayStringForOption: (r) => r.nombreCanonico,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controladorAnoReina,
              decoration: const InputDecoration(
                labelText: 'Año de la reina',
                hintText: '2024 (marca: verde)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EstadoColmena>(
              initialValue: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: EstadoColmena.viva, child: Text('Viva')),
                DropdownMenuItem(value: EstadoColmena.vacia, child: Text('Vacía')),
                DropdownMenuItem(value: EstadoColmena.descolmenada, child: Text('Descolmenada')),
                DropdownMenuItem(value: EstadoColmena.enjambreNuevo, child: Text('Enjambre nuevo')),
              ],
              onChanged: (v) => setState(() => _estado = v ?? EstadoColmena.viva),
            ),
            const SizedBox(height: 12),
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
              title: Text(_fechaAlta == null
                  ? 'Sin fecha de alta'
                  : 'Alta ${formatoFecha.format(_fechaAlta!)}'),
              trailing: TextButton(
                onPressed: _elegirFechaAlta,
                child: Text(_fechaAlta == null ? 'Elegir' : 'Cambiar'),
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
              label: Text(widget.esEdicion ? 'Guardar cambios' : 'Guardar colmena'),
            ),
          ],
        ),
      ),
    );
  }
}
