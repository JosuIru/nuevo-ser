/// Eficacia del tratamiento, como la pide el cuaderno de explotación.
const List<String> eficaciasTratamiento = ['buena', 'regular', 'mala'];

/// Aplicación de un insumo en una parcela o un bancal: un tratamiento
/// fitosanitario (cuaderno de explotación, RD 1311/2012) o un abonado o
/// enmienda (registro de insumos para el certificador ecológico). El tipo
/// lo da el [Insumo] aplicado.
///
/// La app **no recomienda** productos ni dosis: la persona apunta lo que
/// aplicó, copiado de la etiqueta.
class Tratamiento {
  Tratamiento({
    this.id,
    required this.parcelaId,
    required this.insumoId,
    required this.fechaMs,
    this.bancalId,
    this.superficieTratadaM2,
    this.problema = '',
    this.sustanciaActivaId = '',
    this.dosisAplicada = '',
    this.cantidadTotal = '',
    this.plazoSeguridadDias,
    this.aplicadorNombre = '',
    this.carnetAplicador = '',
    this.equipoAplicacion = '',
    this.eficacia = '',
    this.observaciones = '',
  });

  final int? id;
  final int parcelaId;

  /// Null si se aplicó en toda la parcela.
  final int? bancalId;
  final int insumoId;
  final int fechaMs;
  final double? superficieTratadaM2;

  /// Plaga, enfermedad o carencia (id del catálogo o texto libre). En un
  /// abonado puede ir vacío.
  final String problema;

  /// Sustancia activa (texto libre o id), para los fitosanitarios.
  final String sustanciaActivaId;

  /// Texto tal como lo apunta la persona («3 kg/100 m²»). La app no lo
  /// calcula ni lo propone.
  final String dosisAplicada;

  /// Cantidad total gastada, texto libre («12 kg»).
  final String cantidadTotal;

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
        'bancal_id': bancalId,
        'insumo_id': insumoId,
        'fecha_ms': fechaMs,
        'superficie_tratada_m2': superficieTratadaM2,
        'problema': problema,
        'sustancia_activa_id': sustanciaActivaId,
        'dosis_aplicada': dosisAplicada,
        'cantidad_total': cantidadTotal,
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
        bancalId: mapa['bancal_id'] as int?,
        insumoId: mapa['insumo_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        superficieTratadaM2:
            (mapa['superficie_tratada_m2'] as num?)?.toDouble(),
        problema: (mapa['problema'] as String?) ?? '',
        sustanciaActivaId: (mapa['sustancia_activa_id'] as String?) ?? '',
        dosisAplicada: (mapa['dosis_aplicada'] as String?) ?? '',
        cantidadTotal: (mapa['cantidad_total'] as String?) ?? '',
        plazoSeguridadDias: mapa['plazo_seguridad_dias'] as int?,
        aplicadorNombre: (mapa['aplicador_nombre'] as String?) ?? '',
        carnetAplicador: (mapa['carnet_aplicador'] as String?) ?? '',
        equipoAplicacion: (mapa['equipo_aplicacion'] as String?) ?? '',
        eficacia: (mapa['eficacia'] as String?) ?? '',
        observaciones: (mapa['observaciones'] as String?) ?? '',
      );
}
