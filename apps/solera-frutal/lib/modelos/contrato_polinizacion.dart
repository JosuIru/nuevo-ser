/// Colmenas que un apicultor pone en una parcela durante la floración.
/// Importe en céntimos por colmena. El puente con Larrea Apícola es el
/// código REGA del apicultor.
class ContratoPolinizacion {
  ContratoPolinizacion({
    this.id,
    required this.parcelaId,
    required this.campania,
    required this.apicultorNombre,
    this.apicultorCodigoRega = '',
    this.numeroColmenas = 0,
    this.fechaEntradaMs,
    this.fechaSalidaMs,
    this.precioCentimosPorColmena = 0,
    this.notas = '',
  });

  final int? id;
  final int parcelaId;

  /// Año de la floración.
  final int campania;
  final String apicultorNombre;
  final String apicultorCodigoRega;
  final int numeroColmenas;
  final int? fechaEntradaMs;
  final int? fechaSalidaMs;
  final int precioCentimosPorColmena;
  final String notas;

  int get importeTotalCentimos => numeroColmenas * precioCentimosPorColmena;

  /// Colmenas por hectárea en una parcela de [superficieHa]; null si la
  /// superficie no está apuntada.
  double? colmenasPorHectarea(double superficieHa) =>
      superficieHa <= 0 ? null : numeroColmenas / superficieHa;

  /// Las colmenas siguen en la parcela en [fechaMs].
  bool estaEnParcela(int fechaMs) =>
      fechaEntradaMs != null &&
      fechaEntradaMs! <= fechaMs &&
      (fechaSalidaMs == null || fechaMs <= fechaSalidaMs!);

  Map<String, Object?> toMap() => {
        'id': id,
        'parcela_id': parcelaId,
        'campania': campania,
        'apicultor_nombre': apicultorNombre,
        'apicultor_codigo_rega': apicultorCodigoRega,
        'numero_colmenas': numeroColmenas,
        'fecha_entrada_ms': fechaEntradaMs,
        'fecha_salida_ms': fechaSalidaMs,
        'precio_centimos_colmena': precioCentimosPorColmena,
        'notas': notas,
      };

  factory ContratoPolinizacion.fromMap(Map<String, Object?> mapa) =>
      ContratoPolinizacion(
        id: mapa['id'] as int?,
        parcelaId: mapa['parcela_id'] as int,
        campania: mapa['campania'] as int,
        apicultorNombre: (mapa['apicultor_nombre'] as String?) ?? '',
        apicultorCodigoRega: (mapa['apicultor_codigo_rega'] as String?) ?? '',
        numeroColmenas: (mapa['numero_colmenas'] as int?) ?? 0,
        fechaEntradaMs: mapa['fecha_entrada_ms'] as int?,
        fechaSalidaMs: mapa['fecha_salida_ms'] as int?,
        precioCentimosPorColmena:
            (mapa['precio_centimos_colmena'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
