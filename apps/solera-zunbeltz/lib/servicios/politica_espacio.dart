import '../modelos/persona_espacio.dart';

/// Qué puede hacer la persona conectada con todo lo que no son tareas:
/// fincas, zonas, puntos, proyectos, peticiones y avisos. Replica las
/// reglas del servidor (`wp-plugin/solera-zunbeltz-sync/includes/entidades.php`)
/// solo para no ofrecer lo que se va a rechazar; **quien manda es el
/// servidor**, que deshace al sincronizar lo no permitido.
///
/// Sin sesión ([sesion] `null`: sincronización sin configurar) la app está
/// en modo local de un solo dispositivo y todo está permitido.
class PoliticaEspacio {
  const PoliticaEspacio(this.sesion);

  final SesionEspacio? sesion;

  bool get modoLocal => sesion == null;

  String get miUid => sesion?.persona.uid ?? '';

  bool _puede(String capacidad) => sesion?.puede(capacidad) ?? true;

  /// Crear, editar y borrar fincas y zonas; editar y borrar cualquier punto.
  bool get puedeEditarEspacio => _puede(capacidadEditarEspacio);

  /// Añadir puntos (un corral móvil nuevo, un bidón…).
  bool get puedeAnadirPuntos =>
      puedeEditarEspacio || _puede(capacidadAnadirPuntos);

  /// Recolocar un punto o cambiar su estado y notas.
  bool get puedeMoverPuntos => puedeAnadirPuntos;

  bool get puedeBorrarPuntos => puedeEditarEspacio;

  /// Ver todos los proyectos y llevar lo que es solo de coordinación
  /// (ficha del proyecto, presupuesto, fianza, acompañamiento, incidencias
  /// de cumplimiento, cierre).
  bool get puedeGestionarProyectos => _puede(capacidadGestionarProyectos);

  /// Apuntar seguimiento (producción, ventas, validaciones, gastos) en un
  /// proyecto: coordinación siempre; la persona tester en el suyo mientras
  /// esté abierto.
  bool puedeRegistrarEnProyecto({
    required String personaUidProyecto,
    required bool cerrado,
  }) =>
      puedeGestionarProyectos ||
      (!cerrado && miUid.isNotEmpty && personaUidProyecto == miUid);

  bool get puedeEnviarPeticiones =>
      _puede(capacidadEnviarPeticiones) || puedeGestionarPeticiones;

  bool get puedeGestionarPeticiones => _puede(capacidadGestionarPeticiones);

  bool get puedeCrearAvisos =>
      _puede(capacidadCrearAvisos) || puedeGestionarAvisos;

  bool get puedeGestionarAvisos => _puede(capacidadGestionarAvisos);

  /// Resolver o editar un aviso: quien lo dio o quien gestiona avisos.
  bool puedeEditarAviso(String autorUid) =>
      puedeGestionarAvisos || (miUid.isNotEmpty && autorUid == miUid);

  bool get puedeVerActividad => _puede(capacidadVerActividad);

  /// Los documentos salen sin marca de BORRADOR solo cuando los genera
  /// coordinación identificada (no en modo local) y, si son de un proyecto,
  /// con el proyecto cerrado (respuestas de Zunbeltz, 2026-10-06).
  bool documentoDefinitivo({bool? proyectoCerrado}) =>
      !modoLocal && puedeGestionarProyectos && (proyectoCerrado ?? true);
}
