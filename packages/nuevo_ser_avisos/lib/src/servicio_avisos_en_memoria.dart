import 'servicio_avisos.dart';

/// Implementación en memoria para tests (y para pantallas de prueba): guarda
/// los avisos en un mapa y no toca el sistema.
class ServicioAvisosEnMemoria implements ServicioAvisos {
  /// Reloj sustituible: los tests fijan la hora de «ahora».
  DateTime Function() reloj;

  /// Lo que contestará [pedirPermiso] (para probar el permiso denegado).
  bool permisoConcedido;

  bool inicializado = false;
  int vecesPedidoPermiso = 0;

  final Map<String, AvisoPendiente> _avisosPorClave = {};

  ServicioAvisosEnMemoria(
      {DateTime Function()? reloj, this.permisoConcedido = true})
      : reloj = reloj ?? DateTime.now;

  @override
  Future<void> inicializar() async {
    inicializado = true;
  }

  @override
  Future<bool> pedirPermiso() async {
    vecesPedidoPermiso++;
    return permisoConcedido;
  }

  @override
  Future<bool> programar({
    required String clave,
    required DateTime cuando,
    required String titulo,
    String? cuerpo,
  }) async {
    if (!permisoConcedido || !cuando.isAfter(reloj())) return false;
    _avisosPorClave[clave] = AvisoPendiente(
        clave: clave, titulo: titulo, cuerpo: cuerpo, cuando: cuando);
    return true;
  }

  @override
  Future<void> cancelar(String clave) async {
    _avisosPorClave.remove(clave);
  }

  @override
  Future<void> cancelarGrupo(String prefijo) async {
    _avisosPorClave.removeWhere((clave, _) => clave.startsWith(prefijo));
  }

  @override
  Future<List<AvisoPendiente>> pendientes() async {
    // Los ya vencidos se habrían enseñado: dejan de estar pendientes.
    final ahora = reloj();
    final ordenados = _avisosPorClave.values
        .where((aviso) => aviso.cuando!.isAfter(ahora))
        .toList()
      ..sort((a, b) => a.cuando!.compareTo(b.cuando!));
    return ordenados;
  }
}
