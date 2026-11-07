/// Salida de planta del vivero: venta, entrega o traslado.
///
/// Las marcas de destino son las que deciden si hace falta pasaporte
/// (Reglamento (UE) 2016/2031, art. 81; RD 1054/2021, art. 16.6): ver
/// `dominio/pasaporte.dart`.
class Salida {
  Salida({
    this.id,
    required this.partidaId,
    required this.fechaMs,
    required this.cantidad,
    this.clienteNombre = '',
    this.clienteNif = '',
    this.clienteCodigoRopveg = '',
    this.esUsuarioFinal = false,
    this.esVentaADistancia = false,
    this.destinoZonaProtegida = false,
    this.esTrasladoPropioMismaComunidad = false,
    this.codigoTrazabilidad = '',
    this.importeCentimos = 0,
    this.notas = '',
  });

  final int? id;
  final int partidaId;
  final int fechaMs;
  final int cantidad;
  final String clienteNombre;
  final String clienteNif;

  /// Si el cliente es operador profesional (otro vivero, un jardín, una
  /// explotación), su nº ROPVEG: va al registro de trazabilidad.
  final String clienteCodigoRopveg;

  /// Persona que compra para su uso personal, fuera de su profesión
  /// (Reglamento 2016/2031, art. 2.12).
  final bool esUsuarioFinal;

  /// Venta por internet, teléfono o correo (art. 81.2: entonces sí hace
  /// falta pasaporte aunque sea un usuario final).
  final bool esVentaADistancia;

  /// Si el destino está en una zona protegida para alguna plaga de la
  /// especie (pasaporte «ZP»).
  final bool destinoZonaProtegida;

  /// Traslado a otra instalación del mismo vivero en la misma comunidad
  /// autónoma (RD 1054/2021, art. 16.6.b).
  final bool esTrasladoPropioMismaComunidad;

  /// Letra C del pasaporte. Por defecto, el código de la partida.
  final String codigoTrazabilidad;

  /// Importe de la venta sin IVA (lo usa la economía).
  final int importeCentimos;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'partida_id': partidaId,
        'fecha_ms': fechaMs,
        'cantidad': cantidad,
        'cliente_nombre': clienteNombre,
        'cliente_nif': clienteNif,
        'cliente_codigo_ropveg': clienteCodigoRopveg,
        'es_usuario_final': esUsuarioFinal ? 1 : 0,
        'es_venta_a_distancia': esVentaADistancia ? 1 : 0,
        'destino_zona_protegida': destinoZonaProtegida ? 1 : 0,
        'es_traslado_propio_misma_comunidad':
            esTrasladoPropioMismaComunidad ? 1 : 0,
        'codigo_trazabilidad': codigoTrazabilidad,
        'importe_centimos': importeCentimos,
        'notas': notas,
      };

  factory Salida.fromMap(Map<String, Object?> mapa) => Salida(
        id: mapa['id'] as int?,
        partidaId: mapa['partida_id'] as int,
        fechaMs: mapa['fecha_ms'] as int,
        cantidad: (mapa['cantidad'] as int?) ?? 0,
        clienteNombre: (mapa['cliente_nombre'] as String?) ?? '',
        clienteNif: (mapa['cliente_nif'] as String?) ?? '',
        clienteCodigoRopveg: (mapa['cliente_codigo_ropveg'] as String?) ?? '',
        esUsuarioFinal: (mapa['es_usuario_final'] as int?) == 1,
        esVentaADistancia: (mapa['es_venta_a_distancia'] as int?) == 1,
        destinoZonaProtegida: (mapa['destino_zona_protegida'] as int?) == 1,
        esTrasladoPropioMismaComunidad:
            (mapa['es_traslado_propio_misma_comunidad'] as int?) == 1,
        codigoTrazabilidad: (mapa['codigo_trazabilidad'] as String?) ?? '',
        importeCentimos: (mapa['importe_centimos'] as int?) ?? 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
