const String estadoProyectoAbierto = 'abierto';
const String estadoProyectoCerrado = 'cerrado';

/// Un proyecto de test: el proceso que prueba una persona tester en el
/// Espacio Test. Es el eje del seguimiento (producción, validación de
/// producto, comercialización y económico se cuelgan del proyecto). La
/// finca es de apoyo (dónde lo desarrolla), opcional.
class ProyectoTest {
  ProyectoTest({
    this.id,
    this.nombre = '',
    this.persona = '',
    this.actividad = '',
    this.fincaId,
    this.fechaInicioMs,
    this.fechaFinMs,
    this.notas = '',
    this.fechaCreacionMs = 0,
    this.personaUid = '',
    this.estado = estadoProyectoAbierto,
    this.cerradoMs,
    this.porcentajeBeneficioZunbeltz = 25,
    this.porcentajePerdidaZunbeltz = 50,
    this.valoracionZunbeltz,
    this.valoracionTester,
  });

  final int? id;

  /// Nombre del proyecto de test.
  final String nombre;

  /// Persona tester que lo lleva.
  final String persona;

  /// Actividad o vertical productiva (p. ej. «ovino de leche», «huerta»).
  final String actividad;

  /// Finca de apoyo donde se desarrolla (opcional).
  final int? fincaId;

  final int? fechaInicioMs;
  final int? fechaFinMs;
  final String notas;
  final int fechaCreacionMs;

  /// Persona tester del espacio (`uid` del WordPress). Decide quién ve el
  /// proyecto y quién apunta en él. Vacío en modo local.
  final String personaUid;

  /// `abierto` o `cerrado`. Cerrado por coordinación: la persona tester ya
  /// no apunta y los informes dejan de ser borrador.
  final String estado;
  final int? cerradoMs;

  /// Reparto del resultado del balance del test (convenio, art. 7): % para
  /// Zunbeltz si hay beneficio (25) y si hay pérdida (50). El resto, tester.
  final int porcentajeBeneficioZunbeltz;
  final int porcentajePerdidaZunbeltz;

  /// Valoración general de la implicación, 0-10 (anexo IV), de cada parte.
  final int? valoracionZunbeltz;
  final int? valoracionTester;

  bool get cerrado => estado == estadoProyectoCerrado;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'persona': persona,
        'actividad': actividad,
        'finca_id': fincaId,
        'fecha_inicio_ms': fechaInicioMs,
        'fecha_fin_ms': fechaFinMs,
        'notas': notas,
        'fecha_creacion_ms': fechaCreacionMs,
        'persona_uid': personaUid,
        'estado': estado,
        'cerrado_ms': cerradoMs,
        'porcentaje_beneficio_zunbeltz': porcentajeBeneficioZunbeltz,
        'porcentaje_perdida_zunbeltz': porcentajePerdidaZunbeltz,
        'valoracion_zunbeltz': valoracionZunbeltz,
        'valoracion_tester': valoracionTester,
      };

  factory ProyectoTest.fromMap(Map<String, Object?> mapa) => ProyectoTest(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        persona: (mapa['persona'] as String?) ?? '',
        actividad: (mapa['actividad'] as String?) ?? '',
        fincaId: mapa['finca_id'] as int?,
        fechaInicioMs: mapa['fecha_inicio_ms'] as int?,
        fechaFinMs: mapa['fecha_fin_ms'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
        fechaCreacionMs: (mapa['fecha_creacion_ms'] as int?) ?? 0,
        personaUid: (mapa['persona_uid'] as String?) ?? '',
        estado: (mapa['estado'] as String?) ?? estadoProyectoAbierto,
        cerradoMs: mapa['cerrado_ms'] as int?,
        porcentajeBeneficioZunbeltz:
            (mapa['porcentaje_beneficio_zunbeltz'] as int?) ?? 25,
        porcentajePerdidaZunbeltz:
            (mapa['porcentaje_perdida_zunbeltz'] as int?) ?? 50,
        valoracionZunbeltz: mapa['valoracion_zunbeltz'] as int?,
        valoracionTester: mapa['valoracion_tester'] as int?,
      );
}
