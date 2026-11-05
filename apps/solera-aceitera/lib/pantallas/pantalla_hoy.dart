import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/lote_aceite.dart';
import 'pantalla_campanias.dart';
import 'pantalla_ficha_lote.dart';
import 'pantalla_lista_lotes.dart';
import 'widgets/banner_catalogos_provisionales.dart';
import 'widgets/tarjeta_resumen_meteo.dart';
import '../utiles/textos_visibles.dart';

/// Dashboard de "hoy". Muestra el estado de la campaña activa, el
/// número de lotes y de parcelas, y los últimos lotes creados.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');

  Campania? _campaniaActiva;
  List<LoteAceite> _ultimosLotes = const [];
  int _conteoLotes = 0;
  int _conteoParcelas = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final campanias = await bd.listarCampanias();
    final activa =
        campanias.where((c) => c.estaAbierta).cast<Campania?>().firstWhere(
              (_) => true,
              orElse: () => null,
            );
    final lotes = await bd.listarLotesAceite();
    final parcelas = await bd.listarParcelas();
    if (!mounted) return;
    setState(() {
      _campaniaActiva = activa;
      _ultimosLotes = lotes.take(5).toList(growable: false);
      _conteoLotes = lotes.length;
      _conteoParcelas = parcelas.length;
    });
  }

  /// Abre una pantalla encima y, al volver, recarga el resumen.
  Future<void> _abrir(WidgetBuilder construirPantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: construirPantalla));
    if (mounted) await _cargar();
  }

  /// Fecha de hoy en el idioma de la app, con mayúscula inicial
  /// («Jueves, 5 de noviembre»).
  String get _fechaDeHoy {
    final localeFechas =
        SoleraL10n.idioma == 'es' ? 'es_ES' : SoleraL10n.idioma;
    final texto = DateFormat.MMMMEEEEd(localeFechas).format(DateTime.now());
    return texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colores = context.coloresSolera;
    final campania = _campaniaActiva;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargar,
        edgeOffset: MediaQuery.paddingOf(context).top,
        child: ListView(
          padding:
              rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
          children: [
            CabeceraHoySolera(
              titulo: SoleraL10n.t('acei.hoy'),
              fecha: _fechaDeHoy,
              cifras: [
                CifraCabecera(
                  valor: campania == null
                      ? '—'
                      : formatearNumero(campania.rendimientoMedioPorcentaje,
                          decimales: 1),
                  etiqueta: SoleraL10n.t('acei.rendimiento_medio_porcentaje'),
                  detalle: campania == null
                      ? null
                      : SoleraL10n.tf('acei.campania_anyos', {
                          'inicio': campania.anyoComercial,
                          'fin': campania.anyoComercial + 1,
                        }),
                ),
                CifraCabecera(
                  valor: '$_conteoLotes',
                  etiqueta: SoleraL10n.t('acei.lotes'),
                ),
                CifraCabecera(
                  valor: '$_conteoParcelas',
                  etiqueta: SoleraL10n.t('acei.parcelas'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Aviso de versión nueva: si no la hay, no ocupa sitio.
                  AvisoActualizaciones(
                    config: configActualizacionesMonorepo('solera-aceitera'),
                    nombreApp: 'Larrea Aceitera',
                    margen: const EdgeInsets.only(bottom: 4),
                  ),
                  const BannerCatalogosProvisionales(),
                  const TarjetaResumenMeteo(),
                  TituloBloqueSolera(SoleraL10n.t('acei.campania')),
                  _TarjetaCampania(
                    campania: campania,
                    formatoFecha: _formatoFecha,
                    alPulsar: () => _abrir((_) => const PantallaCampanias()),
                  ),
                  TituloBloqueSolera(SoleraL10n.t('acei.ultimos_lotes')),
                  if (_ultimosLotes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(children: [
                        Icon(Icons.task_alt, size: 40, color: colores.hecho),
                        const SizedBox(height: 8),
                        Text(SoleraL10n.t('acei.hoy_sin_lotes'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ]),
                    )
                  else ...[
                    Card(
                      child: Column(children: [
                        for (final lote in _ultimosLotes)
                          ListTile(
                            title: Text(lote.identificadorLote),
                            subtitle: Text(
                              '${formatearNumero(lote.kgNetos, decimales: 0)} kg · ${nombreCategoriaAceite(lote.categoria)}',
                            ),
                            trailing: Text(
                                _formatoFecha.format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        lote.fechaCreacionMs)),
                                style: theme.textTheme.bodySmall),
                            onTap: () =>
                                _abrir((_) => PantallaFichaLote(lote: lote)),
                          ),
                      ]),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            _abrir((_) => const PantallaListaLotes()),
                        child: Text(SoleraL10n.t('acei.ver_todos')),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaCampania extends StatelessWidget {
  final Campania? campania;
  final DateFormat formatoFecha;
  final VoidCallback alPulsar;

  const _TarjetaCampania({
    required this.campania,
    required this.formatoFecha,
    required this.alPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final colorIcono = Theme.of(context).colorScheme.primary;
    final campaniaActiva = campania;
    if (campaniaActiva == null) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.calendar_today,
              color: context.coloresSolera.pendiente),
          title: Text(SoleraL10n.t('acei.sin_campania_abierta')),
          subtitle: Text(SoleraL10n.t('acei.sin_campania_abierta_ayuda')),
          trailing: const Icon(Icons.chevron_right),
          onTap: alPulsar,
        ),
      );
    }
    // El rendimiento medio ya va en la cabecera: aquí solo años e inicio.
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_fire_department, color: colorIcono),
        title: Text(SoleraL10n.tf('acei.campania_anyos', {
          'inicio': campaniaActiva.anyoComercial,
          'fin': campaniaActiva.anyoComercial + 1,
        })),
        subtitle: Text(SoleraL10n.tf('acei.inicio_fecha', {
          'fecha': formatoFecha.format(
              DateTime.fromMillisecondsSinceEpoch(campaniaActiva.fechaInicioMs)),
        })),
        trailing: const Icon(Icons.chevron_right),
        onTap: alPulsar,
      ),
    );
  }
}
