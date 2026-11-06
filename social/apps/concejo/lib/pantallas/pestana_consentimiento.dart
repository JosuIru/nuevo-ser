import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/consentimiento.dart';
import '../dominio/reglas_decision.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
import 'textos_dominio.dart';

/// Consentimiento: objeciones vivas arriba; la mesa las integra o dice que
/// no son objeción (con motivo), quien objetó puede retirarla, y la mesa
/// cierra cada vuelta. Las resueltas quedan a la vista con su respuesta.
class PestanaConsentimiento extends StatelessWidget {
  const PestanaConsentimiento(
      {super.key, required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final consentimiento = estado.consentimiento(asunto.uid);
    final estilos = Theme.of(context).textTheme;
    final fase = asunto.faseEn(estado.ahora);
    final enCurso = !consentimiento.decidido &&
        (fase == FaseAsunto.debate || fase == FaseAsunto.decision);
    final resueltas = consentimiento.objeciones
        .where((o) => o.estado != EstadoObjecion.viva)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(textos.forma(FormaDecision.consentimiento),
            style: estilos.titleSmall),
        const SizedBox(height: 4),
        if (consentimiento.decidido)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                consentimiento.desenlace == DesenlaceConsentimiento.aprobada
                    ? textos.consentimientoAprobado
                    : textos.consentimientoPasa,
                style: estilos.titleMedium,
              ),
            ),
          )
        else
          Text(textos.rondaConsentimiento(
              consentimiento.rondaActual, consentimiento.rondasMaximas)),
        const SizedBox(height: 16),
        if (consentimiento.vivas.isEmpty)
          Text(textos.sinObjeciones)
        else ...[
          Text(textos.objecionesVivas, style: estilos.labelLarge),
          for (final objecion in consentimiento.vivas)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(objecion.motivo),
                    const SizedBox(height: 4),
                    Text(estado.nombreDe(objecion.autorUid),
                        style: estilos.labelSmall),
                    if (enCurso)
                      _AccionesObjecion(
                          estado: estado, asunto: asunto, objecion: objecion),
                  ],
                ),
              ),
            ),
        ],
        if (resueltas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(textos.objecionesResueltas, style: estilos.labelLarge),
          for (final objecion in resueltas)
            Card(
              child: ListTile(
                title: Text(objecion.motivo),
                subtitle: Text([
                  '${estado.nombreDe(objecion.autorUid)} · '
                      '${textos.estadoObjecion(objecion.estado)}',
                  if (objecion.respuesta.isNotEmpty) objecion.respuesta,
                ].join('\n')),
              ),
            ),
        ],
        const SizedBox(height: 16),
        if (enCurso) ...[
          Text(textos.objetarNoEsContra, style: estilos.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final motivo = await pedirTexto(
                context,
                titulo: textos.objetar,
                etiqueta: textos.queDanoCausa,
                confirmar: textos.enviar,
              );
              if (motivo != null) estado.objetar(asunto.uid, motivo);
            },
            icon: const Icon(Icons.pan_tool_outlined),
            label: Text(textos.objetar),
          ),
          if (estado.soyMesa) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () async {
                if (await confirmar(context,
                    mensaje: textos.confirmarCerrarVuelta,
                    accion: textos.cerrar)) {
                  estado.cerrarRondaConsentimiento(asunto.uid);
                }
              },
              icon: const Icon(Icons.flag_outlined),
              label: Text(textos.cerrarVuelta(consentimiento.rondaActual)),
            ),
          ],
        ],
      ],
    );
  }
}

class _AccionesObjecion extends StatelessWidget {
  const _AccionesObjecion({
    required this.estado,
    required this.asunto,
    required this.objecion,
  });

  final EstadoConcejo estado;
  final Asunto asunto;
  final Objecion objecion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final esMia = objecion.autorUid == estado.personaActual.uid;
    Future<void> resolver(EstadoObjecion nuevo, String etiqueta) async {
      final respuesta = await pedirTexto(
        context,
        titulo: textos.estadoObjecion(nuevo),
        etiqueta: etiqueta,
        confirmar: textos.guardar,
      );
      if (respuesta != null) {
        estado.resolverObjecion(asunto.uid, objecion.uid, nuevo, respuesta);
      }
    }

    return Wrap(spacing: 8, children: [
      if (estado.soyMesa) ...[
        TextButton(
          onPressed: () =>
              resolver(EstadoObjecion.integrada, textos.comoSeIntegra),
          child: Text(textos.integrarObjecion),
        ),
        TextButton(
          onPressed: () =>
              resolver(EstadoObjecion.noEsObjecion, textos.porQueNoEsObjecion),
          child: Text(textos.noEsObjecion),
        ),
      ],
      if (esMia)
        TextButton(
          onPressed: () => estado.resolverObjecion(
              asunto.uid, objecion.uid, EstadoObjecion.retirada, ''),
          child: Text(textos.retirarMiObjecion),
        ),
    ]);
  }
}
