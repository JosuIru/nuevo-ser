import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../servicios/cache_teselas.dart';
import '../servicios/mapa_sin_cobertura.dart';
import '../utiles/cola_descarga_teselas.dart';
import '../utiles/teselas_mapa.dart';

/// Pide confirmación y lanza la descarga de la ortofoto de las fincas
/// (desde el menú del mapa y desde Ajustes → Mapa sin cobertura).
///
/// Antes de preguntar dice cuántas teselas y MB son; sin wifi ni cable no
/// empieza. La descarga sigue aunque se cierre la pantalla, y al acabar se
/// avisa con una franja abajo.
Future<void> descargarMapaFincas(BuildContext context) async {
  final servicio = MapaSinCobertura.instancia;
  if (servicio == null || servicio.descarga.descargando) return;
  final textos = AppLocalizations.of(context);
  final mensajero = ScaffoldMessenger.of(context);
  void avisar(String texto) =>
      mensajero.showSnackBar(SnackBar(content: Text(texto)));

  final bd = BaseDatosSoleraZunbeltz();
  final fincas = fincasParaDescarga(
      await bd.listarFincas(), await bd.listarZonas(), await bd.listarPuntos());
  final plan = await servicio.descarga.planificar(fincas);
  if (plan.nombresFincas.isEmpty || plan.totalTeselas == 0) {
    avisar(textos.mapaDescargaSinFincas);
    return;
  }
  if (plan.nadaQueBajar) {
    avisar(textos.mapaDescargaNadaQueBajar);
    return;
  }
  final megas = megabytesHaciaArriba(plan.bytesEstimados);
  if (!await servicio.hayWifi()) {
    avisar(textos.mapaDescargaSinWifi(megas));
    return;
  }
  if (!context.mounted) return;
  final confirmada = await showDialog<bool>(
    context: context,
    builder: (contexto) => AlertDialog(
      title: Text(textos.mapaDescargaConfirmarTitulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textos.mapaDescargaConfirmar(
              plan.nombresFincas.join(', '),
              zoomMinimoDescarga,
              zoomMaximoDescarga,
              plan.pendientes.length,
              megas,
            )),
            if (plan.yaDescargadas > 0) ...[
              const SizedBox(height: 8),
              Text(textos.mapaDescargaYaBajadas(plan.yaDescargadas)),
            ],
            const SizedBox(height: 8),
            Text(textos.mapaCallejeroSoloVisto,
                style: Theme.of(contexto).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(contexto, false),
            child: Text(textos.comunCancelar)),
        FilledButton(
            onPressed: () => Navigator.pop(contexto, true),
            child: Text(textos.mapaDescargaBoton)),
      ],
    ),
  );
  if (confirmada != true) return;
  unawaited(servicio.descarga.iniciar(plan));
}

/// Texto de cómo acabó una descarga.
String textoFinDescargaMapa(AppLocalizations textos, FinDescargaTeselas fin,
    ProgresoDescargaTeselas? progreso) {
  switch (fin) {
    case FinDescargaTeselas.completada:
      final fallidas = progreso?.fallidas ?? 0;
      return fallidas == 0
          ? textos.mapaDescargaCompletada
          : textos.mapaDescargaConFallos(fallidas);
    case FinDescargaTeselas.cancelada:
      return textos.mapaDescargaCancelada;
    case FinDescargaTeselas.sinWifi:
      return textos.mapaDescargaParadaSinWifi;
    case FinDescargaTeselas.demasiadosFallos:
      return textos.mapaDescargaParadaFallos;
  }
}

/// Franja con el progreso de la descarga (y cancelar), o con cómo acabó
/// (y cerrar). Nada si no hay descarga.
class FranjaDescargaMapa extends StatelessWidget {
  const FranjaDescargaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = MapaSinCobertura.instancia;
    if (servicio == null) return const SizedBox.shrink();
    final gestor = servicio.descarga;
    return ListenableBuilder(
      listenable: gestor,
      builder: (context, _) {
        final progreso = gestor.progreso;
        final fin = gestor.ultimoFin;
        if (!gestor.descargando && fin == null) return const SizedBox.shrink();
        final textos = AppLocalizations.of(context);
        return Material(
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radioZunbeltz)),
            side: BorderSide(color: colorLineaZunbeltz),
          ),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gestor.descargando
                            ? textos.mapaDescargando(
                                progreso?.intentadas ?? 0, progreso?.total ?? 0)
                            : textoFinDescargaMapa(textos, fin!, progreso),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (gestor.descargando) ...[
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: progreso?.fraccion ?? 0),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: textos.comunCancelar,
                  icon: const Icon(Icons.close),
                  onPressed: gestor.descargando
                      ? gestor.cancelar
                      : gestor.olvidarResultado,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Ajustes → Mapa sin cobertura: qué ocupa lo guardado, descargar el mapa
/// de las fincas y borrarlo.
class PantallaMapaSinCobertura extends StatefulWidget {
  const PantallaMapaSinCobertura({super.key});

  @override
  State<PantallaMapaSinCobertura> createState() =>
      _PantallaMapaSinCoberturaState();
}

class _PantallaMapaSinCoberturaState extends State<PantallaMapaSinCobertura> {
  final MapaSinCobertura? _servicio = MapaSinCobertura.instancia;
  TamanoCacheTeselas? _tamano;
  bool _estabaDescargando = false;

  @override
  void initState() {
    super.initState();
    _servicio?.descarga.addListener(_alCambiarDescarga);
    _estabaDescargando = _servicio?.descarga.descargando ?? false;
    _medir();
  }

  @override
  void dispose() {
    _servicio?.descarga.removeListener(_alCambiarDescarga);
    super.dispose();
  }

  void _alCambiarDescarga() {
    final descargando = _servicio?.descarga.descargando ?? false;
    if (_estabaDescargando && !descargando) _medir();
    if (_estabaDescargando != descargando && mounted) setState(() {});
    _estabaDescargando = descargando;
  }

  Future<void> _medir() async {
    final servicio = _servicio;
    if (servicio == null) return;
    final tamano = await servicio.almacen.tamano();
    if (mounted) setState(() => _tamano = tamano);
  }

  Future<void> _borrar({required bool descargado}) async {
    final servicio = _servicio;
    if (servicio == null) return;
    final textos = AppLocalizations.of(context);
    if (descargado) {
      final confirmada = await showDialog<bool>(
        context: context,
        builder: (contexto) => AlertDialog(
          content: Text(textos.mapaBorrarDescargadoConfirmar),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(contexto, false),
                child: Text(textos.comunCancelar)),
            FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: Text(textos.comunBorrar)),
          ],
        ),
      );
      if (confirmada != true) return;
      await servicio.almacen.borrarDescargadas();
    } else {
      await servicio.almacen.borrarVista();
    }
    // Lo que el mapa tenga ya en memoria se quedaría a la vista.
    PaintingBinding.instance.imageCache.clear();
    await _medir();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final estiloPequeno = Theme.of(context).textTheme.bodySmall;
    final servicio = _servicio;
    return Scaffold(
      appBar: AppBar(title: Text(textos.mapaSinCobertura)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(kIsWeb || servicio == null
                ? textos.mapaSinCoberturaNoWeb
                : textos.mapaSinCoberturaExplicacion),
          ),
          if (servicio != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: FranjaDescargaMapa(),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: Text(textos.mapaDescargarFincas),
              onTap: servicio.descarga.descargando
                  ? null
                  : () => descargarMapaFincas(context),
            ),
            ListTile(
              leading: const Icon(Icons.offline_pin_outlined),
              title: Text(_tamano == null || _tamano!.teselasDescargadas == 0
                  ? textos.mapaDescargadoNada
                  : textos.mapaDescargado(_tamano!.teselasDescargadas,
                      tamanoLegible(_tamano!.bytesDescargadas))),
              trailing: IconButton(
                tooltip: textos.mapaBorrarDescargado,
                icon: const Icon(Icons.delete_outline),
                onPressed: servicio.descarga.descargando ||
                        (_tamano?.teselasDescargadas ?? 0) == 0
                    ? null
                    : () => _borrar(descargado: true),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(textos.mapaCacheVista(
                  tamanoLegible(_tamano?.bytesVista ?? 0),
                  tamanoLegible(topeBytesCacheVista))),
              trailing: IconButton(
                tooltip: textos.mapaVaciarCacheVista,
                icon: const Icon(Icons.cleaning_services_outlined),
                onPressed: (_tamano?.teselasVista ?? 0) == 0
                    ? null
                    : () => _borrar(descargado: false),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(textos.mapaCallejeroSoloVisto, style: estiloPequeno),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Text(textos.mapaAtribucionPnoa, style: estiloPequeno),
          ),
        ],
      ),
    );
  }
}
