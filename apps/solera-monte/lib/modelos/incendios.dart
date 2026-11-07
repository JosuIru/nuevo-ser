import 'contorno.dart';

/// Infraestructuras de prevención y defensa contra incendios.
const List<String> tiposInfraestructuraIncendios = [
  'pista',
  'punto_agua',
  'cortafuegos',
  'faja_auxiliar',
  'otra',
];

/// Las que son una línea (se trazan caminando) y no un punto.
const List<String> tiposInfraestructuraLineal = [
  'pista',
  'cortafuegos',
  'faja_auxiliar',
];

/// Resultado de la revisión de una infraestructura.
const List<String> estadosRevision = [
  'correcto',
  'necesita_mantenimiento',
  'no_utilizable',
];

/// Pista, punto de agua, cortafuegos o faja del monte.
class InfraestructuraIncendios {
  InfraestructuraIncendios({
    this.id,
    required this.tipo,
    required this.nombre,
    this.latitud,
    this.longitud,
    this.traza = const [],
    this.longitudM,
    this.anchoM,
    this.capacidadM3,
    this.activa = true,
    this.notas = '',
  });

  final int? id;

  /// Uno de [tiposInfraestructuraIncendios].
  final String tipo;
  final String nombre;

  /// Punto (un punto de agua, el arranque de una pista).
  final double? latitud;
  final double? longitud;

  /// Traza de una pista o un cortafuegos (vértices con el GPS).
  final List<(double, double)> traza;

  /// Longitud declarada (m); si no, la de la traza.
  final double? longitudM;
  final double? anchoM;

  /// Capacidad de un punto de agua (m³).
  final double? capacidadM3;
  final bool activa;
  final String notas;

  bool get esLineal => tiposInfraestructuraLineal.contains(tipo);
  bool get tieneUbicacion => latitud != null && longitud != null;

  InfraestructuraIncendios conUbicacion(double latitud, double longitud) =>
      InfraestructuraIncendios.fromMap(
          {...toMap(), 'latitud': latitud, 'longitud': longitud});

  InfraestructuraIncendios conTraza(List<(double, double)> nuevaTraza) =>
      InfraestructuraIncendios.fromMap(
          {...toMap(), 'traza': codificarContorno(nuevaTraza)});

  Map<String, Object?> toMap() => {
        'id': id,
        'tipo': tipo,
        'nombre': nombre,
        'latitud': latitud,
        'longitud': longitud,
        'traza': codificarContorno(traza),
        'longitud_m': longitudM,
        'ancho_m': anchoM,
        'capacidad_m3': capacidadM3,
        'activa': activa ? 1 : 0,
        'notas': notas,
      };

  factory InfraestructuraIncendios.fromMap(Map<String, Object?> mapa) =>
      InfraestructuraIncendios(
        id: mapa['id'] as int?,
        tipo: tiposInfraestructuraIncendios.contains(mapa['tipo'])
            ? mapa['tipo'] as String
            : 'otra',
        nombre: (mapa['nombre'] as String?) ?? '',
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        traza: leerContorno(mapa['traza'] as String?),
        longitudM: (mapa['longitud_m'] as num?)?.toDouble(),
        anchoM: (mapa['ancho_m'] as num?)?.toDouble(),
        capacidadM3: (mapa['capacidad_m3'] as num?)?.toDouble(),
        activa: (mapa['activa'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Revisión de una infraestructura (normalmente antes de la época de
/// peligro).
class RevisionIncendios {
  RevisionIncendios({
    this.id,
    required this.infraestructuraId,
    required this.fechaMs,
    this.estado = 'correcto',
    this.trabajosNecesarios = '',
    this.revisor = '',
    this.notas = '',
  });

  final int? id;
  final int infraestructuraId;
  final int fechaMs;

  /// Uno de [estadosRevision].
  final String estado;

  /// Lo que hay que hacer (desbrozar, limpiar cunetas, reparar la balsa…).
  final String trabajosNecesarios;
  final String revisor;
  final String notas;

  bool get pideTrabajo => estado != 'correcto';

  Map<String, Object?> toMap() => {
        'id': id,
        'infraestructura_id': infraestructuraId,
        'fecha_ms': fechaMs,
        'estado': estado,
        'trabajos_necesarios': trabajosNecesarios,
        'revisor': revisor,
        'notas': notas,
      };

  factory RevisionIncendios.fromMap(Map<String, Object?> mapa) =>
      RevisionIncendios(
        id: mapa['id'] as int?,
        infraestructuraId: mapa['infraestructura_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        estado: estadosRevision.contains(mapa['estado'])
            ? mapa['estado'] as String
            : 'necesita_mantenimiento',
        trabajosNecesarios: (mapa['trabajos_necesarios'] as String?) ?? '',
        revisor: (mapa['revisor'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
