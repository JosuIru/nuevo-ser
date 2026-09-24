import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/repositorio_progreso.dart';
import 'catalogo_sonidos.dart';
import 'localizador_audio.dart';

/// Motor sonoro central. Gestiona un AudioPlayer por capa (ambient,
/// música, efectos, narrativos) con volumen independiente y fades
/// amables para transiciones. Tolera assets ausentes: si el archivo
/// catalogado no existe todavía, la llamada es un no-op silencioso y
/// la app sigue funcionando. Esto permite integrar llamadas sonoras
/// en el código antes de tener los WAVs definitivos (doc 12).
///
/// Singleton perezoso. Llamar [inicializar] una sola vez al arrancar
/// la app con el [RepositorioProgreso] para cargar preferencias del
/// perfil activo. Tras [cambiarDePerfil] hay que volver a cargar las
/// preferencias del nuevo perfil.
class ServicioSonoro {
  ServicioSonoro._();
  static final ServicioSonoro instancia = ServicioSonoro._();

  final Map<CapaAudio, AudioPlayer> _reproductores = {};
  final Map<CapaAudio, int> _volumenCapa = {};
  final Map<CapaAudio, String?> _pistaActual = {};
  final Map<CapaAudio, Timer?> _fadesActivos = {};

  /// Quien espera el fundido en curso de cada capa: al cancelarlo hay
  /// que soltarlo, o se queda colgado para siempre.
  final Map<CapaAudio, Completer<void>> _esperasDeFade = {};

  /// Turno de cada capa: sube con cada reproducir/detener. Tras un
  /// fundido, sólo actúa quien sigue teniendo el turno (si mientras se
  /// apagaba la música entró otra, no se para la nueva).
  final Map<CapaAudio, int> _turno = {};
  final Set<String> _idsAusentes = <String>{};

  bool _modoSilencio = false;
  bool _ducking = false;
  bool _inicializado = false;

  Future<void> inicializar(RepositorioProgreso repositorio) async {
    if (_inicializado) {
      await cargarPreferenciasDelPerfil(repositorio);
      return;
    }
    // Contexto global "mezclar": ningún reproductor pide el foco de audio
    // de Android. Si lo pidieran (lo que hace audioplayers por defecto),
    // cada efecto le quitaría el foco a la música y la pararía: la música
    // de las máquinas sonaba hasta el primer "tap".
    try {
      await AudioPlayer.global.setAudioContext(
          AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build());
    } catch (_) {
      // Sin plugin (tests) o plataforma sin contexto: seguimos igual.
    }
    // En entornos sin plugin de audio (tests widget, headless CI) la
    // creación del AudioPlayer o el `setReleaseMode` inicial levantan
    // MissingPluginException. Tolerarlo: los reproductores quedan sin
    // crear para esa capa y cualquier llamada posterior (`reproducirX`)
    // devuelve sin hacer nada.
    for (final capa in CapaAudio.values) {
      try {
        final player = AudioPlayer(playerId: 'capa_${capa.clave}');
        await player.setReleaseMode(ReleaseMode.stop);
        _reproductores[capa] = player;
      } on MissingPluginException {
        // Sin plugin registrado — el motor sigue existiendo pero mudo.
      } on PlatformException {
        // El canal responde con error — no creamos player para esa capa.
      } catch (_) {
        // Cualquier otro fallo al arrancar la capa lo tragamos: la app
        // nunca debe dejar de funcionar por no poder sonar.
      }
      _volumenCapa[capa] = capa.volumenPredeterminado;
      _pistaActual[capa] = null;
    }
    await cargarPreferenciasDelPerfil(repositorio);
    _inicializado = true;
  }

  Future<void> cargarPreferenciasDelPerfil(
      RepositorioProgreso repositorio) async {
    _modoSilencio = await repositorio.cargarAudioModoSilencio();
    for (final capa in CapaAudio.values) {
      _volumenCapa[capa] = await repositorio.cargarAudioVolumenCapa(
        capa.clave,
        predeterminado: capa.volumenPredeterminado,
      );
    }
    await _aplicarVolumenesVigentes();
  }

  bool get modoSilencio => _modoSilencio;

  int volumenDeCapa(CapaAudio capa) =>
      _volumenCapa[capa] ?? capa.volumenPredeterminado;

  Future<void> fijarVolumenDeCapa(
    CapaAudio capa,
    int nuevoValor0a100,
    RepositorioProgreso repositorio,
  ) async {
    final acotado = nuevoValor0a100.clamp(0, 100);
    _volumenCapa[capa] = acotado;
    await repositorio.guardarAudioVolumenCapa(capa.clave, acotado);
    await _aplicarVolumenDe(capa);
  }

  Future<void> fijarModoSilencio(
    bool silencio,
    RepositorioProgreso repositorio,
  ) async {
    _modoSilencio = silencio;
    await repositorio.guardarAudioModoSilencio(silencio);
    await _aplicarVolumenesVigentes();
  }

  /// Reproduce un efecto puntual (capa efectos o narrativos). No
  /// interrumpe el loop de la capa correspondiente si lo hay — usa un
  /// reproductor efímero interno.
  Future<void> reproducirEfecto(String identificador) async {
    if (!_inicializado || _modoSilencio) return;
    final sonido = CatalogoSonidos.obtener(identificador);
    if (sonido == null) return;
    if (_idsAusentes.contains(identificador)) return;
    try {
      // Cada efecto necesita su propio AudioPlayer para que efectos
      // cortos y solapables (tap, acierto, fragmento_disuelto) no se
      // pisen entre sí. Pero `ReleaseMode.release` sólo libera el
      // recurso de audio nativo cuando termina la pista; el AudioPlayer
      // dart-side queda vivo. Sin un dispose explícito al terminar, las
      // instancias se acumulan en memoria — leak invisible en sesiones
      // largas. Suscribimos al `onPlayerComplete` para desecharlo.
      final player = AudioPlayer(playerId: 'efecto_${DateTime.now().microsecondsSinceEpoch}')
        ..setReleaseMode(ReleaseMode.release);
      _autoDesecharCuandoTermine(player);
      final volumen = _volumenEfectivoDe(sonido.capa);
      await player.setVolume(volumen);
      final fuente = await LocalizadorAudio.instancia.resolver(sonido.rutaAsset);
      await player.play(fuente);
    } on PlatformException {
      _idsAusentes.add(identificador);
    } on FlutterError {
      _idsAusentes.add(identificador);
    } catch (_) {
      // Cualquier otro error — lo silenciamos para no romper el juego.
      _idsAusentes.add(identificador);
    }
  }

  /// Reproduce una voz TTS desde un asset directo (sin pasar por
  /// CatalogoSonidos). Útil para el catálogo de voces, donde habrá
  /// cientos de OGGs y catalogarlos uno a uno no escala. Va por la
  /// capa narrativos para que active el ducking automático sobre
  /// ambient/música mientras suena la frase.
  ///
  /// Si el asset no existe o el plugin de audio no está disponible
  /// (tests, headless), falla en silencio igual que [reproducirEfecto].
  Future<void> reproducirVoz(String rutaAsset) async {
    if (!_inicializado || _modoSilencio) return;
    if (_idsAusentes.contains(rutaAsset)) return;
    try {
      final player = AudioPlayer(
        playerId: 'voz_${DateTime.now().microsecondsSinceEpoch}',
      )..setReleaseMode(ReleaseMode.release);
      _autoDesecharCuandoTermine(player);
      final volumen = _volumenEfectivoDe(CapaAudio.narrativos);
      await player.setVolume(volumen);
      final fuente = await LocalizadorAudio.instancia.resolver(rutaAsset);
      await player.play(fuente);
    } on PlatformException {
      _idsAusentes.add(rutaAsset);
    } on FlutterError {
      _idsAusentes.add(rutaAsset);
    } catch (_) {
      _idsAusentes.add(rutaAsset);
    }
  }

  /// Suscribe al `onPlayerComplete` del [player] para liberar la
  /// instancia cuando termina la pista. Usado por `reproducirEfecto`
  /// y `reproducirVoz`, que crean un AudioPlayer por llamada para
  /// permitir efectos solapables. Sin esto, las instancias se
  /// acumulan en memoria durante sesiones largas.
  ///
  /// El subscription `cancel()` se llama dentro del propio listener,
  /// así no hace falta tracking externo. Si la suscripción ya estaba
  /// cancelada, `dispose()` también es seguro de llamar dos veces.
  void _autoDesecharCuandoTermine(AudioPlayer player) {
    late final StreamSubscription<void> sub;
    sub = player.onPlayerComplete.listen((_) async {
      await sub.cancel();
      try {
        await player.dispose();
      } catch (_) {
        // En tests headless o tras un dispose previo, el plugin puede
        // tirar — silenciamos para no estropear la sesión.
      }
    });
  }

  /// Reproduce un loop en la capa del sonido (ambient o música).
  /// Si ya hay otro loop activo en esa capa, hace un fade-crossing
  /// lineal de [msFade] milisegundos. Si es el mismo loop, no hace nada.
  Future<void> reproducirLoop(
    String identificador, {
    int msFade = 1200,
  }) async {
    if (!_inicializado) return;
    final sonido = CatalogoSonidos.obtener(identificador);
    if (sonido == null) return;
    if (_idsAusentes.contains(identificador)) return;
    final capa = sonido.capa;
    if (_pistaActual[capa] == identificador) return;

    final player = _reproductores[capa];
    if (player == null) return;

    final turno = _tomarTurno(capa);
    _cancelarFade(capa);
    await _hacerFadeSalida(capa, msFade);
    // Si mientras se apagaba lo anterior alguien pidió otra cosa, manda él.
    if (_turno[capa] != turno) return;

    try {
      await player.setReleaseMode(
        sonido.enBucle ? ReleaseMode.loop : ReleaseMode.stop,
      );
      await player.setVolume(0);
      final fuente = await LocalizadorAudio.instancia.resolver(sonido.rutaAsset);
      await player.play(fuente);
      _pistaActual[capa] = identificador;
      if (_turno[capa] != turno) return;
      await _hacerFadeEntrada(capa, msFade);
    } on PlatformException {
      _idsAusentes.add(identificador);
      _pistaActual[capa] = null;
    } on FlutterError {
      _idsAusentes.add(identificador);
      _pistaActual[capa] = null;
    } catch (_) {
      _idsAusentes.add(identificador);
      _pistaActual[capa] = null;
    }
  }

  /// Detiene con fade el loop de una capa.
  Future<void> detenerCapa(CapaAudio capa, {int msFade = 800}) async {
    final turno = _tomarTurno(capa);
    _cancelarFade(capa);
    final player = _reproductores[capa];
    // La capa queda libre desde ya: si se vuelve a pedir la misma pista
    // durante el fundido (volver a entrar en la misma máquina), se oye.
    final sonaba = _pistaActual[capa];
    _pistaActual[capa] = null;
    if (sonaba != null && player != null) {
      await _fadeLineal(
        capa: capa,
        player: player,
        desde: _volumenEfectivoDe(capa),
        hasta: 0,
        msTotal: msFade,
      );
    }
    // Si durante el fundido empezó otra pista, no se para: ya no es nuestra.
    if (_turno[capa] != turno) return;
    await player?.stop();
  }

  int _tomarTurno(CapaAudio capa) => _turno[capa] = (_turno[capa] ?? 0) + 1;

  /// Atenúa temporalmente las capas ambient+música+efectos (a -6 dB
  /// aprox.) para que un efecto narrativo (silbido de Zafrán, voz de
  /// Eco) se oiga sin competencia. Llamar [fijarDucking(false)] para
  /// recuperar.
  Future<void> fijarDucking(bool activo) async {
    if (_ducking == activo) return;
    _ducking = activo;
    await _aplicarVolumenesVigentes();
  }

  /// Limpia el conjunto de identificadores marcados como ausentes y
  /// detiene los loops activos para forzar una resolución fresca al
  /// siguiente [reproducirLoop] / [reproducirEfecto]. Llamar tras
  /// descargar o borrar el paquete sonoro: si la app arrancó sin paquete,
  /// los ids fallaron una vez y quedaron cacheados como ausentes; sin
  /// este reset nunca se volverían a intentar dentro de la misma sesión.
  Future<void> reintentarSonidosAusentes() async {
    _idsAusentes.clear();
    // Invalidamos el cache de path por si el motor pudiera resolver
    // a otro directorio (no es habitual, pero es trivial y robusto).
    LocalizadorAudio.instancia.invalidar();
    for (final capa in CapaAudio.values) {
      _cancelarFade(capa);
      final player = _reproductores[capa];
      await player?.stop();
      _pistaActual[capa] = null;
    }
  }

  /// Libera todos los players. Útil si el motor debe reiniciarse al
  /// cambiar de perfil tras operaciones destructivas — la política
  /// normal es recargar preferencias sin liberar.
  Future<void> liberar() async {
    for (final capa in CapaAudio.values) {
      _cancelarFade(capa);
      final player = _reproductores[capa];
      await player?.stop();
      await player?.release();
      await player?.dispose();
    }
    _reproductores.clear();
    _pistaActual.clear();
    _inicializado = false;
  }

  // ═══ Helpers internos ═══

  double _volumenEfectivoDe(CapaAudio capa) {
    if (_modoSilencio) return 0;
    final base = (_volumenCapa[capa] ?? capa.volumenPredeterminado) / 100.0;
    final factorDucking = _ducking && capa != CapaAudio.narrativos ? 0.45 : 1.0;
    return (base * factorDucking).clamp(0.0, 1.0);
  }

  Future<void> _aplicarVolumenDe(CapaAudio capa) async {
    final player = _reproductores[capa];
    if (player == null) return;
    try {
      await player.setVolume(_volumenEfectivoDe(capa));
    } catch (_) {
      // Ignoramos — el player puede estar libre.
    }
  }

  Future<void> _aplicarVolumenesVigentes() async {
    for (final capa in CapaAudio.values) {
      await _aplicarVolumenDe(capa);
    }
  }

  void _cancelarFade(CapaAudio capa) {
    _fadesActivos[capa]?.cancel();
    _fadesActivos[capa] = null;
    // Soltar a quien esperaba ese fundido.
    final espera = _esperasDeFade.remove(capa);
    if (espera != null && !espera.isCompleted) espera.complete();
  }

  Future<void> _hacerFadeSalida(CapaAudio capa, int msFade) async {
    final player = _reproductores[capa];
    if (player == null) return;
    if (_pistaActual[capa] == null) return;
    await _fadeLineal(
      capa: capa,
      player: player,
      desde: _volumenEfectivoDe(capa),
      hasta: 0,
      msTotal: msFade,
    );
  }

  Future<void> _hacerFadeEntrada(CapaAudio capa, int msFade) async {
    final player = _reproductores[capa];
    if (player == null) return;
    await _fadeLineal(
      capa: capa,
      player: player,
      desde: 0,
      hasta: _volumenEfectivoDe(capa),
      msTotal: msFade,
    );
  }

  Future<void> _fadeLineal({
    required CapaAudio capa,
    required AudioPlayer player,
    required double desde,
    required double hasta,
    required int msTotal,
  }) async {
    if (msTotal <= 0) {
      await player.setVolume(hasta);
      return;
    }
    const ticks = 20;
    final msPorPaso = (msTotal / ticks).round();
    final completer = Completer<void>();
    _esperasDeFade[capa] = completer;
    var paso = 0;
    _fadesActivos[capa] = Timer.periodic(
      Duration(milliseconds: msPorPaso),
      (timer) async {
        paso++;
        final t = paso / ticks;
        final valor = desde + (hasta - desde) * t;
        try {
          await player.setVolume(valor.clamp(0.0, 1.0));
        } catch (_) {
          // Si el player ya no acepta volumen, acabamos el fade.
        }
        if (paso >= ticks) {
          timer.cancel();
          _fadesActivos[capa] = null;
          if (identical(_esperasDeFade[capa], completer)) _esperasDeFade.remove(capa);
          if (!completer.isCompleted) completer.complete();
        }
      },
    );
    await completer.future;
  }
}
