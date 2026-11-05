import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../modelos/persona_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/punto_infraestructura.dart';
import '../modelos/zona_finca.dart';
import '../modelos/tarea_mantenimiento.dart';
import '../servicios/generador_parte_mantenimiento.dart';
import 'pantalla_peticiones.dart';
import 'widgets/acciones_tarea.dart';
import 'widgets/fila_tarea.dart';
import 'nueva_tarea.dart';
import '../utiles/estilos_tarea.dart';
import '../utiles/tareas_por_lugar.dart';
import '../estado/ver_en_mapa.dart';
import '../branding.dart';
import 'widgets/relleno_seguro.dart';
import '../estado/datos_notificador.dart';

/// Tablero de tareas de mantenimiento (pantalla 07 de la propuesta):
/// agrupadas por punto, pieza o finca, con «Mapa» para ir a cada sitio,
/// filtros en chips (finca, abiertas o un estado, prioridad, mías) y el
/// parte en PDF de lo filtrado.
class TableroTareas extends StatefulWidget {
  const TableroTareas({super.key});

  @override
  State<TableroTareas> createState() => _TableroTareasState();
}

class _TableroTareasState extends State<TableroTareas> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<Finca> _fincas = const [];
  List<TareaMantenimiento> _tareas = const [];
  Map<int, PuntoInfraestructura> _puntosPorId = const {};
  Map<int, ZonaFinca> _zonasPorId = const {};
  bool _cargando = true;
  bool _generandoPdf = false;

  int? _filtroFincaId;

  /// `abiertas` (todas menos las hechas, de partida), un estado concreto
  /// o `null` (todas).
  String? _filtroEstado = _estadoAbiertas;
  String? _filtroPrioridad;
  bool _soloMias = false;

  static const _estadoAbiertas = 'abiertas';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    var fincas = <Finca>[];
    var tareas = <TareaMantenimiento>[];
    var puntos = <PuntoInfraestructura>[];
    var zonas = <ZonaFinca>[];
    try {
      fincas = await _bd.listarFincas();
      tareas = await _bd.listarTareas();
      puntos = await _bd.listarPuntos();
      zonas = await _bd.listarZonas();
    } catch (_) {
      // Sin BD disponible mostramos el tablero vacío en vez de romper.
    }
    if (!mounted) return;
    setState(() {
      _fincas = fincas;
      _tareas = tareas;
      _puntosPorId = {
        for (final p in puntos)
          if (p.id != null) p.id!: p
      };
      _zonasPorId = {
        for (final z in zonas)
          if (z.id != null) z.id!: z
      };
      _cargando = false;
    });
  }

  Future<void> _marcarHecha(TareaMantenimiento tarea) =>
      marcarTareaHechaDesdeLista(context, tarea, _cargar);

  Future<void> _accionesTarea(TareaMantenimiento tarea) async {
    if (await mostrarAccionesTarea(context, tarea)) await _cargar();
  }

  /// Todos los filtros menos el de estado (para los contadores del chip).
  bool _pasaFiltrosMenosEstado(TareaMantenimiento t, String? miUid) {
    if (_filtroFincaId != null && t.fincaId != _filtroFincaId) return false;
    if (_filtroPrioridad != null && t.prioridad != _filtroPrioridad) {
      return false;
    }
    if (_soloMias && miUid != null && !t.tieneResponsable(miUid)) {
      return false;
    }
    return true;
  }

  bool _pasaEstado(TareaMantenimiento t, String? estado) => switch (estado) {
        null => true,
        _estadoAbiertas => t.estado != 'hecha',
        _ => t.estado == estado,
      };

  List<TareaMantenimiento> get _tareasFiltradas {
    final miUid = sesionEspacio.value?.persona.uid;
    return _tareas
        .where((t) =>
            _pasaFiltrosMenosEstado(t, miUid) && _pasaEstado(t, _filtroEstado))
        .toList(growable: false);
  }

  Future<void> _generarParte() async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    setState(() => _generandoPdf = true);
    try {
      final documento = await generarParteMantenimientoPdf(
        textos: textos,
        idioma: idioma,
        fincas: _fincas,
        tareas: _tareasFiltradas,
        puntosPorId: _puntosPorId,
        zonasPorId: _zonasPorId,
        definitivo: politicaEspacioActual.documentoDefinitivo(),
      );
      await Printing.sharePdf(
        bytes: documento.bytes,
        filename: documento.nombreFichero,
      );
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return ValueListenableBuilder<SesionEspacio?>(
      valueListenable: sesionEspacio,
      builder: (contexto, sesion, _) => _construir(textos, idioma, sesion),
    );
  }

  /// Nueva tarea de finca (sin punto ni pieza): la del filtro o, con varias,
  /// la que se elija.
  Future<void> _nuevaTarea() async {
    final textos = AppLocalizations.of(context);
    int? fincaId = _filtroFincaId;
    if (fincaId == null && _fincas.length == 1) fincaId = _fincas.single.id;
    if (fincaId == null && _fincas.isNotEmpty) {
      fincaId = await showModalBottomSheet<int>(
        context: context,
        showDragHandle: true,
        builder: (contexto) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(textos.tableroElegirFinca,
                  style: Theme.of(contexto).textTheme.titleMedium),
            ),
            for (final finca in _fincas)
              ListTile(
                leading: const Icon(Icons.home_work_outlined),
                title: Text(finca.nombre),
                onTap: () => Navigator.pop(contexto, finca.id),
              ),
          ]),
        ),
      );
    }
    if (fincaId == null || !mounted) return;
    final creada = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => NuevaTarea(fincaId: fincaId!)));
    if (creada == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Widget _construir(
      AppLocalizations textos, String idioma, SesionEspacio? sesion) {
    final tareas = _tareasFiltradas;
    final politica = politicaTareasActual;
    final miUid = sesion?.persona.uid;
    final grupos = agruparTareasPorLugar(
      tareas,
      puntosExistentes: _puntosPorId.keys.toSet(),
      zonasExistentes: _zonasPorId.keys.toSet(),
    );
    int contar(String? estado) => _tareas
        .where(
            (t) => _pasaFiltrosMenosEstado(t, miUid) && _pasaEstado(t, estado))
        .length;
    String etiquetaEstado(String? estado) => switch (estado) {
          null => textos.tableroTodosEstados,
          _estadoAbiertas => textos.tableroAbiertas(contar(estado)),
          _ =>
            '${buscarOpcion(estadosTarea, estado)?.etiqueta(idioma) ?? estado} ${contar(estado)}',
        };
    final fincaFiltrada =
        _fincas.where((finca) => finca.id == _filtroFincaId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(textos.tableroTitulo),
        actions: [
          if (!politica.modoLocal)
            IconButton(
              tooltip: textos.peticionesTitulo,
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PantallaPeticiones())),
            ),
          IconButton(
            tooltip: textos.tableroPartePdf,
            icon: _generandoPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            onPressed: (_generandoPdf || tareas.isEmpty) ? null : _generarParte,
          ),
        ],
      ),
      floatingActionButton: politica.puedeCrear && _fincas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _nuevaTarea,
              icon: const Icon(Icons.add_task),
              label: Text(textos.zonaNuevaTarea),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(children: [
                    if (_fincas.length > 1) ...[
                      _ChipDesplegable<int>(
                        etiqueta:
                            fincaFiltrada?.nombre ?? textos.tableroTodasFincas,
                        activo: fincaFiltrada != null,
                        opciones: [
                          (-1, textos.tableroTodasFincas),
                          for (final finca in _fincas)
                            if (finca.id != null) (finca.id!, finca.nombre),
                        ],
                        alElegir: (id) => setState(
                            () => _filtroFincaId = id == -1 ? null : id),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _ChipDesplegable<String>(
                      etiqueta: etiquetaEstado(_filtroEstado),
                      activo: _filtroEstado != null,
                      opciones: [
                        (_estadoAbiertas, etiquetaEstado(_estadoAbiertas)),
                        for (final estado in estadosTarea)
                          (estado.codigo, etiquetaEstado(estado.codigo)),
                        ('', textos.tableroTodosEstados),
                      ],
                      alElegir: (estado) => setState(
                          () => _filtroEstado = estado.isEmpty ? null : estado),
                    ),
                    const SizedBox(width: 8),
                    _ChipDesplegable<String>(
                      etiqueta: _filtroPrioridad == null
                          ? textos.tareaPrioridad
                          : '${textos.tareaPrioridad}: ${(buscarOpcion(prioridadesTarea, _filtroPrioridad!)?.etiqueta(idioma) ?? _filtroPrioridad!).toLowerCase()}',
                      activo: _filtroPrioridad != null,
                      opciones: [
                        for (final prioridad in prioridadesTarea)
                          (prioridad.codigo, prioridad.etiqueta(idioma)),
                        ('', textos.tableroTodasPrioridades),
                      ],
                      alElegir: (prioridad) => setState(() => _filtroPrioridad =
                          prioridad.isEmpty ? null : prioridad),
                    ),
                    if (sesion != null) ...[
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(textos.tableroMisTareas),
                        selected: _soloMias,
                        onSelected: (valor) =>
                            setState(() => _soloMias = valor),
                      ),
                    ],
                  ]),
                ),
                Expanded(
                  child: grupos.isEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              _filtroEstado == _estadoAbiertas
                                  ? textos.tableroSinAbiertas
                                  : textos.tableroSinTareas,
                              textAlign: TextAlign.center),
                        ))
                      : ListView(
                          padding: rellenoSobreBarraSistema(
                              context, const EdgeInsets.only(bottom: 96)),
                          children: [
                            for (final grupo in grupos)
                              _GrupoLugar(
                                grupo: grupo,
                                icono: _iconoGrupo(grupo),
                                titulo: _tituloGrupo(grupo, textos, idioma),
                                alVerEnMapa: _destinoGrupo(grupo),
                                filas: [
                                  for (final tarea in grupo.tareas)
                                    FilaTarea(
                                      tarea: tarea,
                                      lugar: '',
                                      verResponsable: true,
                                      alPulsar: () => _accionesTarea(tarea),
                                      alMarcarHecha:
                                          politica.puedeEjecutar(tarea)
                                              ? () => _marcarHecha(tarea)
                                              : null,
                                    ),
                                ],
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  IconData _iconoGrupo(GrupoTareasLugar grupo) => switch (grupo.lugar) {
        LugarTarea.punto => iconoTipoPunto(_puntosPorId[grupo.id]!.tipo),
        LugarTarea.zona => Icons.grass,
        LugarTarea.finca => Icons.home_work_outlined,
      };

  String _tituloGrupo(
      GrupoTareasLugar grupo, AppLocalizations textos, String idioma) {
    switch (grupo.lugar) {
      case LugarTarea.punto:
        final punto = _puntosPorId[grupo.id]!;
        return punto.nombre.isNotEmpty
            ? punto.nombre
            : buscarOpcion(tiposPunto, punto.tipo)?.etiqueta(idioma) ??
                punto.tipo;
      case LugarTarea.zona:
        final zona = _zonasPorId[grupo.id]!;
        return zona.nombre.isNotEmpty
            ? zona.nombre
            : buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo;
      case LugarTarea.finca:
        final finca =
            _fincas.where((finca) => finca.id == grupo.id).firstOrNull;
        return finca == null
            ? textos.tareaDeFinca
            : textos.tableroTareasGenerales(finca.nombre);
    }
  }

  /// «Mapa» lleva a la pieza o al punto (si tiene coordenadas); las
  /// tareas generales de una finca no tienen sitio al que ir.
  VoidCallback? _destinoGrupo(GrupoTareasLugar grupo) {
    switch (grupo.lugar) {
      case LugarTarea.punto:
        final punto = _puntosPorId[grupo.id]!;
        if (punto.latitud == null || punto.longitud == null) return null;
        return () => verEnMapa(context, DestinoMapa(puntoId: grupo.id));
      case LugarTarea.zona:
        return () => verEnMapa(context, DestinoMapa(zonaId: grupo.id));
      case LugarTarea.finca:
        return null;
    }
  }
}

/// Un sitio del tablero: icono, nombre y «Mapa», y sus tareas en una
/// tarjeta.
class _GrupoLugar extends StatelessWidget {
  const _GrupoLugar({
    required this.grupo,
    required this.icono,
    required this.titulo,
    required this.alVerEnMapa,
    required this.filas,
  });

  final GrupoTareasLugar grupo;
  final IconData icono;
  final String titulo;
  final VoidCallback? alVerEnMapa;
  final List<Widget> filas;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final esquema = context.esquemaZunbeltz;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 8, alVerEnMapa == null ? 10 : 2),
          child: Row(children: [
            Icon(icono, size: 20, color: esquema.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            if (alVerEnMapa != null)
              TextButton.icon(
                onPressed: alVerEnMapa,
                icon: const Icon(Icons.map_outlined, size: 20),
                label: Text(textos.tableroVerEnMapa),
              ),
          ]),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: esquema.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            for (var indice = 0; indice < filas.length; indice++) ...[
              if (indice > 0)
                Divider(
                    height: 1,
                    indent: 74,
                    endIndent: 16,
                    color: esquema.outlineVariant),
              filas[indice],
            ],
          ]),
        ),
      ],
    );
  }
}

/// Filtro en chip que abre un menú (finca, estado, prioridad). Activo,
/// relleno y con la marca; si no, con borde.
class _ChipDesplegable<T> extends StatelessWidget {
  const _ChipDesplegable({
    required this.etiqueta,
    required this.activo,
    required this.opciones,
    required this.alElegir,
  });

  final String etiqueta;
  final bool activo;
  final List<(T, String)> opciones;
  final ValueChanged<T> alElegir;

  @override
  Widget build(BuildContext context) {
    final esquema = context.esquemaZunbeltz;
    final color =
        activo ? esquema.onSecondaryContainer : esquema.onSurfaceVariant;
    return PopupMenuButton<T>(
      tooltip: '',
      onSelected: alElegir,
      itemBuilder: (_) => [
        for (final (valor, texto) in opciones)
          PopupMenuItem<T>(value: valor, child: Text(texto)),
      ],
      child: Container(
        height: 32,
        padding: EdgeInsets.only(left: activo ? 8 : 12, right: 6),
        decoration: BoxDecoration(
          color: activo ? esquema.secondaryContainer : null,
          border: activo ? null : Border.all(color: esquema.outline),
          borderRadius: BorderRadius.circular(radioZunbeltz),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (activo) ...[
            Icon(Icons.check, size: 18, color: color),
            const SizedBox(width: 6),
          ],
          Text(etiqueta,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: color)),
          Icon(Icons.arrow_drop_down, size: 20, color: color),
        ]),
      ),
    );
  }
}
