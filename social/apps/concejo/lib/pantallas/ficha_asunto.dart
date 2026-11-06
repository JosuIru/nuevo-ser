import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/reglas_decision.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'pestana_debate.dart';
import 'pestana_decidir.dart';
import 'pestana_resultado.dart';
import 'textos_dominio.dart';

class FichaAsunto extends StatelessWidget {
  const FichaAsunto({super.key, required this.estado, required this.asuntoUid});

  final EstadoConcejo estado;
  final String asuntoUid;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final asunto = estado.asunto(asuntoUid);
        final fase = asunto.faseEn(estado.ahora);
        final terceraPestana = fase == FaseAsunto.seguimiento
            ? textos.pestanaResultado
            : textos.pestanaDecidir;
        return DefaultTabController(
          length: 3,
          // Abre donde hay algo que hacer.
          initialIndex: switch (fase) {
            FaseAsunto.debate => 1,
            FaseAsunto.decision || FaseAsunto.seguimiento => 2,
            FaseAsunto.borrador => 0,
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(asunto.titulo),
              bottom: TabBar(tabs: [
                Tab(text: textos.pestanaInformacion),
                Tab(text: textos.pestanaDebate),
                Tab(text: terceraPestana),
              ]),
            ),
            body: TabBarView(children: [
              _PestanaInformacion(asunto: asunto),
              PestanaDebate(estado: estado, asunto: asunto),
              fase == FaseAsunto.seguimiento
                  ? PestanaResultado(estado: estado, asunto: asunto)
                  : PestanaDecidir(estado: estado, asunto: asunto),
            ]),
          ),
        );
      },
    );
  }
}

class _PestanaInformacion extends StatelessWidget {
  const _PestanaInformacion({required this.asunto});

  final Asunto asunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;
    final reglas = asunto.reglas;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Qué valor tiene lo que salga: lo primero, para que nadie se lleve
        // a engaño (docs/04-concejo.md §3).
        Card(
          color: colores.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(textos.tipoDecision(asunto.tipoDecision),
                    style: estilos.titleSmall
                        ?.copyWith(color: colores.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(textos.explicaTipoDecision(asunto.tipoDecision),
                    style: TextStyle(color: colores.onPrimaryContainer)),
                if (asunto.compromisoPrevio.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('«${asunto.compromisoPrevio}»',
                      style: TextStyle(
                          color: colores.onPrimaryContainer,
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(asunto.resumen, style: estilos.titleMedium),
        if (asunto.texto.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(textos.verTextoCompleto, style: estilos.labelLarge),
          const SizedBox(height: 4),
          Text(asunto.texto),
        ],
        _Seccion(
          titulo: textos.seccionEntorno,
          icono: Icons.eco_outlined,
          children: [Text(asunto.efectoEntorno)],
        ),
        if (asunto.costeEuros != null)
          _Seccion(
            titulo: textos.seccionCoste,
            icono: Icons.euro,
            children: [Text(textos.euros(asunto.costeEuros!))],
          ),
        _Seccion(
          titulo: textos.seccionCalendario,
          icono: Icons.event_outlined,
          children: [
            Text(textos.calendarioDebate(textos.fecha(asunto.inicioDebate))),
            Text(textos.calendarioDecision(textos.fecha(asunto.inicioDecision),
                textos.fecha(asunto.finDecision))),
          ],
        ),
        _Seccion(
          titulo: textos.seccionComoSeDecide,
          icono: Icons.how_to_vote_outlined,
          children: [
            Text(textos.forma(reglas.forma)),
            if (reglas.forma == FormaDecision.votacion)
              Text(textos.mayoria(reglas.mayoria)),
            if (reglas.forma == FormaDecision.presupuesto &&
                reglas.bolsaEuros != null)
              Text(textos.euros(reglas.bolsaEuros!)),
            Text(reglas.quorumPersonas > 0
                ? textos.quorum(reglas.quorumPersonas)
                : textos.sinQuorumRegla),
            if (reglas.forma != FormaDecision.consentimiento)
              Text(reglas.esSecreta ? textos.votoSecreto : textos.votoNominal),
            const SizedBox(height: 6),
            Text(textos.reglasFijas, style: estilos.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 4),
                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
