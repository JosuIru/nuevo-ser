import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../estado/datos_notificador.dart';
import '../l10n/app_localizations.dart';
import '../modelos/finca.dart';
import '../modelos/indicadores_seguimiento.dart';
import '../modelos/proyecto_test.dart';
import '../modelos/rentabilidad_proyecto.dart';
import '../servicios/generador_comparativa_proyectos.dart';
import 'nuevo_proyecto.dart';
import 'proyecto_detalle.dart';

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
    try {
      proyectos = await _bd.listarProyectos();
      fincas = await _bd.listarFincas();
      for (final p in proyectos) {
        if (p.id != null) rent[p.id!] = await _bd.rentabilidadProyecto(p.id!);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _proyectos = proyectos;
      _fincas = fincas;
      _rentabilidad = rent;
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
    final cambiado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProyectoDetalle(proyecto: p)),
    );
    if (cambiado == true) await _cargar();
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
              rentabilidad:
                  _rentabilidad[p.id!] ?? const RentabilidadProyecto()
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
                : const Icon(Icons.bar_chart_outlined),
            onPressed:
                (_generando || _proyectos.isEmpty) ? null : _comparativa,
          ),
        ],
      ),
      floatingActionButton: politicaEspacioActual.puedeGestionarProyectos
          ? FloatingActionButton(
              onPressed: _nuevo,
              child: const Icon(Icons.add),
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
              : ListView(
                  children: [
                    for (final p in _proyectos)
                      _TarjetaProyecto(
                        proyecto: p,
                        rentabilidad: p.id == null ? null : _rentabilidad[p.id!],
                        onTap: () => _abrir(p),
                      ),
                  ],
                ),
    );
  }
}

class _TarjetaProyecto extends StatelessWidget {
  const _TarjetaProyecto({
    required this.proyecto,
    required this.rentabilidad,
    required this.onTap,
  });

  final ProyectoTest proyecto;
  final RentabilidadProyecto? rentabilidad;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subt = [proyecto.persona, proyecto.actividad]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    final r = rentabilidad;
    final positivo = (r?.balanceCentimos ?? 0) >= 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.science_outlined)),
        title: Text(proyecto.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text([
          if (subt.isNotEmpty) subt,
          if (proyecto.cerrado) AppLocalizations.of(context).proyectoCerradoEtiqueta,
        ].join(' · ')),
        trailing: r == null
            ? const Icon(Icons.chevron_right)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${eurosDesdeCentimos(r.balanceCentimos)} €',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: positivo
                              ? colorEstadoHecha
                              : colorEstadoBloqueada)),
                  Text('${r.margenPorcentaje.toStringAsFixed(0)} %',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}
