import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/abonado.dart';
import '../modelos/helada.dart';
import '../modelos/parcela.dart';
import '../modelos/riego.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_frutal.dart';
import 'formularios_registros.dart';

class _DatosCuaderno {
  _DatosCuaderno(this.parcelas, this.tratamientos, this.abonados, this.riegos,
      this.heladas);

  final Map<int, Parcela> parcelas;
  final List<Tratamiento> tratamientos;
  final List<Abonado> abonados;
  final List<Riego> riegos;
  final List<Helada> heladas;
}

/// Registros del cuaderno de explotación de un año: tratamientos,
/// abonados, riegos y heladas.
class PantallaCuaderno extends StatefulWidget {
  const PantallaCuaderno({super.key});

  @override
  State<PantallaCuaderno> createState() => _PantallaCuadernoState();
}

class _PantallaCuadernoState extends State<PantallaCuaderno>
    with SingleTickerProviderStateMixin {
  late final TabController _pestanas = TabController(length: 4, vsync: this);
  int _anyo = DateTime.now().year;
  late Future<_DatosCuaderno> _datos;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
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

  Future<_DatosCuaderno> _cargar() async {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosCuaderno(
      {
        for (final parcela in await baseDatos.listarParcelas())
          parcela.id!: parcela
      },
      await baseDatos.listarTratamientos(desdeMs: desde, hastaMs: hasta),
      await baseDatos.listarAbonados(desdeMs: desde, hastaMs: hasta),
      await baseDatos.listarRiegos(desdeMs: desde, hastaMs: hasta),
      await baseDatos.listarHeladas(desdeMs: desde, hastaMs: hasta),
    );
  }

  void _cambiarAnyo(int desplazamiento) {
    setState(() {
      _anyo += desplazamiento;
      _datos = _cargar();
    });
  }

  Future<void> _anadir() async {
    switch (_pestanas.index) {
      case 0:
        await mostrarAltaTratamiento(context);
      case 1:
        await mostrarAltaAbonado(context);
      case 2:
        await mostrarAltaRiego(context);
      default:
        await mostrarAltaHelada(context);
    }
  }

  Future<void> _borrar(
      String descripcion, Future<void> Function() borrar) async {
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('borrar'),
        mensaje: descripcion,
        esPeligroso: true);
    if (!confirmado) return;
    await borrar();
    avisarCambioDatos();
  }

  Widget _lista(List<Widget> filas) => filas.isEmpty
      ? Center(child: Text(SoleraL10n.t('frut.sin_registros')))
      : ListView(padding: const EdgeInsets.only(bottom: 88), children: filas);

  @override
  Widget build(BuildContext context) {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('frut.cuaderno')),
        actions: [
          IconButton(
              onPressed: () => _cambiarAnyo(-1),
              icon: const Icon(Icons.chevron_left)),
          Center(child: Text('$_anyo')),
          IconButton(
              onPressed: () => _cambiarAnyo(1),
              icon: const Icon(Icons.chevron_right)),
        ],
        bottom: TabBar(
          controller: _pestanas,
          isScrollable: true,
          tabs: [
            Tab(text: SoleraL10n.t('frut.tratamientos')),
            Tab(text: SoleraL10n.t('frut.abonados')),
            Tab(text: SoleraL10n.t('frut.riegos')),
            Tab(text: SoleraL10n.t('frut.heladas')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('frut.anadir'),
        onPressed: _anadir,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<_DatosCuaderno>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          String nombreParcela(int? id) => id == null
              ? SoleraL10n.t('frut.toda_explotacion')
              : datos.parcelas[id]?.nombre ?? '#$id';
          return TabBarView(
            controller: _pestanas,
            children: [
              _lista([
                for (final tratamiento in datos.tratamientos)
                  ListTile(
                    leading: const Icon(Icons.science_outlined),
                    title: Text(tratamiento.sustanciaActivaId),
                    subtitle: Text([
                      formatearFecha(tratamiento.fechaMs),
                      nombreParcela(tratamiento.parcelaId),
                      if (tratamiento.problemaFitosanitario.isNotEmpty)
                        tratamiento.problemaFitosanitario,
                      if (tratamiento.nombreProducto.isNotEmpty)
                        tratamiento.nombreProducto,
                    ].join(' · ')),
                    onLongPress: () => _borrar(tratamiento.sustanciaActivaId,
                        () => baseDatos.borrarTratamiento(tratamiento.id!)),
                  ),
              ]),
              _lista([
                for (final abonado in datos.abonados)
                  ListTile(
                    leading: const Icon(Icons.grass_outlined),
                    title: Text(abonado.tipoAbono),
                    subtitle: Text([
                      formatearFecha(abonado.fechaMs),
                      nombreParcela(abonado.parcelaId),
                      nombreMetodoAbonado(abonado.metodo),
                      if (abonado.cantidadKgPorHa > 0)
                        '${formatearNumero(abonado.cantidadKgPorHa, decimales: 0)} kg/ha',
                    ].join(' · ')),
                    onLongPress: () => _borrar(abonado.tipoAbono,
                        () => baseDatos.borrarAbonado(abonado.id!)),
                  ),
              ]),
              _lista([
                for (final riego in datos.riegos)
                  ListTile(
                    leading: const Icon(Icons.water_drop_outlined),
                    title: Text('${formatearNumero(riego.volumenM3)} m³'),
                    subtitle: Text([
                      formatearFecha(riego.fechaMs),
                      nombreParcela(riego.parcelaId),
                      if (riego.origenAgua.isNotEmpty) riego.origenAgua,
                    ].join(' · ')),
                    onLongPress: () => _borrar(formatearFecha(riego.fechaMs),
                        () => baseDatos.borrarRiego(riego.id!)),
                  ),
              ]),
              _lista([
                for (final helada in datos.heladas)
                  ListTile(
                    leading: Icon(helada.esPedrisco
                        ? Icons.grain_outlined
                        : Icons.ac_unit_outlined),
                    title: Text([
                      formatearFecha(helada.fechaMs),
                      if (helada.temperaturaMinimaC != null)
                        '${formatearNumero(helada.temperaturaMinimaC!)} °C',
                    ].join(' · ')),
                    subtitle: Text([
                      nombreParcela(helada.parcelaId),
                      if (helada.danioEstimadoPorcentaje != null)
                        '${formatearNumero(helada.danioEstimadoPorcentaje!, decimales: 0)} %',
                      SoleraL10n.t(helada.comunicadaAlSeguro
                          ? 'frut.comunicada_seguro'
                          : 'frut.sin_comunicar_seguro'),
                    ].join(' · ')),
                    onLongPress: () => _borrar(formatearFecha(helada.fechaMs),
                        () => baseDatos.borrarHelada(helada.id!)),
                  ),
              ]),
            ],
          );
        },
      ),
    );
  }
}
