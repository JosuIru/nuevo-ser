// Perfil de uso de la app: huerta profesional (con cestas, certificador
// ecológico y cuentas) o huerto de casa (bancales, rotación, siembras y
// plagas, sin la parte de explotación). Solo cambia lo que se ve: los
// datos son los mismos y se puede volver al otro perfil sin perder nada.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PerfilHuerta { profesional, casa }

const String clavePreferenciaPerfilHuerta = 'solera_huerta.perfil';

/// Perfil actual. Por defecto, profesional (lo que ya tenía quien la usaba).
final ValueNotifier<PerfilHuerta> perfilHuerta =
    ValueNotifier(PerfilHuerta.profesional);

bool get esHuertoDeCasa => perfilHuerta.value == PerfilHuerta.casa;

Future<void> cargarPerfilHuerta() async {
  try {
    final preferencias = await SharedPreferences.getInstance();
    final guardado = preferencias.getString(clavePreferenciaPerfilHuerta);
    perfilHuerta.value = PerfilHuerta.values.firstWhere(
        (perfil) => perfil.name == guardado,
        orElse: () => PerfilHuerta.profesional);
  } catch (error) {
    debugPrint('No se pudo leer el perfil de la huerta: $error');
  }
}

Future<void> cambiarPerfilHuerta(PerfilHuerta nuevo) async {
  perfilHuerta.value = nuevo;
  final preferencias = await SharedPreferences.getInstance();
  await preferencias.setString(clavePreferenciaPerfilHuerta, nuevo.name);
}
