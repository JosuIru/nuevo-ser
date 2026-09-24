import 'package:flutter/material.dart';

import 'banner_actualizacion.dart';
import 'checker_actualizaciones.dart';
import 'instalador_actualizacion.dart';

/// Traduce un texto en castellano al idioma de la app. Por defecto, lo
/// deja igual. Las apps con euskera o catalán pasan el suyo.
typedef TraductorActualizaciones = String Function(String textoEs);

String _sinTraducir(String texto) => texto;

/// Pantalla «Actualizaciones»: qué versión hay instalada, cuál es la
/// última publicada, cuándo salió y qué trae, con un botón para buscar
/// ahora y otro para descargar e instalar sin salir de la app.
class PantallaEstadoActualizaciones extends StatefulWidget {
  final ConfigActualizaciones config;
  final String nombreApp;
  final TraductorActualizaciones traducir;

  /// Para los tests: sustituye la consulta a GitHub.
  final Future<EstadoActualizaciones> Function()? consultar;

  const PantallaEstadoActualizaciones({
    super.key,
    required this.config,
    required this.nombreApp,
    this.traducir = _sinTraducir,
    this.consultar,
  });

  @override
  State<PantallaEstadoActualizaciones> createState() => _PantallaEstadoActualizacionesState();
}

class _PantallaEstadoActualizacionesState extends State<PantallaEstadoActualizaciones> {
  EstadoActualizaciones? _estado;
  bool _buscando = false;
  double? _progreso;
  String? _mensaje;

  String _t(String texto) => widget.traducir(texto);

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() {
      _buscando = true;
      _mensaje = null;
    });
    final estado = await (widget.consultar?.call() ?? consultarEstadoActualizaciones(widget.config));
    if (!mounted) return;
    // Lo consultado a mano también refresca el aviso del arranque.
    if (!estado.sinConexion) await limpiarCacheActualizaciones(widget.config);
    if (!mounted) return;
    setState(() {
      _estado = estado;
      _buscando = false;
    });
  }

  Future<void> _instalar(String url) async {
    setState(() {
      _progreso = 0;
      _mensaje = null;
    });
    final resultado = await instalarActualizacion(url, alProgresar: (valor) {
      if (mounted) setState(() => _progreso = valor);
    });
    if (!mounted) return;
    setState(() {
      _progreso = null;
      _mensaje = switch (resultado) {
        ResultadoInstalacion.instaladorAbierto =>
          _t('Se ha abierto el instalador. Confirma la actualización y vuelve a abrir la app.'),
        ResultadoInstalacion.enlaceAbierto => _t('Se ha abierto la descarga en el navegador.'),
        ResultadoInstalacion.errorDescarga => _t('No se ha podido descargar. Comprueba la conexión y vuelve a probar.'),
        ResultadoInstalacion.errorInstalador => _t(
            'Descargada, pero Android no ha dejado abrir el instalador. Permite «instalar apps desconocidas» para esta app en los ajustes del móvil.'),
      };
    });
  }

  String _fecha(int? milisegundos) {
    if (milisegundos == null) return '—';
    final fecha = DateTime.fromMillisecondsSinceEpoch(milisegundos);
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
  }

  @override
  Widget build(BuildContext contexto) {
    final tema = Theme.of(contexto);
    final estado = _estado;
    return Scaffold(
      appBar: AppBar(title: Text(_t('Actualizaciones'))),
      // SafeArea: que la barra de navegación del móvil no tape los botones.
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(widget.nombreApp, style: tema.textTheme.titleLarge),
            const SizedBox(height: 16),
            _Fila(etiqueta: _t('Versión instalada'), valor: estado?.versionInstalada ?? '…'),
            _Fila(
              etiqueta: _t('Última publicada'),
              valor: estado == null
                  ? '…'
                  : estado.sinConexion
                      ? _t('sin conexión')
                      : estado.versionPublicada ?? _t('ninguna todavía'),
            ),
            if (estado?.publicadoMs != null) _Fila(etiqueta: _t('Publicada el'), valor: _fecha(estado!.publicadoMs)),
            if (estado != null) _Fila(etiqueta: _t('Comprobado el'), valor: _fecha(estado.comprobadoMs)),
            const SizedBox(height: 20),
            if (estado != null && !estado.sinConexion)
              Container(
                key: const ValueKey('estado-actualizaciones'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      (estado.hayNueva ? tema.colorScheme.primary : tema.colorScheme.secondary).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(estado.hayNueva ? Icons.system_update : Icons.check_circle_outline,
                        color: estado.hayNueva ? tema.colorScheme.primary : tema.colorScheme.secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(estado.hayNueva ? _t('Hay una versión nueva.') : _t('Tienes la última versión.')),
                    ),
                  ],
                ),
              ),
            if (estado != null && estado.hayNueva && estado.notas.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(_t('Qué trae'), style: tema.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(estado.notas),
            ],
            const SizedBox(height: 24),
            if (_progreso != null) ...[
              LinearProgressIndicator(value: _progreso! < 0 ? null : _progreso),
              const SizedBox(height: 8),
              Text(_progreso! < 0 ? _t('Descargando…') : '${_t('Descargando…')} ${(_progreso! * 100).round()} %'),
              const SizedBox(height: 16),
            ],
            if (estado != null && estado.hayNueva && _progreso == null)
              FilledButton.icon(
                key: const ValueKey('boton-instalar-actualizacion'),
                icon: const Icon(Icons.download),
                label: Text('${_t('Descargar e instalar')} ${estado.versionPublicada}'),
                onPressed: () => _instalar(estado.urlAsset!),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const ValueKey('boton-buscar-actualizacion'),
              icon: _buscando
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.refresh),
              label: Text(_t('Buscar ahora')),
              onPressed: _buscando || _progreso != null ? null : _buscar,
            ),
            if (_mensaje != null) ...[
              const SizedBox(height: 16),
              Text(_mensaje!, key: const ValueKey('mensaje-actualizacion')),
            ],
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Fila({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext contexto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(etiqueta)),
            Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Aviso para la pantalla de inicio de cada app: comprueba al arrancar
/// (con la caché de 24 h) y, si hay versión nueva, enseña el banner. Al
/// tocarlo abre [PantallaEstadoActualizaciones]. Si no hay nada, no ocupa
/// sitio.
class AvisoActualizaciones extends StatefulWidget {
  final ConfigActualizaciones config;
  final String nombreApp;
  final TraductorActualizaciones traducir;
  final bool compacto;
  final EdgeInsetsGeometry margen;

  const AvisoActualizaciones({
    super.key,
    required this.config,
    required this.nombreApp,
    this.traducir = _sinTraducir,
    this.compacto = true,
    this.margen = const EdgeInsets.fromLTRB(12, 8, 12, 0),
  });

  @override
  State<AvisoActualizaciones> createState() => _AvisoActualizacionesState();
}

class _AvisoActualizacionesState extends State<AvisoActualizaciones> {
  ActualizacionDisponible? _disponible;
  bool _descartado = false;

  @override
  void initState() {
    super.initState();
    _comprobar();
  }

  Future<void> _comprobar() async {
    try {
      final disponible = await comprobarActualizacionDisponible(widget.config);
      if (mounted) setState(() => _disponible = disponible);
    } catch (_) {
      // Sin plugins (tests) o sin red: no hay aviso, sin más.
    }
  }

  Future<void> _abrirEstado() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PantallaEstadoActualizaciones(
        config: widget.config,
        nombreApp: widget.nombreApp,
        traducir: widget.traducir,
      ),
    ));
    await _comprobar();
  }

  @override
  Widget build(BuildContext contexto) {
    final disponible = _disponible;
    if (disponible == null || _descartado) return const SizedBox.shrink();
    return Padding(
      padding: widget.margen,
      child: BannerActualizacionDisponible(
        actualizacion: disponible,
        compacto: widget.compacto,
        alTocar: _abrirEstado,
        traducir: widget.traducir,
        onDescartar: () => setState(() => _descartado = true),
      ),
    );
  }
}
