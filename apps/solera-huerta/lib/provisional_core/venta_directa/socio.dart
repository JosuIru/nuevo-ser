// PROVISIONAL CORE — módulo transversal T2 (venta directa) del plan
// (docs/plan-verticales-larrea.md). Vive aquí hasta que la calle N lo suba a
// nuevo_ser_core; entonces esta carpeta se sustituye por el import del core.

/// Persona o familia socia del grupo de consumo que recibe cestas.
class Socio {
  Socio({
    this.id,
    required this.nombre,
    this.telefono = '',
    this.correo = '',
    this.grupoConsumo = '',
    this.puntoEntrega = '',
    this.activo = true,
    this.notas = '',
  });

  final int? id;
  final String nombre;
  final String telefono;
  final String correo;

  /// Grupo de consumo o asociación por la que llega, si la hay.
  final String grupoConsumo;

  /// Dónde recoge la cesta (local del grupo, la propia huerta…).
  final String puntoEntrega;

  /// Un socio que se va se desactiva: sus cestas y entregas se conservan.
  final bool activo;

  /// Alergias, lo que no quiere en la cesta, horarios…
  final String notas;

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        'correo': correo,
        'grupo_consumo': grupoConsumo,
        'punto_entrega': puntoEntrega,
        'activo': activo ? 1 : 0,
        'notas': notas,
      };

  factory Socio.fromMap(Map<String, Object?> mapa) => Socio(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        telefono: (mapa['telefono'] as String?) ?? '',
        correo: (mapa['correo'] as String?) ?? '',
        grupoConsumo: (mapa['grupo_consumo'] as String?) ?? '',
        puntoEntrega: (mapa['punto_entrega'] as String?) ?? '',
        activo: (mapa['activo'] as int?) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}
