import 'package:flutter/material.dart';

import '../dominio/tarea.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'textos_dominio.dart';

/// Crear una tarea en común. Con «repetir cada semana» salen varias tareas
/// iguales una semana detrás de otra: los turnos (abrir el local cada
/// sábado), cada uno con sus plazas.
class FormularioTarea extends StatefulWidget {
  const FormularioTarea({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  State<FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<FormularioTarea> {
  final _titulo = TextEditingController();
  final _lugar = TextEditingController();
  final _descripcion = TextEditingController();
  late DateTime _dia;
  var _hora = const TimeOfDay(hour: 10, minute: 0);
  var _plazas = 0;
  var _repetir = false;
  var _semanas = 4;
  List<ProblemaTarea> _problemas = const [];

  @override
  void initState() {
    super.initState();
    final semanaQueViene = widget.estado.ahora.add(const Duration(days: 7));
    _dia =
        DateTime(semanaQueViene.year, semanaQueViene.month, semanaQueViene.day);
  }

  @override
  void dispose() {
    _titulo.dispose();
    _lugar.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Tarea _tarea(int semana) => Tarea(
        uid: widget.estado.nuevoUidTarea(),
        titulo: _titulo.text,
        inicio: DateTime(_dia.year, _dia.month, _dia.day + 7 * semana,
            _hora.hour, _hora.minute),
        lugar: _lugar.text,
        descripcion: _descripcion.text,
        plazas: _plazas,
      );

  void _crear() {
    final primera = _tarea(0);
    final problemas = primera.problemas(widget.estado.ahora);
    if (problemas.isNotEmpty) {
      setState(() => _problemas = problemas);
      return;
    }
    widget.estado.crearTarea(primera);
    for (var semana = 1; _repetir && semana < _semanas; semana++) {
      widget.estado.crearTarea(_tarea(semana));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(textos.nuevaTarea)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titulo,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: textos.campoTitulo,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event),
                label: Text(textos.fecha(_dia)),
                onPressed: () async {
                  final elegido = await showDatePicker(
                    context: context,
                    initialDate: _dia,
                    firstDate: DateTime(_dia.year - 1),
                    lastDate: DateTime(_dia.year + 2),
                    helpText: textos.campoDia,
                  );
                  if (elegido != null) setState(() => _dia = elegido);
                },
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: Text(_hora.format(context)),
              onPressed: () async {
                final elegida = await showTimePicker(
                    context: context,
                    initialTime: _hora,
                    helpText: textos.campoHora);
                if (elegida != null) setState(() => _hora = elegida);
              },
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _lugar,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: textos.campoLugar,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descripcion,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: textos.campoDescripcionTarea,
                border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(textos.campoPlazas),
            subtitle: Text(_plazas == 0 ? textos.plazasSinLimite : '$_plazas'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    _plazas == 0 ? null : () => setState(() => _plazas--),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => _plazas++),
              ),
            ]),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(textos.repetirCadaSemana),
            value: _repetir,
            onChanged: (valor) => setState(() => _repetir = valor),
          ),
          if (_repetir)
            Row(children: [
              Expanded(child: Text(textos.semanasRepetir(_semanas))),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed:
                    _semanas <= 2 ? null : () => setState(() => _semanas--),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed:
                    _semanas >= 12 ? null : () => setState(() => _semanas++),
              ),
            ]),
          if (_problemas.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final problema in _problemas)
              Text(textos.problemaTarea(problema),
                  style: TextStyle(color: colores.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: _crear, child: Text(textos.crear)),
        ],
      ),
    );
  }
}
