import 'package:flutter/material.dart';

import '../../branding.dart';

/// Barra fija de abajo de un formulario a pantalla completa, sobre una
/// raya: los botones de guardar repartidos a partes iguales.
class BarraInferiorFormulario extends StatelessWidget {
  const BarraInferiorFormulario({super.key, required this.botones});

  final List<Widget> botones;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        border: Border(top: BorderSide(color: esquema.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(children: [
            for (var indice = 0; indice < botones.length; indice++) ...[
              if (indice > 0) const SizedBox(width: 12),
              Expanded(child: botones[indice]),
            ],
          ]),
        ),
      ),
    );
  }
}
