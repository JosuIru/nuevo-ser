/// Contrato de los avisos programados de la suite Larrea.
///
/// Cada aviso se identifica con una **clave de texto** estable
/// (`plan.12.amasado`, `masa_madre.3.refresco`…). El id entero que pide el
/// sistema se deriva de ella con [idDeClave], y la clave viaja como `payload`
/// del aviso, así [ServicioAvisos.cancelarGrupo] puede quitar todos los de un
/// prefijo sin guardar nada aparte.
///
/// Nada de esto puede romper la app: si no hay permiso, si la plataforma no
/// tiene notificaciones (tests, escritorio, web) o si el sistema falla, los
/// métodos devuelven `false` o una lista vacía y la app sigue enseñando los
/// avisos en pantalla.
abstract class ServicioAvisos {
  /// Prepara el plugin (canal, zona horaria). Idempotente.
  Future<void> inicializar();

  /// Pide permiso para enseñar notificaciones (Android 13+, iOS) y, si la
  /// configuración lo pide, para alarmas exactas. `true` si se puede avisar.
  Future<bool> pedirPermiso();

  /// Programa un aviso para [cuando] (hora local). Si ya había uno con la
  /// misma [clave], lo sustituye. `false` si [cuando] ya ha pasado o si no
  /// se ha podido programar.
  Future<bool> programar({
    required String clave,
    required DateTime cuando,
    required String titulo,
    String? cuerpo,
  });

  /// Quita el aviso de [clave], si lo hay.
  Future<void> cancelar(String clave);

  /// Quita todos los avisos cuya clave empieza por [prefijo]
  /// (p. ej. `plan.12.` para todas las fases de un plan).
  Future<void> cancelarGrupo(String prefijo);

  /// Los avisos pendientes que programó esta app (con su clave).
  Future<List<AvisoPendiente>> pendientes();
}

/// Un aviso que el sistema tiene pendiente de enseñar.
class AvisoPendiente {
  final String clave;
  final String titulo;
  final String? cuerpo;

  /// Solo se conoce en la implementación en memoria: el sistema no
  /// devuelve la hora de un aviso programado.
  final DateTime? cuando;

  const AvisoPendiente({
    required this.clave,
    required this.titulo,
    this.cuerpo,
    this.cuando,
  });

  @override
  String toString() => 'AvisoPendiente($clave, $titulo, $cuando)';
}

/// Id entero estable para una clave de texto: FNV-1a de 32 bits recortado a
/// 31 (Android exige un `int` de Java positivo). El mismo texto da siempre
/// el mismo id, en cualquier móvil y versión de la app.
int idDeClave(String clave) {
  const desplazamientoFnv = 0x811c9dc5;
  const primoFnv = 0x01000193;
  var hash = desplazamientoFnv;
  for (final unidad in clave.codeUnits) {
    hash ^= unidad;
    hash = (hash * primoFnv) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
