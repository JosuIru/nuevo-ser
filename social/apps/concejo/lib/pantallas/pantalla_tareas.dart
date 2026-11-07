import 'package:flutter/material.dart';

import '../dominio/tarea.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'ficha_tarea.dart';
import 'textos_dominio.dart';

/// Las tareas en común: las próximas primero (la más cercana arriba) y
/// después las hechas y pasadas (la última arriba).
class PantallaTareas extends StatelessWidget {
  const PantallaTareas({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final ahora = estado.ahora;
    final proximas = [
      for (final tarea in estado.tareas)
        if (!tarea.empezadaEn(ahora) && !tarea.estaHecha) tarea,
    ];
    final pasadas = [
      for (final tarea in estado.tareas.reversed)
        if (tarea.empezadaEn(ahora) || tarea.estaHecha) tarea,
    ];
    Widget seccion(String titulo, List<Tarea> tareas) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child:
                  Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            ),
            if (tareas.isEmpty)
              Text(textos.sinTareas,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              for (final tarea in tareas)
                _TarjetaTarea(estado: estado, tarea: tarea),
          ],
        );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      children: [
        seccion(textos.proximasAsambleas, proximas),
        seccion(textos.tareasPasadas, pasadas),
      ],
    );
  }
}

class _TarjetaTarea extends StatelessWidget {
  const _TarjetaTarea({required this.estado, required this.tarea});

  final EstadoConcejo estado;
  final Tarea tarea;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final voy = tarea.apuntadosUids.contains(estado.personaActual.uid);
    final pie = tarea.anulada
        ? textos.tareaAnulada(tarea.motivoAnulacion)
        : tarea.estaHecha
            ? textos.tareaHecha
            : [
                textos.cuentaTarea(tarea),
                if (voy) textos.teHasApuntado,
              ].join(' · ');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FichaTarea(estado: estado, tareaUid: tarea.uid),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tarea.titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration:
                          tarea.anulada ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 4),
              Text([
                textos.fechaYHora(tarea.inicio),
                if (tarea.lugar.isNotEmpty) tarea.lugar,
              ].join(' · ')),
              const SizedBox(height: 8),
              Text(
                pie,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tarea.anulada
                        ? colores.error
                        : voy
                            ? colores.primary
                            : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
