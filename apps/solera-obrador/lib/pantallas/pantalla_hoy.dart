import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show AvisoCatalogosProvisionales;
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show AvisoActualizaciones, configActualizacionesMonorepo;
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n, TituloBloqueSolera;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../estado/cambios_datos.dart';
import '../modelos/masa_madre.dart';
import '../modelos/pedido_fijo.dart';
import '../modelos/receta.dart';
import '../modelos/registro_autocontrol.dart';
import '../utiles/textos_obrador.dart';
import 'pantalla_autocontrol.dart';
import 'pantalla_hornadas.dart';
import 'pantalla_ingredientes.dart';
import 'pantalla_recetas.dart';
import 'pantalla_masa_madre.dart';
import 'pantalla_pedidos_fijos.dart';

/// Lo del día: qué hornear (pedidos fijos), controles apuntados y la masa
/// madre.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _DatosHoy {
  _DatosHoy(this.piezasPorReceta, this.recetas, this.controles,
      this.ultimoRefresco, this.hayIngredientes);

  final Map<int, int> piezasPorReceta;
  final Map<int, Receta> recetas;
  final List<RegistroAutocontrol> controles;
  final (MasaMadre, RefrescoMasaMadre?)? ultimoRefresco;
  final bool hayIngredientes;
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

  void _recargar() => setState(() {
        _datos = _cargar();
      });

  Future<_DatosHoy> _cargar() async {
    final baseDatos = BaseDatosSoleraObrador.instancia;
    final ahora = DateTime.now();
    final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
    final finDia = inicioDia.add(const Duration(days: 1));
    final recetas = {
      for (final receta in await baseDatos.listarRecetas()) receta.id!: receta
    };
    final piezas =
        piezasPedidasPara(ahora, await baseDatos.listarPedidosFijos());
    final controles = await baseDatos.listarRegistrosAutocontrol(
        desdeMs: inicioDia.millisecondsSinceEpoch,
        hastaMs: finDia.millisecondsSinceEpoch - 1);
    final masas = await baseDatos.listarMasasMadre();
    (MasaMadre, RefrescoMasaMadre?)? ultimo;
    if (masas.isNotEmpty) {
      final refrescos = await baseDatos.listarRefrescos(masas.first.id!);
      ultimo = (masas.first, refrescos.isEmpty ? null : refrescos.first);
    }
    final hayIngredientes = (await baseDatos.listarIngredientes()).isNotEmpty;
    return _DatosHoy(piezas, recetas, controles, ultimo, hayIngredientes);
  }

  Future<void> _abrir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarAltaAutocontrol(context),
        icon: const Icon(Icons.add_task),
        label: Text(SoleraL10n.t('obra.nuevo_control')),
      ),
      body: FutureBuilder<_DatosHoy>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          final fecha =
              DateFormat.MMMMEEEEd(SoleraL10n.idioma).format(DateTime.now());
          final totalPiezas = datos?.piezasPorReceta.values
                  .fold<int>(0, (suma, piezas) => suma + piezas) ??
              0;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              CabeceraHoySolera(
                titulo: 'Larrea Obrador',
                rutaLogo: rutaLogoObrador,
                fecha: fecha,
                acciones: [
                  IconButton(
                    tooltip: SoleraL10n.t('obra.hornadas'),
                    icon: const Icon(Icons.local_fire_department_outlined),
                    onPressed: () => _abrir(const PantallaHornadas()),
                  ),
                  IconButton(
                    tooltip: SoleraL10n.t('obra.pedidos_fijos'),
                    icon: const Icon(Icons.event_repeat_outlined),
                    onPressed: () => _abrir(const PantallaPedidosFijos()),
                  ),
                  IconButton(
                    tooltip: SoleraL10n.t('obra.masa_madre'),
                    icon: const Icon(Icons.bubble_chart_outlined),
                    onPressed: () => _abrir(const PantallaMasaMadre()),
                  ),
                ],
                cifras: [
                  CifraCabecera(
                      valor: '$totalPiezas',
                      etiqueta: SoleraL10n.t('obra.piezas_para_hoy')),
                  CifraCabecera(
                      valor: '${datos?.controles.length ?? 0}',
                      etiqueta: SoleraL10n.t('obra.controles_de_hoy')),
                ],
              ),
              // Aviso de versión nueva: si no la hay, no ocupa sitio.
              AvisoActualizaciones(
                config: configActualizacionesMonorepo('solera-obrador'),
                nombreApp: 'Larrea Obrador',
              ),
              if (!catalogosCompletamenteRevisados)
                AvisoCatalogosProvisionales(
                    texto: SoleraL10n.t('obra.catalogos_provisionales')),
              if (instantanea.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('obra.error_cargar')),
                ),
              if (datos != null) ..._bloques(context, datos),
            ],
          );
        },
      ),
    );
  }

  /// Tarjeta de bienvenida mientras falten ingredientes o recetas, como en
  /// el resto de verticales.
  Widget _primerosPasos(BuildContext context) => Card(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(SoleraL10n.t('obra.primeros_pasos'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(SoleraL10n.t('obra.ayuda_empezar_texto')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _abrir(const PantallaEditarIngrediente()),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(SoleraL10n.t('obra.nuevo_ingrediente')),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _abrir(const PantallaEditarReceta()),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(SoleraL10n.t('obra.nueva_receta')),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  List<Widget> _bloques(BuildContext context, _DatosHoy datos) {
    final refresco = datos.ultimoRefresco;
    return [
      if (!datos.hayIngredientes || datos.recetas.isEmpty)
        _primerosPasos(context),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('obra.que_hornear')),
      ),
      if (datos.piezasPorReceta.isEmpty)
        ListTile(title: Text(SoleraL10n.t('obra.sin_pedidos_hoy')))
      else
        for (final MapEntry(key: recetaId, value: piezas)
            in datos.piezasPorReceta.entries)
          ListTile(
            leading: const Icon(Icons.bakery_dining_outlined),
            title: Text(datos.recetas[recetaId]?.nombre ?? '#$recetaId'),
            trailing:
                Text('$piezas', style: Theme.of(context).textTheme.titleMedium),
          ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('obra.controles_de_hoy')),
      ),
      if (datos.controles.isEmpty)
        ListTile(title: Text(SoleraL10n.t('obra.sin_controles_hoy')))
      else
        for (final control in datos.controles)
          TarjetaRegistroAutocontrol(registro: control),
      if (refresco != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TituloBloqueSolera(SoleraL10n.t('obra.masa_madre')),
        ),
        ListTile(
          leading: const Icon(Icons.bubble_chart_outlined),
          title: Text(refresco.$1.nombre),
          subtitle: Text(refresco.$2 == null
              ? SoleraL10n.t('obra.sin_refrescos')
              : '${DateFormat.MMMd(SoleraL10n.idioma).add_Hm().format(DateTime.fromMillisecondsSinceEpoch(refresco.$2!.fechaMs))}'
                  ' · ${refresco.$2!.proporcion}'
                  ' · ${formatearNumero(refresco.$2!.hidratacionPorcentaje, decimales: 0)} %'),
        ),
      ],
    ];
  }
}
