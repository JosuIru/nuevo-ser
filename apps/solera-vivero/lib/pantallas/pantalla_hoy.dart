import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n;

import '../branding.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../dominio/catalogos.dart' show exigeAvisoAutoridad;
import '../dominio/pasaporte.dart';
import '../dominio/stock.dart';
import '../modelos/inspeccion_plagas.dart';
import '../modelos/partida_planta.dart';
import '../modelos/salida.dart';
import '../modelos/tratamiento.dart';
import '../modelos/vivero.dart';
import '../utiles/textos_vivero.dart';
import 'campos_especie.dart';
import 'formularios.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_cuaderno.dart';
import 'pantalla_escaner_qr.dart';
import 'pantalla_salidas.dart';
import 'vista_carga.dart';

class _DatosHoy {
  _DatosHoy({
    required this.vivero,
    required this.hayLotes,
    required this.hayBandejas,
    required this.hayPartidas,
    required this.inspeccionesPendientes,
    required this.salidasSinPasaporte,
    required this.plazosAbiertos,
    required this.plantasDisponibles,
    required this.listasParaVenta,
    required this.partidas,
  });
  final Vivero vivero;
  final bool hayLotes;
  final bool hayBandejas;
  final bool hayPartidas;
  final List<InspeccionPlagas> inspeccionesPendientes;
  final List<Salida> salidasSinPasaporte;
  final List<Tratamiento> plazosAbiertos;
  final int plantasDisponibles;
  final int listasParaVenta;
  final Map<int, PartidaPlanta> partidas;

  bool get faltanPrimerosPasos =>
      vivero.nombre.isEmpty || !hayLotes || !hayBandejas || !hayPartidas;
}

Future<_DatosHoy> _cargarHoy() async {
  final bd = BaseDatosSoleraVivero.instancia;
  final ahora = DateTime.now();
  final partidas = await bd.listarPartidas();
  final repicados = await bd.listarRepicados();
  final salidas = await bd.listarSalidas();
  final pasaportes = await bd.listarPasaportes();
  final stock =
      resumenStock(partidas: partidas, repicados: repicados, salidas: salidas);
  final desdeTratamientos =
      ahora.subtract(const Duration(days: 90)).millisecondsSinceEpoch;
  return _DatosHoy(
    vivero: await bd.obtenerVivero(),
    hayLotes: (await bd.listarLotesMaterial()).isNotEmpty,
    hayBandejas: (await bd.listarBandejas()).isNotEmpty,
    hayPartidas: partidas.isNotEmpty,
    inspeccionesPendientes: (await bd.listarInspecciones())
        .where((inspeccion) =>
            inspeccion.pendienteDeNotificar &&
            exigeAvisoAutoridad(inspeccion.plagaId))
        .toList(),
    salidasSinPasaporte: salidas
        .where((salida) =>
            necesidadExigePasaporte(necesidadDeSalida(salida)) &&
            !pasaportes.any((pasaporte) =>
                pasaporte.salidaId == salida.id && !pasaporte.anulado))
        .toList(),
    plazosAbiertos: (await bd.listarTratamientos(desdeMs: desdeTratamientos))
        .where((tratamiento) =>
            tratamiento.finPlazoSeguridad?.isAfter(ahora) ?? false)
        .toList(),
    plantasDisponibles:
        stock.fold<int>(0, (suma, fila) => suma + fila.disponibles),
    listasParaVenta:
        stock.fold<int>(0, (suma, fila) => suma + fila.listasParaVenta),
    partidas: {for (final partida in partidas) partida.id!: partida},
  );
}

/// Pestaña Hoy: primeros pasos, avisos (inspecciones sin notificar,
/// salidas sin pasaporte, plazos de seguridad) y accesos rápidos.
class PantallaHoy extends StatelessWidget {
  const PantallaHoy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VistaCarga<_DatosHoy>(
        cargar: _cargarHoy,
        construir: (context, datos) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            CabeceraHoySolera(
              titulo: 'Larrea Vivero',
              rutaLogo: rutaLogoVivero,
              fecha: DateFormat.MMMMEEEEd(SoleraL10n.idioma)
                  .format(DateTime.now()),
              acciones: [
                IconButton(
                  tooltip: SoleraL10n.t('vive.escanear_bandeja'),
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () => abrirBandejaPorQr(context),
                ),
                IconButton(
                  tooltip: SoleraL10n.t('ajustes'),
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PantallaAjustes())),
                ),
              ],
              cifras: [
                CifraCabecera(
                    valor: '${datos.plantasDisponibles}',
                    etiqueta: SoleraL10n.t('vive.cifra_disponibles')),
                CifraCabecera(
                    valor: '${datos.listasParaVenta}',
                    etiqueta: SoleraL10n.t('vive.cifra_listas')),
                CifraCabecera(
                    valor: '${datos.salidasSinPasaporte.length}',
                    etiqueta: SoleraL10n.t('vive.cifra_sin_pasaporte')),
              ],
            ),
            const SizedBox(height: 8),
            ...[
              if (datos.faltanPrimerosPasos) _primerosPasos(context, datos),
              if (!catalogosCompletamenteRevisados)
                Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title:
                        Text(SoleraL10n.t('vive.banner_datos_provisionales')),
                  ),
                ),
              for (final inspeccion in datos.inspeccionesPendientes)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: Text(SoleraL10n.tf('vive.aviso_inspeccion', {
                      'plaga': nombrePlagaVisible(inspeccion.plagaId),
                      'fecha': formatearFecha(inspeccion.fechaMs),
                    })),
                    subtitle:
                        Text(SoleraL10n.t('vive.aviso_notificar_autoridad')),
                  ),
                ),
              if (datos.salidasSinPasaporte.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.pending_actions_outlined),
                    title: Text(SoleraL10n.tf('vive.salidas_sin_pasaporte',
                        {'n': datos.salidasSinPasaporte.length})),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => abrirFichaSalida(
                        context, datos.salidasSinPasaporte.first.id!),
                  ),
                ),
              for (final tratamiento in datos.plazosAbiertos)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(SoleraL10n.tf('vive.plazo_abierto', {
                      'sustancia':
                          nombreSustanciaVisible(tratamiento.sustanciaActivaId),
                      'fecha': formatearFecha(tratamiento
                          .finPlazoSeguridad!.millisecondsSinceEpoch),
                    })),
                    subtitle: Text(tratamiento.partidaId == null
                        ? ''
                        : datos.partidas[tratamiento.partidaId]?.codigo ?? ''),
                  ),
                ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.grain_outlined),
                  label: Text(SoleraL10n.t('vive.nueva_siembra')),
                  onPressed: () => mostrarFormularioSiembra(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.sanitizer_outlined),
                  label: Text(SoleraL10n.t('vive.nuevo_tratamiento')),
                  onPressed: () => mostrarFormularioTratamiento(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(SoleraL10n.t('vive.nueva_inspeccion')),
                  onPressed: () => mostrarFormularioInspeccion(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.menu_book_outlined),
                  label: Text(SoleraL10n.t('vive.cuaderno')),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PantallaCuaderno())),
                ),
              ]),
            ].map((hijo) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: hijo)),
          ],
        ),
      ),
    );
  }

  Widget _primerosPasos(BuildContext context, _DatosHoy datos) {
    Widget paso(bool hecho, String texto) => ListTile(
          dense: true,
          leading: Icon(hecho ? Icons.check_circle : Icons.circle_outlined),
          title: Text(texto),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(SoleraL10n.t('vive.primeros_pasos'),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            paso(datos.vivero.nombre.isNotEmpty,
                SoleraL10n.t('vive.paso_datos_vivero')),
            paso(datos.hayLotes, SoleraL10n.t('vive.paso_lote')),
            paso(datos.hayBandejas, SoleraL10n.t('vive.paso_bandeja')),
            paso(datos.hayPartidas, SoleraL10n.t('vive.paso_siembra')),
          ],
        ),
      ),
    );
  }
}
