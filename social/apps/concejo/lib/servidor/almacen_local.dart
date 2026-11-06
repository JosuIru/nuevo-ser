/// Dónde guarda la app lo que tiene que sobrevivir a cerrarla: la
/// dirección y el código, el último estado bajado y la cola sin enviar.
library;

import 'package:shared_preferences/shared_preferences.dart';

abstract class AlmacenLocal {
  String? leer(String clave);

  /// `null` borra la clave.
  Future<void> escribir(String clave, String? valor);
}

class AlmacenPreferencias implements AlmacenLocal {
  AlmacenPreferencias(this._preferencias);

  static Future<AlmacenPreferencias> abrir() async =>
      AlmacenPreferencias(await SharedPreferences.getInstance());

  final SharedPreferences _preferencias;

  @override
  String? leer(String clave) => _preferencias.getString(clave);

  @override
  Future<void> escribir(String clave, String? valor) async {
    if (valor == null) {
      await _preferencias.remove(clave);
    } else {
      await _preferencias.setString(clave, valor);
    }
  }
}

/// Para los tests.
class AlmacenEnMemoria implements AlmacenLocal {
  final datos = <String, String>{};

  @override
  String? leer(String clave) => datos[clave];

  @override
  Future<void> escribir(String clave, String? valor) async {
    if (valor == null) {
      datos.remove(clave);
    } else {
      datos[clave] = valor;
    }
  }
}
