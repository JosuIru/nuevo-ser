import 'package:flutter/material.dart';

import '../dominio/anuncio.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
import 'textos_dominio.dart';

/// Días que un anuncio de otra persona lleva la etiqueta «Nuevo».
const diasDeAnuncioNuevo = 3;

/// El tablón: los anuncios vigentes, los fijados por la mesa arriba.
class PantallaTablon extends StatelessWidget {
  const PantallaTablon({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final anuncios = estado.anunciosVigentes;
    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          if (anuncios.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(textos.tablonVacio,
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            for (final anuncio in anuncios)
              _TarjetaAnuncio(estado: estado, anuncio: anuncio),
        ],
      ),
    );
  }
}

enum _OpcionAnuncio { fijar, desfijar, retirar }

class _TarjetaAnuncio extends StatelessWidget {
  const _TarjetaAnuncio({required this.estado, required this.anuncio});

  final EstadoConcejo estado;
  final Anuncio anuncio;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final esMio = anuncio.autorUid == estado.personaActual.uid;
    final esNuevo = !esMio &&
        estado.ahora.difference(anuncio.publicado).inDays < diasDeAnuncioNuevo;
    final hasta = anuncio.hasta;
    final opciones = [
      if (estado.soyMesa)
        anuncio.fijado ? _OpcionAnuncio.desfijar : _OpcionAnuncio.fijar,
      if (esMio || estado.soyMesa) _OpcionAnuncio.retirar,
    ];
    return Card(
      color: anuncio.fijado ? colores.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (anuncio.fijado || esNuevo)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Wrap(spacing: 6, children: [
                        if (anuncio.fijado)
                          Chip(
                            avatar: const Icon(Icons.push_pin, size: 16),
                            label: Text(textos.etiquetaFijado),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (esNuevo)
                          Chip(
                            label: Text(textos.etiquetaNuevo),
                            visualDensity: VisualDensity.compact,
                          ),
                      ]),
                    ),
                  Text(anuncio.titulo,
                      style: Theme.of(context).textTheme.titleMedium),
                  if (anuncio.texto.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(anuncio.texto),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    [
                      estado.nombreDe(anuncio.autorUid),
                      textos.fecha(anuncio.publicado),
                      if (hasta != null)
                        textos.anuncioHasta(textos.fecha(hasta)),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (opciones.isNotEmpty)
              PopupMenuButton<_OpcionAnuncio>(
                onSelected: (opcion) => _elegir(context, opcion, esMio),
                itemBuilder: (_) => [
                  for (final opcion in opciones)
                    PopupMenuItem(
                      value: opcion,
                      child: Text(switch (opcion) {
                        _OpcionAnuncio.fijar => textos.fijarAnuncio,
                        _OpcionAnuncio.desfijar => textos.desfijarAnuncio,
                        _OpcionAnuncio.retirar => textos.retirarAnuncio,
                      }),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _elegir(
      BuildContext context, _OpcionAnuncio opcion, bool esMio) async {
    final textos = AppLocalizations.of(context);
    switch (opcion) {
      case _OpcionAnuncio.fijar:
        estado.fijarAnuncio(anuncio.uid, fijado: true);
      case _OpcionAnuncio.desfijar:
        estado.fijarAnuncio(anuncio.uid, fijado: false);
      case _OpcionAnuncio.retirar:
        if (esMio) {
          final seguro = await showDialog<bool>(
            context: context,
            builder: (contextoDialogo) => AlertDialog(
              title: Text(textos.retirarAnuncio),
              content: Text(textos.retirarAnuncioPropio),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(contextoDialogo).pop(false),
                  child: Text(textos.cancelar),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(contextoDialogo).pop(true),
                  child: Text(textos.retirarAnuncio),
                ),
              ],
            ),
          );
          if (seguro == true) estado.retirarAnuncio(anuncio.uid, '');
        } else {
          final motivo = await pedirTexto(context,
              titulo: textos.retirarAnuncio,
              etiqueta: textos.motivoRetiradaAnuncio,
              confirmar: textos.retirarAnuncio);
          if (motivo != null) estado.retirarAnuncio(anuncio.uid, motivo);
        }
    }
  }
}
