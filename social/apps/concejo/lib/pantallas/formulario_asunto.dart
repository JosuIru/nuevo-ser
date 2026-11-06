import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';
import 'textos_dominio.dart';

/// Crear o editar un asunto en borrador. Abajo, siempre a la vista, lo que
/// falta para poder abrirlo.
class FormularioAsunto extends StatefulWidget {
  const FormularioAsunto({super.key, required this.estado, this.existente});

  final EstadoConcejo estado;

  /// `null` = asunto nuevo.
  final Asunto? existente;

  @override
  State<FormularioAsunto> createState() => _FormularioAsuntoState();
}

class _OpcionEditable {
  _OpcionEditable(this.id, {String texto = '', double? coste})
      : texto = TextEditingController(text: texto),
        coste = TextEditingController(
            text: coste == null ? '' : _numeroComoTexto(coste));

  final String id;
  final TextEditingController texto;
  final TextEditingController coste;

  void dispose() {
    texto.dispose();
    coste.dispose();
  }
}

String _numeroComoTexto(double numero) => numero == numero.roundToDouble()
    ? numero.toStringAsFixed(0)
    : numero.toString().replaceAll('.', ',');

/// «1.500,50», «1500,5» o «1500.5». Con coma, los puntos son de miles.
double? _leerNumero(String texto) {
  final limpio = texto.trim().replaceAll(' ', '');
  return double.tryParse(limpio.contains(',')
      ? limpio.replaceAll('.', '').replaceAll(',', '.')
      : limpio);
}

class _FormularioAsuntoState extends State<FormularioAsunto> {
  late final String _uid;
  late final _titulo = TextEditingController(text: widget.existente?.titulo);
  late final _resumen = TextEditingController(text: widget.existente?.resumen);
  late final _texto = TextEditingController(text: widget.existente?.texto);
  late final _compromiso =
      TextEditingController(text: widget.existente?.compromisoPrevio);
  late final _coste = TextEditingController(
      text: widget.existente?.costeEuros == null
          ? ''
          : _numeroComoTexto(widget.existente!.costeEuros!));
  late final _entorno =
      TextEditingController(text: widget.existente?.efectoEntorno);
  late final _quorum = TextEditingController(
      text: '${widget.existente?.reglas.quorumPersonas ?? 0}');
  late final _bolsa = TextEditingController(
      text: widget.existente?.reglas.bolsaEuros == null
          ? ''
          : _numeroComoTexto(widget.existente!.reglas.bolsaEuros!));

  late TipoDecision _tipo;
  late FormaDecision _forma;
  late Mayoria _mayoria;
  late bool _secreta;
  late int _rondas;
  late DateTime _inicioDebate;
  late DateTime _inicioDecision;
  late DateTime _finDecision;
  final _opciones = <_OpcionEditable>[];
  var _siguienteOpcion = 1;

  @override
  void initState() {
    super.initState();
    final existente = widget.existente;
    final hoy = widget.estado.ahora;
    DateTime dia(int mas) => DateTime(hoy.year, hoy.month, hoy.day + mas);
    _uid = existente?.uid ?? widget.estado.nuevoUidAsunto();
    _tipo = existente?.tipoDecision ?? TipoDecision.consultiva;
    _forma = existente?.reglas.forma ?? FormaDecision.votacion;
    _mayoria = existente?.reglas.mayoria ?? Mayoria.simple;
    _secreta = existente?.reglas.secreta ?? true;
    _rondas = existente?.reglas.rondasConsentimiento ?? 2;
    _inicioDebate = existente?.inicioDebate ?? dia(0);
    _inicioDecision = existente?.inicioDecision ?? dia(10);
    _finDecision = existente?.finDecision ?? dia(17);
    for (final opcion
        in existente?.reglas.opciones ?? const <OpcionDecision>[]) {
      _opciones.add(_OpcionEditable(opcion.id,
          texto: opcion.texto, coste: opcion.costeEuros));
      final numero = int.tryParse(opcion.id.replaceFirst('o', ''));
      if (numero != null && numero >= _siguienteOpcion) {
        _siguienteOpcion = numero + 1;
      }
    }
  }

  @override
  void dispose() {
    for (final controlador in [
      _titulo,
      _resumen,
      _texto,
      _compromiso,
      _coste,
      _entorno,
      _quorum,
      _bolsa,
    ]) {
      controlador.dispose();
    }
    for (final opcion in _opciones) {
      opcion.dispose();
    }
    super.dispose();
  }

  bool get _llevaOpciones =>
      _forma == FormaDecision.eleccionEntreOpciones ||
      _forma == FormaDecision.presupuesto;

  Asunto _borrador() => Asunto(
        uid: _uid,
        titulo: _titulo.text.trim(),
        resumen: _resumen.text.trim(),
        texto: _texto.text.trim(),
        tipoDecision: _tipo,
        compromisoPrevio: _tipo == TipoDecision.conCompromisoPrevio
            ? _compromiso.text.trim()
            : '',
        costeEuros: _leerNumero(_coste.text),
        efectoEntorno: _entorno.text.trim(),
        reglas: ReglasDecision(
          forma: _forma,
          mayoria: _mayoria,
          quorumPersonas: int.tryParse(_quorum.text.trim()) ?? 0,
          secreta: _secreta,
          rondasConsentimiento: _rondas,
          bolsaEuros: _forma == FormaDecision.presupuesto
              ? _leerNumero(_bolsa.text)
              : null,
          opciones: _llevaOpciones
              ? [
                  for (final opcion in _opciones)
                    if (opcion.texto.text.trim().isNotEmpty)
                      OpcionDecision(
                        id: opcion.id,
                        texto: opcion.texto.text.trim(),
                        costeEuros: _forma == FormaDecision.presupuesto
                            ? _leerNumero(opcion.coste.text)
                            : null,
                      ),
                ]
              : const [],
        ),
        inicioDebate: _inicioDebate,
        inicioDecision: _inicioDecision,
        finDecision: _finDecision,
      );

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    final problemas = _borrador().problemasParaAbrir();
    const hueco = SizedBox(height: 12);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existente == null
            ? textos.nuevoAsunto
            : textos.editarAsunto),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _Campo(
              controlador: _titulo,
              etiqueta: textos.campoTitulo,
              alCambiar: _refrescar),
          hueco,
          _Campo(
            controlador: _resumen,
            etiqueta: textos.campoResumen,
            ayuda: textos.ayudaResumen,
            lineas: 3,
            alCambiar: _refrescar,
          ),
          hueco,
          _Campo(controlador: _texto, etiqueta: textos.campoTexto, lineas: 5),
          hueco,
          _Campo(
            controlador: _entorno,
            etiqueta: textos.campoEntorno,
            ayuda: textos.ayudaEntorno,
            lineas: 2,
            alCambiar: _refrescar,
          ),
          hueco,
          _Campo(
            controlador: _coste,
            etiqueta: textos.campoCoste,
            teclado: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          Text(textos.campoTipoDecision, style: estilos.labelLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final tipo in TipoDecision.values)
              ChoiceChip(
                label: Text(textos.tipoDecision(tipo)),
                selected: _tipo == tipo,
                onSelected: (_) => setState(() => _tipo = tipo),
              ),
          ]),
          const SizedBox(height: 6),
          Text(textos.explicaTipoDecision(_tipo), style: estilos.bodySmall),
          if (_tipo == TipoDecision.conCompromisoPrevio) ...[
            hueco,
            _Campo(
              controlador: _compromiso,
              etiqueta: textos.campoCompromiso,
              ayuda: textos.ayudaCompromiso,
              lineas: 2,
              alCambiar: _refrescar,
            ),
          ],
          const SizedBox(height: 20),
          Text(textos.seccionCalendario, style: estilos.labelLarge),
          _CampoFecha(
            etiqueta: textos.campoInicioDebate,
            valor: _inicioDebate,
            alElegir: (fecha) => setState(() => _inicioDebate = fecha),
          ),
          _CampoFecha(
            etiqueta: textos.campoInicioDecision,
            valor: _inicioDecision,
            alElegir: (fecha) => setState(() => _inicioDecision = fecha),
          ),
          _CampoFecha(
            etiqueta: textos.campoFinDecision,
            valor: _finDecision,
            alElegir: (fecha) => setState(() => _finDecision = fecha),
          ),
          const SizedBox(height: 20),
          Text(textos.campoForma, style: estilos.labelLarge),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final forma in FormaDecision.values)
              ChoiceChip(
                label: Text(textos.nombreForma(forma)),
                selected: _forma == forma,
                onSelected: (_) => setState(() => _forma = forma),
              ),
          ]),
          const SizedBox(height: 6),
          Text(textos.forma(_forma), style: estilos.bodySmall),
          hueco,
          ..._reglasDeLaForma(textos),
          const SizedBox(height: 24),
          if (problemas.isNotEmpty)
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(textos.faltaParaAbrir, style: estilos.labelLarge),
                    for (final problema in problemas)
                      Text('· ${textos.problema(problema)}'),
                  ],
                ),
              ),
            ),
          hueco,
          OutlinedButton(
            onPressed: _guardar,
            child: Text(textos.guardarBorrador),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: problemas.isEmpty ? _abrir : null,
            child: Text(textos.abrirAsunto),
          ),
        ],
      ),
    );
  }

  List<Widget> _reglasDeLaForma(AppLocalizations textos) {
    const hueco = SizedBox(height: 12);
    final campoQuorum = _Campo(
      controlador: _quorum,
      etiqueta: textos.campoQuorum,
      ayuda: textos.ayudaQuorum,
      teclado: TextInputType.number,
      alCambiar: _refrescar,
    );
    final interruptorSecreto = SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(textos.campoSecreto),
      value: _secreta,
      onChanged: (valor) => setState(() => _secreta = valor),
    );
    return switch (_forma) {
      FormaDecision.votacion => [
          DropdownButtonFormField<Mayoria>(
            initialValue: _mayoria,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: textos.campoMayoria,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final mayoria in Mayoria.values)
                DropdownMenuItem(
                    value: mayoria, child: Text(textos.mayoria(mayoria))),
            ],
            onChanged: (valor) => setState(() => _mayoria = valor!),
          ),
          hueco,
          campoQuorum,
          interruptorSecreto,
        ],
      FormaDecision.consentimiento => [
          Row(children: [
            Expanded(child: Text(textos.campoRondas)),
            IconButton(
              onPressed: _rondas > 1 ? () => setState(() => _rondas--) : null,
              icon: const Icon(Icons.remove),
            ),
            Text('$_rondas'),
            IconButton(
              onPressed: _rondas < 5 ? () => setState(() => _rondas++) : null,
              icon: const Icon(Icons.add),
            ),
          ]),
        ],
      FormaDecision.eleccionEntreOpciones || FormaDecision.presupuesto => [
          if (_forma == FormaDecision.presupuesto) ...[
            _Campo(
              controlador: _bolsa,
              etiqueta: textos.campoBolsa,
              teclado: const TextInputType.numberWithOptions(decimal: true),
              alCambiar: _refrescar,
            ),
            hueco,
          ],
          Text(
            _forma == FormaDecision.presupuesto
                ? textos.propuestas
                : textos.opciones,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          for (final opcion in _opciones)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                Expanded(
                  child: _Campo(
                    controlador: opcion.texto,
                    etiqueta: textos.textoOpcion,
                    alCambiar: _refrescar,
                  ),
                ),
                if (_forma == FormaDecision.presupuesto) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: _Campo(
                      controlador: opcion.coste,
                      etiqueta: textos.costeOpcion,
                      teclado:
                          const TextInputType.numberWithOptions(decimal: true),
                      alCambiar: _refrescar,
                    ),
                  ),
                ],
                IconButton(
                  onPressed: () => setState(() {
                    _opciones.remove(opcion);
                    opcion.dispose();
                  }),
                  icon: const Icon(Icons.delete_outline),
                ),
              ]),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() =>
                  _opciones.add(_OpcionEditable('o${_siguienteOpcion++}'))),
              icon: const Icon(Icons.add),
              label: Text(textos.anadirOpcion),
            ),
          ),
          hueco,
          campoQuorum,
          interruptorSecreto,
        ],
    };
  }

  void _refrescar() => setState(() {});

  void _guardar() {
    widget.estado.guardarBorrador(_borrador());
    Navigator.pop(context);
  }

  Future<void> _abrir() async {
    final textos = AppLocalizations.of(context);
    final si = await confirmar(context,
        mensaje: textos.confirmarAbrir, accion: textos.abrir);
    if (!si || !mounted) return;
    widget.estado
      ..guardarBorrador(_borrador())
      ..abrirAsunto(_uid);
    Navigator.pop(context);
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controlador,
    required this.etiqueta,
    this.ayuda,
    this.lineas = 1,
    this.teclado,
    this.alCambiar,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final String? ayuda;
  final int lineas;
  final TextInputType? teclado;
  final VoidCallback? alCambiar;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controlador,
        minLines: lineas,
        maxLines: lineas == 1 ? 1 : lineas + 4,
        keyboardType: teclado,
        textCapitalization: TextCapitalization.sentences,
        onChanged: alCambiar == null ? null : (_) => alCambiar!(),
        decoration: InputDecoration(
          labelText: etiqueta,
          helperText: ayuda,
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
        ),
      );
}

class _CampoFecha extends StatelessWidget {
  const _CampoFecha({
    required this.etiqueta,
    required this.valor,
    required this.alElegir,
  });

  final String etiqueta;
  final DateTime valor;
  final ValueChanged<DateTime> alElegir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(etiqueta),
      subtitle: Text(textos.fecha(valor)),
      onTap: () async {
        final elegida = await showDatePicker(
          context: context,
          initialDate: valor,
          firstDate: DateTime(valor.year - 1),
          lastDate: DateTime(valor.year + 3),
        );
        if (elegida != null) alElegir(elegida);
      },
    );
  }
}
