import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/plan_gestion.dart';
import '../estado/cambios_datos.dart';
import '../modelos/actuacion_plan.dart';
import '../modelos/aprovechamiento.dart';
import '../modelos/ejecucion.dart';
import '../modelos/rodal.dart';
import '../utiles/textos_monte.dart';
import 'formularios.dart';

class _DatosPlan {
  _DatosPlan(
      this.actuaciones, this.ejecuciones, this.rodales, this.aprovechamientos);

  final List<ActuacionPlan> actuaciones;
  final List<Ejecucion> ejecuciones;
  final List<Rodal> rodales;
  final List<Aprovechamiento> aprovechamientos;
}

/// El plan de gestión: lo previsto por año y rodal, lo ejecutado, y el
/// volumen previsto frente a lo aprovechado.
class PantallaPlan extends StatefulWidget {
  const PantallaPlan({super.key});

  @override
  State<PantallaPlan> createState() => _PantallaPlanState();
}

class _PantallaPlanState extends State<PantallaPlan>
    with SingleTickerProviderStateMixin {
  late final TabController _pestanas = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));
  late Future<_DatosPlan> _datos = _cargar();

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

  static Future<_DatosPlan> _cargar() async {
    final bd = BaseDatosSoleraMonte.instancia;
    return _DatosPlan(
        await bd.listarActuaciones(),
        await bd.listarEjecuciones(),
        await bd.listarRodales(),
        await bd.listarAprovechamientos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('mont.plan')),
        bottom: TabBar(
          controller: _pestanas,
          tabs: [
            Tab(text: SoleraL10n.t('mont.previsto')),
            Tab(text: SoleraL10n.t('mont.ejecutado')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pestanas.index == 0
            ? mostrarEdicionActuacion(context)
            : mostrarEdicionEjecucion(context),
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t(_pestanas.index == 0
            ? 'mont.nueva_actuacion'
            : 'mont.nueva_ejecucion')),
      ),
      body: FutureBuilder<_DatosPlan>(
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
            children: [_previsto(context, datos), _ejecutado(context, datos)],
          );
        },
      ),
    );
  }

  String _codigoRodal(_DatosPlan datos, int? rodalId) => rodalId == null
      ? SoleraL10n.t('mont.todo_el_monte')
      : datos.rodales.where((r) => r.id == rodalId).firstOrNull?.etiqueta ??
          '?';

  Widget _previsto(BuildContext context, _DatosPlan datos) {
    if (datos.actuaciones.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_actuaciones'),
                  textAlign: TextAlign.center)));
    }
    final anyoActual = DateTime.now().year;
    final resumen =
        resumenPlanPorAnyo(datos.actuaciones, datos.ejecuciones, anyoActual);
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final anyo in resumen) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TituloBloqueSolera('${anyo.anyo}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              SoleraL10n.tf('mont.resumen_anyo', {
                'ejecutadas': '${anyo.ejecutadas}',
                'previstas': '${anyo.previstas}',
              }),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          () {
            final volumen = compararVolumen(anyo.anyo,
                actuaciones: datos.actuaciones,
                aprovechamientos: datos.aprovechamientos,
                m3PorEstereo: m3PorEstereo);
            if (volumen.previstoPlanM3 <= 0 && volumen.aprovechadoM3 <= 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Text(
                  SoleraL10n.tf('mont.volumen_previsto_aprovechado', {
                    'previsto':
                        formatearNumero(volumen.previstoPlanM3, decimales: 0),
                    'aprovechado':
                        formatearNumero(volumen.aprovechadoM3, decimales: 0),
                  }),
                  style: Theme.of(context).textTheme.bodySmall),
            );
          }(),
          for (final actuacion
              in datos.actuaciones.where((a) => a.anyoPrevisto == anyo.anyo))
            () {
              final estado =
                  estadoActuacion(actuacion, datos.ejecuciones, anyoActual);
              return ListTile(
                leading: Icon(
                    switch (estado) {
                      EstadoActuacion.ejecutada => Icons.check_circle_outline,
                      EstadoActuacion.enCurso => Icons.timelapse,
                      EstadoActuacion.atrasada => Icons.warning_amber_outlined,
                      EstadoActuacion.cancelada => Icons.block,
                      EstadoActuacion.pendiente => Icons.radio_button_unchecked,
                    },
                    color: estado == EstadoActuacion.atrasada
                        ? Theme.of(context).colorScheme.error
                        : null),
                title: Text(
                    '${nombreTipoActuacion(actuacion.tipo)} · ${_codigoRodal(datos, actuacion.rodalId)}'),
                subtitle: Text([
                  textoEstadoActuacion(estado),
                  if (actuacion.superficiePrevistaHa != null)
                    '${formatearNumero(actuacion.superficiePrevistaHa!, decimales: 2)} ha',
                  if (actuacion.volumenPrevistoM3 != null)
                    '${formatearNumero(actuacion.volumenPrevistoM3!)} m³',
                  if (actuacion.descripcion.isNotEmpty) actuacion.descripcion,
                ].join(' · ')),
                trailing: estado == EstadoActuacion.ejecutada ||
                        estado == EstadoActuacion.cancelada
                    ? null
                    : IconButton(
                        tooltip: SoleraL10n.t('mont.apuntar_ejecucion'),
                        icon: const Icon(Icons.task_alt),
                        onPressed: () => mostrarEdicionEjecucion(context,
                            deActuacion: actuacion),
                      ),
                onTap: () =>
                    mostrarEdicionActuacion(context, actuacion: actuacion),
              );
            }(),
        ],
      ],
    );
  }

  Widget _ejecutado(BuildContext context, _DatosPlan datos) {
    if (datos.ejecuciones.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(SoleraL10n.t('mont.sin_ejecuciones'),
                  textAlign: TextAlign.center)));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final ejecucion in datos.ejecuciones)
          ListTile(
            leading: Icon(ejecucion.actuacionPlanId == null
                ? Icons.add_task
                : Icons.task_alt),
            title: Text(
                '${formatearFecha(ejecucion.fechaMs)} · ${nombreTipoActuacion(ejecucion.tipo)}'),
            subtitle: Text([
              _codigoRodal(datos, ejecucion.rodalId),
              if (ejecucion.superficieHa != null)
                '${formatearNumero(ejecucion.superficieHa!, decimales: 2)} ha',
              if (ejecucion.ejecutor.isNotEmpty) ejecucion.ejecutor,
              if (ejecucion.actuacionPlanId == null)
                SoleraL10n.t('mont.no_prevista'),
              if (!ejecucion.completa) SoleraL10n.t('mont.en_parte'),
            ].join(' · ')),
            onTap: () => mostrarEdicionEjecucion(context, ejecucion: ejecucion),
          ),
      ],
    );
  }
}
