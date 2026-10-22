import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../modelos/historial_animal.dart';
import 'ficha_lote.dart';
import 'formularios_ganado.dart';
import 'pantalla_ganado.dart';
import 'widgets/confirmar_borrado.dart';
import 'widgets/relleno_seguro.dart';

/// Un animal: su ficha, su lote, si está en plazo de supresión y lo que se
/// le ha hecho (a él y a su lote).
class FichaAnimal extends StatefulWidget {
  const FichaAnimal({super.key, required this.animalId});

  final int animalId;

  @override
  State<FichaAnimal> createState() => _FichaAnimalState();
}

class _FichaAnimalState extends State<FichaAnimal> {
  final _bd = BaseDatosSoleraZunbeltz();
  Animal? _animal;
  LoteGanado? _lote;
  List<EventoGanado> _eventos = const [];
  List<MovimientoGanado> _movimientosRebano = const [];
  Map<int, String> _zonas = const {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final animal = await _bd.obtenerAnimal(widget.animalId);
    final lote =
        animal?.loteId == null ? null : await _bd.obtenerLote(animal!.loteId!);
    final eventos = animal == null
        ? const <EventoGanado>[]
        : await _bd.listarEventosGanado(
            animalId: animal.id, loteId: animal.loteId);
    final movimientos = animal?.loteId == null
        ? const <MovimientoGanado>[]
        : await _bd.listarMovimientos(loteId: animal!.loteId);
    final zonas = await nombresDeZonas(_bd);
    if (!mounted) return;
    setState(() {
      _animal = animal;
      _lote = lote;
      _eventos = eventos;
      _movimientosRebano = movimientos;
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

  Future<bool> _cambiarDeLote(Animal animal) async {
    final textos = AppLocalizations.of(context);
    final lotes = (await _bd.listarLotes(soloActivos: true))
        .where((lote) => lote.id != animal.loteId)
        .toList();
    if (!mounted) return false;
    if (lotes.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.ganSinOtrosLotes)));
      return false;
    }
    final elegido = await showModalBottomSheet<LoteGanado>(
      context: context,
      showDragHandle: true,
      builder: (contexto) => SafeArea(
        child: ListView(shrinkWrap: true, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(textos.ganElegirLote,
                style: Theme.of(contexto).textTheme.titleMedium),
          ),
          for (final lote in lotes)
            ListTile(
              leading: const Icon(Icons.pets_outlined),
              title: Text(lote.nombre),
              onTap: () => Navigator.pop(contexto, lote),
            ),
        ]),
      ),
    );
    if (elegido == null) return false;
    await _bd.actualizarAnimal(animal.id!, {'lote_id': elegido.id});
    return true;
  }

  Future<bool> _darDeBaja(Animal animal) async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    var estado = 'vendido';
    var fecha = DateTime.now();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, setStateDialogo) => AlertDialog(
          title: Text(textos.ganDarDeBaja),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            RadioGroup<String>(
              groupValue: estado,
              onChanged: (valor) =>
                  setStateDialogo(() => estado = valor ?? estado),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                for (final opcion in estadosAnimal
                    .where((e) => e.codigo != estadoAnimalActivo))
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: opcion.codigo,
                    title: Text(opcion.etiqueta(idioma)),
                  ),
              ]),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(DateFormat('dd/MM/yyyy', idioma).format(fecha)),
              onTap: () async {
                final elegida = await showDatePicker(
                  context: contexto,
                  initialDate: fecha,
                  firstDate: DateTime(fecha.year - 5),
                  lastDate: DateTime.now(),
                );
                if (elegida != null) setStateDialogo(() => fecha = elegida);
              },
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto, false),
                child: Text(textos.comunCancelar)),
            FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: Text(textos.comunGuardar)),
          ],
        ),
      ),
    );
    if (confirmado != true) return false;
    await _bd.actualizarAnimal(animal.id!, {
      'estado': estado,
      'fecha_baja_ms': fecha.millisecondsSinceEpoch,
    });
    return true;
  }

  Future<void> _borrar() async {
    if (!await confirmarBorrado(context)) return;
    await _bd.borrarAnimal(widget.animalId);
    avisarCambioDatos();
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Una entrada de la línea de tiempo.
  Widget _hito(HitoAnimal hito, AppLocalizations textos, String idioma,
      String Function(int?) fecha) {
    final animal = _animal!;
    switch (hito.tipo) {
      case TipoHitoAnimal.nacimiento:
        return ListTile(
          leading: const Icon(Icons.cake_outlined),
          title: Text(textos.ganHistNacimiento),
          subtitle: Text([
            fecha(hito.fechaMs),
            if (animal.madre.isNotEmpty) '${textos.ganMadre}: ${animal.madre}',
          ].join(' · ')),
        );
      case TipoHitoAnimal.baja:
        return ListTile(
          leading: const Icon(Icons.remove_circle_outline),
          title: Text(textos.ganHistBaja(
              buscarOpcion(estadosAnimal, animal.estado)?.etiqueta(idioma) ??
                  animal.estado)),
          subtitle: Text(fecha(hito.fechaMs)),
        );
      case TipoHitoAnimal.movimientoRebano:
        final movimiento = hito.movimiento!;
        return ListTile(
          leading: Icon(iconoMovimiento(movimiento.tipo)),
          title: Text(
              '${buscarOpcion(tiposMovimientoGanado, movimiento.tipo)?.etiqueta(idioma) ?? movimiento.tipo}: '
              '${trayectoMovimiento(movimiento, _zonas, textos)}'),
          subtitle: Text([
            fecha(hito.fechaMs),
            textos.ganHistConSuRebano,
            if (movimiento.guia.isNotEmpty)
              '${textos.ganGuia}: ${movimiento.guia}',
          ].join(' · ')),
          onTap: _lote == null
              ? null
              : () => _tras(_ir(FichaLote(loteId: _lote!.id!))),
        );
      case TipoHitoAnimal.evento:
        final evento = hito.evento!;
        return ListTile(
          leading: Icon(iconoEvento(evento.tipo)),
          title: Text(describirEvento(evento, textos, idioma)),
          subtitle: Text([
            fecha(evento.fechaMs),
            if (evento.animalId == null) textos.ganAlLote,
          ].join(' · ')),
          onTap: () => _tras(mostrarApunteGanado(context,
              titulo: describirEvento(evento, textos, idioma),
              detalle: [
                fecha(evento.fechaMs),
                if (evento.veterinario.isNotEmpty) evento.veterinario,
                if (evento.receta.isNotEmpty)
                  '${textos.ganReceta}: ${evento.receta}',
              ].join(' · '),
              autorUid: evento.autorUid,
              borrar: () => _bd.borrarEventoGanado(evento.id!))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final animal = _animal;
    if (_cargando || animal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: _cargando
                ? const CircularProgressIndicator()
                : Text(textos.ganNoExiste)),
      );
    }
    final politica = politicaEspacioActual;
    final puedeEditar = politica.puedeEditarGanado(animal.autorUid);
    final puedeManejar = politica.puedeManejarAnimales && animal.activo;
    final formato = DateFormat('dd/MM/yyyy', idioma);
    final supresion = describirSupresion(
        supresionVigente(_eventos, DateTime.now(),
            ecologico: _lote?.ecologico ?? false),
        textos,
        idioma);
    final ecologico = tarjetaEcologico(context, _lote, _eventos, textos);
    String fecha(int? ms) => ms == null
        ? '—'
        : formato.format(DateTime.fromMillisecondsSinceEpoch(ms));
    final historial = historialDeAnimal(
        animal: animal, movimientos: _movimientosRebano, eventos: _eventos);

    return Scaffold(
      appBar: AppBar(
        title: Text(animal.rotulo.isEmpty ? '—' : animal.rotulo),
        actions: [
          if (puedeEditar) ...[
            IconButton(
              tooltip: textos.ganEditarAnimal,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _tras(_ir(FormularioAnimal(animal: animal))),
            ),
            IconButton(
              tooltip: textos.comunBorrar,
              icon: const Icon(Icons.delete_outline),
              onPressed: _borrar,
            ),
          ],
        ],
      ),
      body: ListView(
        padding: rellenoSobreBarraSistema(
            context, const EdgeInsets.only(bottom: 24)),
        children: [
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text([
              if (animal.especie.isNotEmpty)
                etiquetaEspecie(animal.especie, idioma),
              if (animal.raza.isNotEmpty) animal.raza,
              if (buscarOpcion(sexosAnimal, animal.sexo) case final sexo?)
                sexo.etiqueta(idioma),
            ].join(' · ')),
            subtitle: Text([
              '${textos.ganNacimiento}: ${fecha(animal.fechaNacimientoMs)}',
              if (animal.madre.isNotEmpty)
                '${textos.ganMadre}: ${animal.madre}',
            ].join(' · ')),
          ),
          ListTile(
            leading: const Icon(Icons.pets_outlined),
            title: Text(_lote?.nombre ?? textos.ganSinLote),
            subtitle: Text(animal.activo
                ? textos.ganLote
                : '${buscarOpcion(estadosAnimal, animal.estado)?.etiqueta(idioma) ?? animal.estado} · ${fecha(animal.fechaBajaMs)}'),
            trailing: _lote == null ? null : const Icon(Icons.chevron_right),
            onTap: _lote == null
                ? null
                : () => _tras(_ir(FichaLote(loteId: _lote!.id!))),
          ),
          if (ecologico != null) ecologico,
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
          if (animal.notas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(animal.notas),
            ),
          if (puedeManejar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.tonalIcon(
                  onPressed: () => _tras(_ir(FormularioEventoGanado(
                      animalId: animal.id, titulo: animal.rotulo))),
                  icon: const Icon(Icons.medication_outlined),
                  label: Text(textos.ganApuntarManejo),
                ),
                OutlinedButton.icon(
                  onPressed: () => _tras(_cambiarDeLote(animal)),
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(textos.ganCambiarDeLote),
                ),
                OutlinedButton.icon(
                  onPressed: () => _tras(_darDeBaja(animal)),
                  icon: const Icon(Icons.remove_circle_outline),
                  label: Text(textos.ganDarDeBaja),
                ),
              ]),
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
          for (final hito in historial) _hito(hito, textos, idioma, fecha),
          if (historial.any((hito) => hito.delRebano))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(textos.ganHistNotaRebano,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
