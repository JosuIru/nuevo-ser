import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show AvisoCatalogosProvisionales;
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n, TituloBloqueSolera;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../dominio/aprovechamientos.dart';
import '../dominio/incendios.dart';
import '../dominio/plan_gestion.dart';
import '../dominio/superficies.dart';
import '../estado/cambios_datos.dart';
import '../modelos/actuacion_plan.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/ejecucion.dart';
import '../modelos/incendios.dart';
import '../modelos/monte.dart';
import '../modelos/rodal.dart';
import '../modelos/sorteo_lena.dart';
import '../utiles/textos_monte.dart';
import 'formularios.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_sorteo.dart';

class _DatosHoy {
  _DatosHoy(
      this.monte,
      this.rodales,
      this.actuaciones,
      this.ejecuciones,
      this.aprovechamientos,
      this.sorteos,
      this.infraestructuras,
      this.revisiones);

  final Monte monte;
  final List<Rodal> rodales;
  final List<ActuacionPlan> actuaciones;
  final List<Ejecucion> ejecuciones;
  final List<Aprovechamiento> aprovechamientos;
  final List<SorteoLena> sorteos;
  final List<InfraestructuraIncendios> infraestructuras;
  final List<RevisionIncendios> revisiones;
}

/// Lo del día: la época de peligro de incendios, los trámites y plazos de
/// los aprovechamientos, el plan del año y los sorteos sin hacer.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

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

  static Future<_DatosHoy> _cargar() async {
    final bd = BaseDatosSoleraMonte.instancia;
    final anyo = DateTime.now().year;
    final (desde, hasta) = intervaloAnyo(anyo);
    return _DatosHoy(
      await bd.obtenerMonte(),
      await bd.listarRodales(),
      await bd.listarActuaciones(hastaAnyo: anyo),
      await bd.listarEjecuciones(),
      [
        ...await bd.listarAprovechamientos(campanya: anyo),
        ...await bd.listarAprovechamientos(campanya: anyo - 1),
      ],
      await bd.listarSorteos(),
      await bd.listarInfraestructuras(soloActivas: true),
      await bd.listarRevisiones(desdeMs: desde, hastaMs: hasta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_DatosHoy>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          final anyo = DateTime.now().year;
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CabeceraHoySolera(
                titulo: (datos?.monte.nombre.isNotEmpty ?? false)
                    ? datos!.monte.nombre
                    : 'Larrea Monte',
                rutaLogo: rutaLogoMonte,
                fecha: DateFormat.MMMMEEEEd(SoleraL10n.idioma)
                    .format(DateTime.now()),
                cifras: [
                  CifraCabecera(
                      valor: '${datos?.rodales.length ?? 0}',
                      etiqueta: SoleraL10n.t('mont.rodales')),
                  CifraCabecera(
                      valor: formatearNumero(
                          superficieTotal(datos?.rodales ?? const []),
                          decimales: 0),
                      etiqueta: 'ha'),
                  CifraCabecera(
                      valor:
                          '${datos?.aprovechamientos.where((a) => a.campanya == anyo).length ?? 0}',
                      etiqueta: SoleraL10n.t('mont.aprovechamientos_anyo')),
                ],
              ),
              if (!catalogosCompletamenteRevisados)
                AvisoCatalogosProvisionales(texto: SoleraL10n.t('mont.catalogos_provisionales')),
              if (instantanea.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('mont.error_cargar')),
                ),
              if (datos != null) ..._bloques(context, datos),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _bloques(BuildContext context, _DatosHoy datos) {
    final esquema = Theme.of(context).colorScheme;
    if (datos.rodales.isEmpty && datos.monte.nombre.isEmpty) {
      return [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SoleraL10n.t('mont.primeros_pasos'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(SoleraL10n.t('mont.primeros_pasos_texto')),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PantallaDatosMonte())),
                      icon: const Icon(Icons.landscape_outlined),
                      label: Text(SoleraL10n.t('mont.datos_monte')),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => mostrarEdicionRodal(context),
                      icon: const Icon(Icons.pentagon_outlined),
                      label: Text(SoleraL10n.t('mont.nuevo_rodal')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ];
    }
    final hoy = DateTime.now();
    final avisoIncendios = avisoEpocaPeligro(
        monte: datos.monte,
        infraestructuras: datos.infraestructuras,
        revisiones: datos.revisiones,
        hoy: hoy);
    final conAvisos = [
      for (final aprovechamiento in datos.aprovechamientos)
        if (avisosAprovechamiento(aprovechamiento, hoy).isNotEmpty)
          aprovechamiento
    ];
    final delPlan = [
      for (final actuacion in datos.actuaciones)
        if ({
          EstadoActuacion.atrasada,
          EstadoActuacion.pendiente,
          EstadoActuacion.enCurso
        }.contains(estadoActuacion(actuacion, datos.ejecuciones, hoy.year)))
          actuacion
    ];
    final sinSortear = datos.sorteos.where((s) => !s.realizado).toList();
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('mont.incendios')),
      ),
      if (datos.monte.inicioEpocaPeligroEn(hoy.year) == null)
        ListTile(
          leading: const Icon(Icons.event_note_outlined),
          title: Text(SoleraL10n.t('mont.apunta_epoca_peligro')),
          subtitle: Text(SoleraL10n.t('mont.epoca_peligro_ca')),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PantallaDatosMonte())),
        )
      else if (avisoIncendios == null)
        ListTile(
          leading: const Icon(Icons.local_fire_department_outlined),
          title: Text(SoleraL10n.tf('mont.epoca_peligro_empieza', {
            'fecha': formatearFecha(datos.monte
                .inicioEpocaPeligroEn(hoy.year)!
                .millisecondsSinceEpoch)
          })),
        )
      else ...[
        ListTile(
          leading: Icon(Icons.local_fire_department,
              color: avisoIncendios.hayPendientes ? esquema.error : null),
          title: Text(SoleraL10n.tf(
              avisoIncendios.diasHastaInicio < 0
                  ? 'mont.epoca_peligro_en_curso'
                  : 'mont.epoca_peligro_en_dias',
              {'n': '${avisoIncendios.diasHastaInicio}'})),
          subtitle: Text(avisoIncendios.hayPendientes
              ? SoleraL10n.tf('mont.revisiones_pendientes', {
                  'sin': '${avisoIncendios.sinRevisar.length}',
                  'trabajo': '${avisoIncendios.conTrabajoPendiente.length}'
                })
              : SoleraL10n.t('mont.todo_revisado')),
        ),
        for (final infraestructura in [
          ...avisoIncendios.sinRevisar,
          ...avisoIncendios.conTrabajoPendiente
        ])
          ListTile(
            dense: true,
            leading: const SizedBox(width: 24),
            title: Text(infraestructura.nombre),
            subtitle: Text(nombreTipoInfraestructura(infraestructura.tipo)),
            onTap: () =>
                mostrarNuevaRevision(context, infraestructura: infraestructura),
          ),
      ],
      if (conAvisos.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TituloBloqueSolera(SoleraL10n.t('mont.tramites_y_plazos')),
        ),
        for (final aprovechamiento in conAvisos)
          ListTile(
            leading: Icon(Icons.assignment_late_outlined, color: esquema.error),
            title: Text(
                '${aprovechamiento.campanya} · ${nombreTipoAprovechamiento(aprovechamiento.tipo)}'),
            subtitle: Text([
              for (final aviso in avisosAprovechamiento(aprovechamiento, hoy))
                textoAvisoAprovechamiento(
                    aviso, limiteComunicacionCuantia(aprovechamiento))
            ].join('\n')),
            onTap: () => mostrarEdicionAprovechamiento(context,
                aprovechamiento: aprovechamiento),
          ),
      ],
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(
            SoleraL10n.tf('mont.plan_del_anyo', {'anyo': '${hoy.year}'})),
      ),
      if (delPlan.isEmpty)
        ListTile(title: Text(SoleraL10n.t('mont.plan_al_dia')))
      else
        for (final actuacion in delPlan)
          ListTile(
            dense: true,
            leading: Icon(
                estadoActuacion(actuacion, datos.ejecuciones, hoy.year) ==
                        EstadoActuacion.atrasada
                    ? Icons.warning_amber_outlined
                    : Icons.radio_button_unchecked),
            title: Text(
                '${actuacion.anyoPrevisto} · ${nombreTipoActuacion(actuacion.tipo)}'),
            subtitle: Text(textoEstadoActuacion(
                    estadoActuacion(actuacion, datos.ejecuciones, hoy.year)) +
                (actuacion.rodalId == null
                    ? ''
                    : ' · ${datos.rodales.where((r) => r.id == actuacion.rodalId).firstOrNull?.etiqueta ?? ''}')),
            onTap: () =>
                mostrarEdicionEjecucion(context, deActuacion: actuacion),
          ),
      if (sinSortear.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TituloBloqueSolera(SoleraL10n.t('mont.sorteos_lena')),
        ),
        for (final sorteo in sinSortear)
          ListTile(
            leading: const Icon(Icons.casino_outlined),
            title: Text(sorteo.nombre.isEmpty
                ? SoleraL10n.tf(
                    'mont.sorteo_de', {'anyo': '${sorteo.campanya}'})
                : sorteo.nombre),
            subtitle: Text(SoleraL10n.t(sorteo.fechaCierreListaMs == null
                ? 'mont.lista_abierta'
                : 'mont.lista_cerrada')),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => PantallaSorteo(sorteoId: sorteo.id!))),
          ),
      ],
    ];
  }
}
