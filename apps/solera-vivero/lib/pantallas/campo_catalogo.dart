import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show separarCampoSolera;

import '../dominio/catalogos.dart';

/// Campo de texto con sugerencias de un catálogo. Escribe en [controlador]
/// el nombre visible; al guardar, `idDesdeTexto` lo convierte en id del
/// catálogo si coincide, o lo deja como texto libre.
class CampoCatalogo extends StatefulWidget {
  const CampoCatalogo({
    super.key,
    required this.controlador,
    required this.opciones,
    required this.etiqueta,
    this.ayuda,
    this.alElegir,
  });

  final TextEditingController controlador;
  final List<OpcionCatalogo> opciones;
  final String etiqueta;
  final String? ayuda;
  final ValueChanged<OpcionCatalogo>? alElegir;

  @override
  State<CampoCatalogo> createState() => _CampoCatalogoState();
}

class _CampoCatalogoState extends State<CampoCatalogo> {
  final FocusNode _foco = FocusNode();

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opciones = widget.opciones;
    // El margen va por fuera del autocompletado: dentro del campo bajaría
    // también la lista de sugerencias.
    return separarCampoSolera(RawAutocomplete<OpcionCatalogo>(
      textEditingController: widget.controlador,
      focusNode: _foco,
      optionsBuilder: (valor) {
        final texto = valor.text.trim().toLowerCase();
        return opciones.where((opcion) =>
            texto.isEmpty || opcion.nombre.toLowerCase().contains(texto));
      },
      displayStringForOption: (opcion) => opcion.nombre,
      onSelected: widget.alElegir,
      fieldViewBuilder: (context, controladorCampo, foco, alEnviar) =>
          TextField(
        controller: controladorCampo,
        focusNode: foco,
        decoration: InputDecoration(
            labelText: widget.etiqueta, helperText: widget.ayuda),
      ),
      optionsViewBuilder: (context, alSeleccionar, sugerencias) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final opcion in sugerencias)
                  ListTile(
                    dense: true,
                    title: Text(opcion.nombre),
                    onTap: () => alSeleccionar(opcion),
                  ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
