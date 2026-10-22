import 'package:flutter/widgets.dart';

/// Libera [controladores] (campos de texto de un diálogo u hoja creados en
/// la función que lo abre) cuando el diálogo desaparece del todo.
///
/// No vale liberarlos justo después del `await showDialog(...)`: el
/// diálogo se sigue pintando durante la animación de cierre y el campo
/// usaría un controlador ya liberado. Este widget, puesto en el `builder`
/// del diálogo, los libera al desmontarse, que es después. Leer `.text`
/// tras el `await` sigue funcionando.
class LiberarAlCerrar extends StatefulWidget {
  const LiberarAlCerrar({
    super.key,
    required this.controladores,
    required this.child,
  });

  final List<ChangeNotifier> controladores;
  final Widget child;

  @override
  State<LiberarAlCerrar> createState() => _LiberarAlCerrarState();
}

class _LiberarAlCerrarState extends State<LiberarAlCerrar> {
  @override
  void dispose() {
    for (final controlador in widget.controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
