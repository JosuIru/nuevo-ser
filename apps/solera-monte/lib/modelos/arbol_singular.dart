/// Qué se inventaría con un código QR.
const List<String> tiposArbolInventario = [
  'arbol_singular',
  'parcela_muestreo'
];

/// Árbol singular o parcela de muestreo del inventario, con su código para
/// la chapa QR (como el arbolado urbano).
class ArbolSingular {
  ArbolSingular({
    this.id,
    required this.codigo,
    this.tipo = 'arbol_singular',
    this.especieId = '',
    this.nombre = '',
    this.rodalId,
    this.latitud,
    this.longitud,
    this.perimetroCm,
    this.alturaM,
    this.radioParcelaM,
    this.fechaAltaMs = 0,
    this.notas = '',
  });

  final int? id;

  /// Código único que va en la chapa («AS-001», «PM-12»).
  final String codigo;

  /// Uno de [tiposArbolInventario].
  final String tipo;
  final String especieId;

  /// Nombre popular del árbol («El roble de la fuente»).
  final String nombre;
  final int? rodalId;
  final double? latitud;
  final double? longitud;

  /// Perímetro normal (a 1,30 m), en cm.
  final double? perimetroCm;
  final double? alturaM;

  /// Radio de la parcela de muestreo (m).
  final double? radioParcelaM;
  final int fechaAltaMs;
  final String notas;

  bool get esParcelaMuestreo => tipo == 'parcela_muestreo';
  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Texto del QR: plano, sin URL ni servidor.
  String textoQr(String nombreMonte) => [
        'Larrea Monte',
        if (nombreMonte.isNotEmpty) nombreMonte,
        codigo,
        if (nombre.isNotEmpty) nombre,
        if (especieId.isNotEmpty) especieId,
      ].join('\n');

  ArbolSingular conUbicacion(double latitud, double longitud) =>
      ArbolSingular.fromMap(
          {...toMap(), 'latitud': latitud, 'longitud': longitud});

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'tipo': tipo,
        'especie_id': especieId,
        'nombre': nombre,
        'rodal_id': rodalId,
        'latitud': latitud,
        'longitud': longitud,
        'perimetro_cm': perimetroCm,
        'altura_m': alturaM,
        'radio_parcela_m': radioParcelaM,
        'fecha_alta_ms': fechaAltaMs,
        'notas': notas,
      };

  factory ArbolSingular.fromMap(Map<String, Object?> mapa) => ArbolSingular(
        id: mapa['id'] as int?,
        codigo: (mapa['codigo'] as String?) ?? '',
        tipo: tiposArbolInventario.contains(mapa['tipo'])
            ? mapa['tipo'] as String
            : 'arbol_singular',
        especieId: (mapa['especie_id'] as String?) ?? '',
        nombre: (mapa['nombre'] as String?) ?? '',
        rodalId: mapa['rodal_id'] as int?,
        latitud: (mapa['latitud'] as num?)?.toDouble(),
        longitud: (mapa['longitud'] as num?)?.toDouble(),
        perimetroCm: (mapa['perimetro_cm'] as num?)?.toDouble(),
        alturaM: (mapa['altura_m'] as num?)?.toDouble(),
        radioParcelaM: (mapa['radio_parcela_m'] as num?)?.toDouble(),
        fechaAltaMs: (mapa['fecha_alta_ms'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
