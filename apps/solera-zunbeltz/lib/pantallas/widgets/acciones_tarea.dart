import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show GestorFotos;

import '../../datos/base_datos.dart';
import '../../estado/sesion_espacio.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/apunte_economico.dart';
import '../../modelos/constantes.dart';
import '../../modelos/plantillas_tarea.dart';
import '../../modelos/proyecto_test.dart';
import '../../modelos/tarea_mantenimiento.dart';
import '../../utiles/estilos_tarea.dart';
import '../../estado/datos_notificador.dart';
import '../nuevo_apunte.dart';
import 'fotos_sincronizadas.dart';

enum _AccionTarea { asignarme, soltar, apuntarGasto }

/// Hoja con lo que la persona conectada puede hacer con una tarea según su
/// rol (ver `PoliticaTareas`): cambiar el estado, cogérsela o soltarla.
/// Devuelve `true` si ha cambiado algo, para que la pantalla recargue.
Future<bool> mostrarAccionesTarea(
    BuildContext context, TareaMantenimiento tarea) async {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  final politica = politicaTareasActual;
  final puedeEjecutar = politica.puedeEjecutar(tarea);
  final puedeCogerse = politica.puedeCogerse(tarea);
  final puedeSoltar = politica.puedeSoltar(tarea);
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
      return true;
    case String estado:
      if (estado == tarea.estado) return false;
      await bd.actualizarTarea(id, {'estado': estado});
      avisarCambioDatos();
      return true;
    case _AccionTarea.asignarme when persona != null:
      await bd.actualizarTarea(
          id, {'responsable_uid': persona.uid, 'responsable': persona.nombre});
      avisarCambioDatos();
      return true;
    case _AccionTarea.soltar:
      await bd.actualizarTarea(id, {'responsable_uid': '', 'responsable': ''});
      avisarCambioDatos();
      return true;
    case _AccionTarea.apuntarGasto:
      if (context.mounted) await _apuntarComoGasto(context, tarea);
      return false;
  }
  return false;
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
