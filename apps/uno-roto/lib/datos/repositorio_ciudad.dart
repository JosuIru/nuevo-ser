import 'package:nuevo_ser_core/nuevo_ser_core.dart';

/// Persistencia del taller de restauración del perfil activo (doc 16,
/// eje B).
///
/// Claves por perfil:
///
/// - `ciudad.piezas`: lista de ids de [PiezaCiudad] ya restauradas.
/// - `ciudad.esquirlas_gastadas`: total gastado en el taller.
///
/// Regla de oro: las esquirlas GANADAS (`esquirlas_total`) nunca
/// bajan — de ellas dependen los rangos narrativos y el desbloqueo de
/// distritos. Lo gastado se apunta aparte y lo disponible se calcula
/// como `ganadas - gastadas`.
class RepositorioCiudad {
  RepositorioCiudad({required this.gestor});

  final GestorPerfiles gestor;

  static const _sufPiezas = 'ciudad.piezas';
  static const _sufEsquirlasGastadas = 'ciudad.esquirlas_gastadas';

  Future<Set<String>> cargarPiezasRestauradas() async {
    final prefs = await gestor.prefsInicializadas();
    final clave = '${await gestor.prefijoActivo()}$_sufPiezas';
    return (prefs.getStringList(clave) ?? const []).toSet();
  }

  Future<int> cargarEsquirlasGastadas() async {
    final prefs = await gestor.prefsInicializadas();
    final clave = '${await gestor.prefijoActivo()}$_sufEsquirlasGastadas';
    return prefs.getInt(clave) ?? 0;
  }

  /// Intenta restaurar [idPieza] pagando [precio] con el saldo
  /// disponible (`esquirlasGanadas - gastadas`). Devuelve el resultado
  /// para que la vista responda sin recalcular nada.
  Future<ResultadoRestauracion> restaurarPieza({
    required String idPieza,
    required int precio,
    required int esquirlasGanadas,
  }) async {
    final restauradas = await cargarPiezasRestauradas();
    if (restauradas.contains(idPieza)) {
      return ResultadoRestauracion.yaRestaurada;
    }
    final gastadas = await cargarEsquirlasGastadas();
    if (esquirlasGanadas - gastadas < precio) {
      return ResultadoRestauracion.sinEsquirlas;
    }
    final prefs = await gestor.prefsInicializadas();
    final prefijo = await gestor.prefijoActivo();
    // El gasto se apunta primero: si la app muere entre las dos
    // escrituras, el niño pierde como mucho el apunte de una pieza no
    // marcada (se puede volver a restaurar gratis de facto), nunca
    // aparece una pieza pagada dos veces.
    await prefs.setInt('$prefijo$_sufEsquirlasGastadas', gastadas + precio);
    await prefs.setStringList(
      '$prefijo$_sufPiezas',
      [...restauradas, idPieza],
    );
    return ResultadoRestauracion.hecha;
  }

  /// Borra el estado del taller del perfil activo (tests; el
  /// "reiniciar partida" barre por prefijo y ya incluye estas claves).
  Future<void> borrarTodo() async {
    final prefs = await gestor.prefsInicializadas();
    final prefijo = await gestor.prefijoActivo();
    await prefs.remove('$prefijo$_sufPiezas');
    await prefs.remove('$prefijo$_sufEsquirlasGastadas');
  }
}

enum ResultadoRestauracion { hecha, yaRestaurada, sinEsquirlas }
