import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claro (de partida: la app se usa a pleno sol, DESIGN.md del rediseño),
/// oscuro o como el sistema. Se guarda en `zunbeltz.tema` y repinta
/// `MaterialApp` al cambiar.
final ValueNotifier<ThemeMode> temaAppZunbeltz =
    ValueNotifier<ThemeMode>(ThemeMode.light);

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

/// «system» / «dark»; cualquier otra cosa (también nada guardado), claro.
ThemeMode temaDesdeCodigo(String? codigo) => switch (codigo) {
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
