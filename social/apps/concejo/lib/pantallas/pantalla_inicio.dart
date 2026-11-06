import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import 'ficha_asunto.dart';
import 'pantalla_se_ha_hecho.dart';
import 'textos_dominio.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key, required this.estado});

  final EstadoConcejo estado;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  var _pestana = 0;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.estado,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(widget.estado.nombreEspacio),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: _FranjaEjemplo(texto: textos.ejemploAviso),
          ),
        ),
        body: _pestana == 0
            ? _ListaAsuntos(estado: widget.estado)
            : PantallaSeHaHecho(estado: widget.estado),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _pestana,
          onDestinationSelected: (indice) => setState(() => _pestana = indice),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.forum_outlined),
              selectedIcon: const Icon(Icons.forum),
              label: textos.pestanaAsuntos,
            ),
            NavigationDestination(
              icon: const Icon(Icons.task_alt_outlined),
              selectedIcon: const Icon(Icons.task_alt),
              label: textos.pestanaSeHaHecho,
            ),
          ],
        ),
      ),
    );
  }
}

class _FranjaEjemplo extends StatelessWidget {
  const _FranjaEjemplo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colores.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        texto,
        style: TextStyle(color: colores.onSecondaryContainer, fontSize: 13),
      ),
    );
  }
}

class _ListaAsuntos extends StatelessWidget {
  const _ListaAsuntos({required this.estado});

  final EstadoConcejo estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    // Lo que pide a la gente actuar ya, primero.
    const orden = [
      FaseAsunto.decision,
      FaseAsunto.debate,
      FaseAsunto.seguimiento
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final fase in orden) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(textos.fase(fase),
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (estado.asuntosEnFase(fase).isEmpty)
            Text(textos.sinAsuntos,
                style: Theme.of(context).textTheme.bodySmall)
          else
            for (final asunto in estado.asuntosEnFase(fase))
              _TarjetaAsunto(estado: estado, asunto: asunto),
        ],
      ],
    );
  }
}

class _TarjetaAsunto extends StatelessWidget {
  const _TarjetaAsunto({required this.estado, required this.asunto});

  final EstadoConcejo estado;
  final Asunto asunto;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final fase = asunto.faseEn(estado.ahora);
    final pie = switch (fase) {
      FaseAsunto.debate =>
        textos.decisionAunNo(textos.fecha(asunto.inicioDecision)),
      FaseAsunto.decision => estado.heVotado(asunto.uid)
          ? textos.yaHasVotado
          : textos.calendarioDecision(textos.fecha(asunto.inicioDecision),
              textos.fecha(asunto.finDecision)),
      _ => textos.tipoDecision(asunto.tipoDecision),
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => FichaAsunto(estado: estado, asuntoUid: asunto.uid),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(asunto.titulo,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(asunto.resumen,
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text(pie, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
