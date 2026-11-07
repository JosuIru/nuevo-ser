import 'dart:convert';

/// Un sorteo de lotes de leña vecinal («suertes», «fogueras») de una
/// campaña. Cómo se sortea está en `dominio/sorteo_lena.dart`.
///
/// Orden del procedimiento, para que nadie pueda amañarlo:
/// 1. la junta cierra la **lista de participantes** (la app guarda su huella);
/// 2. se fija la **semilla** desde una fuente pública posterior al cierre
///    (p. ej., el número premiado de un sorteo público de una fecha dada) y
///    se publica;
/// 3. se sortea: el resultado sale solo de la lista y la semilla, y
///    cualquiera puede repetirlo.
///
/// Una vez realizado ([realizado]), la lista y la semilla no se cambian.
class SorteoLena {
  SorteoLena({
    this.id,
    required this.campanya,
    this.nombre = '',
    this.participantes = const [],
    this.semilla = '',
    this.origenSemilla = '',
    this.fechaCierreListaMs,
    this.fechaSorteoMs,
    this.huellaParticipantes = '',
    this.realizado = false,
    this.aprovechamientoId,
    this.notas = '',
  });

  final int? id;
  final int campanya;
  final String nombre;

  /// Personas o casas con derecho a lote, en el orden de la lista de la
  /// junta. Quién tiene derecho lo deciden la ordenanza o los estatutos.
  final List<String> participantes;

  /// Texto público del que sale el orden. Vacío hasta fijarla.
  final String semilla;

  /// De dónde sale la semilla (para que se pueda comprobar).
  final String origenSemilla;
  final int? fechaCierreListaMs;
  final int? fechaSorteoMs;

  /// SHA-256 de la lista cerrada, para publicarla antes de la semilla.
  final String huellaParticipantes;
  final bool realizado;

  /// Aprovechamiento de leña al que pertenecen los lotes (opcional).
  final int? aprovechamientoId;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'campanya': campanya,
        'nombre': nombre,
        'participantes_json': jsonEncode(participantes),
        'semilla': semilla,
        'origen_semilla': origenSemilla,
        'fecha_cierre_lista_ms': fechaCierreListaMs,
        'fecha_sorteo_ms': fechaSorteoMs,
        'huella_participantes': huellaParticipantes,
        'realizado': realizado ? 1 : 0,
        'aprovechamiento_id': aprovechamientoId,
        'notas': notas,
      };

  factory SorteoLena.fromMap(Map<String, Object?> mapa) => SorteoLena(
        id: mapa['id'] as int?,
        campanya: mapa['campanya'] as int,
        nombre: (mapa['nombre'] as String?) ?? '',
        participantes: leerParticipantes(mapa['participantes_json'] as String?),
        semilla: (mapa['semilla'] as String?) ?? '',
        origenSemilla: (mapa['origen_semilla'] as String?) ?? '',
        fechaCierreListaMs: mapa['fecha_cierre_lista_ms'] as int?,
        fechaSorteoMs: mapa['fecha_sorteo_ms'] as int?,
        huellaParticipantes: (mapa['huella_participantes'] as String?) ?? '',
        realizado: (mapa['realizado'] as int?) == 1,
        aprovechamientoId: mapa['aprovechamiento_id'] as int?,
        notas: (mapa['notas'] as String?) ?? '',
      );

  SorteoLena copiarCon({
    List<String>? participantes,
    String? semilla,
    String? origenSemilla,
    int? fechaCierreListaMs,
    int? fechaSorteoMs,
    String? huellaParticipantes,
    bool? realizado,
  }) =>
      SorteoLena(
        id: id,
        campanya: campanya,
        nombre: nombre,
        participantes: participantes ?? this.participantes,
        semilla: semilla ?? this.semilla,
        origenSemilla: origenSemilla ?? this.origenSemilla,
        fechaCierreListaMs: fechaCierreListaMs ?? this.fechaCierreListaMs,
        fechaSorteoMs: fechaSorteoMs ?? this.fechaSorteoMs,
        huellaParticipantes: huellaParticipantes ?? this.huellaParticipantes,
        realizado: realizado ?? this.realizado,
        aprovechamientoId: aprovechamientoId,
        notas: notas,
      );
}

/// Lista vacía si el JSON está roto (defensivo con datos antiguos).
List<String> leerParticipantes(String? json) {
  try {
    final crudo = jsonDecode(json ?? '[]');
    if (crudo is! List) return const [];
    return crudo.whereType<String>().toList();
  } catch (_) {
    return const [];
  }
}

/// Un lote de leña: el trozo de monte con su volumen orientativo. El
/// adjudicatario lo pone el sorteo.
class LoteLena {
  LoteLena({
    this.id,
    required this.sorteoId,
    required this.numero,
    this.rodalId,
    this.cantidad,
    this.unidad = 'estereos',
    this.descripcion = '',
    this.adjudicatario = '',
  });

  final int? id;
  final int sorteoId;

  /// Número del lote (1, 2, 3…), único dentro del sorteo.
  final int numero;
  final int? rodalId;

  /// Volumen orientativo del lote; null = sin estimar.
  final double? cantidad;

  /// Normalmente estéreos (ver `unidades_volumen.csv`).
  final String unidad;

  /// Dónde está (paraje, marcas, pintura…).
  final String descripcion;

  /// Lo pone el sorteo; vacío = sin adjudicar.
  final String adjudicatario;

  bool get adjudicado => adjudicatario.isNotEmpty;

  LoteLena conAdjudicatario(String nuevoAdjudicatario) =>
      LoteLena.fromMap({...toMap(), 'adjudicatario': nuevoAdjudicatario});

  Map<String, Object?> toMap() => {
        'id': id,
        'sorteo_id': sorteoId,
        'numero': numero,
        'rodal_id': rodalId,
        'cantidad': cantidad,
        'unidad': unidad,
        'descripcion': descripcion,
        'adjudicatario': adjudicatario,
      };

  factory LoteLena.fromMap(Map<String, Object?> mapa) => LoteLena(
        id: mapa['id'] as int?,
        sorteoId: mapa['sorteo_id'] as int,
        numero: mapa['numero'] as int,
        rodalId: mapa['rodal_id'] as int?,
        cantidad: (mapa['cantidad'] as num?)?.toDouble(),
        unidad: (mapa['unidad'] as String?) ?? 'estereos',
        descripcion: (mapa['descripcion'] as String?) ?? '',
        adjudicatario: (mapa['adjudicatario'] as String?) ?? '',
      );
}
