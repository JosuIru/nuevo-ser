import 'package:shared_preferences/shared_preferences.dart';

/// El "viñedo activo" es el viñedo seleccionado en el filtro principal
/// del mapa. Persiste entre arranques en SharedPreferences. Si vale
/// `null` la pantalla mapa muestra todas las cepas (incluidos puntos
/// sueltos); si tiene valor, sólo las de ese viñedo.
///
/// Está separado del modelo `Vinedo` porque es estado de UI/preferencia,
/// no un dato del dominio. Patrón heredado de la suite Larrea.
class VinedoActivoPersistido {
  static const _clave = 'solera_viticultura.vinedo_activo.id';

  Future<int?> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_clave);
  }

  Future<void> guardar(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_clave);
    } else {
      await prefs.setInt(_clave, id);
    }
  }
}
