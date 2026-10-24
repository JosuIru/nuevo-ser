import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'widgets/selector_fotos_app.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/tarea_mantenimiento.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/selector_plantilla_tarea.dart';
import 'widgets/selector_responsables.dart';
import '../utiles/responsables_tarea.dart';
import 'widgets/relleno_seguro.dart';
import '../estado/datos_notificador.dart';

/// Alta de una tarea de mantenimiento, anclada a una finca y opcionalmente
/// a un punto de infraestructura o a una zona dibujada.
///
/// Con [tituloInicial]/[descripcionInicial] llega rellena (p. ej. desde una
/// petición) y con [guardar] se sustituye el guardado normal (aceptar la
/// petición y crear la tarea en una sola operación).
///
/// Con sesión se eligen una o varias responsables; con dos o más se
/// pregunta si es una tarea compartida o una para cada persona (ver
/// [RepartoTarea]). En «una para cada persona» [guardar] recibe la primera
/// y las demás se guardan aparte.
class NuevaTarea extends StatefulWidget {
  const NuevaTarea({
    super.key,
    required this.fincaId,
    this.puntoId,
    this.zonaId,
    this.tituloInicial = '',
    this.descripcionInicial = '',
    this.guardar,
  });

  final int fincaId;
  final int? puntoId;
  final int? zonaId;
  final String tituloInicial;
  final String descripcionInicial;
  final Future<void> Function(TareaMantenimiento tarea)? guardar;

  @override
  State<NuevaTarea> createState() => _NuevaTareaState();
}

class _NuevaTareaState extends State<NuevaTarea> {
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

  /// Con sesión, las responsables se eligen de las personas del espacio
  /// (vacía = tarea general); en modo local se escribe en [_responsable].
  List<String> _responsablesUids = const [];

  /// Tipo del punto al que va la tarea, para sugerir tareas tipo.
  String? _tipoPunto;

  @override
  void initState() {
    super.initState();
    _titulo.text = widget.tituloInicial;
    _descripcion.text = widget.descripcionInicial;
    final puntoId = widget.puntoId;
    if (puntoId != null) {
      _bd.obtenerPunto(puntoId).then((punto) {
        if (mounted && punto != null) setState(() => _tipoPunto = punto.tipo);
      });
    }
  }

  void _aplicarPlantilla(EleccionPlantilla eleccion) {
    final (plantilla, subtipo) = eleccion;
    final idioma = Localizations.localeOf(context).languageCode;
    setState(() {
      _titulo.text = plantilla.titulo(idioma, subtipo);
      _recurrenciaDias = recurrenciasTarea.contains(plantilla.recurrenciaDias)
          ? plantilla.recurrenciaDias
          : null;
    });
  }

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

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    if (_titulo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.tareaTituloObligatorio)));
      return;
    }
    final costeEscrito = _coste.text.trim().isNotEmpty;
    final costeCentimos = costeEscrito ? centimosDesdeTexto(_coste.text) : null;
    if (costeEscrito && (costeCentimos == null || costeCentimos < 0)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.numeroNoValido)));
      return;
    }
    final sesion = sesionEspacio.value;
    final personas = personasEspacio.value;
    final conocidas = {for (final persona in personas) persona.uid};
    final responsables = sesion == null
        ? const <String>[]
        : _responsablesUids.where(conocidas.contains).toList();
    var reparto = RepartoTarea.compartida;
    if (responsables.length >= 2) {
      final elegido = await preguntarRepartoTarea(context, responsables.length);
      if (elegido == null || !mounted) return;
      reparto = elegido;
    }
    final base = TareaMantenimiento(
      fincaId: widget.fincaId,
      puntoId: widget.puntoId,
      zonaId: widget.zonaId,
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      responsable: sesion == null ? _responsable.text.trim() : '',
      creadoPorUid: sesion?.persona.uid ?? '',
      prioridad: _prioridad,
      estado: _estado,
      fechaObjetivoMs: _fechaObjetivo?.millisecondsSinceEpoch,
      rutasFotosAntesJson: GestorFotos.codificar(_fotosAntes),
      rutasFotosDespuesJson: GestorFotos.codificar(_fotosDespues),
      costeCentimos: costeCentimos,
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
      recurrenciaDias: _recurrenciaDias,
    );
    final tareas = sesion == null
        ? [base]
        : tareasDelAlta(base, responsables, personas, reparto);
    final guardar = widget.guardar;
    for (final (indice, tarea) in tareas.indexed) {
      if (guardar != null && indice == 0) {
        await guardar(tarea);
      } else {
        await _bd.guardarTarea(tarea);
      }
    }
    avisarCambioDatos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tareas.length > 1
            ? textos.tareasCreadasUnaPorPersona(tareas.length)
            : textos.tareaGuardada)));
    Navigator.of(context).pop(true);
  }

  /// En modo local, texto libre. Con sesión, casillas con las personas del
  /// espacio; sin permiso para asignar a otras, sólo una misma (o nadie).
  Widget _campoResponsable(AppLocalizations textos) {
    final sesion = sesionEspacio.value;
    if (sesion == null) {
      return TextField(
        controller: _responsable,
        decoration: InputDecoration(labelText: textos.tareaResponsable),
      );
    }
    final puedeAsignarAOtras = politicaTareasActual.puedeAsignarAOtras;
    final personasElegibles = puedeAsignarAOtras
        ? personasEspacio.value
        : personasEspacio.value
            .where((persona) => persona.uid == sesion.persona.uid)
            .toList();
    return SelectorResponsables(
      personas: personasElegibles,
      elegidas: _responsablesUids,
      ayuda: puedeAsignarAOtras ? null : textos.tareaResponsablesSoloTu,
      alCambiar: (elegidas) => setState(() => _responsablesUids = elegidas),
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
      body: CuerpoResponsivo(
          child: ListView(
        padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
        children: [
          BotonPlantillaTarea(
              tipoPunto: _tipoPunto, alElegir: _aplicarPlantilla),
          const SizedBox(height: 12),
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
                DropdownMenuItem(
                    value: p.codigo, child: Text(p.etiqueta(idioma))),
            ],
            onChanged: (v) => setState(() => _prioridad = v ?? _prioridad),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _estado,
            decoration: InputDecoration(labelText: textos.tareaEstado),
            items: [
              for (final e in estadosTarea)
                DropdownMenuItem(
                    value: e.codigo, child: Text(e.etiqueta(idioma))),
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
            // Cambia al elegir una tarea tipo: la clave lo redibuja.
            key: ValueKey(_recurrenciaDias),
            initialValue: _recurrenciaDias,
            decoration: InputDecoration(labelText: textos.tareaRecurrencia),
            items: [
              for (final r in recurrenciasTarea)
                DropdownMenuItem(
                    value: r, child: Text(etiquetaRecurrencia(r, idioma))),
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
          SelectorFotosApp(
            rutas: _fotosAntes,
            alCambiar: (n) => setState(() => _fotosAntes = n),
          ),
          const SizedBox(height: 16),
          Text(textos.tareaFotosDespues,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SelectorFotosApp(
            rutas: _fotosDespues,
            alCambiar: (n) => setState(() => _fotosDespues = n),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _guardando ? null : _guardarUnaVez,
            icon: const Icon(Icons.save),
            label: Text(textos.comunGuardar),
          ),
        ],
      )),
    );
  }
}
