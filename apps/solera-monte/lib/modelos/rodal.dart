import '../utiles/geodesia.dart';
import 'contorno.dart';
import 'lista_ids.dart';

/// Estado de la masa del rodal (descripción selvícola sencilla).
const List<String> estadosMasa = [
  'repoblado',
  'monte_bajo',
  'latizal',
  'fustal',
  'masa_irregular',
  'raso',
  'quemado',
];

/// Unidad de gestión del monte: una superficie con especie, edad y estado
/// parecidos. Su contorno se dibuja caminando la linde con el GPS.
class Rodal {
  Rodal({
    this.id,
    required this.codigo,
    this.nombre = '',
    required this.especiePrincipalId,
    this.especiesSecundarias = const [],
    this.anyoOrigen,
    this.estadoMasa = 'fustal',
    this.superficieDeclaradaHa,
    this.contorno = const [],
    this.notas = '',
  });

  final int? id;

  /// Código del rodal en el plan («1a», «R-03»…). Único.
  final String codigo;
  final String nombre;

  /// Id del catálogo de especies forestales.
  final String especiePrincipalId;
  final List<String> especiesSecundarias;

  /// Año de la plantación, la regeneración o la última corta a hecho; con él
  /// se calcula la edad. null = desconocida.
  final int? anyoOrigen;

  /// Uno de [estadosMasa].
  final String estadoMasa;

  /// Superficie del plan o de la escritura (ha); null = sin dato.
  final double? superficieDeclaradaHa;

  /// Vértices (latitud, longitud) tomados con el GPS.
  final List<(double, double)> contorno;
  final String notas;

  bool get tieneContorno => contorno.length >= 3;

  /// Superficie del polígono (ha, orientativa: exceso esférico); 0 sin
  /// contorno.
  double get superficieCalculadaHa => superficieHectareas(aLatLng(contorno));

  /// La declarada si la hay; si no, la calculada (0 sin ninguna).
  double get superficieHa => superficieDeclaradaHa ?? superficieCalculadaHa;

  /// Nombre para listas: «1a · Pinar de arriba».
  String get etiqueta => nombre.isEmpty ? codigo : '$codigo · $nombre';

  /// Edad en [anyo]; null sin año de origen o si es posterior.
  int? edadEn(int anyo) {
    final origen = anyoOrigen;
    if (origen == null || origen > anyo) return null;
    return anyo - origen;
  }

  Rodal conContorno(List<(double, double)> nuevoContorno) =>
      Rodal.fromMap({...toMap(), 'contorno': codificarContorno(nuevoContorno)});

  Map<String, Object?> toMap() => {
        'id': id,
        'codigo': codigo,
        'nombre': nombre,
        'especie_principal_id': especiePrincipalId,
        'especies_secundarias': unirLista(especiesSecundarias),
        'anyo_origen': anyoOrigen,
        'estado_masa': estadoMasa,
        'superficie_declarada_ha': superficieDeclaradaHa,
        'contorno': codificarContorno(contorno),
        'notas': notas,
      };

  factory Rodal.fromMap(Map<String, Object?> mapa) => Rodal(
        id: mapa['id'] as int?,
        codigo: (mapa['codigo'] as String?) ?? '',
        nombre: (mapa['nombre'] as String?) ?? '',
        especiePrincipalId: (mapa['especie_principal_id'] as String?) ?? '',
        especiesSecundarias:
            separarLista(mapa['especies_secundarias'] as String?),
        anyoOrigen: mapa['anyo_origen'] as int?,
        estadoMasa: estadosMasa.contains(mapa['estado_masa'])
            ? mapa['estado_masa'] as String
            : 'fustal',
        superficieDeclaradaHa:
            (mapa['superficie_declarada_ha'] as num?)?.toDouble(),
        contorno: leerContorno(mapa['contorno'] as String?),
        notas: (mapa['notas'] as String?) ?? '',
      );
}
