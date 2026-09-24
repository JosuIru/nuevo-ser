import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/ajuste_sin_prisas.dart';
import '../datos/config_api.dart';
import '../datos/repositorio_progreso.dart';
import '../l10n/app_localizations.dart';
import '../l10n/textos_enums.dart';
import '../nucleo/paleta.dart';
import '../sonido/localizador_audio.dart';
import '../sonido/servicio_sonoro.dart';

/// Ajustes sonoros por perfil (doc 12 §Accesibilidad). Control
/// independiente de las cuatro capas + switch de modo sin sonido.
/// Los cambios se aplican en vivo y se persisten en el perfil activo.
class PantallaAjustesSonido extends StatefulWidget {
  final RepositorioProgreso repositorio;

  const PantallaAjustesSonido({super.key, required this.repositorio});

  @override
  State<PantallaAjustesSonido> createState() => _PantallaAjustesSonidoState();
}

class _PantallaAjustesSonidoState extends State<PantallaAjustesSonido> {
  final Map<CapaAudio, int> _volumenes = {};
  bool _modoSilencio = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    // Aseguramos que el motor está activo — si no, sincronizar nada
    // sirve de poco.
    await ServicioSonoro.instancia.inicializar(widget.repositorio);
    for (final capa in CapaAudio.values) {
      _volumenes[capa] = ServicioSonoro.instancia.volumenDeCapa(capa);
    }
    _modoSilencio = ServicioSonoro.instancia.modoSilencio;
    if (!mounted) return;
    setState(() => _cargando = false);
  }

  Future<void> _alCambiarVolumen(CapaAudio capa, double valor) async {
    final entero = valor.round();
    setState(() => _volumenes[capa] = entero);
    await ServicioSonoro.instancia.fijarVolumenDeCapa(
      capa,
      entero,
      widget.repositorio,
    );
  }

  Future<void> _alCambiarModoSilencio(bool silencio) async {
    setState(() => _modoSilencio = silencio);
    await ServicioSonoro.instancia.fijarModoSilencio(
      silencio,
      widget.repositorio,
    );
  }

  @override
  Widget build(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        title: Text(
          textos.sonidoTitulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 16,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: PaletaNeon.azulNeon),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _ModoSilencioTile(
                  activo: _modoSilencio,
                  alCambiar: _alCambiarModoSilencio,
                ),
                const SizedBox(height: 24),
                Text(
                  textos.sonidoSeccionVolumen,
                  style: TextStyle(
                    color: PaletaNeon.textoTenue.withOpacity(0.7),
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                for (final capa in CapaAudio.values)
                  _SliderCapa(
                    capa: capa,
                    valor: _volumenes[capa] ??
                        capa.volumenPredeterminado,
                    habilitado: !_modoSilencio,
                    alCambiar: (v) => _alCambiarVolumen(capa, v),
                  ),
                const SizedBox(height: 24),
                Text(
                  textos.ajustesSeccionMaquinas,
                  style: TextStyle(
                    color: PaletaNeon.textoTenue.withOpacity(0.7),
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: AjusteSinPrisas.activo,
                  builder: (_, activo, __) => _InterruptorTile(
                    key: const ValueKey('interruptor-sin-prisas'),
                    activo: activo,
                    titulo: textos.sinPrisasTitulo,
                    subtitulo: textos.sinPrisasSubtitulo,
                    alCambiar: AjusteSinPrisas.fijar,
                  ),
                ),
                const SizedBox(height: 24),
                _BloquePaqueteSonoro(repositorio: widget.repositorio),
                const SizedBox(height: 24),
                const _NotaAccesibilidad(),
              ],
            ),
    );
  }
}

/// Bloque que gestiona el paquete sonoro descargable. Solo los efectos
/// cortos van empaquetados en el APK; ambient + música + narrativos se
/// bajan del servidor a la cache local. Este widget muestra el estado
/// (versión instalada, tamaño en disco) y ofrece descargar / actualizar
/// / borrar.
class _BloquePaqueteSonoro extends StatefulWidget {
  final RepositorioProgreso repositorio;
  const _BloquePaqueteSonoro({required this.repositorio});

  @override
  State<_BloquePaqueteSonoro> createState() => _BloquePaqueteSonoroState();
}

class _BloquePaqueteSonoroState extends State<_BloquePaqueteSonoro> {
  late final DescargadorAudio _descargador;
  int? _versionInstalada;
  int _tamanoCacheBytes = 0;
  EstadoDescargaAudio? _estadoEnVuelo;
  StreamSubscription<EstadoDescargaAudio>? _suscripcion;

  @override
  void initState() {
    super.initState();
    _descargador = DescargadorAudio(
      urlManifest: Uri.parse(
        '${ConfigApi.urlBase}/wp-json/nuevo-ser/v1/audio/manifest',
      ),
      hostOverride: ConfigApi.hostOverride,
      userAgent: 'UnoRoto/0.5 (Android)',
      rutaBaseCache: () => LocalizadorAudio.instancia.rutaBaseCache(),
      leerVersion: () => widget.repositorio.cargarVersionPaqueteAudio(),
      escribirVersion: (v) =>
          widget.repositorio.guardarVersionPaqueteAudio(v),
      borrarVersion: () => widget.repositorio.borrarVersionPaqueteAudio(),
      invalidarLocalizador: () => LocalizadorAudio.instancia.invalidar(),
    );
    _refrescarEstadoLocal();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  Future<void> _refrescarEstadoLocal() async {
    final version = await _descargador.versionLocal();
    final bytes = await _descargador.tamanoCacheBytes();
    if (!mounted) return;
    setState(() {
      _versionInstalada = version;
      _tamanoCacheBytes = bytes;
    });
  }

  Future<void> _descargar() async {
    final textos = AppLocalizations.of(context);
    setState(() => _estadoEnVuelo = const PreparandoDescargaAudio());
    ManifestPaqueteAudio manifest;
    try {
      manifest = await _descargador.obtenerManifest();
    } catch (e) {
      if (!mounted) return;
      setState(() => _estadoEnVuelo = DescargaAudioFallida(e.toString()));
      _mostrarMensajeBreve(textos.sonidoMensajeFallido(e.toString()));
      return;
    }

    // Short-circuit: si la versión local coincide con la del servidor,
    // no rebajar todo de nuevo — solo informar "ya estás al día". Esto
    // evita el flujo destructivo (borrar cache + descomprimir) cuando
    // el usuario pulsa "Comprobar" más de una vez, que era una fuente
    // de errores reportada el 2026-05-19.
    final versionLocal = await _descargador.versionLocal();
    if (versionLocal == manifest.version) {
      if (!mounted) return;
      setState(() => _estadoEnVuelo = null);
      _mostrarMensajeBreve(
        'Ya tienes la última versión (v${manifest.version}).',
      );
      return;
    }

    // Detener loops antes de tocar archivos en cache.
    for (final capa in CapaAudio.values) {
      await ServicioSonoro.instancia.detenerCapa(capa, msFade: 200);
    }

    _suscripcion = _descargador.descargarEInstalar(manifest).listen((estado) async {
      if (!mounted) return;
      setState(() => _estadoEnVuelo = estado);
      if (estado is DescargaAudioCompletada) {
        // Los archivos ya están en cache: limpiamos los ids que
        // hubieran fallado antes de la descarga para que el motor
        // los vuelva a intentar al próximo play.
        await ServicioSonoro.instancia.reintentarSonidosAusentes();
        _refrescarEstadoLocal();
        _mostrarMensajeBreve(textos.sonidoMensajeInstalado);
      } else if (estado is DescargaAudioFallida) {
        _mostrarMensajeBreve(textos.sonidoMensajeFallido(estado.mensaje));
      }
    });
  }

  Future<void> _borrarCache() async {
    final textos = AppLocalizations.of(context);
    final confirmar = await _confirmar(
      textos.sonidoPaqueteConfirmTitulo,
      textos.sonidoPaqueteConfirmTexto(
        _formatearTamano(_tamanoCacheBytes),
      ),
      confirmTexto: textos.sonidoPaqueteConfirmBotonBorrar,
    );
    if (confirmar != true) return;
    for (final capa in CapaAudio.values) {
      await ServicioSonoro.instancia.detenerCapa(capa, msFade: 200);
    }
    await _descargador.borrarCache();
    if (!mounted) return;
    setState(() => _estadoEnVuelo = null);
    _refrescarEstadoLocal();
    _mostrarMensajeBreve(textos.sonidoMensajeBorrado);
  }

  Future<bool?> _confirmar(
    String titulo,
    String texto, {
    required String confirmTexto,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PaletaNeon.fondoMedio,
        title: Text(titulo,
            style: const TextStyle(color: PaletaNeon.textoPrincipal)),
        content: Text(texto,
            style: const TextStyle(color: PaletaNeon.textoTenue)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx).sonidoBotonCancelar),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: PaletaNeon.azulNeon),
            child: Text(confirmTexto),
          ),
        ],
      ),
    );
  }

  void _mostrarMensajeBreve(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _formatearTamano(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext contexto) {
    final estado = _estadoEnVuelo;
    final descargaEnCurso = estado is DescargandoAudio ||
        estado is VerificandoAudio ||
        estado is DescomprimiendoAudio ||
        estado is PreparandoDescargaAudio;

    final textos = AppLocalizations.of(contexto);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: PaletaNeon.violetaBase.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textos.sonidoPaqueteTitulo,
            style: const TextStyle(
              color: PaletaNeon.textoTenue,
              fontSize: 11,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _versionInstalada == null
                ? textos.sonidoPaqueteNoInstalado
                : textos.sonidoPaqueteVersion(
                    _versionInstalada!,
                    _formatearTamano(_tamanoCacheBytes),
                  ),
            style: const TextStyle(
              color: PaletaNeon.textoPrincipal,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            textos.sonidoPaqueteExplicacion,
            style: TextStyle(
              color: PaletaNeon.textoTenue.withOpacity(0.7),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (descargaEnCurso) _ProgresoDescarga(estado: estado!),
          if (!descargaEnCurso) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _descargar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PaletaNeon.azulNeon.withOpacity(0.85),
                    foregroundColor: PaletaNeon.fondoProfundo,
                  ),
                  child: Text(_versionInstalada == null
                      ? textos.sonidoPaqueteBotonDescargar
                      : textos.sonidoPaqueteBotonComprobar),
                ),
                if (_versionInstalada != null)
                  TextButton(
                    onPressed: _borrarCache,
                    style: TextButton.styleFrom(
                      foregroundColor: PaletaNeon.textoTenue,
                    ),
                    child: Text(textos.sonidoPaqueteBotonBorrar),
                  ),
              ],
            ),
            if (estado is DescargaAudioFallida)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  estado.mensaje,
                  style: TextStyle(
                    color: PaletaNeon.rojoOxidado.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ),
            if (estado is DescargaAudioCompletada)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '✓ ${estado.archivosInstalados} archivos · versión ${estado.version}',
                  style: TextStyle(
                    color: PaletaNeon.exitoSuave.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProgresoDescarga extends StatelessWidget {
  final EstadoDescargaAudio estado;
  const _ProgresoDescarga({required this.estado});

  @override
  Widget build(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    String texto;
    double? fraccion;
    final estadoActual = estado;
    if (estadoActual is PreparandoDescargaAudio) {
      texto = textos.sonidoDescargaConectando;
      fraccion = null;
    } else if (estadoActual is DescargandoAudio) {
      final mb = (estadoActual.recibidoBytes / (1024 * 1024))
          .toStringAsFixed(1);
      final total = estadoActual.totalBytes / (1024 * 1024);
      texto = total > 0
          ? textos.sonidoDescargaBajandoConTotal(
              mb,
              total.toStringAsFixed(1),
            )
          : textos.sonidoDescargaBajandoSinTotal(mb);
      fraccion = estadoActual.fraccion >= 0 ? estadoActual.fraccion : null;
    } else if (estadoActual is VerificandoAudio) {
      texto = textos.sonidoDescargaVerificando;
      fraccion = null;
    } else if (estadoActual is DescomprimiendoAudio) {
      texto = textos.sonidoDescargaInstalando(
        estadoActual.archivoActual,
        estadoActual.archivosTotal,
      );
      fraccion = estadoActual.archivosTotal > 0
          ? estadoActual.archivoActual / estadoActual.archivosTotal
          : null;
    } else {
      texto = '';
      fraccion = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          texto,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: fraccion,
          backgroundColor: PaletaNeon.violetaBase.withOpacity(0.3),
          color: PaletaNeon.azulNeon,
          minHeight: 4,
        ),
      ],
    );
  }
}

class _ModoSilencioTile extends StatelessWidget {
  final bool activo;
  final ValueChanged<bool> alCambiar;

  const _ModoSilencioTile({required this.activo, required this.alCambiar});

  @override
  Widget build(BuildContext contexto) => _InterruptorTile(
        activo: activo,
        titulo: AppLocalizations.of(contexto).sonidoModoSilencioTitulo,
        subtitulo: AppLocalizations.of(contexto).sonidoModoSilencioSubtitulo,
        alCambiar: alCambiar,
      );
}

/// Un interruptor con título y explicación, en su tarjeta.
class _InterruptorTile extends StatelessWidget {
  final bool activo;
  final String titulo;
  final String subtitulo;
  final ValueChanged<bool> alCambiar;

  const _InterruptorTile({
    super.key,
    required this.activo,
    required this.titulo,
    required this.subtitulo,
    required this.alCambiar,
  });


  @override
  Widget build(BuildContext contexto) {
    return Container(
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: activo
              ? PaletaNeon.azulNeon.withOpacity(0.7)
              : PaletaNeon.violetaBase.withOpacity(0.5),
        ),
      ),
      child: SwitchListTile(
        value: activo,
        onChanged: alCambiar,
        activeColor: PaletaNeon.azulNeon,
        title: Text(
          titulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 14,
            letterSpacing: 0.6,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(
            color: PaletaNeon.textoTenue.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _SliderCapa extends StatelessWidget {
  final CapaAudio capa;
  final int valor;
  final bool habilitado;
  final ValueChanged<double> alCambiar;

  const _SliderCapa({
    required this.capa,
    required this.valor,
    required this.habilitado,
    required this.alCambiar,
  });

  String _descripcionCapa(CapaAudio capa, AppLocalizations textos) {
    switch (capa) {
      case CapaAudio.ambient:
        return textos.sonidoCapaAmbient;
      case CapaAudio.musica:
        return textos.sonidoCapaMusica;
      case CapaAudio.efectos:
        return textos.sonidoCapaEfectos;
      case CapaAudio.narrativos:
        return textos.sonidoCapaNarrativos;
    }
  }

  @override
  Widget build(BuildContext contexto) {
    final textos = AppLocalizations.of(contexto);
    return Opacity(
      opacity: habilitado ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  capa.nombreLocalizado(textos),
                  style: const TextStyle(
                    color: PaletaNeon.textoPrincipal,
                    fontSize: 13,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Text(
                  '$valor%',
                  style: TextStyle(
                    color: PaletaNeon.textoTenue.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              _descripcionCapa(capa, textos),
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.6),
                fontSize: 10,
                letterSpacing: 0.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(contexto).copyWith(
                activeTrackColor: PaletaNeon.violetaNeon,
                inactiveTrackColor:
                    PaletaNeon.violetaBase.withOpacity(0.3),
                thumbColor: PaletaNeon.azulNeon,
                overlayColor: PaletaNeon.violetaNeon.withOpacity(0.2),
              ),
              child: Slider(
                value: valor.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: habilitado ? alCambiar : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotaAccesibilidad extends StatelessWidget {
  const _NotaAccesibilidad();

  @override
  Widget build(BuildContext contexto) {
    return Text(
      AppLocalizations.of(contexto).sonidoNotaAccesibilidad,
      style: TextStyle(
        color: PaletaNeon.textoTenue.withOpacity(0.6),
        fontSize: 11,
        height: 1.4,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
