import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../utiles/textos_vivero.dart';

/// Hoja inferior con un formulario corto y un botón Guardar (copiada de
/// Frutal).
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
      decoration: InputDecoration(
          labelText: etiqueta, helperText: ayuda, helperMaxLines: 3),
    );

/// Fila con la fecha elegida; al tocarla abre el calendario.
Widget selectorFecha(
  BuildContext context, {
  required DateTime fecha,
  required ValueChanged<DateTime> alCambiar,
  String? etiqueta,
}) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(etiqueta ?? SoleraL10n.t('vive.fecha')),
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

/// Desplegable genérico de opciones con nombre visible.
Widget selectorOpcion<T>({
  required String etiqueta,
  required T? valor,
  required List<T> opciones,
  required String Function(T) nombre,
  required ValueChanged<T?> alCambiar,
}) =>
    DropdownButtonFormField<T>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        for (final opcion in opciones)
          DropdownMenuItem(value: opcion, child: Text(nombre(opcion))),
      ],
      onChanged: alCambiar,
    );

/// Pide confirmación antes de borrar o anular algo.
Future<bool> confirmar(BuildContext context, String pregunta) async =>
    await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        content: Text(pregunta),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(SoleraL10n.t('vive.aceptar'))),
        ],
      ),
    ) ==
    true;

void avisar(BuildContext context, String texto) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

/// Libera los controladores de una hoja cuando ya se ha cerrado: la
/// animación de cierre aún repinta los campos un momento después de que
/// `showModalBottomSheet` devuelva, y liberarlos antes rompe.
void liberarControladores(List<TextEditingController> controladores) {
  Future<void>.delayed(const Duration(seconds: 1), () {
    for (final controlador in controladores) {
      controlador.dispose();
    }
  });
}
