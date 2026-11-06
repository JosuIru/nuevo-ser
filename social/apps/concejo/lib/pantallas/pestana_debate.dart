import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/debate.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import '../tema.dart';
import 'textos_dominio.dart';

/// El debate en cuatro columnas (en el móvil, una debajo de otra). Sin
/// «me gusta» ni contadores: para apoyar algo, se responde diciendo por qué.
class PestanaDebate extends StatelessWidget {
  const PestanaDebate({super.key, required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  bool get _abierto =>
      asunto.faseEn(estado.ahora) == FaseAsunto.debate ||
      asunto.faseEn(estado.ahora) == FaseAsunto.decision;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final debate = estado.debate(asunto.uid);
    final colores = Theme.of(context).colorScheme;
    final mias = debate.aportaciones.where((a) =>
        a.autorUid == estado.personaActual.uid &&
        a.estado == EstadoModeracion.pendiente);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (debate.resumenMesa.isNotEmpty)
            Card(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(debate.resumenMesa),
            )),
          if (mias.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(textos.pendienteMesa,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          if (!_abierto)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(textos.debateCerrado),
            ),
          for (final (indice, tipo) in TipoAportacion.values.indexed)
            _Columna(
              titulo: textos.columna(tipo),
              color: colorDeColumna(colores, indice),
              aportaciones: debate.columna(tipo, paraLaMesa: estado.soyMesa),
              debate: debate,
              estado: estado,
              alResponder: _abierto
                  ? (original) => _escribir(context, respondeA: original)
                  : null,
            ),
        ],
      ),
      floatingActionButton: _abierto
          ? FloatingActionButton.extended(
              onPressed: () => _escribir(context),
              icon: const Icon(Icons.edit_outlined),
              label: Text(textos.aportar),
            )
          : null,
    );
  }

  Future<void> _escribir(BuildContext context, {Aportacion? respondeA}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _FormularioAportacion(
          estado: estado,
          asuntoUid: asunto.uid,
          respondeA: respondeA,
        ),
      );
}

class _Columna extends StatelessWidget {
  const _Columna({
    required this.titulo,
    required this.color,
    required this.aportaciones,
    required this.debate,
    required this.estado,
    required this.alResponder,
  });

  final String titulo;
  final Color color;
  final List<Aportacion> aportaciones;
  final Debate debate;
  final EstadoConcejo estado;
  final void Function(Aportacion original)? alResponder;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 4, height: 20, color: color),
            const SizedBox(width: 8),
            Text(titulo, style: Theme.of(context).textTheme.titleSmall),
          ]),
          const SizedBox(height: 4),
          if (aportaciones.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(textos.columnaVacia,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          for (final aportacion in aportaciones)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Firma(estado: estado, aportacion: aportacion),
                    Text(aportacion.texto),
                    for (final respuesta in debate.respuestasA(aportacion.uid,
                        paraLaMesa: estado.soyMesa))
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Firma(estado: estado, aportacion: respuesta),
                            Text(respuesta.texto),
                          ],
                        ),
                      ),
                    if (alResponder != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => alResponder!(aportacion),
                          child: Text(textos.responder),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Firma extends StatelessWidget {
  const _Firma({required this.estado, required this.aportacion});

  final EstadoConcejo estado;
  final Aportacion aportacion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final nombre = aportacion.anonima
        ? textos.vecinaAnonima
        : estado.nombreDe(aportacion.autorUid);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$nombre · ${textos.fecha(aportacion.creada)}',
          style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _FormularioAportacion extends StatefulWidget {
  const _FormularioAportacion({
    required this.estado,
    required this.asuntoUid,
    this.respondeA,
  });

  final EstadoConcejo estado;
  final String asuntoUid;
  final Aportacion? respondeA;

  @override
  State<_FormularioAportacion> createState() => _FormularioAportacionState();
}

class _FormularioAportacionState extends State<_FormularioAportacion> {
  final _texto = TextEditingController();
  var _tipo = TipoAportacion.aFavor;
  var _anonima = false;

  @override
  void initState() {
    super.initState();
    if (widget.respondeA != null) _tipo = TipoAportacion.duda;
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.respondeA != null)
            Text('↪ ${widget.respondeA!.texto}',
                maxLines: 2, overflow: TextOverflow.ellipsis),
          if (widget.respondeA == null) ...[
            Text(textos.tipoDeAportacion,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final tipo in TipoAportacion.values)
                ChoiceChip(
                  label: Text(textos.columna(tipo)),
                  selected: _tipo == tipo,
                  onSelected: (_) => setState(() => _tipo = tipo),
                ),
            ]),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _texto,
            autofocus: true,
            minLines: 3,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: textos.tuAportacion,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _anonima,
            onChanged: (valor) => setState(() => _anonima = valor ?? false),
            title: Text(textos.aportarAnonima),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(textos.cancelar),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _texto.text.trim().isEmpty
                  ? null
                  : () {
                      widget.estado.aportar(
                        widget.asuntoUid,
                        widget.respondeA?.tipo ?? _tipo,
                        _texto.text,
                        respondeAUid: widget.respondeA?.uid,
                        anonima: _anonima,
                      );
                      Navigator.pop(context);
                    },
              child: Text(textos.publicar),
            ),
          ]),
        ],
      ),
    );
  }
}
