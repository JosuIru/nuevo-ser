import 'dart:convert' show jsonEncode;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/tarea_mantenimiento.dart' show unirNombresResponsables;
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';
import 'widgets/selector_responsables.dart';

/// Alta o edición (con [proyecto]) de un proyecto de test: la persona
/// tester y su proceso. Con sincronización, la persona se elige entre las
/// del espacio (su `uid` decide quién ve el proyecto).
class NuevoProyecto extends StatefulWidget {
  const NuevoProyecto({super.key, required this.fincas, this.proyecto});

  final List<Finca> fincas;
  final ProyectoTest? proyecto;

  @override
  State<NuevoProyecto> createState() => _NuevoProyectoState();
}

class _NuevoProyectoState extends State<NuevoProyecto> {
  /// Un doble toque en Guardar no debe guardar dos veces.
  bool _guardando = false;

  Future<void> _guardarUnaVez() async {
    if (_guardando) return;
    setState(() => _guardando = true);
    try {
      await _guardar();
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  final _bd = BaseDatosSoleraZunbeltz();
  final _nombre = TextEditingController();
  final _persona = TextEditingController();
  final _actividad = TextEditingController();
  final _notas = TextEditingController();
  int? _fincaId;
  DateTime? _inicio;

  /// Personas tester elegidas, en el orden en que se marcaron.
  List<String> _personasUids = const [];
  String _especie = '';

  @override
  void initState() {
    super.initState();
    final proyecto = widget.proyecto;
    if (proyecto == null) return;
    _nombre.text = proyecto.nombre;
    _persona.text = proyecto.persona;
    _actividad.text = proyecto.actividad;
    _especie = proyecto.especie;
    _notas.text = proyecto.notas;
    _fincaId = proyecto.fincaId;
    _personasUids = proyecto.uidsTester;
    if (proyecto.fechaInicioMs != null) {
      _inicio = DateTime.fromMillisecondsSinceEpoch(proyecto.fechaInicioMs!);
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _persona.dispose();
    _actividad.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirInicio() async {
    final ahora = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _inicio ?? ahora,
      firstDate: DateTime(ahora.year - 3),
      lastDate: DateTime(ahora.year + 3),
    );
    if (d != null) setState(() => _inicio = d);
  }

  /// Lo que va en `persona`: con sincronización, los nombres de las
  /// elegidas («Ane, Mikel»; si una ya no está en el espacio, el nombre que
  /// tenía el proyecto); sin ella, lo escrito a mano.
  String _nombrePersonas() {
    if (personasEspacio.value.isEmpty) return _persona.text.trim();
    final nombrePorUid = {
      for (final persona in personasEspacio.value) persona.uid: persona.nombre
    };
    final desconocidas =
        _personasUids.where((uid) => !nombrePorUid.containsKey(uid));
    if (desconocidas.isNotEmpty && _personasUids.length == 1) {
      return _persona.text.trim();
    }
    return unirNombresResponsables(
        [for (final uid in _personasUids) nombrePorUid[uid] ?? uid]);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.proyectoNombreObligatorio)));
      return;
    }
    final existente = widget.proyecto;
    if (existente?.id != null) {
      await _bd.actualizarProyecto(existente!.id!, {
        'nombre': _nombre.text.trim(),
        'persona': _nombrePersonas(),
        'persona_uid': _personasUids.firstOrNull ?? '',
        'personas_uids': jsonEncode(_personasUids),
        'actividad': _actividad.text.trim(),
        'especie': _especie,
        'finca_id': _fincaId,
        'fecha_inicio_ms': _inicio?.millisecondsSinceEpoch,
        'notas': _notas.text.trim(),
      });
    } else {
      await _bd.guardarProyecto(ProyectoTest(
        nombre: _nombre.text.trim(),
        persona: _nombrePersonas(),
        personaUid: _personasUids.firstOrNull ?? '',
        personasUids: _personasUids,
        actividad: _actividad.text.trim(),
        especie: _especie,
        fincaId: _fincaId,
        fechaInicioMs: _inicio?.millisecondsSinceEpoch,
        notas: _notas.text.trim(),
        fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.proyectoGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.proyecto == null
              ? textos.proyectoNuevo
              : textos.proyectoEditar)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
                controller: _nombre,
                decoration: InputDecoration(labelText: textos.proyectoNombre)),
            const SizedBox(height: 12),
            if (personasEspacio.value.isEmpty)
              TextField(
                  controller: _persona,
                  decoration:
                      InputDecoration(labelText: textos.proyectoPersona))
            else
              SelectorResponsables(
                // Solo quien puede ser tester (coordinación ve todos los
                // proyectos igualmente); las ya elegidas salen siempre.
                personas: [
                  for (final persona in personasEspacio.value)
                    if (persona.rol != 'coordinador' ||
                        _personasUids.contains(persona.uid))
                      persona,
                ],
                elegidas: _personasUids,
                etiqueta: textos.proyectoPersonasTester,
                ayuda: textos.proyectoPersonasTesterAyuda,
                alCambiar: (uids) => setState(() => _personasUids = uids),
              ),
            const SizedBox(height: 12),
            TextField(
                controller: _actividad,
                decoration: InputDecoration(
                    labelText: textos.proyectoActividad,
                    hintText: textos.proyectoActividadEjemplo)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: buscarOpcion(especiesGanado, _especie) == null
                  ? ''
                  : _especie,
              decoration: InputDecoration(labelText: textos.proyectoEspecie),
              items: [
                const DropdownMenuItem(value: '', child: Text('—')),
                for (final especie in especiesGanado)
                  DropdownMenuItem(
                      value: especie.codigo,
                      child: Text(especie.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _especie = valor ?? ''),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              // Una finca que ya no está (borrada al sincronizar) no puede
              // ser el valor inicial.
              initialValue: widget.fincas.any((finca) => finca.id == _fincaId)
                  ? _fincaId
                  : null,
              decoration: InputDecoration(labelText: textos.proyectoFinca),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(textos.proyectoSinFinca)),
                for (final f in widget.fincas)
                  DropdownMenuItem(value: f.id, child: Text(f.nombre)),
              ],
              onChanged: (v) => setState(() => _fincaId = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(textos.proyectoFechaInicio),
              subtitle: Text(_inicio == null
                  ? '—'
                  : DateFormat('dd/MM/yyyy', idioma).format(_inicio!)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _elegirInicio,
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 2,
                decoration: InputDecoration(labelText: textos.apuNotas)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardarUnaVez,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
