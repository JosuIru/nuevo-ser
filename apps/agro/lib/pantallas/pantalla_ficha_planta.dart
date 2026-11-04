import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/cosecha.dart';
import '../modelos/finca.dart';
import '../modelos/incidencia.dart';
import '../modelos/observacion.dart';
import '../modelos/planta.dart';
import '../modelos/tratamiento.dart';
import 'pantalla_nueva_planta.dart';
import 'pantalla_nuevo_evento.dart';

/// Ficha de una planta: cabecera con datos fijos (cultivo, variedad,
/// finca, coords) y un **timeline cronológico** que mezcla cosechas,
/// observaciones, incidencias y tratamientos. La unificación de los
/// cuatro tipos en un único hilo cronológico es la vista más útil para
/// el agricultor: "¿qué le ha pasado a este árbol?".
class PantallaFichaPlanta extends StatefulWidget {
  final int plantaId;
  PantallaFichaPlanta({super.key, required this.plantaId});

  @override
  State<PantallaFichaPlanta> createState() => _PantallaFichaPlantaState();
}

class _PantallaFichaPlantaState extends State<PantallaFichaPlanta> {
  Planta? _planta;
  Finca? _finca;
  List<_EventoTimeline> _eventos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final db = BaseDatosAgro.instancia;
    final planta = await db.obtenerPlanta(widget.plantaId);
    if (planta == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final finca = planta.fincaId != null ? await db.obtenerFinca(planta.fincaId!) : null;
    final cosechas = await db.listarCosechasDePlanta(planta.id!);
    final observaciones = await db.listarObservacionesDePlanta(planta.id!);
    final incidencias = await db.listarIncidenciasDePlanta(planta.id!);
    final tratamientos = await db.listarTratamientosDePlanta(planta.id!);
    final eventos = <_EventoTimeline>[
      for (final c in cosechas) _EventoTimeline.deCosecha(c),
      for (final o in observaciones) _EventoTimeline.deObservacion(o),
      for (final i in incidencias) _EventoTimeline.deIncidencia(i),
      for (final t in tratamientos) _EventoTimeline.deTratamiento(t),
    ]..sort((a, b) => b.fechaMs.compareTo(a.fechaMs));
    if (!mounted) return;
    setState(() {
      _planta = planta;
      _finca = finca;
      _eventos = eventos;
      _cargando = false;
    });
  }

  Future<void> _alAnadirEvento(TipoEventoNuevo tipo) async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoEvento(plantaId: widget.plantaId, tipo: tipo),
      ),
    );
    if (creado == true) _cargar();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final planta = _planta!;
    final cultivo = cultivoPorId(planta.cultivoId);
    return Scaffold(
      appBar: AppBar(
        title: Text(planta.etiqueta.isNotEmpty ? planta.etiqueta : cultivo.nombreVisible),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: SoleraL10n.t('agro.editar_planta'),
            onPressed: () async {
              final cambio = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => PantallaNuevaPlanta(plantaExistente: planta),
                ),
              );
              if (cambio == true) _cargar();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: SoleraL10n.t('agro.borrar_planta'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(SoleraL10n.t('agro.pregunta_borrar_planta')),
                  content: Text(SoleraL10n.t('agro.se_borrara_planta_y_su_historia')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: Text(SoleraL10n.t('borrar'), style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (ok != true) return;
              await BaseDatosAgro.instancia.borrarPlanta(planta.id!);
              if (!context.mounted) return;
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _Cabecera(planta: planta, finca: _finca),
          Divider(height: 1),
          if (_eventos.isEmpty)
            Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  '${SoleraL10n.t('agro.aun_no_hay_eventos_ayuda_1')}\n${SoleraL10n.t('agro.aun_no_hay_eventos_ayuda_2')}\n${SoleraL10n.t('agro.aun_no_hay_eventos_ayuda_3')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            for (final ev in _eventos)
              _TarjetaEvento(evento: ev, plantaId: planta.id!, alCambiar: _cargar),
          SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final tipo = await showModalBottomSheet<TipoEventoNuevo>(
            context: context,
            builder: (_) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.shopping_basket, color: Color(0xFF689F38)),
                    title: Text(SoleraL10n.t('agro.cosecha')),
                    onTap: () => Navigator.pop(context, TipoEventoNuevo.cosecha),
                  ),
                  ListTile(
                    leading: Icon(Icons.visibility, color: Color(0xFF1976D2)),
                    title: Text(SoleraL10n.t('agro.observacion')),
                    onTap: () => Navigator.pop(context, TipoEventoNuevo.observacion),
                  ),
                  ListTile(
                    leading: Icon(Icons.warning_amber, color: Color(0xFFE65100)),
                    title: Text(SoleraL10n.t('agro.incidencia_plaga_enfermedad')),
                    onTap: () => Navigator.pop(context, TipoEventoNuevo.incidencia),
                  ),
                  ListTile(
                    leading: Icon(Icons.medical_services, color: Color(0xFF6A1B9A)),
                    title: Text(SoleraL10n.t('agro.tratamiento')),
                    onTap: () => Navigator.pop(context, TipoEventoNuevo.tratamiento),
                  ),
                ],
              ),
            ),
          );
          if (tipo != null) _alAnadirEvento(tipo);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final Planta planta;
  final Finca? finca;
  _Cabecera({required this.planta, required this.finca});

  @override
  Widget build(BuildContext context) {
    final cultivo = cultivoPorId(planta.cultivoId);
    final fotos = GestorFotos.decodificar(planta.rutasFotosJson);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cultivo.color,
                child: Icon(cultivo.icono, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cultivo.nombreVisible, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (planta.variedad.isNotEmpty)
                      Text(planta.variedad, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          if (fotos.isNotEmpty) ...[
            SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: fotos.length,
                separatorBuilder: (_, __) => SizedBox(width: 6),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
                      body: Center(
                        child: InteractiveViewer(
                          child: Image.file(File(fotos[i]), errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.white, size: 80)),
                        ),
                      ),
                    ),
                  )),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(fotos[i]),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.black12,
                        child: Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 12),
          if (finca != null) _FilaDato(etiqueta: SoleraL10n.t('agro.finca'), valor: finca!.nombre),
          if (finca == null) _FilaDato(etiqueta: SoleraL10n.t('agro.finca'), valor: SoleraL10n.t('agro.punto_suelto')),
          if (planta.patron.isNotEmpty)
            _FilaDato(
              etiqueta: cultivo.categoria == CategoriaCultivo.micorricicoTrufa ? SoleraL10n.t('agro.hospedero') : SoleraL10n.t('agro.patron'),
              valor: planta.patron,
            ),
          if (planta.fechaPlantacionMs != null)
            _FilaDato(
              etiqueta: SoleraL10n.t('agro.plantada'),
              valor: DateFormat('dd MMM yyyy', SoleraL10n.idioma).format(DateTime.fromMillisecondsSinceEpoch(planta.fechaPlantacionMs!)),
            ),
          _FilaDato(
            etiqueta: SoleraL10n.t('agro.posicion'),
            valor: '${planta.latitud.toStringAsFixed(6)}, ${planta.longitud.toStringAsFixed(6)}'
                '${planta.precisionMetros != null ? '  ±${formatearNumero(planta.precisionMetros!)} m' : ''}',
          ),
          if (planta.notas.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(planta.notas),
          ],
        ],
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  _FilaDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(etiqueta, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(valor, style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

enum _AccionEvento { editar, borrar, toggleResuelta }

class _TarjetaEvento extends StatelessWidget {
  final _EventoTimeline evento;
  final int plantaId;
  final VoidCallback alCambiar;
  _TarjetaEvento({required this.evento, required this.plantaId, required this.alCambiar});

  Future<void> _alLongPress(BuildContext context) async {
    final accion = await showModalBottomSheet<_AccionEvento>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text(SoleraL10n.t('editar')),
              onTap: () => Navigator.pop(context, _AccionEvento.editar),
            ),
            if (evento.tipo == TipoEventoNuevo.incidencia)
              ListTile(
                leading: Icon(evento.incidenciaResuelta == true ? Icons.refresh : Icons.check_circle),
                title: Text(evento.incidenciaResuelta == true ? SoleraL10n.t('agro.reabrir_incidencia') : SoleraL10n.t('agro.cerrar_incidencia_resuelta')),
                onTap: () => Navigator.pop(context, _AccionEvento.toggleResuelta),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text(SoleraL10n.t('borrar'), style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, _AccionEvento.borrar),
            ),
          ],
        ),
      ),
    );
    if (accion == null || !context.mounted) return;
    final db = BaseDatosAgro.instancia;
    switch (accion) {
      case _AccionEvento.editar:
        final cambio = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PantallaNuevoEvento(
              plantaId: plantaId,
              tipo: evento.tipo,
              eventoExistenteId: evento.eventoId,
            ),
          ),
        );
        if (cambio == true) alCambiar();
        break;
      case _AccionEvento.toggleResuelta:
        final ahora = DateTime.now().millisecondsSinceEpoch;
        await db.actualizarIncidencia(evento.eventoId, {
          'resuelta': evento.incidenciaResuelta == true ? 0 : 1,
          'fecha_resolucion_ms': evento.incidenciaResuelta == true ? null : ahora,
        });
        alCambiar();
        break;
      case _AccionEvento.borrar:
        if (!context.mounted) return;
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(SoleraL10n.tf('agro.pregunta_borrar_evento', {'evento': evento.titulo.toLowerCase()})),
            content: Text(SoleraL10n.t('agro.accion_no_se_puede_deshacer')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text(SoleraL10n.t('cancelar'))),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text(SoleraL10n.t('borrar'), style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (ok != true) return;
        switch (evento.tipo) {
          case TipoEventoNuevo.cosecha:
            await db.borrarCosecha(evento.eventoId);
            break;
          case TipoEventoNuevo.observacion:
            await db.borrarObservacion(evento.eventoId);
            break;
          case TipoEventoNuevo.incidencia:
            await db.borrarIncidencia(evento.eventoId);
            break;
          case TipoEventoNuevo.tratamiento:
            await db.borrarTratamiento(evento.eventoId);
            break;
        }
        alCambiar();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onLongPress: () => _alLongPress(context),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: evento.color, child: Icon(evento.icono, color: Colors.white, size: 20)),
            title: Text(evento.titulo),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy', SoleraL10n.idioma).format(DateTime.fromMillisecondsSinceEpoch(evento.fechaMs))}'
              '${evento.subtitulo.isNotEmpty ? '  ·  ${evento.subtitulo}' : ''}',
            ),
            // Antes los 3 puntos eran un Icon decorativo y la única
            // forma de abrir el menú era tocar largo el card. El
            // tester (2026-05-15) probó tocar los 3 puntos y no
            // pasaba nada. Ahora el icono es un IconButton que abre
            // el mismo menú que el long press.
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: SoleraL10n.t('agro.acciones'),
              onPressed: () => _alLongPress(context),
            ),
            onTap: () => _alLongPress(context),
          ),
          if (evento.rutasFotos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: evento.rutasFotos.length,
                  separatorBuilder: (_, __) => SizedBox(width: 6),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _abrirFotoCompleta(context, evento.rutasFotos[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        File(evento.rutasFotos[i]),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.black12,
                          child: Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  void _abrirFotoCompleta(BuildContext context, String ruta) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: Center(
          child: InteractiveViewer(
            child: Image.file(File(ruta), errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.white, size: 80)),
          ),
        ),
      ),
    ));
  }
}

/// Nombre visible del tipo de incidencia guardado en BD (el valor
/// guardado no cambia; si no se reconoce se enseña tal cual).
String _nombreTipoIncidencia(String tipo) => switch (tipo) {
      'plaga' => SoleraL10n.t('agro.tipo_incidencia_plaga'),
      'enfermedad' => SoleraL10n.t('agro.tipo_incidencia_enfermedad'),
      'estres' => SoleraL10n.t('agro.tipo_incidencia_estres'),
      'fisiologico' => SoleraL10n.t('agro.tipo_incidencia_fisiologico'),
      'otro' => SoleraL10n.t('agro.tipo_otro'),
      _ => tipo,
    };

/// Nombre visible del tipo de tratamiento guardado en BD.
String _nombreTipoTratamiento(String tipo) => switch (tipo) {
      'fitosanitario' => SoleraL10n.t('agro.tipo_tratamiento_fitosanitario'),
      'abono' => SoleraL10n.t('agro.tipo_tratamiento_abono'),
      'riego' => SoleraL10n.t('agro.tipo_tratamiento_riego'),
      'poda' => SoleraL10n.t('agro.tipo_tratamiento_poda'),
      'otro' => SoleraL10n.t('agro.tipo_otro'),
      _ => tipo,
    };

/// Item del timeline unificado. Cuatro tipos de eventos colapsados a
/// una representación visual compartida (icono + color + título +
/// subtítulo + fecha) para que el agricultor lea de un vistazo el
/// historial de la planta sin saltar entre pestañas.
///
/// `eventoId` y `tipo` se llevan junto con los datos visuales para
/// permitir editar/borrar el evento desde el long-press de la tarjeta.
/// `incidenciaResuelta` es null para tipos que no son incidencia;
/// para incidencias indica si está resuelta para mostrar la acción
/// "cerrar/reabrir incidencia".
class _EventoTimeline {
  final int eventoId;
  final TipoEventoNuevo tipo;
  final int fechaMs;
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final List<String> rutasFotos;
  final bool? incidenciaResuelta;

  _EventoTimeline({
    required this.eventoId,
    required this.tipo,
    required this.fechaMs,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    this.rutasFotos = const [],
    this.incidenciaResuelta,
  });

  factory _EventoTimeline.deCosecha(Cosecha c) {
    final partes = <String>[];
    if (c.kilos != null) partes.add('${formatearNumero(c.kilos!, decimales: 2)} kg');
    if (c.unidades != null) partes.add(SoleraL10n.tf('agro.unidades_abreviado_n', {'n': c.unidades}));
    if (c.calidad != null) partes.add(SoleraL10n.tf('agro.calidad_abreviada_n_de_5', {'n': c.calidad}));
    return _EventoTimeline(
      eventoId: c.id!,
      tipo: TipoEventoNuevo.cosecha,
      fechaMs: c.fechaMs,
      icono: Icons.shopping_basket,
      color: Color(0xFF689F38),
      titulo: SoleraL10n.t('agro.cosecha'),
      subtitulo: partes.join(' · '),
      rutasFotos: GestorFotos.decodificar(c.rutasFotosJson),
    );
  }

  factory _EventoTimeline.deObservacion(Observacion o) {
    final partes = <String>[];
    if (o.salud != null) partes.add(SoleraL10n.tf('agro.salud_n_de_5', {'n': o.salud}));
    if (o.notas.isNotEmpty) partes.add(o.notas);
    return _EventoTimeline(
      eventoId: o.id!,
      tipo: TipoEventoNuevo.observacion,
      fechaMs: o.fechaMs,
      icono: Icons.visibility,
      color: Color(0xFF1976D2),
      titulo: SoleraL10n.t('agro.observacion'),
      subtitulo: partes.join(' · '),
      rutasFotos: GestorFotos.decodificar(o.rutasFotosJson),
    );
  }

  factory _EventoTimeline.deIncidencia(Incidencia i) {
    final partes = <String>[
      _nombreTipoIncidencia(i.tipo).toUpperCase(),
      if (i.diagnostico.isNotEmpty) i.diagnostico,
      if (i.severidad != null) SoleraL10n.tf('agro.severidad_abreviada_n_de_5', {'n': i.severidad}),
      if (i.resuelta) SoleraL10n.t('agro.resuelta_minuscula'),
    ];
    return _EventoTimeline(
      eventoId: i.id!,
      tipo: TipoEventoNuevo.incidencia,
      fechaMs: i.fechaMs,
      icono: Icons.warning_amber,
      color: i.resuelta ? Colors.grey : Color(0xFFE65100),
      titulo: SoleraL10n.t('agro.incidencia'),
      subtitulo: partes.join(' · '),
      rutasFotos: GestorFotos.decodificar(i.rutasFotosJson),
      incidenciaResuelta: i.resuelta,
    );
  }

  factory _EventoTimeline.deTratamiento(Tratamiento t) {
    final partes = <String>[
      _nombreTipoTratamiento(t.tipo).toUpperCase(),
      if (t.producto.isNotEmpty) t.producto,
      if (t.dosis.isNotEmpty) t.dosis,
    ];
    return _EventoTimeline(
      eventoId: t.id!,
      tipo: TipoEventoNuevo.tratamiento,
      fechaMs: t.fechaMs,
      icono: Icons.medical_services,
      color: Color(0xFF6A1B9A),
      titulo: SoleraL10n.t('agro.tratamiento'),
      subtitulo: partes.join(' · '),
    );
  }
}
