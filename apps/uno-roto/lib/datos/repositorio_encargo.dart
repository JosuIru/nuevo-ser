import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Persistencia del encargo del día del perfil activo (doc 16, eje D).
///
/// Cada perfil guarda tres claves:
///
/// - `encargo.fecha`: la clave `AAAA-MM-DD` del encargo al que
///   pertenecen el progreso y el completado. Si no coincide con la
///   fecha de hoy, el estado guardado es de ayer y se ignora — el
///   encargo de ayer se evapora sin rastro (doc 16 §6: sin racha,
///   sin pérdida, sin culpa).
/// - `encargo.progreso`: capturas que ya cuentan para el encargo.
/// - `encargo.completado`: si el niño ya lo cumplió hoy.
///
/// El repositorio no sabe generar encargos (eso es del módulo puro
/// `GeneradorEncargoDelDia`); solo guarda el avance del día.
class RepositorioEncargo {
  RepositorioEncargo({required this.gestor});

  final GestorPerfiles gestor;

  static const _sufFecha = 'encargo.fecha';
  static const _sufProgreso = 'encargo.progreso';
  static const _sufCompletado = 'encargo.completado';

  /// Devuelve el estado del encargo para [claveFecha]. Si lo guardado
  /// pertenece a otro día, devuelve el estado limpio (0 capturas, sin
  /// completar) sin tocar disco — la primera captura de hoy ya
  /// sobrescribirá las claves.
  Future<EstadoEncargoDia> cargarEstado(String claveFecha) async {
    final prefs = await gestor.prefsInicializadas();
    final prefijo = await gestor.prefijoActivo();
    final fechaGuardada = prefs.getString('$prefijo$_sufFecha');
    if (fechaGuardada != claveFecha) {
      return const EstadoEncargoDia(progreso: 0, completado: false);
    }
    return EstadoEncargoDia(
      progreso: prefs.getInt('$prefijo$_sufProgreso') ?? 0,
      completado: prefs.getBool('$prefijo$_sufCompletado') ?? false,
    );
  }

  /// Registra una captura que cuenta para el encargo de [claveFecha]
  /// con meta [objetivo]. Devuelve el estado resultante, con
  /// [EstadoEncargoDia.recienCompletado] a `true` solo en la captura
  /// exacta que cierra el encargo — es la señal para el cierre sobrio
  /// en la pantalla de caza (una vez, no en cada captura posterior).
  Future<EstadoEncargoDia> registrarCaptura({
    required String claveFecha,
    required int objetivo,
  }) async {
    final previo = await cargarEstado(claveFecha);
    if (previo.completado) return previo;
    final progreso = previo.progreso + 1;
    final completado = progreso >= objetivo;
    final prefs = await gestor.prefsInicializadas();
    final prefijo = await gestor.prefijoActivo();
    // La fecha se escribe primero: si lo guardado era de ayer, estas
    // tres escrituras dejan el trío coherente para hoy.
    await prefs.setString('$prefijo$_sufFecha', claveFecha);
    await prefs.setInt('$prefijo$_sufProgreso', progreso);
    await prefs.setBool('$prefijo$_sufCompletado', completado);
    return EstadoEncargoDia(
      progreso: progreso,
      completado: completado,
      recienCompletado: completado,
    );
  }

  /// Borra el estado del encargo del perfil activo. Para tests y
  /// simetría con el resto de repositorios ("reiniciar partida" barre
  /// por prefijo y ya incluye estas claves).
  Future<void> borrarTodo() async {
    final prefs = await gestor.prefsInicializadas();
    final prefijo = await gestor.prefijoActivo();
    for (final sufijo in const [_sufFecha, _sufProgreso, _sufCompletado]) {
      await prefs.remove('$prefijo$sufijo');
    }
  }
}

/// Snapshot inmutable del avance del encargo de un día.
class EstadoEncargoDia {
  /// Capturas que ya cuentan.
  final int progreso;

  /// Si el encargo del día está cumplido.
  final bool completado;

  /// `true` solo en el resultado de la llamada a `registrarCaptura`
  /// que acaba de cerrarlo. Nunca se persiste.
  final bool recienCompletado;

  const EstadoEncargoDia({
    required this.progreso,
    required this.completado,
    this.recienCompletado = false,
  });
}
