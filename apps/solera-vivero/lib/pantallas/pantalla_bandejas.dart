import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/stock.dart';
import '../modelos/bandeja.dart';
import '../modelos/lote_material.dart';
import '../modelos/partida_planta.dart';
import '../modelos/repicado.dart';
import '../modelos/salida.dart';
import '../modelos/siembra.dart';
import '../modelos/zona_cultivo.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'formularios.dart';
import 'pantalla_plantas.dart';
import 'vista_carga.dart';

/// Pestaña Bandejas: bandejas y contenedores con su QR, y las zonas.
class PantallaBandejas extends StatelessWidget {
  const PantallaBandejas({super.key, this.accionesExtra = const []});

  /// Botones de la barra (escáner y etiquetas QR, bloque 8).
  final List<Widget> accionesExtra;

  Future<(List<Bandeja>, Map<int, ZonaCultivo>)> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final zonas = {for (final zona in await bd.listarZonas()) zona.id!: zona};
    return (await bd.listarBandejas(), zonas);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('vive.bandejas')),
        actions: [
          ...accionesExtra,
          IconButton(
            tooltip: SoleraL10n.t('vive.zonas'),
            icon: const Icon(Icons.warehouse_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaZonas())),
          ),
        ],
      ),
      body: VistaCarga<(List<Bandeja>, Map<int, ZonaCultivo>)>(
        cargar: _cargar,
        construir: (context, datos) {
          final (bandejas, zonas) = datos;
          if (bandejas.isEmpty) {
            return ListaVacia(SoleraL10n.t('vive.sin_bandejas'));
          }
          return ListView(
            children: [
              for (final bandeja in bandejas)
                ListTile(
                  leading: Icon(Icons.grid_on_outlined,
                      color: bandeja.activa
                          ? null
                          : Theme.of(context).disabledColor),
                  title: Text(bandeja.codigoQr),
                  subtitle: Text([
                    nombreFormato(bandeja.formato),
                    if (bandeja.numeroAlveolos > 0)
                      SoleraL10n.tf(
                          'vive.alveolos_n', {'n': bandeja.numeroAlveolos}),
                    if (bandeja.zonaId != null)
                      zonas[bandeja.zonaId]?.nombre ?? '',
                    if (bandeja.ubicacion.isNotEmpty) bandeja.ubicacion,
                    if (!bandeja.activa) SoleraL10n.t('vive.retirada'),
                  ].where((parte) => parte.isNotEmpty).join(' · ')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => abrirFichaBandeja(context, bandeja.id!),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_nueva_bandeja',
        tooltip: SoleraL10n.t('vive.nueva_bandeja'),
        onPressed: () => mostrarFormularioBandeja(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<void> abrirFichaBandeja(BuildContext context, int bandejaId) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaFichaBandeja(bandejaId: bandejaId)));

class _DatosBandeja {
  _DatosBandeja(this.bandeja, this.zona, this.siembras, this.lotes,
      this.partidas, this.repicados, this.salidas);
  final Bandeja? bandeja;
  final ZonaCultivo? zona;
  final List<Siembra> siembras;
  final Map<int, LoteMaterial> lotes;
  final List<PartidaPlanta> partidas;
  final List<Repicado> repicados;
  final List<Salida> salidas;
}

/// Ficha de la bandeja: lo sembrado en ella y las partidas que contiene.
/// Es lo que se abre al escanear su QR.
class PantallaFichaBandeja extends StatelessWidget {
  const PantallaFichaBandeja({super.key, required this.bandejaId});
  final int bandejaId;

  Future<_DatosBandeja> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final bandeja = await bd.obtenerBandeja(bandejaId);
    final zonas = await bd.listarZonas();
    return _DatosBandeja(
      bandeja,
      zonas.where((zona) => zona.id == bandeja?.zonaId).firstOrNull,
      await bd.listarSiembras(bandejaId: bandejaId),
      {for (final lote in await bd.listarLotesMaterial()) lote.id!: lote},
      await bd.listarPartidas(bandejaId: bandejaId),
      await bd.listarRepicados(),
      await bd.listarSalidas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VistaCarga<_DatosBandeja>(
      cargar: _cargar,
      construir: (context, datos) {
        final bandeja = datos.bandeja;
        if (bandeja == null) {
          return Scaffold(
              appBar: AppBar(),
              body: ListaVacia(SoleraL10n.t('vive.bandeja_no_encontrada')));
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(bandeja.codigoQr),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    mostrarFormularioBandeja(context, existente: bandeja),
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                title: Text(nombreFormato(bandeja.formato)),
                subtitle: Text([
                  if (bandeja.numeroAlveolos > 0)
                    SoleraL10n.tf(
                        'vive.alveolos_n', {'n': bandeja.numeroAlveolos}),
                  datos.zona?.nombre ?? SoleraL10n.t('vive.sin_zona'),
                  if (bandeja.ubicacion.isNotEmpty) bandeja.ubicacion,
                  if (!bandeja.activa) SoleraL10n.t('vive.retirada'),
                ].join(' · ')),
              ),
              TituloSeccion(SoleraL10n.t('vive.partidas_en_bandeja')),
              if (datos.partidas.isEmpty)
                ListaVacia(SoleraL10n.t('vive.sin_partidas')),
              for (final partida in datos.partidas)
                ListTile(
                  leading: const Icon(Icons.spa_outlined),
                  title: Text(etiquetaPartida(partida)),
                  subtitle: Text(SoleraL10n.tf('vive.disponibles_n', {
                    'n': plantasDisponibles(partida,
                        repicados: datos.repicados, salidas: datos.salidas)
                  })),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => abrirFichaPartida(context, partida.id!),
                ),
              TituloSeccion(SoleraL10n.t('vive.siembras'),
                  accion: bandeja.activa
                      ? TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(SoleraL10n.t('vive.sembrar')),
                          onPressed: () => mostrarFormularioSiembra(context,
                              bandejaId: bandeja.id),
                        )
                      : null),
              if (datos.siembras.isEmpty)
                ListaVacia(SoleraL10n.t('vive.sin_siembras')),
              for (final siembra in datos.siembras)
                ListTile(
                  leading: const Icon(Icons.grain_outlined),
                  title: Text(
                      '${datos.lotes[siembra.loteMaterialId]?.codigo ?? '—'} · '
                      '${nombreEspecieVisible(datos.lotes[siembra.loteMaterialId]?.especieId ?? '')}'),
                  subtitle: Text(
                      '${nombreMetodoSiembra(siembra.metodo)} · ${formatearFecha(siembra.fechaMs)} · '
                      '${SoleraL10n.tf('vive.alveolos_n', {
                        'n': siembra.alveolosOcupados
                      })}'),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Zonas del vivero: naves, invernaderos, umbráculos y parcelas exteriores.
class PantallaZonas extends StatelessWidget {
  const PantallaZonas({super.key, this.accionesExtra = const []});

  /// Mapa de las parcelas exteriores (bloque 8).
  final List<Widget> accionesExtra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(SoleraL10n.t('vive.zonas')), actions: accionesExtra),
      body: VistaCarga<List<ZonaCultivo>>(
        cargar: BaseDatosSoleraVivero.instancia.listarZonas,
        construir: (context, zonas) => zonas.isEmpty
            ? ListaVacia(SoleraL10n.t('vive.sin_zonas'))
            : ListView(
                children: [
                  for (final zona in zonas)
                    ListTile(
                      leading: Icon(zona.esExterior
                          ? Icons.landscape_outlined
                          : Icons.warehouse_outlined),
                      title: Text(zona.nombre),
                      subtitle: Text([
                        nombreTipoZona(zona.tipo),
                        if (zona.superficieM2 != null)
                          '${formatearNumero(zona.superficieM2!, decimales: 0)} m²',
                        if (zona.tieneUbicacion) SoleraL10n.t('vive.con_gps'),
                      ].join(' · ')),
                      onTap: () =>
                          mostrarFormularioZona(context, existente: zona),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_nueva_zona',
        tooltip: SoleraL10n.t('vive.nueva_zona'),
        onPressed: () => mostrarFormularioZona(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
