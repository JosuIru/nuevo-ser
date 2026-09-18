import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/validacion_producto.dart';
import 'widgets/cuerpo_responsivo.dart';

/// Alta de una prueba de validación de producto de un proyecto de test.
class NuevaValidacion extends StatefulWidget {
  const NuevaValidacion({super.key, required this.proyectoId});

  final int proyectoId;

  @override
  State<NuevaValidacion> createState() => _NuevaValidacionState();
}

class _NuevaValidacionState extends State<NuevaValidacion> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _descripcion = TextEditingController();
  final _notas = TextEditingController();
  String _resultado = resultadoValidacionPorDefecto;
  int _valoracion = 0;
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _descripcion.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(ahora.year - 3),
      lastDate: DateTime(ahora.year + 1),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    await _bd.guardarValidacion(ValidacionProducto(
      proyectoId: widget.proyectoId,
      fechaMs: _fecha.millisecondsSinceEpoch,
      descripcion: _descripcion.text.trim(),
      resultado: _resultado,
      valoracion: _valoracion,
      notas: _notas.text.trim(),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.valGuardada)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.valNuevaTitulo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
                controller: _descripcion,
                decoration: InputDecoration(labelText: textos.valDescripcion)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _resultado,
              decoration: InputDecoration(labelText: textos.valResultado),
              items: [
                for (final r in resultadosValidacion)
                  DropdownMenuItem(
                      value: r.codigo, child: Text(r.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() => _resultado = v ?? _resultado),
            ),
            const SizedBox(height: 16),
            Text(textos.valValoracion,
                style: Theme.of(context).textTheme.labelLarge),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                        i <= _valoracion ? Icons.star : Icons.star_border),
                    color: colorSenalZunbeltz,
                    onPressed: () => setState(
                        () => _valoracion = _valoracion == i ? 0 : i),
                  ),
                if (_valoracion == 0)
                  Text(textos.valSinValorar,
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(textos.comunFecha),
              subtitle: Text(DateFormat('dd/MM/yyyy', idioma).format(_fecha)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _elegirFecha,
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notas')),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(textos.comunGuardar),
            ),
          ],
        ),
      ),
    );
  }
}
