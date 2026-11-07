import 'dart:convert';

/// Tipo de pasto a efectos del eco-régimen (RD 1048/2022, art. 30.2.b).
const String pastoMediterraneo = 'mediterraneo';
const String pastoHumedo = 'humedo';
const List<String> tiposPasto = [pastoMediterraneo, pastoHumedo];

/// Quién es dueño de la pieza.
const List<String> titularidadesPieza = [
  'propia',
  'arrendada',
  'comunal',
  'cedida',
];

/// Una pieza de pasto: la unidad en la que se mueve el ganado y se mide la
/// carga. Si coincide con un recinto SIGPAC, el informe del eco-régimen
/// sale por recinto.
class PiezaPasto {
  PiezaPasto({
    this.id,
    required this.nombre,
    this.recintoSigpac = '',
    this.superficieHa,
    this.tipoPasto = pastoMediterraneo,
    this.titularidad = 'propia',
    this.contorno = const [],
    this.activa = true,
    this.notas = '',
  });

  final int? id;
  final String nombre;

  /// Referencia SIGPAC (polígono, parcela, recinto), en texto libre.
  final String recintoSigpac;

  /// Superficie de pasto en hectáreas; null = sin medir.
  final double? superficieHa;

  /// Código de [tiposPasto].
  final String tipoPasto;

  /// Código de [titularidadesPieza].
  final String titularidad;

  /// Vértices (latitud, longitud) tomados con el GPS.
  final List<(double, double)> contorno;
  final bool activa;
  final String notas;

  PiezaPasto conContorno(List<(double, double)> nuevoContorno) => PiezaPasto(
        id: id,
        nombre: nombre,
        recintoSigpac: recintoSigpac,
        superficieHa: superficieHa,
        tipoPasto: tipoPasto,
        titularidad: titularidad,
        contorno: nuevoContorno,
        activa: activa,
        notas: notas,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'recinto_sigpac': recintoSigpac,
        'superficie_ha': superficieHa,
        'tipo_pasto': tipoPasto,
        'titularidad': titularidad,
        'contorno': jsonEncode([
          for (final (latitud, longitud) in contorno) [latitud, longitud]
        ]),
        'activa': activa ? 1 : 0,
        'notas': notas,
      };

  factory PiezaPasto.fromMap(Map<String, Object?> mapa) => PiezaPasto(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        recintoSigpac: (mapa['recinto_sigpac'] as String?) ?? '',
        superficieHa: (mapa['superficie_ha'] as num?)?.toDouble(),
        tipoPasto: (mapa['tipo_pasto'] as String?) ?? pastoMediterraneo,
        titularidad: (mapa['titularidad'] as String?) ?? 'propia',
        contorno: leerContorno(mapa['contorno'] as String?),
        activa: ((mapa['activa'] as num?)?.toInt() ?? 1) != 0,
        notas: (mapa['notas'] as String?) ?? '',
      );
}

/// Lee el contorno guardado; uno roto o vacío da una lista vacía.
List<(double, double)> leerContorno(String? texto) {
  if (texto == null || texto.isEmpty) return const [];
  try {
    final lista = jsonDecode(texto);
    if (lista is! List) return const [];
    return [
      for (final punto in lista)
        if (punto is List &&
            punto.length == 2 &&
            punto[0] is num &&
            punto[1] is num)
          ((punto[0] as num).toDouble(), (punto[1] as num).toDouble()),
    ];
  } on FormatException {
    return const [];
  }
}
