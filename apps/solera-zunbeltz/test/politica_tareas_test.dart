// Tests de la política de tareas en la app. Replica las reglas del
// servidor (`wp-plugin/solera-zunbeltz-sync/includes/politica-tareas.php`,
// probadas en `tests/test_sync.php`): si una cambia, cambia la otra.

import 'package:flutter_test/flutter_test.dart';

import 'package:solera_zunbeltz/modelos/persona_espacio.dart';
import 'package:solera_zunbeltz/modelos/tarea_mantenimiento.dart';
import 'package:solera_zunbeltz/servicios/politica_tareas.dart';

void main() {
  SesionEspacio sesion(String uid, Set<String> capacidades) => SesionEspacio(
        persona: PersonaEspacio(uid: uid, nombre: uid),
        capacidades: capacidades,
      );

  final coordinacion = sesion('coord', {
    capacidadVerTodasTareas,
    capacidadCrearTareas,
    capacidadEditarCualquierTarea,
    capacidadAsignarTareas,
  });
  // Tester (reparto acordado el 2026-10-06): ninguna capacidad sobre
  // tareas; ve las suyas y las generales y las ejecuta.
  final ane = sesion('ane', const {});
  final jon = sesion('jon', const {});

  final tareaDeAne = TareaMantenimiento(
    fincaId: 1,
    titulo: 'Reparar cierre',
    responsableUid: 'ane',
    creadoPorUid: 'coord',
  );
  final tareaLibre = TareaMantenimiento(fincaId: 1, titulo: 'Desbrozar');

  test('modo local (sin sesión): todo permitido', () {
    const politica = PoliticaTareas(null);
    expect(politica.modoLocal, isTrue);
    expect(politica.puedeCrear, isTrue);
    expect(politica.puedeAsignarAOtras, isTrue);
    expect(politica.puedeEjecutar(tareaDeAne), isTrue);
    expect(politica.puedeEditarContenido(tareaDeAne), isTrue);
    expect(politica.puedeCogerse(tareaLibre), isFalse,
        reason: 'sin sesión no hay "yo" al que asignarla');
  });

  test('coordinación edita, ejecuta y asigna cualquier tarea', () {
    final politica = PoliticaTareas(coordinacion);
    expect(politica.puedeAsignarAOtras, isTrue);
    expect(politica.puedeEjecutar(tareaDeAne), isTrue);
    expect(politica.puedeEditarContenido(tareaDeAne), isTrue);
  });

  test('la responsable ejecuta su tarea pero no edita su contenido', () {
    final politica = PoliticaTareas(ane);
    expect(politica.puedeEjecutar(tareaDeAne), isTrue);
    expect(politica.puedeEditarContenido(tareaDeAne), isFalse);
    expect(politica.puedeSoltar(tareaDeAne), isTrue);
    expect(politica.puedeAsignarAOtras, isFalse);
  });

  test('un tester no toca tareas ajenas, pero se coge las libres', () {
    final politica = PoliticaTareas(jon);
    expect(politica.puedeEjecutar(tareaDeAne), isFalse);
    expect(politica.puedeSoltar(tareaDeAne), isFalse);
    expect(politica.puedeCogerse(tareaDeAne), isFalse);
    expect(politica.puedeCogerse(tareaLibre), isTrue);
  });

  test('un tester no crea tareas (las pide)', () {
    expect(PoliticaTareas(ane).puedeCrear, isFalse);
    expect(PoliticaTareas(coordinacion).puedeCrear, isTrue);
  });

  test('visibilidad: tester ve las suyas y las generales; coordinación, todas',
      () {
    final deJon = PoliticaTareas(jon);
    expect(deJon.tareaVisible(tareaDeAne), isFalse);
    expect(deJon.tareaVisible(tareaLibre), isTrue,
        reason: 'general = sin responsable');
    expect(PoliticaTareas(ane).tareaVisible(tareaDeAne), isTrue);
    expect(
        deJon.tareaVisible(TareaMantenimiento(
            fincaId: 1, responsableUid: 'ane', creadoPorUid: 'jon')),
        isTrue,
        reason: 'las que creó antes del reparto nuevo');
    expect(PoliticaTareas(coordinacion).tareaVisible(tareaDeAne), isTrue);
    expect(const PoliticaTareas(null).tareaVisible(tareaDeAne), isTrue);
  });

  test('quien crea una tarea la edita y ejecuta aunque no la tenga asignada',
      () {
    final creadaPorJon = TareaMantenimiento(
        fincaId: 1, titulo: 'Cierre roto', creadoPorUid: 'jon');
    final politica = PoliticaTareas(jon);
    expect(politica.puedeEjecutar(creadaPorJon), isTrue);
    expect(politica.puedeEditarContenido(creadaPorJon), isTrue);
  });

  test('sin crear_tareas no se crean', () {
    expect(PoliticaTareas(sesion('lectora', {capacidadVerTodasTareas})).puedeCrear,
        isFalse);
  });

  test('SesionEspacio ida y vuelta por JSON', () {
    final json = SesionEspacio.fromJson({
      'uid': 'ane',
      'nombre': 'Ane',
      'rol': 'tester',
      'etiqueta_rol': 'Tester',
      'capacidades': ['crear_tareas', 'ver_todas_tareas'],
    }).toJson();
    final reconstruida = SesionEspacio.fromJson(json);
    expect(reconstruida.persona.nombre, 'Ane');
    expect(reconstruida.persona.etiquetaRol, 'Tester');
    expect(reconstruida.puede(capacidadCrearTareas), isTrue);
    expect(reconstruida.puede(capacidadAsignarTareas), isFalse);
  });
}
