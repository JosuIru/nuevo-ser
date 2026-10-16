import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import 'ficha_animal.dart';
import 'ficha_lote.dart';
import 'formularios_ganado.dart';
import 'widgets/relleno_seguro.dart';

// ─── Textos compartidos por las pantallas del ganado ───

String etiquetaEspecie(String especie, String idioma) =>
    buscarOpcion(especiesGanado, especie)?.etiqueta(idioma) ?? especie;

/// «Pasillo · Zunbeltz» para cada zona, para decir dónde está un lote.
Future<Map<int, String>> nombresDeZonas(BaseDatosSoleraZunbeltz bd) async {
  final fincas = {for (final finca in await bd.listarFincas()) finca.id: finca};
  return {
    for (final zona in await bd.listarZonas())
      if (zona.id != null)
        zona.id!: [
          if (zona.nombre.isNotEmpty) zona.nombre,
          if (fincas[zona.fincaId] != null) fincas[zona.fincaId]!.nombre,
        ].join(' · '),
  };
}

/// «En Pasillo · Zunbeltz desde el 12/10/2026», «Fuera: Sierra de Urbasa»…
String describirUbicacion(MovimientoGanado? ultimo, Map<int, String> zonas,
    AppLocalizations textos, String idioma) {
  if (ultimo == null) return textos.ganSinUbicar;
  final desde = DateFormat('dd/MM/yyyy', idioma)
      .format(DateTime.fromMillisecondsSinceEpoch(ultimo.fechaMs));
  if (ultimo.esSalida) {
    return textos.ganFuera(
        ultimo.destinoExterno.isEmpty ? '—' : ultimo.destinoExterno, desde);
  }
  final zona = zonas[ultimo.zonaDestinoId];
  return zona == null ? textos.ganSinUbicar : textos.ganEnZona(zona, desde);
}

/// «Carne: libre desde el 25/10 · Leche: libre desde el 19/10».
String? describirSupresion(
    SupresionVigente supresion, AppLocalizations textos, String idioma) {
  if (!supresion.hayAlguna) return null;
  final formato = DateFormat('dd/MM/yyyy', idioma);
  return [
    if (supresion.carneHasta != null)
      textos.ganSupresionCarne(formato.format(supresion.carneHasta!)),
    if (supresion.lecheHasta != null)
      textos.ganSupresionLeche(formato.format(supresion.lecheHasta!)),
  ].join(' · ');
}

/// Pestaña «Ganado»: los lotes y dónde está cada uno, los animales y los
/// últimos movimientos.
class PantallaGanado extends StatefulWidget {
  const PantallaGanado({super.key});

  @override
  State<PantallaGanado> createState() => _PantallaGanadoState();
}

class _PantallaGanadoState extends State<PantallaGanado>
    with SingleTickerProviderStateMixin {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _pestanas = TabController(length: 3, vsync: this)
    ..addListener(() {
      if (mounted) setState(() {});
    });
  final _busqueda = TextEditingController();
  List<ResumenLote> _lotes = const [];
  List<Animal> _animales = const [];
  List<MovimientoGanado> _movimientos = const [];
  Map<int, String> _zonas = const {};
  Map<int, String> _nombresLote = const {};
  Map<int, SupresionVigente> _supresionPorLote = const {};
  bool _verCerrados = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    notificadorDatos.addListener(_cargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_cargar);
    _pestanas.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final lotes = await _bd.listarResumenLotes(soloActivos: !_verCerrados);
      final todosLosLotes = await _bd.listarLotes();
      final animales = await _bd.listarAnimales();
      final movimientos = await _bd.listarMovimientos();
      final zonas = await nombresDeZonas(_bd);
      final ahora = DateTime.now();
      final supresion = <int, SupresionVigente>{};
      for (final resumen in lotes) {
        final id = resumen.lote.id;
        if (id == null) continue;
        supresion[id] =
            supresionVigente(await _bd.listarEventosGanado(loteId: id), ahora);
      }
      if (!mounted) return;
      setState(() {
        _lotes = lotes;
        _animales = animales;
        _movimientos = movimientos;
        _zonas = zonas;
        _nombresLote = {
          for (final lote in todosLosLotes)
            if (lote.id != null) lote.id!: lote.nombre
        };
        _supresionPorLote = supresion;
        _cargando = false;
      });
    } catch (_) {
      // Sin BD (tests de pantallas sin plugins): vacío en vez de romper.
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    await _cargar();
  }

  Future<void> _nuevoLote() async {
    final guardado = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const FormularioLote()));
    if (guardado == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Future<void> _nuevoAnimal() async {
    final guardado = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const FormularioAnimal()));
    if (guardado == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Future<void> _moverUnLote() async {
    final textos = AppLocalizations.of(context);
    final activos = _lotes.where((resumen) => resumen.lote.activo).toList();
    if (activos.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.ganSinLotes)));
      return;
    }
    final elegido = await elegirLote(context, activos, _zonas);
    if (elegido == null || !mounted) return;
    final guardado = await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => FormularioMovimiento(lote: elegido.lote)));
    if (guardado == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final puedeRegistrar = politicaEspacioActual.puedeRegistrarGanado;
    final pestana = _pestanas.index;
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.ganTitulo),
        bottom: TabBar(
          controller: _pestanas,
          tabs: [
            Tab(text: textos.ganLotes),
            Tab(text: textos.ganAnimales),
            Tab(text: textos.ganMovimientos),
          ],
        ),
      ),
      floatingActionButton: !puedeRegistrar
          ? null
          : switch (pestana) {
              0 => FloatingActionButton.extended(
                  heroTag: 'ganado',
                  onPressed: _nuevoLote,
                  icon: const Icon(Icons.add),
                  label: Text(textos.ganNuevoLote),
                ),
              1 => FloatingActionButton.extended(
                  heroTag: 'ganado',
                  onPressed: _nuevoAnimal,
                  icon: const Icon(Icons.add),
                  label: Text(textos.ganNuevoAnimal),
                ),
              _ => FloatingActionButton.extended(
                  heroTag: 'ganado',
                  onPressed: _moverUnLote,
                  icon: const Icon(Icons.moving),
                  label: Text(textos.ganMoverLote),
                ),
            },
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _pestanas,
              children: [
                _listaLotes(textos),
                _listaAnimales(textos),
                _listaMovimientos(textos),
              ],
            ),
    );
  }

  Widget _listaLotes(AppLocalizations textos) {
    final idioma = Localizations.localeOf(context).languageCode;
    return ListView(
      padding:
          rellenoSobreBarraSistema(context, const EdgeInsets.only(bottom: 88)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(textos.ganIntro,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        SwitchListTile(
          title: Text(textos.ganVerCerrados),
          value: _verCerrados,
          onChanged: (valor) {
            setState(() => _verCerrados = valor);
            _cargar();
          },
        ),
        if (_lotes.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(textos.ganSinLotes, textAlign: TextAlign.center),
          ),
        for (final resumen in _lotes)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.pets_outlined),
              title: Text(resumen.lote.nombre.isEmpty
                  ? etiquetaEspecie(resumen.lote.especie, idioma)
                  : resumen.lote.nombre),
              subtitle: Text([
                [
                  if (resumen.lote.especie.isNotEmpty)
                    etiquetaEspecie(resumen.lote.especie, idioma),
                  textos.ganCabezas(resumen.cabezas),
                  if (!resumen.lote.activo) textos.ganLoteCerrado,
                ].join(' · '),
                describirUbicacion(
                    resumen.ultimoMovimiento, _zonas, textos, idioma),
                if (describirSupresion(
                        _supresionPorLote[resumen.lote.id] ??
                            const SupresionVigente(),
                        textos,
                        idioma)
                    case final supresion?)
                  supresion,
              ].join('\n')),
              isThreeLine: true,
              trailing: (_supresionPorLote[resumen.lote.id]?.hayAlguna ?? false)
                  ? Icon(Icons.medication_outlined,
                      color: Theme.of(context).colorScheme.error)
                  : const Icon(Icons.chevron_right),
              onTap: () => _abrir(FichaLote(loteId: resumen.lote.id!)),
            ),
          ),
      ],
    );
  }

  Widget _listaAnimales(AppLocalizations textos) {
    final idioma = Localizations.localeOf(context).languageCode;
    final filtro = _busqueda.text.trim().toLowerCase();
    final animales = _animales
        .where((animal) =>
            filtro.isEmpty ||
            animal.identificacion.toLowerCase().contains(filtro) ||
            animal.nombre.toLowerCase().contains(filtro))
        .toList();
    return ListView(
      padding:
          rellenoSobreBarraSistema(context, const EdgeInsets.only(bottom: 88)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _busqueda,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: textos.ganBuscarAnimal,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (animales.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(textos.ganSinAnimales, textAlign: TextAlign.center),
          ),
        for (final animal in animales)
          ListTile(
            leading:
                Icon(animal.activo ? Icons.tag : Icons.remove_circle_outline),
            title: Text(animal.rotulo.isEmpty ? '—' : animal.rotulo),
            subtitle: Text([
              if (animal.especie.isNotEmpty)
                etiquetaEspecie(animal.especie, idioma),
              if (animal.raza.isNotEmpty) animal.raza,
              if (!animal.activo)
                buscarOpcion(estadosAnimal, animal.estado)?.etiqueta(idioma) ??
                    animal.estado
              else if (_nombresLote[animal.loteId] case final lote?)
                lote
              else
                textos.ganSinLote,
            ].join(' · ')),
            onTap: () => _abrir(FichaAnimal(animalId: animal.id!)),
          ),
      ],
    );
  }

  Widget _listaMovimientos(AppLocalizations textos) {
    final idioma = Localizations.localeOf(context).languageCode;
    final formato = DateFormat('dd/MM/yyyy', idioma);
    return ListView(
      padding:
          rellenoSobreBarraSistema(context, const EdgeInsets.only(bottom: 88)),
      children: [
        if (_movimientos.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(textos.ganSinMovimientos, textAlign: TextAlign.center),
          ),
        for (final movimiento in _movimientos.take(200))
          ListTile(
            leading: Icon(iconoMovimiento(movimiento.tipo)),
            title: Text(_nombresLote[movimiento.loteId] ?? '—'),
            subtitle: Text([
              formato.format(
                  DateTime.fromMillisecondsSinceEpoch(movimiento.fechaMs)),
              trayectoMovimiento(movimiento, _zonas, textos),
              if (movimiento.cabezas > 0) textos.ganCabezas(movimiento.cabezas),
            ].join(' · ')),
            onTap: () => _abrir(FichaLote(loteId: movimiento.loteId)),
          ),
      ],
    );
  }
}

IconData iconoMovimiento(String tipo) => switch (tipo) {
      tipoMovimientoEntrada => Icons.login,
      tipoMovimientoSalida => Icons.logout,
      _ => Icons.moving,
    };

/// «Pasillo → Los Avellanos», «→ Sierra de Urbasa».
String trayectoMovimiento(MovimientoGanado movimiento, Map<int, String> zonas,
    AppLocalizations textos) {
  final origen = movimiento.tipo == tipoMovimientoEntrada
      ? (movimiento.destinoExterno.isEmpty
          ? textos.ganFueraDelEspacio
          : movimiento.destinoExterno)
      : (zonas[movimiento.zonaOrigenId] ?? '?');
  final destino = movimiento.esSalida
      ? (movimiento.destinoExterno.isEmpty
          ? textos.ganFueraDelEspacio
          : movimiento.destinoExterno)
      : (zonas[movimiento.zonaDestinoId] ?? '?');
  return '$origen → $destino';
}

/// Hoja para elegir uno de [lotes].
Future<ResumenLote?> elegirLote(
    BuildContext context, List<ResumenLote> lotes, Map<int, String> zonas) {
  final textos = AppLocalizations.of(context);
  final idioma = Localizations.localeOf(context).languageCode;
  return showModalBottomSheet<ResumenLote>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (contexto) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(textos.ganElegirLote,
                style: Theme.of(contexto).textTheme.titleMedium),
          ),
          for (final resumen in lotes)
            ListTile(
              leading: const Icon(Icons.pets_outlined),
              title: Text(resumen.lote.nombre),
              subtitle: Text(
                  '${textos.ganCabezas(resumen.cabezas)} · ${describirUbicacion(resumen.ultimoMovimiento, zonas, textos, idioma)}'),
              onTap: () => Navigator.pop(contexto, resumen),
            ),
        ],
      ),
    ),
  );
}
