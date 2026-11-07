/// Qué elabora la casa: sidra, txakoli o las dos cosas.
const List<String> perfilesElaboracion = ['sidra', 'txakoli', 'ambos'];

/// La sagardotegi o bodega (tabla de una sola fila): lo que sale en los
/// documentos y decide qué pantallas se ven.
class Sagardotegi {
  Sagardotegi({
    this.id,
    this.nombre = '',
    this.municipio = '',
    this.territorio = '',
    this.perfil = 'sidra',
    this.dopId = '',
    this.abreTxotx = true,
  });

  final int? id;
  final String nombre;
  final String municipio;

  /// Territorio histórico o provincia (Gipuzkoa, Bizkaia, Araba, Nafarroa,
  /// Asturias…), texto libre.
  final String territorio;

  /// Uno de [perfilesElaboracion].
  final String perfil;

  /// Id del catálogo `dop_sidra_txakoli` (vacío si no elabora bajo DOP).
  final String dopId;

  /// Si abre temporada de txotx (enseña la pestaña).
  final bool abreTxotx;

  bool get elaboraSidra => perfil != 'txakoli';
  bool get elaboraTxakoli => perfil != 'sidra';

  /// Sin nombre todavía: Hoy enseña la bienvenida.
  bool get estaSinConfigurar => nombre.trim().isEmpty;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'municipio': municipio,
        'territorio': territorio,
        'perfil': perfil,
        'dop_id': dopId,
        'abre_txotx': abreTxotx ? 1 : 0,
      };

  factory Sagardotegi.fromMap(Map<String, Object?> mapa) => Sagardotegi(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        municipio: (mapa['municipio'] as String?) ?? '',
        territorio: (mapa['territorio'] as String?) ?? '',
        perfil: perfilesElaboracion.contains(mapa['perfil'])
            ? mapa['perfil'] as String
            : 'sidra',
        dopId: (mapa['dop_id'] as String?) ?? '',
        abreTxotx: (mapa['abre_txotx'] as int?) != 0,
      );
}
