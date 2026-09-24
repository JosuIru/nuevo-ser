import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// «Sin prisas» (Ajustes): en las máquinas de acción, lo que corre solo
/// espera al niño. La pieza de Encaje no cae hasta que se suelta, las
/// sombras de Canales sólo se mueven cuando el Fragmento se mueve, las
/// barcas de Esclusas se paran antes de la compuerta, la Serpiente va
/// más despacio y sus números se quedan quietos, y Salto corre menos.
///
/// Apagado por defecto. Clave global del dispositivo, como el idioma.
class AjusteSinPrisas {
  static const clave = 'uroto.sin_prisas';

  static final activo = ValueNotifier<bool>(false);

  static Future<void> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    activo.value = preferencias.getBool(clave) ?? false;
  }

  static Future<void> fijar(bool valor) async {
    activo.value = valor;
    final preferencias = await SharedPreferences.getInstance();
    if (valor) {
      await preferencias.setBool(clave, true);
    } else {
      await preferencias.remove(clave);
    }
  }
}
