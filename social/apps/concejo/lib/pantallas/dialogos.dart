import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Pide un texto obligatorio. Devuelve `null` si se cancela.
///
/// El campo vive dentro del propio diálogo (y se libera con él): si se
/// liberase al volver de `showDialog`, la animación de cierre lo seguiría
/// usando.
Future<String?> pedirTexto(
  BuildContext context, {
  required String titulo,
  required String etiqueta,
  required String confirmar,
  String inicial = '',
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _DialogoTexto(
        titulo: titulo,
        etiqueta: etiqueta,
        confirmar: confirmar,
        inicial: inicial,
      ),
    );

class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.titulo,
    required this.etiqueta,
    required this.confirmar,
    required this.inicial,
  });

  final String titulo;
  final String etiqueta;
  final String confirmar;
  final String inicial;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  late final _controlador = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _controlador,
        autofocus: true,
        minLines: 3,
        maxLines: 8,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: widget.etiqueta,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(textos.cancelar),
        ),
        FilledButton(
          onPressed: _controlador.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, _controlador.text.trim()),
          child: Text(widget.confirmar),
        ),
      ],
    );
  }
}

Future<bool> confirmar(
  BuildContext context, {
  required String mensaje,
  required String accion,
}) async {
  final textos = AppLocalizations.of(context);
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(textos.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(accion),
        ),
      ],
    ),
  );
  return respuesta ?? false;
}
