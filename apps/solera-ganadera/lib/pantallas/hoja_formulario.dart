import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, margenHojaSegura, separarCampoSolera;

/// Hoja inferior con un formulario corto y un botón Guardar.
///
/// [construir] recibe `setState` de la hoja para refrescar sus propios
/// selectores. [guardar] devuelve `false` si falta algo (la hoja sigue
/// abierta); al guardar bien, la hoja se cierra devolviendo `true`.
Future<bool> mostrarHojaFormulario(
  BuildContext context, {
  required String titulo,
  required List<Widget> Function(StateSetter refrescar) construir,
  required Future<bool> Function() guardar,
}) async {
  final guardado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (contextoHoja) {
      var guardando = false;
      return StatefulBuilder(
        builder: (contextoHoja, refrescar) => Padding(
          padding: margenHojaSegura(contextoHoja, const EdgeInsets.all(16)),
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
      );
    },
  );
  return guardado == true;
}

/// Campo de texto numérico de una línea.
Widget campoNumero(TextEditingController controlador, String etiqueta,
        {bool decimales = true}) =>
    separarCampoSolera(TextField(
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      decoration: InputDecoration(labelText: etiqueta),
    ));

/// Campo de texto de una línea.
Widget campoTexto(TextEditingController controlador, String etiqueta) =>
    separarCampoSolera(TextField(
      controller: controlador,
      decoration: InputDecoration(labelText: etiqueta),
    ));
