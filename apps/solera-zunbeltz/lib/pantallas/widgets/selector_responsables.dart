import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../modelos/persona_espacio.dart';
import '../../utiles/responsables_tarea.dart';

/// Elección de una o varias responsables entre las personas del espacio,
/// con una casilla (chip) por persona. Sin ninguna marcada, la tarea es
/// general. Quien no puede asignar a otras recibe en [personas] solo a sí
/// misma.
class SelectorResponsables extends StatelessWidget {
  const SelectorResponsables({
    super.key,
    required this.personas,
    required this.elegidas,
    required this.alCambiar,
    this.ayuda,
  });

  final List<PersonaEspacio> personas;

  /// uids elegidos, en el orden en que se eligieron (la primera es la que
  /// ven las apps antiguas).
  final List<String> elegidas;
  final ValueChanged<List<String>> alCambiar;

  /// Texto bajo las casillas; por defecto, qué pasa sin elegir a nadie.
  final String? ayuda;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    // Una responsable que ya no está entre las personas (desactivada) se
    // enseña igual, para poder quitarla o dejarla a sabiendas.
    final conocidas = {for (final persona in personas) persona.uid};
    final todas = [
      ...personas,
      for (final uid in elegidas)
        if (!conocidas.contains(uid)) PersonaEspacio(uid: uid, nombre: uid),
    ];
    return InputDecorator(
      decoration: InputDecoration(
        labelText: textos.tareaResponsables,
        helperText: ayuda ?? textos.tareaResponsablesAyudaGeneral,
        helperMaxLines: 3,
      ),
      child: todas.isEmpty
          ? Text(textos.tareaSinAsignar)
          : Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final persona in todas)
                  FilterChip(
                    key: ValueKey('responsable-${persona.uid}'),
                    label: Text(persona.nombre),
                    tooltip: persona.etiquetaRol.isEmpty
                        ? null
                        : persona.etiquetaRol,
                    selected: elegidas.contains(persona.uid),
                    onSelected: (marcada) => alCambiar(marcada
                        ? [...elegidas, persona.uid]
                        : elegidas.where((uid) => uid != persona.uid).toList()),
                  ),
              ],
            ),
    );
  }
}

/// Al dar de alta una tarea con dos o más responsables: ¿una compartida o
/// una para cada persona? `null` si se cancela (se vuelve al formulario).
Future<RepartoTarea?> preguntarRepartoTarea(
    BuildContext context, int numeroPersonas) {
  final textos = AppLocalizations.of(context);
  return showDialog<RepartoTarea>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(textos.tareaRepartoTitulo(numeroPersonas)),
      contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(textos.tareaRepartoPregunta),
            ),
            const SizedBox(height: 8),
            ListTile(
              key: const ValueKey('reparto-compartida'),
              leading: const Icon(Icons.groups_outlined),
              title: Text(textos.tareaRepartoCompartida),
              subtitle: Text(textos.tareaRepartoCompartidaDetalle),
              onTap: () => Navigator.pop(contexto, RepartoTarea.compartida),
            ),
            ListTile(
              key: const ValueKey('reparto-una-para-cada'),
              leading: const Icon(Icons.call_split),
              title: Text(textos.tareaRepartoCadaPersona),
              subtitle:
                  Text(textos.tareaRepartoCadaPersonaDetalle(numeroPersonas)),
              onTap: () => Navigator.pop(contexto, RepartoTarea.unaParaCada),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto),
            child: Text(textos.comunCancelar)),
      ],
    ),
  );
}
