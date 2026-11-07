import 'package:flutter/material.dart';

import '../dominio/tarea.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
import 'textos_dominio.dart';

/// Una tarea en común: cuándo, dónde, qué hay que hacer y quién va. Cada
/// cual se apunta o se borra hasta que empieza; la mesa apunta a quien se
/// lo pide de palabra, la anula o, desde ese día, la da por hecha.
class FichaTarea extends StatelessWidget {
  const FichaTarea({super.key, required this.estado, required this.tareaUid});

  final EstadoConcejo estado;
  final String tareaUid;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final tarea = estado.tarea(tareaUid);
        final ahora = estado.ahora;
        final colores = Theme.of(context).colorScheme;
        final abierta =
            !tarea.anulada && !tarea.estaHecha && !tarea.empezadaEn(ahora);
        final mesa = estado.soyMesa;
        final yo = estado.personaActual.uid;
        final voy = tarea.apuntadosUids.contains(yo);
        final nombres = [
          for (final uid in tarea.apuntadosUids) (uid, estado.nombreDe(uid)),
        ]..sort((a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));
        return Scaffold(
          appBar: AppBar(
            title: Text(tarea.titulo),
            actions: [
              if (mesa && abierta)
                PopupMenuButton<String>(
                  onSelected: (_) => _anular(context, tarea),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'anular', child: Text(textos.anularTarea)),
                  ],
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (tarea.anulada)
                Card(
                  color: colores.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(textos.tareaAnulada(tarea.motivoAnulacion),
                        style: TextStyle(color: colores.onErrorContainer)),
                  ),
                ),
              if (tarea.estaHecha)
                Card(
                  color: colores.primaryContainer,
                  child: ListTile(
                    leading:
                        Icon(Icons.task_alt, color: colores.onPrimaryContainer),
                    title: Text(textos.tareaHecha,
                        style: TextStyle(color: colores.onPrimaryContainer)),
                    subtitle: tarea.notaHecha.isEmpty
                        ? null
                        : Text(tarea.notaHecha,
                            style:
                                TextStyle(color: colores.onPrimaryContainer)),
                  ),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(textos.fechaYHora(tarea.inicio)),
              ),
              if (tarea.lugar.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(tarea.lugar),
                ),
              if (tarea.descripcion.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(tarea.descripcion),
                ),
              const SizedBox(height: 8),
              Text(textos.quienVa,
                  style: Theme.of(context).textTheme.titleMedium),
              Text(textos.cuentaTarea(tarea),
                  style: Theme.of(context).textTheme.bodySmall),
              if (nombres.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(textos.nadieApuntado),
                ),
              for (final (uid, nombre) in nombres)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(nombre),
                  trailing: mesa && abierta && uid != yo
                      ? IconButton(
                          tooltip: textos.quitarDeLaTarea,
                          icon: const Icon(Icons.close),
                          onPressed: () => estado.apuntarseATarea(tarea.uid,
                              apuntado: false, personaUid: uid),
                        )
                      : null,
                ),
              if (mesa && abierta && !tarea.llena)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.person_add_alt),
                    label: Text(textos.apuntarAOtraPersona),
                    onPressed: () => _apuntarAOtra(context, tarea),
                  ),
                ),
              const SizedBox(height: 16),
              if (abierta && (voy || !tarea.llena))
                voy
                    ? OutlinedButton(
                        onPressed: () =>
                            estado.apuntarseATarea(tarea.uid, apuntado: false),
                        child: Text(textos.meBorro),
                      )
                    : FilledButton(
                        onPressed: () =>
                            estado.apuntarseATarea(tarea.uid, apuntado: true),
                        child: Text(textos.meApunto),
                      ),
              if (mesa && tarea.admiteHechaEn(ahora))
                FilledButton.tonal(
                  onPressed: () => _darPorHecha(context, tarea),
                  child: Text(textos.darPorHecha),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _anular(BuildContext context, Tarea tarea) async {
    final textos = AppLocalizations.of(context);
    final motivo = await pedirTexto(context,
        titulo: textos.anularTarea,
        etiqueta: textos.motivoAnulacionTarea,
        confirmar: textos.anularTarea);
    if (motivo != null) estado.anularTarea(tarea.uid, motivo);
  }

  Future<void> _apuntarAOtra(BuildContext context, Tarea tarea) async {
    final persona = await elegirPersona(
      context,
      titulo: AppLocalizations.of(context).apuntarAOtraPersona,
      personas: [
        for (final persona in estado.personas)
          if (!tarea.apuntadosUids.contains(persona.uid)) persona,
      ],
    );
    if (persona != null) {
      estado.apuntarseATarea(tarea.uid,
          apuntado: true, personaUid: persona.uid);
    }
  }

  Future<void> _darPorHecha(BuildContext context, Tarea tarea) async {
    final textos = AppLocalizations.of(context);
    final nota = await pedirTexto(context,
        titulo: tarea.titulo,
        etiqueta: textos.notaHecha,
        confirmar: textos.darPorHecha,
        inicial: tarea.notaHecha,
        obligatorio: false);
    if (nota != null) estado.marcarTareaHecha(tarea.uid, nota);
  }
}
