import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, margenHojaSegura, separarCampoSolera;

import '../utiles/textos_huerta.dart';

/// Hoja inferior con un formulario corto y un botón Guardar.
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
      decoration: InputDecoration(
          labelText: etiqueta, helperText: ayuda, helperMaxLines: 3),
    ));

/// Desplegable de una lista cerrada de ids con su nombre visible.
Widget desplegable<T>({
  required String etiqueta,
  required T? valor,
  required List<T> opciones,
  required String Function(T) nombre,
  required ValueChanged<T?> alCambiar,
  Key? key,
}) =>
    separarCampoSolera(DropdownButtonFormField<T>(
      key: key,
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        for (final opcion in opciones)
          DropdownMenuItem(
              value: opcion,
              child: Text(nombre(opcion), overflow: TextOverflow.ellipsis)),
      ],
      onChanged: alCambiar,
    ));

/// Fila con la fecha elegida; al tocarla abre el calendario. Los registros
/// del cuaderno se apuntan a menudo días después, y el plan va por delante.
Widget selectorFecha(
  BuildContext context, {
  required DateTime fecha,
  required ValueChanged<DateTime> alCambiar,
  String? etiqueta,
}) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(etiqueta ?? SoleraL10n.t('huer.fecha')),
      subtitle: Text(formatearFechaDia(fecha)),
      onTap: () async {
        final elegida = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 3 * 366)),
        );
        if (elegida != null) alCambiar(elegida);
      },
    );

/// Pide confirmación para borrar. Devuelve true si se confirma.
Future<bool> confirmarBorrado(BuildContext context, String que) async {
  final respuesta = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(SoleraL10n.t('borrar')),
      content: Text(que),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(SoleraL10n.t('cancelar'))),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(SoleraL10n.t('borrar'))),
      ],
    ),
  );
  return respuesta == true;
}

/// Mensaje corto abajo.
void avisar(BuildContext context, String texto) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

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
