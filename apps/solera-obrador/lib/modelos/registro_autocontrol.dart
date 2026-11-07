/// Tipos de registro del cuaderno de autocontrol. Una sola tabla para
/// todos (decisión 2026-11-07): el cuaderno mensual sale de una consulta.
const List<String> tiposRegistroAutocontrol = [
  'temperatura', // cámaras, neveras, recepción
  'limpieza', // zona o equipo limpiado
  'plagas', // revisión de cebos o trampas
  'proveedor', // recepción de mercancía conforme o no
  'formacion', // manipuladores
  'incidencia', // algo fue mal y qué se hizo
];

/// Un apunte del cuaderno de autocontrol.
class RegistroAutocontrol {
  RegistroAutocontrol({
    this.id,
    required this.tipo,
    required this.fechaMs,
    required this.elemento,
    this.valor,
    this.correcto = true,
    this.accionCorrectora = '',
    this.responsable = '',
    this.notas = '',
  }) : assert(tiposRegistroAutocontrol.contains(tipo));

  final int? id;
  final String tipo;
  final int fechaMs;

  /// Qué se controla: «Cámara 1», «Amasadora», «Harinera Ejemplo»…
  final String elemento;

  /// Lectura numérica cuando la hay (temperatura en °C).
  final double? valor;
  final bool correcto;

  /// Obligatoria en la práctica cuando [correcto] es falso.
  final String accionCorrectora;
  final String responsable;
  final String notas;

  bool get faltaAccionCorrectora =>
      !correcto && accionCorrectora.trim().isEmpty;

  Map<String, Object?> toMap() => {
        'id': id,
        'tipo': tipo,
        'fecha_ms': fechaMs,
        'elemento': elemento,
        'valor': valor,
        'correcto': correcto ? 1 : 0,
        'accion_correctora': accionCorrectora,
        'responsable': responsable,
        'notas': notas,
      };

  factory RegistroAutocontrol.fromMap(Map<String, Object?> mapa) =>
      RegistroAutocontrol(
        id: mapa['id'] as int?,
        tipo: mapa['tipo'] as String,
        fechaMs: mapa['fecha_ms'] as int,
        elemento: mapa['elemento'] as String,
        valor: (mapa['valor'] as num?)?.toDouble(),
        correcto: (mapa['correcto'] as int?) != 0,
        accionCorrectora: (mapa['accion_correctora'] as String?) ?? '',
        responsable: (mapa['responsable'] as String?) ?? '',
        notas: (mapa['notas'] as String?) ?? '',
      );
}
