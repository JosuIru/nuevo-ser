import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Flags narrativos persistidos del juego — los hitos de cinemática
/// vistos, las elecciones tomadas, los rangos alcanzados. Cada flag
/// es un booleano por perfil: dos hermanos que comparten el aparato
/// cada uno tiene los suyos.
///
/// Namespace: `<prefijoPerfilActivo>flag.<nombre>` — el prefijo lo
/// resuelve el [GestorPerfiles] del core.
class RepositorioFlagsNarrativos {
  static const String _sufijo = 'flag.';

  final GestorPerfiles _gestor;

  const RepositorioFlagsNarrativos({required GestorPerfiles gestor})
      : _gestor = gestor;

  Future<String> _claveDe(String flag) async {
    final prefijo = await _gestor.prefijoActivo();
    return '$prefijo$_sufijo$flag';
  }

  /// `true` si el flag está activo para el perfil actual.
  Future<bool> estaActivo(String flag) async {
    final prefs = await _gestor.prefsInicializadas();
    return prefs.getBool(await _claveDe(flag)) ?? false;
  }

  /// Activa el flag para el perfil actual. Idempotente.
  Future<void> activar(String flag) async {
    final prefs = await _gestor.prefsInicializadas();
    await prefs.setBool(await _claveDe(flag), true);
  }

  /// Desactiva el flag para el perfil actual. Idempotente. Sólo para
  /// flags que son preferencias (p. ej. `preferencia_escenas_enteras`):
  /// los hitos narrativos no se deshacen.
  Future<void> desactivar(String flag) async {
    final prefs = await _gestor.prefsInicializadas();
    await prefs.remove(await _claveDe(flag));
  }

  /// Conjunto de flags actualmente activos del perfil actual. Útil
  /// para que el orquestador resuelva precondiciones
  /// (`flagsRequeridos` de `EscenaCinematica`).
  Future<Set<String>> activos() async {
    final prefs = await _gestor.prefsInicializadas();
    final prefijoCompleto = '${await _gestor.prefijoActivo()}$_sufijo';
    final activos = <String>{};
    for (final clave in prefs.getKeys()) {
      if (clave.startsWith(prefijoCompleto) &&
          (prefs.getBool(clave) ?? false)) {
        activos.add(clave.substring(prefijoCompleto.length));
      }
    }
    return activos;
  }

  /// Borra todos los flags activos del perfil actual.
  Future<void> borrarTodos() async {
    final prefs = await _gestor.prefsInicializadas();
    final prefijoCompleto = '${await _gestor.prefijoActivo()}$_sufijo';
    final claves = prefs
        .getKeys()
        .where((k) => k.startsWith(prefijoCompleto))
        .toList();
    for (final clave in claves) {
      await prefs.remove(clave);
    }
  }
}
