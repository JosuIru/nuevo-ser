import 'package:flutter/material.dart';

import '../../branding.dart';

/// Barra fija de abajo de un formulario a pantalla completa, sobre una
/// raya: los botones de guardar repartidos a partes iguales.
class BarraInferiorFormulario extends StatelessWidget {
  const BarraInferiorFormulario(
      {super.key, required this.botones, this.conRaya = true});

  final List<Widget> botones;

  /// Sin raya cuando va pegada a otra franja de la misma barra.
  final bool conRaya;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        border: conRaya
            ? Border(top: BorderSide(color: esquema.outlineVariant))
            : null,
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
