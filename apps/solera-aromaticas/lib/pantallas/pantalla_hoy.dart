import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show AvisoCatalogosProvisionales;
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n, TituloBloqueSolera;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../dominio/catalogos.dart';
import '../dominio/guia.dart';
import '../dominio/recoleccion.dart';
import '../estado/cambios_datos.dart';
import '../modelos/cosecha.dart';
import '../modelos/parcela.dart';
import '../modelos/zona_recoleccion.dart';
import '../utiles/textos_aromaticas.dart';
import 'formularios.dart';
import 'pantalla_editar_origen.dart';
import 'pantalla_guia.dart';

class _DatosHoy {
  _DatosHoy(this.parcelas, this.zonas, this.cosechasDelAnyo, this.lotes);

  final List<Parcela> parcelas;
  final List<ZonaRecoleccion> zonas;
  final List<Cosecha> cosechasDelAnyo;
  final int lotes;
}

/// Lo del día: permisos que vencen, especies en temporada y, la primera vez,
/// los primeros pasos.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key, this.fechaParaPruebas});

  /// Fija «hoy» en los tests (la temporada depende del mes).
  final DateTime? fechaParaPruebas;

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  late Future<_DatosHoy> _datos = _cargar();

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

  Future<_DatosHoy> _cargar() async {
    final bd = BaseDatosSoleraAromaticas.instancia;
    final (desde, hasta) = intervaloAnyo(DateTime.now().year);
    return _DatosHoy(
      await bd.listarParcelas(),
      await bd.listarZonasRecoleccion(),
      await bd.listarCosechas(desdeMs: desde, hastaMs: hasta),
      (await bd.listarLotesProducto()).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarAltaCosecha(context),
        icon: const Icon(Icons.agriculture_outlined),
        label: Text(SoleraL10n.t('arom.nueva_cosecha')),
      ),
      body: FutureBuilder<_DatosHoy>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          final kgDelAnyo = datos?.cosechasDelAnyo.fold<double>(
                  0, (suma, cosecha) => suma + cosecha.kgFrescos) ??
              0;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              CabeceraHoySolera(
                titulo: 'Larrea Aromáticas',
                rutaLogo: rutaLogoAromaticas,
                fecha: DateFormat.MMMMEEEEd(SoleraL10n.idioma)
                    .format(DateTime.now()),
                cifras: [
                  CifraCabecera(
                      valor:
                          '${(datos?.parcelas.length ?? 0) + (datos?.zonas.length ?? 0)}',
                      etiqueta: SoleraL10n.t('arom.origenes')),
                  CifraCabecera(
                      valor: formatearNumero(kgDelAnyo, decimales: 0),
                      etiqueta: SoleraL10n.t('arom.kg_cosechados_anyo')),
                  CifraCabecera(
                      valor: '${datos?.lotes ?? 0}',
                      etiqueta: SoleraL10n.t('arom.lotes')),
                ],
              ),
              if (!catalogosCompletamenteRevisados)
                AvisoCatalogosProvisionales(
                    texto: SoleraL10n.t('arom.catalogos_provisionales')),
              if (instantanea.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('arom.error_cargar')),
                ),
              if (datos != null) ..._bloques(context, datos),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _bloques(BuildContext context, _DatosHoy datos) {
    if (datos.parcelas.isEmpty && datos.zonas.isEmpty) {
      return [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SoleraL10n.t('arom.primeros_pasos'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(SoleraL10n.t('arom.primeros_pasos_texto')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => abrirEdicionParcela(context),
                      icon: const Icon(Icons.grass_outlined),
                      label: Text(SoleraL10n.t('arom.nueva_parcela')),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => abrirEdicionZona(context),
                      icon: const Icon(Icons.forest_outlined),
                      label: Text(SoleraL10n.t('arom.nueva_zona')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ];
    }
    final hoy = widget.fechaParaPruebas ?? DateTime.now();
    final porVencer = permisosPorVencer(datos.zonas, hoy);
    final sinPermiso = datos.zonas.where((zona) => !zona.tienePermiso).toList();
    final enEpoca = especiesEnEpoca([
      for (final parcela in datos.parcelas) parcela.especieId,
      for (final zona in datos.zonas) ...zona.especiesPermitidas,
    ], hoy.month);
    return [
      if (porVencer.isNotEmpty || sinPermiso.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TituloBloqueSolera(SoleraL10n.t('arom.permisos')),
        ),
        for (final zona in porVencer)
          ListTile(
            leading: Icon(Icons.event_busy_outlined,
                color: Theme.of(context).colorScheme.error),
            title: Text(zona.nombre),
            subtitle: Text(SoleraL10n.tf(
                zona.diasHastaFinVigencia(hoy)! < 0
                    ? 'arom.permiso_caducado_el'
                    : 'arom.permiso_vence_el',
                {'fecha': formatearFecha(zona.finVigenciaMs!)})),
            onTap: () => abrirEdicionZona(context, zona: zona),
          ),
        for (final zona in sinPermiso)
          ListTile(
            leading: Icon(Icons.report_gmailerrorred_outlined,
                color: Theme.of(context).colorScheme.error),
            title: Text(zona.nombre),
            subtitle: Text(SoleraL10n.t('arom.sin_permiso_apuntado')),
            onTap: () => abrirEdicionZona(context, zona: zona),
          ),
      ],
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('arom.en_temporada')),
      ),
      if (enEpoca.isEmpty)
        ListTile(title: Text(SoleraL10n.t('arom.nada_en_temporada')))
      else
        for (final (indice, especie) in enEpoca.indexed)
          ListTile(
            dense: true,
            leading: const Icon(Icons.local_florist_outlined),
            title: Text(especie.nombre),
            subtitle: Text(especie.parteUsada),
            trailing: const Icon(Icons.menu_book_outlined, size: 20),
            onTap: () => abrirFichaGuia(context,
                lista: [
                  for (final enTemporada in enEpoca) entradaGuiaDe(enTemporada)
                ],
                indiceInicial: indice),
          ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(SoleraL10n.t('arom.epoca_orientativa'),
            style: Theme.of(context).textTheme.bodySmall),
      ),
    ];
  }
}
