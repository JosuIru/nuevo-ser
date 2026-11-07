/// Tipos de material de partida.
const List<String> tiposMaterial = [
  'semilla',
  'esqueje',
  'planta_madre',
  'planton',
  'bulbo',
];

/// Categorías de los materiales forestales de reproducción (RD 289/2003,
/// art. 10.6: identificado, seleccionado, cualificado y controlado, con
/// etiqueta amarilla, verde, rosa y azul).
const List<String> categoriasMaterialForestal = [
  'identificado',
  'seleccionado',
  'cualificado',
  'controlado',
];

/// Lote de material de partida: semilla, esquejes, planta madre o plantón
/// comprado. Es el primer eslabón de la trazabilidad.
class LoteMaterial {
  LoteMaterial({
    this.id,
    required this.codigo,
    this.tipo = 'semilla',
    required this.especieId,
    this.nombreBotanico = '',
    this.variedad = '',
    this.esPropio = false,
    this.proveedorNombre = '',
    this.proveedorCodigoRopveg = '',
    this.pasaporteRecibido = '',
    this.paisOrigen = 'ES',
    required this.fechaEntradaMs,
    this.cantidad = 0,
    this.unidad = 'uds',
    this.categoriaForestal = '',
    this.regionProcedencia = '',
    this.certificadoPatron = '',
    this.notas = '',
  });

  final int? id;

  /// Código del lote: el del proveedor o uno propio. Único en la BD.
  final String codigo;

  /// Uno de [tiposMaterial].
  final String tipo;

  /// Id del catálogo de especies o texto libre.
  final String especieId;

  /// Nombre botánico (letra A del pasaporte); se copia del catálogo si la
  /// especie está en él.
  final String nombreBotanico;
  final String variedad;

  /// Recolectado o producido en el propio vivero (semilla local, esquejes
  /// de las plantas madre de la casa).
  final bool esPropio;
  final String proveedorNombre;
  final String proveedorCodigoRopveg;

  /// Código de trazabilidad del pasaporte con el que llegó el material, si
  /// llegó con pasaporte (registro de trazabilidad, RD 1054/2021, art. 20).
  final String pasaporteRecibido;

  /// Código ISO del país de origen (letra D del pasaporte).
  final String paisOrigen;
  final int fechaEntradaMs;
  final double cantidad;

  /// g, kg, uds, sobres…
  final String unidad;

  /// Perfil forestal (RD 289/2003): uno de [categoriasMaterialForestal] o vacío.
  final String categoriaForestal;

  /// Región de procedencia (nombre y código) en material identificado o
  /// seleccionado.
  final String regionProcedencia;

  /// Número del certificado patrón del lote forestal.
  final String certificadoPatron;
  final String notas;

  bool get esForestal => categoriaForestal.isNotEmpty;

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'tipo': tipo,
        'especie_id': especieId,
        'nombre_botanico': nombreBotanico,
        'variedad': variedad,
        'es_propio': esPropio ? 1 : 0,
        'proveedor_nombre': proveedorNombre,
        'proveedor_codigo_ropveg': proveedorCodigoRopveg,
        'pasaporte_recibido': pasaporteRecibido,
        'pais_origen': paisOrigen,
        'fecha_entrada_ms': fechaEntradaMs,
        'cantidad': cantidad,
        'unidad': unidad,
        'categoria_forestal': categoriaForestal,
        'region_procedencia': regionProcedencia,
        'certificado_patron': certificadoPatron,
        'notas': notas,
      };

  factory LoteMaterial.fromMap(Map<String, Object?> mapa) => LoteMaterial(
        id: mapa['id'] as int?,
        codigo: (mapa['codigo'] as String?) ?? '',
        tipo: (mapa['tipo'] as String?) ?? 'semilla',
        especieId: (mapa['especie_id'] as String?) ?? '',
        nombreBotanico: (mapa['nombre_botanico'] as String?) ?? '',
        variedad: (mapa['variedad'] as String?) ?? '',
        esPropio: (mapa['es_propio'] as int?) == 1,
        proveedorNombre: (mapa['proveedor_nombre'] as String?) ?? '',
        proveedorCodigoRopveg:
            (mapa['proveedor_codigo_ropveg'] as String?) ?? '',
        pasaporteRecibido: (mapa['pasaporte_recibido'] as String?) ?? '',
        paisOrigen: (mapa['pais_origen'] as String?) ?? 'ES',
        fechaEntradaMs: (mapa['fecha_entrada_ms'] as int?) ?? 0,
        cantidad: (mapa['cantidad'] as num?)?.toDouble() ?? 0,
        unidad: (mapa['unidad'] as String?) ?? 'uds',
        categoriaForestal: (mapa['categoria_forestal'] as String?) ?? '',
        regionProcedencia: (mapa['region_procedencia'] as String?) ?? '',
        certificadoPatron: (mapa['certificado_patron'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
