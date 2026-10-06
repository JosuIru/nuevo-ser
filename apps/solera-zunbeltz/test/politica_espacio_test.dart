// Tests de la política del espacio en la app. Replica las reglas del
// servidor (`wp-plugin/solera-zunbeltz-sync/includes/entidades.php`,
// probadas en `tests/test_entidades.php`): si una cambia, cambia la otra.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/servicios/politica_espacio.dart';

void main() {
  SesionEspacio sesion(String uid, Set<String> capacidades) => SesionEspacio(
        persona: PersonaEspacio(uid: uid, nombre: uid),
        capacidades: capacidades,
      );

  final coordinacion = PoliticaEspacio(sesion('coord', {
    capacidadEditarEspacio,
    capacidadAnadirPuntos,
    capacidadGestionarProyectos,
    capacidadEnviarPeticiones,
    capacidadGestionarPeticiones,
    capacidadCrearAvisos,
    capacidadGestionarAvisos,
    capacidadVerActividad,
  }));
  final ane = PoliticaEspacio(sesion('ane', {
    capacidadAnadirPuntos,
    capacidadEnviarPeticiones,
    capacidadCrearAvisos,
  }));

  test('modo local: todo permitido', () {
    const local = PoliticaEspacio(null);
    expect(local.puedeEditarEspacio, isTrue);
    expect(local.puedeGestionarProyectos, isTrue);
    expect(local.puedeVerActividad, isTrue);
  });

  test('tester añade y mueve puntos, pero no borra ni toca fincas y zonas', () {
    expect(ane.puedeAnadirPuntos, isTrue);
    expect(ane.puedeMoverPuntos, isTrue);
    expect(ane.puedeBorrarPuntos, isFalse);
    expect(ane.puedeEditarEspacio, isFalse);
    expect(coordinacion.puedeBorrarPuntos, isTrue);
  });

  test('seguimiento: tester en su proyecto abierto; coordinación siempre', () {
    expect(ane.puedeRegistrarEnProyecto(personaUidProyecto: 'ane', cerrado: false), isTrue);
    expect(ane.puedeRegistrarEnProyecto(personaUidProyecto: 'ane', cerrado: true), isFalse);
    expect(ane.puedeRegistrarEnProyecto(personaUidProyecto: 'jon', cerrado: false), isFalse);
    expect(coordinacion.puedeRegistrarEnProyecto(personaUidProyecto: 'jon', cerrado: true), isTrue);
    expect(ane.puedeGestionarProyectos, isFalse);
  });

  test('peticiones y avisos', () {
    expect(ane.puedeEnviarPeticiones, isTrue);
    expect(ane.puedeGestionarPeticiones, isFalse);
    expect(ane.puedeCrearAvisos, isTrue);
    expect(ane.puedeEditarAviso('ane'), isTrue);
    expect(ane.puedeEditarAviso('jon'), isFalse);
    expect(coordinacion.puedeEditarAviso('jon'), isTrue);
    expect(ane.puedeVerActividad, isFalse);
  });
}
