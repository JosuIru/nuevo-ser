import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/cepa.dart';
import '../modelos/cosecha.dart';
import '../modelos/incidencia.dart';
import '../modelos/observacion.dart';
import '../modelos/tratamiento.dart';
import '../modelos/vinedo.dart';
import '../utiles/nombres_visibles.dart';
import 'pantalla_nueva_cepa.dart';
import 'pantalla_nuevo_evento.dart';

/// Ficha de una cepa: cabecera con datos fijos (variedad,
/// portainjerto, viñedo, coords, fecha plantación) + foto principal +
/// timeline cronológico que mezcla cosechas, observaciones,
/// incidencias y tratamientos. Patrón heredado de la suite Larrea.
class PantallaFichaCepa extends StatefulWidget {
  final int cepaId;
  PantallaFichaCepa({super.key, required this.cepaId});

  @override
  State<PantallaFichaCepa> createState() => _PantallaFichaCepaState();
}

class _PantallaFichaCepaState extends State<PantallaFichaCepa> {
  Cepa? _cepa;
  Vinedo? _vinedo;
  List<_EventoTimeline> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraViticultura.instancia;
    final cepa = await db.obtenerCepa(widget.cepaId);
    if (cepa == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final vinedo = cepa.vinedoId == null ? null : await db.obtenerVinedo(cepa.vinedoId!);
    final cosechas = await db.listarCosechasDeCepa(cepa.id!);
    final observaciones = await db.listarObservacionesDeCepa(cepa.id!);
    final incidencias = await db.listarIncidenciasDeCepa(cepa.id!);
    final tratamientos = await db.listarTratamientosDeCepa(cepa.id!);

    final eventos = <_EventoTimeline>[
      ...cosechas.map((c) => _EventoTimeline.cosecha(c)),
      ...observaciones.map((o) => _EventoTimeline.observacion(o)),
      ...incidencias.map((i) => _EventoTimeline.incidencia(i)),
      ...tratamientos.map((t) => _EventoTimeline.tratamiento(t)),
    ]..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));

    if (!mounted) return;
    setState(() {
      _cepa = cepa;
      _vinedo = vinedo;
      _eventos = eventos;
      _cargando = false;
    });
  }

  Future<void> _crearEvento(TipoEventoNuevo tipo) async {
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoEvento(cepaId: widget.cepaId, tipo: tipo),
      ),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _editarCepa() async {
    final cepa = _cepa;
    if (cepa == null) return;
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaNuevaCepa(cepaExistente: cepa)),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _confirmarEliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(SoleraL10n.t('viti.eliminar_cepa')),
        content: Text(
          SoleraL10n.t('viti.eliminar_cepa_aviso'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(SoleraL10n.t('viti.eliminar')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await BaseDatosSoleraViticultura.instancia.borrarCepa(widget.cepaId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final cepa = _cepa!;
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final etiqueta = cepa.etiqueta.isEmpty ? '#${cepa.id}' : cepa.etiqueta;
    final fotos = GestorFotos.decodificar(cepa.rutasFotosJson);

    return Scaffold(
      appBar: AppBar(
        title: Text('$etiqueta · ${cepa.variedadId}'),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _editarCepa),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: _confirmarEliminar),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        children: [
          if (fotos.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(fotos.first),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => SizedBox(height: 220),
              ),
            ),
          if (fotos.isNotEmpty) SizedBox(height: 12),
          _filaInfo(SoleraL10n.t('viti.variedad'), cepa.variedadId),
          if (cepa.portainjertoId.isNotEmpty) _filaInfo(SoleraL10n.t('viti.portainjerto'), cepa.portainjertoId),
          _filaInfo(SoleraL10n.t('viti.vinedo'), _vinedo?.nombre ?? SoleraL10n.t('viti.punto_suelto')),
          _filaInfo(SoleraL10n.t('viti.coordenadas'), '${cepa.latitud.toStringAsFixed(6)}, ${cepa.longitud.toStringAsFixed(6)}'),
          if (cepa.fechaPlantacionMs != null)
            _filaInfo(SoleraL10n.t('viti.plantada'),
                formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(cepa.fechaPlantacionMs!))),
          if (cepa.notas.isNotEmpty) _filaInfo(SoleraL10n.t('viti.notas'), cepa.notas),
          SizedBox(height: 16),
          Text(SoleraL10n.t('viti.historia'), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          if (_eventos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                SoleraL10n.t('viti.sin_eventos_todavia'),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            for (final e in _eventos) _Evento(evento: e),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarMenuNuevoEvento,
        icon: Icon(Icons.add),
        label: Text(SoleraL10n.t('viti.nuevo_evento')),
      ),
    );
  }

  Widget _filaInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(etiqueta, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  Future<void> _mostrarMenuNuevoEvento() async {
    final tipo = await showModalBottomSheet<TipoEventoNuevo>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.agriculture),
              title: Text(SoleraL10n.t('viti.cosecha')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.cosecha),
            ),
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text(SoleraL10n.t('viti.observacion')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.observacion),
            ),
            ListTile(
              leading: Icon(Icons.warning_amber),
              title: Text(SoleraL10n.t('viti.incidencia')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.incidencia),
            ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text(SoleraL10n.t('viti.tratamiento')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.tratamiento),
            ),
          ],
        ),
      ),
    );
    if (tipo != null) await _crearEvento(tipo);
  }
}

/// Wrapper polimórfico para mostrar los 4 tipos de eventos en la
/// misma timeline. Cada constructor extrae fechaMs, título, subtítulo
/// y un icono representativo del modelo concreto. Título y subtítulo se
/// calculan al pintar para que salgan en el idioma elegido.
class _EventoTimeline {
  final int fechaMs;
  final String Function() _construirTitulo;
  final String Function() _construirSubtitulo;
  final IconData icono;
  _EventoTimeline._(this.fechaMs, this._construirTitulo, this._construirSubtitulo, this.icono);

  String get titulo => _construirTitulo();
  String get subtitulo => _construirSubtitulo();

  factory _EventoTimeline.cosecha(Cosecha c) {
    String subtitulo() => <String>[
          if (c.kilos != null) '${c.kilos!.toStringAsFixed(2)} kg',
          if (c.unidades != null) SoleraL10n.tf('viti.n_unidades_abreviado', {'n': c.unidades}),
          if (c.calidad != null) SoleraL10n.tf('viti.calidad_n', {'n': c.calidad}),
        ].join(' · ');
    return _EventoTimeline._(
        c.fechaMs, () => SoleraL10n.t('viti.cosecha'), subtitulo, Icons.agriculture);
  }

  factory _EventoTimeline.observacion(Observacion o) {
    String subtitulo() => <String>[
          if (o.salud != null) SoleraL10n.tf('viti.salud_n', {'n': o.salud}),
          if (o.notas.isNotEmpty) o.notas,
        ].join(' · ');
    return _EventoTimeline._(
        o.fechaMs, () => SoleraL10n.t('viti.observacion'), subtitulo, Icons.visibility);
  }

  factory _EventoTimeline.incidencia(Incidencia i) {
    String subtitulo() => <String>[
          if (i.diagnostico.isNotEmpty) i.diagnostico,
          if (i.severidad != null) SoleraL10n.tf('viti.severidad_abreviada_n', {'n': i.severidad}),
          if (i.resuelta) SoleraL10n.t('viti.resuelta'),
        ].join(' · ');
    return _EventoTimeline._(
        i.fechaMs,
        () => '${SoleraL10n.t('viti.incidencia')} · ${nombreVisibleTipoIncidencia(i.tipo)}',
        subtitulo,
        Icons.warning_amber);
  }

  factory _EventoTimeline.tratamiento(Tratamiento t) {
    String subtitulo() => <String>[
          if (t.producto.isNotEmpty) t.producto,
          if (t.dosis.isNotEmpty) t.dosis,
          if (t.motivo.isNotEmpty) t.motivo,
        ].join(' · ');
    return _EventoTimeline._(
        t.fechaMs,
        () => '${SoleraL10n.t('viti.tratamiento')} · ${nombreVisibleTipoTratamiento(t.tipo)}',
        subtitulo,
        Icons.medical_services);
  }
}

class _Evento extends StatelessWidget {
  final _EventoTimeline evento;
  _Evento({required this.evento});

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    return ListTile(
      leading: Icon(evento.icono),
      title: Text(evento.titulo),
      subtitle: evento.subtitulo.isEmpty ? null : Text(evento.subtitulo),
      trailing: Text(
        formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(evento.fechaMs)),
        style: TextStyle(color: Colors.grey.shade600),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
