import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../utiles/textos_sidra.dart';

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

/// Libera los controladores cuando la hoja se retira del árbol.
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
        {bool decimales = true, String? sufijo}) =>
    TextField(
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: decimales),
      decoration: InputDecoration(labelText: etiqueta, suffixText: sufijo),
    );

/// Campo de texto de una línea.
Widget campoTexto(TextEditingController controlador, String etiqueta,
        {String? ayuda}) =>
    TextField(
      controller: controlador,
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    );

/// Desplegable de una lista cerrada con su texto visible.
Widget campoDesplegable<T>({
  required String etiqueta,
  required T? valor,
  required List<(T, String)> opciones,
  required ValueChanged<T?> alCambiar,
  Key? key,
}) =>
    DropdownButtonFormField<T>(
      key: key,
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(labelText: etiqueta),
      items: [
        for (final (valorOpcion, texto) in opciones)
          DropdownMenuItem<T>(
              value: valorOpcion,
              child: Text(texto, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: alCambiar,
    );

/// Fila con la fecha elegida y un botón para cambiarla.
class SelectorFecha extends StatelessWidget {
  const SelectorFecha({
    super.key,
    required this.etiqueta,
    required this.fechaMs,
    required this.alCambiar,
    this.permitirVacia = false,
  });

  final String etiqueta;
  final int? fechaMs;
  final ValueChanged<int?> alCambiar;
  final bool permitirVacia;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(etiqueta),
      subtitle: Text(fechaMs == null ? '—' : formatearFecha(fechaMs!)),
      trailing: permitirVacia && fechaMs != null
          ? IconButton(
              tooltip: SoleraL10n.t('borrar'),
              icon: const Icon(Icons.clear),
              onPressed: () => alCambiar(null),
            )
          : null,
      onTap: () async {
        final inicial = fechaMs == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(fechaMs!);
        final elegida = await showDatePicker(
          context: context,
          initialDate: inicial,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 366)),
        );
        if (elegida == null) return;
        // Conserva la hora de hoy para que los movimientos del mismo día
        // queden ordenados como se apuntaron.
        final ahora = DateTime.now();
        alCambiar(DateTime(elegida.year, elegida.month, elegida.day, ahora.hour,
                ahora.minute)
            .millisecondsSinceEpoch);
      },
    );
  }
}

/// Abre una lista con buscador para elegir varios ids. Devuelve null si se
/// cancela.
Future<Set<String>?> elegirVarios(
  BuildContext context, {
  required String titulo,
  required List<({String id, String nombre})> opciones,
  required Set<String> elegidos,
}) {
  final seleccion = {...elegidos};
  var filtro = '';
  return showDialog<Set<String>>(
    context: context,
    builder: (contexto) => StatefulBuilder(
      builder: (contexto, refrescar) {
        final visibles = opciones
            .where((opcion) =>
                filtro.isEmpty ||
                opcion.nombre.toLowerCase().contains(filtro.toLowerCase()))
            .toList();
        return AlertDialog(
          title: Text(titulo),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: SoleraL10n.t('sidr.buscar')),
                  onChanged: (texto) => refrescar(() => filtro = texto),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final opcion in visibles)
                        CheckboxListTile(
                          dense: true,
                          value: seleccion.contains(opcion.id),
                          title: Text(opcion.nombre),
                          onChanged: (marcado) => refrescar(() {
                            if (marcado == true) {
                              seleccion.add(opcion.id);
                            } else {
                              seleccion.remove(opcion.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto),
                child: Text(SoleraL10n.t('cancelar'))),
            FilledButton(
                onPressed: () => Navigator.pop(contexto, seleccion),
                child: Text(SoleraL10n.t('sidr.aceptar'))),
          ],
        );
      },
    ),
  );
}

/// Texto pequeño de aviso (fondo terciario).
class TarjetaAviso extends StatelessWidget {
  const TarjetaAviso(this.texto, {super.key, this.icono = Icons.info_outline});

  final String texto;
  final IconData icono;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: ListTile(leading: Icon(icono), title: Text(texto)),
      );
}
