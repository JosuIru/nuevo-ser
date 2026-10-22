import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../servicios/generador_libro_explotacion.dart';
import 'ficha_animal.dart';
import 'formularios_ganado.dart';
import 'pantalla_ganado.dart';
import 'pantalla_inventario.dart' show numeroLegible;
import 'widgets/confirmar_borrado.dart';
import 'widgets/relleno_seguro.dart';

/// «Cura o tratamiento · ivermectina · 1 ml/10 kg · carne 28 d».
String describirEvento(
    EventoGanado evento, AppLocalizations textos, String idioma) {
  final tipo = buscarOpcion(tiposEventoGanado, evento.tipo)?.etiqueta(idioma) ??
      evento.tipo;
  return [
    tipo,
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
    required Future<void> Function() borrar}) async {
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
  bool _cargando = true;

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
    if (!mounted) return;
    setState(() {
      _lote = lote;
      _animales = animales;
      _movimientos = movimientos;
      _eventos = eventos;
      _zonas = zonas;
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
    final politica = politicaEspacioActual;
    final puedeEditar = politica.puedeEditarGanado(lote.autorUid);
    final puedeRegistrar = politica.puedeRegistrarGanado && lote.activo;
    final activos = _animales.where((animal) => animal.activo).toList();
    final cabezas = cabezasDeLote(lote, _animales);
    final supresion = describirSupresion(
        supresionVigente(_eventos, DateTime.now(), ecologico: lote.ecologico),
        textos,
        idioma);
    final ugm = ugmDeLote(lote, _animales, DateTime.now());
    final ecologico = tarjetaEcologico(context, lote, _eventos, textos);
    final titular = lote.titularUid.isEmpty
        ? textos.ganTitularEspacio
        : personasEspacio.value
                .where((persona) => persona.uid == lote.titularUid)
                .firstOrNull
                ?.nombre ??
            '—';
    final formato = DateFormat('dd/MM/yyyy', idioma);
    final historial = <(int, Widget)>[
      for (final movimiento in _movimientos)
        (
          movimiento.fechaMs,
          ListTile(
            leading: Icon(iconoMovimiento(movimiento.tipo)),
            trailing: IconButton(
              tooltip: textos.libroHoja,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () => _hojaMovimiento(lote, movimiento),
            ),
            title: Text(trayectoMovimiento(movimiento, _zonas, textos)),
            subtitle: Text([
              formato.format(
                  DateTime.fromMillisecondsSinceEpoch(movimiento.fechaMs)),
              if (movimiento.cabezas > 0) textos.ganCabezas(movimiento.cabezas),
              if (movimiento.guia.isNotEmpty)
                '${textos.ganGuia}: ${movimiento.guia}',
              if (movimiento.notas.isNotEmpty) movimiento.notas,
            ].join(' · ')),
            onTap: () => _tras(mostrarApunteGanado(context,
                titulo: trayectoMovimiento(movimiento, _zonas, textos),
                detalle: formato.format(
                    DateTime.fromMillisecondsSinceEpoch(movimiento.fechaMs)),
                autorUid: movimiento.autorUid,
                borrar: () => _bd.borrarMovimiento(movimiento.id!))),
          )
        ),
      for (final evento in _eventos)
        (
          evento.fechaMs,
          ListTile(
            leading: Icon(iconoEvento(evento.tipo)),
            title: Text(describirEvento(evento, textos, idioma)),
            subtitle: Text(formato
                .format(DateTime.fromMillisecondsSinceEpoch(evento.fechaMs))),
            onTap: () => _tras(mostrarApunteGanado(context,
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
            IconButton(
              tooltip: textos.comunBorrar,
              icon: const Icon(Icons.delete_outline),
              onPressed: _borrarLote,
            ),
          ],
        ],
      ),
      body: ListView(
        padding: rellenoSobreBarraSistema(
            context, const EdgeInsets.only(bottom: 24)),
        children: [
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(describirUbicacion(
                ultimoMovimiento(_movimientos), _zonas, textos, idioma)),
            subtitle: Text([
              if (lote.especie.isNotEmpty)
                etiquetaEspecie(lote.especie, idioma),
              textos.ganCabezas(cabezas),
              if (lote.cabezasSinIdentificar > 0)
                textos.ganDeEllasSinCrotal(lote.cabezasSinIdentificar),
              if (ugm > 0) textos.ganUgm(numeroConComa(ugm)),
              if (lote.ecologico) textos.ganEcologico,
              titular,
              if (!lote.activo) textos.ganLoteCerrado,
            ].join(' · ')),
          ),
          if (supresion != null)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Theme.of(context).colorScheme.error,
              child: ListTile(
                textColor: Theme.of(context).colorScheme.onError,
                iconColor: Theme.of(context).colorScheme.onError,
                leading: const Icon(Icons.medication_outlined),
                title: Text(textos.ganEnSupresion),
                subtitle: Text(supresion),
              ),
            ),
          if (ecologico != null) ecologico,
          if (lote.notas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(lote.notas),
            ),
          if (puedeRegistrar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  onPressed: () => _tras(_ir(FormularioMovimiento(lote: lote))),
                  icon: const Icon(Icons.moving),
                  label: Text(textos.ganMover),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _tras(_ir(FormularioEventoGanado(
                      loteId: lote.id, titulo: lote.nombre))),
                  icon: const Icon(Icons.medication_outlined),
                  label: Text(textos.ganApuntarManejo),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      _tras(_ir(FormularioAnimal(loteId: lote.id))),
                  icon: const Icon(Icons.add),
                  label: Text(textos.ganNuevoAnimal),
                ),
              ]),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(textos.ganAnimalesDelLote(activos.length),
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (activos.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(textos.ganLoteSinAnimales),
            ),
          for (final animal in activos)
            ListTile(
              dense: true,
              leading: const Icon(Icons.tag),
              title: Text(animal.rotulo.isEmpty ? '—' : animal.rotulo),
              subtitle: Text([
                if (animal.raza.isNotEmpty) animal.raza,
                if (buscarOpcion(sexosAnimal, animal.sexo) case final sexo?)
                  sexo.etiqueta(idioma),
              ].join(' · ')),
              onTap: () => _tras(_ir(FichaAnimal(animalId: animal.id!))),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(textos.ganHistorial,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (historial.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(textos.ganSinHistorial),
            ),
          for (final (_, fila) in historial) fila,
        ],
      ),
    );
  }
}
