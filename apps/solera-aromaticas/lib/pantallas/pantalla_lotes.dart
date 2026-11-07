import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/trazabilidad.dart';
import '../estado/cambios_datos.dart';
import '../modelos/lote_producto.dart';
import '../utiles/textos_aromaticas.dart';
import 'formularios.dart';

/// Lotes de producto (planta seca, aceite esencial, hidrolato), del más
/// reciente.
class PantallaLotes extends StatefulWidget {
  const PantallaLotes({super.key});

  @override
  State<PantallaLotes> createState() => _PantallaLotesState();
}

class _PantallaLotesState extends State<PantallaLotes> {
  late Future<List<LoteProducto>> _lotes =
      BaseDatosSoleraAromaticas.instancia.listarLotesProducto();

  @override
  void initState() {
    super.initState();
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
      _lotes = BaseDatosSoleraAromaticas.instancia.listarLotesProducto();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('arom.lotes'))),
      body: FutureBuilder<List<LoteProducto>>(
        future: _lotes,
        builder: (context, instantanea) {
          final lotes = instantanea.data;
          if (instantanea.hasError) {
            return Center(child: Text(SoleraL10n.t('arom.error_cargar')));
          }
          if (lotes == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (lotes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('arom.sin_lotes'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            children: [
              for (final lote in lotes)
                ListTile(
                  leading: Icon(_iconoLote(lote.tipo)),
                  title:
                      Text('${lote.codigo} · ${nombreEspecie(lote.especieId)}'),
                  subtitle: Text([
                    nombreTipoLote(lote.tipo),
                    '${formatearNumero(lote.disponible)} / ${formatearNumero(lote.cantidad)} ${lote.unidad}',
                    nombreDestinoLote(lote.destino),
                  ].join(' · ')),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PantallaFichaLote(loteId: lote.id!))),
                ),
            ],
          );
        },
      ),
    );
  }
}

IconData _iconoLote(String tipo) => switch (tipo) {
      'aceite_esencial' => Icons.opacity,
      'hidrolato' => Icons.water_drop_outlined,
      _ => Icons.inventory_2_outlined,
    };

/// Ficha de un lote con su trazabilidad hacia atrás.
class PantallaFichaLote extends StatefulWidget {
  const PantallaFichaLote({super.key, required this.loteId});

  final int loteId;

  @override
  State<PantallaFichaLote> createState() => _PantallaFichaLoteState();
}

class _PantallaFichaLoteState extends State<PantallaFichaLote> {
  late Future<(LoteProducto?, OrigenLote?)> _datos = _cargar();

  @override
  void initState() {
    super.initState();
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

  Future<(LoteProducto?, OrigenLote?)> _cargar() async {
    final bd = BaseDatosSoleraAromaticas.instancia;
    final lote = (await bd.listarLotesProducto())
        .where((candidato) => candidato.id == widget.loteId)
        .firstOrNull;
    if (lote == null) return (null, null);
    return (
      lote,
      origenDeLote(
        lote,
        secados: await bd.listarSecados(),
        destilaciones: await bd.listarDestilaciones(),
        cosechas: await bd.listarCosechas(),
        parcelas: await bd.listarParcelas(),
        zonas: await bd.listarZonasRecoleccion(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(LoteProducto?, OrigenLote?)>(
      future: _datos,
      builder: (context, instantanea) {
        final (lote, origen) = instantanea.data ?? (null, null);
        return Scaffold(
          appBar: AppBar(
            title: Text(lote?.codigo ?? ''),
            actions: [
              if (lote != null)
                IconButton(
                  tooltip: SoleraL10n.t('editar'),
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => mostrarEdicionLote(context, lote),
                ),
              if (lote != null)
                IconButton(
                  tooltip: SoleraL10n.t('borrar'),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await confirmarYBorrar(
                        context,
                        () => BaseDatosSoleraAromaticas.instancia
                            .borrarLoteProducto(lote.id!));
                    if (context.mounted) Navigator.maybePop(context);
                  },
                ),
            ],
          ),
          body: lote == null || origen == null
              ? const Center(child: CircularProgressIndicator())
              : _cuerpo(context, lote, origen),
        );
      },
    );
  }

  Widget _cuerpo(BuildContext context, LoteProducto lote, OrigenLote origen) {
    final especie = especiePorId(lote.especieId);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ListTile(
          leading: Icon(_iconoLote(lote.tipo)),
          title: Text(
              '${nombreTipoLote(lote.tipo)} · ${nombreEspecie(lote.especieId)}'),
          subtitle: Text([
            if (especie != null) especie.nombreCientifico,
            formatearFecha(lote.fechaMs),
          ].join(' · ')),
        ),
        ListTile(
          title: Text(SoleraL10n.t('arom.cantidad')),
          trailing: Text(
              '${formatearNumero(lote.disponible)} / ${formatearNumero(lote.cantidad)} ${lote.unidad}'),
        ),
        ListTile(
          title: Text(SoleraL10n.t('arom.destino')),
          subtitle: Text(SoleraL10n.t('arom.destino_por_verificar')),
          trailing: Text(nombreDestinoLote(lote.destino)),
        ),
        if (lote.envase.isNotEmpty)
          ListTile(
              title: Text(SoleraL10n.t('arom.envase')),
              trailing: Text(lote.envase)),
        TituloBloqueSolera(SoleraL10n.t('arom.trazabilidad')),
        if (!origen.tieneProceso)
          ListTile(title: Text(SoleraL10n.t('arom.lote_sin_origen'))),
        if (origen.destilacion != null)
          ListTile(
            leading: const Icon(Icons.water_drop_outlined),
            title: Text(SoleraL10n.tf('arom.destilado_el',
                {'fecha': formatearFecha(origen.destilacion!.fechaMs)})),
            subtitle: Text(
                '${formatearNumero(origen.destilacion!.kgPlanta)} kg · ${nombreTipoAlambique(origen.destilacion!.tipoAlambique)}'),
          ),
        if (origen.secado != null)
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: Text(SoleraL10n.tf('arom.secado_el',
                {'fecha': formatearFecha(origen.secado!.fechaInicioMs)})),
            subtitle: Text(
                '${formatearNumero(origen.secado!.kgFrescos)} → ${formatearNumero(origen.secado!.kgSecos)} kg · ${nombreMetodoSecado(origen.secado!.metodo)}'),
          ),
        for (final parcela in origen.parcelas)
          ListTile(
            leading: const Icon(Icons.grass_outlined),
            title: Text(parcela.nombre),
            subtitle: Text(SoleraL10n.t('arom.cultivo')),
          ),
        for (final zona in origen.zonas)
          ListTile(
            leading: const Icon(Icons.forest_outlined),
            title: Text(zona.nombre),
            subtitle: Text(zona.tienePermiso
                ? SoleraL10n.tf(
                    'arom.permiso_n', {'numero': zona.numeroPermiso})
                : SoleraL10n.t('arom.sin_permiso_apuntado')),
          ),
        for (final cosecha in origen.cosechas)
          ListTile(
            dense: true,
            leading: const Icon(Icons.agriculture_outlined),
            title: Text(
                '${formatearFecha(cosecha.fechaMs)} · ${formatearNumero(cosecha.kgFrescos)} kg'),
            subtitle: Text([
              if (cosecha.estadoFenologico.isNotEmpty)
                nombreEstadoFenologico(cosecha.estadoFenologico),
              cosecha.recolector,
            ].where((texto) => texto.isNotEmpty).join(' · ')),
          ),
      ],
    );
  }
}
