import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../estado/perfil_huerta.dart';

/// Elegir entre huerta profesional y huerto de casa.
class SelectorPerfilHuerta extends StatelessWidget {
  const SelectorPerfilHuerta({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PerfilHuerta>(
      valueListenable: perfilHuerta,
      builder: (context, perfil, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<PerfilHuerta>(
            segments: [
              ButtonSegment(
                value: PerfilHuerta.profesional,
                icon: const Icon(Icons.agriculture_outlined),
                label: Text(SoleraL10n.t('huer.perfil_profesional')),
              ),
              ButtonSegment(
                value: PerfilHuerta.casa,
                icon: const Icon(Icons.yard_outlined),
                label: Text(SoleraL10n.t('huer.perfil_casa')),
              ),
            ],
            selected: {perfil},
            onSelectionChanged: (elegidos) =>
                cambiarPerfilHuerta(elegidos.first),
          ),
          const SizedBox(height: 6),
          Text(
            SoleraL10n.t(perfil == PerfilHuerta.casa
                ? 'huer.perfil_casa_ayuda'
                : 'huer.perfil_profesional_ayuda'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
