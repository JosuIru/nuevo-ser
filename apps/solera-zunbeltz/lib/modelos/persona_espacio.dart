/// Capacidades que concede el servidor (plugin `solera-zunbeltz-sync`,
/// `includes/roles.php`). La app no conoce los roles, sólo capacidades:
/// un rol nuevo en el servidor funciona sin publicar otra versión de la app
/// mientras reutilice estas capacidades.
const String capacidadVerTodasTareas = 'ver_todas_tareas';
const String capacidadCrearTareas = 'crear_tareas';
const String capacidadEditarCualquierTarea = 'editar_cualquier_tarea';
const String capacidadAsignarTareas = 'asignar_tareas';

/// Una persona del Espacio Test, tal como la da de alta la coordinación en
/// el WordPress. Se usa para elegir responsable de una tarea.
class PersonaEspacio {
  const PersonaEspacio({
    required this.uid,
    required this.nombre,
    this.rol = '',
    this.etiquetaRol = '',
  });

  final String uid;
  final String nombre;

  /// Código del rol (`coordinador`, `tester`…). Sólo informativo: los
  /// permisos se deciden por capacidades, ver [SesionEspacio].
  final String rol;

  /// Nombre legible del rol, tal como lo define el servidor.
  final String etiquetaRol;

  Map<String, Object?> toJson() => {
        'uid': uid,
        'nombre': nombre,
        'rol': rol,
        'etiqueta_rol': etiquetaRol,
      };

  factory PersonaEspacio.fromJson(Map<String, Object?> json) => PersonaEspacio(
        uid: (json['uid'] as String?) ?? '',
        nombre: (json['nombre'] as String?) ?? '',
        rol: (json['rol'] as String?) ?? '',
        etiquetaRol: (json['etiqueta_rol'] as String?) ?? '',
      );
}

/// Quién está usando la app en este dispositivo y qué puede hacer, según
/// el último `GET /yo` o sincronización. Sin sesión (sincronización sin
/// configurar) la app funciona en modo local, sin restricciones.
class SesionEspacio {
  const SesionEspacio({required this.persona, required this.capacidades});

  final PersonaEspacio persona;
  final Set<String> capacidades;

  bool puede(String capacidad) => capacidades.contains(capacidad);

  Map<String, Object?> toJson() => {
        ...persona.toJson(),
        'capacidades': capacidades.toList(),
      };

  factory SesionEspacio.fromJson(Map<String, Object?> json) => SesionEspacio(
        persona: PersonaEspacio.fromJson(json),
        capacidades: {
          for (final capacidad in (json['capacidades'] as List?) ?? const [])
            if (capacidad is String) capacidad,
        },
      );
}
