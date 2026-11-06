import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/debate.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import '../tema.dart';
import 'dialogos.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(textos.resumenDebate,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(debate.resumenMesa),
                ],
              ),
            )),
          if (estado.soyMesa)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final resumen = await pedirTexto(
                    context,
                    titulo: textos.escribirResumen,
                    etiqueta: textos.resumenDebate,
                    confirmar: textos.guardar,
                    inicial: debate.resumenMesa,
                  );
                  if (resumen != null) {
                    estado.resumirDebate(asunto.uid, resumen);
                  }
                },
                icon: const Icon(Icons.summarize_outlined),
                label: Text(textos.escribirResumen),
              ),
            ),
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
                    _Cuerpo(estado: estado, aportacion: aportacion),
                    for (final respuesta in debate.respuestasA(aportacion.uid,
                        paraLaMesa: estado.soyMesa))
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Firma(estado: estado, aportacion: respuesta),
                            _Cuerpo(estado: estado, aportacion: respuesta),
                          ],
                        ),
                      ),
                    if (alResponder != null &&
                        aportacion.estado == EstadoModeracion.visible)
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

/// El texto, o el hueco de una retirada, o la moderación pendiente (mesa).
class _Cuerpo extends StatelessWidget {
  const _Cuerpo({required this.estado, required this.aportacion});

  final EstadoConcejo estado;
  final Aportacion aportacion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    switch (aportacion.estado) {
      case EstadoModeracion.retirada:
        return Text(textos.retiradaPorMesa(aportacion.motivoRetirada),
            style: const TextStyle(fontStyle: FontStyle.italic));
      case EstadoModeracion.visible:
        if (!estado.soyMesa) return Text(aportacion.texto);
        // La mesa también puede retirar lo publicado (datos personales,
        // insultos), y queda el hueco con el motivo.
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(aportacion.texto)),
          IconButton(
            tooltip: textos.retirarAportacion,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => _retirar(context),
          ),
        ]);
      case EstadoModeracion.pendiente:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textos.pendienteModeracion,
                style: Theme.of(context).textTheme.labelSmall),
            Text(aportacion.texto),
            if (estado.soyMesa)
              Wrap(spacing: 8, children: [
                TextButton(
                  onPressed: () => estado.moderar(aportacion.asuntoUid,
                      aportacion.uid, EstadoModeracion.visible),
                  child: Text(textos.publicarAportacion),
                ),
                TextButton(
                  onPressed: () => _retirar(context),
                  child: Text(textos.retirarAportacion),
                ),
              ]),
          ],
        );
    }
  }
}

extension on _Cuerpo {
  Future<void> _retirar(BuildContext context) async {
    final textos = AppLocalizations.of(context);
    final motivo = await pedirTexto(
      context,
      titulo: textos.retirarAportacion,
      etiqueta: textos.motivoRetirada,
      confirmar: textos.retirarAportacion,
    );
    if (motivo != null) {
      estado.moderar(
          aportacion.asuntoUid, aportacion.uid, EstadoModeracion.retirada,
          motivo: motivo);
    }
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

  /// La mesa recoge lo que dijo otra persona; `null` = lo digo yo.
  String? _enNombreDe;

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
          if (widget.estado.soyMesa) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _enNombreDe,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: textos.quienLoDijo,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String?>(
                    value: null,
                    child: Text(widget.estado.personaActual.nombre)),
                for (final persona in widget.estado.personas)
                  if (persona.uid != widget.estado.personaActual.uid)
                    DropdownMenuItem<String?>(
                        value: persona.uid, child: Text(persona.nombre)),
              ],
              onChanged: (valor) => setState(() => _enNombreDe = valor),
            ),
          ],
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
                        enNombreDeUid: _enNombreDe,
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
