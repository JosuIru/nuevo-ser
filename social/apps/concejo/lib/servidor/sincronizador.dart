/// Mantiene el estado de la app al día con el servidor del pueblo y deja
/// trabajar sin red:
///
/// 1. Cada acción se aplica al momento y entra en una **cola** guardada en
///    el teléfono.
/// 2. Al sincronizar se envía la cola (el servidor no aplica dos veces la
///    misma), se baja lo que ve la persona y se **rehacen encima** las
///    acciones que aún no han llegado.
/// 3. Lo que el servidor rechaza (o ya no vale al rehacerlo: se cerró el
///    plazo, otra persona firmó…) se quita y se avisa.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../datos/instantanea.dart';
import '../datos/json_dominio.dart';
import '../estado/accion.dart';
import '../estado/estado_concejo.dart';
import 'almacen_local.dart';
import 'cliente_concejo.dart';

class AccionRechazada {
  const AccionRechazada(this.accion, this.motivo);
  final AccionConcejo accion;
  final String motivo;
}

class Sincronizador extends ChangeNotifier {
  Sincronizador._({
    required this.cliente,
    required this.almacen,
    required this.estado,
    required Json vista,
    required List<AccionConcejo> pendientes,
    DateTime Function()? reloj,
  })  : _vista = vista,
        _pendientes = pendientes,
        _reloj = reloj {
    estado.alHacerAccion = _encolar;
  }

  static const claveVista = 'concejo.vista';
  static const clavePendientes = 'concejo.pendientes';

  final ClienteConcejo cliente;
  final AlmacenLocal almacen;

  /// El que escuchan las pantallas: se recarga en su sitio.
  final EstadoConcejo estado;
  final DateTime Function()? _reloj;
  Json _vista;
  final List<AccionConcejo> _pendientes;
  final _rechazadas = <AccionRechazada>[];
  Timer? _envioProgramado;
  Future<void>? _enCurso;

  bool sinConexion = false;
  bool codigoIncorrecto = false;

  int get pendientes => _pendientes.length;
  List<AccionRechazada> get rechazadas => List.unmodifiable(_rechazadas);
  void olvidarRechazadas() {
    _rechazadas.clear();
    notifyListeners();
  }

  /// Con lo guardado en el teléfono, o `null` si aún no se ha entrado.
  static Sincronizador? abrir({
    required ClienteConcejo cliente,
    required AlmacenLocal almacen,
    DateTime Function()? reloj,
  }) {
    final textoVista = almacen.leer(claveVista);
    if (textoVista == null) return null;
    final vista = jsonDecode(textoVista) as Json;
    final pendientes = [
      for (final accion
          in jsonDecode(almacen.leer(clavePendientes) ?? '[]') as List)
        AccionConcejo.desdeJson(accion as Json),
    ];
    return Sincronizador._(
      cliente: cliente,
      almacen: almacen,
      estado: _estadoDesde(vista, reloj),
      vista: vista,
      pendientes: pendientes,
      reloj: reloj,
    ).._reconstruir();
  }

  /// Primera vez: baja lo que ve la persona (comprueba el código) y lo
  /// guarda. Lanza [CodigoIncorrecto] o [SinConexion].
  static Future<Sincronizador> entrar({
    required ClienteConcejo cliente,
    required AlmacenLocal almacen,
    DateTime Function()? reloj,
  }) async {
    final vista = (await cliente.estado())!;
    await almacen.escribir(claveVista, jsonEncode(vista));
    await almacen.escribir(clavePendientes, '[]');
    return Sincronizador._(
      cliente: cliente,
      almacen: almacen,
      estado: _estadoDesde(vista, reloj),
      vista: vista,
      pendientes: [],
      reloj: reloj,
    );
  }

  static EstadoConcejo _estadoDesde(Json vista, DateTime Function()? reloj) =>
      instantaneaDesdeJson(vista,
          personaActualUid: vista['yo'] as String, reloj: reloj);

  void _encolar(AccionConcejo accion) {
    _pendientes.add(accion);
    unawaited(_guardarPendientes());
    notifyListeners();
    // Unas cuantas acciones seguidas salen juntas.
    _envioProgramado?.cancel();
    _envioProgramado =
        Timer(const Duration(seconds: 2), () => unawaited(sincronizar()));
  }

  Future<void> _guardarPendientes() => almacen.escribir(clavePendientes,
      jsonEncode([for (final accion in _pendientes) accion.aJson()]));

  /// Envía la cola y baja el estado. Si ya hay una en marcha, espera a esa.
  Future<void> sincronizar() => _enCurso ??= _sincronizar().whenComplete(() {
        _enCurso = null;
      });

  Future<void> _sincronizar() async {
    try {
      if (_pendientes.isNotEmpty) {
        final enviadas = [..._pendientes];
        final resultados = await cliente.enviarAcciones(enviadas);
        for (final accion in enviadas) {
          if (!resultados.containsKey(accion.uid)) continue;
          _pendientes.removeWhere((p) => p.uid == accion.uid);
          final motivo = resultados[accion.uid];
          if (motivo != null) _rechazadas.add(AccionRechazada(accion, motivo));
        }
        await _guardarPendientes();
      }
      final nueva = await cliente.estado(huella: _vista['huella'] as String?);
      if (nueva != null) {
        _vista = nueva;
        await almacen.escribir(claveVista, jsonEncode(nueva));
      }
      sinConexion = false;
      codigoIncorrecto = false;
      _reconstruir();
    } on SinConexion {
      sinConexion = true;
    } on CodigoIncorrecto {
      codigoIncorrecto = true;
    } on ErrorServidor {
      sinConexion = true;
    }
    notifyListeners();
  }

  /// Lo bajado del servidor con la cola rehecha encima.
  void _reconstruir() {
    final nuevo = _estadoDesde(_vista, _reloj);
    for (final accion in [..._pendientes]) {
      try {
        nuevo.rehacer(accion);
      } catch (error) {
        _pendientes.remove(accion);
        _rechazadas.add(AccionRechazada(accion, '$error'));
      }
    }
    estado.cargarDesde(nuevo);
  }

  /// Código nuevo para una persona (lo pide la mesa). Antes se envía la
  /// cola, por si la persona se acaba de dar de alta sin red.
  Future<String> nuevoCodigo(String personaUid) async {
    await sincronizar();
    return cliente.nuevoCodigo(personaUid);
  }

  /// La dirección que va en la hoja del código, como la teclearía alguien.
  String get direccionPueblo => cliente.api
      .toString()
      .replaceFirst(RegExp(r'^https://'), '')
      .replaceFirst(RegExp(r'/wp-json/concejo/v1/$'), '');

  /// Salir: se olvida todo lo guardado (también lo que no se ha enviado).
  Future<void> salir() async {
    _envioProgramado?.cancel();
    estado.alHacerAccion = null;
    await almacen.escribir(claveVista, null);
    await almacen.escribir(clavePendientes, null);
  }

  @override
  void dispose() {
    _envioProgramado?.cancel();
    super.dispose();
  }
}
