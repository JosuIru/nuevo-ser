import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/apiario.dart';
import '../modelos/colmena.dart';
import '../modelos/cosecha_miel.dart';
import '../modelos/incidencia_apicola.dart';
import '../modelos/movimiento.dart';
import '../modelos/revision.dart';
import '../modelos/tratamiento_varroa.dart';
import '../utiles/etiquetas_visibles.dart';
import 'pantalla_nueva_colmena.dart';
import 'pantalla_nuevo_evento.dart';

/// Ficha de una colmena: cabecera con datos fijos (matrícula, tipo,
/// raza, año reina, estado) + foto principal + timeline cronológico
/// que mezcla los 5 tipos de eventos (revisiones, cosechas,
/// tratamientos, incidencias, movimientos).
class PantallaFichaColmena extends StatefulWidget {
  final int colmenaId;
  PantallaFichaColmena({super.key, required this.colmenaId});

  @override
  State<PantallaFichaColmena> createState() => _PantallaFichaColmenaState();
}

class _PantallaFichaColmenaState extends State<PantallaFichaColmena> {
  Colmena? _colmena;
  Apiario? _apiario;
  List<_EventoTimeline> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosSoleraApicola.instancia;
    final colmena = await db.obtenerColmena(widget.colmenaId);
    if (colmena == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final apiario = colmena.apiarioId == null ? null : await db.obtenerApiario(colmena.apiarioId!);
    final revisiones = await db.listarRevisionesDeColmena(colmena.id!);
    final cosechas = await db.listarCosechasDeColmena(colmena.id!);
    final tratamientos = await db.listarTratamientosDeColmena(colmena.id!);
    final incidencias = await db.listarIncidenciasDeColmena(colmena.id!);
    final movimientos = await db.listarMovimientosDeColmena(colmena.id!);

    final eventos = <_EventoTimeline>[
      ...revisiones.map((r) => _EventoTimeline.revision(r)),
      ...cosechas.map((c) => _EventoTimeline.cosecha(c)),
      ...tratamientos.map((t) => _EventoTimeline.tratamiento(t)),
      ...incidencias.map((i) => _EventoTimeline.incidencia(i)),
      ...movimientos.map((m) => _EventoTimeline.movimiento(m)),
    ]..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));

    if (!mounted) return;
    setState(() {
      _colmena = colmena;
      _apiario = apiario;
      _eventos = eventos;
      _cargando = false;
    });
  }

  Future<void> _crearEvento(TipoEventoNuevo tipo) async {
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoEvento(colmenaId: widget.colmenaId, tipo: tipo),
      ),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _editarColmena() async {
    final colmena = _colmena;
    if (colmena == null) return;
    final cambio = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PantallaNuevaColmena(colmenaExistente: colmena)),
    );
    if (cambio == true) _cargar();
  }

  Future<void> _confirmarEliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(SoleraL10n.t('api.eliminar_colmena')),
        content: Text(SoleraL10n.t('api.eliminar_colmena_aviso')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(SoleraL10n.t('api.eliminar')),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await BaseDatosSoleraApicola.instancia.borrarColmena(widget.colmenaId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colmena = _colmena!;
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final fotos = GestorFotos.decodificar(colmena.rutasFotosJson);

    return Scaffold(
      appBar: AppBar(
        title: Text(colmena.matricula),
        actions: [
          IconButton(icon: Icon(Icons.edit), tooltip: SoleraL10n.t('editar'), onPressed: _editarColmena),
          IconButton(icon: Icon(Icons.delete_outline), tooltip: SoleraL10n.t('api.eliminar'), onPressed: _confirmarEliminar),
        ],
      ),
      body: ListView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(16, 12, 16, 80)),
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
          _filaInfo(SoleraL10n.t('api.estado'), etiquetaEstadoColmena(colmena.estado)),
          _filaInfo(SoleraL10n.t('api.apiario'), _apiario?.nombre ?? SoleraL10n.t('api.punto_suelto')),
          if (colmena.tipoColmenaId.isNotEmpty) _filaInfo(SoleraL10n.t('api.tipo'), colmena.tipoColmenaId),
          if (colmena.razaId.isNotEmpty) _filaInfo(SoleraL10n.t('api.raza'), colmena.razaId),
          if (colmena.anoReina != null)
            _filaInfo(
              SoleraL10n.t('api.reina'),
              SoleraL10n.tf('api.ano_y_marca_reina', {
                'ano': colmena.anoReina,
                'color': etiquetaColorMarcaReina(colmena.colorMarcaReina),
              }),
            ),
          if (colmena.ultimaLatitud != null)
            _filaInfo(SoleraL10n.t('api.ultima_ubicacion'),
                '${colmena.ultimaLatitud!.toStringAsFixed(6)}, ${colmena.ultimaLongitud!.toStringAsFixed(6)}'),
          if (colmena.fechaAltaMs != null)
            _filaInfo(SoleraL10n.t('api.alta'), formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(colmena.fechaAltaMs!))),
          if (colmena.notas.isNotEmpty) _filaInfo(SoleraL10n.t('api.notas'), colmena.notas),
          SizedBox(height: 16),
          Text(SoleraL10n.t('api.historia'), style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          if (_eventos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                SoleraL10n.t('api.sin_eventos_todavia'),
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
        label: Text(SoleraL10n.t('api.nuevo_evento')),
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
            width: 130,
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
              leading: Icon(Icons.visibility),
              title: Text(SoleraL10n.t('api.revision')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.revision),
            ),
            ListTile(
              leading: Icon(Icons.water_drop),
              title: Text(SoleraL10n.t('api.cosecha')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.cosecha),
            ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text(SoleraL10n.t('api.tratamiento')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.tratamiento),
            ),
            ListTile(
              leading: Icon(Icons.warning_amber),
              title: Text(SoleraL10n.t('api.incidencia')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.incidencia),
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text(SoleraL10n.t('api.movimiento')),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.movimiento),
            ),
          ],
        ),
      ),
    );
    if (tipo != null) await _crearEvento(tipo);
  }
}

class _EventoTimeline {
  final int fechaMs;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  _EventoTimeline._(this.fechaMs, this.titulo, this.subtitulo, this.icono);

  factory _EventoTimeline.revision(Revision r) {
    final partes = <String>[
      if (r.presenciaReina != 'no_observada')
        SoleraL10n.tf('api.reina_valor', {'valor': etiquetaPresenciaReina(r.presenciaReina)}),
      if (r.nivelPostura != null) SoleraL10n.tf('api.postura_n', {'n': r.nivelPostura}),
      if (r.varroaCaidaDiaria != null) SoleraL10n.tf('api.varroa_n_dia', {'n': r.varroaCaidaDiaria}),
    ];
    return _EventoTimeline._(r.fechaMs, SoleraL10n.t('api.revision'), partes.join(' · '), Icons.visibility);
  }

  factory _EventoTimeline.cosecha(CosechaMiel c) {
    final partes = <String>[
      if (c.kilosMiel != null) SoleraL10n.tf('api.kg_de_miel', {'kg': formatearNumero(c.kilosMiel!, decimales: 1)}),
      if (c.kilosCera != null) SoleraL10n.tf('api.kg_de_cera', {'kg': formatearNumero(c.kilosCera!, decimales: 2)}),
      if (c.kilosPolen != null) SoleraL10n.tf('api.kg_de_polen', {'kg': formatearNumero(c.kilosPolen!, decimales: 2)}),
      if (c.numeroAlza != null) SoleraL10n.tf('api.alza_n', {'n': c.numeroAlza}),
    ];
    return _EventoTimeline._(c.fechaMs, SoleraL10n.t('api.cosecha'), partes.join(' · '), Icons.water_drop);
  }

  factory _EventoTimeline.tratamiento(TratamientoVarroa t) {
    final partes = <String>[
      if (t.sustanciaActivaId.isNotEmpty) t.sustanciaActivaId,
      if (t.dosis.isNotEmpty) t.dosis,
      if (t.vehiculo.isNotEmpty) t.vehiculo,
    ];
    return _EventoTimeline._(t.fechaAplicacionMs, '${SoleraL10n.t('api.tratamiento')} · ${etiquetaTipoTratamiento(t.tipo)}', partes.join(' · '), Icons.medical_services);
  }

  factory _EventoTimeline.incidencia(IncidenciaApicola i) {
    final partes = <String>[
      if (i.diagnostico.isNotEmpty) i.diagnostico,
      if (i.severidad != null) SoleraL10n.tf('api.severidad_abreviada_n', {'n': i.severidad}),
      if (i.resuelta) SoleraL10n.t('api.resuelta'),
    ];
    return _EventoTimeline._(i.fechaMs, '${SoleraL10n.t('api.incidencia')} · ${etiquetaTipoIncidencia(i.tipo)}', partes.join(' · '), Icons.warning_amber);
  }

  factory _EventoTimeline.movimiento(Movimiento m) {
    final partes = <String>[
      if (m.numeroColmenas > 1) SoleraL10n.tf('api.n_colmenas', {'n': m.numeroColmenas}),
      if (m.notas.isNotEmpty) m.notas,
    ];
    return _EventoTimeline._(m.fechaMovimientoMs, '${SoleraL10n.t('api.movimiento')} · ${etiquetaMotivoMovimiento(m.motivo)}', partes.join(' · '), Icons.swap_horiz);
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
