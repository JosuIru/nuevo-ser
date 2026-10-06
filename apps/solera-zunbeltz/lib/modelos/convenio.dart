import 'constantes.dart';

/// Lo que el convenio tester (art. 7-8 y anexos II y IV) añade al
/// seguimiento de un proyecto. Solo lo escribe coordinación; la persona
/// tester lo ve en su proyecto.

/// Partida del presupuesto inicial del proyecto (anexo II): lo previsto,
/// para compararlo con lo gastado.
class PartidaPresupuesto {
  PartidaPresupuesto({
    this.id,
    required this.proyectoId,
    this.categoria = '',
    this.concepto = '',
    this.asumidoPor = asumidoPorTester,
    this.esAmortizacion = false,
    this.importeCentimos = 0,
    this.notas = '',
  });

  final int? id;
  final int proyectoId;
  final String categoria;
  final String concepto;
  final String asumidoPor;
  final bool esAmortizacion;
  final int importeCentimos;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'proyecto_id': proyectoId,
        'categoria': categoria,
        'concepto': concepto,
        'asumido_por': asumidoPor,
        'es_amortizacion': esAmortizacion ? 1 : 0,
        'importe_centimos': importeCentimos,
        'notas': notas,
      };

  factory PartidaPresupuesto.fromMap(Map<String, Object?> mapa) =>
      PartidaPresupuesto(
        id: mapa['id'] as int?,
        proyectoId: (mapa['proyecto_id'] as int?) ?? 0,
        categoria: (mapa['categoria'] as String?) ?? '',
        concepto: (mapa['concepto'] as String?) ?? '',
        asumidoPor: (mapa['asumido_por'] as String?) ?? asumidoPorTester,
        esAmortizacion: ((mapa['es_amortizacion'] as int?) ?? 0) != 0,
        importeCentimos: (mapa['importe_centimos'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Depósito, devolución o retención de la fianza.
class MovimientoFianza {
  MovimientoFianza({
    this.id,
    required this.proyectoId,
    this.tipo = 'deposito',
    this.importeCentimos = 0,
    this.fechaMs = 0,
    this.notas = '',
  });

  final int? id;
  final int proyectoId;

  /// `deposito` · `devolucion` · `retencion`.
  final String tipo;
  final int importeCentimos;
  final int fechaMs;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'proyecto_id': proyectoId,
        'tipo': tipo,
        'importe_centimos': importeCentimos,
        'fecha_ms': fechaMs,
        'notas': notas,
      };

  factory MovimientoFianza.fromMap(Map<String, Object?> mapa) =>
      MovimientoFianza(
        id: mapa['id'] as int?,
        proyectoId: (mapa['proyecto_id'] as int?) ?? 0,
        tipo: (mapa['tipo'] as String?) ?? 'deposito',
        importeCentimos: (mapa['importe_centimos'] as int?) ?? 0,
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Actividad de acompañamiento del anexo IV (formación, reunión, visita…),
/// con si la persona tester asistió.
class Acompanamiento {
  Acompanamiento({
    this.id,
    required this.proyectoId,
    this.tipo = 'reunion',
    this.fechaMs = 0,
    this.descripcion = '',
    this.asistencia = 'propuesta',
    this.horas,
    this.notas = '',
  });

  final int? id;
  final int proyectoId;

  /// Código de [tiposAcompanamiento].
  final String tipo;
  final int fechaMs;
  final String descripcion;

  /// `propuesta` · `asistida` · `no_asistida`.
  final String asistencia;

  /// Horas dedicadas (búsqueda de canales, apoyo en tareas…).
  final double? horas;
  final String notas;

  bool get asistida => asistencia == 'asistida';

  Map<String, Object?> toMap() => {
        'id': id,
        'proyecto_id': proyectoId,
        'tipo': tipo,
        'fecha_ms': fechaMs,
        'descripcion': descripcion,
        'asistencia': asistencia,
        'horas': horas,
        'notas': notas,
      };

  factory Acompanamiento.fromMap(Map<String, Object?> mapa) => Acompanamiento(
        id: mapa['id'] as int?,
        proyectoId: (mapa['proyecto_id'] as int?) ?? 0,
        tipo: (mapa['tipo'] as String?) ?? 'reunion',
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
        descripcion: (mapa['descripcion'] as String?) ?? '',
        asistencia: (mapa['asistencia'] as String?) ?? 'propuesta',
        horas: (mapa['horas'] as num?)?.toDouble(),
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Incidencia de cumplimiento del convenio (art. 8): leve, grave o muy
/// grave, con la retención de fianza que conlleve. Dato personal sensible:
/// solo la ven coordinación y la persona tester afectada.
class IncidenciaCumplimiento {
  IncidenciaCumplimiento({
    this.id,
    required this.proyectoId,
    this.nivel = 'leve',
    this.fechaMs = 0,
    this.descripcion = '',
    this.retencionCentimos = 0,
    this.notas = '',
  });

  final int? id;
  final int proyectoId;

  /// `leve` · `grave` · `muy_grave`.
  final String nivel;
  final int fechaMs;
  final String descripcion;
  final int retencionCentimos;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'proyecto_id': proyectoId,
        'nivel': nivel,
        'fecha_ms': fechaMs,
        'descripcion': descripcion,
        'retencion_centimos': retencionCentimos,
        'notas': notas,
      };

  factory IncidenciaCumplimiento.fromMap(Map<String, Object?> mapa) =>
      IncidenciaCumplimiento(
        id: mapa['id'] as int?,
        proyectoId: (mapa['proyecto_id'] as int?) ?? 0,
        nivel: (mapa['nivel'] as String?) ?? 'leve',
        fechaMs: (mapa['fecha_ms'] as int?) ?? 0,
        descripcion: (mapa['descripcion'] as String?) ?? '',
        retencionCentimos: (mapa['retencion_centimos'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
