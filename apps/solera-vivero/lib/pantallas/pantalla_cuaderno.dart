import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/inspeccion_plagas.dart';
import '../modelos/partida_planta.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona_cultivo.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'formularios.dart';
import 'hoja_formulario.dart';
import 'vista_carga.dart';

class _DatosCuaderno {
  _DatosCuaderno(
      this.tratamientos, this.inspecciones, this.partidas, this.zonas);
  final List<Tratamiento> tratamientos;
  final List<InspeccionPlagas> inspecciones;
  final Map<int, PartidaPlanta> partidas;
  final Map<int, ZonaCultivo> zonas;

  String donde(int? partidaId, int? zonaId) => [
        if (partidaId != null) partidas[partidaId]?.codigo ?? '',
        if (zonaId != null) zonas[zonaId]?.nombre ?? '',
      ].where((parte) => parte.isNotEmpty).join(' · ');
}

/// Cuaderno del año: tratamientos fitosanitarios e inspecciones de plagas.
class PantallaCuaderno extends StatefulWidget {
  const PantallaCuaderno({super.key});

  @override
  State<PantallaCuaderno> createState() => _PantallaCuadernoState();
}

class _PantallaCuadernoState extends State<PantallaCuaderno> {
  int _anyo = DateTime.now().year;

  Future<_DatosCuaderno> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosCuaderno(
      await bd.listarTratamientos(desdeMs: desde, hastaMs: hasta),
      await bd.listarInspecciones(desdeMs: desde, hastaMs: hasta),
      {for (final partida in await bd.listarPartidas()) partida.id!: partida},
      {for (final zona in await bd.listarZonas()) zona.id!: zona},
    );
  }

  Future<void> _borrar(Future<void> Function() accion) async {
    if (!await confirmar(context, SoleraL10n.t('vive.borrar_registro'))) {
      return;
    }
    await accion();
    avisarCambioDatos();
  }

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    final bd = BaseDatosSoleraVivero.instancia;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('vive.cuaderno')),
        actions: [
          DropdownButton<int>(
            value: _anyo,
            underline: const SizedBox.shrink(),
            items: [
              for (var anyo = anyoActual; anyo >= anyoActual - 3; anyo--)
                DropdownMenuItem(value: anyo, child: Text('$anyo')),
            ],
            onChanged: (valor) => setState(() {
              _anyo = valor ?? anyoActual;
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: VistaCarga<_DatosCuaderno>(
        key: ValueKey(_anyo),
        cargar: _cargar,
        construir: (context, datos) => ListView(
          padding: const EdgeInsets.only(bottom: 88),
          children: [
            TituloSeccion(SoleraL10n.t('vive.tratamientos'),
                accion: IconButton(
                  tooltip: SoleraL10n.t('vive.nuevo_tratamiento'),
                  icon: const Icon(Icons.add),
                  onPressed: () => mostrarFormularioTratamiento(context),
                )),
            if (datos.tratamientos.isEmpty)
              ListaVacia(SoleraL10n.t('vive.sin_tratamientos')),
            for (final tratamiento in datos.tratamientos)
              ListTile(
                leading: const Icon(Icons.sanitizer_outlined),
                title: Text([
                  nombreSustanciaVisible(tratamiento.sustanciaActivaId),
                  tratamiento.nombreProducto,
                ].where((parte) => parte.isNotEmpty).join(' · ')),
                subtitle: Text([
                  formatearFecha(tratamiento.fechaMs),
                  datos.donde(tratamiento.partidaId, tratamiento.zonaId),
                  nombrePlagaVisible(tratamiento.problemaFitosanitario),
                ].where((parte) => parte.isNotEmpty).join(' · ')),
                onLongPress: () =>
                    _borrar(() => bd.borrarTratamiento(tratamiento.id!)),
              ),
            TituloSeccion(SoleraL10n.t('vive.inspecciones'),
                accion: IconButton(
                  tooltip: SoleraL10n.t('vive.nueva_inspeccion'),
                  icon: const Icon(Icons.add),
                  onPressed: () => mostrarFormularioInspeccion(context),
                )),
            if (datos.inspecciones.isEmpty)
              ListaVacia(SoleraL10n.t('vive.sin_inspecciones')),
            for (final inspeccion in datos.inspecciones)
              ListTile(
                leading: Icon(
                  inspeccion.resultado == 'no_detectada'
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_outlined,
                  color: inspeccion.pendienteDeNotificar
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                title: Text(nombrePlagaVisible(inspeccion.plagaId)),
                subtitle: Text([
                  formatearFecha(inspeccion.fechaMs),
                  datos.donde(inspeccion.partidaId, inspeccion.zonaId),
                  nombreResultadoInspeccion(inspeccion.resultado),
                  nombreTipoInspeccion(inspeccion.tipo),
                  if (inspeccion.pendienteDeNotificar)
                    SoleraL10n.t('vive.sin_notificar'),
                ].where((parte) => parte.isNotEmpty).join(' · ')),
                onLongPress: () =>
                    _borrar(() => bd.borrarInspeccion(inspeccion.id!)),
              ),
          ],
        ),
      ),
    );
  }
}
