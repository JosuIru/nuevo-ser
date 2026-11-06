import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import '../servidor/sincronizador.dart';
import 'dialogos.dart';
import 'ficha_asunto.dart';
import 'formulario_asunto.dart';
import 'pantalla_personas.dart';
import 'pantalla_se_ha_hecho.dart';
import 'textos_dominio.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio(
      {super.key, required this.estado, this.sincronizador, this.alSalir});

  final EstadoConcejo estado;

  /// `null` en el pueblo de ejemplo.
  final Sincronizador? sincronizador;
  final VoidCallback? alSalir;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  var _pestana = 0;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final sincronizador = widget.sincronizador;
    return ListenableBuilder(
      listenable: Listenable.merge(
          [widget.estado, if (sincronizador != null) sincronizador]),
      builder: (context, _) {
        final franja = widget.estado.esEjemplo
            ? textos.ejemploAviso
            : _avisoConexion(textos, sincronizador);
        final rechazadas = sincronizador?.rechazadas ?? const [];
        final cuerpo = _pestana == 0
            ? _ListaAsuntos(estado: widget.estado)
            : PantallaSeHaHecho(estado: widget.estado);
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.estado.nombreEspacio),
            actions: [
              if (widget.estado.soyMesa)
                IconButton(
                  tooltip: textos.personas,
                  icon: const Icon(Icons.badge_outlined),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PantallaPersonas(
                        estado: widget.estado, sincronizador: sincronizador),
                  )),
                ),
              if (widget.estado.esEjemplo) _MenuVerComo(estado: widget.estado),
              if (widget.estado.esEjemplo && widget.alSalir != null)
                IconButton(
                  tooltip: textos.salir,
                  onPressed: widget.alSalir,
                  icon: const Icon(Icons.logout),
                ),
              if (sincronizador != null)
                _MenuConexion(
                    sincronizador: sincronizador, alSalir: widget.alSalir),
            ],
            bottom: franja == null
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(32),
                    child: _FranjaEjemplo(texto: franja),
                  ),
          ),
          body: Column(children: [
            if (rechazadas.isNotEmpty)
              MaterialBanner(
                content: Text(textos.rechazadasAviso(
                    rechazadas.length, rechazadas.last.motivo)),
                actions: [
                  TextButton(
                    onPressed: sincronizador!.olvidarRechazadas,
                    child: Text(textos.entendido),
                  ),
                ],
              ),
            Expanded(
              child: sincronizador == null
                  ? cuerpo
                  : RefreshIndicator(
                      onRefresh: sincronizador.sincronizar, child: cuerpo),
            ),
          ]),
          floatingActionButton: _pestana == 0 && widget.estado.soyMesa
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FormularioAsunto(estado: widget.estado),
                  )),
                  icon: const Icon(Icons.add),
                  label: Text(textos.nuevoAsunto),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _pestana,
            onDestinationSelected: (indice) =>
                setState(() => _pestana = indice),
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
        );
      },
    );
  }

  /// Lo que hay que saber de la conexión, o nada si todo está al día.
  String? _avisoConexion(
      AppLocalizations textos, Sincronizador? sincronizador) {
    if (sincronizador == null) return null;
    if (sincronizador.codigoIncorrecto) return textos.codigoCaducadoAviso;
    if (sincronizador.sinConexion) return textos.sinConexionAviso;
    if (sincronizador.pendientes > 0) {
      return textos.pendientesAviso(sincronizador.pendientes);
    }
    return null;
  }
}

enum _OpcionConexion { actualizar, salir }

class _MenuConexion extends StatelessWidget {
  const _MenuConexion({required this.sincronizador, this.alSalir});

  final Sincronizador sincronizador;
  final VoidCallback? alSalir;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return PopupMenuButton<_OpcionConexion>(
      onSelected: (opcion) async {
        switch (opcion) {
          case _OpcionConexion.actualizar:
            await sincronizador.sincronizar();
          case _OpcionConexion.salir:
            final seguro = await confirmar(context,
                mensaje: textos.confirmarSalir, accion: textos.salir);
            if (!seguro) return;
            await sincronizador.salir();
            alSalir?.call();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
            value: _OpcionConexion.actualizar,
            child: Text(textos.sincronizarAhora)),
        PopupMenuItem(value: _OpcionConexion.salir, child: Text(textos.salir)),
      ],
    );
  }
}

/// Solo en el pueblo de ejemplo: probar la app como vecina o como mesa.
class _MenuVerComo extends StatelessWidget {
  const _MenuVerComo({required this.estado});

  final EstadoConcejo estado;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      tooltip: textos.verComo,
      icon: const Icon(Icons.switch_account_outlined),
      onSelected: estado.verComo,
      itemBuilder: (_) => [
        for (final persona in estado.personas)
          CheckedPopupMenuItem(
            value: persona.uid,
            checked: persona.uid == estado.personaActual.uid,
            child: Text('${persona.nombre} · '
                '${persona.esMesaEn(estado.ahora) ? textos.rolMesa : textos.rolVecina}'),
          ),
      ],
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
      FaseAsunto.borrador,
      FaseAsunto.decision,
      FaseAsunto.debate,
      FaseAsunto.seguimiento
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final fase in orden)
          // Los borradores solo salen si hay alguno (y solo para la mesa).
          if (fase != FaseAsunto.borrador ||
              estado.asuntosEnFase(fase).isNotEmpty) ...[
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
