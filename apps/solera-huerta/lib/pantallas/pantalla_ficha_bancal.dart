import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/guia.dart';
import '../dominio/rotacion.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../modelos/cosecha.dart';
import '../modelos/observacion_plaga.dart';
import '../modelos/siembra.dart';
import '../utiles/textos_huerta.dart';
import 'formularios_huerta.dart';
import 'hoja_formulario.dart';
import 'identificar_plaga.dart';
import 'pantalla_guia.dart';

/// Ficha de un bancal: el plan de rotación (qué familias no pueden volver
/// todavía), sus siembras planificadas y hechas, y sus cosechas.
class PantallaFichaBancal extends StatefulWidget {
  const PantallaFichaBancal({super.key, required this.bancalId});

  final int bancalId;

  @override
  State<PantallaFichaBancal> createState() => _PantallaFichaBancalState();
}

class _PantallaFichaBancalState extends State<PantallaFichaBancal> {
  late Future<(DatosHuerta, List<Cosecha>, List<ObservacionPlaga>)> _datos;

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

  Future<(DatosHuerta, List<Cosecha>, List<ObservacionPlaga>)>
      _cargar() async => (
            await DatosHuerta.cargar(),
            await BaseDatosSoleraHuerta.instancia
                .listarCosechas(bancalId: widget.bancalId),
            await BaseDatosSoleraHuerta.instancia
                .listarObservacionesPlaga(bancalId: widget.bancalId),
          );

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _accionesSiembra(DatosHuerta datos, Siembra siembra) async {
    final bd = BaseDatosSoleraHuerta.instancia;
    final accion = await showModalBottomSheet<String>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!siembra.realizada)
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(SoleraL10n.t('huer.marcar_hecha_hoy')),
              onTap: () => Navigator.pop(contexto, 'hecha'),
            ),
          if (siembra.realizada)
            ListTile(
              leading: const Icon(Icons.shopping_basket_outlined),
              title: Text(SoleraL10n.t('huer.nueva_cosecha')),
              onTap: () => Navigator.pop(contexto, 'cosecha'),
            ),
          if (siembra.realizada && siembra.fechaLevantadaMs == null)
            ListTile(
              leading: const Icon(Icons.cleaning_services_outlined),
              title: Text(SoleraL10n.t('huer.levantar_hoy')),
              onTap: () => Navigator.pop(contexto, 'levantar'),
            ),
          if (fichaGuiaCultivo(
                  datos.cultivo(siembra.cultivoId)?.especieId ?? '') !=
              null)
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(SoleraL10n.t('huer.guia_ver_ficha')),
              onTap: () => Navigator.pop(contexto, 'guia'),
            ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(SoleraL10n.t('editar')),
            onTap: () => Navigator.pop(contexto, 'editar'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(SoleraL10n.t('borrar')),
            onTap: () => Navigator.pop(contexto, 'borrar'),
          ),
        ]),
      ),
    );
    if (!mounted || accion == null) return;
    final hoy = DateTime.now().millisecondsSinceEpoch;
    switch (accion) {
      case 'hecha':
        await bd.guardarSiembra(siembra.copiar(fechaRealMs: hoy));
        avisarCambioDatos();
      case 'levantar':
        await bd.guardarSiembra(siembra.copiar(fechaLevantadaMs: hoy));
        avisarCambioDatos();
      case 'cosecha':
        await mostrarFormularioCosecha(context, datos: datos, siembra: siembra);
      case 'guia':
        await abrirFichaCultivoGuia(
            context, datos.cultivo(siembra.cultivoId)?.especieId ?? '');
      case 'editar':
        await mostrarFormularioSiembra(context, datos: datos, siembra: siembra);
      case 'borrar':
        if (!await confirmarBorrado(
            context, SoleraL10n.t('huer.borrar_siembra'))) {
          return;
        }
        await bd.borrarSiembra(siembra.id!);
        avisarCambioDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(DatosHuerta, List<Cosecha>, List<ObservacionPlaga>)>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data?.$1;
        final cosechas = instantanea.data?.$2 ?? const <Cosecha>[];
        final observaciones =
            instantanea.data?.$3 ?? const <ObservacionPlaga>[];
        final bancal = datos?.bancal(widget.bancalId);
        if (datos == null || bancal == null) {
          return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
        }
        final siembras = [
          for (final siembra in datos.siembras)
            if (siembra.bancalId == bancal.id) siembra
        ];
        final historial = datos.historialRotacion;
        final bloqueadas = familiasBloqueadas(
            bancalId: bancal.id!,
            fecha: DateTime.now(),
            historial: historial,
            aniosMinimosPorFamilia: aniosMinimosPorFamilia());
        final sinRegla = familiasSinRegla(historial: [
          for (final paso in historial)
            if (paso.bancalId == bancal.id) paso
        ], aniosMinimosPorFamilia: aniosMinimosPorFamilia());
        return Scaffold(
          appBar: AppBar(
            title: Text(datos.nombreDeBancal(bancal.id!)),
            actions: [
              IconButton(
                tooltip: SoleraL10n.t('huer.identificar_con_foto'),
                icon: const Icon(Icons.document_scanner_outlined),
                onPressed: () => identificarPlagaConFoto(context,
                    datos: datos, bancalId: bancal.id!),
              ),
              IconButton(
                tooltip: SoleraL10n.t('editar'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => mostrarFormularioBancal(context,
                    parcelaId: bancal.parcelaId, bancal: bancal),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => mostrarFormularioSiembra(context,
                datos: datos, bancalId: bancal.id),
            icon: const Icon(Icons.add),
            label: Text(SoleraL10n.t('huer.nueva_siembra')),
          ),
          body: ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 88)),
            children: [
              ListTile(
                title: Text(SoleraL10n.t('huer.plan_rotacion'),
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(SoleraL10n.t('huer.plan_rotacion_ayuda')),
              ),
              if (bloqueadas.isEmpty)
                ListTile(
                    leading: const Icon(Icons.check),
                    title: Text(SoleraL10n.t('huer.sin_familias_bloqueadas'))),
              for (final bloqueada in bloqueadas)
                ListTile(
                  leading: const Icon(Icons.block_outlined),
                  title: Text(nombreFamilia(bloqueada.familiaId)),
                  subtitle: Text(SoleraL10n.tf('huer.puede_volver_desde',
                      {'fecha': formatearFechaDia(bloqueada.fechaLibre)})),
                ),
              if (sinRegla.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(SoleraL10n.tf('huer.familias_sin_regla',
                      {'familias': sinRegla.map(nombreFamilia).join(', ')})),
                ),
              if (!tuvoLeguminosas(
                  bancalId: bancal.id!,
                  fecha: DateTime.now(),
                  historial: historial))
                ListTile(
                  leading: const Icon(Icons.eco_outlined),
                  title: Text(SoleraL10n.t('huer.recordatorio_leguminosas')),
                ),
              const Divider(),
              ListTile(
                title: Text(SoleraL10n.t('huer.siembras'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (siembras.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('huer.sin_siembras')),
                ),
              for (final siembra in siembras)
                ListTile(
                  leading: Icon(siembra.realizada
                      ? (siembra.fechaLevantadaMs == null
                          ? Icons.spa_outlined
                          : Icons.history)
                      : Icons.schedule_outlined),
                  title: Text(datos.nombreDeCultivo(siembra.cultivoId)),
                  subtitle: Text([
                    nombreTipoSiembra(siembra.tipo),
                    siembra.realizada
                        ? formatearFecha(siembra.fechaRealMs!)
                        : SoleraL10n.tf('huer.prevista_el',
                            {'fecha': formatearFecha(siembra.fechaPrevistaMs)}),
                    if (siembra.fechaLevantadaMs != null)
                      SoleraL10n.tf('huer.levantada_el',
                          {'fecha': formatearFecha(siembra.fechaLevantadaMs!)}),
                    if (textoAvisoRotacion(datos.avisoRotacion(
                            bancalId: siembra.bancalId,
                            cultivoId: siembra.cultivoId,
                            fecha: DateTime.fromMillisecondsSinceEpoch(
                                siembra.fechaReferenciaMs),
                            excluirSiembraId: siembra.id)) !=
                        null)
                      SoleraL10n.t('huer.rotacion_corta'),
                  ].join(' · ')),
                  onTap: () => _accionesSiembra(datos, siembra),
                ),
              const Divider(),
              ListTile(
                title: Text(SoleraL10n.t('huer.observaciones_plagas'),
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(SoleraL10n.t('huer.observaciones_plagas_ayuda')),
                trailing: IconButton(
                  tooltip: SoleraL10n.t('huer.nueva_observacion'),
                  icon: const Icon(Icons.add),
                  onPressed: () => mostrarAltaObservacion(context,
                      datos: datos,
                      bancalId: bancal.id!,
                      cultivoId:
                          datos.ocupacionDe(bancal.id!).firstOrNull?.cultivoId),
                ),
              ),
              for (final observacion in observaciones)
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(nombrePlaga(observacion.plagaId)),
                  trailing: auxiliaresDePlaga(observacion.plagaId).isEmpty
                      ? null
                      : IconButton(
                          tooltip: SoleraL10n.t('huer.guia_ver_auxiliares'),
                          icon: const Icon(Icons.menu_book_outlined),
                          onPressed: () => mostrarAuxiliaresDePlaga(
                              context, observacion.plagaId),
                        ),
                  subtitle: Text([
                    formatearFecha(observacion.fechaMs),
                    if (observacion.cultivoId != null)
                      datos.nombreDeCultivo(observacion.cultivoId!),
                    if (observacion.notas.isNotEmpty) observacion.notas,
                  ].join(' · ')),
                  onTap: () => mostrarAltaObservacion(context,
                      datos: datos,
                      bancalId: bancal.id!,
                      observacion: observacion),
                  onLongPress: () async {
                    if (!await confirmarBorrado(
                        context, SoleraL10n.t('huer.borrar_registro'))) {
                      return;
                    }
                    await BaseDatosSoleraHuerta.instancia
                        .borrarObservacionPlaga(observacion.id!);
                    avisarCambioDatos();
                  },
                ),
              const Divider(),
              ListTile(
                title: Text(SoleraL10n.t('huer.cosechas'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final cosecha in cosechas)
                ListTile(
                  leading: const Icon(Icons.shopping_basket_outlined),
                  title: Text(datos.nombreDeCultivo(cosecha.cultivoId)),
                  subtitle: Text([
                    formatearFecha(cosecha.fechaMs),
                    nombreDestinoCosecha(cosecha.destino),
                  ].join(' · ')),
                  trailing: Text([
                    if (cosecha.kg > 0) formatearKilos(cosecha.kg),
                    if (cosecha.porUnidades)
                      SoleraL10n.tf('huer.n_piezas', {'n': cosecha.unidades}),
                  ].join(' · ')),
                  onTap: () => mostrarFormularioCosecha(context,
                      datos: datos, cosecha: cosecha),
                ),
            ],
          ),
        );
      },
    );
  }
}
