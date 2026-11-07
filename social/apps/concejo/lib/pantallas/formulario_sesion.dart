import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/sesion.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
import 'textos_dominio.dart';

/// Convocar una asamblea, o cambiar su convocatoria antes de que empiece.
/// El orden del día mezcla asuntos abiertos de la app y puntos libres
/// («Ruegos y preguntas»).
class FormularioSesion extends StatefulWidget {
  const FormularioSesion({super.key, required this.estado, this.sesion});

  final EstadoConcejo estado;

  /// `null` para convocar una nueva.
  final Sesion? sesion;

  @override
  State<FormularioSesion> createState() => _FormularioSesionState();
}

class _FormularioSesionState extends State<FormularioSesion> {
  late final _titulo = TextEditingController(text: widget.sesion?.titulo);
  late final _lugar = TextEditingController(text: widget.sesion?.lugar);
  late DateTime _dia;
  late TimeOfDay _hora;
  late List<PuntoOrdenDia> _puntos;
  List<ProblemaSesion> _problemas = const [];

  @override
  void initState() {
    super.initState();
    final sesion = widget.sesion;
    final semanaQueViene = widget.estado.ahora.add(const Duration(days: 7));
    final inicio = sesion?.inicio ??
        DateTime(
            semanaQueViene.year, semanaQueViene.month, semanaQueViene.day, 19);
    _dia = DateTime(inicio.year, inicio.month, inicio.day);
    _hora = TimeOfDay(hour: inicio.hour, minute: inicio.minute);
    _puntos = [...?sesion?.puntos];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.sesion == null && _titulo.text.isEmpty) {
      final textos = AppLocalizations.of(context);
      _titulo.text = textos.tituloAsambleaInicial;
      if (_puntos.isEmpty) {
        _puntos = [
          PuntoOrdenDia(
              uid: widget.estado.nuevoUidPunto(),
              texto: textos.ruegosYPreguntas),
        ];
      }
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _lugar.dispose();
    super.dispose();
  }

  Sesion _sesion() => Sesion(
        uid: widget.sesion?.uid ?? widget.estado.nuevoUidSesion(),
        titulo: _titulo.text,
        inicio:
            DateTime(_dia.year, _dia.month, _dia.day, _hora.hour, _hora.minute),
        lugar: _lugar.text,
        puntos: _puntos,
      );

  void _convocar() {
    final sesion = _sesion();
    final problemas = sesion.problemas();
    if (problemas.isNotEmpty) {
      setState(() => _problemas = problemas);
      return;
    }
    widget.estado.convocarSesion(sesion);
    Navigator.of(context).pop();
  }

  Future<void> _anadirPuntoLibre() async {
    final textos = AppLocalizations.of(context);
    final texto = await pedirTexto(context,
        titulo: textos.anadirPunto,
        etiqueta: textos.textoDelPunto,
        confirmar: textos.anadirPunto);
    if (texto == null) return;
    setState(() => _puntos = [
          ..._puntos,
          PuntoOrdenDia(uid: widget.estado.nuevoUidPunto(), texto: texto),
        ]);
  }

  /// Los asuntos abiertos que aún no están en el orden del día.
  List<Asunto> _asuntosParaAnadir() => [
        for (final asunto in widget.estado.asuntos)
          if (asunto.abierto && !_puntos.any((p) => p.asuntoUid == asunto.uid))
            asunto,
      ];

  void _anadirAsunto(Asunto asunto) => setState(() => _puntos = [
        // Antes de los puntos libres del final («Ruegos y preguntas»).
        ..._puntos.where((p) => p.asuntoUid != null),
        PuntoOrdenDia(
            uid: widget.estado.nuevoUidPunto(),
            texto: asunto.titulo,
            asuntoUid: asunto.uid),
        ..._puntos.where((p) => p.asuntoUid == null),
      ]);

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final asuntos = _asuntosParaAnadir();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sesion == null
            ? textos.convocarAsamblea
            : textos.cambiarConvocatoria),
      ),
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
          const SizedBox(height: 16),
          Text(textos.ordenDelDia,
              style: Theme.of(context).textTheme.titleMedium),
          for (final (indice, punto) in _puntos.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                  punto.asuntoUid == null ? Icons.notes : Icons.forum_outlined),
              title: Text('${indice + 1}. ${punto.texto}'),
              trailing: IconButton(
                tooltip: textos.quitarPunto,
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _puntos = [
                      for (final otro in _puntos)
                        if (otro.uid != punto.uid) otro,
                    ]),
              ),
            ),
          Wrap(spacing: 8, children: [
            if (asuntos.isNotEmpty)
              PopupMenuButton<Asunto>(
                onSelected: _anadirAsunto,
                itemBuilder: (_) => [
                  for (final asunto in asuntos)
                    PopupMenuItem(value: asunto, child: Text(asunto.titulo)),
                ],
                child: Chip(
                  avatar: const Icon(Icons.add),
                  label: Text(textos.anadirAsunto),
                ),
              ),
            ActionChip(
              avatar: const Icon(Icons.add),
              label: Text(textos.anadirPunto),
              onPressed: _anadirPuntoLibre,
            ),
          ]),
          if (_problemas.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final problema in _problemas)
              Text(textos.problemaSesion(problema),
                  style: TextStyle(color: colores.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _convocar,
            child:
                Text(widget.sesion == null ? textos.convocar : textos.guardar),
          ),
        ],
      ),
    );
  }
}
