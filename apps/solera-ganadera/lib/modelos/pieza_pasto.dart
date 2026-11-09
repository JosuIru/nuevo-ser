import 'package:latlong2/latlong.dart';
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart'
    show codificarContorno, leerContorno, superficieHectareas, tieneArea;

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

  /// Esquinas del área (caminadas con el GPS, dibujadas o importadas con
  /// el editor de `nuevo_ser_mapa`). Columna `contorno`, JSON `[[lat,lng],…]`.
  final List<LatLng> contorno;
  final bool activa;
  final String notas;

  bool get tieneContorno => tieneArea(contorno);

  /// Superficie del área dibujada (ha, orientativa); 0 sin área.
  double get superficieCalculadaHa => superficieHectareas(contorno);

  /// Con el área nueva. Si la pieza no tenía superficie, toma la calculada
  /// (la que se haya escrito a mano manda: no se pisa).
  PiezaPasto conContorno(List<LatLng> nuevoContorno) {
    final calculada = superficieHectareas(nuevoContorno);
    return PiezaPasto(
      id: id,
      nombre: nombre,
      recintoSigpac: recintoSigpac,
      superficieHa: superficieHa ?? (calculada > 0 ? calculada : null),
      tipoPasto: tipoPasto,
      titularidad: titularidad,
      contorno: nuevoContorno,
      activa: activa,
      notas: notas,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'nombre': nombre,
        'recinto_sigpac': recintoSigpac,
        'superficie_ha': superficieHa,
        'tipo_pasto': tipoPasto,
        'titularidad': titularidad,
        'contorno': codificarContorno(contorno),
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
