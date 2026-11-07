import 'package:flutter/material.dart';

import '../dominio/sesion.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'ficha_sesion.dart';
import 'textos_dominio.dart';

/// Las asambleas: las próximas primero (la más cercana arriba) y después
/// las ya celebradas (la última arriba).
class PantallaAsambleas extends StatelessWidget {
  const PantallaAsambleas({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final ahora = estado.ahora;
    final proximas = [
      for (final sesion in estado.sesiones)
        if (!sesion.empezadaEn(ahora)) sesion,
    ];
    final pasadas = [
      for (final sesion in estado.sesiones.reversed)
        if (sesion.empezadaEn(ahora)) sesion,
    ];
    Widget seccion(String titulo, List<Sesion> sesiones) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child:
                  Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            ),
            if (sesiones.isEmpty)
              Text(textos.sinAsambleas,
                  style: Theme.of(context).textTheme.bodySmall)
            else
              for (final sesion in sesiones)
                _TarjetaSesion(estado: estado, sesion: sesion),
          ],
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        seccion(textos.proximasAsambleas, proximas),
        seccion(textos.asambleasPasadas, pasadas),
      ],
    );
  }
}

class _TarjetaSesion extends StatelessWidget {
  const _TarjetaSesion({required this.estado, required this.sesion});

  final EstadoConcejo estado;
  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final pie = sesion.anulada
        ? textos.asambleaAnulada(sesion.motivoAnulacion)
        : sesion.puntos.map((punto) => punto.texto).join(' · ');
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FichaSesion(estado: estado, sesionUid: sesion.uid),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sesion.titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration:
                          sesion.anulada ? TextDecoration.lineThrough : null)),
              const SizedBox(height: 4),
              Text('${textos.fechaYHora(sesion.inicio)} · ${sesion.lugar}'),
              const SizedBox(height: 8),
              Text(
                pie,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: sesion.anulada ? colores.error : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
