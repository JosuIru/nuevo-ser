import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Pregunta antes de borrar. Lo borrado se sincroniza y desaparece también
/// de los demás móviles, así que un toque largo accidental no debe bastar.
Future<bool> confirmarBorrado(BuildContext context) async {
  final textos = AppLocalizations.of(context);
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      content: Text(textos.comunBorrarConfirmar),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(contexto, false),
          child: Text(textos.comunCancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(contexto, true),
          child: Text(textos.comunBorrar),
        ),
      ],
    ),
  );
  return confirmado == true;
}
