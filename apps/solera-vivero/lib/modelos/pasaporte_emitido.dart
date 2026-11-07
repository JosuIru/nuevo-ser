/// Registro de un pasaporte fitosanitario preparado para una salida.
///
/// Es una **foto** de los datos en el momento de prepararlo (si luego se
/// corrige la partida, el registro no cambia): es lo que pide el registro
/// de trazabilidad durante tres años (RD 1054/2021, art. 20). La app no
/// emite el pasaporte: lo expide el operador autorizado; si el vivero no
/// tiene la autorización apuntada, queda como borrador.
class PasaporteEmitido {
  PasaporteEmitido({
    this.id,
    required this.salidaId,
    required this.fechaMs,
    this.esZonaProtegida = false,
    required this.nombreBotanico,
    this.variedad = '',
    required this.codigoOperador,
    required this.codigoTrazabilidad,
    required this.paisOrigen,
    this.plagasZonaProtegida = '',
    this.cantidad = 0,
    this.preparadoPor = '',
    this.esBorrador = true,
    this.anulado = false,
    this.notas = '',
  });

  final int? id;
  final int salidaId;
  final int fechaMs;

  /// Pasaporte «ZP» (Reglamento de Ejecución (UE) 2017/2313, anexo, parte B).
  final bool esZonaProtegida;

  /// Letra A.
  final String nombreBotanico;
  final String variedad;

  /// Letra B: «ES-» y el nº ROPVEG.
  final String codigoOperador;

  /// Letra C.
  final String codigoTrazabilidad;

  /// Letra D.
  final String paisOrigen;

  /// Nombres o códigos de las plagas de zona protegida (solo «ZP»).
  final String plagasZonaProtegida;
  final int cantidad;

  /// Persona que lo preparó (la que firma como operador autorizado).
  final String preparadoPor;

  /// Sin autorización del vivero para expedir pasaportes, o con datos que
  /// faltan, el registro es un borrador y la etiqueta lo dice.
  final bool esBorrador;

  /// Pasaporte retirado o sustituido (art. 93 del Reglamento 2016/2031):
  /// se conserva, no se borra.
  final bool anulado;
  final String notas;

  PasaporteEmitido copiarAnulado() => PasaporteEmitido(
        id: id,
        salidaId: salidaId,
        fechaMs: fechaMs,
        esZonaProtegida: esZonaProtegida,
        nombreBotanico: nombreBotanico,
        variedad: variedad,
        codigoOperador: codigoOperador,
        codigoTrazabilidad: codigoTrazabilidad,
        paisOrigen: paisOrigen,
        plagasZonaProtegida: plagasZonaProtegida,
        cantidad: cantidad,
        preparadoPor: preparadoPor,
        esBorrador: esBorrador,
        anulado: true,
        notas: notas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'salida_id': salidaId,
        'fecha_ms': fechaMs,
        'es_zona_protegida': esZonaProtegida ? 1 : 0,
        'nombre_botanico': nombreBotanico,
        'variedad': variedad,
        'codigo_operador': codigoOperador,
        'codigo_trazabilidad': codigoTrazabilidad,
        'pais_origen': paisOrigen,
        'plagas_zona_protegida': plagasZonaProtegida,
        'cantidad': cantidad,
        'preparado_por': preparadoPor,
        'es_borrador': esBorrador ? 1 : 0,
        'anulado': anulado ? 1 : 0,
        'notas': notas,
      };

  factory PasaporteEmitido.fromMap(Map<String, Object?> mapa) =>
      PasaporteEmitido(
        id: mapa['id'] as int?,
        salidaId: mapa['salida_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        esZonaProtegida: (mapa['es_zona_protegida'] as int?) == 1,
        nombreBotanico: (mapa['nombre_botanico'] as String?) ?? '',
        variedad: (mapa['variedad'] as String?) ?? '',
        codigoOperador: (mapa['codigo_operador'] as String?) ?? '',
        codigoTrazabilidad: (mapa['codigo_trazabilidad'] as String?) ?? '',
        paisOrigen: (mapa['pais_origen'] as String?) ?? '',
        plagasZonaProtegida: (mapa['plagas_zona_protegida'] as String?) ?? '',
        cantidad: (mapa['cantidad'] as int?) ?? 0,
        preparadoPor: (mapa['preparado_por'] as String?) ?? '',
        esBorrador: (mapa['es_borrador'] as int?) != 0,
        anulado: (mapa['anulado'] as int?) == 1,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
