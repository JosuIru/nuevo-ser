import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/persona_espacio.dart';
import '../servicios/politica_tareas.dart';

/// Persona conectada en este dispositivo. `null` = modo local (sin
/// sincronización configurada). Se refresca con cada `GET /yo` o
/// sincronización y se guarda para que los permisos sigan valiendo sin
/// cobertura.
final ValueNotifier<SesionEspacio?> sesionEspacio =
    ValueNotifier<SesionEspacio?>(null);

/// Personas activas del espacio, para elegir responsable de una tarea.
final ValueNotifier<List<PersonaEspacio>> personasEspacio =
    ValueNotifier<List<PersonaEspacio>>(const []);

/// Política de tareas de la sesión actual.
PoliticaTareas get politicaTareasActual => PoliticaTareas(sesionEspacio.value);

const _claveSesion = 'zunbeltz.sesion_json';
const _clavePersonas = 'zunbeltz.personas_json';

/// Carga la última sesión guardada antes del primer build.
Future<void> precargarSesionEspacio() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final sesionJson = prefs.getString(_claveSesion);
    if (sesionJson != null) {
      sesionEspacio.value = SesionEspacio.fromJson(
          Map<String, Object?>.from(jsonDecode(sesionJson) as Map));
    }
    final personasJson = prefs.getString(_clavePersonas);
    if (personasJson != null) {
      personasEspacio.value = [
        for (final item in jsonDecode(personasJson) as List)
          PersonaEspacio.fromJson(Map<String, Object?>.from(item as Map)),
      ];
    }
  } catch (_) {
    // Datos guardados corruptos: se arranca en modo local y la próxima
    // sincronización los rehace.
    await cerrarSesionEspacio();
  }
}

Future<void> guardarSesionEspacio(
    SesionEspacio sesion, List<PersonaEspacio> personas) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_claveSesion, jsonEncode(sesion.toJson()));
  await prefs.setString(
      _clavePersonas, jsonEncode([for (final p in personas) p.toJson()]));
  sesionEspacio.value = sesion;
  personasEspacio.value = List.unmodifiable(personas);
}

/// Vuelve a modo local (p. ej. al cambiar de token o de WordPress).
Future<void> cerrarSesionEspacio() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_claveSesion);
  await prefs.remove(_clavePersonas);
  sesionEspacio.value = null;
  personasEspacio.value = const [];
}
