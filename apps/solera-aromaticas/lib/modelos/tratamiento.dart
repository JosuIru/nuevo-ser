/// Eficacia del tratamiento, como la pide el cuaderno de explotación.
const List<String> eficaciasTratamiento = ['buena', 'regular', 'mala'];

/// Tratamiento fitosanitario aplicado en una parcela (cuaderno de
/// explotación, RD 1311/2012).
///
/// La app **no recomienda** productos ni dosis: la persona apunta lo que
/// aplicó, copiado de la etiqueta. La trazabilidad es la sustancia activa
/// (id del catálogo) más el producto y su número de registro tal como
/// figuran en el envase.
class Tratamiento {
  Tratamiento({
    this.id,
    required this.parcelaId,
    required this.fechaMs,
    this.superficieTratadaHa = 0,
    this.problemaFitosanitario = '',
    this.sustanciaActivaId = '',
    this.nombreProducto = '',
    this.numeroRegistroProducto = '',
    this.dosisAplicada = '',
    this.plazoSeguridadDias,
    this.aplicadorNombre = '',
    this.carnetAplicador = '',
    this.equipoAplicacion = '',
    this.eficacia = '',
    this.observaciones = '',
  });

  final int? id;
  final int parcelaId;
  final int fechaMs;
  final double superficieTratadaHa;

  /// Id del catálogo de plagas o texto libre (p. ej. «malas hierbas»).
  final String problemaFitosanitario;

  /// Id del catálogo de sustancias activas o texto libre.
  final String sustanciaActivaId;
  final String nombreProducto;

  /// Número de inscripción en el Registro de Productos Fitosanitarios.
  final String numeroRegistroProducto;

  /// Texto tal como lo apunta la persona (p. ej. «0,5 l/ha»). La app no
  /// lo calcula ni lo propone.
  final String dosisAplicada;

  /// Plazo de seguridad de la etiqueta, en días.
  final int? plazoSeguridadDias;
  final String aplicadorNombre;
  final String carnetAplicador;

  /// Equipo de aplicación (nº ROMA o descripción).
  final String equipoAplicacion;

  /// Uno de [eficaciasTratamiento] o vacío.
  final String eficacia;
  final String observaciones;

  /// Día a partir del cual se puede cosechar según el plazo apuntado.
  DateTime? get finPlazoSeguridad => plazoSeguridadDias == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(fechaMs)
          .add(Duration(days: plazoSeguridadDias!));

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'fecha_ms': fechaMs,
        'superficie_tratada_ha': superficieTratadaHa,
        'problema_fitosanitario': problemaFitosanitario,
        'sustancia_activa_id': sustanciaActivaId,
        'nombre_producto': nombreProducto,
        'numero_registro_producto': numeroRegistroProducto,
        'dosis_aplicada': dosisAplicada,
        'plazo_seguridad_dias': plazoSeguridadDias,
        'aplicador_nombre': aplicadorNombre,
        'carnet_aplicador': carnetAplicador,
        'equipo_aplicacion': equipoAplicacion,
        'eficacia': eficacia,
        'observaciones': observaciones,
      };

  factory Tratamiento.fromMap(Map<String, Object?> mapa) => Tratamiento(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        superficieTratadaHa:
            (mapa['superficie_tratada_ha'] as num?)?.toDouble() ?? 0,
        problemaFitosanitario:
            (mapa['problema_fitosanitario'] as String?) ?? '',
        sustanciaActivaId: (mapa['sustancia_activa_id'] as String?) ?? '',
        nombreProducto: (mapa['nombre_producto'] as String?) ?? '',
        numeroRegistroProducto:
            (mapa['numero_registro_producto'] as String?) ?? '',
        dosisAplicada: (mapa['dosis_aplicada'] as String?) ?? '',
        plazoSeguridadDias: mapa['plazo_seguridad_dias'] as int?,
        aplicadorNombre: (mapa['aplicador_nombre'] as String?) ?? '',
        carnetAplicador: (mapa['carnet_aplicador'] as String?) ?? '',
        equipoAplicacion: (mapa['equipo_aplicacion'] as String?) ?? '',
        eficacia: (mapa['eficacia'] as String?) ?? '',
        observaciones: (mapa['observaciones'] as String?) ?? '',
      );
}
