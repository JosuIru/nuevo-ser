import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../dominio/consentimiento.dart';
import '../dominio/recuento.dart';
import '../dominio/reglas_decision.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'tarjeta_compromiso.dart';
import 'textos_dominio.dart';

/// Resultado con las cifras con que se calculó (se puede rehacer a mano) y
/// los compromisos que salen del acuerdo.
class PestanaResultado extends StatelessWidget {
  const PestanaResultado(
      {super.key, required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilos = Theme.of(context).textTheme;
    final urna = estado.urna(asunto.uid);
    final reglas = asunto.reglas;
    final compromisos = estado.compromisosDe(asunto.uid);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (reglas.forma != FormaDecision.consentimiento)
          Text(textos.resultadoParticipacion(urna.personasQueHanParticipado),
              style: estilos.bodySmall),
        const SizedBox(height: 8),
        ...switch (reglas.forma) {
          FormaDecision.votacion =>
            _votacion(context, contarVotacion(reglas, urna)),
          FormaDecision.eleccionEntreOpciones =>
            _eleccion(context, reglas, contarEleccion(reglas, urna)),
          FormaDecision.presupuesto =>
            _presupuesto(context, contarPresupuesto(reglas, urna)),
          FormaDecision.consentimiento => [
              Text(
                switch (estado.consentimiento(asunto.uid).desenlace) {
                  DesenlaceConsentimiento.aprobada =>
                    textos.consentimientoAprobado,
                  DesenlaceConsentimiento.pasaAVotacionOAsamblea =>
                    textos.consentimientoPasa,
                  DesenlaceConsentimiento.enCurso => textos.recuentoEnCurso,
                },
                style: estilos.titleMedium,
              ),
            ],
        },
        const SizedBox(height: 24),
        Text(textos.seccionCompromisos, style: estilos.titleMedium),
        if (compromisos.isEmpty) Text(textos.sinCompromisos),
        if (estado.soyMesa)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => apuntarCompromiso(context, estado, asunto.uid),
              icon: const Icon(Icons.add_task),
              label: Text(textos.apuntarCompromiso),
            ),
          ),
        for (final compromiso in compromisos)
          TarjetaCompromiso(estado: estado, compromiso: compromiso),
      ],
    );
  }

  List<Widget> _votacion(BuildContext context, ResultadoVotacion resultado) {
    final textos = AppLocalizations.of(context);
    return [
      Text(
        switch (resultado.desenlace) {
          DesenlaceVotacion.aprobada => textos.resultadoAprobada,
          DesenlaceVotacion.rechazada => textos.resultadoRechazada,
          DesenlaceVotacion.sinQuorum => textos.resultadoSinQuorum,
        },
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      _Barra(
          etiqueta: textos.votoSi,
          valor: resultado.si,
          total: resultado.emitidos),
      _Barra(
          etiqueta: textos.votoNo,
          valor: resultado.no,
          total: resultado.emitidos),
      _Barra(
          etiqueta: textos.votoAbstencion,
          valor: resultado.abstenciones,
          total: resultado.emitidos),
    ];
  }

  List<Widget> _eleccion(BuildContext context, ReglasDecision reglas,
      ResultadoEleccion resultado) {
    final textos = AppLocalizations.of(context);
    return [
      if (resultado.empate) Text(textos.resultadoEmpate),
      if (!resultado.hayQuorum) Text(textos.resultadoSinQuorum),
      for (final opcion in reglas.opciones)
        _Barra(
          etiqueta: opcion.texto,
          valor: resultado.aceptacionesPorOpcion[opcion.id] ?? 0,
          total: resultado.papeletas,
          destacada:
              resultado.ganadoras.contains(opcion.id) && !resultado.empate,
          nota: resultado.ganadoras.contains(opcion.id) && !resultado.empate
              ? textos.resultadoGanadora
              : null,
        ),
    ];
  }

  List<Widget> _presupuesto(
      BuildContext context, ResultadoPresupuesto resultado) {
    final textos = AppLocalizations.of(context);
    return [
      if (!resultado.hayQuorum) Text(textos.resultadoSinQuorum),
      for (final linea in resultado.lineas)
        Card(
          child: ListTile(
            leading: Icon(
                linea.entra ? Icons.check_circle : Icons.remove_circle_outline),
            title: Text(linea.opcion.texto),
            subtitle: Text('${textos.euros(linea.opcion.costeEuros!)} · '
                '${textos.apoyos(linea.apoyos)}'),
            trailing: Text(switch (linea.motivo) {
              MotivoPresupuesto.entra => textos.presupuestoEntra,
              MotivoPresupuesto.noCabe => textos.presupuestoNoCabe,
              MotivoPresupuesto.sinApoyos => textos.presupuestoSinApoyos,
            }),
          ),
        ),
      Text(textos.sobrante(textos.euros(resultado.sobranteEuros))),
    ];
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.etiqueta,
    required this.valor,
    required this.total,
    this.destacada = false,
    this.nota,
  });

  final String etiqueta;
  final int valor;
  final int total;
  final bool destacada;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(etiqueta,
                  style: destacada
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null),
            ),
            Text('$valor'),
          ]),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total == 0 ? 0 : valor / total,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            color: destacada ? colores.primary : colores.secondary,
            backgroundColor: colores.surfaceContainerHighest,
          ),
          if (nota != null)
            Text(nota!, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
