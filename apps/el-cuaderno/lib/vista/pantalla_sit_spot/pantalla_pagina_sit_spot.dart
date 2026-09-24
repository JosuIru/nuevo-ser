import 'package:flutter/material.dart';

import '../../datos/almacenador_medios.dart';
import '../../dominio/observacion.dart';
import '../../dominio/repositorio_local.dart';
import '../../dominio/resumen_mes_sit_spot.dart';
import '../../dominio/sit_spot.dart';
import '../../nucleo/i18n/generado/textos_app.dart';
import '../tema/colores.dart';
import '../tema/tipografia.dart';
import 'bloque_paleta_del_lugar.dart';
import 'pantalla_comparar_visitas.dart';

/// Página del sit spot activo. Hermana de `PantallaPaginaSitSpotJubilado`
/// pero con dos diferencias estructurales:
///
/// - La cabecera dice "Activo desde DD/MM/YYYY" en lugar de "Estuvo
///   activo del DD/MM al DD/MM" (no hay fecha de jubilación todavía).
/// - Hay un botón "anotar observación aquí" que abre el flujo de nueva
///   observación con el sit spot activo ya preseleccionado (lo hace el
///   home porque `PantallaObservacion` recibe `sitSpotActivo` y lo
///   ancla automáticamente). El botón no está en la jubilada porque doc
///   13 §2.6 prohíbe registrar observaciones contra un sit spot ya
///   retirado.
///
/// El listado de observaciones lo lee del repositorio cada vez que se
/// monta (y al volver del callback de nueva observación).
class PantallaPaginaSitSpot extends StatefulWidget {
  const PantallaPaginaSitSpot({
    super.key,
    required this.repositorio,
    required this.sitSpot,
    this.alAbrirNuevaObservacion,
    this.proveedorAhora,
    this.almacenadorMedios,
    this.extractorColores,
  });

  final RepositorioLocal repositorio;
  final SitSpot sitSpot;

  /// Closure que el home cabla a `_abrirObservacion(null)` — la
  /// observación quedará anclada al sit spot por la lógica de
  /// `PantallaObservacion` que ya recibe `sitSpotActivo`. Si es null,
  /// el botón no se monta.
  final Future<void> Function()? alAbrirNuevaObservacion;

  /// Proveedor de la fecha "ahora" para calcular el bloque "Este mes
  /// aquí". Default `DateTime.now`. Inyectable para tests deterministas
  /// — si no se inyecta y la suite corre en otro mes que el de los
  /// datos, el bloque del resumen no se mostraría aunque hubiera
  /// observaciones (por diseño: filtra al mes calendárico en curso).
  final DateTime Function()? proveedorAhora;

  /// Para leer las fotos del sit spot y pintar «los colores de este
  /// sitio». Si es null, el bloque no aparece.
  final AlmacenadorMedios? almacenadorMedios;

  /// Extractor de colores inyectable para tests (sin decodificar
  /// imágenes). Por defecto, [extraerColoresDeFoto].
  final ExtractorColores? extractorColores;

  @override
  State<PantallaPaginaSitSpot> createState() => _EstadoPantallaPaginaSitSpot();
}

class _EstadoPantallaPaginaSitSpot extends State<PantallaPaginaSitSpot> {
  List<Observacion> _observaciones = const [];
  ResumenMesSitSpot _resumenMes = const ResumenMesSitSpot(
    visitas: 0,
    primera: null,
    ultima: null,
  );
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await widget.repositorio
        .obtenerObservaciones(sitSpotId: widget.sitSpot.id);
    if (!mounted) return;
    final ahora = (widget.proveedorAhora ?? DateTime.now)();
    setState(() {
      _observaciones = lista;
      _resumenMes = ResumenMesSitSpot.calcular(
        observaciones: lista,
        sitSpotId: widget.sitSpot.id,
        ahora: ahora,
      );
      _cargando = false;
    });
  }

  Future<void> _anotar() async {
    final cb = widget.alAbrirNuevaObservacion;
    if (cb == null) return;
    await cb();
    if (mounted) await _cargar();
  }

  Future<void> _abrirComparador() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PantallaCompararVisitas(
          repositorio: widget.repositorio,
          sitSpot: widget.sitSpot,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.sitSpot.nombre)),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator.adaptive())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _CabeceraSitSpotActivo(
                    sitSpot: widget.sitSpot,
                    esquema: esquema,
                  ),
                  // Bloque "Este mes aquí" — sólo se monta a partir de
                  // dos visitas. Con una visita sola, articular
                  // "primera" y "última" es vacío; con cero, el bloque
                  // sería ruido.
                  if (_resumenMes.visitas >= 2) ...[
                    const SizedBox(height: 16),
                    _BloqueResumenMes(
                      resumen: _resumenMes,
                      textos: textos,
                      esquema: esquema,
                    ),
                  ],
                  if (widget.almacenadorMedios != null &&
                      _observaciones.any((o) => o.fotoRutaLocal != null)) ...[
                    const SizedBox(height: 20),
                    BloquePaletaDelLugar(
                      observaciones: _observaciones,
                      almacenadorMedios: widget.almacenadorMedios!,
                      extractor: widget.extractorColores ?? extraerColoresDeFoto,
                    ),
                  ],
                  if (widget.alAbrirNuevaObservacion != null) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _anotar,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(textos.paginaSitSpotBotonAnotar),
                      ),
                    ),
                  ],
                  // El botón del comparador se monta a partir de la
                  // segunda observación. Antes no tiene sentido
                  // ofrecerlo: comparar uno consigo mismo es vacío.
                  // El sit spot recién creado no lleva al niño a un
                  // botón gris desactivado, sino a un cuaderno
                  // limpio.
                  if (_observaciones.length >= 2) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _abrirComparador,
                        icon: const Icon(Icons.compare_arrows_outlined),
                        label: Text(textos.compararVisitasEnlace),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    _observaciones.isEmpty
                        ? textos.paginaSitSpotLoQueAnotaste
                        : _contadorEtiqueta(textos, _observaciones.length),
                    style: TipografiaCuaderno.sans(
                      color: esquema.tertiary,
                      tamano: TipografiaCuaderno.tamano12,
                      peso: TipografiaCuaderno.pesoMedio,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_observaciones.isEmpty)
                    Text(
                      textos.paginaSitSpotVacio,
                      style: TipografiaCuaderno.serif(
                        color: PaletaCuaderno.tintaTenue,
                        tamano: TipografiaCuaderno.tamano13,
                        altoLinea: 1.5,
                      ),
                    )
                  else
                    for (final obs in _observaciones) ...[
                      _TarjetaObservacionLectura(
                        observacion: obs,
                        textos: textos,
                        esquema: esquema,
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
      ),
    );
  }

  static String _contadorEtiqueta(TextosApp textos, int n) =>
      n == 1
          ? textos.sitSpotJubiladoUnaObservacion
          : textos.sitSpotJubiladoVariasObservaciones(n);
}

class _CabeceraSitSpotActivo extends StatelessWidget {
  const _CabeceraSitSpotActivo({required this.sitSpot, required this.esquema});

  final SitSpot sitSpot;
  final ColorScheme esquema;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: esquema.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sitSpot.nombre,
            style: TipografiaCuaderno.serif(
              color: esquema.onSurface,
              tamano: TipografiaCuaderno.tamano17,
              peso: TipografiaCuaderno.pesoMedio,
            ),
          ),
          if (sitSpot.dondeNombre.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              sitSpot.dondeNombre,
              style: TipografiaCuaderno.serif(
                color: PaletaCuaderno.tintaTenue,
                tamano: TipografiaCuaderno.tamano13,
                altoLinea: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            TextosApp.of(context)
                .paginaSitSpotActivoDesde(_formatearFecha(sitSpot.creadoEn)),
            style: TipografiaCuaderno.sans(
              color: esquema.tertiary,
              tamano: TipografiaCuaderno.tamano12,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatearFecha(DateTime cuando) {
    final dd = cuando.day.toString().padLeft(2, '0');
    final mm = cuando.month.toString().padLeft(2, '0');
    return '$dd/$mm/${cuando.year}';
  }
}

/// Bloque "Este mes aquí" — resumen cualitativo del mes en curso para
/// el sit spot activo. Cabecera sans gris ceniza + dos líneas serif
/// con el conteo plural y la pareja primera/última visita. Sin barras,
/// sin contadores duros: el oficio del lugar narrado en frases cortas.
class _BloqueResumenMes extends StatelessWidget {
  const _BloqueResumenMes({
    required this.resumen,
    required this.textos,
    required this.esquema,
  });

  final ResumenMesSitSpot resumen;
  final TextosApp textos;
  final ColorScheme esquema;

  @override
  Widget build(BuildContext context) {
    final primera = resumen.primera!;
    final ultima = resumen.ultima!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esquema.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: esquema.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textos.paginaSitSpotResumenMesCabecera,
            style: TipografiaCuaderno.sans(
              color: esquema.tertiary,
              tamano: TipografiaCuaderno.tamano12,
              peso: TipografiaCuaderno.pesoMedio,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            textos.paginaSitSpotResumenMesVisitas(resumen.visitas),
            style: TipografiaCuaderno.serif(
              color: esquema.onSurface,
              tamano: TipografiaCuaderno.tamano14,
              altoLinea: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            textos.paginaSitSpotResumenMesPrimeraUltima(
              _formatearFechaCorta(primera.cuandoOcurrio),
              _formatearFechaCorta(ultima.cuandoOcurrio),
            ),
            style: TipografiaCuaderno.serif(
              color: PaletaCuaderno.tintaTenue,
              tamano: TipografiaCuaderno.tamano13,
              altoLinea: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Formato corto DD/MM (sin año) — el bloque ya está acotado al mes
  /// en curso, repetir el año dilataría la frase. Si el operador
  /// alguna vez quiere mostrar el resumen del mes anterior, este
  /// helper crece a DD/MM/YYYY sin dolor.
  static String _formatearFechaCorta(DateTime cuando) {
    final dd = cuando.day.toString().padLeft(2, '0');
    final mm = cuando.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}

class _TarjetaObservacionLectura extends StatelessWidget {
  const _TarjetaObservacionLectura({
    required this.observacion,
    required this.textos,
    required this.esquema,
  });

  final Observacion observacion;
  final TextosApp textos;
  final ColorScheme esquema;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esquema.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: esquema.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatearFecha(observacion.cuandoOcurrio),
            style: TipografiaCuaderno.sans(
              color: esquema.tertiary,
              tamano: TipografiaCuaderno.tamano12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            observacion.queVio,
            style: TipografiaCuaderno.serif(
              color: esquema.onSurface,
              tamano: TipografiaCuaderno.tamano14,
              altoLinea: 1.5,
            ),
          ),
          if (observacion.creesQueEs != null &&
              observacion.creesQueEs!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${observacion.creesQueEs} · '
              '${observacion.confianza.toLocaleLabel(textos.localeName)}',
              style: TipografiaCuaderno.sans(
                color: esquema.tertiary,
                tamano: TipografiaCuaderno.tamano12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatearFecha(DateTime cuando) {
    final dd = cuando.day.toString().padLeft(2, '0');
    final mm = cuando.month.toString().padLeft(2, '0');
    return '$dd/$mm/${cuando.year}';
  }
}
