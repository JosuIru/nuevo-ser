/// Hueco de la barra de navegación del sistema (Android 15+ edge-to-edge).
///
/// Con `targetSdk` ≥ 35 la app dibuja bajo la barra de navegación de
/// Android, y cada pantalla debe dejar ese hueco abajo. Flutter lo deja solo
/// en algunos casos (`ListView` sin `padding`, `SafeArea`, `Scaffold` con
/// `bottomNavigationBar`); en los demás lo último queda tapado:
///
/// - una lista o scroll con `padding:` explícito → [rellenoInferiorSeguro]
///   (en `piezas_solera.dart`);
/// - una hoja inferior (`showModalBottomSheet`) → [mostrarHojaSolera],
///   [ContenidoHojaSegura] o [margenHojaSegura].
///
/// Regla para pantallas nuevas de Larrea: todo `padding:` de un scroll que
/// llegue al borde inferior de la pantalla pasa por [rellenoInferiorSeguro],
/// y toda hoja inferior por [mostrarHojaSolera] (o [margenHojaSegura]).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'piezas_solera.dart' show rellenoInferiorSeguro;

/// Hueco inferior que necesita el contenido de una hoja inferior: el mayor
/// entre el teclado (`viewInsets`) y la barra del sistema (`viewPadding`).
///
/// Se toma el mayor y no la suma: con el teclado abierto, el teclado ya
/// cubre la barra de navegación.
double huecoInferiorHoja(BuildContext context) {
  final datos = MediaQuery.of(context);
  return math.max(
    datos.viewInsets.bottom,
    math.max(datos.viewPadding.bottom, datos.padding.bottom),
  );
}

/// [margen] con el hueco inferior de la hoja ([huecoInferiorHoja]) sumado
/// abajo. Para hojas que ya montan su propio `Padding` o scroll (p. ej. un
/// `SingleChildScrollView` dentro de un `DraggableScrollableSheet`):
/// sustituye a `16 + MediaQuery.viewInsetsOf(context).bottom`.
EdgeInsets margenHojaSegura(BuildContext context,
        [EdgeInsets margen = EdgeInsets.zero]) =>
    margen.copyWith(bottom: margen.bottom + huecoInferiorHoja(context));

/// Envoltorio del contenido de una hoja inferior: le deja abajo el hueco del
/// teclado o de la barra del sistema (el mayor) más [margen], y lo quita del
/// `MediaQuery` de [child] para que un `SafeArea` o un `ListView` interior
/// no lo vuelvan a sumar.
class ContenidoHojaSegura extends StatelessWidget {
  const ContenidoHojaSegura({
    super.key,
    this.margen = EdgeInsets.zero,
    required this.child,
  });

  /// Margen propio del contenido (el hueco del sistema se suma abajo).
  final EdgeInsets margen;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margenHojaSegura(context, margen),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Builder(
          builder: (contextoSinTeclado) => MediaQuery.removePadding(
            context: contextoSinTeclado,
            removeBottom: true,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// `showModalBottomSheet` con el contenido dentro de [ContenidoHojaSegura]:
/// el último botón queda por encima de la barra de navegación del sistema y
/// del teclado. Los parámetros son los de `showModalBottomSheet`.
Future<T?> mostrarHojaSolera<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  EdgeInsets margen = EdgeInsets.zero,
  bool isScrollControlled = false,
  bool showDragHandle = false,
  bool useSafeArea = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (contextoHoja) => ContenidoHojaSegura(
      margen: margen,
      child: Builder(builder: builder),
    ),
  );
}
