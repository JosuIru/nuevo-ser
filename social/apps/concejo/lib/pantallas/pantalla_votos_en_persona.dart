import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../dominio/urna.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'dialogos.dart';

/// La mesa en la urna de papel: apunta a cada persona que entrega su
/// papeleta (así nadie vota dos veces) y, al cerrar, pasa el conteo firmado
/// por dos. Sirve igual para una asamblea a mano alzada.
class PantallaVotosEnPersona extends StatefulWidget {
  const PantallaVotosEnPersona(
      {super.key, required this.estado, required this.asuntoUid});

  final EstadoConcejo estado;
  final String asuntoUid;

  @override
  State<PantallaVotosEnPersona> createState() => _PantallaVotosEnPersonaState();
}

class _PantallaVotosEnPersonaState extends State<PantallaVotosEnPersona> {
  var _busqueda = '';

  EstadoConcejo get _estado => widget.estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    return ListenableBuilder(
      listenable: _estado,
      builder: (context, _) {
        final asunto = _estado.asunto(widget.asuntoUid);
        final urna = _estado.urna(asunto.uid);
        final enPlazo = asunto.faseEn(_estado.ahora) == FaseAsunto.decision;
        final sinParticipar = _estado
            .personasSinParticipar(asunto.uid)
            .where(
                (p) => p.nombre.toLowerCase().contains(_busqueda.toLowerCase()))
            .toList();
        return Scaffold(
          appBar: AppBar(title: Text(textos.votosEnPersona)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(asunto.titulo, style: estilos.titleMedium),
              const SizedBox(height: 8),
              Text(textos.votosEnPersonaTexto),
              const SizedBox(height: 16),
              Text(textos.anotadasEnPersona(urna.participacionesPresenciales),
                  style: estilos.labelLarge),
              if (enPlazo) ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: textos.buscarPersona,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (texto) => setState(() => _busqueda = texto),
                ),
                for (final persona in sinParticipar)
                  ListTile(
                    title: Text(persona.nombre),
                    trailing: OutlinedButton(
                      onPressed: () =>
                          _estado.anotarVotoPresencial(asunto.uid, persona.uid),
                      child: Text(textos.anotar),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () async {
                    final nombre = await pedirTexto(
                      context,
                      titulo: textos.darDeAlta,
                      etiqueta: textos.nombreNuevaPersona,
                      confirmar: textos.anotar,
                      inicial: _busqueda,
                    );
                    if (nombre == null) return;
                    final nueva = _estado.darDeAlta(nombre);
                    _estado.anotarVotoPresencial(asunto.uid, nueva.uid);
                  },
                  icon: const Icon(Icons.person_add_alt),
                  label: Text(textos.darDeAlta),
                ),
              ],
              const Divider(height: 32),
              Text(
                  textos.conteosRegistrados(urna.papeletasPresencialesContadas),
                  style: estilos.labelLarge),
              if (urna
                  .avisos()
                  .contains(AvisoUrna.papeletasPresencialesNoCuadran))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(textos.avisoPapeletasNoCuadran,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 8),
              if (_estado.otrasPersonasDeLaMesa().isEmpty)
                Text(textos.sinOtraMesa)
              else
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        _FormularioConteo(estado: _estado, asunto: asunto),
                  )),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(textos.pasarConteo),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FormularioConteo extends StatefulWidget {
  const _FormularioConteo({required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  @override
  State<_FormularioConteo> createState() => _FormularioConteoState();
}

class _FormularioConteoState extends State<_FormularioConteo> {
  late final List<String> _ids;
  final _marcas = <String, TextEditingController>{};
  final _totales = TextEditingController();
  String? _segundaFirma;

  @override
  void initState() {
    super.initState();
    final reglas = widget.asunto.reglas;
    _ids = reglas.forma == FormaDecision.votacion
        ? const [votoSi, votoNo, votoAbstencion]
        : [for (final opcion in reglas.opciones) opcion.id];
    for (final id in _ids) {
      _marcas[id] = TextEditingController();
    }
    // Lo esperable: tantas papeletas como personas anotadas sin conteo.
    final urna = widget.estado.urna(widget.asunto.uid);
    final pendientes =
        urna.participacionesPresenciales - urna.papeletasPresencialesContadas;
    if (pendientes > 0) _totales.text = '$pendientes';
  }

  @override
  void dispose() {
    for (final controlador in [..._marcas.values, _totales]) {
      controlador.dispose();
    }
    super.dispose();
  }

  int? _numero(TextEditingController controlador) => int.tryParse(
      controlador.text.trim().isEmpty ? '0' : controlador.text.trim());

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final otras = widget.estado.otrasPersonasDeLaMesa();
    final reglas = widget.asunto.reglas;
    String etiqueta(String id) => switch (id) {
          votoSi when reglas.forma == FormaDecision.votacion => textos.votoSi,
          votoNo when reglas.forma == FormaDecision.votacion => textos.votoNo,
          votoAbstencion when reglas.forma == FormaDecision.votacion =>
            textos.votoAbstencion,
          _ => reglas.opciones.firstWhere((o) => o.id == id).texto,
        };
    final numerosValidos =
        _marcas.values.every((c) => (_numero(c) ?? -1) >= 0) &&
            (_numero(_totales) ?? -1) >= 0;
    return Scaffold(
      appBar: AppBar(title: Text(textos.pasarConteo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.asunto.titulo,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final id in _ids)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(child: Text(etiqueta(id))),
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: _marcas[id],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: '0'),
                  ),
                ),
              ]),
            ),
          const Divider(),
          Row(children: [
            Expanded(child: Text(textos.pdfPapeletasTotales)),
            SizedBox(
              width: 96,
              child: TextField(
                controller: _totales,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: '0'),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _segundaFirma,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: textos.segundaFirma,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final persona in otras)
                DropdownMenuItem(
                    value: persona.uid, child: Text(persona.nombre)),
            ],
            onChanged: (valor) => setState(() => _segundaFirma = valor),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: numerosValidos && _segundaFirma != null
                ? () {
                    widget.estado.registrarConteoPresencial(
                      asuntoUid: widget.asunto.uid,
                      papeletasTotales: _numero(_totales)!,
                      marcasPorOpcion: {
                        for (final entrada in _marcas.entries)
                          if (_numero(entrada.value)! > 0)
                            entrada.key: _numero(entrada.value)!,
                      },
                      segundaFirmaUid: _segundaFirma!,
                    );
                    Navigator.pop(context);
                  }
                : null,
            child: Text(textos.registrarConteo),
          ),
          const SizedBox(height: 12),
          Text(
            textos.resultadoParticipacion(widget.estado
                .urna(widget.asunto.uid)
                .personasQueHanParticipado),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
