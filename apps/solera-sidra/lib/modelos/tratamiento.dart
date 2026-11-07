/// Eficacia observada del tratamiento (la pide el cuaderno de
/// fitosanitarios del RD 1311/2012).
const List<String> eficaciasTratamiento = ['', 'buena', 'regular', 'mala'];

/// Tratamiento fitosanitario aplicado en una pomarada: va al cuaderno de la
/// pomarada.
///
/// **Hard limit**: la app no propone productos ni dosis. La sustancia
/// activa sale del catálogo; el número de registro y la cantidad los
/// escribe la persona copiándolos de la etiqueta del producto que ya ha
/// aplicado, porque el cuaderno los exige.
class Tratamiento {
  Tratamiento({
    this.id,
    required this.pomaradaId,
    required this.fechaMs,
    this.sustanciaActivaId = '',
    this.numeroRegistroProducto = '',
    this.cantidadAplicada = '',
    this.plagaObjetivoId = '',
    this.superficieTratadaHa,
    this.aplicador = '',
    this.carnetAplicador = '',
    this.eficacia = '',
    this.notas = '',
  });

  final int? id;
  final int pomaradaId;
  final int fechaMs;

  /// Id del catálogo `fitosanitarios_manzano`.
  final String sustanciaActivaId;

  /// N.º de inscripción en el Registro de Productos Fitosanitarios, tal como
  /// figura en la etiqueta. Nunca se guarda ni se sugiere una marca.
  final String numeroRegistroProducto;

  /// Lo que se aplicó, en texto libre y con su unidad, copiado de lo que se
  /// hizo (no lo calcula ni lo propone la app).
  final String cantidadAplicada;

  /// Id del catálogo `plagas_manzano` (vacío: preventivo).
  final String plagaObjetivoId;
  final double? superficieTratadaHa;
  final String aplicador;

  /// N.º del carné de usuario profesional de fitosanitarios.
  final String carnetAplicador;

  /// Uno de [eficaciasTratamiento].
  final String eficacia;
  final String notas;

  /// Lo mínimo que el cuaderno no puede dejar en blanco.
  bool get estaIncompleto =>
      sustanciaActivaId.isEmpty ||
      numeroRegistroProducto.trim().isEmpty ||
      aplicador.trim().isEmpty;

  Map<String, Object?> toMap() => {
        'id': id,
        'pomarada_id': pomaradaId,
        'fecha_ms': fechaMs,
        'sustancia_activa_id': sustanciaActivaId,
        'numero_registro_producto': numeroRegistroProducto,
        'cantidad_aplicada': cantidadAplicada,
        'plaga_objetivo_id': plagaObjetivoId,
        'superficie_tratada_ha': superficieTratadaHa,
        'aplicador': aplicador,
        'carnet_aplicador': carnetAplicador,
        'eficacia': eficacia,
        'notas': notas,
      };

  factory Tratamiento.fromMap(Map<String, Object?> mapa) => Tratamiento(
        id: mapa['id'] as int?,
        pomaradaId: mapa['pomarada_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        sustanciaActivaId: (mapa['sustancia_activa_id'] as String?) ?? '',
        numeroRegistroProducto:
            (mapa['numero_registro_producto'] as String?) ?? '',
        cantidadAplicada: (mapa['cantidad_aplicada'] as String?) ?? '',
        plagaObjetivoId: (mapa['plaga_objetivo_id'] as String?) ?? '',
        superficieTratadaHa:
            (mapa['superficie_tratada_ha'] as num?)?.toDouble(),
        aplicador: (mapa['aplicador'] as String?) ?? '',
        carnetAplicador: (mapa['carnet_aplicador'] as String?) ?? '',
        eficacia: eficaciasTratamiento.contains(mapa['eficacia'])
            ? mapa['eficacia'] as String
            : '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
