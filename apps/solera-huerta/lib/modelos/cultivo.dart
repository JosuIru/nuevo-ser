/// Un cultivo de la huerta: especie (del catálogo o texto libre), su
/// familia botánica (la que manda en la rotación) y la variedad.
class Cultivo {
  Cultivo({
    this.id,
    required this.especieId,
    required this.familiaId,
    this.variedad = '',
    this.variedadLocal = false,
    this.notas = '',
  });

  final int? id;

  /// Id del catálogo de cultivos o nombre libre si no está.
  final String especieId;

  /// Id de familia botánica del catálogo de rotación (`solanaceas`…) o
  /// texto libre. Se guarda aquí para que la rotación funcione aunque la
  /// especie no esté en el catálogo.
  final String familiaId;
  final String variedad;

  /// Variedad local o tradicional (banco de semillas).
  final bool variedadLocal;
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'especie_id': especieId,
        'familia_id': familiaId,
        'variedad': variedad,
        'variedad_local': variedadLocal ? 1 : 0,
        'notas': notas,
      };

  factory Cultivo.fromMap(Map<String, Object?> mapa) => Cultivo(
        id: mapa['id'] as int?,
        especieId: (mapa['especie_id'] as String?) ?? '',
        familiaId: (mapa['familia_id'] as String?) ?? '',
        variedad: (mapa['variedad'] as String?) ?? '',
        variedadLocal: (mapa['variedad_local'] as int?) == 1,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
