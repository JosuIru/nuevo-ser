import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show CampoPunto, leerPosicionActual;

import '../branding.dart';

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/incendios.dart';
import '../dominio/superficies.dart';
import '../estado/cambios_datos.dart';
import '../modelos/arbol_singular.dart';
import '../modelos/incendios.dart';
import '../modelos/rodal.dart';
import '../utiles/textos_monte.dart';
import 'formularios.dart';
import 'hoja_formulario.dart';
import 'identificar_con_ia.dart';
import 'pantalla_mapa.dart';

class _DatosMonte {
  _DatosMonte(
      this.rodales, this.arboles, this.infraestructuras, this.revisiones);

  final List<Rodal> rodales;
  final List<ArbolSingular> arboles;
  final List<InfraestructuraIncendios> infraestructuras;

  /// Revisiones del año en curso.
  final List<RevisionIncendios> revisiones;
}

/// El monte: rodales (con su superficie por especie), árboles singulares y
/// parcelas de muestreo, e infraestructuras contra incendios.
class PantallaMonte extends StatefulWidget {
  const PantallaMonte({super.key});

  @override
  State<PantallaMonte> createState() => _PantallaMonteState();
}

class _PantallaMonteState extends State<PantallaMonte>
    with SingleTickerProviderStateMixin {
  late final TabController _pestanas = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));
  late Future<_DatosMonte> _datos = _cargar();

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

  static Future<_DatosMonte> _cargar() async {
    final bd = BaseDatosSoleraMonte.instancia;
    final (desde, hasta) = intervaloAnyo(DateTime.now().year);
    return _DatosMonte(
      await bd.listarRodales(),
      await bd.listarArboles(),
      await bd.listarInfraestructuras(),
      await bd.listarRevisiones(desdeMs: desde, hastaMs: hasta),
    );
  }

  Future<void> _nuevo(_DatosMonte? datos) async {
    switch (_pestanas.index) {
      case 0:
        await mostrarEdicionRodal(context);
      case 1:
        final siguiente = (datos?.arboles.length ?? 0) + 1;
        await mostrarEdicionArbol(context,
            codigoPropuesto: 'AS-${siguiente.toString().padLeft(3, '0')}');
      default:
        await mostrarEdicionInfraestructura(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const etiquetasBoton = [
      'mont.nuevo_rodal',
      'mont.nuevo_arbol',
      'mont.nueva_infraestructura',
    ];
    return FutureBuilder<_DatosMonte>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(SoleraL10n.t('mont.monte')),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('mont.ia_identificar'),
                icon: const Icon(Icons.document_scanner_outlined),
                onPressed: () => identificarPlagaConFoto(context),
              ),
              IconButton(
                tooltip: SoleraL10n.t('mont.mapa'),
                icon: const Icon(Icons.map_outlined),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PantallaMapaMonte())),
              ),
            ],
            bottom: TabBar(
              controller: _pestanas,
              tabs: [
                Tab(text: SoleraL10n.t('mont.rodales')),
                Tab(text: SoleraL10n.t('mont.arboles')),
                Tab(text: SoleraL10n.t('mont.incendios')),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _nuevo(datos),
            icon: const Icon(Icons.add),
            label: Text(SoleraL10n.t(etiquetasBoton[_pestanas.index])),
          ),
          body: datos == null
              ? Center(
                  child: instantanea.hasError
                      ? Text(SoleraL10n.t('mont.error_cargar'))
                      : const CircularProgressIndicator())
              : TabBarView(
                  controller: _pestanas,
                  children: [
                    _ListaRodales(rodales: datos.rodales),
                    _ListaArboles(
                        arboles: datos.arboles, rodales: datos.rodales),
                    _ListaInfraestructuras(
                        infraestructuras: datos.infraestructuras,
                        revisiones: datos.revisiones),
                  ],
                ),
        );
      },
    );
  }
}

class _ListaRodales extends StatelessWidget {
  const _ListaRodales({required this.rodales});

  final List<Rodal> rodales;

  @override
  Widget build(BuildContext context) {
    if (rodales.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_rodales'),
                  textAlign: TextAlign.center)));
    }
    final porEspecie = superficiePorEspecie(rodales);
    final anyo = DateTime.now().year;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TituloBloqueSolera(SoleraL10n.tf('mont.superficie_total',
              {'ha': formatearNumero(superficieTotal(rodales), decimales: 2)})),
        ),
        for (final (especie, superficie) in porEspecie)
          ListTile(
            dense: true,
            title: Text(nombreEspecie(especie)),
            trailing: Text('${formatearNumero(superficie, decimales: 2)} ha'),
          ),
        const Divider(),
        for (final rodal in rodales)
          ListTile(
            leading: Icon(rodal.tieneContorno
                ? Icons.pentagon_outlined
                : Icons.crop_square_outlined),
            title: Text(rodal.etiqueta),
            subtitle: Text([
              nombreEspecie(rodal.especiePrincipalId),
              if (rodal.superficieHa > 0)
                '${formatearNumero(rodal.superficieHa, decimales: 2)} ha',
              if (rodal.edadEn(anyo) != null)
                SoleraL10n.tf(
                    'mont.edad_anyos', {'n': '${rodal.edadEn(anyo)}'}),
              nombreEstadoMasa(rodal.estadoMasa),
            ].join(' · ')),
            onTap: () => abrirFichaRodal(context, rodal),
          ),
      ],
    );
  }
}

/// Ficha del rodal: datos, editar, dibujar el contorno y borrar.
Future<void> abrirFichaRodal(BuildContext context, Rodal rodal) async {
  final accion = await showModalBottomSheet<String>(
    context: context,
    builder: (contexto) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(rodal.etiqueta,
                style: Theme.of(contexto).textTheme.titleMedium),
            subtitle: Text(rodal.tieneContorno
                ? SoleraL10n.tf('mont.superficie_dibujada', {
                    'ha': formatearNumero(rodal.superficieCalculadaHa,
                        decimales: 2)
                  })
                : SoleraL10n.t('mont.sin_contorno')),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(SoleraL10n.t('editar')),
            onTap: () => Navigator.pop(contexto, 'editar'),
          ),
          ListTile(
            leading: const Icon(Icons.edit_location_alt_outlined),
            title: Text(SoleraL10n.t('mont.dibujar_contorno')),
            onTap: () => Navigator.pop(contexto, 'contorno'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(SoleraL10n.t('borrar')),
            onTap: () => Navigator.pop(contexto, 'borrar'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || accion == null) return;
  final bd = BaseDatosSoleraMonte.instancia;
  switch (accion) {
    case 'editar':
      await mostrarEdicionRodal(context, rodal: rodal);
    case 'contorno':
      await editarAreaRodal(context, rodal);
    case 'borrar':
      if (!await confirmar(context, 'mont.borrar_rodal')) return;
      try {
        await bd.borrarRodal(rodal.id!);
        avisarCambioDatos();
      } catch (_) {
        if (context.mounted) {
          avisarConMensaje(context, 'mont.rodal_con_registros');
        }
      }
  }
}

class _ListaArboles extends StatelessWidget {
  const _ListaArboles({required this.arboles, required this.rodales});

  final List<ArbolSingular> arboles;
  final List<Rodal> rodales;

  @override
  Widget build(BuildContext context) {
    if (arboles.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_arboles'),
                  textAlign: TextAlign.center)));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final arbol in arboles)
          ListTile(
            leading: Icon(arbol.esParcelaMuestreo
                ? Icons.radio_button_unchecked
                : Icons.park_outlined),
            title: Text(arbol.nombre.isEmpty
                ? arbol.codigo
                : '${arbol.codigo} · ${arbol.nombre}'),
            subtitle: Text([
              nombreTipoArbol(arbol.tipo),
              if (arbol.especieId.isNotEmpty) nombreEspecie(arbol.especieId),
              if (arbol.perimetroCm != null)
                '${formatearNumero(arbol.perimetroCm!)} cm',
              if (arbol.rodalId != null)
                rodales
                        .where((rodal) => rodal.id == arbol.rodalId)
                        .firstOrNull
                        ?.codigo ??
                    '',
              if (!arbol.tieneUbicacion) SoleraL10n.t('mont.sin_ubicacion'),
            ].where((parte) => parte.isNotEmpty).join(' · ')),
            trailing: IconButton(
              tooltip: SoleraL10n.t('mont.usar_mi_ubicacion'),
              icon: const Icon(Icons.my_location),
              onPressed: () async {
                final lectura = await leerPosicionActual();
                if (!context.mounted) return;
                if (lectura == null) {
                  avisarConMensaje(context, 'mont.sin_gps');
                  return;
                }
                await BaseDatosSoleraMonte.instancia.guardarArbol(
                    arbol.conUbicacion(
                        lectura.posicion.latitude, lectura.posicion.longitude));
                avisarCambioDatos();
              },
            ),
            onTap: () => mostrarEdicionArbol(context, arbol: arbol),
          ),
      ],
    );
  }
}

class _ListaInfraestructuras extends StatelessWidget {
  const _ListaInfraestructuras(
      {required this.infraestructuras, required this.revisiones});

  final List<InfraestructuraIncendios> infraestructuras;
  final List<RevisionIncendios> revisiones;

  @override
  Widget build(BuildContext context) {
    if (infraestructuras.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_infraestructuras'),
                  textAlign: TextAlign.center)));
    }
    final anyo = DateTime.now().year;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final infraestructura in infraestructuras)
          () {
            final estado = estadoCampanya(infraestructura, revisiones, anyo);
            final esquema = Theme.of(context).colorScheme;
            return ListTile(
              leading: Icon(
                infraestructura.tipo == 'punto_agua'
                    ? Icons.water_drop_outlined
                    : infraestructura.esLineal
                        ? Icons.timeline
                        : Icons.local_fire_department_outlined,
                color: infraestructura.activa ? null : esquema.outline,
              ),
              title: Text(infraestructura.nombre),
              subtitle: Text([
                nombreTipoInfraestructura(infraestructura.tipo),
                if (infraestructura.esLineal &&
                    longitudInfraestructuraMetros(infraestructura) > 0)
                  '${formatearNumero(longitudInfraestructuraMetros(infraestructura), decimales: 0)} m',
                if (!infraestructura.activa) SoleraL10n.t('mont.inactiva'),
              ].join(' · ')),
              trailing: infraestructura.activa
                  ? Chip(
                      label: Text(textoEstadoCampanya(estado)),
                      backgroundColor:
                          estado == EstadoCampanyaIncendios.correcta
                              ? esquema.secondaryContainer
                              : esquema.errorContainer,
                    )
                  : null,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PantallaInfraestructura(
                          infraestructuraId: infraestructura.id!))),
            );
          }(),
      ],
    );
  }
}

/// Ficha de una infraestructura: datos, ubicación o traza y revisiones.
class PantallaInfraestructura extends StatefulWidget {
  const PantallaInfraestructura({super.key, required this.infraestructuraId});

  final int infraestructuraId;

  @override
  State<PantallaInfraestructura> createState() =>
      _PantallaInfraestructuraState();
}

class _PantallaInfraestructuraState extends State<PantallaInfraestructura> {
  late Future<(InfraestructuraIncendios?, List<RevisionIncendios>)> _datos =
      _cargar();

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

  Future<(InfraestructuraIncendios?, List<RevisionIncendios>)> _cargar() async {
    final bd = BaseDatosSoleraMonte.instancia;
    final todas = await bd.listarInfraestructuras();
    return (
      todas.where((i) => i.id == widget.infraestructuraId).firstOrNull,
      await bd.listarRevisiones(infraestructuraId: widget.infraestructuraId),
    );
  }

  /// Pistas, cortafuegos y fajas: traza abierta caminando.
  Future<void> _trazar(InfraestructuraIncendios infraestructura) async {
    final traza = await Navigator.push<List<LatLng>>(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaTrazado(
                titulo: infraestructura.nombre,
                verticesIniciales: infraestructura.traza)));
    if (traza == null) return;
    await BaseDatosSoleraMonte.instancia
        .guardarInfraestructura(infraestructura.conTraza(traza));
    avisarCambioDatos();
  }

  /// Puntos de agua y demás: el punto con el GPS o marcado en el mapa.
  Future<void> _ubicar(InfraestructuraIncendios infraestructura,
      double? latitud, double? longitud) async {
    await BaseDatosSoleraMonte.instancia
        .guardarInfraestructura(InfraestructuraIncendios.fromMap({
      ...infraestructura.toMap(),
      'latitud': latitud,
      'longitud': longitud,
    }));
    avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(InfraestructuraIncendios?, List<RevisionIncendios>)>(
      future: _datos,
      builder: (context, instantanea) {
        final infraestructura = instantanea.data?.$1;
        final revisiones = instantanea.data?.$2 ?? const [];
        return Scaffold(
          appBar: AppBar(
            title: Text(infraestructura?.nombre ?? ''),
            actions: [
              if (infraestructura != null)
                IconButton(
                  tooltip: SoleraL10n.t('editar'),
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => mostrarEdicionInfraestructura(context,
                      infraestructura: infraestructura),
                ),
            ],
          ),
          floatingActionButton: infraestructura == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => mostrarNuevaRevision(context,
                      infraestructura: infraestructura),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: Text(SoleraL10n.t('mont.nueva_revision')),
                ),
          body: infraestructura == null
              ? const SizedBox.shrink()
              : ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    ListTile(
                      title:
                          Text(nombreTipoInfraestructura(infraestructura.tipo)),
                      subtitle: Text([
                        if (infraestructura.capacidadM3 != null)
                          '${formatearNumero(infraestructura.capacidadM3!)} m³',
                        if (infraestructura.esLineal)
                          '${formatearNumero(longitudInfraestructuraMetros(infraestructura), decimales: 0)} m',
                        if (infraestructura.anchoM != null)
                          '${formatearNumero(infraestructura.anchoM!)} m ${SoleraL10n.t('mont.de_ancho')}',
                        if (infraestructura.notas.isNotEmpty)
                          infraestructura.notas,
                      ].join(' · ')),
                    ),
                    if (infraestructura.esLineal)
                      ListTile(
                        leading: const Icon(Icons.directions_walk),
                        title: Text(SoleraL10n.t('mont.trazar_caminando')),
                        subtitle: Text(
                            '${infraestructura.traza.length} ${SoleraL10n.t('mont.puntos')}'),
                        onTap: () => _trazar(infraestructura),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CampoPunto(
                          latitud: infraestructura.latitud,
                          longitud: infraestructura.longitud,
                          paqueteApp: paqueteAppMonte,
                          alCambiar: (latitud, longitud) =>
                              _ubicar(infraestructura, latitud, longitud),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          TituloBloqueSolera(SoleraL10n.t('mont.revisiones')),
                    ),
                    if (revisiones.isEmpty)
                      ListTile(
                          title: Text(SoleraL10n.t('mont.sin_revisiones'))),
                    for (final revision in revisiones)
                      ListTile(
                        leading: Icon(revision.pideTrabajo
                            ? Icons.build_outlined
                            : Icons.check_circle_outline),
                        title: Text(
                            '${formatearFecha(revision.fechaMs)} · ${nombreEstadoRevision(revision.estado)}'),
                        subtitle: Text([
                          revision.trabajosNecesarios,
                          revision.revisor,
                        ].where((parte) => parte.isNotEmpty).join(' · ')),
                        onTap: () => mostrarNuevaRevision(context,
                            infraestructura: infraestructura,
                            revision: revision),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
