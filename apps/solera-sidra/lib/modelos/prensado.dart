import 'codificacion.dart';

/// Molienda (matxaka) y prensado de una o varias partidas: el mosto va a
/// una kupela. El pliego de Euskal Sagardoa pide registrar la presión y da
/// una densidad natural mínima del mosto de 1045 a 20 °C.
class Prensado {
  Prensado({
    this.id,
    required this.fechaMs,
    required this.kupelaId,
    required this.kilosFruta,
    required this.litrosMosto,
    this.presionBar,
    this.densidadMosto,
    this.temperaturaMostoC,
    this.notas = '',
  });

  final int? id;
  final int fechaMs;

  /// Kupela (o depósito) que recibe el mosto.
  final int kupelaId;
  final double kilosFruta;
  final double litrosMosto;
  final double? presionBar;

  /// Densidad del mosto (p. ej. 1048), sin unidades: g/l ÷ 1.
  final double? densidadMosto;
  final double? temperaturaMostoC;
  final String notas;

  /// Litros de mosto por cada 100 kg de fruta; null sin kilos.
  double? get rendimientoPorcentaje =>
      kilosFruta > 0 ? litrosMosto / kilosFruta * 100 : null;

  Map<String, Object?> toMap() => {
        'id': id,
        'fecha_ms': fechaMs,
        'kupela_id': kupelaId,
        'kilos_fruta': kilosFruta,
        'litros_mosto': litrosMosto,
        'presion_bar': presionBar,
        'densidad_mosto': densidadMosto,
        'temperatura_mosto_c': temperaturaMostoC,
        'notas': notas,
      };

  factory Prensado.fromMap(Map<String, Object?> mapa) => Prensado(
        id: mapa['id'] as int?,
        fechaMs: mapa['fecha_ms'] as int,
        kupelaId: mapa['kupela_id'] as int,
        kilosFruta: comoDecimal(mapa['kilos_fruta']) ?? 0,
        litrosMosto: comoDecimal(mapa['litros_mosto']) ?? 0,
        presionBar: comoDecimal(mapa['presion_bar']),
        densidadMosto: comoDecimal(mapa['densidad_mosto']),
        temperaturaMostoC: comoDecimal(mapa['temperatura_mosto_c']),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
