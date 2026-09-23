import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/registro_actividad.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Alta de un registro de actividad/producción de un proyecto de test
/// (alimentación, paricion, producto). Se cuelga del proyecto; la finca es
/// la del proyecto (o 0 si no tiene).
class NuevaActividad extends StatefulWidget {
  const NuevaActividad({
    super.key,
    required this.proyectoId,
    required this.fincaId,
  });

  final int proyectoId;
  final int fincaId;

  @override
  State<NuevaActividad> createState() => _NuevaActividadState();
}

class _NuevaActividadState extends State<NuevaActividad> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _cantidad = TextEditingController();
  final _lote = TextEditingController();
  final _notas = TextEditingController();

  String _tipo = tipoActividadPorDefecto;
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _cantidad.dispose();
    _lote.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(_fecha.year - 2),
      lastDate: DateTime(_fecha.year + 1),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    final cantidad = double.tryParse(_cantidad.text.trim().replaceAll(',', '.'));
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.actCantidadObligatoria)));
      return;
    }
    await _bd.guardarRegistro(RegistroActividad(
      fincaId: widget.fincaId,
      proyectoId: widget.proyectoId,
      tipo: _tipo,
      cantidad: cantidad,
      fechaMs: _fecha.millisecondsSinceEpoch,
      lote: _lote.text.trim(),
      notas: _notas.text.trim(),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.actGuardada)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final unidad = unidadActividad(_tipo, idioma);
    return Scaffold(
      appBar: AppBar(title: Text(textos.actNuevaTitulo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: InputDecoration(labelText: textos.actTipo),
              items: [
                for (final t in tiposActividad)
                  DropdownMenuItem(
                      value: t.codigo, child: Text(t.etiqueta(idioma))),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidad,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: textos.actCantidad,
                suffixText: unidad,
              ),
            ),
            const SizedBox(height: 12),
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
                controller: _lote,
                decoration: InputDecoration(labelText: textos.actLote)),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 2,
                decoration: InputDecoration(labelText: textos.actNotas)),
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
