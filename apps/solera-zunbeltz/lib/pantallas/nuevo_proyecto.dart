import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/finca.dart';
import '../modelos/proyecto_test.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

/// Alta de un proyecto de test (la persona tester y su proceso).
class NuevoProyecto extends StatefulWidget {
  const NuevoProyecto({super.key, required this.fincas});

  final List<Finca> fincas;

  @override
  State<NuevoProyecto> createState() => _NuevoProyectoState();
}

class _NuevoProyectoState extends State<NuevoProyecto> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _nombre = TextEditingController();
  final _persona = TextEditingController();
  final _actividad = TextEditingController();
  final _notas = TextEditingController();
  int? _fincaId;
  DateTime? _inicio;

  @override
  void dispose() {
    _nombre.dispose();
    _persona.dispose();
    _actividad.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _elegirInicio() async {
    final ahora = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _inicio ?? ahora,
      firstDate: DateTime(ahora.year - 3),
      lastDate: DateTime(ahora.year + 3),
    );
    if (d != null) setState(() => _inicio = d);
  }

  Future<void> _guardar() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final textos = AppLocalizations.of(context);
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(textos.proyectoNombreObligatorio)));
      return;
    }
    await _bd.guardarProyecto(ProyectoTest(
      nombre: _nombre.text.trim(),
      persona: _persona.text.trim(),
      actividad: _actividad.text.trim(),
      fincaId: _fincaId,
      fechaInicioMs: _inicio?.millisecondsSinceEpoch,
      notas: _notas.text.trim(),
      fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.proyectoGuardado)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(textos.proyectoNuevo)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
                controller: _nombre,
                decoration: InputDecoration(labelText: textos.proyectoNombre)),
            const SizedBox(height: 12),
            TextField(
                controller: _persona,
                decoration: InputDecoration(labelText: textos.proyectoPersona)),
            const SizedBox(height: 12),
            TextField(
                controller: _actividad,
                decoration:
                    InputDecoration(labelText: textos.proyectoActividad)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _fincaId,
              decoration: InputDecoration(labelText: textos.proyectoFinca),
              items: [
                DropdownMenuItem(
                    value: null, child: Text(textos.proyectoSinFinca)),
                for (final f in widget.fincas)
                  DropdownMenuItem(value: f.id, child: Text(f.nombre)),
              ],
              onChanged: (v) => setState(() => _fincaId = v),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(textos.proyectoFechaInicio),
              subtitle: Text(_inicio == null
                  ? '—'
                  : DateFormat('dd/MM/yyyy', idioma).format(_inicio!)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _elegirInicio,
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
