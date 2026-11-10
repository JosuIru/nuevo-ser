import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../modelos/arbol.dart';
import '../modelos/incidencia.dart';
import '../modelos/inspeccion.dart';
import '../modelos/poda.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona.dart';
import '../utiles/etiquetas_l10n.dart';
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
        padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
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
                label: Text(SoleraL10n.t('arb.inspeccion')),
              ),
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.poda),
                icon: const Icon(Icons.content_cut),
                label: Text(SoleraL10n.t('arb.poda')),
              ),
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.tratamiento),
                icon: const Icon(Icons.science),
                label: Text(SoleraL10n.t('arb.tratamiento')),
              ),
              FilledButton.icon(
                onPressed: () => _crearEvento(TipoEventoNuevo.incidencia),
                icon: const Icon(Icons.warning_amber),
                label: Text(SoleraL10n.t('arb.incidencia')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('arb.historico'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          if (_timeline.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text(SoleraL10n.t('arb.sin_eventos_registrados'))),
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

  String _estadoVisible(EstadoArbol e) => e == EstadoArbol.caido
      ? SoleraL10n.t('arb.estado_caido_eliminado')
      : etiquetaEstadoArbol(e);

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
                      Text('${zona?.nombre ?? SoleraL10n.t('arb.sin_zona')} · ${_estadoVisible(arbol.estado)}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (arbol.especieId.isNotEmpty)
              _Linea(etiqueta: SoleraL10n.t('arb.especie'), valor: arbol.especieId),
            if (arbol.qrPayload.isNotEmpty)
              _Linea(etiqueta: SoleraL10n.t('arb.qr_de_la_chapa'), valor: arbol.qrPayload),
            if (arbol.edadEstimadaAnos != null)
              _Linea(
                  etiqueta: SoleraL10n.t('arb.edad'),
                  valor: SoleraL10n.tf('arb.n_anos', {'n': arbol.edadEstimadaAnos})),
            if (arbol.fechaPlantacionMs != null)
              _Linea(
                etiqueta: SoleraL10n.t('arb.plantacion'),
                valor: formatoFecha.format(
                    DateTime.fromMillisecondsSinceEpoch(arbol.fechaPlantacionMs!)),
              ),
            if (arbol.perimetroTroncoCm != null)
              _Linea(
                  etiqueta: SoleraL10n.t('arb.perimetro'),
                  valor: '${formatearNumero(arbol.perimetroTroncoCm!, decimales: 1)} cm'),
            if (arbol.alturaEstimadaMetros != null)
              _Linea(
                  etiqueta: SoleraL10n.t('arb.altura'),
                  valor: '${formatearNumero(arbol.alturaEstimadaMetros!, decimales: 1)} m'),
            if (arbol.riesgoVta != null)
              _Linea(etiqueta: SoleraL10n.t('arb.riesgo_vta'), valor: '${arbol.riesgoVta} / 5'),
            if (arbol.tipoAlcorqueId.isNotEmpty)
              _Linea(etiqueta: SoleraL10n.t('arb.alcorque'), valor: arbol.tipoAlcorqueId),
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
/// para que el render no tenga que abrir el switch. Tipo y resumen son
/// funciones para que salgan en el idioma vigente al repintar.
class _EntradaTimeline {
  final IconData icono;
  final String Function() tipo;
  final int fechaMs;
  final String Function() resumen;
  final String detalle;

  _EntradaTimeline._({
    required this.icono,
    required this.tipo,
    required this.fechaMs,
    required this.resumen,
    required this.detalle,
  });

  factory _EntradaTimeline.inspeccion(Inspeccion i) {
    List<String> detalles() => <String>[
          etiquetaEstadoInspeccion(i.estado),
          if (i.riesgoVta != null) 'VTA ${i.riesgoVta}',
          if (i.fenologia.isNotEmpty) i.fenologia,
        ];
    return _EntradaTimeline._(
      icono: Icons.search,
      tipo: () => SoleraL10n.t('arb.inspeccion'),
      fechaMs: i.fechaMs,
      resumen: () => detalles().join(' · '),
      detalle: i.notas,
    );
  }

  factory _EntradaTimeline.poda(Poda p) {
    final detalles = <String>[
      if (p.tipoPodaId.isNotEmpty) p.tipoPodaId,
      if (p.volumenRestosM3 != null) '${formatearNumero(p.volumenRestosM3!, decimales: 2)} m³',
      if (p.motivo.isNotEmpty) p.motivo,
    ];
    return _EntradaTimeline._(
      icono: Icons.content_cut,
      tipo: () => SoleraL10n.t('arb.poda'),
      fechaMs: p.fechaMs,
      resumen: () => detalles.isEmpty ? SoleraL10n.t('arb.sin_detalles') : detalles.join(' · '),
      detalle: p.notas,
    );
  }

  factory _EntradaTimeline.tratamiento(Tratamiento t) {
    List<String> detalles() => <String>[
          if (t.sustanciaActivaId.isNotEmpty) t.sustanciaActivaId,
          if (t.dosis.isNotEmpty) t.dosis,
          if (t.motivoIdPlaga.isNotEmpty)
            SoleraL10n.tf('arb.contra_plaga', {'plaga': t.motivoIdPlaga}),
        ];
    return _EntradaTimeline._(
      icono: Icons.science,
      tipo: () => SoleraL10n.t('arb.tratamiento'),
      fechaMs: t.fechaMs,
      resumen: () {
        final lista = detalles();
        return lista.isEmpty ? SoleraL10n.t('arb.sin_detalles') : lista.join(' · ');
      },
      detalle: t.notas,
    );
  }

  factory _EntradaTimeline.incidencia(Incidencia i) {
    List<String> detalles() => <String>[
          etiquetaTipoIncidencia(i.tipo),
          if (i.severidad != null) SoleraL10n.tf('arb.severidad_abreviada', {'n': i.severidad}),
          if (i.resuelta) SoleraL10n.t('arb.resuelta') else SoleraL10n.t('arb.abierta'),
        ];
    return _EntradaTimeline._(
      icono: Icons.warning_amber,
      tipo: () => SoleraL10n.t('arb.incidencia'),
      fechaMs: i.fechaMs,
      resumen: () => '${i.descripcion.isEmpty ? "—" : i.descripcion} · ${detalles().join(" · ")}',
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
      title: Text('${entrada.tipo()} · ${entrada.resumen()}'),
      subtitle: Text(
        '${formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(entrada.fechaMs))}'
        '${entrada.detalle.isEmpty ? "" : "\n${entrada.detalle}"}',
      ),
      isThreeLine: entrada.detalle.isNotEmpty,
    );
  }
}
