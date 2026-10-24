/// Cola de descarga de teselas, sin red ni ficheros (se le pasan las
/// funciones que bajan y que esperan), para poder probar la concurrencia,
/// los reintentos y la cancelación sin tocar el IGN.
library;

import 'dart:async';
import 'dart:math' as math;

import 'teselas_mapa.dart';

/// Qué ha pasado al intentar bajar una tesela.
enum ResultadoIntentoTesela {
  /// Bajada y guardada.
  hecha,

  /// Falló algo que puede arreglarse solo (sin red un momento, el servidor
  /// ocupado, un 5xx, un 429): se vuelve a probar más tarde.
  reintentable,

  /// No tiene arreglo (un 404, una respuesta que no es una imagen): se
  /// cuenta como fallida y se sigue con las demás.
  definitivo,
}

/// Por qué terminó una descarga.
enum FinDescargaTeselas {
  /// Se intentaron todas (alguna puede haber fallado: ver [ProgresoDescargaTeselas.fallidas]).
  completada,

  /// Quien la lanzó la canceló.
  cancelada,

  /// Ya no hay wifi o cable: se para para no gastar datos móviles.
  sinWifi,

  /// Demasiados fallos seguidos (sin red de verdad, o el servidor no
  /// quiere): se para en vez de seguir insistiendo.
  demasiadosFallos,
}

/// Cuánto lleva una descarga.
class ProgresoDescargaTeselas {
  const ProgresoDescargaTeselas({
    required this.total,
    this.hechas = 0,
    this.fallidas = 0,
  });

  final int total;
  final int hechas;
  final int fallidas;

  int get intentadas => hechas + fallidas;
  double get fraccion => total == 0 ? 1 : intentadas / total;
}

/// Espera antes del reintento número [intento] (1, 2, 3…): 2 s, 8 s, 30 s y
/// así como mucho. Crece rápido para no martillear a un servidor que ya
/// está diciendo que no.
Duration esperaReintentoTesela(int intento) {
  const esperas = [2, 8, 30];
  final segundos = esperas[math.min(intento, esperas.length) - 1];
  return Duration(seconds: segundos);
}

/// Baja [teselas] con [concurrencia] peticiones a la vez como mucho.
///
/// Cada tesela se intenta hasta [maxIntentos] veces si el fallo es
/// reintentable, esperando [esperaReintento] entre intentos. Si se juntan
/// [maxFallosSeguidos] teselas fallidas sin ninguna buena en medio, se para
/// todo ([FinDescargaTeselas.demasiadosFallos]). Antes de cada tesela se
/// pregunta a [puedeSeguir] (p. ej. «¿sigue habiendo wifi?»).
class ColaDescargaTeselas {
  ColaDescargaTeselas({
    required List<TeselaXYZ> teselas,
    required this.descargar,
    this.concurrencia = 4,
    this.maxIntentos = 4,
    this.maxFallosSeguidos = 12,
    this.esperaReintento = esperaReintentoTesela,
    Future<void> Function(Duration espera)? dormir,
    Future<bool> Function()? puedeSeguir,
    this.alProgresar,
  })  : _pendientes = List.of(teselas),
        _total = teselas.length,
        dormir = dormir ?? ((espera) => Future<void>.delayed(espera)),
        puedeSeguir = puedeSeguir ?? (() async => true);

  final Future<ResultadoIntentoTesela> Function(TeselaXYZ tesela) descargar;
  final int concurrencia;
  final int maxIntentos;
  final int maxFallosSeguidos;
  final Duration Function(int intento) esperaReintento;
  final Future<void> Function(Duration espera) dormir;
  final Future<bool> Function() puedeSeguir;
  final void Function(ProgresoDescargaTeselas progreso)? alProgresar;

  final List<TeselaXYZ> _pendientes;
  final int _total;
  int _siguiente = 0;
  int _hechas = 0;
  int _fallidas = 0;
  int _fallosSeguidos = 0;
  FinDescargaTeselas? _motivoParada;
  final Completer<void> _cancelacion = Completer<void>();

  ProgresoDescargaTeselas get progreso => ProgresoDescargaTeselas(
      total: _total, hechas: _hechas, fallidas: _fallidas);

  bool get cancelada => _motivoParada == FinDescargaTeselas.cancelada;

  /// Para la descarga: lo que está en vuelo termina, lo demás no empieza y
  /// las esperas de reintento se cortan.
  void cancelar() => _parar(FinDescargaTeselas.cancelada);

  void _parar(FinDescargaTeselas motivo) {
    _motivoParada ??= motivo;
    if (!_cancelacion.isCompleted) _cancelacion.complete();
  }

  Future<FinDescargaTeselas> ejecutar() async {
    final trabajadores =
        math.max(1, math.min(concurrencia, _pendientes.length));
    await Future.wait(List.generate(trabajadores, (_) => _trabajar()));
    return _motivoParada ?? FinDescargaTeselas.completada;
  }

  Future<void> _trabajar() async {
    while (_motivoParada == null && _siguiente < _pendientes.length) {
      if (!await puedeSeguir()) {
        _parar(FinDescargaTeselas.sinWifi);
        return;
      }
      // Otra trabajadora puede haber cogido la última mientras se esperaba.
      if (_motivoParada != null || _siguiente >= _pendientes.length) return;
      final tesela = _pendientes[_siguiente++];
      final bien = await _bajarConReintentos(tesela);
      if (bien == null) return; // parada a mitad de los reintentos
      if (bien) {
        _hechas++;
        _fallosSeguidos = 0;
      } else {
        _fallidas++;
        _fallosSeguidos++;
        if (_fallosSeguidos >= maxFallosSeguidos) {
          _parar(FinDescargaTeselas.demasiadosFallos);
        }
      }
      alProgresar?.call(progreso);
    }
  }

  /// true = hecha; false = fallida; null = se paró la cola antes de saberlo
  /// (la tesela queda sin contar: se bajará al reanudar).
  Future<bool?> _bajarConReintentos(TeselaXYZ tesela) async {
    for (var intento = 1; intento <= maxIntentos; intento++) {
      ResultadoIntentoTesela resultado;
      try {
        resultado = await descargar(tesela);
      } catch (_) {
        // Un fallo no previsto se trata como pasajero: con los intentos
        // contados no puede convertirse en un bucle.
        resultado = ResultadoIntentoTesela.reintentable;
      }
      switch (resultado) {
        case ResultadoIntentoTesela.hecha:
          return true;
        case ResultadoIntentoTesela.definitivo:
          return false;
        case ResultadoIntentoTesela.reintentable:
          if (intento == maxIntentos) return false;
          await Future.any(
              [dormir(esperaReintento(intento)), _cancelacion.future]);
          if (_motivoParada != null) return null;
      }
    }
    return false;
  }
}
