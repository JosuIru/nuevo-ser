import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, margenHojaSegura;

import '../utiles/textos_monte.dart';

/// Hoja inferior con un formulario corto y un botón Guardar (como Obrador).
///
/// [construir] recibe `setState` de la hoja para refrescar sus propios
/// selectores. [guardar] devuelve `false` si falta algo (la hoja sigue
/// abierta); al guardar bien, la hoja se cierra devolviendo `true`.
///
/// Los [controladores] los libera la hoja cuando desaparece (después de la
/// animación de cierre): quien llama **no** los libera.
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
        ),
      );
    },
  );
  return guardado == true;
}

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

/// Campo de texto numérico de una línea.
Widget campoNumero(TextEditingController controlador, String etiqueta,
        {bool decimales = true, String? ayuda}) =>
    TextField(
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    );

/// Campo de texto (de una línea, o de [lineas] si se pasa).
Widget campoTexto(TextEditingController controlador, String etiqueta,
        {String? ayuda, int lineas = 1}) =>
    TextField(
      controller: controlador,
      minLines: lineas,
      maxLines: lineas == 1 ? 1 : lineas + 4,
      decoration: InputDecoration(
          labelText: etiqueta, helperText: ayuda, helperMaxLines: 3),
    );

/// Fila con la fecha elegida; al tocarla abre el calendario.
Widget selectorFecha(
  BuildContext context, {
  required DateTime? fecha,
  required ValueChanged<DateTime> alCambiar,
  String? etiqueta,
  VoidCallback? alQuitar,
}) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(etiqueta ?? SoleraL10n.t('mont.fecha')),
      subtitle: Text(fecha == null
          ? SoleraL10n.t('mont.sin_fecha')
          : formatearFecha(fecha.millisecondsSinceEpoch)),
      trailing: fecha != null && alQuitar != null
          ? IconButton(
              tooltip: SoleraL10n.t('borrar'),
              icon: const Icon(Icons.clear),
              onPressed: alQuitar)
          : null,
      onTap: () async {
        final elegida = await showDatePicker(
          context: context,
          initialDate: fecha ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now().add(const Duration(days: 3660)),
        );
        if (elegida != null) alCambiar(elegida);
      },
    );

/// Fila de chips para elegir uno de [opciones].
Widget selectorChips({
  required List<String> opciones,
  required String valor,
  required String Function(String) nombre,
  required ValueChanged<String> alCambiar,
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
              if (marcado) alCambiar(opcion);
            },
          ),
      ],
    );

/// Desplegable de un id entero opcional (rodal, actuación…).
Widget selectorId({
  required String etiqueta,
  required int? valor,
  required List<(int, String)> opciones,
  required ValueChanged<int?> alCambiar,
  String? textoNinguno,
}) =>
    DropdownButtonFormField<int?>(
      initialValue: opciones.any((opcion) => opcion.$1 == valor) ? valor : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        DropdownMenuItem<int?>(
            value: null,
            child: Text(textoNinguno ?? SoleraL10n.t('mont.ninguno'))),
        for (final (id, nombre) in opciones)
          DropdownMenuItem<int?>(
              value: id, child: Text(nombre, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: alCambiar,
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

/// Mensaje corto abajo.
void avisarConMensaje(BuildContext context, String clave) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(SoleraL10n.t(clave))));

/// Pide confirmación con [clave] como pregunta. True si se acepta.
Future<bool> confirmar(BuildContext context, String clave,
    {String? detalle}) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t(clave)),
      content: detalle == null ? null : Text(detalle),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(SoleraL10n.t('mont.aceptar'))),
      ],
    ),
  );
  return respuesta == true;
}
