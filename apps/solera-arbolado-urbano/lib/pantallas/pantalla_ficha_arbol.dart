import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/arbol.dart';
import '../modelos/incidencia.dart';
import '../modelos/inspeccion.dart';
import '../modelos/poda.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona.dart';
import 'pantalla_nuevo_arbol.dart';
import 'pantalla_nuevo_evento.dart';

/// Ficha del árbol — datos descriptivos arriba y timeline mezclada de
/// los 4 tipos de evento abajo (inspección / poda / tratamiento /
/// incidencia), ordenada por fecha descendente.
class PantallaFichaArbol extends StatefulWidget {
  final int arbolId;
  const PantallaFichaArbol({super.key, required this.arbolId});

  @override
  State<PantallaFichaArbol> createState() => _PantallaFichaArbolState();
}

class _PantallaFichaArbolState extends State<PantallaFichaArbol> {
  Arbol? _arbol;
  Zona? _zona;
  List<_EntradaTimeline> _timeline = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraArbolado.instancia;
    final arbol = await db.obtenerArbol(widget.arbolId);
    if (arbol == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    final zona = arbol.zonaId == null ? null : await db.obtenerZona(arbol.zonaId!);
    final inspecciones = await db.listarInspeccionesDeArbol(widget.arbolId);
    final podas = await db.listarPodasDeArbol(widget.arbolId);
    final tratamientos = await db.listarTratamientosDeArbol(widget.arbolId);
    final incidencias = await db.listarIncidenciasDeArbol(widget.arbolId);

    final entradas = <_EntradaTimeline>[
      ...inspecciones.map((i) => _EntradaTimeline.inspeccion(i)),
      ...podas.map((p) => _EntradaTimeline.poda(p)),
      ...tratamientos.map((t) => _EntradaTimeline.tratamiento(t)),
      ...incidencias.map((i) => _EntradaTimeline.incidencia(i)),
    ]..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));

    if (!mounted) return;
    setState(() {
      _arbol = arbol;
      _zona = zona;
      _timeline = entradas;
      _cargando = false;
    });
  }

  Future<void> _editarArbol() async {
    if (_arbol == null) return;
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaNuevoArbol(arbolExistente: _arbol)),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _crearEvento(TipoEventoNuevo tipo) async {
    if (_arbol == null) return;
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoEvento(arbolId: _arbol!.id!, tipo: tipo),
      ),
    );
    if (cambio == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando || _arbol == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final arbol = _arbol!;
    return Scaffold(
      appBar: AppBar(
        title: Text(arbol.identificadorMunicipal),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editarArbol),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BloqueDescriptivo(arbol: arbol, zona: _zona, formatoFecha: formatoFecha),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.inspeccion),
                icon: const Icon(Icons.search),
                label: const Text('Inspección'),
              ),
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.poda),
                icon: const Icon(Icons.content_cut),
                label: const Text('Poda'),
              ),
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.tratamiento),
                icon: const Icon(Icons.science),
                label: const Text('Tratamiento'),
              ),
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.incidencia),
                icon: const Icon(Icons.warning_amber),
                label: const Text('Incidencia'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Histórico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          if (_timeline.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Sin eventos registrados todavía.')),
            )
          else
            ..._timeline.map((e) => _FilaTimeline(entrada: e, formatoFecha: formatoFecha)),
        ],
      ),
    );
  }
}

class _BloqueDescriptivo extends StatelessWidget {
  final Arbol arbol;
  final Zona? zona;
  final DateFormat formatoFecha;
  const _BloqueDescriptivo(
      {required this.arbol, required this.zona, required this.formatoFecha});

  String _estadoVisible(EstadoArbol e) {
    switch (e) {
      case EstadoArbol.sano:
        return 'Sano';
      case EstadoArbol.observacion:
        return 'Observación';
      case EstadoArbol.riesgo:
        return 'Riesgo';
      case EstadoArbol.caido:
        return 'Caído / eliminado';
      case EstadoArbol.sustituido:
        return 'Sustituido';
    }
  }

  Color _colorEstado(EstadoArbol e, ColorScheme paleta) {
    switch (e) {
      case EstadoArbol.sano:
        return paleta.primary;
      case EstadoArbol.observacion:
        return Colors.amber.shade700;
      case EstadoArbol.riesgo:
        return Colors.red;
      case EstadoArbol.caido:
        return Colors.grey.shade700;
      case EstadoArbol.sustituido:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paleta = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _colorEstado(arbol.estado, paleta),
                  child: const Icon(Icons.park, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(arbol.identificadorMunicipal,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${zona?.nombre ?? "Sin zona"} · ${_estadoVisible(arbol.estado)}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (arbol.especieId.isNotEmpty)
              _Linea(etiqueta: 'Especie', valor: arbol.especieId),
            if (arbol.qrPayload.isNotEmpty)
              _Linea(etiqueta: 'QR chapa', valor: arbol.qrPayload),
            if (arbol.edadEstimadaAnos != null)
              _Linea(etiqueta: 'Edad', valor: '${arbol.edadEstimadaAnos} años'),
            if (arbol.fechaPlantacionMs != null)
              _Linea(
                etiqueta: 'Plantación',
                valor: formatoFecha.format(
                    DateTime.fromMillisecondsSinceEpoch(arbol.fechaPlantacionMs!)),
              ),
            if (arbol.perimetroTroncoCm != null)
              _Linea(
                  etiqueta: 'Perímetro',
                  valor: '${arbol.perimetroTroncoCm!.toStringAsFixed(1)} cm'),
            if (arbol.alturaEstimadaMetros != null)
              _Linea(
                  etiqueta: 'Altura',
                  valor: '${arbol.alturaEstimadaMetros!.toStringAsFixed(1)} m'),
            if (arbol.riesgoVta != null)
              _Linea(etiqueta: 'Riesgo VTA', valor: '${arbol.riesgoVta} / 5'),
            if (arbol.tipoAlcorqueId.isNotEmpty)
              _Linea(etiqueta: 'Alcorque', valor: arbol.tipoAlcorqueId),
            if (arbol.latitud != null && arbol.longitud != null)
              _Linea(
                  etiqueta: 'GPS',
                  valor:
                      '${arbol.latitud!.toStringAsFixed(6)}, ${arbol.longitud!.toStringAsFixed(6)}'),
          ],
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Linea({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(etiqueta, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}

/// Una entrada genérica de la timeline. Mantiene el tipo + un resumen
/// para que el render no tenga que abrir el switch.
class _EntradaTimeline {
  final IconData icono;
  final String tipo;
  final int fechaMs;
  final String resumen;
  final String detalle;

  _EntradaTimeline._({
    required this.icono,
    required this.tipo,
    required this.fechaMs,
    required this.resumen,
    required this.detalle,
  });

  factory _EntradaTimeline.inspeccion(Inspeccion i) {
    final detalles = <String>[
      i.estado,
      if (i.riesgoVta != null) 'VTA ${i.riesgoVta}',
      if (i.fenologia.isNotEmpty) i.fenologia,
    ];
    return _EntradaTimeline._(
      icono: Icons.search,
      tipo: 'Inspección',
      fechaMs: i.fechaMs,
      resumen: detalles.join(' · '),
      detalle: i.notas,
    );
  }

  factory _EntradaTimeline.poda(Poda p) {
    final detalles = <String>[
      if (p.tipoPodaId.isNotEmpty) p.tipoPodaId,
      if (p.volumenRestosM3 != null) '${p.volumenRestosM3!.toStringAsFixed(2)} m³',
      if (p.motivo.isNotEmpty) p.motivo,
    ];
    return _EntradaTimeline._(
      icono: Icons.content_cut,
      tipo: 'Poda',
      fechaMs: p.fechaMs,
      resumen: detalles.isEmpty ? 'Sin detalles' : detalles.join(' · '),
      detalle: p.notas,
    );
  }

  factory _EntradaTimeline.tratamiento(Tratamiento t) {
    final detalles = <String>[
      if (t.sustanciaActivaId.isNotEmpty) t.sustanciaActivaId,
      if (t.dosis.isNotEmpty) t.dosis,
      if (t.motivoIdPlaga.isNotEmpty) 'contra ${t.motivoIdPlaga}',
    ];
    return _EntradaTimeline._(
      icono: Icons.science,
      tipo: 'Tratamiento',
      fechaMs: t.fechaMs,
      resumen: detalles.isEmpty ? 'Sin detalles' : detalles.join(' · '),
      detalle: t.notas,
    );
  }

  factory _EntradaTimeline.incidencia(Incidencia i) {
    final detalles = <String>[
      i.tipo,
      if (i.severidad != null) 'sev ${i.severidad}',
      if (i.resuelta) 'resuelta' else 'abierta',
    ];
    return _EntradaTimeline._(
      icono: Icons.warning_amber,
      tipo: 'Incidencia',
      fechaMs: i.fechaMs,
      resumen: '${i.descripcion.isEmpty ? "—" : i.descripcion} · ${detalles.join(" · ")}',
      detalle: i.notas,
    );
  }
}

class _FilaTimeline extends StatelessWidget {
  final _EntradaTimeline entrada;
  final DateFormat formatoFecha;
  const _FilaTimeline({required this.entrada, required this.formatoFecha});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(entrada.icono),
      title: Text('${entrada.tipo} · ${entrada.resumen}'),
      subtitle: Text(
        '${formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(entrada.fechaMs))}'
        '${entrada.detalle.isEmpty ? "" : "\n${entrada.detalle}"}',
      ),
      isThreeLine: entrada.detalle.isNotEmpty,
    );
  }
}
