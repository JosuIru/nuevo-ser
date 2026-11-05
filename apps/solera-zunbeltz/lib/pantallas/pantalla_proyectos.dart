import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../estado/datos_notificador.dart';
import '../l10n/app_localizations.dart';
import '../modelos/amortizacion.dart';
import '../modelos/balance_convenio.dart';
import '../modelos/constantes.dart';
import '../modelos/finca.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../servicios/generador_comparativa_proyectos.dart';
import '../utiles/resumen_proyecto.dart';
import 'nuevo_proyecto.dart';
import 'proyecto_detalle.dart';
import 'widgets/proyecto_visual.dart';

/// Pestaña "Proyectos": el proceso de test por persona tester. Lista de
/// proyectos con su rentabilidad de un vistazo (comparativa) y, al entrar,
/// el panel completo del proyecto.
class PantallaProyectos extends StatefulWidget {
  const PantallaProyectos({super.key});

  @override
  State<PantallaProyectos> createState() => _PantallaProyectosState();
}

class _PantallaProyectosState extends State<PantallaProyectos> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<ProyectoTest> _proyectos = const [];
  List<Finca> _fincas = const [];
  Map<int, RentabilidadProyecto> _rentabilidad = const {};
  Map<int, BalanceConvenio> _balances = const {};

  /// Qué se ve: los abiertos (de partida) y/o los cerrados.
  bool _verAbiertos = true;
  bool _verCerrados = false;
  bool _cargando = true;
  bool _generando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
    notificadorDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => _cargar();

  Future<void> _cargar() async {
    var proyectos = <ProyectoTest>[];
    var fincas = <Finca>[];
    final rent = <int, RentabilidadProyecto>{};
    final balances = <int, BalanceConvenio>{};
    try {
      proyectos = await _bd.listarProyectos();
      fincas = await _bd.listarFincas();
      final bienes = {
        for (final bien in await _bd.listarBienes())
          if (bien.id != null) bien.id!: bien
      };
      await Future.wait([
        for (final p in proyectos)
          if (p.id != null)
            () async {
              final (rentabilidad, apuntes, usos, ventas) = await (
                _bd.rentabilidadProyecto(p.id!),
                _bd.listarApuntes(proyectoId: p.id),
                _bd.listarUsosBienes(p.id!),
                _bd.listarComercializacion(proyectoId: p.id),
              ).wait;
              rent[p.id!] = rentabilidad;
              // El mismo balance que la pantalla Convenio: apuntes, ventas y
              // las cuotas del inventario (bloque VI).
              balances[p.id!] = BalanceConvenio.calcular(
                proyecto: p,
                apuntes: [
                  ...apuntes,
                  ...apuntesDeAmortizacion(
                      proyecto: p,
                      usos: usos,
                      bienesPorId: bienes,
                      fincaId: p.fincaId ?? 0),
                ],
                ventas: ventas,
              );
            }(),
      ]);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _proyectos = proyectos;
      _fincas = fincas;
      _rentabilidad = rent;
      _balances = balances;
      _cargando = false;
    });
  }

  Future<void> _nuevo() async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NuevoProyecto(fincas: _fincas)),
    );
    if (creado == true) await _cargar();
  }

  Future<void> _abrir(ProyectoTest p) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProyectoDetalle(proyecto: p)),
    );
    // Siempre: desde el detalle se edita, se cierra o se apuntan ventas, y
    // la lista enseña nombre, estado y balance.
    if (mounted) await _cargar();
  }

  Future<void> _comparativa() async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    setState(() => _generando = true);
    try {
      final filas = <FilaComparativa>[
        for (final p in _proyectos)
          if (p.id != null)
            (
              proyecto: p,
              rentabilidad: _rentabilidad[p.id!] ?? const RentabilidadProyecto()
            ),
      ];
      final documento = await generarComparativaProyectosPdf(
          textos: textos,
          idioma: idioma,
          filas: filas,
          definitivo: politicaEspacioActual.documentoDefinitivo());
      await Printing.sharePdf(
          bytes: documento.bytes, filename: documento.nombreFichero);
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final abiertos = _proyectos.where((p) => !p.cerrado).toList();
    final cerrados = _proyectos.where((p) => p.cerrado).toList();
    final hayDeLosDos = abiertos.isNotEmpty && cerrados.isNotEmpty;
    // Con un solo tipo, sin filtros: se ve todo.
    final verAbiertos = !hayDeLosDos || _verAbiertos;
    final verCerrados = !hayDeLosDos || _verCerrados;
    final puedeCrear = politicaEspacioActual.puedeGestionarProyectos;
    return Scaffold(
      appBar: AppBar(
        title: Text(textos.proyectosTitulo),
        actions: [
          IconButton(
            tooltip: textos.comparativaPdf,
            icon: _generando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.bar_chart),
            onPressed: (_generando || _proyectos.isEmpty) ? null : _comparativa,
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: puedeCrear
          ? FloatingActionButton.extended(
              onPressed: _nuevo,
              icon: const Icon(Icons.add),
              label: Text(textos.proyectoNuevo),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _proyectos.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(textos.proyectosVacio,
                        textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    children: [
                      if (hayDeLosDos)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Wrap(spacing: 8, children: [
                            FilterChip(
                              label: Text(textos
                                  .proyFiltroAbiertos('${abiertos.length}')),
                              selected: _verAbiertos,
                              onSelected: (valor) =>
                                  setState(() => _verAbiertos = valor),
                            ),
                            FilterChip(
                              label: Text(textos
                                  .proyFiltroCerrados('${cerrados.length}')),
                              selected: _verCerrados,
                              onSelected: (valor) =>
                                  setState(() => _verCerrados = valor),
                            ),
                          ]),
                        ),
                      if (verAbiertos)
                        for (final p in abiertos)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TarjetaProyecto(
                              proyecto: p,
                              balance: _balances[p.id],
                              onTap: () => _abrir(p),
                            ),
                          ),
                      if (verCerrados)
                        for (final p in cerrados)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FilaProyectoCerrado(
                                proyecto: p, onTap: () => _abrir(p)),
                          ),
                      if (!verAbiertos && !verCerrados)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              _verAbiertos
                                  ? textos.proySinAbiertos
                                  : textos.proySinCerrados,
                              textAlign: TextAlign.center),
                        ),
                    ],
                  ),
                ),
    );
  }
}

/// Dos letras del proyecto: las de su especie si la tiene; si no, las de
/// la actividad o el nombre.
String _siglasProyecto(ProyectoTest proyecto, String idioma) {
  final especie = buscarOpcion(especiesGanado, proyecto.especie);
  final base = [
    if (especie != null && proyecto.especie != 'varias')
      especie.etiqueta(idioma),
    proyecto.actividad,
    proyecto.nombre,
  ].firstWhere((texto) => texto.trim().length >= 2, orElse: () => '·');
  return base
      .trim()
      .substring(0, base.trim().length >= 2 ? 2 : 1)
      .toUpperCase();
}

class _AvatarProyecto extends StatelessWidget {
  const _AvatarProyecto(
      {required this.proyecto, this.tamano = 64, this.apagado = false});

  final ProyectoTest proyecto;
  final double tamano;
  final bool apagado;

  @override
  Widget build(BuildContext context) {
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: apagado ? esquema.surfaceContainerHighest : colorCuadroEsmeralda,
        // Esquinas alternas, como los cuadros del logotipo.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(tamano * 0.18),
          topRight: Radius.circular(tamano * 0.18),
          bottomLeft: Radius.circular(tamano * 0.18),
          bottomRight: Radius.circular(tamano * 0.4),
        ),
      ),
      child: Text(_siglasProyecto(proyecto, idioma),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  apagado ? esquema.onSurfaceVariant : colorSobreCuadroClaro)),
    );
  }
}

class _TarjetaProyecto extends StatelessWidget {
  const _TarjetaProyecto({
    required this.proyecto,
    required this.balance,
    required this.onTap,
  });

  final ProyectoTest proyecto;
  final BalanceConvenio? balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final inicioMs = proyecto.fechaInicioMs;
    final subtitulo = [
      if (proyecto.persona.isNotEmpty) proyecto.persona,
      if (inicioMs != null && inicioMs != 0)
        textos.proyDesde(DateFormat.yMMMM(idioma)
            .format(DateTime.fromMillisecondsSinceEpoch(inicioMs))
            .toLowerCase()),
    ].join(' · ');
    final mes = mesDelTest(proyecto);
    final reparto = balance == null ? null : repartoDeGastos(balance!);
    final balanceTest = balance?.balanceTestCentimos ?? 0;
    return Material(
      color: esquema.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _AvatarProyecto(proyecto: proyecto),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proyecto.nombre.isEmpty ? '—' : proyecto.nombre,
                          style: estilos.titleLarge),
                      if (subtitulo.isNotEmpty)
                        Text(subtitulo,
                            style: estilos.bodyMedium
                                ?.copyWith(color: esquema.onSurfaceVariant)),
                    ],
                  ),
                ),
              ]),
              if (mes != null) ...[
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Text(
                      mes.mesActual == 0
                          ? textos.proyEmpieza(DateFormat.MMMMd(idioma).format(
                              DateTime.fromMillisecondsSinceEpoch(inicioMs!)))
                          : mes.mesesTotales == null
                              ? textos.proyMes('${mes.mesActual}')
                              : textos.proyMesDe(
                                  '${mes.mesActual}', '${mes.mesesTotales}'),
                      style: estilos.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(textos.proyAbierto,
                      style: estilos.titleSmall?.copyWith(
                          color: colores.hecha, fontWeight: FontWeight.w600)),
                ]),
                if (mes.mesesTotales != null) ...[
                  const SizedBox(height: 8),
                  BarraMesesTest(
                      hechos: mes.mesActual, totales: mes.mesesTotales!),
                ],
              ],
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textos.balanceTest,
                          style: estilos.bodyMedium
                              ?.copyWith(color: esquema.onSurfaceVariant)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          eurosConSigno(balanceTest),
                          style: estilos.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: balanceTest < 0
                                  ? colores.bloqueada
                                  : colores.hecha),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textos.proyQuienAsume,
                          style: estilos.bodyMedium
                              ?.copyWith(color: esquema.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      if (reparto == null)
                        Text(textos.proySinGastos, style: estilos.bodySmall)
                      else
                        _BarraReparto(
                            tester: reparto.tester, zunbeltz: reparto.zunbeltz),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra partida: lo que asume la persona tester (salvia) y Zunbeltz (pino).
class _BarraReparto extends StatelessWidget {
  const _BarraReparto({required this.tester, required this.zunbeltz});

  final int tester;
  final int zunbeltz;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estilo = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(fontWeight: FontWeight.w600);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      BarraRepartoGastos(tester: tester, zunbeltz: zunbeltz),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(textos.proyParteTester('$tester'), style: estilo),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(textos.proyParteZunbeltz('$zunbeltz'), style: estilo),
          ),
        ),
      ]),
    ]);
  }
}

/// Un proyecto cerrado: en una fila, apagado y con candado.
class _FilaProyectoCerrado extends StatelessWidget {
  const _FilaProyectoCerrado({required this.proyecto, required this.onTap});

  final ProyectoTest proyecto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final cerradoMs = proyecto.cerradoMs ?? proyecto.fechaFinMs;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: esquema.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            _AvatarProyecto(proyecto: proyecto, tamano: 48, apagado: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proyecto.nombre.isEmpty ? '—' : proyecto.nombre,
                      style: estilos.titleMedium),
                  Text(
                    cerradoMs == null || cerradoMs == 0
                        ? textos.proyectoCerradoEtiqueta
                        : textos.proyCerradoEl(DateFormat.yMMMMd(idioma).format(
                            DateTime.fromMillisecondsSinceEpoch(cerradoMs))),
                    style: estilos.bodyMedium
                        ?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.lock_outline, color: esquema.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}
