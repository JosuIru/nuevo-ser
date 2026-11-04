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
        title: Text('Eliminar colmena'),
        content: Text(
          'Se borra la colmena y toda su historia (revisiones, cosechas, '
          'tratamientos, incidencias, movimientos). Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
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
          IconButton(icon: Icon(Icons.edit), onPressed: _editarColmena),
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
          _filaInfo('Estado', _etiquetaEstado(colmena.estado)),
          _filaInfo('Apiario', _apiario?.nombre ?? 'Punto suelto'),
          if (colmena.tipoColmenaId.isNotEmpty) _filaInfo('Tipo', colmena.tipoColmenaId),
          if (colmena.razaId.isNotEmpty) _filaInfo('Raza', colmena.razaId),
          if (colmena.anoReina != null)
            _filaInfo('Reina', '${colmena.anoReina} · marca ${colmena.colorMarcaReina}'),
          if (colmena.ultimaLatitud != null)
            _filaInfo('Última ubicación',
                '${colmena.ultimaLatitud!.toStringAsFixed(6)}, ${colmena.ultimaLongitud!.toStringAsFixed(6)}'),
          if (colmena.fechaAltaMs != null)
            _filaInfo('Alta', formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(colmena.fechaAltaMs!))),
          if (colmena.notas.isNotEmpty) _filaInfo('Notas', colmena.notas),
          SizedBox(height: 16),
          Text('Historia', style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: 8),
          if (_eventos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Sin eventos registrados todavía.',
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
        label: Text('Nuevo evento'),
      ),
    );
  }

  String _etiquetaEstado(EstadoColmena e) {
    switch (e) {
      case EstadoColmena.viva:
        return 'Viva';
      case EstadoColmena.vacia:
        return 'Vacía';
      case EstadoColmena.descolmenada:
        return 'Descolmenada';
      case EstadoColmena.enjambreNuevo:
        return 'Enjambre nuevo';
    }
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
              title: Text('Revisión'),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.revision),
            ),
            ListTile(
              leading: Icon(Icons.water_drop),
              title: Text('Cosecha'),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.cosecha),
            ),
            ListTile(
              leading: Icon(Icons.medical_services),
              title: Text('Tratamiento'),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.tratamiento),
            ),
            ListTile(
              leading: Icon(Icons.warning_amber),
              title: Text('Incidencia'),
              onTap: () => Navigator.pop(context, TipoEventoNuevo.incidencia),
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Movimiento'),
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
      if (r.presenciaReina != 'no_observada') 'Reina: ${r.presenciaReina}',
      if (r.nivelPostura != null) 'postura ${r.nivelPostura}',
      if (r.varroaCaidaDiaria != null) 'varroa ${r.varroaCaidaDiaria}/día',
    ];
    return _EventoTimeline._(r.fechaMs, 'Revisión', partes.join(' · '), Icons.visibility);
  }

  factory _EventoTimeline.cosecha(CosechaMiel c) {
    final partes = <String>[
      if (c.kilosMiel != null) '${c.kilosMiel!.toStringAsFixed(1)} kg de miel',
      if (c.kilosCera != null) '${c.kilosCera!.toStringAsFixed(2)} kg de cera',
      if (c.kilosPolen != null) '${c.kilosPolen!.toStringAsFixed(2)} kg de polen',
      if (c.numeroAlza != null) 'alza ${c.numeroAlza}',
    ];
    return _EventoTimeline._(c.fechaMs, 'Cosecha', partes.join(' · '), Icons.water_drop);
  }

  factory _EventoTimeline.tratamiento(TratamientoVarroa t) {
    final partes = <String>[
      if (t.sustanciaActivaId.isNotEmpty) t.sustanciaActivaId,
      if (t.dosis.isNotEmpty) t.dosis,
      if (t.vehiculo.isNotEmpty) t.vehiculo,
    ];
    return _EventoTimeline._(t.fechaAplicacionMs, 'Tratamiento · ${t.tipo}', partes.join(' · '), Icons.medical_services);
  }

  factory _EventoTimeline.incidencia(IncidenciaApicola i) {
    final partes = <String>[
      if (i.diagnostico.isNotEmpty) i.diagnostico,
      if (i.severidad != null) 'sev. ${i.severidad}',
      if (i.resuelta) 'resuelta',
    ];
    return _EventoTimeline._(i.fechaMs, 'Incidencia · ${i.tipo}', partes.join(' · '), Icons.warning_amber);
  }

  factory _EventoTimeline.movimiento(Movimiento m) {
    final partes = <String>[
      if (m.numeroColmenas > 1) '${m.numeroColmenas} colmenas',
      if (m.notas.isNotEmpty) m.notas,
    ];
    return _EventoTimeline._(m.fechaMovimientoMs, 'Movimiento · ${m.motivo}', partes.join(' · '), Icons.swap_horiz);
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
