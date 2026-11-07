/// Regímenes fiscales que distingue la app (PROVISIONAL: lo fija el asesor
/// fiscal). `reagp`: régimen especial de agricultura (venta de manzana
/// propia sin transformar); `general`: el resto (elaborar y vender sidra es
/// transformación).
const List<String> regimenesFiscales = ['general', 'reagp'];

/// Titular de la sagardotegi o bodega (tabla de una sola fila).
class Titular {
  Titular({
    this.id,
    this.nombre = '',
    this.nif = '',
    this.registroSanitario = '',
    this.inscripcionDop = '',
    this.regimenFiscal = 'general',
  });

  final int? id;
  final String nombre;
  final String nif;

  /// Número del RGSEAA o del registro sanitario autonómico.
  final String registroSanitario;

  /// Número de inscripción en los registros de la DOP (elaborador).
  final String inscripcionDop;

  /// Uno de [regimenesFiscales].
  final String regimenFiscal;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'nif': nif,
        'registro_sanitario': registroSanitario,
        'inscripcion_dop': inscripcionDop,
        'regimen_fiscal': regimenFiscal,
      };

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
        registroSanitario: (mapa['registro_sanitario'] as String?) ?? '',
        inscripcionDop: (mapa['inscripcion_dop'] as String?) ?? '',
        regimenFiscal: regimenesFiscales.contains(mapa['regimen_fiscal'])
            ? mapa['regimen_fiscal'] as String
            : 'general',
      );
}
