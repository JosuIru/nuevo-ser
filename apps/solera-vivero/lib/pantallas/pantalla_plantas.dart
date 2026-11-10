import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/stock.dart';
import '../dominio/trazabilidad.dart';
import '../modelos/bandeja.dart';
import '../modelos/inspeccion_plagas.dart';
import '../modelos/lote_material.dart';
import '../modelos/partida_planta.dart';
import '../modelos/repicado.dart';
import '../modelos/salida.dart';
import '../modelos/siembra.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'formularios.dart';
import 'identificar_plaga.dart';
import 'pantalla_salidas.dart';
import 'vista_carga.dart';

class _DatosPlantas {
  _DatosPlantas(this.partidas, this.repicados, this.salidas);
  final List<PartidaPlanta> partidas;
  final List<Repicado> repicados;
  final List<Salida> salidas;
}

Future<_DatosPlantas> _cargarPlantas() async {
  final bd = BaseDatosSoleraVivero.instancia;
  return _DatosPlantas(await bd.listarPartidas(), await bd.listarRepicados(),
      await bd.listarSalidas());
}

/// Pestaña Plantas: stock por especie y formato, y las partidas vivas.
class PantallaPlantas extends StatefulWidget {
  const PantallaPlantas({super.key});

  @override
  State<PantallaPlantas> createState() => _PantallaPlantasState();
}

class _PantallaPlantasState extends State<PantallaPlantas> {
  bool _verAgotadas = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('vive.plantas')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('vive.ver_agotadas'),
            isSelected: _verAgotadas,
            icon: const Icon(Icons.history_outlined),
            onPressed: () => setState(() {
              _verAgotadas = !_verAgotadas;
            }),
          ),
        ],
      ),
      body: VistaCarga<_DatosPlantas>(
        cargar: _cargarPlantas,
        construir: (context, datos) {
          final stock = resumenStock(
              partidas: datos.partidas,
              repicados: datos.repicados,
              salidas: datos.salidas);
          final partidas = [
            for (final partida in datos.partidas)
              (
                partida,
                plantasDisponibles(partida,
                    repicados: datos.repicados, salidas: datos.salidas)
              ),
          ].where((par) => _verAgotadas || par.$2 > 0).toList();
          if (datos.partidas.isEmpty) {
            return ListaVacia(SoleraL10n.t('vive.sin_partidas_ayuda'));
          }
          return ListView(
            children: [
              TituloSeccion(SoleraL10n.t('vive.stock')),
              for (final fila in stock)
                ListTile(
                  dense: true,
                  title: Text(
                      '${nombreEspecieVisible(fila.especieId)}${fila.variedad.isEmpty ? '' : ' · ${fila.variedad}'}'),
                  subtitle: Text(nombreFormato(fila.formato)),
                  trailing: Text(
                      SoleraL10n.tf('vive.stock_fila', {
                        'n': fila.disponibles,
                        'listas': fila.listasParaVenta,
                      }),
                      textAlign: TextAlign.end),
                ),
              TituloSeccion(SoleraL10n.t('vive.partidas')),
              for (final (partida, disponibles) in partidas)
                ListTile(
                  leading: Icon(partida.listaParaVenta
                      ? Icons.local_florist
                      : Icons.spa_outlined),
                  title: Text(etiquetaPartida(partida)),
                  subtitle: Text(
                      '${nombreFormato(partida.formato)} · ${SoleraL10n.tf('vive.disponibles_n', {
                        'n': disponibles
                      })}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => abrirFichaPartida(context, partida.id!),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_nueva_siembra',
        tooltip: SoleraL10n.t('vive.nueva_siembra'),
        onPressed: () => mostrarFormularioSiembra(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> abrirFichaPartida(BuildContext context, int partidaId) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaFichaPartida(partidaId: partidaId)));

class _DatosPartida {
  _DatosPartida({
    required this.partida,
    required this.disponibles,
    required this.cadena,
    required this.salidas,
    required this.tratamientos,
    required this.inspecciones,
  });
  final PartidaPlanta? partida;
  final int disponibles;
  final CadenaTrazabilidad cadena;
  final List<Salida> salidas;
  final List<Tratamiento> tratamientos;
  final List<InspeccionPlagas> inspecciones;
}

/// Ficha de la partida: disponibles, trazabilidad hasta el lote, salidas,
/// tratamientos e inspecciones.
class PantallaFichaPartida extends StatelessWidget {
  const PantallaFichaPartida({super.key, required this.partidaId});
  final int partidaId;

  Future<_DatosPartida> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final partidas = {
      for (final partida in await bd.listarPartidas()) partida.id!: partida
    };
    final repicados = await bd.listarRepicados();
    final salidas = await bd.listarSalidas();
    final partida = partidas[partidaId];
    return _DatosPartida(
      partida: partida,
      disponibles: partida == null
          ? 0
          : plantasDisponibles(partida, repicados: repicados, salidas: salidas),
      cadena: reconstruirTrazabilidad(partidaId,
          partidas: partidas,
          siembras: <int, Siembra>{
            for (final siembra in await bd.listarSiembras())
              siembra.id!: siembra
          },
          bandejas: <int, Bandeja>{
            for (final bandeja in await bd.listarBandejas())
              bandeja.id!: bandeja
          },
          lotes: <int, LoteMaterial>{
            for (final lote in await bd.listarLotesMaterial()) lote.id!: lote
          }),
      salidas:
          salidas.where((salida) => salida.partidaId == partidaId).toList(),
      tratamientos: await bd.listarTratamientos(partidaId: partidaId),
      inspecciones: await bd.listarInspecciones(partidaId: partidaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VistaCarga<_DatosPartida>(
      cargar: _cargar,
      construir: (context, datos) {
        final partida = datos.partida;
        if (partida == null) return const Scaffold();
        return Scaffold(
          appBar: AppBar(
            title: Text(partida.codigo),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => mostrarFormularioPartida(context, partida),
              ),
            ],
          ),
          body: ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
            children: [
              ListTile(
                title: Text(etiquetaPartida(partida)),
                subtitle: Text([
                  if (partida.nombreBotanico.isNotEmpty) partida.nombreBotanico,
                  nombreFormato(partida.formato),
                  SoleraL10n.tf('vive.inicial_mermas', {
                    'inicial': partida.cantidadInicial,
                    'mermas': partida.mermas,
                  }),
                  if (partida.listaParaVenta)
                    SoleraL10n.t('vive.lista_para_venta'),
                ].join(' · ')),
                trailing: Text('${datos.disponibles}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(spacing: 8, runSpacing: 8, children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.remove_circle_outline),
                    label: Text(SoleraL10n.t('vive.apuntar_merma')),
                    onPressed: () => mostrarFormularioMerma(context, partida),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.call_split),
                    label: Text(SoleraL10n.t('vive.repicar')),
                    onPressed: datos.disponibles == 0
                        ? null
                        : () => mostrarFormularioRepicado(context, partida,
                            disponibles: datos.disponibles),
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.local_shipping_outlined),
                    label: Text(SoleraL10n.t('vive.nueva_salida')),
                    onPressed: datos.disponibles == 0
                        ? null
                        : () => mostrarFormularioSalida(context,
                            partida: partida, disponibles: datos.disponibles),
                  ),
                ]),
              ),
              TituloSeccion(SoleraL10n.t('vive.trazabilidad')),
              ..._eslabones(context, datos.cadena),
              TituloSeccion(SoleraL10n.t('vive.salidas')),
              if (datos.salidas.isEmpty)
                ListaVacia(SoleraL10n.t('vive.sin_salidas')),
              for (final salida in datos.salidas)
                ListTile(
                  leading: const Icon(Icons.local_shipping_outlined),
                  title: Text(
                      '${salida.cantidad} · ${salida.clienteNombre.isEmpty ? '—' : salida.clienteNombre}'),
                  subtitle: Text(formatearFecha(salida.fechaMs)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => abrirFichaSalida(context, salida.id!),
                ),
              TituloSeccion(SoleraL10n.t('vive.tratamientos'),
                  accion: IconButton(
                    tooltip: SoleraL10n.t('vive.nuevo_tratamiento'),
                    icon: const Icon(Icons.add),
                    onPressed: () => mostrarFormularioTratamiento(context,
                        partidaId: partida.id),
                  )),
              for (final tratamiento in datos.tratamientos)
                ListTile(
                  dense: true,
                  title: Text(
                      '${nombreSustanciaVisible(tratamiento.sustanciaActivaId)} · ${tratamiento.nombreProducto}'),
                  subtitle: Text(
                      '${formatearFecha(tratamiento.fechaMs)} · ${nombrePlagaVisible(tratamiento.problemaFitosanitario)}'),
                ),
              TituloSeccion(SoleraL10n.t('vive.inspecciones'),
                  accion: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: SoleraL10n.t('vive.identificar_con_ia'),
                      icon: const Icon(Icons.document_scanner_outlined),
                      onPressed: () =>
                          identificarPlagaConFoto(context, partida),
                    ),
                    IconButton(
                      tooltip: SoleraL10n.t('vive.nueva_inspeccion'),
                      icon: const Icon(Icons.add),
                      onPressed: () => mostrarFormularioInspeccion(context,
                          partidaId: partida.id),
                    ),
                  ])),
              for (final inspeccion in datos.inspecciones)
                ListTile(
                  dense: true,
                  leading: Icon(inspeccion.resultado == 'no_detectada'
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_outlined),
                  title: Text(nombrePlagaVisible(inspeccion.plagaId)),
                  subtitle: Text(
                      '${formatearFecha(inspeccion.fechaMs)} · ${nombreResultadoInspeccion(inspeccion.resultado)} · ${nombreTipoInspeccion(inspeccion.tipo)}'),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _eslabones(BuildContext context, CadenaTrazabilidad cadena) => [
        for (final eslabon in cadena.eslabones)
          if (eslabon.partida != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.spa_outlined),
              title: Text(eslabon.partida!.codigo),
              subtitle: Text(
                  '${nombreFormato(eslabon.partida!.formato)} · ${formatearFecha(eslabon.partida!.fechaAltaMs)}'),
            )
          else if (eslabon.siembra != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.grid_on_outlined),
              title: Text(eslabon.bandeja?.codigoQr ?? '—'),
              subtitle: Text(
                  '${nombreMetodoSiembra(eslabon.siembra!.metodo)} · ${formatearFecha(eslabon.siembra!.fechaMs)}'),
            )
          else if (eslabon.lote != null)
            ListTile(
              dense: true,
              leading: const Icon(Icons.grain_outlined),
              title: Text(eslabon.lote!.codigo),
              subtitle: Text([
                nombreTipoMaterial(eslabon.lote!.tipo),
                eslabon.lote!.esPropio
                    ? SoleraL10n.t('vive.propio')
                    : eslabon.lote!.proveedorNombre,
                if (eslabon.lote!.pasaporteRecibido.isNotEmpty)
                  eslabon.lote!.pasaporteRecibido,
              ].where((parte) => parte.isNotEmpty).join(' · ')),
            ),
        if (!cadena.completa)
          ListTile(
            dense: true,
            leading: const Icon(Icons.link_off),
            title: Text(SoleraL10n.t('vive.trazabilidad_incompleta')),
          ),
      ];
}
