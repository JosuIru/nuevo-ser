/// Tipos de aprovechamiento: la lista del art. 6.i de la Ley 43/2003
/// (consolidado BOE, actualizado el 09/11/2024), más «otros».
const List<String> tiposAprovechamiento = [
  'madera',
  'lena',
  'biomasa',
  'corcho',
  'resina',
  'pastos',
  'caza',
  'frutos',
  'hongos',
  'aromaticas',
  'apicolas',
  'otros',
];

/// Los maderables y leñosos del art. 37 (declaración o autorización).
const List<String> tiposMaderablesYLenosos = ['madera', 'lena', 'biomasa'];

/// Unidades en las que se apunta lo aprovechado.
const List<String> unidadesAprovechamiento = [
  'm3',
  'estereos',
  'toneladas',
  'kg',
  'hectareas',
  'cabezas',
  'colmenas',
  'unidades',
];

/// Cómo se reparte o se vende.
const List<String> modalidadesAprovechamiento = [
  'lotes_vecinales',
  'subasta',
  'adjudicacion_directa',
  'uso_propio',
  'otra',
];

/// Trámite ante el órgano forestal de la comunidad autónoma. La app **no
/// decide** cuál toca (Ley 43/2003, arts. 36.3 y 37.2, y la norma de cada
/// CA): apunta el que se ha hecho.
const List<String> tramitesAprovechamiento = [
  'pendiente',
  'declaracion_responsable',
  'autorizacion',
  'comunicacion',
  'otro',
];

/// Un aprovechamiento del monte en una campaña.
class Aprovechamiento {
  Aprovechamiento({
    this.id,
    required this.campanya,
    this.rodalId,
    required this.tipo,
    required this.fechaInicioMs,
    this.fechaFinMs,
    this.cantidadPrevista,
    this.cantidad = 0,
    this.unidad = 'm3',
    this.modalidad = 'uso_propio',
    this.adjudicatario = '',
    this.tramite = 'pendiente',
    this.referenciaTramite = '',
    this.comercializado = false,
    this.fechaComunicacionCuantiaMs,
    this.notas = '',
  });

  final int? id;

  /// Año de la campaña (la de leña puede empezar en otoño y acabar en
  /// primavera: se apunta en el año en que empieza).
  final int campanya;
  final int? rodalId;

  /// Uno de [tiposAprovechamiento].
  final String tipo;
  final int fechaInicioMs;

  /// Fin del aprovechamiento; null = en curso.
  final int? fechaFinMs;

  /// Lo que se pidió o se previó (en [unidad]); null = sin dato.
  final double? cantidadPrevista;

  /// Lo obtenido de verdad (en [unidad]).
  final double cantidad;

  /// Uno de [unidadesAprovechamiento].
  final String unidad;

  /// Uno de [modalidadesAprovechamiento].
  final String modalidad;

  /// Rematante, ganadero, vecino o «lotes vecinales».
  final String adjudicatario;

  /// Uno de [tramitesAprovechamiento] y su número de expediente.
  final String tramite;
  final String referenciaTramite;

  /// Los productos se venden (art. 37.4: comunicar la cuantía obtenida).
  final bool comercializado;

  /// Cuándo se comunicó la cuantía realmente obtenida; null = no consta.
  final int? fechaComunicacionCuantiaMs;
  final String notas;

  bool get esMaderableOLenoso => tiposMaderablesYLenosos.contains(tipo);
  bool get terminado => fechaFinMs != null;

  Map<String, Object?> toMap() => {
        'id': id,
        'campanya': campanya,
        'rodal_id': rodalId,
        'tipo': tipo,
        'fecha_inicio_ms': fechaInicioMs,
        'fecha_fin_ms': fechaFinMs,
        'cantidad_prevista': cantidadPrevista,
        'cantidad': cantidad,
        'unidad': unidad,
        'modalidad': modalidad,
        'adjudicatario': adjudicatario,
        'tramite': tramite,
        'referencia_tramite': referenciaTramite,
        'comercializado': comercializado ? 1 : 0,
        'fecha_comunicacion_cuantia_ms': fechaComunicacionCuantiaMs,
        'notas': notas,
      };

  factory Aprovechamiento.fromMap(Map<String, Object?> mapa) => Aprovechamiento(
        id: mapa['id'] as int?,
        campanya: mapa['campanya'] as int,
        rodalId: mapa['rodal_id'] as int?,
        tipo: tiposAprovechamiento.contains(mapa['tipo'])
            ? mapa['tipo'] as String
            : 'otros',
        fechaInicioMs: mapa['fecha_inicio_ms'] as int,
        fechaFinMs: mapa['fecha_fin_ms'] as int?,
        cantidadPrevista: (mapa['cantidad_prevista'] as num?)?.toDouble(),
        cantidad: (mapa['cantidad'] as num?)?.toDouble() ?? 0,
        unidad: unidadesAprovechamiento.contains(mapa['unidad'])
            ? mapa['unidad'] as String
            : 'unidades',
        modalidad: modalidadesAprovechamiento.contains(mapa['modalidad'])
            ? mapa['modalidad'] as String
            : 'otra',
        adjudicatario: (mapa['adjudicatario'] as String?) ?? '',
        tramite: tramitesAprovechamiento.contains(mapa['tramite'])
            ? mapa['tramite'] as String
            : 'otro',
        referenciaTramite: (mapa['referencia_tramite'] as String?) ?? '',
        comercializado: (mapa['comercializado'] as int?) == 1,
        fechaComunicacionCuantiaMs:
            mapa['fecha_comunicacion_cuantia_ms'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
