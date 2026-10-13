import 'package:flutter/material.dart';

import '../../modelos/constantes.dart';

/// Partida de un bloque de gasto. Sugiere las del catálogo
/// ([partidasGasto]) y admite escribir una propia del proyecto: las
/// partidas «varían según proyecto» (Zunbeltz, 2026-10-13). Al guardar,
/// el texto se pasa por [codigoPartida] para quedarse con el código si es
/// del catálogo.
class CampoPartidaGasto extends StatefulWidget {
  const CampoPartidaGasto({
    super.key,
    required this.bloque,
    required this.controlador,
    required this.idioma,
    required this.etiqueta,
    this.alElegirDelCatalogo,
  });

  final String bloque;
  final TextEditingController controlador;
  final String idioma;
  final String etiqueta;

  /// Se llama con el código al elegir una sugerencia (p. ej. para poner
  /// quién asume el gasto por defecto).
  final ValueChanged<String>? alElegirDelCatalogo;

  @override
  State<CampoPartidaGasto> createState() => _CampoPartidaGastoState();
}

class _CampoPartidaGastoState extends State<CampoPartidaGasto> {
  final _foco = FocusNode();

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  Iterable<OpcionCatalogo> _sugerencias(TextEditingValue valor) {
    final consulta = valor.text.trim().toLowerCase();
    final partidas = partidasDe(widget.bloque);
    if (consulta.isEmpty) return partidas;
    return partidas.where((opcion) =>
        opcion.es.toLowerCase().contains(consulta) ||
        opcion.eu.toLowerCase().contains(consulta));
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<OpcionCatalogo>(
      textEditingController: widget.controlador,
      focusNode: _foco,
      optionsBuilder: _sugerencias,
      displayStringForOption: (opcion) => opcion.etiqueta(widget.idioma),
      onSelected: (opcion) => widget.alElegirDelCatalogo?.call(opcion.codigo),
      fieldViewBuilder: (context, controlador, foco, alEnviar) => TextField(
        controller: controlador,
        focusNode: foco,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: widget.etiqueta,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        onSubmitted: (_) => alEnviar(),
      ),
      optionsViewBuilder: (context, alElegir, opciones) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280, maxWidth: 420),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final opcion in opciones)
                  ListTile(
                    dense: true,
                    title: Text(opcion.etiqueta(widget.idioma)),
                    onTap: () => alElegir(opcion),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
