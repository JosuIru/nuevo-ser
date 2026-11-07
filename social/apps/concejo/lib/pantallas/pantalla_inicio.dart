import 'package:flutter/material.dart';

import '../dominio/asunto.dart';
import '../estado/avisos.dart';
import '../estado/estado_concejo.dart';
import '../l10n/app_localizations.dart';
import '../servidor/almacen_local.dart';
import '../servidor/sincronizador.dart';
import 'dialogos.dart';
import 'ficha_asunto.dart';
import 'ficha_sesion.dart';
import 'ficha_tarea.dart';
import 'formulario_anuncio.dart';
import 'formulario_asunto.dart';
import 'formulario_sesion.dart';
import 'formulario_tarea.dart';
import 'pantalla_asambleas.dart';
import 'pantalla_guia.dart';
import 'pantalla_personas.dart';
import 'pantalla_se_ha_hecho.dart';
import 'pantalla_tablon.dart';
import 'pantalla_tareas.dart';
import 'textos_dominio.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio(
      {super.key,
      required this.estado,
      this.sincronizador,
      this.alSalir,
      this.almacen});

  final EstadoConcejo estado;

  /// `null` en el pueblo de ejemplo.
  final Sincronizador? sincronizador;
  final VoidCallback? alSalir;

  /// Dónde recordar los avisos quitados; sin él, solo mientras dure.
  final AlmacenLocal? almacen;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  var _pestana = 0;
  late final _avisosVistos = AvisosVistos(almacen: widget.almacen);

  @override
  void dispose() {
    _avisosVistos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final sincronizador = widget.sincronizador;
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.estado,
        _avisosVistos,
        if (sincronizador != null) sincronizador
      ]),
      builder: (context, _) {
        final franja = widget.estado.esEjemplo
            ? textos.ejemploAviso
            : _avisoConexion(textos, sincronizador);
        final rechazadas = sincronizador?.rechazadas ?? const [];
        final cuerpo = switch (_pestana) {
          0 =>
            _ListaAsuntos(estado: widget.estado, avisosVistos: _avisosVistos),
          1 => PantallaAsambleas(estado: widget.estado),
          2 => PantallaTareas(estado: widget.estado),
          3 => PantallaTablon(estado: widget.estado),
          _ => PantallaSeHaHecho(estado: widget.estado),
        };
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.estado.nombreEspacio),
            actions: [
              IconButton(
                tooltip: textos.guia,
                icon: const Icon(Icons.help_outline),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PantallaGuia(
                      nombreEspacio: widget.estado.nombreEspacio,
                      soyMesa: widget.estado.soyMesa),
                )),
              ),
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
          floatingActionButton: _botonNuevo(textos),
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
                icon: const Icon(Icons.groups_outlined),
                selectedIcon: const Icon(Icons.groups),
                label: textos.pestanaAsambleas,
              ),
              NavigationDestination(
                icon: const Icon(Icons.handyman_outlined),
                selectedIcon: const Icon(Icons.handyman),
                label: textos.pestanaTareas,
              ),
              NavigationDestination(
                icon: const Icon(Icons.push_pin_outlined),
                selectedIcon: const Icon(Icons.push_pin),
                label: textos.pestanaTablon,
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

  /// El botón de crear de cada pestaña: asuntos, asambleas y tareas los
  /// lleva la mesa; en el tablón publica cualquiera.
  Widget? _botonNuevo(AppLocalizations textos) {
    final mesa = widget.estado.soyMesa;
    final (etiqueta, formulario) = switch (_pestana) {
      0 when mesa => (
          textos.nuevoAsunto,
          FormularioAsunto(estado: widget.estado)
        ),
      1 when mesa => (
          textos.convocarAsamblea,
          FormularioSesion(estado: widget.estado)
        ),
      2 when mesa => (
          textos.nuevaTarea,
          FormularioTarea(estado: widget.estado)
        ),
      3 => (textos.publicarAnuncio, FormularioAnuncio(estado: widget.estado)),
      _ => (null, null),
    };
    if (etiqueta == null || formulario == null) return null;
    return FloatingActionButton.extended(
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => formulario)),
      icon: const Icon(Icons.add),
      label: Text(etiqueta),
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
  const _ListaAsuntos({required this.estado, required this.avisosVistos});

  final EstadoConcejo estado;
  final AvisosVistos avisosVistos;

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
    final yo = estado.personaActual.uid;
    final avisos = avisosPara(estado);
    final pendientes = avisosVistos.pendientes(yo, avisos);
    // «Nuevo» y «hay resultado» van en la tarjeta del asunto y se quitan al
    // abrirlo; arriba, solo lo que pide hacer algo.
    bool vaEnLaTarjeta(Aviso aviso) =>
        aviso.tipo == TipoAviso.asuntoNuevo ||
        aviso.tipo == TipoAviso.resultado;
    final paraTi = pendientes.where((a) => !vaEnLaTarjeta(a)).toList();
    List<Aviso> deLaTarjeta(Asunto asunto) => [
          for (final aviso in pendientes)
            if (vaEnLaTarjeta(aviso) && aviso.asuntoUid == asunto.uid) aviso,
        ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (paraTi.isNotEmpty) ...[
          Text(textos.paraTi, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final aviso in paraTi)
            _TarjetaAviso(
              estado: estado,
              aviso: aviso,
              alQuitar: () => avisosVistos.quitar(yo, [aviso], avisos),
            ),
        ],
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
                _TarjetaAsunto(
                  estado: estado,
                  asunto: asunto,
                  avisos: deLaTarjeta(asunto),
                  alAbrir: (avisosDeLaTarjeta) =>
                      avisosVistos.quitar(yo, avisosDeLaTarjeta, avisos),
                ),
          ],
      ],
    );
  }
}

class _TarjetaAsunto extends StatelessWidget {
  const _TarjetaAsunto({
    required this.estado,
    required this.asunto,
    this.avisos = const [],
    this.alAbrir,
  });

  final EstadoConcejo estado;
  final Asunto asunto;

  /// «Nuevo» o «hay resultado», si la persona aún no lo ha abierto.
  final List<Aviso> avisos;
  final void Function(List<Aviso> avisos)? alAbrir;

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
        onTap: () {
          if (avisos.isNotEmpty) alAbrir?.call(avisos);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FichaAsunto(estado: estado, asuntoUid: asunto.uid),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(asunto.titulo,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final aviso in avisos)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _Etiqueta(
                        texto: aviso.tipo == TipoAviso.resultado
                            ? textos.etiquetaResultado
                            : textos.etiquetaNuevo),
                  ),
              ]),
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

class _TarjetaAviso extends StatelessWidget {
  const _TarjetaAviso(
      {required this.estado, required this.aviso, required this.alQuitar});

  final EstadoConcejo estado;
  final Aviso aviso;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final colores = Theme.of(context).colorScheme;
    final asuntoUid = aviso.asuntoUid;
    final asunto = asuntoUid == null ? null : estado.buscarAsunto(asuntoUid);
    final titulo = asunto?.titulo ?? '';
    final fecha = textos.fecha(aviso.fecha);
    final tareaUid = aviso.tareaUid;
    final tarea = tareaUid == null ? null : estado.tarea(tareaUid);
    final sesionUid = aviso.sesionUid;
    final sesion = sesionUid == null ? null : estado.sesion(sesionUid);
    String queDelCompromiso() => estado.compromisos
        .firstWhere((compromiso) => compromiso.uid == aviso.compromisoUid)
        .que;
    final (icono, texto) = switch (aviso.tipo) {
      TipoAviso.ultimosDias => (
          Icons.how_to_vote_outlined,
          textos.avisoUltimosDias(titulo, fecha)
        ),
      TipoAviso.compromisoVence => (
          Icons.event_outlined,
          textos.avisoCompromisoVence(queDelCompromiso(), fecha)
        ),
      TipoAviso.compromisoVencido => (
          Icons.event_busy_outlined,
          textos.avisoCompromisoVencido(queDelCompromiso(), fecha)
        ),
      TipoAviso.asamblea => (
          Icons.groups_outlined,
          textos.avisoAsamblea(
              sesion!.titulo, textos.fechaYHora(sesion.inicio), sesion.lugar)
        ),
      TipoAviso.asambleaAnulada => (
          Icons.event_busy_outlined,
          textos.avisoAsambleaAnulada(sesion!.titulo, sesion.motivoAnulacion)
        ),
      TipoAviso.tarea => (
          Icons.handyman_outlined,
          textos.avisoTarea(tarea!.titulo, textos.fechaYHora(tarea.inicio))
        ),
      TipoAviso.tareaAnulada => (
          Icons.event_busy_outlined,
          textos.avisoAsambleaAnulada(tarea!.titulo, tarea.motivoAnulacion)
        ),
      TipoAviso.mandatoAcaba => (
          Icons.autorenew,
          textos.avisoMandatoAcaba(fecha)
        ),
      TipoAviso.asuntoNuevo => (
          Icons.fiber_new_outlined,
          textos.avisoAsuntoNuevo(titulo, fecha)
        ),
      TipoAviso.resultado => (
          Icons.fact_check_outlined,
          textos.avisoResultado(titulo)
        ),
    };
    return Card(
      color: colores.tertiaryContainer,
      child: ListTile(
        leading: Icon(icono, color: colores.onTertiaryContainer),
        title:
            Text(texto, style: TextStyle(color: colores.onTertiaryContainer)),
        onTap: tarea != null
            ? () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      FichaTarea(estado: estado, tareaUid: tarea.uid),
                ))
            : sesion != null
                ? () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          FichaSesion(estado: estado, sesionUid: sesion.uid),
                    ))
                : asunto == null
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FichaAsunto(
                              estado: estado, asuntoUid: asunto.uid),
                        )),
        trailing: IconButton(
          tooltip: textos.quitarAviso,
          icon: const Icon(Icons.close),
          color: colores.onTertiaryContainer,
          onPressed: alQuitar,
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colores.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(texto,
          style: TextStyle(color: colores.onTertiaryContainer, fontSize: 12)),
    );
  }
}
