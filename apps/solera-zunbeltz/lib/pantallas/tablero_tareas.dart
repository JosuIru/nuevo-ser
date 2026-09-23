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
import 'widgets/acciones_tarea.dart';
import 'widgets/tile_tarea.dart';

/// Tablero de tareas de mantenimiento: lista filtrable por finca y estado,
/// con exportación del parte en PDF.
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
  String? _filtroEstado;
  bool _soloMias = false;

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
      _puntosPorId = {for (final p in puntos) if (p.id != null) p.id!: p};
      _zonasPorId = {for (final z in zonas) if (z.id != null) z.id!: z};
      _cargando = false;
    });
  }

  Future<void> _marcarHecha(TareaMantenimiento tarea) async {
    final id = tarea.id;
    if (id == null) return;
    final textos = AppLocalizations.of(context);
    final generoSiguiente = await _bd.marcarTareaHecha(id) != null;
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(generoSiguiente
            ? textos.tareaSiguienteGenerada
            : textos.tareaGuardada)));
  }

  Future<void> _accionesTarea(TareaMantenimiento tarea) async {
    if (await mostrarAccionesTarea(context, tarea)) await _cargar();
  }

  List<TareaMantenimiento> get _tareasFiltradas {
    final miUid = sesionEspacio.value?.persona.uid;
    return _tareas.where((t) {
      if (_filtroFincaId != null && t.fincaId != _filtroFincaId) return false;
      if (_filtroEstado != null && t.estado != _filtroEstado) return false;
      if (_soloMias && miUid != null && t.responsableUid != miUid) return false;
      return true;
    }).toList(growable: false);
  }

  String _subtitulo(TareaMantenimiento tarea, AppLocalizations textos) {
    final finca = _fincas.firstWhere(
      (f) => f.id == tarea.fincaId,
      orElse: () => Finca(),
    );
    final punto = tarea.puntoId == null ? null : _puntosPorId[tarea.puntoId];
    final zona = tarea.zonaId == null ? null : _zonasPorId[tarea.zonaId];
    final idioma = Localizations.localeOf(context).languageCode;
    final String anclaje;
    if (punto != null) {
      anclaje = punto.nombre.isNotEmpty
          ? punto.nombre
          : buscarOpcion(tiposPunto, punto.tipo)?.etiqueta(idioma) ??
              punto.tipo;
    } else if (zona != null) {
      anclaje = zona.nombre.isNotEmpty
          ? zona.nombre
          : buscarOpcion(tiposZona, zona.tipo)?.etiqueta(idioma) ?? zona.tipo;
    } else {
      anclaje = textos.tareaDeFinca;
    }
    return '${finca.nombre} · $anclaje';
  }

  Future<void> _generarParte() async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    setState(() => _generandoPdf = true);
    try {
      final fichero = await generarParteMantenimientoPdf(
        textos: textos,
        idioma: idioma,
        fincas: _fincas,
        tareas: _tareasFiltradas,
        puntosPorId: _puntosPorId,
        zonasPorId: _zonasPorId,
      );
      final bytes = await fichero.readAsBytes();
      await Printing.sharePdf(
        bytes: bytes,
        filename: fichero.uri.pathSegments.last,
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

  Widget _construir(
      AppLocalizations textos, String idioma, SesionEspacio? sesion) {
    final tareas = _tareasFiltradas;
    final politica = politicaTareasActual;
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.tableroTitulo),
        actions: [
          IconButton(
            tooltip: textos.tableroPartePdf,
            icon: _generandoPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            onPressed:
                (_generandoPdf || tareas.isEmpty) ? null : _generarParte,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _Filtros(
                  fincas: _fincas,
                  idioma: idioma,
                  textos: textos,
                  fincaId: _filtroFincaId,
                  estado: _filtroEstado,
                  onFinca: (v) => setState(() => _filtroFincaId = v),
                  onEstado: (v) => setState(() => _filtroEstado = v),
                ),
                if (sesion != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FilterChip(
                        label: Text(textos.tableroMisTareas),
                        selected: _soloMias,
                        onSelected: (valor) => setState(() => _soloMias = valor),
                      ),
                    ),
                  ),
                const Divider(height: 1),
                Expanded(
                  child: tareas.isEmpty
                      ? Center(child: Text(textos.tableroSinTareas))
                      : ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            for (final tarea in tareas)
                              TileTarea(
                                tarea: tarea,
                                idioma: idioma,
                                subtitulo: _subtitulo(tarea, textos),
                                onTap: () => _accionesTarea(tarea),
                                onMarcarHecha: politica.puedeEjecutar(tarea)
                                    ? () => _marcarHecha(tarea)
                                    : null,
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.fincas,
    required this.idioma,
    required this.textos,
    required this.fincaId,
    required this.estado,
    required this.onFinca,
    required this.onEstado,
  });

  final List<Finca> fincas;
  final String idioma;
  final AppLocalizations textos;
  final int? fincaId;
  final String? estado;
  final ValueChanged<int?> onFinca;
  final ValueChanged<String?> onEstado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int?>(
              initialValue: fincaId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: textos.tableroFiltroFinca,
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(textos.tableroTodas)),
                for (final f in fincas)
                  DropdownMenuItem(value: f.id, child: Text(f.nombre)),
              ],
              onChanged: onFinca,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue: estado,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: textos.tableroFiltroEstado,
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(textos.tableroTodas)),
                for (final e in estadosTarea)
                  DropdownMenuItem(
                      value: e.codigo, child: Text(e.etiqueta(idioma))),
              ],
              onChanged: onEstado,
            ),
          ),
        ],
      ),
    );
  }
}
