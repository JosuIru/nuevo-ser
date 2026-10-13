import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../modelos/constantes.dart';
import '../../modelos/plantillas_tarea.dart';

/// Tarea tipo elegida, con su variante si la tiene.
typedef EleccionPlantilla = (PlantillaTarea, SubtipoTarea?);

/// Botón «Elegir una tarea tipo» que abre la lista de [plantillasTarea].
class BotonPlantillaTarea extends StatelessWidget {
  const BotonPlantillaTarea({
    super.key,
    required this.alElegir,
    this.tipoPunto,
  });

  final ValueChanged<EleccionPlantilla> alElegir;

  /// Si la tarea va a un punto, las tareas tipo que le encajan van arriba.
  final String? tipoPunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.list_alt_outlined),
        label: Text(textos.plantillaElegir),
        onPressed: () async {
          final eleccion =
              await elegirPlantillaTarea(context, tipoPunto: tipoPunto);
          if (eleccion != null) alElegir(eleccion);
        },
      ),
    );
  }
}

Future<EleccionPlantilla?> elegirPlantillaTarea(BuildContext context,
    {String? tipoPunto}) {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  final sugeridas = tipoPunto == null
      ? const <PlantillaTarea>[]
      : plantillasTarea.where((p) => p.encajaCon(tipoPunto)).toList();

  Widget fila(BuildContext contextoHoja, PlantillaTarea plantilla) {
    final tipo = buscarOpcion(tiposPlantillaTarea, plantilla.tipo)
            ?.etiqueta(idioma) ??
        plantilla.tipo;
    final periodicidad = plantilla.recurrenciaDias == null
        ? tipo
        : '$tipo · ${etiquetaRecurrencia(plantilla.recurrenciaDias, idioma)}';
    if (plantilla.subtipos.isEmpty) {
      return ListTile(
        title: Text(plantilla.etiqueta(idioma)),
        subtitle: Text(periodicidad),
        onTap: () => Navigator.pop(contextoHoja, (plantilla, null)),
      );
    }
    return ExpansionTile(
      title: Text(plantilla.etiqueta(idioma)),
      subtitle: Text(periodicidad),
      children: [
        for (final subtipo in plantilla.subtipos)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 32, right: 16),
            title: Text(idioma == 'eu' ? subtipo.eu : subtipo.es),
            onTap: () => Navigator.pop(contextoHoja, (plantilla, subtipo)),
          ),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 32, right: 16),
          title: Text(textos.plantillaOtra),
          onTap: () => Navigator.pop(contextoHoja, (plantilla, null)),
        ),
      ],
    );
  }

  Widget cabecera(BuildContext contextoHoja, String texto) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(texto, style: Theme.of(contextoHoja).textTheme.titleSmall),
      );

  return showModalBottomSheet<EleccionPlantilla>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (contextoHoja) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (contextoHoja, desplazamiento) => ListView(
        controller: desplazamiento,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(textos.plantillaAviso,
                style: Theme.of(contextoHoja).textTheme.bodySmall),
          ),
          if (sugeridas.isNotEmpty) ...[
            cabecera(contextoHoja, textos.plantillaParaEstePunto),
            for (final plantilla in sugeridas) fila(contextoHoja, plantilla),
          ],
          for (final grupo in gruposPlantillaTarea) ...[
            cabecera(contextoHoja, grupo.etiqueta(idioma)),
            for (final plantilla
                in plantillasTarea.where((p) => p.grupo == grupo.codigo))
              fila(contextoHoja, plantilla),
          ],
        ],
      ),
    ),
  );
}
