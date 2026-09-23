/// Versión de la app — `mayor.menor.parche+build`. Comparable según
/// la convención semántica simple del juego (Uno Roto solo bumpea el
/// `+build` entre releases; el `mayor.menor.parche` queda fijado en
/// `1.0.0` hasta que haya cambios estructurales que justifiquen otro
/// número). El operador renombra `tag_name` en GitHub Releases con el
/// formato `uno-roto-<version>` (ej. `uno-roto-1.0.0+17`) — el parser
/// tolera ambos: el tag completo o la versión pelada.
class VersionApp implements Comparable<VersionApp> {
  const VersionApp({
    required this.mayor,
    required this.menor,
    required this.parche,
    required this.build,
  });

  final int mayor;
  final int menor;
  final int parche;
  final int build;

  /// Intenta parsear una cadena con el formato `X.Y.Z+N` o
  /// `uno-roto-X.Y.Z+N`. Devuelve `null` si no encaja — los call-sites
  /// tratan ese caso como "no hay versión nueva" (fallar en silencio,
  /// no romper el banner).
  static VersionApp? parse(String entrada) {
    final limpia = entrada.trim();
    if (limpia.isEmpty) return null;
    // Patrón: opcional prefijo "uno-roto-" + X.Y.Z + opcional +N.
    final patron = RegExp(r'^(?:uno-roto-)?(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');
    final coincidencia = patron.firstMatch(limpia);
    if (coincidencia == null) return null;
    final mayor = int.tryParse(coincidencia.group(1)!);
    final menor = int.tryParse(coincidencia.group(2)!);
    final parche = int.tryParse(coincidencia.group(3)!);
    final build = int.tryParse(coincidencia.group(4) ?? '0') ?? 0;
    if (mayor == null || menor == null || parche == null) return null;
    return VersionApp(mayor: mayor, menor: menor, parche: parche, build: build);
  }

  /// Construye desde `PackageInfo`: la `version` ya viene como
  /// `X.Y.Z` y el `buildNumber` como string del entero.
  static VersionApp deStrings({
    required String version,
    required String buildNumber,
  }) {
    final partes = version.split('.');
    if (partes.length != 3) {
      throw FormatException('version no tiene formato X.Y.Z: $version');
    }
    return VersionApp(
      mayor: int.parse(partes[0]),
      menor: int.parse(partes[1]),
      parche: int.parse(partes[2]),
      build: int.tryParse(buildNumber) ?? 0,
    );
  }

  @override
  int compareTo(VersionApp otro) {
    if (mayor != otro.mayor) return mayor.compareTo(otro.mayor);
    if (menor != otro.menor) return menor.compareTo(otro.menor);
    if (parche != otro.parche) return parche.compareTo(otro.parche);
    return build.compareTo(otro.build);
  }

  bool operator >(VersionApp otro) => compareTo(otro) > 0;
  bool operator <(VersionApp otro) => compareTo(otro) < 0;
  bool operator >=(VersionApp otro) => compareTo(otro) >= 0;
  bool operator <=(VersionApp otro) => compareTo(otro) <= 0;

  @override
  bool operator ==(Object other) =>
      other is VersionApp &&
      other.mayor == mayor &&
      other.menor == menor &&
      other.parche == parche &&
      other.build == build;

  @override
  int get hashCode => Object.hash(mayor, menor, parche, build);

  /// Formato canónico `X.Y.Z+N`. La página del release lo lleva como
  /// `1.0.0+17`, sin el prefijo `uno-roto-`.
  @override
  String toString() => '$mayor.$menor.$parche+$build';
}
