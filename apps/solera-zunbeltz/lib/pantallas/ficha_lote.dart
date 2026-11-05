import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/carga_ganadera.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../modelos/zona_finca.dart';
import '../servicios/generador_libro_explotacion.dart';
import 'ficha_animal.dart';
import 'formularios_ganado.dart';
import 'pantalla_ganado.dart';
import 'pantalla_inventario.dart' show numeroLegible;
import 'widgets/confirmar_borrado.dart';
import 'widgets/ganado_visual.dart';
import 'widgets/relleno_seguro.dart';

/// «Cura o tratamiento · ivermectina · 1 ml/10 kg · carne 28 d».
String describirEvento(
        EventoGanado evento, AppLocalizations textos, String idioma) =>
    [
      tipoDeEvento(evento, idioma),
      if (detalleEvento(evento, textos) case final detalle
          when detalle.isNotEmpty)
        detalle,
    ].join(' · ');

String tipoDeEvento(EventoGanado evento, String idioma) =>
    buscarOpcion(tiposEventoGanado, evento.tipo)?.etiqueta(idioma) ??
    evento.tipo;

/// Lo de un evento sin su tipo: «ivermectina · 1 ml/10 kg · carne 28 d».
String detalleEvento(EventoGanado evento, AppLocalizations textos) {
  return [
    if (evento.sustanciaActiva.isNotEmpty) evento.sustanciaActiva,
    if (evento.dosis.isNotEmpty) evento.dosis,
    if (evento.plazoSupresionCarneDias > 0)
      textos.ganPlazoCarne(evento.plazoSupresionCarneDias),
    if (evento.plazoSupresionLecheDias > 0)
      textos.ganPlazoLeche(evento.plazoSupresionLecheDias),
    if (evento.pesoKg != null) '${numeroLegible(evento.pesoKg!)} kg',
    if (evento.crias > 0) textos.ganCriasN(evento.crias),
    if (evento.cabezas > 0) textos.ganCabezas(evento.cabezas),
    if (evento.descripcion.isNotEmpty) evento.descripcion,
  ].join(' · ');
}

IconData iconoEvento(String tipo) => switch (tipo) {
      tipoEventoTratamiento => Icons.medication_outlined,
      'saneamiento' => Icons.vaccines_outlined,
      tipoEventoPesaje => Icons.scale_outlined,
      tipoEventoParto => Icons.child_friendly_outlined,
      'incidencia' => Icons.report_problem_outlined,
      _ => Icons.edit_note,
    };

/// Hoja con un evento o un movimiento y, si se puede, el botón de borrarlo.
Future<bool> mostrarApunteGanado(BuildContext context,
    {required String titulo,
    required String detalle,
    required String autorUid,
    required Future<void> Function() borrar,
    (IconData, String, VoidCallback)? accionExtra}) async {
  final textos = AppLocalizations.of(context);
  final puedeBorrar = politicaEspacioActual.puedeEditarGanado(autorUid);
  final borrado = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (contexto) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(contexto).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(detalle),
            if (accionExtra
                case (final icono, final texto, final alPulsar)) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: alPulsar,
                icon: Icon(icono),
                label: Text(texto),
              ),
            ],
            if (puedeBorrar) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  if (!await confirmarBorrado(contexto)) return;
                  await borrar();
                  if (contexto.mounted) Navigator.pop(contexto, true);
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(textos.comunBorrar),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  return borrado == true;
}

/// Un lote: dónde está, sus animales y su historial (movimientos y
/// manejo). Desde aquí se mueve, se apunta una cura y se añaden animales.
class FichaLote extends StatefulWidget {
  const FichaLote({super.key, required this.loteId});

  final int loteId;

  @override
  State<FichaLote> createState() => _FichaLoteState();
}

class _FichaLoteState extends State<FichaLote> {
  /// La hoja de un movimiento para acompañar el traslado.
  Future<void> _hojaMovimiento(
      LoteGanado lote, MovimientoGanado movimiento) async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final documento = await generarHojaMovimientoPdf(
      textos: textos,
      idioma: idioma,
      movimiento: movimiento,
      lote: lote,
      animalesDelLote: _animales,
      zonas: _zonas,
    );
    await Printing.sharePdf(
        bytes: documento.bytes, filename: documento.nombreFichero);
  }

  final _bd = BaseDatosSoleraZunbeltz();
  LoteGanado? _lote;
  List<Animal> _animales = const [];
  List<MovimientoGanado> _movimientos = const [];
  List<EventoGanado> _eventos = const [];
  Map<int, String> _zonas = const {};
  Map<int, ZonaFinca> _zonasPorId = const {};
  bool _cargando = true;
  bool _verTodoManejo = false;
  bool _verTodosAnimales = false;

  /// Lo que cabe sin desplegar en Manejo y en Animales.
  static const _filasPlegadas = 3;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lote = await _bd.obtenerLote(widget.loteId);
    final animales = await _bd.listarAnimales(loteId: widget.loteId);
    final movimientos = await _bd.listarMovimientos(loteId: widget.loteId);
    final eventos = await _bd.listarEventosGanado(loteId: widget.loteId);
    final zonas = await nombresDeZonas(_bd);
    final zonasPorId = {
      for (final zona in await _bd.listarZonas())
        if (zona.id != null) zona.id!: zona,
    };
    if (!mounted) return;
    setState(() {
      _lote = lote;
      _animales = animales;
      _movimientos = movimientos;
      _eventos = eventos;
      _zonas = zonas;
      _zonasPorId = zonasPorId;
      _cargando = false;
    });
  }

  Future<void> _tras(Future<bool?> accion) async {
    if (await accion == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Future<bool?> _ir(Widget pantalla) => Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => pantalla));

  Future<void> _borrarLote() async {
    if (!await confirmarBorrado(context)) return;
    await _bd.borrarLote(widget.loteId);
    avisarCambioDatos();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final lote = _lote;
    if (_cargando || lote == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: _cargando
                ? const CircularProgressIndicator()
                : Text(textos.ganNoExiste)),
      );
    }
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final ahora = DateTime.now();
    final politica = politicaEspacioActual;
    final puedeEditar = politica.puedeEditarGanado(lote.autorUid);
    final puedeRegistrar = politica.puedeRegistrarGanado && lote.activo;
    final activos = _animales.where((animal) => animal.activo).toList();
    final cabezas = cabezasDeLote(lote, _animales);
    final conCrotal =
        activos.where((animal) => animal.identificacion.isNotEmpty).length;
    final ugm = ugmDeLote(lote, _animales, ahora);
    final ultimo = ultimoMovimiento(_movimientos);
    final zonaActual = ultimo == null || ultimo.esSalida
        ? null
        : _zonasPorId[ultimo.zonaDestinoId];

    final chipsCabecera = <Widget>[
      if (lote.especie.isNotEmpty)
        ChipGanado(
            texto: etiquetaEspecie(lote.especie, idioma),
            fondo: esquema.surfaceContainerHigh,
            color: esquema.onSurface),
      if (lote.ecologico)
        ChipGanado(
            texto: lote.cicloCorto
                ? textos.ganChipEcologicoCicloCorto
                : textos.ganChipEcologico,
            icono: Icons.eco_outlined,
            fondo: colores.fondoHecha,
            color: colores.hecha),
      ChipGanado(
          texto: lote.titularUid.isEmpty
              ? textos.ganTitularEspacio
              : titularCorto(lote, textos),
          fondo: esquema.surfaceContainerHigh,
          color: esquema.onSurface),
      if (!lote.activo)
        ChipGanado(
            texto: textos.ganChipCerrado,
            icono: Icons.archive_outlined,
            fondo: esquema.surfaceContainerHighest,
            color: esquema.onSurfaceVariant),
    ];

    final manejo = _filasManejo(lote, textos, idioma);
    final manejoVisible =
        _verTodoManejo ? manejo : manejo.take(_filasPlegadas).toList();
    final animalesVisibles =
        _verTodosAnimales ? activos : activos.take(_filasPlegadas).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(lote.nombre),
        actions: [
          if (puedeEditar) ...[
            IconButton(
              tooltip: textos.ganEditarLote,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _tras(_ir(FormularioLote(lote: lote))),
            ),
            PopupMenuButton<VoidCallback>(
              onSelected: (accion) => accion(),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _borrarLote,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline),
                    title: Text(textos.comunBorrar),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      floatingActionButton: puedeRegistrar
          ? FloatingActionButton.extended(
              onPressed: () => _tras(_ir(FormularioEventoGanado(
                  loteId: lote.id, titulo: lote.nombre))),
              icon: const Icon(Icons.edit_note),
              label: Text(textos.ganApuntarManejoCorto),
            )
          : null,
      body: ListView(
        padding: rellenoSobreBarraSistema(
            context, const EdgeInsets.fromLTRB(16, 4, 16, 96)),
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: chipsCabecera),
          const SizedBox(height: 16),
          _TarjetaUbicacion(
            zona: zonaActual,
            donde: dondeEstaRebano(
                ultimo,
                {
                  for (final MapEntry(:key, :value) in _zonasPorId.entries)
                    key: value.nombre
                },
                textos),
            desde: ultimo == null
                ? null
                : DateFormat.MMMMd(idioma).format(
                    DateTime.fromMillisecondsSinceEpoch(ultimo.fechaMs)),
            alMover: puedeRegistrar
                ? () => _tras(_ir(FormularioMovimiento(lote: lote)))
                : null,
          ),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _Cifra(
                    valor: '$cabezas', rotulo: textos.ganCabezasEnTotal)),
            Expanded(
                child: _Cifra(
                    valor: '$conCrotal', rotulo: textos.ganConCrotalRotulo)),
            Expanded(
                child: _Cifra(
                    valor: '${cabezas - conCrotal}',
                    rotulo: textos.ganSinCrotalRotulo)),
            if (ugm > 0)
              Expanded(
                  child: _Cifra(
                      valor: numeroConComa(ugm, decimales: 1),
                      rotulo: textos.ganUgmRotulo)),
          ]),
          if (lote.notas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(lote.notas,
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant)),
          ],
          ..._estadoSanitario(lote, ahora, textos, idioma),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Text(textos.ganManejo, style: estilos.titleLarge)),
            if (manejo.length > _filasPlegadas)
              TextButton(
                onPressed: () =>
                    setState(() => _verTodoManejo = !_verTodoManejo),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_verTodoManejo ? textos.ganVerMenos : textos.ganVerTodo),
                  Icon(_verTodoManejo ? Icons.expand_less : Icons.chevron_right,
                      size: 20),
                ]),
              ),
          ]),
          if (manejo.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(textos.ganSinHistorial,
                  style: estilos.bodyMedium
                      ?.copyWith(color: esquema.onSurfaceVariant)),
            ),
          ...manejoVisible,
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: Text(textos.ganAnimalesDelLote(activos.length),
                  style: estilos.titleLarge),
            ),
            if (puedeRegistrar)
              IconButton(
                tooltip: textos.ganNuevoAnimal,
                icon: const Icon(Icons.add),
                onPressed: () => _tras(_ir(FormularioAnimal(loteId: lote.id))),
              ),
            if (activos.length > _filasPlegadas)
              TextButton(
                onPressed: () =>
                    setState(() => _verTodosAnimales = !_verTodosAnimales),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(_verTodosAnimales
                      ? textos.ganVerMenos
                      : textos.ganVerLosN(activos.length)),
                  Icon(
                      _verTodosAnimales
                          ? Icons.expand_less
                          : Icons.chevron_right,
                      size: 20),
                ]),
              ),
          ]),
          const SizedBox(height: 8),
          if (activos.isEmpty)
            Text(textos.ganLoteSinAnimales,
                style: estilos.bodyMedium
                    ?.copyWith(color: esquema.onSurfaceVariant))
          else
            Container(
              decoration: BoxDecoration(
                color: esquema.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (var indice = 0;
                    indice < animalesVisibles.length;
                    indice++) ...[
                  if (indice > 0)
                    Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: esquema.outlineVariant),
                  _FilaAnimal(
                    animal: animalesVisibles[indice],
                    ahora: ahora,
                    alPulsar: () => _tras(_ir(
                        FichaAnimal(animalId: animalesVisibles[indice].id!))),
                  ),
                ],
              ]),
            ),
        ],
      ),
    );
  }

  /// Ecológico (tratamientos que cuentan, con su barra) y plazos de
  /// supresión vigentes. Nada si no hay ni lo uno ni lo otro.
  List<Widget> _estadoSanitario(
      LoteGanado lote, DateTime ahora, AppLocalizations textos, String idioma) {
    final supresion =
        supresionVigente(_eventos, ahora, ecologico: lote.ecologico);
    if (!lote.ecologico && !supresion.hayAlguna) return const [];
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final apagado =
        estilos.bodySmall?.copyWith(color: esquema.onSurfaceVariant);
    final formato = DateFormat.MMMMd(idioma);
    final estado = estadoTratamientosEcologico(_eventos, ahora,
        cicloCorto: lote.cicloCorto);
    final colorEstado = estado.superado
        ? colores.bloqueada
        : estado.enElLimite
            ? colores.pendiente
            : colores.hecha;
    Widget filaSupresion(String texto) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colores.fondoPendiente,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.hourglass_bottom, color: colores.pendiente),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(texto, style: estilos.titleSmall),
                  if (lote.ecologico)
                    Text(textos.ganPlazoDoble, style: apagado),
                ],
              ),
            ),
          ]),
        );
    return [
      const SizedBox(height: 24),
      Text(textos.ganEstadoSanitario, style: estilos.titleLarge),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: esquema.surfaceContainerLow,
          borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (lote.ecologico) ...[
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textos.ganTratamientosAlopaticos,
                          style: estilos.titleSmall),
                      Text(textos.ganAlPasarDeLimite(estado.limite),
                          style: apagado),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(textos.ganNDeLimite(estado.tratamientos, estado.limite),
                      style: estilos.titleLarge?.copyWith(
                          fontFamily: familiaTextoZunbeltz,
                          fontWeight: FontWeight.w700,
                          color: estado.superado ? colorEstado : null)),
                  const SizedBox(height: 6),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    for (var indice = 0; indice < estado.limite; indice++)
                      Container(
                        width: 18,
                        height: 5,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: indice < estado.tratamientos
                              ? colorEstado
                              : esquema.outlineVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ]),
                ]),
              ]),
              if (estado.superado || estado.enElLimite)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      estado.superado
                          ? textos.ganEcoSuperado
                          : textos.ganEcoEnLimite,
                      style: estilos.bodySmall?.copyWith(color: colorEstado)),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(textos.ganEcoNoCuentan, style: apagado),
              ),
              if (supresion.hayAlguna)
                Divider(height: 24, color: esquema.outlineVariant),
            ],
            if (supresion.carneHasta != null)
              filaSupresion(textos
                  .ganCarneLibreDesde(formato.format(supresion.carneHasta!))),
            if (supresion.lecheHasta != null)
              filaSupresion(textos
                  .ganLecheLibreDesde(formato.format(supresion.lecheHasta!))),
          ],
        ),
      ),
    ];
  }

  /// Movimientos y eventos, del más reciente al más antiguo.
  List<Widget> _filasManejo(
      LoteGanado lote, AppLocalizations textos, String idioma) {
    final colores = context.coloresZunbeltz;
    final esquema = context.esquemaZunbeltz;
    final formato = DateFormat('dd/MM/yyyy', idioma);
    final filas = <(int, Widget)>[
      for (final movimiento in _movimientos)
        (
          movimiento.fechaMs,
          _FilaManejo(
            fechaMs: movimiento.fechaMs,
            icono: iconoMovimiento(movimiento.tipo),
            fondo: colores.fondoHecha,
            color: colores.hecha,
            titulo: textos.ganMoverRebano,
            detalle: [
              trayectoMovimiento(movimiento, _zonas, textos),
              if (movimiento.cabezas > 0) textos.ganCabezas(movimiento.cabezas),
              if (movimiento.guia.isNotEmpty)
                '${textos.ganGuia}: ${movimiento.guia}',
            ].join(' · '),
            alPulsar: () => _tras(mostrarApunteGanado(context,
                titulo: trayectoMovimiento(movimiento, _zonas, textos),
                detalle: [
                  formato.format(
                      DateTime.fromMillisecondsSinceEpoch(movimiento.fechaMs)),
                  if (movimiento.cabezas > 0)
                    textos.ganCabezas(movimiento.cabezas),
                  if (movimiento.guia.isNotEmpty)
                    '${textos.ganGuia}: ${movimiento.guia}',
                  if (movimiento.notas.isNotEmpty) movimiento.notas,
                ].join(' · '),
                autorUid: movimiento.autorUid,
                borrar: () => _bd.borrarMovimiento(movimiento.id!),
                accionExtra: (
                  Icons.picture_as_pdf_outlined,
                  textos.libroHoja,
                  () => _hojaMovimiento(lote, movimiento),
                ))),
          )
        ),
      for (final evento in _eventos)
        (
          evento.fechaMs,
          _FilaManejo(
            fechaMs: evento.fechaMs,
            icono: iconoEvento(evento.tipo),
            fondo: evento.tipo == tipoEventoTratamiento
                ? colores.fondoPendiente
                : esquema.surfaceContainerHigh,
            color: evento.tipo == tipoEventoTratamiento
                ? colores.pendiente
                : esquema.onSurfaceVariant,
            titulo: tipoDeEvento(evento, idioma),
            detalle: detalleEvento(evento, textos),
            alPulsar: () => _tras(mostrarApunteGanado(context,
                titulo: describirEvento(evento, textos, idioma),
                detalle: [
                  formato.format(
                      DateTime.fromMillisecondsSinceEpoch(evento.fechaMs)),
                  if (evento.veterinario.isNotEmpty) evento.veterinario,
                  if (evento.receta.isNotEmpty)
                    '${textos.ganReceta}: ${evento.receta}',
                ].join(' · '),
                autorUid: evento.autorUid,
                borrar: () => _bd.borrarEventoGanado(evento.id!))),
          )
        ),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final (_, fila) in filas) fila];
  }
}

/// Dónde está el rebaño: el plano de la pieza, su nombre, desde cuándo y
/// la superficie, con «Mover».
class _TarjetaUbicacion extends StatelessWidget {
  const _TarjetaUbicacion({
    required this.zona,
    required this.donde,
    required this.desde,
    required this.alMover,
  });

  final ZonaFinca? zona;
  final String donde;
  final String? desde;
  final VoidCallback? alMover;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final apagado =
        estilos.bodySmall?.copyWith(color: esquema.onSurfaceVariant);
    final zona = this.zona;
    return Container(
      decoration: BoxDecoration(
        color: esquema.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (zona != null && zona.vertices.length >= 3)
          PlanoPieza(vertices: zona.vertices),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(textos.ganEstaEn, style: apagado),
                  Text(donde,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: estilos.titleLarge),
                  if (desde != null || zona != null)
                    Text(
                        [
                          if (desde != null) textos.ganDesdeElDia(desde!),
                          if (zona != null && zona.superficieHa > 0)
                            '${NumberFormat('#,##0.00', idioma).format(zona.superficieHa)} ha',
                        ].join(' · '),
                        style: apagado),
                ],
              ),
            ),
            if (alMover != null)
              FilledButton.icon(
                onPressed: alMover,
                icon: const Icon(Icons.moving, size: 18),
                label: Text(textos.ganMover),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _Cifra extends StatelessWidget {
  const _Cifra({required this.valor, required this.rotulo});
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(valor,
          style: estilos.headlineMedium?.copyWith(
              fontFamily: familiaTextoZunbeltz, fontWeight: FontWeight.w700)),
      Text(rotulo,
          style: estilos.bodySmall
              ?.copyWith(color: context.esquemaZunbeltz.onSurfaceVariant)),
    ]);
  }
}

/// Un apunte de manejo: día y mes, icono sobre su color, qué y detalle.
class _FilaManejo extends StatelessWidget {
  const _FilaManejo({
    required this.fechaMs,
    required this.icono,
    required this.fondo,
    required this.color,
    required this.titulo,
    required this.detalle,
    required this.alPulsar,
  });

  final int fechaMs;
  final IconData icono;
  final Color fondo;
  final Color color;
  final String titulo;
  final String detalle;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final idioma = Localizations.localeOf(context).languageCode;
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final dia = DateTime.fromMillisecondsSinceEpoch(fechaMs);
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(radioZunbeltz),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          SizedBox(
            width: 44,
            child: Column(children: [
              Text('${dia.day}',
                  style: estilos.titleLarge?.copyWith(
                      fontFamily: familiaTextoZunbeltz,
                      fontWeight: FontWeight.w700)),
              Text(DateFormat('MMM', idioma).format(dia).replaceAll('.', ''),
                  style: estilos.bodySmall
                      ?.copyWith(color: esquema.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: fondo, borderRadius: BorderRadius.circular(12)),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: estilos.titleMedium),
                if (detalle.isNotEmpty)
                  Text(detalle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: estilos.bodyMedium
                          ?.copyWith(color: esquema.onSurfaceVariant)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// Un animal del rebaño: su crotal en amarillo (o el nombre si no tiene) y
/// nombre, sexo y edad.
class _FilaAnimal extends StatelessWidget {
  const _FilaAnimal(
      {required this.animal, required this.ahora, required this.alPulsar});

  final Animal animal;
  final DateTime ahora;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final estilos = Theme.of(context).textTheme;
    final esquema = context.esquemaZunbeltz;
    final nacimiento = animal.fechaNacimientoMs;
    final meses = nacimiento == null
        ? null
        : mesesCumplidos(
            DateTime.fromMillisecondsSinceEpoch(nacimiento), ahora);
    final detalle = [
      if (animal.identificacion.isNotEmpty && animal.nombre.isNotEmpty)
        animal.nombre,
      if (animal.raza.isNotEmpty) animal.raza,
      if (buscarOpcion(sexosAnimal, animal.sexo) case final sexo?)
        sexo.etiqueta(idioma),
      if (meses != null)
        meses >= 24
            ? textos.ganEdadAnios(meses ~/ 12)
            : textos.ganEdadMeses(meses),
    ].join(' · ');
    return InkWell(
      onTap: alPulsar,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (animal.identificacion.isNotEmpty)
                  EtiquetaCrotal(identificacion: animal.identificacion)
                else
                  Text(animal.nombre.isEmpty ? '—' : animal.nombre,
                      style: estilos.titleMedium),
                if (detalle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(detalle,
                        style: estilos.bodyMedium
                            ?.copyWith(color: esquema.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: esquema.onSurfaceVariant),
        ]),
      ),
    );
  }
}
