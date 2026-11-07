import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/aprovechamientos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/rodal.dart';
import '../modelos/sorteo_lena.dart';
import '../utiles/textos_monte.dart';
import 'formularios.dart';
import 'pantalla_sorteo.dart';

class _DatosAprovechamientos {
  _DatosAprovechamientos(this.aprovechamientos, this.sorteos, this.rodales);

  final List<Aprovechamiento> aprovechamientos;
  final List<SorteoLena> sorteos;
  final List<Rodal> rodales;
}

/// Aprovechamientos de la campaña y sorteos de lotes de leña vecinal.
class PantallaAprovechamientos extends StatefulWidget {
  const PantallaAprovechamientos({super.key});

  @override
  State<PantallaAprovechamientos> createState() =>
      _PantallaAprovechamientosState();
}

class _PantallaAprovechamientosState extends State<PantallaAprovechamientos>
    with SingleTickerProviderStateMixin {
  late final TabController _pestanas = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));
  int _campanya = DateTime.now().year;
  late Future<_DatosAprovechamientos> _datos = _cargar();

  @override
  void initState() {
    super.initState();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    _pestanas.dispose();
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<_DatosAprovechamientos> _cargar() async {
    final bd = BaseDatosSoleraMonte.instancia;
    return _DatosAprovechamientos(
      await bd.listarAprovechamientos(campanya: _campanya),
      await bd.listarSorteos(campanya: _campanya),
      await bd.listarRodales(),
    );
  }

  Future<void> _nuevo() async {
    if (_pestanas.index == 0) {
      await mostrarEdicionAprovechamiento(context, campanya: _campanya);
      return;
    }
    final sorteoId = await mostrarNuevoSorteo(context);
    if (sorteoId == null || !mounted) return;
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => PantallaSorteo(sorteoId: sorteoId)));
  }

  @override
  Widget build(BuildContext context) {
    final anyo = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('mont.aprovechamientos')),
        bottom: TabBar(
          controller: _pestanas,
          tabs: [
            Tab(text: SoleraL10n.t('mont.aprovechamientos')),
            Tab(text: SoleraL10n.t('mont.sorteos_lena')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t(_pestanas.index == 0
            ? 'mont.nuevo_aprovechamiento'
            : 'mont.nuevo_sorteo')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Wrap(
              spacing: 6,
              children: [
                for (final opcion in [anyo - 1, anyo, anyo + 1])
                  ChoiceChip(
                    label: Text('$opcion'),
                    selected: _campanya == opcion,
                    onSelected: (_) => setState(() {
                      _campanya = opcion;
                      _datos = _cargar();
                    }),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<_DatosAprovechamientos>(
              future: _datos,
              builder: (context, instantanea) {
                final datos = instantanea.data;
                if (datos == null) {
                  return Center(
                      child: instantanea.hasError
                          ? Text(SoleraL10n.t('mont.error_cargar'))
                          : const CircularProgressIndicator());
                }
                return TabBarView(
                  controller: _pestanas,
                  children: [_lista(context, datos), _sorteos(context, datos)],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _lista(BuildContext context, _DatosAprovechamientos datos) {
    if (datos.aprovechamientos.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_aprovechamientos'),
                  textAlign: TextAlign.center)));
    }
    final hoy = DateTime.now();
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final aprovechamiento in datos.aprovechamientos)
          () {
            final avisos = avisosAprovechamiento(aprovechamiento, hoy);
            final limite = limiteComunicacionCuantia(aprovechamiento);
            final rodal = datos.rodales
                .where((r) => r.id == aprovechamiento.rodalId)
                .firstOrNull;
            return ListTile(
              isThreeLine: avisos.isNotEmpty,
              leading: Icon(avisos.isEmpty
                  ? Icons.forest_outlined
                  : Icons.warning_amber_outlined),
              title: Text(
                  '${nombreTipoAprovechamiento(aprovechamiento.tipo)} · '
                  '${formatearNumero(aprovechamiento.cantidad)} ${nombreUnidad(aprovechamiento.unidad)}'),
              subtitle: Text([
                [
                  if (rodal != null) rodal.etiqueta,
                  nombreModalidad(aprovechamiento.modalidad),
                  nombreTramite(aprovechamiento.tramite),
                  if (aprovechamiento.adjudicatario.isNotEmpty)
                    aprovechamiento.adjudicatario,
                ].join(' · '),
                for (final aviso in avisos)
                  textoAvisoAprovechamiento(aviso, limite),
              ].join('\n')),
              onTap: () => mostrarEdicionAprovechamiento(context,
                  aprovechamiento: aprovechamiento),
            );
          }(),
      ],
    );
  }

  Widget _sorteos(BuildContext context, _DatosAprovechamientos datos) {
    if (datos.sorteos.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_sorteos'),
                  textAlign: TextAlign.center)));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final sorteo in datos.sorteos)
          ListTile(
            leading: Icon(sorteo.realizado
                ? Icons.verified_outlined
                : Icons.casino_outlined),
            title: Text(sorteo.nombre.isEmpty
                ? SoleraL10n.tf(
                    'mont.sorteo_de', {'anyo': '${sorteo.campanya}'})
                : sorteo.nombre),
            subtitle: Text([
              SoleraL10n.tf('mont.n_participantes',
                  {'n': '${sorteo.participantes.length}'}),
              SoleraL10n.t(sorteo.realizado
                  ? 'mont.sorteo_realizado'
                  : sorteo.fechaCierreListaMs != null
                      ? 'mont.lista_cerrada'
                      : 'mont.lista_abierta'),
            ].join(' · ')),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PantallaSorteo(sorteoId: sorteo.id!))),
          ),
      ],
    );
  }
}
