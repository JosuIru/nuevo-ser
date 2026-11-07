import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

/// Hoja inferior con un formulario corto y un botón Guardar.
///
/// [construir] recibe `setState` de la hoja para refrescar sus propios
/// selectores. [guardar] devuelve `false` si falta algo (la hoja sigue
/// abierta); al guardar bien, la hoja se cierra devolviendo `true`.
///
/// Los [controladores] los libera la hoja cuando desaparece (después de la
/// animación de cierre): quien llama **no** los libera. Liberarlos justo al
/// volver del `await` rompía la animación (lo cazó un test de Sagardoa).
Future<bool> mostrarHojaFormulario(
  BuildContext context, {
  required String titulo,
  required List<Widget> Function(StateSetter refrescar) construir,
  required Future<bool> Function() guardar,
  List<TextEditingController> controladores = const [],
}) async {
  final guardado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (contextoHoja) {
      var guardando = false;
      return _LiberaControladores(
        controladores: controladores,
        child: StatefulBuilder(
          builder: (contextoHoja, refrescar) => Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.viewInsetsOf(contextoHoja).bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(titulo,
                      style: Theme.of(contextoHoja).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...construir(refrescar),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: guardando
                        ? null
                        : () async {
                            refrescar(() => guardando = true);
                            final correcto = await guardar();
                            if (!contextoHoja.mounted) return;
                            if (correcto) {
                              Navigator.pop(contextoHoja, true);
                            } else {
                              refrescar(() => guardando = false);
                            }
                          },
                    child: Text(SoleraL10n.t('guardar')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  return guardado == true;
}

/// Campo de texto numérico de una línea.
Widget campoNumero(TextEditingController controlador, String etiqueta,
        {bool decimales = true}) =>
    TextField(
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      decoration: InputDecoration(labelText: etiqueta),
    );

/// Campo de texto de una línea.
Widget campoTexto(TextEditingController controlador, String etiqueta) =>
    TextField(
      controller: controlador,
      decoration: InputDecoration(labelText: etiqueta),
    );

/// Libera los controladores de la hoja cuando el widget sale del árbol.
class _LiberaControladores extends StatefulWidget {
  const _LiberaControladores(
      {required this.controladores, required this.child});

  final List<TextEditingController> controladores;
  final Widget child;

  @override
  State<_LiberaControladores> createState() => _LiberaControladoresState();
}

class _LiberaControladoresState extends State<_LiberaControladores> {
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
