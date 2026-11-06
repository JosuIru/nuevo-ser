import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/urna.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'pestana_consentimiento.dart';
import 'textos_dominio.dart';

/// Votar, elegir, apoyar propuestas u objetar, según la forma de decidir.
class PestanaDecidir extends StatelessWidget {
  const PestanaDecidir({super.key, required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final fase = asunto.faseEn(estado.ahora);
    final reglas = asunto.reglas;

    // En consentimiento se puede objetar desde el debate: objetar a tiempo
    // es lo que permite integrar la objeción.
    if (reglas.forma == FormaDecision.consentimiento) {
      return PestanaConsentimiento(estado: estado, asunto: asunto);
    }
    if (fase != FaseAsunto.decision) {
      return _Mensaje(
          textos.decisionAunNo(textos.fecha(asunto.inicioDecision)));
    }
    if (estado.heVotado(asunto.uid)) return _Mensaje(textos.yaHasVotado);
    return _Papeleta(estado: estado, asunto: asunto);
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(texto, textAlign: TextAlign.center),
        ),
      );
}

class _Papeleta extends StatefulWidget {
  const _Papeleta({required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  @override
  State<_Papeleta> createState() => _PapeletaState();
}

class _PapeletaState extends State<_Papeleta> {
  final _marcadas = <String>{};

  ReglasDecision get _reglas => widget.asunto.reglas;
  bool get _votacion => _reglas.forma == FormaDecision.votacion;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(textos.forma(_reglas.forma),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        if (_votacion)
          RadioGroup<String>(
            groupValue: _marcadas.firstOrNull,
            onChanged: (nuevo) => setState(() => _marcadas
              ..clear()
              ..add(nuevo!)),
            child: Column(children: [
              for (final (valor, etiqueta) in [
                (votoSi, textos.votoSi),
                (votoNo, textos.votoNo),
                (votoAbstencion, textos.votoAbstencion),
              ])
                Card(
                  child: RadioListTile<String>(
                    value: valor,
                    title: Text(etiqueta),
                  ),
                ),
            ]),
          )
        else ...[
          for (final opcion in _reglas.opciones)
            Card(
              child: CheckboxListTile(
                value: _marcadas.contains(opcion.id),
                onChanged: (marcada) => setState(() => marcada!
                    ? _marcadas.add(opcion.id)
                    : _marcadas.remove(opcion.id)),
                title: Text(opcion.texto),
                subtitle: opcion.costeEuros == null
                    ? null
                    : Text(textos.euros(opcion.costeEuros!)),
              ),
            ),
          const SizedBox(height: 8),
          if (_reglas.forma == FormaDecision.presupuesto)
            Text(textos.bolsaRestante(
                textos.euros(_gastado), textos.euros(_reglas.bolsaEuros!))),
          Text(textos.votoEnBlanco,
              style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed:
              _votacion && _marcadas.isEmpty ? null : () => _enviar(context),
          icon: const Icon(Icons.how_to_vote),
          label: Text(textos.enviarVoto),
        ),
        const SizedBox(height: 8),
        Text(_reglas.esSecreta ? textos.votoSecreto : textos.votoNominal,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  double get _gastado => _reglas.opciones
      .where((o) => _marcadas.contains(o.id))
      .fold(0.0, (suma, o) => suma + (o.costeEuros ?? 0));

  Future<void> _enviar(BuildContext context) async {
    final textos = AppLocalizations.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(textos.confirmarVoto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(textos.cancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(textos.enviar)),
        ],
      ),
    );
    if (confirmado == true) {
      widget.estado.votar(widget.asunto.uid, {..._marcadas});
    }
  }
}
