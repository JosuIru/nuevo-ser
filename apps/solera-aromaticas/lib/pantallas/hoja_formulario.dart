import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../utiles/textos_aromaticas.dart';

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
      );
    },
  );
  return guardado == true;
}

/// Campo de texto numérico de una línea.
Widget campoNumero(TextEditingController controlador, String etiqueta,
        {bool decimales = true, String? ayuda}) =>
    TextField(
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    );

/// Campo de texto de una línea.
Widget campoTexto(TextEditingController controlador, String etiqueta,
        {String? ayuda}) =>
    TextField(
      controller: controlador,
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    );

/// Fila con la fecha elegida; al tocarla abre el calendario. Los registros
/// del cuaderno se apuntan a menudo días después.
Widget selectorFecha(
  BuildContext context, {
  required DateTime fecha,
  required ValueChanged<DateTime> alCambiar,
  String? etiqueta,
}) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(etiqueta ?? SoleraL10n.t('arom.fecha')),
      subtitle: Text(formatearFecha(fecha.millisecondsSinceEpoch)),
      onTap: () async {
        final elegida = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 366)),
        );
        if (elegida != null) alCambiar(elegida);
      },
    );

/// Fila de chips para elegir uno de [opciones] (o ninguno si [permitirVacio]).
Widget selectorChips({
  required List<String> opciones,
  required String valor,
  required String Function(String) nombre,
  required ValueChanged<String> alCambiar,
  bool permitirVacio = false,
}) =>
    Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final opcion in opciones)
          ChoiceChip(
            label: Text(nombre(opcion)),
            selected: valor == opcion,
            onSelected: (marcado) {
              if (marcado) {
                alCambiar(opcion);
              } else if (permitirVacio) {
                alCambiar('');
              }
            },
          ),
      ],
    );

/// Etiqueta pequeña encima de un grupo de chips.
Widget etiquetaGrupo(BuildContext context, String texto) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(texto, style: Theme.of(context).textTheme.labelLarge),
    );

/// Texto de aviso (en el color de error si [grave]).
Widget textoAviso(BuildContext context, String texto, {bool grave = true}) =>
    Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(texto,
          style: TextStyle(
              color: grave ? Theme.of(context).colorScheme.error : null)),
    );
