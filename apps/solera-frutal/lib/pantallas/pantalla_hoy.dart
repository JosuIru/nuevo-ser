import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../estado/cambios_datos.dart';
import '../modelos/contrato_polinizacion.dart';
import '../modelos/parcela.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_frutal.dart';
import 'formularios_registros.dart';
import 'pantalla_parcelas.dart';

class _DatosHoy {
  _DatosHoy(this.parcelas, this.tratamientosDelAnyo, this.plazosAbiertos,
      this.colmenasPuestas);

  final Map<int, Parcela> parcelas;
  final int tratamientosDelAnyo;
  final List<Tratamiento> plazosAbiertos;
  final List<ContratoPolinizacion> colmenasPuestas;
}

/// Lo del día: plazos de seguridad abiertos, colmenas en las parcelas y,
/// la primera vez, los primeros pasos.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  late Future<_DatosHoy> _datos;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<_DatosHoy> _cargar() async {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    final ahora = DateTime.now();
    final (desde, hasta) = intervaloAnyo(ahora.year);
    final tratamientos =
        await baseDatos.listarTratamientos(desdeMs: desde, hastaMs: hasta);
    final contratos =
        await baseDatos.listarContratosPolinizacion(campania: ahora.year);
    return _DatosHoy(
      {
        for (final parcela in await baseDatos.listarParcelas())
          parcela.id!: parcela
      },
      tratamientos.length,
      tratamientos
          .where((tratamiento) =>
              tratamiento.finPlazoSeguridad?.isAfter(ahora) ?? false)
          .toList(),
      contratos
          .where((contrato) =>
              contrato.estaEnParcela(ahora.millisecondsSinceEpoch))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarAltaTratamiento(context),
        icon: const Icon(Icons.science_outlined),
        label: Text(SoleraL10n.t('frut.nuevo_tratamiento')),
      ),
      body: FutureBuilder<_DatosHoy>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          final hectareas = datos?.parcelas.values.fold<double>(
                  0, (suma, parcela) => suma + parcela.superficieHa) ??
              0;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              CabeceraHoySolera(
                titulo: 'Larrea Frutal',
                fecha: DateFormat.MMMMEEEEd(SoleraL10n.idioma)
                    .format(DateTime.now()),
                acciones: [
                  IconButton(
                    tooltip: SoleraL10n.t('frut.nueva_helada'),
                    icon: const Icon(Icons.ac_unit_outlined),
                    onPressed: () => mostrarAltaHelada(context),
                  ),
                ],
                cifras: [
                  CifraCabecera(
                      valor: '${datos?.parcelas.length ?? 0}',
                      etiqueta: SoleraL10n.t('frut.parcelas')),
                  CifraCabecera(
                      valor: formatearNumero(hectareas, decimales: 1),
                      etiqueta: 'ha'),
                  CifraCabecera(
                      valor: '${datos?.tratamientosDelAnyo ?? 0}',
                      etiqueta: SoleraL10n.t('frut.tratamientos_del_anyo')),
                ],
              ),
              if (!catalogosCompletamenteRevisados)
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(SoleraL10n.t('frut.catalogos_provisionales')),
                  ),
                ),
              if (instantanea.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('frut.error_cargar')),
                ),
              if (datos != null) ..._bloques(context, datos),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _bloques(BuildContext context, _DatosHoy datos) {
    if (datos.parcelas.isEmpty) {
      return [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SoleraL10n.t('frut.primeros_pasos'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(SoleraL10n.t('frut.primeros_pasos_texto')),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    final guardado = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PantallaEditarParcela()));
                    if (guardado == true) avisarCambioDatos();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(SoleraL10n.t('frut.nueva_parcela')),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    String nombreParcela(int id) => datos.parcelas[id]?.nombre ?? '#$id';
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('frut.plazos_abiertos')),
      ),
      if (datos.plazosAbiertos.isEmpty)
        ListTile(title: Text(SoleraL10n.t('frut.sin_plazos_abiertos')))
      else
        for (final tratamiento in datos.plazosAbiertos)
          ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(
                '${nombreParcela(tratamiento.parcelaId)} · ${tratamiento.sustanciaActivaId}'),
            subtitle: Text(SoleraL10n.tf('frut.no_cosechar_hasta', {
              'fecha': formatearFecha(
                  tratamiento.finPlazoSeguridad!.millisecondsSinceEpoch)
            })),
          ),
      if (datos.colmenasPuestas.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TituloBloqueSolera(SoleraL10n.t('frut.colmenas_en_parcela')),
        ),
        for (final contrato in datos.colmenasPuestas)
          ListTile(
            leading: const Icon(Icons.hive_outlined),
            title: Text(nombreParcela(contrato.parcelaId)),
            subtitle: Text(
                '${contrato.apicultorNombre} · ${SoleraL10n.tf('frut.n_colmenas', {
                  'n': contrato.numeroColmenas
                })}'),
          ),
      ],
    ];
  }
}
