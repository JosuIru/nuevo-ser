import 'package:flutter/foundation.dart' show kIsWeb, listEquals;
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show GestorFotos;

import '../../datos/base_datos.dart';
import '../../estado/sesion_espacio.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/apunte_economico.dart';
import '../../modelos/constantes.dart';
import '../../modelos/persona_espacio.dart';
import '../../modelos/plantillas_tarea.dart';
import '../../modelos/proyecto_test.dart';
import '../../modelos/tarea_mantenimiento.dart';
import '../../utiles/estilos_tarea.dart';
import '../../estado/datos_notificador.dart';
import '../nuevo_apunte.dart';
import 'fotos_sincronizadas.dart';
import 'selector_fotos_app.dart';
import 'selector_responsables.dart';
import '../../utiles/responsables_tarea.dart';

enum _AccionTarea {
  asignarme,
  soltar,
  cambiarResponsables,
  apuntarGasto,
  fotosDespues,
}

/// Hoja con lo que la persona conectada puede hacer con una tarea según su
/// rol (ver `PoliticaTareas`): cambiar el estado, cogérsela, soltarla o
/// (coordinación) cambiar sus responsables.
/// Devuelve `true` si ha cambiado algo, para que la pantalla recargue.
Future<bool> mostrarAccionesTarea(
    BuildContext context, TareaMantenimiento tarea) async {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  final politica = politicaTareasActual;
  final puedeEjecutar = politica.puedeEjecutar(tarea);
  final puedeCogerse = politica.puedeCogerse(tarea);
  final puedeSoltar = politica.puedeSoltar(tarea);
  final puedeCambiarResponsables = politica.puedeCambiarResponsables(tarea);
  final id = tarea.id;
  // Una compra con coste se puede llevar a las cuentas de un proyecto.
  final puedeApuntarGasto = (tarea.costeCentimos ?? 0) > 0 &&
      politicaEspacioActual.puedeGestionarProyectos;

  // Sin nada que hacer con ella, la hoja solo sale si hay fotos que ver.
  final tieneFotos =
      GestorFotos.decodificar(tarea.rutasFotosAntesJson).isNotEmpty ||
          GestorFotos.decodificar(tarea.rutasFotosDespuesJson).isNotEmpty;
  if (id == null ||
      !(puedeEjecutar ||
          puedeCogerse ||
          puedeSoltar ||
          puedeCambiarResponsables ||
          puedeApuntarGasto ||
          tieneFotos)) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.tareaSinPermiso)));
    return false;
  }

  final eleccion = await showModalBottomSheet<Object>(
    useSafeArea: true,
    context: context,
    showDragHandle: true,
    builder: (contextoHoja) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(tarea.titulo,
                style: Theme.of(contextoHoja).textTheme.titleMedium),
          ),
          GaleriaFotos(
              titulo: textos.tareaFotosAntes,
              entradas: GestorFotos.decodificar(tarea.rutasFotosAntesJson)),
          GaleriaFotos(
              titulo: textos.tareaFotosDespues,
              entradas: GestorFotos.decodificar(tarea.rutasFotosDespuesJson)),
          if (puedeEjecutar) ...[
            ListTile(
              dense: true,
              title: Text(textos.tareaCambiarEstado,
                  style: Theme.of(contextoHoja).textTheme.labelLarge),
            ),
            for (final estado in estadosTarea)
              ListTile(
                leading:
                    Icon(Icons.circle, color: colorEstadoTarea(estado.codigo)),
                title: Text(estado.etiqueta(idioma)),
                trailing: estado.codigo == tarea.estado
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(contextoHoja, estado.codigo),
              ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.add_a_photo_outlined),
                title: Text(textos.tareaAnadirFotosDespues),
                onTap: () =>
                    Navigator.pop(contextoHoja, _AccionTarea.fotosDespues),
              ),
            const Divider(),
          ],
          if (puedeCogerse)
            ListTile(
              leading: const Icon(Icons.pan_tool_outlined),
              title: Text(textos.tareaAsignarme),
              onTap: () => Navigator.pop(contextoHoja, _AccionTarea.asignarme),
            ),
          if (puedeSoltar)
            ListTile(
              leading: const Icon(Icons.person_remove_outlined),
              title: Text(textos.tareaSoltar),
              onTap: () => Navigator.pop(contextoHoja, _AccionTarea.soltar),
            ),
          if (puedeCambiarResponsables)
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: Text(textos.tareaCambiarResponsables),
              subtitle: tarea.responsable.isEmpty
                  ? null
                  : Text(tarea.responsable),
              onTap: () => Navigator.pop(
                  contextoHoja, _AccionTarea.cambiarResponsables),
            ),
          if (puedeApuntarGasto)
            ListTile(
              leading: const Icon(Icons.euro_outlined),
              title: Text(textos.tareaApuntarGasto),
              onTap: () =>
                  Navigator.pop(contextoHoja, _AccionTarea.apuntarGasto),
            ),
        ],
      ),
    ),
  );

  final bd = BaseDatosSoleraZunbeltz();
  final persona = sesionEspacio.value?.persona;
  switch (eleccion) {
    case 'hecha':
      if (tarea.estado == 'hecha') return false;
      // Pasa por marcarTareaHecha para generar la siguiente si es periódica.
      await bd.marcarTareaHecha(id);
      avisarCambioDatos();
      // Al cerrarla, la foto de cómo ha quedado (se puede decir que no).
      if (context.mounted) {
        await _anadirFotosDespues(context, id,
            pregunta: textos.tareaPreguntaFotoDespues);
      }
      return true;
    case String estado:
      if (estado == tarea.estado) return false;
      await bd.actualizarTarea(id, {'estado': estado});
      avisarCambioDatos();
      return true;
    case _AccionTarea.asignarme when persona != null:
      // Se suma a la lista (en una general, queda ella sola).
      await bd.actualizarTarea(
          id,
          columnasResponsables(politica.responsablesAlCogerse(tarea),
              _personasConmigo(persona)));
      avisarCambioDatos();
      return true;
    case _AccionTarea.soltar:
      // Sale solo ella; en una compartida las demás siguen.
      await bd.actualizarTarea(
          id,
          columnasResponsables(
              politica.responsablesAlSoltar(tarea), personasEspacio.value));
      avisarCambioDatos();
      return true;
    case _AccionTarea.cambiarResponsables:
      if (!context.mounted) return false;
      return _cambiarResponsables(context, tarea, id);
    case _AccionTarea.fotosDespues:
      return context.mounted && await _anadirFotosDespues(context, id);
    case _AccionTarea.apuntarGasto:
      if (context.mounted) await _apuntarComoGasto(context, tarea);
      return false;
  }
  return false;
}

/// Hace o elige fotos y las suma a las «después» de la tarea. `true` si
/// se añadió alguna.
Future<bool> _anadirFotosDespues(BuildContext context, int id,
    {String? pregunta}) async {
  final textos = AppLocalizations.of(context);
  final nuevas = await pedirFotos(context, pregunta: pregunta);
  if (nuevas.isEmpty) return false;
  await BaseDatosSoleraZunbeltz().anadirFotosDespuesTarea(id, nuevas);
  avisarCambioDatos();
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.tareaFotosAnadidas)));
  }
  return true;
}

/// Lleva el coste de la tarea a las cuentas de un proyecto abierto, con
/// el bloque y la partida de la tarea tipo si salió de una compra.
Future<void> _apuntarComoGasto(
    BuildContext context, TareaMantenimiento tarea) async {
  final textos = AppLocalizations.of(context);
  final proyectos = (await BaseDatosSoleraZunbeltz().listarProyectos())
      .where((proyecto) => !proyecto.cerrado && proyecto.id != null)
      .toList();
  if (!context.mounted) return;
  if (proyectos.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.tareaSinProyectosAbiertos)));
    return;
  }
  final proyecto = await showDialog<ProyectoTest>(
    context: context,
    builder: (contexto) => SimpleDialog(
      title: Text(textos.tareaElegirProyecto),
      children: [
        for (final proyecto in proyectos)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(contexto, proyecto),
            child: Text(proyecto.persona.isEmpty
                ? proyecto.nombre
                : '${proyecto.nombre} · ${proyecto.persona}'),
          ),
      ],
    ),
  );
  if (proyecto == null || !context.mounted) return;
  final (bloque, partida) = gastoSugeridoParaTarea(tarea.titulo);
  await Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => NuevoApunte(
      proyectoId: proyecto.id!,
      fincaId: proyecto.fincaId ?? tarea.fincaId,
      gastoInicial: ApunteEconomico(
        fincaId: proyecto.fincaId ?? tarea.fincaId,
        tipo: 'gasto',
        categoria: bloque,
        partida: partida,
        concepto: tarea.titulo,
        importeCentimos: tarea.costeCentimos ?? 0,
        fechaMs: tarea.actualizadoMs,
      ),
    ),
  ));
}

/// Las personas del espacio con la de la sesión aunque la lista aún no
/// haya llegado, para poner bien su nombre.
List<PersonaEspacio> _personasConmigo(PersonaEspacio persona) => [
      ...personasEspacio.value.where((otra) => otra.uid != persona.uid),
      persona,
    ];

/// Coordinación cambia a quién está asignada una tarea que ya existe. Con
/// varias personas queda compartida (no se trocea). `true` si cambió.
Future<bool> _cambiarResponsables(
    BuildContext context, TareaMantenimiento tarea, int id) async {
  final textos = AppLocalizations.of(context);
  var elegidas = tarea.uidsResponsables;
  final guardar = await showDialog<bool>(
    context: context,
    builder: (contexto) => StatefulBuilder(
      builder: (contexto, cambiarEstado) => AlertDialog(
        title: Text(textos.tareaCambiarResponsables),
        content: SingleChildScrollView(
          child: SelectorResponsables(
            personas: personasEspacio.value,
            elegidas: elegidas,
            ayuda: textos.tareaCambiarResponsablesAyuda,
            alCambiar: (nuevas) => cambiarEstado(() => elegidas = nuevas),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(textos.comunCancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(textos.comunGuardar)),
        ],
      ),
    ),
  );
  if (guardar != true ||
      listEquals(elegidas, tarea.uidsResponsables) ||
      !context.mounted) {
    return false;
  }
  await BaseDatosSoleraZunbeltz().actualizarTarea(
      id, columnasResponsables(elegidas, personasEspacio.value));
  avisarCambioDatos();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.tareaResponsablesCambiadas)));
  }
  return true;
}
