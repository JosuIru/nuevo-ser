import 'codificacion.dart';

const List<String> materialesKupela = ['madera', 'inoxidable', 'otro'];

/// Lo que guarda: sidra (de manzana) o txakoli (de uva).
const List<String> productosKupela = ['sidra', 'txakoli'];

/// Calificación de la partida por el órgano de control de la DOP: la anota
/// la persona, la app no califica nada.
const List<String> calificacionesKupela = [
  'pendiente',
  'apta',
  'descalificada',
];

/// Kupela, upel o depósito. El pliego de Euskal Sagardoa considera cada
/// depósito identificado una partida.
class Kupela {
  Kupela({
    this.id,
    required this.codigo,
    required this.capacidadLitros,
    this.nombre = '',
    this.material = 'madera',
    this.producto = 'sidra',
    this.calificacion = 'pendiente',
    this.activa = true,
    this.notas = '',
  });

  final int? id;

  /// Código pintado en la kupela («K-7», «3»…). Único.
  final String codigo;
  final double capacidadLitros;
  final String nombre;
  final String material;
  final String producto;
  final String calificacion;

  /// False si se ha retirado (no sale en las listas de hoy).
  final bool activa;
  final String notas;

  String get etiqueta => nombre.isEmpty ? codigo : '$codigo · $nombre';

  bool get estaDescalificada => calificacion == 'descalificada';

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'capacidad_litros': capacidadLitros,
        'nombre': nombre,
        'material': material,
        'producto': producto,
        'calificacion': calificacion,
        'activa': activa ? 1 : 0,
        'notas': notas,
      };

  factory Kupela.fromMap(Map<String, Object?> mapa) => Kupela(
        id: mapa['id'] as int?,
        codigo: mapa['codigo'] as String,
        capacidadLitros: comoDecimal(mapa['capacidad_litros']) ?? 0,
        nombre: (mapa['nombre'] as String?) ?? '',
        material: materialesKupela.contains(mapa['material'])
            ? mapa['material'] as String
            : 'otro',
        producto: mapa['producto'] == 'txakoli' ? 'txakoli' : 'sidra',
        calificacion: calificacionesKupela.contains(mapa['calificacion'])
            ? mapa['calificacion'] as String
            : 'pendiente',
        activa: (mapa['activa'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Seguimiento de la fermentación: densidad, temperatura y acidez volátil
/// (la que la DOP limita), y si se analizó, grado y sulfuroso.
class MedicionKupela {
  MedicionKupela({
    this.id,
    required this.kupelaId,
    required this.fechaMs,
    this.densidad,
    this.temperaturaC,
    this.acidezVolatilGL,
    this.gradoAlcoholico,
    this.sulfurosoTotalMgL,
    this.notas = '',
  });

  final int? id;
  final int kupelaId;
  final int fechaMs;
  final double? densidad;
  final double? temperaturaC;

  /// Acidez volátil en g/l de ácido acético.
  final double? acidezVolatilGL;

  /// % vol.
  final double? gradoAlcoholico;
  final double? sulfurosoTotalMgL;
  final String notas;

  bool get estaVacia =>
      densidad == null &&
      temperaturaC == null &&
      acidezVolatilGL == null &&
      gradoAlcoholico == null &&
      sulfurosoTotalMgL == null;

  Map<String, Object?> toMap() => {
        'id': id,
        'kupela_id': kupelaId,
        'fecha_ms': fechaMs,
        'densidad': densidad,
        'temperatura_c': temperaturaC,
        'acidez_volatil_g_l': acidezVolatilGL,
        'grado_alcoholico': gradoAlcoholico,
        'sulfuroso_total_mg_l': sulfurosoTotalMgL,
        'notas': notas,
      };

  factory MedicionKupela.fromMap(Map<String, Object?> mapa) => MedicionKupela(
        id: mapa['id'] as int?,
        kupelaId: mapa['kupela_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        densidad: comoDecimal(mapa['densidad']),
        temperaturaC: comoDecimal(mapa['temperatura_c']),
        acidezVolatilGL: comoDecimal(mapa['acidez_volatil_g_l']),
        gradoAlcoholico: comoDecimal(mapa['grado_alcoholico']),
        sulfurosoTotalMgL: comoDecimal(mapa['sulfuroso_total_mg_l']),
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Trasiego de una kupela a otra. Sin destino: lo que se retira (lías,
/// merma, vertido).
class Trasiego {
  Trasiego({
    this.id,
    required this.fechaMs,
    required this.kupelaOrigenId,
    this.kupelaDestinoId,
    required this.litros,
    this.motivo = '',
  });

  final int? id;
  final int fechaMs;
  final int kupelaOrigenId;
  final int? kupelaDestinoId;
  final double litros;
  final String motivo;

  bool get esRetirada => kupelaDestinoId == null;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'kupela_origen_id': kupelaOrigenId,
        'kupela_destino_id': kupelaDestinoId,
        'litros': litros,
        'motivo': motivo,
      };

  factory Trasiego.fromMap(Map<String, Object?> mapa) => Trasiego(
        id: mapa['id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        kupelaOrigenId: mapa['kupela_origen_id'] as int,
        kupelaDestinoId: mapa['kupela_destino_id'] as int?,
        litros: comoDecimal(mapa['litros']) ?? 0,
        motivo: (mapa['motivo'] as String?) ?? '',
      );
}
