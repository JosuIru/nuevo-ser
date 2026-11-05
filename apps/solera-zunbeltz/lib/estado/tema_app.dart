import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claro, oscuro o como el sistema (de partida). Se guarda en
/// `zunbeltz.tema` y repinta `MaterialApp` al cambiar.
final ValueNotifier<ThemeMode> temaAppZunbeltz =
    ValueNotifier<ThemeMode>(ThemeMode.system);

const String _claveTema = 'zunbeltz.tema';

/// Aplica el tema guardado antes del primer build.
Future<void> precargarTemaZunbeltz() async {
  try {
    final preferencias = await SharedPreferences.getInstance();
    temaAppZunbeltz.value = temaDesdeCodigo(preferencias.getString(_claveTema));
  } catch (_) {}
}

Future<void> elegirTemaZunbeltz(ThemeMode tema) async {
  temaAppZunbeltz.value = tema;
  try {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_claveTema, tema.name);
  } catch (_) {}
}

/// «light» / «dark»; cualquier otra cosa, el del sistema.
ThemeMode temaDesdeCodigo(String? codigo) => switch (codigo) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
