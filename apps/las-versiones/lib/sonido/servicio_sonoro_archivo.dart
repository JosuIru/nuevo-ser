import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import 'catalogo_sonidos_archivo.dart';

/// Motor sonoro de Las Versiones. Versión corta del de Uno Roto
/// (`apps/uno-roto/lib/sonido/servicio_sonoro.dart`) porque la guía
/// sonora pide mucho menos: un ambiente en bucle, efectos de objeto
/// sueltos y fragmentos de capa que suenan **una vez** (nunca música
/// en bucle, doc 12 §1.2).
///
/// Tolera assets ausentes y entornos sin plugin (tests): si algo no se
/// puede reproducir, se calla y el juego sigue.
///
/// Singleton perezoso. [inicializar] al arrancar y
/// [cargarPreferenciasDelPerfil] tras cambiar de perfil o salir de los
/// ajustes de audio.
class ServicioSonoroArchivo {
  ServicioSonoroArchivo._();
  static final ServicioSonoroArchivo instancia = ServicioSonoroArchivo._();

  final Map<CapaAudio, int> _volumenCapa = {};
  final Set<String> _idsAusentes = <String>{};
  AudioPlayer? _reproductorAmbiente;
  AudioPlayer? _reproductorFragmento;
  String? _ambienteActual;
  bool _modoSilencio = false;
  bool _inicializado = false;
  RepositorioPreferenciasAudio? _repositorio;

  Future<void> inicializar(RepositorioPreferenciasAudio repositorio) async {
    _repositorio = repositorio;
    if (!_inicializado) {
      try {
        // Mezclar en vez de pedir el foco: si no, cada efecto pararía
        // el ambiente (lo mismo que se corrigió en Uno Roto).
        await AudioPlayer.global.setAudioContext(
            AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers)
                .build());
        _reproductorAmbiente = AudioPlayer(playerId: 'lv_ambiente')
          ..setReleaseMode(ReleaseMode.loop);
        _reproductorFragmento = AudioPlayer(playerId: 'lv_fragmento')
          ..setReleaseMode(ReleaseMode.stop);
      } catch (_) {
        // Sin plugin (tests, headless): el motor existe pero mudo.
        _reproductorAmbiente = null;
        _reproductorFragmento = null;
      }
      _inicializado = true;
    }
    await cargarPreferenciasDelPerfil();
  }

  Future<void> cargarPreferenciasDelPerfil() async {
    final repositorio = _repositorio;
    if (repositorio == null) return;
    _modoSilencio = await repositorio.cargarModoSilencio();
    for (final capa in CapaAudio.values) {
      _volumenCapa[capa] = await repositorio.cargarVolumenCapa(capa.clave,
          predeterminado: capa.volumenPredeterminado);
    }
    await _fijarVolumen(_reproductorAmbiente, CapaAudio.ambient);
    await _fijarVolumen(_reproductorFragmento, CapaAudio.musica);
  }

  /// Efecto de objeto (papel, pinza, balanza…). Cada uno con su
  /// reproductor efímero para que puedan solaparse.
  Future<void> reproducirEfecto(String identificador) async {
    final sonido = _sonidoReproducible(identificador);
    if (sonido == null) return;
    try {
      final reproductor = AudioPlayer()..setReleaseMode(ReleaseMode.release);
      late final StreamSubscription<void> suscripcion;
      suscripcion = reproductor.onPlayerComplete.listen((_) async {
        await suscripcion.cancel();
        try {
          await reproductor.dispose();
        } catch (_) {}
      });
      await reproductor.setVolume(_volumenEfectivo(sonido.capa));
      await reproductor.play(_fuente(sonido));
    } catch (error) {
      _marcarAusente(identificador, error);
    }
  }

  /// Ambiente en bucle. Si ya suena el mismo, no hace nada.
  Future<void> reproducirAmbiente(String identificador) async {
    if (_ambienteActual == identificador) return;
    final sonido = _sonidoReproducible(identificador);
    final reproductor = _reproductorAmbiente;
    if (sonido == null || reproductor == null) return;
    try {
      await reproductor.stop();
      await reproductor.setVolume(_volumenEfectivo(CapaAudio.ambient));
      await reproductor.play(_fuente(sonido));
      _ambienteActual = identificador;
    } catch (error) {
      _marcarAusente(identificador, error);
    }
  }

  Future<void> detenerAmbiente() async {
    _ambienteActual = null;
    try {
      await _reproductorAmbiente?.stop();
    } catch (_) {}
  }

  /// Fragmento musical de una capa histórica. Suena una vez; si ya
  /// sonaba otro, lo sustituye.
  Future<void> reproducirFragmentoDeCapa(String codigoCapa) async {
    final identificador = CatalogoSonidosArchivo.fragmentoDeCapa(codigoCapa);
    final sonido = _sonidoReproducible(identificador);
    final reproductor = _reproductorFragmento;
    if (sonido == null || reproductor == null) return;
    try {
      await reproductor.stop();
      await reproductor.setVolume(_volumenEfectivo(CapaAudio.musica));
      await reproductor.play(_fuente(sonido));
    } catch (error) {
      _marcarAusente(identificador, error);
    }
  }

  Future<void> detenerFragmento() async {
    try {
      await _reproductorFragmento?.stop();
    } catch (_) {}
  }

  // ─── Internos ─────────────────────────────────────────────────────

  SonidoArchivo? _sonidoReproducible(String identificador) {
    if (!_inicializado || _modoSilencio) return null;
    if (_idsAusentes.contains(identificador)) return null;
    return CatalogoSonidosArchivo.obtener(identificador);
  }

  Source _fuente(SonidoArchivo sonido) {
    const prefijo = 'assets/';
    final ruta = sonido.rutaAsset.startsWith(prefijo)
        ? sonido.rutaAsset.substring(prefijo.length)
        : sonido.rutaAsset;
    return AssetSource(ruta);
  }

  double _volumenEfectivo(CapaAudio capa) {
    if (_modoSilencio) return 0;
    return ((_volumenCapa[capa] ?? capa.volumenPredeterminado) / 100.0)
        .clamp(0.0, 1.0);
  }

  Future<void> _fijarVolumen(AudioPlayer? reproductor, CapaAudio capa) async {
    if (reproductor == null) return;
    try {
      await reproductor.setVolume(_volumenEfectivo(capa));
    } catch (_) {}
  }

  void _marcarAusente(String identificador, Object error) {
    _idsAusentes.add(identificador);
    debugPrint('[sonido] $identificador no disponible: $error');
  }
}
