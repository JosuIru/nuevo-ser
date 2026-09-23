import 'package:flutter/material.dart';

import '../../datos/base_datos.dart';
import '../../estado/sesion_espacio.dart';
import '../../l10n/app_localizations.dart';
import '../../modelos/constantes.dart';
import '../../modelos/tarea_mantenimiento.dart';
import '../../utiles/estilos_tarea.dart';

enum _AccionTarea { asignarme, soltar }

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

  if (id == null || !(puedeEjecutar || puedeCogerse || puedeSoltar)) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.tareaSinPermiso)));
    return false;
  }

  final eleccion = await showModalBottomSheet<Object>(
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
          if (puedeEjecutar) ...[
            ListTile(
              dense: true,
              title: Text(textos.tareaCambiarEstado,
                  style: Theme.of(contextoHoja).textTheme.labelLarge),
            ),
            for (final estado in estadosTarea)
              ListTile(
                leading: Icon(Icons.circle, color: colorEstadoTarea(estado.codigo)),
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
      return true;
    case String estado:
      if (estado == tarea.estado) return false;
      await bd.actualizarTarea(id, {'estado': estado});
      return true;
    case _AccionTarea.asignarme when persona != null:
      await bd.actualizarTarea(
          id, {'responsable_uid': persona.uid, 'responsable': persona.nombre});
      return true;
    case _AccionTarea.soltar:
      await bd.actualizarTarea(id, {'responsable_uid': '', 'responsable': ''});
      return true;
  }
  return false;
}
