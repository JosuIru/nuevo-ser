import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/tarea_mantenimiento.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Alta de una tarea de mantenimiento, anclada a una finca y opcionalmente
/// a un punto de infraestructura o a una zona dibujada.
class NuevaTarea extends StatefulWidget {
  const NuevaTarea(
      {super.key, required this.fincaId, this.puntoId, this.zonaId});

  final int fincaId;
  final int? puntoId;
  final int? zonaId;

  @override
  State<NuevaTarea> createState() => _NuevaTareaState();
}

class _NuevaTareaState extends State<NuevaTarea> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _responsable = TextEditingController();
  final _coste = TextEditingController();

  String _prioridad = prioridadTareaPorDefecto;
  String _estado = estadoTareaPorDefecto;
  DateTime? _fechaObjetivo;
  int? _recurrenciaDias;
  List<String> _fotosAntes = const [];
  List<String> _fotosDespues = const [];

  /// Con sesión, el responsable se elige de las personas del espacio
  /// (`''` = sin asignar); en modo local se escribe en [_responsable].
  String _responsableUid = '';

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _responsable.dispose();
    _coste.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaObjetivo ?? ahora,
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 5),
    );
    if (elegida != null) setState(() => _fechaObjetivo = elegida);
  }

  int? _costeCentimos() {
    final texto = _coste.text.trim().replaceAll(',', '.');
    if (texto.isEmpty) return null;
    final euros = double.tryParse(texto);
    if (euros == null) return null;
    return (euros * 100).round();
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    if (_titulo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.tareaTituloObligatorio)));
      return;
    }
    final sesion = sesionEspacio.value;
    final responsableElegido = personasEspacio.value
        .where((persona) => persona.uid == _responsableUid)
        .firstOrNull;
    final tarea = TareaMantenimiento(
      fincaId: widget.fincaId,
      puntoId: widget.puntoId,
      zonaId: widget.zonaId,
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      responsable: sesion == null
          ? _responsable.text.trim()
          : (responsableElegido?.nombre ?? ''),
      responsableUid: responsableElegido?.uid ?? '',
      creadoPorUid: sesion?.persona.uid ?? '',
      prioridad: _prioridad,
      estado: _estado,
      fechaObjetivoMs: _fechaObjetivo?.millisecondsSinceEpoch,
      rutasFotosAntesJson: GestorFotos.codificar(_fotosAntes),
      rutasFotosDespuesJson: GestorFotos.codificar(_fotosDespues),
      costeCentimos: _costeCentimos(),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
      recurrenciaDias: _recurrenciaDias,
    );
    await _bd.guardarTarea(tarea);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.tareaGuardada)));
    Navigator.of(context).pop(true);
  }

  /// En modo local, texto libre. Con sesión, lista de personas del espacio;
  /// sin permiso para asignar a otras, sólo "sin asignar" o una misma.
  Widget _campoResponsable(AppLocalizations textos) {
    final sesion = sesionEspacio.value;
    if (sesion == null) {
      return TextField(
        controller: _responsable,
        decoration: InputDecoration(labelText: textos.tareaResponsable),
      );
    }
    final personasElegibles = politicaTareasActual.puedeAsignarAOtras
        ? personasEspacio.value
        : personasEspacio.value
            .where((persona) => persona.uid == sesion.persona.uid)
            .toList();
    return DropdownButtonFormField<String>(
      initialValue: _responsableUid,
      decoration: InputDecoration(labelText: textos.tareaResponsable),
      items: [
        DropdownMenuItem(value: '', child: Text(textos.tareaSinAsignar)),
        for (final persona in personasElegibles)
          DropdownMenuItem(
            value: persona.uid,
            child: Text(persona.etiquetaRol.isEmpty
                ? persona.nombre
                : '${persona.nombre} · ${persona.etiquetaRol}'),
          ),
      ],
      onChanged: (valor) => setState(() => _responsableUid = valor ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final fecha = _fechaObjetivo == null
        ? textos.tareaSinFecha
        : DateFormat('dd/MM/yyyy', idioma).format(_fechaObjetivo!);
    return Scaffold(
      appBar: AppBar(title: Text(textos.tareaNuevaTitulo)),
      body: CuerpoResponsivo(child: ListView(
        padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
        children: [
          TextField(
            controller: _titulo,
            decoration: InputDecoration(labelText: textos.tareaTitulo),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            maxLines: 3,
            decoration: InputDecoration(labelText: textos.tareaDescripcion),
          ),
          const SizedBox(height: 12),
          _campoResponsable(textos),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _prioridad,
            decoration: InputDecoration(labelText: textos.tareaPrioridad),
            items: [
              for (final p in prioridadesTarea)
                DropdownMenuItem(value: p.codigo, child: Text(p.etiqueta(idioma))),
            ],
            onChanged: (v) => setState(() => _prioridad = v ?? _prioridad),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _estado,
            decoration: InputDecoration(labelText: textos.tareaEstado),
            items: [
              for (final e in estadosTarea)
                DropdownMenuItem(value: e.codigo, child: Text(e.etiqueta(idioma))),
            ],
            onChanged: (v) => setState(() => _estado = v ?? _estado),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: Text(textos.tareaFechaObjetivo),
            subtitle: Text(fecha),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: _elegirFecha,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _recurrenciaDias,
            decoration: InputDecoration(labelText: textos.tareaRecurrencia),
            items: [
              for (final r in recurrenciasTarea)
                DropdownMenuItem(value: r, child: Text(etiquetaRecurrencia(r, idioma))),
            ],
            onChanged: (v) => setState(() => _recurrenciaDias = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _coste,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: textos.tareaCoste),
          ),
          const SizedBox(height: 16),
          Text(textos.tareaFotosAntes,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SelectorFotos(
            rutas: _fotosAntes,
            alCambiar: (n) => setState(() => _fotosAntes = n),
          ),
          const SizedBox(height: 16),
          Text(textos.tareaFotosDespues,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SelectorFotos(
            rutas: _fotosDespues,
            alCambiar: (n) => setState(() => _fotosDespues = n),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save),
            label: Text(textos.comunGuardar),
          ),
        ],
      )),
    );
  }
}
