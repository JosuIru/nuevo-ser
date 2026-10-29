import 'package:flutter/material.dart';

/// Wrapper sobre `RawAutocomplete<T>` + `TextFormField` que mantiene la
/// API esperada por las apps de la **suite Larrea** (Viticultura,
/// Apícola, Arbolado Urbano):
///
/// - `TextEditingController` externo: la pantalla anfitriona controla
///   el texto y puede registrar listeners para reaccionar al teclear
///   (necesario para banners reactivos contra catálogo, ya que
///   `RawAutocomplete` sólo notifica vía `onSelected` cuando el usuario
///   PULSA un item del menú, no cuando teclea).
/// - `validator` del formulario.
/// - Hint, label y sugerencias del catálogo curado.
/// - Compatibilidad con texto libre cuando ninguna opción coincide
///   (necesario hasta que el técnico/agrónomo asesor valide los
///   catálogos).
///
/// El catálogo se pasa como dos funciones puras:
///  - `opcionesCompletas`: lista mostrada al abrir el campo
///    (típicamente el catálogo entero, recortado al pop por
///    `maxOpcionesVisibles`).
///  - `buscar(query)`: lista filtrada según lo tecleado.
///
/// `displayStringForOption` decide qué texto se muestra/escribe al
/// seleccionar una opción.
class CampoAutocompleteCatalogo<T extends Object> extends StatelessWidget {
  final TextEditingController controlador;
  final String labelText;
  final String? hintText;
  final List<T> opcionesCompletas;
  final List<T> Function(String) buscar;
  final String Function(T) displayStringForOption;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final int maxOpcionesVisibles;

  const CampoAutocompleteCatalogo({
    super.key,
    required this.controlador,
    required this.labelText,
    required this.opcionesCompletas,
    required this.buscar,
    required this.displayStringForOption,
    this.hintText,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.maxOpcionesVisibles = 8,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controlador,
      focusNode: FocusNode(),
      optionsBuilder: (valor) {
        final consultaUsuario = valor.text.trim();
        final resultados = consultaUsuario.isEmpty ? opcionesCompletas : buscar(consultaUsuario);
        return resultados.take(maxOpcionesVisibles);
      },
      displayStringForOption: displayStringForOption,
      onSelected: (opcion) {
        // RawAutocomplete actualiza el controlador automáticamente.
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.menu_book_outlined, size: 18),
          ),
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, opciones) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: opciones.length,
                itemBuilder: (context, i) {
                  final opcion = opciones.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(displayStringForOption(opcion)),
                    onTap: () => onSelected(opcion),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
