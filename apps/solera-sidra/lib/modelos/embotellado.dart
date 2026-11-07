import 'codificacion.dart';

/// Embotellado de una kupela: el lote de botellas. Lleva lo que el pliego
/// de Euskal Sagardoa pide del proceso de elaboración (ap. E): día del
/// envasado, cantidad, partida, día del etiquetado, número de etiquetas y
/// sus numeraciones, y destino.
class Embotellado {
  Embotellado({
    this.id,
    required this.fechaMs,
    required this.kupelaId,
    required this.codigoLote,
    required this.botellas,
    this.mililitrosBotella = 750,
    this.conDop = false,
    this.fechaEtiquetadoMs,
    this.etiquetaDesde,
    this.etiquetaHasta,
    this.destino = '',
    this.notas = '',
  });

  final int? id;
  final int fechaMs;
  final int kupelaId;
  final String codigoLote;
  final int botellas;
  final int mililitrosBotella;

  /// Con contraetiqueta numerada de la DOP.
  final bool conDop;
  final int? fechaEtiquetadoMs;

  /// Primera y última contraetiqueta numerada usada (inclusive).
  final int? etiquetaDesde;
  final int? etiquetaHasta;
  final String destino;
  final String notas;

  double get litros => botellas * mililitrosBotella / 1000;

  /// Contraetiquetas del rango, o null si no hay rango.
  int? get etiquetasUsadas => etiquetaDesde != null && etiquetaHasta != null
      ? etiquetaHasta! - etiquetaDesde! + 1
      : null;

  /// El rango de contraetiquetas no cuadra con las botellas.
  bool get etiquetasDescuadradas =>
      conDop && etiquetasUsadas != null && etiquetasUsadas != botellas;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'kupela_id': kupelaId,
        'codigo_lote': codigoLote,
        'botellas': botellas,
        'mililitros_botella': mililitrosBotella,
        'con_dop': conDop ? 1 : 0,
        'fecha_etiquetado_ms': fechaEtiquetadoMs,
        'etiqueta_desde': etiquetaDesde,
        'etiqueta_hasta': etiquetaHasta,
        'destino': destino,
        'notas': notas,
      };

  factory Embotellado.fromMap(Map<String, Object?> mapa) => Embotellado(
        id: mapa['id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        kupelaId: mapa['kupela_id'] as int,
        codigoLote: mapa['codigo_lote'] as String,
        botellas: mapa['botellas'] as int,
        mililitrosBotella: (mapa['mililitros_botella'] as int?) ?? 750,
        conDop: comoBooleano(mapa['con_dop']),
        fechaEtiquetadoMs: mapa['fecha_etiquetado_ms'] as int?,
        etiquetaDesde: mapa['etiqueta_desde'] as int?,
        etiquetaHasta: mapa['etiqueta_hasta'] as int?,
        destino: (mapa['destino'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Código de lote por defecto: `AAAAMMDD-<kupela>`.
String codigoLoteEmbotellado(DateTime fecha, String codigoKupela) {
  String dos(int valor) => valor.toString().padLeft(2, '0');
  final kupela = codigoKupela.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  return '${fecha.year}${dos(fecha.month)}${dos(fecha.day)}-$kupela';
}
