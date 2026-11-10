import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, margenHojaSegura, separarCampoSolera;

import '../modelos/parcela.dart';
import '../utiles/textos_frutal.dart';

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
        {bool decimales = true, String? ayuda}) =>
    separarCampoSolera(TextField(
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    ));

/// Campo de texto de una línea.
Widget campoTexto(TextEditingController controlador, String etiqueta,
        {String? ayuda}) =>
    separarCampoSolera(TextField(
      controller: controlador,
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    ));

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
      title: Text(etiqueta ?? SoleraL10n.t('frut.fecha')),
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

/// Desplegable de parcelas (el valor es el id).
Widget selectorParcela({
  required List<Parcela> parcelas,
  required int? parcelaId,
  required ValueChanged<int?> alCambiar,
}) =>
    separarCampoSolera(DropdownButtonFormField<int>(
      initialValue: parcelaId,
      decoration: InputDecoration(labelText: SoleraL10n.t('frut.parcela')),
      items: [
        for (final parcela in parcelas)
          DropdownMenuItem(
              value: parcela.id,
              child: Text(
                  '${parcela.nombre} · ${nombreEspecie(parcela.especieId)}')),
      ],
      onChanged: alCambiar,
    ));
